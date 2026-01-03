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

function Get-HecHmsRepoFromUsacePage {
  Write-Host "Discovering GitHub repo from: $DownloadsPage"
  $html = (Invoke-WebRequest -Uri $DownloadsPage -UseBasicParsing).Content

  # Find any GitHub repo links in the page (owner/repo)
  $matches = [regex]::Matches($html, 'https://github\.com/([^/\s"]+)/([^/\s"#?]+)', 'IgnoreCase') |
    ForEach-Object {
      [pscustomobject]@{ Owner = $_.Groups[1].Value; Repo = $_.Groups[2].Value }
    }

  if (-not $matches -or $matches.Count -eq 0) {
    throw "Could not find any github.com/<owner>/<repo> links on the USACE downloads page."
  }

  # Prefer a repo name that looks like hec-hms
  $best = $matches | Where-Object { $_.Repo -match 'hec[-_]?hms' } | Select-Object -First 1
  if (-not $best) { $best = $matches | Select-Object -First 1 }

  Write-Host "Using GitHub repo: $($best.Owner)/$($best.Repo)"
  return $best
}

function Get-LatestHecHms {
  $headers = @{
    'User-Agent' = 'Chocolatey-AU'
    'Accept'     = 'application/vnd.github+json'
  }

  $repo = Get-HecHmsRepoFromUsacePage
  $releasesUri = "https://api.github.com/repos/$($repo.Owner)/$($repo.Repo)/releases"

  Write-Host "Querying GitHub releases: $releasesUri"
  $releases = Invoke-RestMethod -Uri $releasesUri -Headers $headers -TimeoutSec 60

  if (-not $releases) {
    throw "No releases returned from $releasesUri"
  }

  # Pick newest non-draft, non-prerelease release (works even if /latest 404s)
  $release = $releases |
    Where-Object { -not $_.draft -and -not $_.prerelease } |
    Select-Object -First 1

  if (-not $release) {
    throw "No non-draft, non-prerelease releases found in $releasesUri"
  }

  $version = $release.tag_name
  if (-not $version) { throw "Release has no tag_name." }
  $version = $version.TrimStart('v')

  # Find a Windows installer asset. Try a few common patterns.
  $asset = $null

  $asset = $release.assets |
    Where-Object { $_.name -match 'Setup\.exe$' -and $_.name -match 'Windows' } |
    Select-Object -First 1

  if (-not $asset) {
    $asset = $release.assets |
        Where-Object { $_.name -match 'Setup\.exe$' } |
        Select-Object -First 1
    }

  if (-not $asset) {
    $asset = $release.assets |
        Where-Object { $_.name -match 'Windows.*\.zip$' } |
        Select-Object -First 1
    }

  if (-not $asset) {
    $names = ($release.assets | Select-Object -ExpandProperty name) -join ', '
    throw "Could not find a suitable Windows asset in release $($release.tag_name). Assets: $names"
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
