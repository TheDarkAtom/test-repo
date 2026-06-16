param(
    [Parameter(Mandatory)]
    [string]$Branch,
    [Parameter(Mandatory)]
    [string]$Toolchain
)

Set-Location $PSScriptRoot

. "$PSScriptRoot/common.ps1" -Toolchain $Toolchain

Write-Host "Cloning repository..."
git clone https://codeberg.org/DarkAtom/titan-editor.git
if ($LASTEXITCODE -ne 0) { Write-Host "Clone failed, aborting..."; exit 1 }

Write-Host "Switching to branch $Branch..."
Set-Location titan-editor
git checkout $Branch
if ($LASTEXITCODE -ne 0) { Write-Host "Checkout failed, aborting..."; exit 1 }
Set-Location $PSScriptRoot

Write-Host "Done."

$env:PATH = "$PSScriptRoot/toolchain/mingw/bin;$env:PATH"

function Get-ShortPath($path) {
    $fso = New-Object -ComObject Scripting.FileSystemObject
    if (Test-Path $path -PathType Container) {
        return $fso.GetFolder($path).ShortPath.Replace('\', '/')
    } else {
        return $fso.GetFile($path).ShortPath.Replace('\', '/')
    }
}

Write-Host "Configuring..."
cmake -S "titan-editor" -B "$PSScriptRoot/build" @commonArgs @commonArgsCxx `
    "-DZLIB_LIBRARY=$(Get-ShortPath "$installDir/lib/libzs.a")" `
    "-DZLIB_INCLUDE_DIR=$(Get-ShortPath "$installDir/include")" `
    "-DwxWidgets_CONFIGURATION=mswu"
if ($LASTEXITCODE -ne 0) { Write-Host "Configure failed, aborting..."; exit 1 }

Write-Host "Building..."
cmake --build "$PSScriptRoot/build"
if ($LASTEXITCODE -ne 0) { Write-Host "Build failed, aborting..."; exit 1 }

Write-Host "Stripping debug symbols..."
llvm-objcopy --only-keep-debug "$PSScriptRoot/build/TitanEditor.exe" "$PSScriptRoot/build/TitanEditor.debug"
llvm-objcopy --strip-debug "--add-gnu-debuglink=$PSScriptRoot/build/TitanEditor.debug" "$PSScriptRoot/build/TitanEditor.exe"

Write-Host "Done."