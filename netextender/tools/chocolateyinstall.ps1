$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-x86-10.2.337.msi'
$url64bit      = 'https://software.sonicwall.com/NetExtender/NetExtender-x64-10.2.337.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  softwareName  = 'netextender*'

  url           = $url
  checksum      = '1C4F7A1EED85B27A2031E5A9774F7E3E3A5FC35BBB6EA3E7CC0B8A77D8495D25'
  checksumType  = 'sha256'

  url64bit      = $url64bit
  checksum64    = '83F29BF25E429CE35E3814320409703AEAC624EC1A283FB9144ACD46B3C53700'
  checksumType64= 'sha256'


  silentArgs   = '/norestart /qn' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
