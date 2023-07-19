$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# Community Repo: Use official urls for non-redist binaries or redist where total package size is over 200MB
# Internal/Organization: Download from internal location (internet sources are unreliable)
$url        = 'https://software.sonicwall.com/GlobalVPNClient/184-011921-00_REV_A_GVCSetup64.exe' # download url, HTTPS preferred

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'global-vpn-client*'

  checksum      = '2663dee4be9d346751d42bb1465b5d0138bcc99805790be0cb6f8f01574c1309'
  checksumType  = 'sha256'

  silentArgs   = '/S /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
