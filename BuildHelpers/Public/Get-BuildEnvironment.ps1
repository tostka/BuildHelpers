function Get-BuildEnvironment {
    <#
    .SYNOPSIS
        Get normalized build system and project details

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Get normalized build system and project details

        Returns the following details:
            ProjectPath      via Get-BuildVariable
            BranchName       via Get-BuildVariable
            CommitMessage    via Get-BuildVariable
            CommitHash       via Get-BuildVariable
            BuildNumber      via Get-BuildVariable
            ProjectName      via Get-ProjectName
            PSModuleManifest via Get-PSModuleManifest
            ModulePath       via Split-Path on PSModuleManifest
            BuildOutput      via BuildOutput parameter

    .PARAMETER Path
        Path to project root. Defaults to the current working path

    .PARAMETER BuildOutput
        Specify a path to use for build output.  Defaults to '$ProjectPath\BuildOutput'

        You may use build variables produced in this same call.  Refer to them as variables, with a literal (escaped) $

        Examples:
            -BuildOutput '$ProjectPath\BuildOutput'
            -BuildOutput 'C:\Build'
            -BuildOutput 'C:\Builds\$ProjectName'

    .PARAMETER GitPath
        Path to git.  Defaults to git (i.e. git is in $ENV:PATH)

    .NOTES
        We assume you are in the project root, for several of the fallback options

    .EXAMPLE
        Get-BuildEnvironment

    .EXAMPLE
        Get-BuildEnvironment -Path C:\sc\PSDepend -BuildOutput 'C:\Builds\$ProjectName'

        # Get BuildEnvironment pointing at C:\sc\PSDepend
        # Assuming ProjectName evaluates to PSDepend, BuildOutput will be set to C:\Builds\PSDepend

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        Get-BuildVariable

    .LINK
        Set-BuildEnvironment

    .LINK
        Get-ProjectName

    .LINK
        about_BuildHelpers
    #>
    [cmdletbinding()]
    param(
        [validatescript({ Test-Path $_ -PathType Container })]
        $Path = $PWD.Path,

        [string]$BuildOutput = '$ProjectPath\BuildOutput',

        [validatescript({
            if(-not (Get-Command $_ -ErrorAction SilentlyContinue))
            {
                throw "Could not find command at GitPath [$_]"
            }
            $true
        })]
        [string]$GitPath,

        [validateset('object', 'hashtable')]
        [string]$As = 'object'
    )
    $GBVParams = @{Path = $Path}
    if($PSBoundParameters.ContainsKey('GitPath'))
    {
        $GBVParams.add('GitPath', $GitPath)
    }
    ${Build.Vars} = Get-BuildVariable @GBVParams
    ${Build.ProjectName} = Get-ProjectName @GBVParams
    ${Build.ManifestPath} = Get-PSModuleManifest -Path $Path
    if( ${Build.ManifestPath} ) {
        ${Build.ModulePath} = Split-Path -Path ${Build.ManifestPath} -Parent
    }
    else {
        ${Build.ModulePath} = $null
    }
    $BuildHelpersVariables = [ordered]@{
        BuildSystem = ${Build.Vars}.BuildSystem
        ProjectPath = ${Build.Vars}.ProjectPath
        BranchName  = ${Build.Vars}.BranchName
        CommitMessage = ${Build.Vars}.CommitMessage
        CommitHash = ${Build.Vars}.CommitHash
        BuildNumber = ${Build.Vars}.BuildNumber
        ProjectName = ${Build.ProjectName}
        PSModuleManifest = ${Build.ManifestPath}
        ModulePath = ${Build.ModulePath}
    }
    foreach($VarName in $BuildHelpersVariables.keys){
        $BuildOutput = $BuildOutput -replace "\`$$VarName", $BuildHelpersVariables[$VarName]
    }
    $BuildOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($BuildOutput)
    $BuildHelpersVariables.add('BuildOutput', $BuildOutput)
    if($As -eq 'object') {
        return [pscustomobject]$BuildHelpersVariables
    }
    if($As -eq 'hashtable') {
        return $BuildHelpersVariables
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUu1BIMseb+NJOYkvYgcWkOx7H
# gTWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQYp39b
# KXFPCDPNt9HUAQ1nROenSjANBgkqhkiG9w0BAQEFAASBgFZMd/Mv3hjn1SceaaNZ
# mSn8xzsAc0Zx07hHpEKelVJrCYm3/Ls5BNIY+9veysiKT9HOPVEO6/D5Lj/vYF8M
# QutmPNv9TLG3GlMSZ3HD+v6YSGRMma8NYdpOOwLCJvP83CX+3BBKMclNqN/jOr2T
# iXjKX8WSNuByKtUFblKlLSL7
# SIG # End signature block
