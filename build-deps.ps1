param(
    [Parameter(Mandatory)]
    [string]$Toolchain
)

Set-Location $PSScriptRoot

. "$PSScriptRoot/common.ps1" -Toolchain $Toolchain

$env:PATH = "$PSScriptRoot/toolchain/mingw/bin;$env:PATH"

function Get-ShortPath($path) {
    $fso = New-Object -ComObject Scripting.FileSystemObject
    if (Test-Path $path -PathType Container) {
        return $fso.GetFolder($path).ShortPath.Replace('\', '/')
    } else {
        return $fso.GetFile($path).ShortPath.Replace('\', '/')
    }
}

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