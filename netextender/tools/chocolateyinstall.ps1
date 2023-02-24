$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# Community Repo: Use official urls for non-redist binaries or redist where total package size is over 200MB
# Internal/Organization: Download from internal location (internet sources are unreliable)
$url        = 'https://software.sonicwall.com/NetExtender/NetExtender-x64-10.2.331.MSI' # download url, HTTPS preferred

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  url           = $url

  softwareName  = 'netextender*'

  checksum      = 'DC701172990CC795C9BA6F50B7F1AA454160D570BF2756B65E312A4EDE4DCC34'
  checksumType  = 'sha256'

  silentArgs   = '/norestart /qn' 
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
