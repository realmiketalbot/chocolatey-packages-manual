[CmdletBinding()]
param(
  [switch]$UpdateChangelog
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$PackageName  = 'hec-hms'
$PackageRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path

$InstallScript = Join-Path $PackageRoot 'tools\chocolateyinstall.ps1'
$NuspecPath    = Join-Path $PackageRoot "$PackageName.nuspec"
$ChangelogPath = Join-Path $PackageRoot 'CHANGELOG.md'

$DownloadsPage = 'https://www.hec.usace.army.mil/software/hec-hms/downloads.aspx'

function Get-LatestHecHmsWindows {
  Write-Host "Fetching: $DownloadsPage"
  $r = Invoke-WebRequest -Uri $DownloadsPage -UseBasicParsing

  # Prefer DOM link parsing when available.
  $link = $null
  if ($r.Links) {
    $link = $r.Links |
      Where-Object { $_.innerText -match 'HEC-HMS\s+\d+(\.\d+)*\s+for Windows' } |
      Select-Object -First 1
  }

  # Fallback: regex from raw HTML if link parsing fails.
  if (-not $link) {
    $html = $r.Content
    $m = [regex]::Match($html, 'href="([^"]+)"[^>]*>\s*Download[^<]*</a>\s*HEC-HMS\s+(\d+(\.\d+)*)\s+for Windows', 'IgnoreCase')
    if (-not $m.Success) { throw "Could not locate the current Windows download link on $DownloadsPage" }
    $href = $m.Groups[1].Value
    $ver  = $m.Groups[2].Value
  } else {
    $href = $link.href
    $ver  = ([regex]::Match($link.innerText, 'HEC-HMS\s+([0-9.]+)')).Groups[1].Value
  }

  if (-not $ver)  { throw "Could not parse version from downloads page." }
  if (-not $href) { throw "Could not parse download URL from downloads page." }

  # Normalize relative URLs if they ever occur
  if ($href -notmatch '^https?://') {
    $href = (New-Object System.Uri((New-Object System.Uri($DownloadsPage)), $href)).AbsoluteUri
  }

  Write-Host "Latest HEC-HMS (Windows): $ver"
  Write-Host "Installer URL: $href"

  [pscustomobject]@{
    Version = $ver
    Url     = $href
  }
}

function Get-Sha256FromUrl {
  param([Parameter(Mandatory=$true)][string]$Url)

  $tmp = Join-Path $env:TEMP ("{0}.exe" -f ([guid]::NewGuid().ToString()))
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
  $latest = Get-LatestHecHmsWindows
  $sha256 = Get-Sha256FromUrl -Url $latest.Url

  return @{
    Version   = $latest.Version
    URL32     = $latest.Url          # HEC-HMS is 64-bit Windows, but Chocolatey AU expects URL32 key; we use it as "the installer URL"
    Checksum32= $sha256
  }
}

function global:au_SearchReplace {
  @{
    $InstallScript = @{
      # Update URL (supports $url = '...' or url = '...' inside packageArgs)
      "(?m)^\s*\$url\s*=\s*'[^']*'\s*$"   = "`$url = '$($Latest.URL32)'"
      "(?m)^\s*url\s*=\s*'[^']*'\s*$"     = "  url           = '$($Latest.URL32)'"

      # Update checksum (supports checksum = '...' inside packageArgs)
      "(?m)^\s*checksum\s*=\s*'[^']*'\s*$"= "  checksum      = '$($Latest.Checksum32)'"
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
  if ($content -match [regex]::Escape("## [$($Latest.Version)]")) { return }

  $date = Get-Date -Format 'yyyy-MM-dd'
  $entry = @"

## [$($Latest.Version)] - $date

### Added

- Version $($Latest.Version) installer
"@
  Add-Content -Path $ChangelogPath -Value $entry
}

# Avoid AU URL rewriting/checking; avoid README -> nuspec description behavior; we compute checksums ourselves.
$global:au_NoCheckUrl = $true
update -NoCheckUrl -ChecksumFor none -NoReadme
