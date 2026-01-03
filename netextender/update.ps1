<#
.SYNOPSIS
  AU updater for the Chocolatey Community package "netextender".

.DESCRIPTION
  - Scrapes SonicWall NetExtender Windows release notes landing page for latest version.
  - Builds the MSI URLs in the standard software.sonicwall.com pattern.
  - Downloads both x86 and x64 MSIs (without AU URL checking), computes SHA256.
  - Updates tools\chocolateyinstall.ps1 and netextender.nuspec accordingly.
  - Optionally appends an entry to CHANGELOG.md.

.REQUIREMENTS
  - PowerShell 5.1+ (works on PS7 as well)
  - chocolatey-au module available (Import-Module au)
#>

[CmdletBinding()]
param(
  [switch]$UpdateChangelog
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$PackageName  = 'netextender'
$PackageRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path

$InstallScript = Join-Path $PackageRoot 'tools\chocolateyinstall.ps1'
$NuspecPath    = Join-Path $PackageRoot "$PackageName.nuspec"
$ChangelogPath = Join-Path $PackageRoot 'CHANGELOG.md'

# SonicWall "NetExtender Windows Release Notes" landing page lists current versions
$ReleaseNotesIndexUri = 'https://www.sonicwall.com/support/technical-documentation/docs/netextender-windows_release_notes/Content/release_notes.htm'

function Get-LatestNetExtenderWindowsVersion {
  Write-Host "Fetching version list from: $ReleaseNotesIndexUri"
  $html = (Invoke-WebRequest -Uri $ReleaseNotesIndexUri -UseBasicParsing).Content

  # Example matches: "Version 10.3.3", "Version 10.3.2", etc.
  $raw = [regex]::Matches($html, 'Version\s+(\d+\.\d+\.\d+)', 'IgnoreCase') |
         ForEach-Object { $_.Groups[1].Value }

  if (-not $raw -or $raw.Count -eq 0) {
    throw "Could not find any 'Version X.Y.Z' tokens at $ReleaseNotesIndexUri"
  }

  $latest = ($raw | Sort-Object -Unique | ForEach-Object { [version]$_ } | Sort-Object -Descending | Select-Object -First 1).ToString()
  Write-Host "Latest version detected: $latest"
  return $latest
}

function Get-Sha256FromUrl {
  param(
    [Parameter(Mandatory=$true)][string]$Url
  )

  $tmp = Join-Path $env:TEMP ("{0}.msi" -f ([guid]::NewGuid().ToString()))
  try {
    Write-Host "Downloading for checksum: $Url"
    Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
    return (Get-FileHash -Path $tmp -Algorithm SHA256).Hash
  }
  finally {
    Remove-Item -Path $tmp -Force -ErrorAction SilentlyContinue
  }
}

Import-Module au -ErrorAction Stop

function global:au_GetLatest {
  $version = Get-LatestNetExtenderWindowsVersion

  $url32 = "https://software.sonicwall.com/NetExtender/NetExtender-x86-$version.msi"
  $url64 = "https://software.sonicwall.com/NetExtender/NetExtender-x64-$version.msi"

  # Compute checksums ourselves (keeps URLs exactly as-is; avoids AU URL check rewriting)
  $checksum32 = Get-Sha256FromUrl -Url $url32
  $checksum64 = Get-Sha256FromUrl -Url $url64

  return @{
    Version    = $version
    URL32      = $url32
    URL64      = $url64
    Checksum32 = $checksum32
    Checksum64 = $checksum64
  }
}

function global:au_SearchReplace {
  @{
    $InstallScript = @{
      '(?m)^\$url\s*=\s*''[^'']*'''        = "`$url        = '$($Latest.URL32)'"
      '(?m)^\$url64bit\s*=\s*''[^'']*'''   = "`$url64bit      = '$($Latest.URL64)'"
      "(?m)^\s*checksum\s*=\s*'[^']*'"     = "  checksum      = '$($Latest.Checksum32)'"
      "(?m)^\s*checksum64\s*=\s*'[^']*'"   = "  checksum64    = '$($Latest.Checksum64)'"
    }

    $NuspecPath = @{
      '(?m)^\s*<version>[^<]+</version>\s*$' = "    <version>$($Latest.Version)</version>"
    }
  }
}

function global:au_AfterUpdate {
  param($Package)

  if (-not $UpdateChangelog) { return }
  if (-not (Test-Path $ChangelogPath)) { return }

  $content = Get-Content -Path $ChangelogPath -Raw

  # Only append if this exact version header isn't already present
  if ($content -match [regex]::Escape("## [$($Latest.Version)]")) { return }

  $date = Get-Date -Format 'yyyy-MM-dd'

  $entry = @"

## [$($Latest.Version)] - $date

### Added

- Version $($Latest.Version) installer
"@

  Add-Content -Path $ChangelogPath -Value $entry
}

# Critical: disable AU URL checking (prevents AU from rewriting/augmenting the URL during validation)
# AU supports -NoCheckUrl; we also set the global for safety in older patterns.
$global:au_NoCheckUrl = $true

# We compute checksums ourselves, so tell AU not to do it.
update -NoCheckUrl -ChecksumFor none
