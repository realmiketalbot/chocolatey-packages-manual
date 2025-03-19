$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# downloads available on this page: https://www.sonicwall.com/products/remote-access/vpn-clients/
$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-x86-10.3.1.msi'
$url64bit      = 'https://software.sonicwall.com/NetExtender/NetExtender-x64-10.3.1.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  softwareName  = 'netextender*'

  url           = $url
  checksum      = '25EE3E4FC42E7ACD0014D0670E575535045F7446171DF02F2389EC75D56AF5E7'
  checksumType  = 'sha256'

  url64bit      = $url64bit
  checksum64    = '5053CDED98D5213A5F5959A9695FF95E12A664AC271EA5B0122D3CA8B087521C'
  checksumType64= 'sha256'


  silentArgs   = '/norestart /qn' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
