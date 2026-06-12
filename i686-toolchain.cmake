set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86)

set(MINGW_ROOT "${CMAKE_CURRENT_LIST_DIR}/deps/llvm-mingw-20260602-msvcrt-i686")

set(CMAKE_C_COMPILER   "${MINGW_ROOT}/bin/i686-w64-mingw32-clang.exe")
set(CMAKE_CXX_COMPILER "${MINGW_ROOT}/bin/i686-w64-mingw32-clang++.exe")
set(CMAKE_RC_COMPILER  "${MINGW_ROOT}/bin/llvm-windres.exe")

set(CMAKE_C_FLAGS_INIT "-fcf-protection=full -mstackrealign -march=i686 -msse2")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_C_FLAGS_INIT}")
set(CMAKE_EXE_LINKER_FLAGS "-static -Wl,--nxcompat -Wl,--dynamicbase -Wl,--large-address-aware")

set(CMAKE_FIND_ROOT_PATH "${MINGW_ROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)