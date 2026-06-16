param(
    [Parameter(Mandatory)]
    [string]$Toolchain
)

$installDir = "$PSScriptRoot/deps/install"

$cflags          = "-Wall -Wextra -fstack-protector-strong -ftrivial-auto-var-init=zero -g"
$cflagsRelease   = "-O2 -DNDEBUG -D_FORTIFY_SOURCE=2"
$cxxflags        = "$cflags -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST"
$cxxflagsRelease = $cflagsRelease
$ldflags         = ""

$env:CFLAGS   = $cflags
$env:CXXFLAGS = $cxxflags
$env:LDFLAGS  = $ldflags

$commonArgs = @(
    "-G", "Ninja"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_TOOLCHAIN_FILE=$Toolchain"
    "-DCMAKE_INSTALL_PREFIX=$installDir"
    "-DCMAKE_C_FLAGS_RELEASE=$cflagsRelease"
)

$commonArgsCxx = @(
    "-DCMAKE_CXX_FLAGS_RELEASE=$cxxflagsRelease"
)