$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://www.epa.gov/system/files/other-files/2023-03/swmm523%28x86%29_setup.exe'
$url64bit      = 'https://www.epa.gov/system/files/other-files/2023-03/swmm523%28x64%29_setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe'
  softwareName  = 'swmm*'

  url           = $url
  checksum      = 'D4278EF5454E6FA2C9672DD363B2A1F8070F9DC78A0F548697D72C9EDEC79DE3'
  checksumType  = 'sha256'

  url64bit      = $url64bit
  checksum64    = '37749E5C16730273F40402750F258BA4C361B6B312636D575769D8D5E90EFE35'
  checksumType64= 'sha256'

  silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
