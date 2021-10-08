$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# Community Repo: Use official urls for non-redist binaries or redist where total package size is over 200MB
# Internal/Organization: Download from internal location (internet sources are unreliable)
$url        = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.21/HEC-RAS_61_Setup.exe' # download url, HTTPS preferred

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url           = $url

  softwareName  = 'hec-ras*'

  checksum      = '6B131F8F59BEF5593394E2E18102C4C798A4FB80B0FEC984081403B640EBCC02'
  checksumType  = 'sha256'

  PackageVersion= '6.1'
  MaintainerName= 'Mike Talbot'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
