$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://gigenet.dl.sourceforge.net/project/saga-gis/SAGA%20-%208/SAGA%20-%208.5.1/saga-8.5.1_win32_setup.exe'
$url64      = 'https://cytranet.dl.sourceforge.net/project/saga-gis/SAGA%20-%208/SAGA%20-%208.5.1/saga-8.5.1_x64_setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'

  softwareName  = 'saga-gis*'

  Url           = $url
  checksum      = '3F430F9871D485E6D8405C0FD1DB33E9305888DDF97511A3DC1D6A5BFF098609'
  checksumType  = 'sha256'

  Url64bit      = $url64
  checksum64    = '40E44CD404470BB45C943A387C81B7B012F387A7266A64C49A1687C847FDAC78'
  checksumType64= 'sha256'

  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
