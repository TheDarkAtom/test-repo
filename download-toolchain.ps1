Write-Host "Downloading toolchain..."

$llvm_version = "20260602"

$url = "https://github.com/mstorsjo/llvm-mingw/releases/download/$llvm_version/llvm-mingw-$llvm_version-msvcrt-i686.zip"
Write-Host $url
try {
    Invoke-WebRequest -Uri $url -OutFile "mingw.zip"
    Write-Host "OK"
} catch {
    Write-Host "An error has occurred: $_"
    Write-Host "Aborting..."
    exit 1
}
7z x "mingw.zip" -o"toolchain" -y
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Extraction failed, aborting...";
    exit 1
}
Rename-Item -Path "toolchain/llvm-mingw-$llvm_version-msvcrt-i686" -NewName "mingw"

