# Install all .ttf files in -Source for the current user (no admin rights needed).
# Called from scripts/setup/wsl.sh
param(
    [Parameter(Mandatory = $true)][string]$Source
)

$ErrorActionPreference = 'Stop'

$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$regPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }

$failed = 0
foreach ($font in Get-ChildItem -Path $Source -Filter '*.ttf') {
    $dest = Join-Path $fontDir $font.Name
    try {
        Copy-Item -Path $font.FullName -Destination $dest -Force
    } catch {
        # happens when an open app (e.g. Windows Terminal) uses an older version of the font
        Write-Warning "Could not copy $($font.Name) (in use?). Close apps using it and re-run."
        $failed++
        continue
    }
    Set-ItemProperty -Path $regPath -Name "$($font.BaseName) (TrueType)" -Value $dest
}

Write-Output "Installed fonts to $fontDir"
if ($failed -gt 0) { exit 1 }
