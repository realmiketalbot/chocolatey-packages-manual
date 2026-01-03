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
    Where-Object { $_.name -match 'W_
