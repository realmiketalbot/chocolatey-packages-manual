$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.24/HEC-HMS_410_Setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'hec-hms*'

  checksum      = 'BDB2FCB5CA1827B74BC322466946A8E0D54B3347C7F6A948639A6184449A041A'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
