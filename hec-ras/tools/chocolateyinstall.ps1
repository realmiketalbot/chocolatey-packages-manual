$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.28/HEC-RAS_641_Setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'hec-ras*'

  checksum      = '66F351EEC47F7D0D669368DFDFEDF615278DCF372C556C511A0D1DB8A378E765'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
