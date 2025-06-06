<#
.SYNOPSIS
    Normalize build system and project details into variables

.FUNCTIONALITY
    CI/CD

.DESCRIPTION
    Normalize build system and project details into variables

    Creates the following variables:
        BHProjectPath      via Get-BuildVariable
        BHBranchName       via Get-BuildVariable
        BHCommitMessage    via Get-BuildVariable
        BHBuildNumber      via Get-BuildVariable
        BHProjectName      via Get-ProjectName
        BHPSModuleManifest via Get-PSModuleManifest
        BHModulePath     via Split-Path on BHPSModuleManifest

.PARAMETER Path
    Path to project root. Defaults to the current working path

.PARAMETER Scope
    Determines the scope of the variables. Valid values are "Global", "Local", or "Script", or a number
    relative to the current scope (0 through the number of scopes, where 0 is the current scope and 1 is its
    parent). For more information, see about_Scopes.

    Defaults to the calling scope, 0 if it is dot-sourced, 1 if it is invoked normally.

    The scope value Script may only be used with dot-sourced Set-BuildVariable.

.PARAMETER VariableNamePrefix
    Allow to set a custom Prefix to the Environment variable created. The default is BH such as $BHProjectPath

.NOTES
    We assume you are in the project root, for several of the fallback options

.EXAMPLE
    Set-BuildVariable
    Get-Variable BH* -Scope 0

    # Set build variables in the current scope, read them

.EXAMPLE
    . Set-BuildVariable -Scope Script
    Get-Variable BH* -Scope Script

    # Set build variables in the script scope (mind the .), read them

.EXAMPLE
    . Set-BuildVariable -VariableNamePrefix BUILD
    Get-Variable BUILD*

    # Set build variables in the script scope (mind the .), read them

.LINK
    https://github.com/RamblingCookieMonster/BuildHelpers

.LINK
    Get-BuildVariable

.LINK
    Get-ProjectName

.LINK
    about_BuildHelpers
#>
[cmdletbinding()]
param(
    $Path = $PWD.Path,

    [validatescript({
        if(-not ('Global', 'Local', 'Script', 'Current' -contains $_ -or (($_ -as [int]) -ge 0)))
        {
            throw "'$_' is an invalid Scope. For more information, run Get-Help Set-BuildVariable -Parameter Scope"
        }
        $true
    })]
    [string]
    $Scope,

    [ValidatePattern('\w*')]
    [String]
    $VariableNamePrefix = 'BH'
)

if($MyInvocation.InvocationName -eq '.')
{
    if(-not $Scope)
    {
        $Scope = '0'
    }
}
else
{
    if($Scope -eq 'Script')
    {
        throw 'The script scope may only be used with dot-sourced Set-BuildVariable.'
    }
    if(-not $Scope)
    {
        $Scope = '1'
    }
}

${Build.Vars} = Get-BuildVariable -Path $Path
${Build.ProjectName} = Get-ProjectName -Path $Path
${Build.ManifestPath} = Get-PSModuleManifest -Path $Path
$BuildHelpersVariables = @{
    BuildSystem = ${Build.Vars}.BuildSystem
    ProjectPath = ${Build.Vars}.ProjectPath
    BranchName  = ${Build.Vars}.BranchName
    CommitMessage = ${Build.Vars}.CommitMessage
    BuildNumber = ${Build.Vars}.BuildNumber
    ProjectName = ${Build.ProjectName}
    PSModuleManifest = ${Build.ManifestPath}
    ModulePath = $(Split-Path -Path ${Build.ManifestPath} -Parent)
}
foreach ($VarName in $BuildHelpersVariables.Keys) {
    Set-Variable -Scope $Scope -Name ('{0}{1}' -f $VariableNamePrefix,$VarName) -Value $BuildHelpersVariables[$VarName]
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxQYLnbIJ/Nan7aJgkriq+acq
# VxigggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTBrJKz
# 6mgHOMaX2KjjXKaRupjydjANBgkqhkiG9w0BAQEFAASBgKFTiiSsKu8ehf2fH0Xm
# wGCVuZfpxPEPz+y9E5btkE8B+fWtb6jSBOKKzpqPAve2HKadO4DebDRIwjJS71jJ
# sMLQjJw/WnoQep+ImGN7gOvyoIbL5sDvkZRg3EJBpLF8bzUG9cGPD5iyPsNxFYwx
# yuMn2awqCGPYbSbQ8Lx6moF8
# SIG # End signature block
