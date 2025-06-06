# Helper function to allow like comparison for each item in an array, against a property (or nested property) in a collection
function Invoke-LikeFilter {
    [cmdletbinding()]
    param(
        $Collection, # Collection to filter
        $PropertyName, # Filter on this property in the Collection.  If not specified, use each item in collection
        [object[]]$NestedPropertyName, # Filter on this array of nested properties in the Collection.  e.g. department, name = $Collection.Department.Name
        [string[]]$FilterArray, # Array of strings to filter on with a -like operator
        [ValidateCount(2,2)][string[]]$FilterReplace, # using array to get the parameters for the .replace() method to run on every object in the FilterArray
        #Added to be able to replace Windows back slashes with the forward slashes used in the Git paths but could be used for other things
        [switch]$Not # return items that are not -like...
    )
    if($FilterArray)
    {
        Write-Verbose "Running FilterArray [$FilterArray] against [$($Collection.count)] items"
        if ($PSBoundParameters.ContainsKey('FilterReplace'))
        {
            [string[]]$NormalizedFilterArray = @()
            foreach ($filter in $FilterArray) {
                $NormalizedFilterArray += $filter.replace($FilterReplace[0],$FilterReplace[1])
            }
            $FilterArray = $NormalizedFilterArray
            Write-Verbose "Strings have been normalized to [$FilterArray]"
        }
        $Collection | Where-Object {
            $Status = $False
            foreach($item in $FilterArray)
            {
                if($PropertyName)
                {
                    if($_.$PropertyName -like $item)
                    {
                        $Status = $True
                    }
                }
                elseif($NestedPropertyName)
                {
                    $dump = $_
                    $Value = $NestedPropertyName | Foreach-Object -process {$dump = $dump.$_} -end {$dump}
                    if($Value -like $item)
                    {
                        $Status = $True
                    }
                }
                else
                {
                    if($_ -like $item)
                    {
                        $Status = $True
                    }
                }
            }
            if($Not)
            {
                -not $Status
            }
            else
            {
                $Status
            }
        }
    }
    else
    {
        $Collection
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6D3wFhtYz+fNHmRebfdcsdk3
# 9pegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSv0Bcj
# umN+X7cDJYeJwQJbieOocDANBgkqhkiG9w0BAQEFAASBgKrOioUqTbRNiTc6O2KE
# P3kQ4oJvqds9G4UwARYh01fr1yrZIYSorHpFsTqNrkOaZ5I5/0qhG/j4sGj3DJpC
# MtfyqFwPGevxn5C5CeilUH+wfoZhgzW4ALICPLwTGUV1KPqPd7tymCQdVnyNEqUt
# MYm8dxVKZhV0m5Y4IJ2eNQ3b
# SIG # End signature block
