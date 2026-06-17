Toolchain="$1"

installDir="$DIR/deps/install"

cflags="-Wall -Wextra -fstack-protector-strong -ftrivial-auto-var-init=zero -g"
cflagsRelease="-O2 -DNDEBUG -D_FORTIFY_SOURCE=2 -ffunction-sections -fdata-sections"
cxxflags="$cflags -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST"
cxxflagsRelease="$cflagsRelease"
ldflags=""
ldflagsRelease="-Wl,--gc-sections"

export CFLAGS="$cflags"
export CXXFLAGS="$cxxflags"
export LDFLAGS="$ldflags"

commonArgs=(
    "-G"
    "Ninja"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_TOOLCHAIN_FILE=$Toolchain"
    "-DCMAKE_INSTALL_PREFIX=$installDir"
    "-DCMAKE_C_FLAGS_RELEASE=$cflagsRelease"
    "-DCMAKE_EXE_LINKER_FLAGS_RELEASE=$ldflagsRelease"
    "-DCMAKE_SHARED_LINKER_FLAGS_RELEASE=$ldflagsRelease"
)

commonArgsCxx=(
    "-DCMAKE_CXX_FLAGS_RELEASE=$cxxflagsRelease"
)