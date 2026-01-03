$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# downloads available on this page: https://www.sonicwall.com/products/remote-access/vpn-clients/
$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-x86-10.3.2.msi'
$url64bit      = 'https://software.sonicwall.com/NetExtender/NetExtender-x64-10.3.2.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  softwareName  = 'netextender*'

  url           = $url
  checksum      = '566FD2DDCC853DD9E96A39922AB1C4EEB685081C74112E4B644957F67DDECE29'
  checksumType  = 'sha256'

  url64bit      = $url64bit
  checksum64    = '793E2ED53A2D7457F387C36F2828177B63FE120DFB2B27F824BB457B78EC8AB1'
  checksumType64= 'sha256'


  silentArgs   = '/norestart /qn' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
