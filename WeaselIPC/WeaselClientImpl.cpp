﻿#include "stdafx.h"
#include "WeaselClientImpl.h"
#include <StringAlgorithm.hpp>

using namespace weasel;

ClientImpl::ClientImpl()
    : session_id(0),
      pipe(INVALID_HANDLE_VALUE),
      is_ime(false),
      has_cnt(false)
{
    buffer = std::make_unique<char[]>(WEASEL_IPC_SHARED_MEMORY_SIZE);
    _InitializeClientInfo();
}

ClientImpl::~ClientImpl()
{
    if (_Connected())
        Disconnect();
}

//http://stackoverflow.com/questions/557081/how-do-i-get-the-hmodule-for-the-currently-executing-code
HMODULE GetCurrentModule()
{
    // NB: XP+ solution!
    HMODULE hModule = NULL;
    GetModuleHandleEx(
        GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
        (LPCTSTR)GetCurrentModule,
        &hModule);
    return hModule;
}

void ClientImpl::_InitializeClientInfo()
{
    // get app name
    WCHAR exe_path[MAX_PATH] = {0};
    GetModuleFileName(NULL, exe_path, MAX_PATH);
    std::wstring path = exe_path;
    size_t separator_pos = path.find_last_of(L"\\/");

    if (separator_pos < path.size())
        app_name = path.substr(separator_pos + 1);
    else
        app_name = path;

    to_lower(app_name);
    // determine client type
    GetModuleFileName(GetCurrentModule(), exe_path, MAX_PATH);
    path = exe_path;
    to_lower(path);
    is_ime = ends_with(path, L".ime");
}

bool ClientImpl::Connect(ServerLauncher const& launcher)
{
    auto pipe_name = GetPipeName();
    _ConnectPipe(pipe_name.c_str());
    return _Connected();
}

void ClientImpl::Disconnect()
{
    if (_Active())
        EndSession();

    DisconnectNamedPipe(pipe);
    CloseHandle(pipe);
    pipe = INVALID_HANDLE_VALUE;
}

void ClientImpl::ShutdownServer()
{
    if (_Connected()) {
        _SendMessage(WEASEL_IPC_SHUTDOWN_SERVER, 0, 0);
    }
}

bool ClientImpl::ProcessKeyEvent(KeyEvent const& keyEvent)
{
    if (!_Active())
        return false;

    LRESULT ret = _SendMessage(WEASEL_IPC_PROCESS_KEY_EVENT, keyEvent, session_id);
    return ret != 0;
}

bool ClientImpl::CommitComposition()
{
    if (!_Active())
        return false;

    LRESULT ret = _SendMessage(WEASEL_IPC_COMMIT_COMPOSITION, 0, session_id);
    return ret != 0;
}

bool ClientImpl::ClearComposition()
{
    if (!_Active())
        return false;

    LRESULT ret = _SendMessage(WEASEL_IPC_CLEAR_COMPOSITION, 0, session_id);
    return ret != 0;
}

void ClientImpl::UpdateInputPosition(RECT const& rc)
{
    if (!_Active())
        return;

    /*
    移位标志 = 1bit == 0
    height:0~127 = 7bit
    top:-2048~2047 = 12bit（有符号）
    left:-2048~2047 = 12bit（有符号）

    高解析度下：
    移位标志 = 1bit == 1
    height:0~254 = 7bit（舍弃低1位）
    top:-4096~4094 = 12bit（有符号，舍弃低1位）
    left:-4096~4094 = 12bit（有符号，舍弃低1位）
    */
    int hi_res = static_cast<int>(rc.bottom - rc.top >= 128 ||
                                  rc.left < -2048 || rc.left >= 2048 || rc.top < -2048 || rc.top >= 2048);
    int left = max(-2048, min(2047, rc.left >> hi_res));
    int top = max(-2048, min(2047, rc.top >> hi_res));
    int height = max(0, min(127, (rc.bottom - rc.top) >> hi_res));
    DWORD compressed_rect = ((hi_res & 0x01) << 31) | ((height & 0x7f) << 24) |
                            ((top & 0xfff) << 12) | (left & 0xfff);
    _SendMessage(WEASEL_IPC_UPDATE_INPUT_POS, compressed_rect, session_id);
}

void ClientImpl::FocusIn()
{
    DWORD client_caps = 0;  /* TODO */
    _SendMessage(WEASEL_IPC_FOCUS_IN, client_caps, session_id);
}

void ClientImpl::FocusOut()
{
    _SendMessage(WEASEL_IPC_FOCUS_OUT, 0, session_id);
}

void ClientImpl::StartSession()
{
    if (!_Connected())
        return;

    if (_Active() && Echo())
        return;

    _WriteClientInfo();
    has_cnt = true;
    UINT ret = _SendMessage(WEASEL_IPC_START_SESSION, 0, 0);
    session_id = ret;
}

void ClientImpl::EndSession()
{
    if (_Connected())
        _SendMessage(WEASEL_IPC_END_SESSION, 0, session_id);

    session_id = 0;
}

void ClientImpl::StartMaintenance()
{
    if (_Connected())
        _SendMessage(WEASEL_IPC_START_MAINTENANCE, 0, 0);

    session_id = 0;
}

void ClientImpl::EndMaintenance()
{
    if (_Connected())
        _SendMessage(WEASEL_IPC_END_MAINTENANCE, 0, 0);

    session_id = 0;
}

bool ClientImpl::Echo()
{
    if (!_Active())
        return false;

    UINT serverEcho = _SendMessage(WEASEL_IPC_ECHO, 0, session_id);
    return (serverEcho == session_id);
}

bool ClientImpl::GetResponseData(ResponseHandler const& handler)
{
    if (!handler) {
        return false;
    }

    return handler((LPWSTR)buffer.get(), WEASEL_IPC_BUFFER_LENGTH);
}

void ClientImpl::_ConnectPipe(const wchar_t * pipeName)
{
    bool err = false;
    DWORD connectErr;

    for (;;) {
        pipe = CreateFile(pipeName, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);

        if (pipe != INVALID_HANDLE_VALUE) {
            // connected to the pipe
            break;
        }

        // being busy is not really an error since we just need to wait.
        if ((connectErr = GetLastError()) != ERROR_PIPE_BUSY) {
            err = true; // otherwise, pipe creation fails
            break;
        }

        // All pipe instances are busy, so wait for 2 seconds.
        if (!WaitNamedPipe(pipeName, 2000)) {
            err = true;
            break;
        }
    }

    if (!err) {
        // The pipe is connected; change to message-read mode.
        DWORD mode = PIPE_READMODE_MESSAGE;

        if (!SetNamedPipeHandleState(pipe, &mode, NULL, NULL)) {
            err = true;
        }
    }

    // the pipe is created, but errors happened, destroy it.
    if (err && pipe != INVALID_HANDLE_VALUE) {
        DisconnectNamedPipe(pipe);
        CloseHandle(pipe);
        pipe = INVALID_HANDLE_VALUE;
    }
}


bool ClientImpl::_WriteClientInfo()
{
    WCHAR* buffer = _GetSendBuffer();
    DWORD written = 0;
    memset(buffer, 0, WEASEL_IPC_BUFFER_SIZE);
    wbufferstream bs(buffer, WEASEL_IPC_BUFFER_LENGTH);
    bs << L"action=session\n";
    bs << L"session.client_app=" << app_name.c_str() << L"\n";
    bs << L"session.client_type=" << (is_ime ? L"ime" : L"tsf") << L"\n";
    bs << L".\n";

    if (!bs.good()) {
        // response text toooo long!
        return false;
    }

    return true;
}


LRESULT ClientImpl::_SendMessage(WEASEL_IPC_COMMAND Msg, DWORD wParam, DWORD lParam)
{
    PipeMessage msg{ Msg, wParam, lParam };
    DWORD result = 0;
    DWORD read = 0, written = 0;
    DWORD errCode;
    char *buffer_ptr = buffer.get();
    DWORD write_len = has_cnt ? WEASEL_IPC_SHARED_MEMORY_SIZE : sizeof(PipeMessage);
    //memcpy(buffer, &msg, sizeof(PipeMessage));
    *reinterpret_cast<PipeMessage *>(buffer_ptr) = msg;

    if (!WriteFile(pipe, buffer_ptr, write_len, &written, NULL)) {
        return 0;
    }

    has_cnt = false;
    FlushFileBuffers(pipe);

    if (!ReadFile(pipe, (LPVOID)&result, sizeof(DWORD), &read, NULL)) {
        if ((errCode = GetLastError()) != ERROR_MORE_DATA) {
            return 0;
        }

        char *buffer_ptr = buffer.get();
        memset(buffer_ptr, 0, WEASEL_IPC_BUFFER_SIZE);

        if (!ReadFile(pipe, buffer_ptr, WEASEL_IPC_BUFFER_SIZE, &read, NULL)) {
            return 0;
        }
    }

    return result;
}


Client::Client()
    : m_pImpl(new ClientImpl())
{}

Client::~Client()
{
    if (m_pImpl)
        delete m_pImpl;
}

bool Client::Connect(ServerLauncher launcher)
{
    return m_pImpl->Connect(launcher);
}

void Client::Disconnect()
{
    m_pImpl->Disconnect();
}

void Client::ShutdownServer()
{
    m_pImpl->ShutdownServer();
}

bool Client::ProcessKeyEvent(KeyEvent const& keyEvent)
{
    return m_pImpl->ProcessKeyEvent(keyEvent);
}

bool Client::CommitComposition()
{
    return m_pImpl->CommitComposition();
}

bool Client::ClearComposition()
{
    return m_pImpl->ClearComposition();
}

void Client::UpdateInputPosition(RECT const& rc)
{
    m_pImpl->UpdateInputPosition(rc);
}

void Client::FocusIn()
{
    m_pImpl->FocusIn();
}

void Client::FocusOut()
{
    m_pImpl->FocusOut();
}

void Client::StartSession()
{
    m_pImpl->StartSession();
}

void Client::EndSession()
{
    m_pImpl->EndSession();
}

void Client::StartMaintenance()
{
    m_pImpl->StartMaintenance();
}

void Client::EndMaintenance()
{
    m_pImpl->EndMaintenance();
}

bool Client::Echo()
{
    return m_pImpl->Echo();
}

bool Client::GetResponseData(ResponseHandler handler)
{
    return m_pImpl->GetResponseData(handler);
}
