function Set-AzurePipelinesVariable {
    <#
    .SYNOPSIS
        Set a envrionment variable in VSTS/Azure Pipelines that will persist between tasks

    .DESCRIPTION
        This command uses the VSTS/Azure Pipelines command task.setvariable to create an
        envrionment variable which will be available in all following tasks
        within the same stage.

    .EXAMPLE
        Set-AzurePipelinesVariable -Name ProjectName -Value (Get-ProjectName)

    .EXAMPLE
        Set-AzurePipelinesVariable -Name ProjectName -Value (Get-ProjectName) -Secret

    .LINK
        https://github.com/Microsoft/azure-pipelines-tasks/blob/master/docs/authoring/commands.md
    #>
    [CmdletBinding( SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', 'Azure Pipelines does not listen to Out-Host')]
    param (
        # Name of the variable
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Value of the variable
        [string]$Value,

        # The value of the variable will be saved as secret and masked out from log.
        # Secret variables are not passed into tasks as environment variables and must be passed as inputs.
        [switch]$Secret
    )

    Process {
        $_secret = ""
        if ($Secret) { $_secret = ";issecret=true" }

        Write-Verbose "storing [$Name] with Azure Pipelines task.setvariable command"
        Write-Host "##vso[task.setvariable variable=$Name$_secret]$Value"
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxOzWX+o5NUDriUYqo9bdW0jo
# O72gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRe4VHT
# XQ3dlzy4PwtVZ+Cbk+6JqTANBgkqhkiG9w0BAQEFAASBgJ3QCnaZYdTvhckb542R
# /0ZiacEB9DV7UZBTToWXyAjRhxoV1newyQDzk/FU8KuKUlGLThyWcZ2AIFFc7EKy
# TIRsJrI5GZYlqQ/OfVEnz3Y6pra5jt/SfRDseYujclJDmmbZG9eN9qwYGfV5/U9x
# CH59xj7PAbHzN0GQ+ON1QD7I
# SIG # End signature block
