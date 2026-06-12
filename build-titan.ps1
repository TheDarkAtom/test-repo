param(
    [Parameter(Mandatory)]
    [string]$Branch,
    [Parameter(Mandatory)]
    [string]$Toolchain
)

Set-Location $PSScriptRoot

Write-Host "Cloning repository..."
git clone https://codeberg.org/DarkAtom/titan-editor.git
if ($LASTEXITCODE -ne 0) { Write-Host "Clone failed, aborting..."; exit 1 }

Write-Host "Switching to branch $Branch..."
Set-Location titan-editor
git checkout $Branch
if ($LASTEXITCODE -ne 0) { Write-Host "Checkout failed, aborting..."; exit 1 }

Write-Host "Done."

Set-Location $PSScriptRoot

$installDir = "$PSScriptRoot/deps/install"
$srcDir     = "$PSScriptRoot/titan-editor"

$cflags          = "-Wall -Wextra -fstack-protector-strong -ftrivial-auto-var-init=zero -g"
$cflagsRelease   = "-O2 -DNDEBUG -D_FORTIFY_SOURCE=2"
$cxxflags        = "$cflags -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST"
$cxxflagsRelease = $cflagsRelease
$ldflags         = ""

$env:PATH = "$PSScriptRoot/deps/mingw32/bin;$env:PATH"

function Get-ShortPath($path) {
    $fso = New-Object -ComObject Scripting.FileSystemObject
    if (Test-Path $path -PathType Container) {
        return $fso.GetFolder($path).ShortPath.Replace('\', '/')
    } else {
        return $fso.GetFile($path).ShortPath.Replace('\', '/')
    }
}

Write-Host "Configuring..."
cmake -S $srcDir -B "$PSScriptRoot/build" `
    -G Ninja `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_TOOLCHAIN_FILE="$Toolchain" `
    "-DCMAKE_PREFIX_PATH=$installDir" `
    -DCMAKE_C_FLAGS="$cflags" `
    -DCMAKE_C_FLAGS_RELEASE="$cflagsRelease" `
    -DCMAKE_CXX_FLAGS="$cxxflags" `
    -DCMAKE_CXX_FLAGS_RELEASE="$cxxflagsRelease" `
    -DCMAKE_EXE_LINKER_FLAGS="$ldflags" `
    -DCMAKE_SHARED_LINKER_FLAGS="$ldflags" `
    "-DZLIB_LIBRARY=$(Get-ShortPath "$installDir/lib/libzs.a")" `
    "-DZLIB_INCLUDE_DIR=$(Get-ShortPath "$installDir/include")"
if ($LASTEXITCODE -ne 0) { Write-Host "Configure failed, aborting..."; exit 1 }

Write-Host "Building..."
cmake --build "$PSScriptRoot/build"
if ($LASTEXITCODE -ne 0) { Write-Host "Build failed, aborting..."; exit 1 }

Write-Host "Done."