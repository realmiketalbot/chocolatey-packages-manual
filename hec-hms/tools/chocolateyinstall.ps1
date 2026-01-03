$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.32/HEC-HMS_412_Setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.38/HEC-HMS_413_Setup.exe'

  softwareName  = 'hec-hms*'

  checksum      = '309BB87EF05CCC8E57CF9557BFDA9E711510AFC6929CF6ECBE36EAD0A6F063B8'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
