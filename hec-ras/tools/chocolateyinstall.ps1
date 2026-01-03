$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.33/HEC-RAS_66_Setup.exe'

  softwareName  = 'hec-ras*'

  checksum      = '42A370B17A43892B17BD941DD0DB5415B97CBAE6C9CDA38EB11544ECE74715EB'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
