$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64      = 'https://www.whiteboxgeo.com/WBT_Windows/WhiteboxTools_win_amd64.zip'

$packageArgs = @{
  packageName   = $Env:ChocolateyPackageName
  Url64         = $url64
  UnzipLocation = $toolsDir
  checksum64    = '2B39F0FC90F73B295467850BD470BFACD3DAB34E84B8550C049D30B4F7600D6B'
  checksumType64= 'sha256'
}

Install-ChocolateyZipPackage @packageArgs