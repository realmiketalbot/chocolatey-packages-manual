$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64      = 'https://www.whiteboxgeo.com/WBT_Windows/WhiteboxTools_win_amd64.zip'

$packageArgs = @{
  packageName   = $Env:ChocolateyPackageName
  Url64         = $url64
  UnzipLocation = $toolsDir
  checksum64    = '303F9CDB53AE03A8DB9E912544CA50C27A49D5CBFE01B2AB57BC2D44F7478998'
  checksumType64= 'sha256'
}

Install-ChocolateyZipPackage @packageArgs