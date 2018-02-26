﻿#include "stdafx.h"
#include "WeaselTrayIcon.h"

// nasty
#include "../WeaselServer/resource.h"

static UINT mode_icon[] = { IDI_ZH, IDI_ZH, IDI_EN, IDI_RELOAD };
static const WCHAR *mode_label[] = { NULL, /*L"中文"*/ NULL, /*L"西文"*/ NULL, L"維護中" };

WeaselTrayIcon::WeaselTrayIcon(weasel::UI &ui)
    : m_style(ui.style()), m_status(ui.status()), m_mode(INITIAL)
{
}

void WeaselTrayIcon::CustomizeMenu(HMENU hMenu)
{
}

BOOL WeaselTrayIcon::Create(HWND hTargetWnd)
{
    HMODULE hModule = GetModuleHandle(NULL);
    CIcon icon;
    icon.LoadIconW(IDI_ZH);
    BOOL bRet = CSystemTray::Create(hModule, NULL, WM_WEASEL_TRAY_NOTIFY,
                                    WEASEL_IME_NAME, icon, IDR_MENU_POPUP);

    if (hTargetWnd) {
        SetTargetWnd(hTargetWnd);
    }

    if (!m_style.display_tray_icon) {
        RemoveIcon();
    }

    return bRet;
}

void WeaselTrayIcon::Refresh()
{
    if (!m_style.display_tray_icon) {
        if (m_mode != INITIAL) {
            RemoveIcon();
            m_mode = INITIAL;
        }

        return;
    }

    WeaselTrayMode mode = m_status.disabled ? DISABLED :
                          m_status.ascii_mode ? ASCII : ZHUNG;

    if (mode != m_mode) {
        m_mode = mode;
        ShowIcon();
        SetIcon(mode_icon[mode]);

        if (mode_label[mode]) {
            ShowBalloon(mode_label[mode], WEASEL_IME_NAME);
        }
    } else if (!Visible()) {
        ShowIcon();
    }
}
