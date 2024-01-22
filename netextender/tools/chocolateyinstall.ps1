$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-x86-10.2.338.msi'
$url64bit      = 'https://software.sonicwall.com/NetExtender/NetExtender-x64-10.2.338.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  softwareName  = 'netextender*'

  url           = $url
  checksum      = '3408569548990D7AF36D9C248FC0F27805D7B7A62F193B4658FFA91700993BDE'
  checksumType  = 'sha256'

  url64bit      = $url64bit
  checksum64    = 'CC1FADA4F9573900195505ECE05C013B875B062A7C9AA5D901F67B3DC1392B23'
  checksumType64= 'sha256'


  silentArgs   = '/norestart /qn' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
