$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# downloads available on this page: https://www.sonicwall.com/products/remote-access/vpn-clients/
$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-x86-10.2.341.msi'
$url64bit      = 'https://software.sonicwall.com/NetExtender/NetExtender-x64-10.2.341.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  softwareName  = 'netextender*'

  url           = $url
  checksum      = 'E66924504A4C582F19E0CEEA23C901C8D4BAA50002FBF38E00E099B6DE3425A7'
  checksumType  = 'sha256'

  url64bit      = $url64bit
  checksum64    = '3F35AE9D0E8C928A7087BA6E10F2AEC81EABCA12DD7B2CBC464E1E1E7D3D6452'
  checksumType64= 'sha256'


  silentArgs   = '/norestart /qn' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
