$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# Community Repo: Use official urls for non-redist binaries or redist where total package size is over 200MB
# Internal/Organization: Download from internal location (internet sources are unreliable)
$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-10.2.313.MSI' # download url, HTTPS preferred

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'msi'
  url           = $url

  softwareName  = 'netextender*'

  checksum      = '6841EDB686FD988D167CBEE79BA10D8F215BBF07F36C3D2185A2543CF364B8CD'
  checksumType  = 'sha256'

  PackageVersion= '10.2.313'
  MaintainerName= 'Mike Talbot'

  # MSI
  silentArgs    = "/qn /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
