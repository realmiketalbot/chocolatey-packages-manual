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

# Official upstream source
$ReleasesApi = 'https://api.github.com/repos/HydrologicEngineeringCenter/hec-hms/releases/latest'

function Get-LatestHecHms {
  Write-Host "Querying GitHub releases API"
  $headers = @{ 'User-Agent' = 'Chocolatey-AU' }

  $release = Invoke-RestMethod -Uri $ReleasesApi -Headers $headers

  if (-not $release.tag_name) {
    throw "Could not determine HEC-HMS version from GitHub releases."
  }

  $version = $release.tag_name.TrimStart('v')

  # Prefer Windows installer EXE
  $asset = $release.assets |
    Where-Object { $_.name -match 'Windows.*Setup\.exe' } |
    Select-Object -First 1

  if (-not $asset) {
    throw "Could not find Windows installer asset in GitHub release."
  }

  [pscustomobject]@{
    Version = $version
    Url     = $asset.browser_download_url
  }
}

function Get-Sha256FromUrl {
  param([Parameter(Mandatory)][string]$Url)

  $tmp = Join-Path $env:TEMP ("{0}.exe" -f ([guid]::NewGuid()))
  try {
    Write-Host "Downloading for checksum: $Url"
    Invoke-WebRequest -Uri $Url -OutFile $tmp
    (Get-FileHash -Path $tmp -Algorithm SHA256).Hash
  }
  finally {
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  }
}

Import-Module au -ErrorAction Stop

function global:au_GetLatest {
  $latest = Get-LatestHecHms
  $sha256 = Get-Sha256FromUrl -Url $latest.Url

  @{
    Version    = $latest.Version
    URL32      = $latest.Url
    Checksum32 = $sha256
  }
}

function global:au_SearchReplace {
  @{
    $InstallScript = @{
      "(?m)^\s*url\s*=\s*'[^']*'"      = "  url           = '$($Latest.URL32)'"
      "(?m)^\s*checksum\s*=\s*'[^']*'" = "  checksum      = '$($Latest.Checksum32)'"
    }

    $NuspecPath = @{
      '(?m)<version>[^<]+</version>' = "<version>$($Latest.Version)</version>"
    }
  }
}

function global:au_AfterUpdate {
  if (-not $UpdateChangelog) { return }
  if (-not (Test-Path $ChangelogPath)) { return }

  $content = Get-Content $ChangelogPath -Raw
  if ($content -match "\[$($Latest.Version)\]") { return }

  $date = Get-Date -Format 'yyyy-MM-dd'
  Add-Content $ChangelogPath @"

## [$($Latest.Version)] - $date
- Updated to HEC-HMS $($Latest.Version)
"@
}

$global:au_NoCheckUrl = $true
update -NoCheckUrl -ChecksumFor none -NoReadme
