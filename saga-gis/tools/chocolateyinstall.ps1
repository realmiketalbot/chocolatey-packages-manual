$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://pilotfiber.dl.sourceforge.net/project/saga-gis/SAGA%20-%207/SAGA%20-%207.9.1/saga-7.9.1_x64_setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'saga-gis*'

  checksum      = '86433A626DC6316B4EA4B275CB7A5D2991EE018056B5997925D8702EB421F827'
  checksumType  = 'sha256'

  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
