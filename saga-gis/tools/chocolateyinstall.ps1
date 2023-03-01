$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://master.dl.sourceforge.net/project/saga-gis/SAGA%20-%207/SAGA%20-%207.9.1/saga-7.9.1_win32_setup.exe'
$url64      = 'https://pilotfiber.dl.sourceforge.net/project/saga-gis/SAGA%20-%207/SAGA%20-%207.9.1/saga-7.9.1_x64_setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'

  softwareName  = 'saga-gis*'

  Url           = $url
  checksum      = '6424130DF63F4548FFECE45E8CF301910DF533934CF2D545412741AD7B55902D'
  checksumType  = 'sha256'

  Url64bit      = $url64
  checksum64    = '86433A626DC6316B4EA4B275CB7A5D2991EE018056B5997925D8702EB421F827'
  checksumType64= 'sha256'

  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
