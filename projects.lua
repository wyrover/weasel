BOOK_CODE_PATH = "E:/book-code"
THIRD_PARTY = "E:/book-code/3rdparty"
WORK_PATH = os.getcwd()
includeexternal (WORK_PATH .. "/premake-vs-include.lua")




workspace(path.getname(os.realpath(".")))
    language "C++"
    location "build/%{_ACTION}/%{wks.name}"    
    if _ACTION == "vs2017" then
        toolset "v141_xp"
    elseif _ACTION == "vs2015" then
        toolset "v140_xp"
    elseif _ACTION == "vs2013" then
        toolset "v120_xp"
    end

    --include (BOOK_CODE_PATH .. "/common.lua")    
    


    function create_example_project(name, dir)        
        project(name)          
        kind "ConsoleApp"                                             
        files
        {                                  
            dir .. "/%{prj.name}/**.h",
            dir .. "/%{prj.name}/**.cpp", 
            dir .. "/%{prj.name}/**.c", 
            dir .. "/%{prj.name}/**.rc",            
        }
        removefiles
        {               
        }
        includedirs
        {               
            "3rdparty/dawgdic/src",   
        }         
        has_stdafx(name, dir)               
    end    
    

    group "客户端"    

        project "WeaselIME"          
            kind "SharedLib" 
            defines { "WEASELIME_EXPORTS" } 
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselIME/**.h",
                "WeaselIME/**.cpp",
                "WeaselIME/**.rc",
                "WeaselIME/**.def",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                "H:/rover/rover-self-work/cpp/boost_1_66_0"
                
            }  
            libdirs
            {
                "H:/rover/rover-self-work/cpp/boost_1_66_0/stage/win32/lib"
            }
            links
            {
                "WeaselIPC",
                "imm32.lib"
            }
            has_stdafx("WeaselIME", ".")

        project "WeaselTSF"          
            kind "SharedLib" 
            defines { "WEASELTSF_EXPORTS" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselTSF/**.h",
                "WeaselTSF/**.cpp",
                "WeaselTSF/**.def",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                
            }  
            links
            {
                "WeaselIPC",
            }
            has_stdafx("WeaselTSF", ".")


        project "WeaselSetup"          
            kind "WindowedApp"
            --defines { "PTW32_STATIC_LIB" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselSetup/**.h",
                "WeaselSetup/**.cpp",
                "WeaselSetup/**.rc",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                
            }  
            links
            {
                "imm32.lib"
            }
            has_stdafx("WeaselSetup", ".")

        project "WeaselDeployer"          
            kind "WindowedApp"
            --defines { "PTW32_STATIC_LIB" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselDeployer/**.h",
                "WeaselDeployer/**.cpp",
                "WeaselDeployer/**.rc",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                "librime/src",
                
            }  
            links
            {
                "rime.lib",
                "WeaselIPC",
                "RimeWithWeasel"
            }
            has_stdafx("WeaselDeployer", ".")

    group "test"

        project "TestWeaselIPC"          
            kind "ConsoleApp"
            --defines { "PTW32_STATIC_LIB" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "test/TestWeaselIPC/**.h",
                "test/TestWeaselIPC/**.cpp",
                "test/TestWeaselIPC/**.rc",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                
                
            }  
            links
            {
                
                "WeaselIPC",
                "WeaselIPCServer"
                
            }
            has_stdafx("TestWeaselIPC", "test")

        project "TestResponseParser"          
            kind "ConsoleApp"
            --defines { "PTW32_STATIC_LIB" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "test/TestResponseParser/**.h",
                "test/TestResponseParser/**.cpp",
                "test/TestResponseParser/**.rc",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                "librime/src",
                
            }  
            links
            {
                
                "rime.lib",
                "RimeWithWeasel",
                "WeaselIPC",
               
                
            }
            has_stdafx("TestResponseParser", "test")
 
            
        project "librime-test"          
            kind "ConsoleApp"
            defines { "RIME_IMPORTS" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "librime/test/**.h",
                "librime/test/**.cc",
                
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "librime/thirdparty/src/gtest/include",
                "librime/thirdparty/include",
                "librime/thirdparty/src/opencc/deps/darts-clone",
                "librime/src",
                
            }  
            links
            {
                
                "gtest",
                "rime.lib",
                
               
                
            }
           
--        project "rime_console"          
--            kind "ConsoleApp"
--            defines { "RIME_IMPORTS" }
--            vpaths 
--            { 
--                ["Header Files"] = {"**.h", "**.hpp"},
--                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
--                ["Resource Files"] = {"**.rc", "**.rc2"}
--            }
--            files
--            {              
--                
--                "librime/tools/rime_console.cc",
--                
--                
--                
--                
--                
--            }
--            removefiles
--            {     
--            
--            }
--            includedirs
--            {               
--                
--                "librime/thirdparty/include",               
--                "librime/src",
--                
--            }  
--            links
--            {
--                
--               
--                "rime.lib",
--                
--               
--                
--            }

    group "服务端"

        project "WeaselServer"          
            kind "WindowedApp"
            --defines { "PTW32_STATIC_LIB" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselServer/**.h",
                "WeaselServer/**.cpp",
                "WeaselServer/**.rc",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                
            }  
            libdirs
            {
                "lib"
            }
            links
            {
                "WeaselUI",
                "WeaselIPC",
                "WeaselIPCServer",
                "RimeWithWeasel",
                "rime.lib",
                "imm32.lib",
                "Usp10.lib",
            }
            has_stdafx("WeaselServer", ".")

        

    group "中间层"

        project "WeaselIPC"          
            kind "StaticLib"
            --defines { "PTW32_STATIC_LIB" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselIPC/**.h",
                "WeaselIPC/**.cpp",
                "WeaselIPC/**.rc",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include"
                
            }  
            links
            {
                
            }
            has_stdafx("WeaselIPC", ".")

        project "WeaselIPCServer"          
            kind "StaticLib" 
            defines { "_WIN32_WINNT=0x0600" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselIPCServer/**.h",
                "WeaselIPCServer/**.cpp",
                "WeaselIPCServer/**.rc",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include"
                
            }  
            links
            {
                
            }
            has_stdafx("WeaselIPCServer", ".")


        


        project "WeaselUI"          
            kind "StaticLib" 
            --defines { "PTW32_STATIC_LIB" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "WeaselUI/**.h",
                "WeaselUI/**.cpp",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                
            }  
            links
            {
                
            }
            has_stdafx("WeaselUI", ".")

        project "RimeWithWeasel"          
            kind "StaticLib" 
            defines { "_WIN32_WINNT=0x0600" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "RimeWithWeasel/**.h",
                "RimeWithWeasel/**.cpp",
                
                
                
            }
            removefiles
            {     
            
            }
            includedirs
            {               
                "include",
                "librime/src",
                
            }  
            links
            {
                
            }
            has_stdafx("RimeWithWeasel", ".")

        project "rime"          
            kind "SharedLib"
            defines { 
                "RIME_VERSION=\"1.2.9\"", 
                --"RIME_ENABLE_LOGGING",
                "GOOGLE_GLOG_DLL_DECL=",
                "Opencc_BUILT_AS_STATIC",
                "BOOST_SIGNALS2",
                "RIME_BUILD_SHARED_LIBS",
                "RIME_EXPORTS"
            }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "librime/src/**.h",
                "librime/src/**.cc",
                
                
                
            }
            removefiles
            {     
               
                
            }
            includedirs
            {               
               
                "librime/src",
                "librime/thirdparty/include",
                "librime/include",
            }  
            links
            {
                "libglog",
                "yaml-cpp",
                "leveldb",
                "libmarisa",
                "libopencc.lib",
            }
            
    
    
    group "3rdparty"

        project "leveldb"          
            kind "StaticLib" 
            defines { "LEVELDB_PLATFORM_WINDOWS", "OS_WIN" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                
                "librime/thirdparty/src/leveldb-windows/**.h",
                "librime/thirdparty/src/leveldb-windows/**.cc",
                
                
                
            }
            removefiles
            {     
                "**_test.cc",
                "**db_bench**.cc",
                "**env_posix.cc",
                "**port_android.cc",
                "**port_posix.cc",
            }
            includedirs
            {               
                "librime/thirdparty/src/leveldb-windows/include",
                "librime/thirdparty/src/leveldb-windows"
                
            }  
            links
            {
                
            }


        project "libglog"          
            kind "StaticLib" 
            defines { "HAVE_SNPRINTF", "GOOGLE_GLOG_DLL_DECL=", "GLOG_NO_ABBREVIATED_SEVERITIES" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              

            
                
                "librime/thirdparty/src/glog-master/vc/glog/logging.h",
                "librime/thirdparty/src/glog-master/vc/glog/raw_logging.h",
                "librime/thirdparty/src/glog-master/vc/glog/stl_logging.h",
                "librime/thirdparty/src/glog-master/vc/glog/vlog_is_on.h",
                "librime/thirdparty/src/glog-master/src/glog/log_severity.h",
                "librime/thirdparty/src/glog-master/src/base/commandlineflags.h",
                "librime/thirdparty/src/glog-master/src/base/googleinit.h",
                "librime/thirdparty/src/glog-master/src/base/mutex.h",
                "librime/thirdparty/src/glog-master/src/demangle.h",
                "librime/thirdparty/src/glog-master/src/symbolize.h",
                "librime/thirdparty/src/glog-master/src/utilities.h",
                "librime/thirdparty/src/glog-master/src/windows/port.h",
                "librime/thirdparty/src/glog-master/src/demangle.cc",
                "librime/thirdparty/src/glog-master/src/logging.cc",
                "librime/thirdparty/src/glog-master/src/raw_logging.cc",
                "librime/thirdparty/src/glog-master/src/symbolize.cc",
                "librime/thirdparty/src/glog-master/src/utilities.cc",
                "librime/thirdparty/src/glog-master/src/vlog_is_on.cc",
                "librime/thirdparty/src/glog-master/src/signalhandler.cc",
                "librime/thirdparty/src/glog-master/src/windows/port.cc",
                
                
                
            }
            removefiles
            {     
               
            }
            includedirs
            {               
                "librime/thirdparty/src/glog-master/src/windows",
                
                
            }  
            links
            {
                
            }
           
        project "yaml-cpp"          
            kind "StaticLib" 
--            defines { "LEVELDB_PLATFORM_WINDOWS", "OS_WIN" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                "librime/thirdparty/src/yaml-cpp/include/**.h",
                "librime/thirdparty/src/yaml-cpp/src/**.h",
                "librime/thirdparty/src/yaml-cpp/src/**.cpp",
               
                
                
                
            }
            removefiles
            {     
               
               
            }
            includedirs
            {               
                "librime/thirdparty/src/yaml-cpp/include",
                
                
            }  
            links
            {
                
            }

        
        project "gtest"          
            kind "StaticLib" 
            defines { "STRICT", "GTEST_HAS_PTHREAD=0", "_HAS_EXCEPTIONS=1" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                "librime/thirdparty/src/gtest/src/gtest-all.cc",
                
               
                
                
                
            }
            removefiles
            {     
                
               
            }
            includedirs
            {               
                "librime/thirdparty/src/gtest/include",
                "librime/thirdparty/src/gtest",
                
                
            }  
            links
            {
                
            }

        project "libopencc"          
            kind "StaticLib" 
            defines { "VERSION=\"1.0.2\"", "PACKAGE_NAME=\"opencc\"", "Opencc_BUILT_AS_STATIC" }
--            vpaths 
--            { 
--                ["Header Files"] = {"**.h", "**.hpp"},
--                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
--                ["Resource Files"] = {"**.rc", "**.rc2"}
--            }
            files
            {              
                "librime/thirdparty/src/opencc/src/**.hpp",
                "librime/thirdparty/src/opencc/src/**.cpp",
               
                
                
                
            }
            removefiles
            {     
                
                "librime/thirdparty/src/opencc/src/tools/**",
                "librime/thirdparty/src/opencc/src/BinaryDictTest.cpp",
                "librime/thirdparty/src/opencc/src/CmdLineOutput.hpp",
                "librime/thirdparty/src/opencc/src/*Test.cpp",
                "librime/thirdparty/src/opencc/src/DictGroupTestBase.hpp",
                "librime/thirdparty/src/opencc/src/TextDictTestBase.hpp",

                
               
            }
            includedirs
            {               
                
                "librime/thirdparty/src/opencc/src/../deps/darts-clone",
                "librime/thirdparty/src/opencc/src/../deps/rapidjson-0.11",
                "librime/thirdparty/src/opencc/src/../deps/tclap-1.2.1",
                
            }  
            links
            {
                
            }
           

        project "libmarisa"          
            kind "StaticLib" 
--            defines { "STRICT", "GTEST_HAS_PTHREAD=0", "_HAS_EXCEPTIONS=1" }
            vpaths 
            { 
                ["Header Files"] = {"**.h", "**.hpp"},
                ["Source Files"] = {"**.c", "**.cpp", "**.cc"},
                ["Resource Files"] = {"**.rc", "**.rc2"}
            }
            files
            {              
                "librime/thirdparty/src/marisa-trie/lib/marisa/**.h",
                "librime/thirdparty/src/marisa-trie/lib/marisa/**.cc",
               
                
                
                
            }
            removefiles
            {     
                
               
            }
            includedirs
            {               
               
                
                
            }  
            links
            {
                
            }      