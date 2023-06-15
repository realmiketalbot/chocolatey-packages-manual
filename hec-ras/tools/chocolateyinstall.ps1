$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://github.com/HydrologicEngineeringCenter/hec-downloads/releases/download/1.0.28/HEC-RAS_64_Setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'hec-ras*'

  checksum      = 'D3C196B27C559EE8B80A8C1279171957FCA2573D46D85E2EB8BAEBB162472A46'
  checksumType  = 'sha256'

  silentArgs   = '/s /v"/qn"' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
