$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64      = 'https://www.whiteboxgeo.com/WBT_Windows/WhiteboxTools_win_amd64.zip'

$packageArgs = @{
  packageName   = $Env:ChocolateyPackageName
  Url64         = $url64
  UnzipLocation = $toolsDir
  checksum64    = '6F208CDC1F5B718717E5EC6C0E461DD96FC2C405E6F79297813784DFB4EEE7BA'
  checksumType64= 'sha256'
}

Install-ChocolateyZipPackage @packageArgs