# Push labeled training photos from assets/ into the Android emulator gallery.
# Usage: .\scripts\push_images_to_emulator.ps1 [-DeviceId emulator-5554]

param(
    [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SourceRoot = Join-Path $ProjectRoot "assets\images\animal photos"
$RemoteRoot = "/sdcard/Pictures/MilkMirror"

$LocalProps = Join-Path $ProjectRoot "android\local.properties"
$SdkDir = $null
if (Test-Path $LocalProps) {
    foreach ($line in Get-Content $LocalProps) {
        if ($line -match '^sdk\.dir=(.+)$') {
            $SdkDir = $Matches[1].Replace('\\', '\')
            break
        }
    }
}
if (-not $SdkDir) {
    $SdkDir = Join-Path $env:LOCALAPPDATA "Android\Sdk"
}

$Adb = Join-Path $SdkDir "platform-tools\adb.exe"
if (-not (Test-Path $Adb)) {
    throw "adb not found at $Adb. Install Android SDK platform-tools."
}
if (-not (Test-Path $SourceRoot)) {
    throw "Source folder not found: $SourceRoot"
}

$AdbArgs = @()
if ($DeviceId) {
    $AdbArgs += "-s", $DeviceId
}

function Get-SafeRemoteFileName {
    param([string]$Name)
    $base = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $ext = [System.IO.Path]::GetExtension($Name).ToLower()
    $safe = ($base -replace '[^\w\-]+', '_').Trim('_')
    if (-not $safe) { $safe = "image" }
    return "$safe$ext"
}

function Invoke-Adb {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & $Adb @AdbArgs @Args
    if ($LASTEXITCODE -ne 0) {
        throw "adb failed: adb $($AdbArgs -join ' ') $($Args -join ' ')"
    }
}

function Invoke-MediaScan {
    param([string]$RemotePath)
    $uri = "file://$RemotePath"
    & $Adb @AdbArgs shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d $uri | Out-Null
}

Write-Host "Using adb: $Adb"
Write-Host "Source:  $SourceRoot"
Write-Host "Target:  $RemoteRoot (on device)"

$devices = (& $Adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" })
if (-not $devices) {
    throw "No Android device/emulator connected. Start an emulator and run: flutter devices"
}
if (-not $DeviceId) {
    $DeviceId = ($devices[0] -split "\t")[0]
    $AdbArgs = @("-s", $DeviceId)
    Write-Host "Auto-selected device: $DeviceId"
}

Invoke-Adb shell "rm -rf `"$RemoteRoot`""
Invoke-Adb shell "mkdir -p `"$RemoteRoot`""

$imageCount = 0
$remoteFiles = New-Object System.Collections.Generic.List[string]
Get-ChildItem $SourceRoot -Directory | ForEach-Object {
    $folderName = $_.Name
    if ($folderName -notmatch '\d+\s*lit') {
        Write-Host "Skipping unlabeled folder: $folderName"
        return
    }
    $safeName = ($folderName -replace '\s+', '_').ToLower()
    $remoteDir = "$RemoteRoot/$safeName"
    Write-Host "Pushing $folderName -> $remoteDir"
    Invoke-Adb shell "mkdir -p `"$remoteDir`""
    Get-ChildItem $_.FullName -Recurse -File | Where-Object {
        $_.Extension -match '^\.(jpg|jpeg|png|webp)$'
    } | ForEach-Object {
        $remoteName = Get-SafeRemoteFileName $_.Name
        $remoteFile = "$remoteDir/$remoteName"
        Invoke-Adb push $_.FullName $remoteFile
        $remoteFiles.Add($remoteFile)
        $imageCount++
    }
}

Write-Host "Scanning $imageCount image(s) into MediaStore..."
foreach ($remotePath in $remoteFiles) {
    Invoke-MediaScan -RemotePath $remotePath
}

Write-Host ""
Write-Host "Done. Open Photos/Gallery on the emulator -> Pictures -> MilkMirror"
Write-Host "Then use Gallery in the Milk Mirror app to pick a photo."
