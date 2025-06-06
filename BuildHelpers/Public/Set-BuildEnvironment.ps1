function Set-BuildEnvironment {
    <#
    .SYNOPSIS
        Normalize build system and project details into environment variables

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Normalize build system and project details into environment variables

        Creates the following environment variables:
            $ENV:<VariableNamePrefix>ProjectPath      via Get-BuildVariable
            $ENV:<VariableNamePrefix>BranchName       via Get-BuildVariable
            $ENV:<VariableNamePrefix>CommitMessage    via Get-BuildVariable
            $ENV:<VariableNamePrefix>BuildNumber      via Get-BuildVariable
            $ENV:<VariableNamePrefix>ProjectName      via Get-ProjectName
            $ENV:<VariableNamePrefix>PSModuleManifest via Get-PSModuleManifest
            $ENV:<VariableNamePrefix>ModulePath       via Split-Path on PSModuleManifest
            $ENV:<VariableNamePrefix>BuildOutput      via BuildOutput parameter
            $ENV:BHPSModulePath                       Legacy, via Split-Path on PSModuleManifest

        If you don't specify a prefix or use BH, we create BHPSModulePath (This will be removed July 1st)

    .PARAMETER Path
        Path to project root. Defaults to the current working path

    .PARAMETER VariableNamePrefix
        Allow to set a custom Prefix to the Environment variable created. The default is BH such as $Env:BHProjectPath

    .PARAMETER BuildOutput
        Specify a path to use for build output.  Defaults to '$ProjectPath\BuildOutput'

        You may use build variables produced in this same call.  Only include the variable, not ENV or the prefix.  Use a literal $.

        Examples:
            -BuildOutput '$ProjectPath\BuildOutput'
            -BuildOutput 'C:\Build'
            -BuildOutput 'C:\Builds\$ProjectName'

    .PARAMETER Passthru
        If specified, include output of the build variables we create

    .PARAMETER GitPath
        Path to git.  Defaults to git (i.e. git is in $ENV:PATH)

    .PARAMETER Force
        Overrides the Environment Variables even if they exist already

    .NOTES
        We assume you are in the project root, for several of the fallback options

    .EXAMPLE
        Set-BuildEnvironment

        Get-Item ENV:BH*

    .EXAMPLE
        Set-BuildEnvironment -VariableNamePrefix '' -Force

        Get-Item ENV:*

    .EXAMPLE
        Set-BuildEnvironment -Path C:\sc\PSDepend -BuildOutput 'C:\Builds\$ProjectName'

        # Set BuildEnvironment pointing at C:\sc\PSDepend
        # Assuming ProjectName evaluates to PSDepend, BuildOutput variable will be set to C:\Builds\PSDepend

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        Get-BuildVariable

    .LINK
        Get-BuildEnvironment

    .LINK
        Get-ProjectName

    .LINK
        about_BuildHelpers
    #>
    [CmdLetBinding( SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [validatescript({ Test-Path $_ -PathType Container })]
        $Path = $PWD.Path,

        [ValidatePattern('\w*')]
        [String]
        $VariableNamePrefix = 'BH',

        [string]$BuildOutput = '$ProjectPath\BuildOutput',

        [switch]
        $Force,

        [switch]$Passthru,

        [validatescript({
            if(-not (Get-Command $_ -ErrorAction SilentlyContinue))
            {
                throw "Could not find command at GitPath [$_]"
            }
            $true
        })]
        [string]$GitPath
    )
    $GBEParams = @{
        Path = $Path
        As = 'hashtable'
        BuildOutput = $BuildOutput
    }
    if($PSBoundParameters.ContainsKey('GitPath')) {
        $GBEParams.add('GitPath', $GitPath)
    }
    $BuildHelpersVariables = Get-BuildEnvironment @GBEParams
    foreach ($VarName in $BuildHelpersVariables.Keys) {
        if($null -ne $BuildHelpersVariables[$VarName]) {
            $prefixedVar = "$VariableNamePrefix$VarName"

            Write-Verbose "storing [$prefixedVar] with value '$($BuildHelpersVariables[$VarName])'."
            $Output = New-Item -Path Env:\ -Name $prefixedVar -Value $BuildHelpersVariables[$VarName] -Force:$Force
            if ("Azure Pipelines" -eq $BuildHelpersVariables["BuildSystem"]) {
                Set-AzurePipelinesVariable -Name $prefixedVar -Value $BuildHelpersVariables[$VarName]
            }
            if($Passthru)
            {
                $Output
            }
        }
    }
    if($VariableNamePrefix -eq 'BH' -and $BuildHelpersVariables.ModulePath)
    {
        # Handle existing scripts that reference BHPSModulePath
        Write-Verbose "storing [BHPSModulePath] with value '$($BuildHelpersVariables.ModulePath)'"
        $Output = New-Item -Path Env:\ -Name BHPSModulePath -Value $BuildHelpersVariables.ModulePath -Force:$Force
        if ("Azure Pipelines" -eq $BuildHelpersVariables["BuildSystem"]) {
            Set-AzurePipelinesVariable -Name BHPSModulePath -Value $BuildHelpersVariables.ModulePath
        }
        if($Passthru)
        {
            $Output
        }
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULrQ23tuL18l3XQ3AtkQ/4MBh
# qi2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQWoMXe
# 97gSvungd2sUr4h8yLDmJzANBgkqhkiG9w0BAQEFAASBgFKeHQ7c01jHHpE0d9no
# It2Dnu9TFbA5nk7OIEqgHSZD/iSV6GNdgUpeKZSHpJg8GFf5YKdBffW81DgCfGVt
# mn3zdoP1UpjiyNvRU2rFZ9hNiDas/6P2cjpVDL8plgPHxtVfBzfX+QfrsR0SbuEW
# tO6TGVSYjbKkN+anA0T8agJN
# SIG # End signature block
