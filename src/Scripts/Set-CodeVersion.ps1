#################################################################################
#
#   (C) Emil Krotki
#
#   Modification of the VersionInfo file or AssemblyInfo for single-assembly project.
#
#   Usage:
#       "Before build" run event in Visual Studio.
#
#   Event example" params are passed using position (VS pe-build event is not working with named parameters):
#       powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -File ".\Scripts\Set-CodeVersion.ps1" "$(ProjectDir)" "1"
#       [TODO] version equal to "*" should use the number from first position in the file.
#
#   Parameters:
#       Project path
#       Version number (string, "major") Single (not dotted) number is expected. Not verified.
#
#################################################################################
PARAM(
    [string]$Project # best is to use full path set by VS in "$(ProjectDir)" or even "$(SolutionDir)"
    ,[string]$Version = '1'
)
#################################################################################
##	Preferred way of setting version is the file set at project level
##  if it is missing, go for AssemblyInfo and replace the numbers there if found
##  Set them here in order of preference from left to right.
$OneOfVersionFiles = @( 'VersionInfo.cs', 'Properties\AssemblyInfo.cs' )
#################################################################################
$File = $OneOfVersionFiles.Where( { Test-Path -Path $(Join-Path -Path $Project -ChildPath $_ ) } ) | Select-Object -First 1
$filePath = Join-Path -Path $Project -ChildPath $File

###	build our version string.
$MN = (Get-Date -Format 'yy')
#Release number is a month and day.
$RN=(Get-date -Format 'MMdd')
#Build number is "0" normally.
$BN = "0" # If you compile more than one version same day, HHMM will be set as Build Number, i.e. Daily Build Number (DBN)
$DBN = (Get-Date -Format 'HHmm')
$versionString = ('"{0}.{1}.{2}.{3}"' -F $version, $MN, $RN, $BN )
$versionMatch = ('"{0}.{1}.{2}.\d+"' -F $version, $MN, $RN )

if ( Test-Path -Path $filePath -PathType Leaf )
{
    $fileContent = Get-Content $filePath
    if ( $fileContent -match $versionMatch )   # same day build?
    {
        $versionString = ('"{0}.{1}.{2}.{3}"' -F $Version, $MN, $RN, $DBN ) # use daily build then.
    }
    $fileContent -replace '\"\d*\.\d*\.\d*\.\d*"', $versionString | Out-File $filePath
    $msg = "Version $versionString set in $filePath"
    write-host -ForegroundColor green $msg

}
else
{
    $msg = "File not found: $filePath"
    write-host -ForegroundColor Red $msg
    write-output $msg
    exit 1    
}