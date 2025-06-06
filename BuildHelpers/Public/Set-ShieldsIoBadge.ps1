function Set-ShieldsIoBadge {
    <#
    .SYNOPSIS
        Modifies the link to a https://shields.io badge in a .md file. Can be used as part of a CI pipeline to update the status of
        badges such as Code Coverage.

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        This cmdlet can be used to update the link to a https://shields.io badge that has been created in a file such as readme.md.

        To use this function You need to have initially added the badge to your readme.md or specified file by adding the following
         string (ensuring 'Subject' matches what you specify for -Subject):

        ![Subject]()

    .PARAMETER Subject
        The label to assign to the badge. Default 'Build'.

    .PARAMETER Status
        The status text of value to assign to the badge. Default: 0.

    .PARAMETER Color
        The color to assign to the badge. If status is set to 0 - 100 and this parameter is not specified, the color is set
        automatically to either green, yellow, orange or red depending on the value, or light grey if it is not a 0 - 100 value.

    .PARAMETER AsPercentage
        Switch: Use to add a percentage sign after whatever you provide for -Status.

    .PARAMETER Path
        Path to the text file to update. By default this is $Env:BHProjectPath\Readme.md

    .EXAMPLE
        Set-ShieldsIoBadge -Subject 'Coverage' -Status ([math]::floor(100 - (($PesterResults.CodeCoverage.NumberOfCommandsMissed / $PesterResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))) -AsPercentage

    .LINK
        http://wragg.io/add-a-code-coverage-badge-to-your-powershell-deployment-pipeline/

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        about_BuildHelpers
    #>
    [cmdletbinding(supportsshouldprocess)]
    param(
        [string]
        $Subject = 'Build',

        $Status = 0,

        [string]
        $Color,

        [switch]
        $AsPercentage,

        [string]
        $Path = "$Env:BHProjectPath\Readme.md"
    )
    Process
    {
        if (-not $Color)
        {
            $Color = switch ($Status)
            {
                {$_ -in 90..100 -or $_ -eq 'Pass'} { 'brightgreen' }
                {$_ -in 75..89}                    { 'yellow' }
                {$_ -in 60..74}                    { 'orange' }
                {$_ -in 0..59 -or $_ -eq 'Fail'}   { 'red' }
                default                            { 'lightgrey' }
            }
        }

        if ($AsPercentage)
        {
            $Percent = '%25'
        }

        if ($PSCmdlet.ShouldProcess($Path))
        {
            $ReadmeContent = (Get-Content $Path)
            $ReadmeContent = $ReadmeContent -replace "!\[$($Subject)\].+\)", "![$($Subject)](https://img.shields.io/badge/$Subject-$Status$Percent-$Color.svg)"
            $ReadmeContent | Set-Content -Path $Path
        }
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKOoBtA6vog/0AaEV+SdKjTxD
# WvSgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRiqVHE
# F27Ef+2WA7dzhfv56afO0jANBgkqhkiG9w0BAQEFAASBgBsm65Egm40aYdQdX4Tv
# GrKc7U9Mbua7gzhnMwumwMfU9q9OZg6VQNRDxYZZtw6YIHa2BqSJkrQ0cOYyT18F
# 8o3bPiyW56C+wVX87S9RpggsxP42n61QiHpQIyKk/fjqT5VJ8O+O2tPFg3m3WB+u
# gJ59Ti6xgK5MgDWRgMdQqbeQ
# SIG # End signature block
