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

function Get-LatestHecRasStableWindowsFromHecSite {
  $downloadPage = 'https://www.hec.usace.army.mil/software/hec-ras/download.aspx'
  Write-Host "Fetching HEC-RAS download page: $downloadPage"

  $r = Invoke-WebRequest -Uri $downloadPage -UseBasicParsing -TimeoutSec 60
  $html = $r.Content

  # Locate the stable section: "HEC-RAS 6.6 Windows:"
  # (This section is explicitly present on the page.) :contentReference[oaicite:2]{index=2}
  $section = [regex]::Match(
    $html,
    '(?is)HEC-RAS\s+(?<ver>\d+(?:\.\d+){1,2})\s+Windows:\s*(?<body>.*?)(?:HEC-RAS\s+\d|\z)'
  )

  if (-not $section.Success) {
    throw "Could not locate a 'HEC-RAS <version> Windows' section on the download page."
  }

  $version = $section.Groups['ver'].Value
  $body    = $section.Groups['body'].Value

  # Find the first Setup.exe link in that *stable* section body
  $exe = [regex]::Match($body, '(?is)href\s*=\s*["''](?<url>[^"'']*Setup\.exe)["'']')
  if (-not $exe.Success) {
    throw "Could not find a Windows Setup.exe link in the HEC-RAS $version Windows section."
  }

  $href = $exe.Groups['url'].Value
  $url = if ($href -match '^https?://') {
    $href
  } else {
    (New-Object System.Uri((New-Object System.Uri($downloadPage)), $href)).AbsoluteUri
  }

  return [pscustomobject]@{
    Version = $version
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
  $latest = Get-LatestHecRasStableWindowsFromHecSite
  Write-Host "Parsed version: $($latest.Version)"
  Write-Host "Installer URL:  $($latest.Url)"

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
