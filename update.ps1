# Stop script on error
$ErrorActionPreference = 'Stop'

Function WriteLog($Message)
{
    $DateTime = (Get-Date).ToString('yyyyMMddHHmmss')
    Write-Output $Message | Out-File -FilePath "$PSScriptRoot\$DateTime.log"
}

# Application folder
$AppDir = $args[0]
# Test to see if folder exists"
if (-Not (Test-Path -Path $AppDir)) {
    $Message = "Application folder not exist: $AppDir"
    WriteLog($Message)
    Write-Error $Message
    exit
}

# Latest stable version (Win32-x64)
$Url = 'https://update.code.visualstudio.com/latest/win32-x64-archive/stable'
# Downloaded zip file
$DownloadFile = [System.IO.Path]::GetTempFileName() + '.zip'
# Download and unlock file
try {
    Invoke-WebRequest -uri $Url -OutFile $DownloadFile
}
catch {
    $Message = "An exception was caught: $($_.Exception.Message)"
    WriteLog($Message)
    Write-Error $Message
    exit
}
Unblock-File $DownloadFile

# Remove files, exclude {data,code.exe}, prevent affecting file associations and user data
Get-ChildItem -Path $AppDir -exclude 'data', 'code.exe' | Remove-Item -force -recurse
# Unzip, overwrite code.exe
Expand-Archive -Force -Path $DownloadFile -DestinationPath $AppDir
# Remove temp file
Remove-Item -force -recurse $DownloadFile

Write-Output 'Finished.'
exit
