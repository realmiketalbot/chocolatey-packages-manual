$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# Community Repo: Use official urls for non-redist binaries or redist where total package size is over 200MB
# Internal/Organization: Download from internal location (internet sources are unreliable)
$url        = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.26/HEC-RAS_631_Setup.exe' # download url, HTTPS preferred

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'hec-ras*'

  checksum      = '5DE0BD85B61DA6D4ED450D443EC1D4BF4BD30D309496C7DD55A6B7011784D827'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
