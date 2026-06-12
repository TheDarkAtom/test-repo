param(
    [Parameter(Mandatory)]
    [string]$Toolchain
)

Set-Location $PSScriptRoot

function Get-ShortPath($path) {
    $fso = New-Object -ComObject Scripting.FileSystemObject
    if (Test-Path $path -PathType Container) {
        return $fso.GetFolder($path).ShortPath.Replace('\', '/')
    } else {
        return $fso.GetFile($path).ShortPath.Replace('\', '/')
    }
}

$downloadItems = @(
    "https://github.com/mstorsjo/llvm-mingw/releases/download/20260602/llvm-mingw-20260602-msvcrt-i686.zip",
    "https://github.com/madler/zlib/releases/download/v1.3.2/zlib132.zip",
    "https://github.com/wxWidgets/wxWidgets/releases/download/v3.3.2/wxWidgets-3.3.2.zip"
)

$installDir = "$PSScriptRoot/deps/install"
$zlibSrc    = "$PSScriptRoot/deps/zlib"
$wxSrc      = "$PSScriptRoot/deps/wxWidgets"

$cflags          = "-Wall -Wextra -fstack-protector-strong -ftrivial-auto-var-init=zero -g"
$cflagsRelease   = "-O2 -DNDEBUG -D_FORTIFY_SOURCE=2"
$cxxflags        = "$cflags -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST"
$cxxflagsRelease = $cflagsRelease
$ldflags         = ""

$commonArgs = @(
    "-G", "Ninja"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_TOOLCHAIN_FILE=$Toolchain"
    "-DCMAKE_INSTALL_PREFIX=$installDir"
    "-DCMAKE_C_FLAGS=$cflags"
    "-DCMAKE_C_FLAGS_RELEASE=$cflagsRelease"
    "-DCMAKE_EXE_LINKER_FLAGS=$ldflags"
    "-DCMAKE_SHARED_LINKER_FLAGS=$ldflags"
)

$commonArgsCxx = @(
    "-DCMAKE_CXX_FLAGS=$cxxflags"
    "-DCMAKE_CXX_FLAGS_RELEASE=$cxxflagsRelease"
)

# Download
Write-Host "Downloading prerequisites..."
foreach ($url in $downloadItems) {
    $filename = Split-Path $url -Leaf
    Write-Host "$url ..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $filename
        Write-Host "OK"
    } catch {
        Write-Host "An error has occurred: $_"
        Write-Host "Aborting..."
        exit 1
    }
}

# Extract
Write-Host "Extracting archives..."
New-Item -ItemType Directory -Force -Path deps | Out-Null

$extractDirs = @(
    "deps/mingw32",
    "deps/zlib",
    "deps/wxWidgets"
)

for ($i = 0; $i -lt $downloadItems.Count; $i++) {
    $filename = Split-Path $downloadItems[$i] -Leaf
    Write-Host "$filename ..."
    7z x $filename -o"$($extractDirs[$i])" -y -spe
    if ($LASTEXITCODE -ne 0) { Write-Host "Extraction failed, aborting..."; exit 1 }
    Write-Host "OK"
}

$env:PATH = "$PSScriptRoot/deps/mingw32/bin;$env:PATH"

# zlib
Write-Host "Configuring zlib..."
cmake -S $zlibSrc -B "$PSScriptRoot/deps/build/zlib" @commonArgs `
    -DZLIB_BUILD_TESTING=OFF `
    -DZLIB_BUILD_SHARED=OFF `
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
if ($LASTEXITCODE -ne 0) { Write-Host "Configure failed, aborting..."; exit 1 }

Write-Host "Building zlib..."
cmake --build "$PSScriptRoot/deps/build/zlib"
if ($LASTEXITCODE -ne 0) { Write-Host "Build failed, aborting..."; exit 1 }

Write-Host "Installing zlib..."
cmake --install "$PSScriptRoot/deps/build/zlib"
if ($LASTEXITCODE -ne 0) { Write-Host "Install failed, aborting..."; exit 1 }

# wxWidgets
Write-Host "Configuring wxWidgets..."
cmake -S $wxSrc -B "$PSScriptRoot/deps/build/wx" @commonArgs @commonArgsCxx `
    "-DCMAKE_PREFIX_PATH=$installDir" `
    -DwxBUILD_INSTALL=ON `
    -DwxBUILD_SHARED=OFF `
    -DwxBUILD_USE_STATIC_RUNTIME=ON `
    -DwxUSE_ZLIB=sys `
    "-DZLIB_LIBRARY=$(Get-ShortPath "$installDir/lib/libzs.a")" `
    "-DZLIB_INCLUDE_DIR=$(Get-ShortPath "$installDir/include")"
if ($LASTEXITCODE -ne 0) { Write-Host "Configure failed, aborting..."; exit 1 }

Write-Host "Building wxWidgets..."
cmake --build "$PSScriptRoot/deps/build/wx"
if ($LASTEXITCODE -ne 0) { Write-Host "Build failed, aborting..."; exit 1 }

Write-Host "Installing wxWidgets..."
cmake --install "$PSScriptRoot/deps/build/wx"
if ($LASTEXITCODE -ne 0) { Write-Host "Install failed, aborting..."; exit 1 }

Write-Host "Done."