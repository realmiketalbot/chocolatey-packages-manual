[CmdletBinding()]
param(
  [switch]$UpdateChangelog
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$PackageName  = 'hec-ras'
$PackageRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path

$InstallScript = Join-Path $PackageRoot 'tools\chocolateyinstall.ps1'
$NuspecPath    = Join-Path $PackageRoot "$PackageName.nuspec"
$ChangelogPath = Join-Path $PackageRoot 'CHANGELOG.md'

$ReleasesApi = 'https://api.github.com/repos/HydrologicEngineeringCenter/hec-downloads/releases'

function Convert-RasTokenToVersion {
  param([Parameter(Mandatory)][string]$Token)

  # Common tokens:
  # 66  -> 6.6
  # 641 -> 6.4.1
  # 631 -> 6.3.1
  # 610 -> 6.1 (or 6.1.0; we drop trailing .0)
  if ($Token.Length -lt 2) { throw "Unrecognized HEC-RAS token: $Token" }

  $major = $Token.Substring(0,1)
  $minor = $Token.Substring(1,1)
  $patch = $null
  if ($Token.Length -ge 3) { $patch = $Token.Substring(2) }

  if ($patch -and $patch -match '^\d+$' -and [int]$patch -ne 0) {
    return "$major.$minor.$patch"
  }

  return "$major.$minor"
}

function Get-HecRas66WindowsInstallerFromHecSite {
  $downloadPage = 'https://www.hec.usace.army.mil/software/hec-ras/download.aspx'
  Write-Host "Fetching HEC-RAS download page: $downloadPage"

  $r = Invoke-WebRequest -Uri $downloadPage -UseBasicParsing -TimeoutSec 60
  $html = $r.Content

  # Grab only the "HEC-RAS 6.6 Windows:" section up to the next major heading
  # (This avoids Beta, Archives, etc.)
  $sec = [regex]::Match(
    $html,
    '(?is)HEC-RAS\s+6\.6\s+Windows:\s*(?<body>.*?)(?:HEC-RAS\s+6\.6\s+Example\s+Projects:|HEC-RAS\s+Archived\s+Versions\s+Windows:|HEC-RAS\s+6\.6\s+Linux:|\z)'
  )
  if (-not $sec.Success) {
    throw "Could not locate the HEC-RAS 6.6 Windows section."
  }

  $body = $sec.Groups['body'].Value

  # Find a Setup.exe link inside that section. Allow .EXE and optional query string.
  $m = [regex]::Match(
    $body,
    '(?is)href\s*=\s*["''](?<url>[^"'']*Setup\.exe(?:\?[^"'']*)?)["'']'
  )
  if (-not $m.Success) {
    # Helpful debug if it still fails
    $snippet = $body.Substring(0, [Math]::Min(1200, $body.Length))
    Write-Host "DEBUG section snippet (first 1200 chars):"
    Write-Host $snippet
    throw "Could not find a Windows Setup.exe link in the HEC-RAS 6.6 Windows section."
  }

  $href = $m.Groups['url'].Value
  $url = if ($href -match '^https?://') {
    $href
  } else {
    (New-Object System.Uri((New-Object System.Uri($downloadPage)), $href)).AbsoluteUri
  }

  return [pscustomobject]@{
    Version = '6.6'
    Url     = $url
  }
}

function Get-Sha256FromUrl {
  param([Parameter(Mandatory)][string]$Url)

  $tmp = Join-Path $env:TEMP ("{0}.exe" -f ([guid]::NewGuid()))
  try {
    Write-Host "Downloading for checksum: $Url"
    Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
    (Get-FileHash -Path $tmp -Algorithm SHA256).Hash
  }
  finally {
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  }
}

Import-Module au -ErrorAction Stop

function global:au_GetLatest {
  $latest = Get-HecRas66WindowsInstallerFromHecSite
  Write-Host "Parsed version:  $($latest.Version)"
  Write-Host "Installer URL:   $($latest.Url)"

  $sha256 = Get-Sha256FromUrl -Url $latest.Url

  return @{
    Version    = $latest.Version
    URL32      = $latest.Url
    Checksum32 = $sha256
  }
}

function global:au_SearchReplace {
  @{
    $InstallScript = @{
      # Recommended install-script style: inline url/checksum literals inside $packageArgs (no $url variable).
      "(?m)^\s*url\s*=\s*'[^']*'\s*$"      = "  url           = '$($Latest.URL32)'"
      "(?m)^\s*checksum\s*=\s*'[^']*'\s*$" = "  checksum      = '$($Latest.Checksum32)'"
    }

    $NuspecPath = @{
      '(?m)^\s*<version>[^<]+</version>\s*$' = "    <version>$($Latest.Version)</version>"
    }
  }
}

function global:au_AfterUpdate {
  if (-not $UpdateChangelog) { return }
  if (-not (Test-Path $ChangelogPath)) { return }

  $content = Get-Content -Path $ChangelogPath -Raw
  if ($content -match [regex]::Escape("## [$($Latest.Version)]")) { return }

  $date = Get-Date -Format 'yyyy-MM-dd'
  Add-Content -Path $ChangelogPath -Value @"

## [$($Latest.Version)] - $date

### Added

- Version $($Latest.Version) installer
"@
}

$global:au_NoCheckUrl = $true
update -NoCheckUrl -ChecksumFor none -NoReadme
