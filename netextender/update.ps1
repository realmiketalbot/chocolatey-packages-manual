<# 
  update.ps1 - Chocolatey AU updater for NetExtender community package

  Expected folder structure:
    netextender\
      netextender.nuspec
      CHANGELOG.md
      tools\
        chocolateyinstall.ps1
        chocolateyuninstall.ps1
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$packageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $packageRoot

# --- Ensure AU is available ---------------------------------------------------
try {
  Import-Module au -ErrorAction Stop
} catch {
  throw "Chocolatey-AU module not found. Install it first (e.g., `choco install chocolatey-au -y`) and re-run."
}

# --- Helpers -----------------------------------------------------------------
function Get-NetExtenderLatestVersion {
  <#
    Strategy:
      1) Fetch SonicWall NetExtender Windows release notes "Versions" index.
      2) Extract versions from links like .../v-10.3.1/...
      3) Select max by semantic version.

    This avoids scraping the product marketing page and is typically more stable.
  #>

  $versionsIndex = 'https://www.sonicwall.com/support/technical-documentation/docs/netextender-windows_release_notes/Content/Versions/'
  $html = (Invoke-WebRequest -Uri $versionsIndex -UseBasicParsing).Content

  # capture v-10.3.1 patterns
  $matches = [regex]::Matches($html, 'v-(\d+\.\d+\.\d+)')
  if ($matches.Count -eq 0) {
    throw "Could not find any versions on the release notes index: $versionsIndex"
  }

  $versions =
    $matches |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique |
    ForEach-Object { [version]$_ }

  ($versions | Sort-Object -Descending | Select-Object -First 1).ToString()
}

function Get-Sha256FromUrl {
  param(
    [Parameter(Mandatory)] [string] $Url,
    [Parameter(Mandatory)] [string] $OutFile
  )

  # Download exactly the URL we provide (no transforms).
  Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing

  if (-not (Test-Path $OutFile)) {
    throw "Download failed; file not found: $OutFile"
  }

  (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Update-ChangelogTopEntry {
  param(
    [Parameter(Mandatory)] [string] $ChangelogPath,
    [Parameter(Mandatory)] [string] $Version
  )

  if (-not (Test-Path $ChangelogPath)) { return }

  $content = Get-Content -Path $ChangelogPath -Raw
  if ($content -match [regex]::Escape("* $Version")) { return }

  $today = (Get-Date).ToString('yyyy-MM-dd')
  $newLine = "* $Version ($today)"

  # Insert after the first line (the "# Changelog" header) if present,
  # otherwise just prepend.
  if ($content -match '^\s*#\s*Changelog\s*$') {
    $lines = Get-Content -Path $ChangelogPath
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add($lines[0])
    $out.Add("")
    $out.Add($newLine)
    for ($i = 1; $i -lt $lines.Count; $i++) { $out.Add($lines[$i]) }
    $out -join "`r`n" | Set-Content -Path $ChangelogPath -Encoding UTF8
  } else {
    ($newLine + "`r`n" + $content) | Set-Content -Path $ChangelogPath -Encoding UTF8
  }
}

# --- AU entry points ----------------------------------------------------------
function global:au_GetLatest {
  $version = Get-NetExtenderLatestVersion

  # Canonical MSI URLs you already use
  $url32 = "https://software.sonicwall.com/NetExtender/NetExtender-x86-$version.msi"
  $url64 = "https://software.sonicwall.com/NetExtender/NetExtender-x64-$version.msi"

  # Optional: quick HEAD validation to fail early if SonicWall changes paths
  foreach ($u in @($url32, $url64)) {
    try {
      Invoke-WebRequest -Uri $u -Method Head -UseBasicParsing | Out-Null
    } catch {
      throw "Upstream URL not reachable (HEAD failed). URL: $u"
    }
  }

  @{
    Version = $version
    URL32   = $url32
    URL64   = $url64
  }
}

function global:au_BeforeUpdate {
  param($Package)

  # Download and hash locally to avoid any URL "helpfulness" from AU
  $tmp = Join-Path $env:TEMP ("netextender-au-" + $Package.Version)
  if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
  New-Item -ItemType Directory -Path $tmp | Out-Null

  $file32 = Join-Path $tmp ("NetExtender-x86-" + $Package.Version + ".msi")
  $file64 = Join-Path $tmp ("NetExtender-x64-" + $Package.Version + ".msi")

  Write-Host "Downloading for checksum (x86): $($Package.URL32)"
  $checksum32 = Get-Sha256FromUrl -Url $Package.URL32 -OutFile $file32

  Write-Host "Downloading for checksum (x64): $($Package.URL64)"
