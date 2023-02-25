$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url      = 'https://github.com/dtarb/TauDEM/releases/download/v5.3.7/TauDEM537exeWin32.zip' # download url for 32-bit
$url64      = 'https://github.com/dtarb/TauDEM/releases/download/v5.3.7/TauDEM537exeWin64.zip' # download url for 64-bit

$packageArgs = @{
  packageName   = $Env:ChocolateyPackageName
  Url           = $url
  Url64         = $url64
  UnzipLocation = Join-Path $toolsDir '/bin/'
  checksum      = 'A6E45298FBF8E4A1D5E0C7E27B6FF0A9F0153BCB723016A078481294CEA576F5'
  checksumType  = 'sha256'
  checksum64    = '1D17FB2F06919342E2422FBE2DA42E0ECEEA29CB6E09928875BA788DB50C89ED'
  checksumType64= 'sha256'
}

Install-ChocolateyZipPackage @packageArgs