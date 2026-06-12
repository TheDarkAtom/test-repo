Write-Host "Downloading prerequisites..."

$zlib_version = "1.3.2"
$wxwidgets_version = "3.3.2"

$url = "https://github.com/madler/zlib/releases/download/v$zlib_version/zlib-$zlib_version.tar.gz"
Write-Host $url
try {
    Invoke-WebRequest -Uri $url -OutFile "zlib.zip"
    Write-Host "OK"
} catch {
    Write-Host "An error has occurred: $_"
    Write-Host "Aborting..."
    exit 1
}
New-Item -ItemType Directory -Force -Path deps | Out-Null
tar -xf "zlib.zip" -C "deps"
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Extraction failed, aborting...";
    exit 1
}
Rename-Item -Path "deps/zlib-$zlib_version" -NewName "zlib"



$url = "https://github.com/wxWidgets/wxWidgets/releases/download/v$wxwidgets_version/wxWidgets-$wxwidgets_version.zip"
Write-Host $url
try {
    Invoke-WebRequest -Uri $url -OutFile "wxwidgets.zip"
    Write-Host "OK"
} catch {
    Write-Host "An error has occurred: $_"
    Write-Host "Aborting..."
    exit 1
}
7z x "wxwidgets.zip" -o"deps/wxWidgets" -y
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Extraction failed, aborting...";
    exit 1
}