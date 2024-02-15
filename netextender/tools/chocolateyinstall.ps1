$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# downloads available on this page: https://www.sonicwall.com/products/remote-access/vpn-clients/
$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-x86-10.2.339.msi'
$url64bit      = 'https://software.sonicwall.com/NetExtender/NetExtender-x64-10.2.339.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  softwareName  = 'netextender*'

  url           = $url
  checksum      = '23ED2A56FD7E0846C1B26628CFBD11BCA946B87E90797A6DD81D8E391E33FC64'
  checksumType  = 'sha256'

  url64bit      = $url64bit
  checksum64    = '8AC08C5147F05DC70B47C5C2617CBCFF0FCE114F8627F0C038B37370EDF2C8D4'
  checksumType64= 'sha256'


  silentArgs   = '/norestart /qn' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
