$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.32/HEC-HMS_412_Setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'hec-hms*'

  checksum      = '9E01DBA368C37B12D11680E002A89215B964904E175DA56C16FF5159B52DCCA7'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
