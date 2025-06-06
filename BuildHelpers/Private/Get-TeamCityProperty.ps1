function Get-TeamCityProperty
{
    <#
    .SYNOPSIS
    Loads TeamCity system build properties into a hashtable
    Doesn't do anything if not running under TeamCity

    .DESCRIPTION
    Teamcity generates a build properties file and stores the location in the environent
    variable TEAMCITY_BUILD_PROPERTIES_FILE.

    Loads the TeamCity system build properties into a hashtable.

    .PARAMETER propertiesfile
    Path to properties xml file. Defaults to environent
    variable TEAMCITY_BUILD_PROPERTIES_FILE.

    .NOTES
    We assume you are in the project root, for several of the fallback options

    .EXAMPLE
    Get-TeamCityProperty

    .LINK
    https://gist.github.com/piers7/6432985

    .LINK
    Get-BuildVariable
    #>
    [OutputType([hashtable])]
    param(
        [string]$propertiesfile = $env:TEAMCITY_BUILD_PROPERTIES_FILE + '.xml'
    )

    if(![String]::IsNullOrEmpty($env:TEAMCITY_VERSION))
    {
        Write-Verbose -Message "Loading TeamCity properties from $propertiesfile"
        $propertiesfile = (Resolve-Path $propertiesfile).Path

        $buildPropertiesXml = New-Object -TypeName System.Xml.XmlDocument
        $buildPropertiesXml.XmlResolver = $null
        $buildPropertiesXml.Load($propertiesfile)

        $buildProperties = @{}
        foreach($entry in $buildPropertiesXml.SelectNodes('//entry'))
        {
            $buildProperties[$entry.Key] = $entry.'#text'
        }

        Write-Output -InputObject $buildProperties
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1KO0eBwhWEMR6L7VeAWrbGl0
# r9GgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQK2gx1
# vfE4nOc3inZaB+HnIZ7sbjANBgkqhkiG9w0BAQEFAASBgHyhJdiUeN+1cs/xJABQ
# 206KKMH0SnvW2r827kaw1k+NbRdfGCO/bI1EBs9T3RNJx6TzdB50X7B0Qvi2sLFb
# ZYpVSZUEGSs2mRTqbwP9Jcj55NOWdM4fpTQYy7qXZsopxaLSzQriqiep2qGK7CjW
# mrmowiRXWMUNhqN6xaIpBbld
# SIG # End signature block
