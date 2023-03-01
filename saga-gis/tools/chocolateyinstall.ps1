$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://versaweb.dl.sourceforge.net/project/saga-gis/SAGA%20-%207/SAGA%20-%207.8.2/saga-7.8.2_x64_setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  url           = $url

  softwareName  = 'saga-gis*'

  checksum      = '6E6F4542250D0C4973462020E9E97C93A94D6E7CE5032D32388983C5F281F5AF'
  checksumType  = 'sha256'

  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
