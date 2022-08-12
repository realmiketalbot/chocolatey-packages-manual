$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# Community Repo: Use official urls for non-redist binaries or redist where total package size is over 200MB
# Internal/Organization: Download from internal location (internet sources are unreliable)
$url        = 'https://software.sonicwall.com/NetExtender/NXSetupU-x64-10.2.324.exe' # download url, HTTPS preferred

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'netextender*'

  checksum      = '67D33EFE77A7DED4C09DF5A66458601FA210312BA9D65AEC5BA7E0FF2A46367F'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
