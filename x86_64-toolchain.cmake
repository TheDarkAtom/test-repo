set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86)

set(MINGW_ROOT "${CMAKE_CURRENT_LIST_DIR}/toolchain/mingw")

set(CMAKE_C_COMPILER   "${MINGW_ROOT}/bin/x86_64-w64-mingw32-clang.exe")
set(CMAKE_CXX_COMPILER "${MINGW_ROOT}/bin/x86_64-w64-mingw32-clang++.exe")
set(CMAKE_RC_COMPILER  "${MINGW_ROOT}/bin/llvm-windres.exe")

set(CMAKE_C_FLAGS_INIT "-fcf-protection=full -march=x86_64")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_C_FLAGS_INIT}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-static -Wl,--nxcompat -Wl,--dynamicbase -Wl,--high-entropy-va")

set(CMAKE_FIND_ROOT_PATH "${MINGW_ROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)