function Get-BuildVariable {
    <#
    .SYNOPSIS
        Normalize build system variables

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Normalize build system variables

        Each build system exposes common variables it's own unique way, if at all.
        This function was written to enable more portable builds, and
            to avoid tightly coupling your build scripts with your build system

            Gathers from:
                AppVeyor
                GitLab CI
                Jenkins
                Teamcity
                Azure Pipelines
                Bamboo
                GoCD
                Travis CI
                GitHub Actions

            For Teamcity the VCS Checkout Mode needs to be to checkout files on agent.
            Since TeamCity 10.0, this is the default setting for the newly created build configurations.

            Git needs to be available on the agent for this.

            Produces:
                BuildSystem: Build system we're running under
                ProjectPath: Project root for cloned repo
                BranchName: git branch for this build
                CommitMessage: git commit message for this build
                BuildNumber: Build number provided by the CI system

    .PARAMETER Path
        Path to project root. Defaults to the current working path

    .PARAMETER GitPath
        Path to git.  Defaults to git (i.e. git is in $ENV:PATH)

    .NOTES
        We assume you are in the project root, for several of the fallback options

    .EXAMPLE
        Get-BuildVariable

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        Get-ProjectName

    .LINK
        Set-BuildEnvironment

    .LINK
        about_BuildHelpers
    #>
    [cmdletbinding()]
    param(
        $Path = $PWD.Path,
        [validatescript({
            if(-not (Get-Command $_ -CommandType Application -ErrorAction SilentlyContinue))
            {
                throw "Could not find command at GitPath [$_]"
            }
            $true
        })]
        $GitPath = 'git'
    )

    $Path = ( Resolve-Path $Path ).Path
    $Environment = Get-Item ENV:
    if(!$PSboundParameters.ContainsKey('GitPath')) {
        $GitPath = (Get-Command $GitPath -CommandType Application -ErrorAction SilentlyContinue)[0].Path
    }

    $WeCanGit = ( (Test-Path $( Join-Path $Path .git )) -and (Get-Command $GitPath -CommandType Application -ErrorAction SilentlyContinue) )
    if($WeCanGit)
    {
        $IGParams = @{
            Path = $Path
            GitPath = $GitPath
        }
    }
    $tcProperties = Get-TeamCityProperty # Teamcity has limited ENV: values but dumps the build configuration in a properties file.

    # Determine the build system:
    $BuildSystem = switch ($Environment.Name)
    {
        'APPVEYOR_BUILD_FOLDER' { 'AppVeyor'; break }
        'GITLAB_CI'             { 'GitLab CI' ; break }
        'JENKINS_URL'           { 'Jenkins'; break }
        'BUILD_DEFINITIONNAME'  { 'Azure Pipelines'; break }
        'TEAMCITY_VERSION'      { 'Teamcity'; break }
        'BAMBOO_BUILDKEY'       { 'Bamboo'; break }
        'GOCD_SERVER_URL'       { 'GoCD'; break }
        'TRAVIS'                { 'Travis CI'; break }
        'GITHUB_WORKFLOW'       { 'GitHub Actions'; break }
    }
    if(-not $BuildSystem)
    {
        $BuildSystem = 'Unknown'
    }

    # Find the build folder based on build system
    $BuildRoot = switch ($Environment.Name)
    {
        'APPVEYOR_BUILD_FOLDER'          { (Get-Item -Path "ENV:$_").Value; break } # AppVeyor
        'CI_PROJECT_DIR'                 { (Get-Item -Path "ENV:$_").Value; break } # GitLab CI
        'WORKSPACE'                      { (Get-Item -Path "ENV:$_").Value; break } # Jenkins Jenkins... seems generic.
        'SYSTEM_DEFAULTWORKINGDIRECTORY' { (Get-Item -Path "ENV:$_").Value; break } # Azure Pipelines (Visual studio team services)
        'BAMBOO_BUILD_WORKING_DIRECTORY' { (Get-Item -Path "ENV:$_").Value; break } # Bamboo
        'TRAVIS_BUILD_DIR'               { (Get-Item -Path "ENV:$_").Value; break } # Travis CI
        'GITHUB_WORKSPACE'               { (Get-Item -Path "ENV:$_").Value; break } # GitHub Actions
    }
    if(-not $BuildRoot)
    {
        if ($BuildSystem -eq 'Teamcity') {
            $BuildRoot = $tcProperties['teamcity.build.checkoutDir']
        } else {
            # Assumption: this function is defined in a file at the root of the build folder
            $BuildRoot = $Path
        }
    }

    # Find the git branch
    $BuildBranch = switch ($Environment.Name)
    {
        'APPVEYOR_REPO_BRANCH'          { (Get-Item -Path "ENV:$_").Value; break } # AppVeyor
        'CI_COMMIT_REF_NAME'            { (Get-Item -Path "ENV:$_").Value; break } # GitLab CI 9.0+
        'CI_BUILD_REF_NAME'             { (Get-Item -Path "ENV:$_").Value; break } # GitLab CI 8.x
        'GIT_BRANCH'                    { (Get-Item -Path "ENV:$_").Value; break } # Jenkins
        'BUILD_SOURCEBRANCHNAME'        { (Get-Item -Path "ENV:$_").Value; break } # Azure Pipelines
        'BAMBOO_REPOSITORY_GIT_BRANCH'  { (Get-Item -Path "ENV:$_").Value; break } # Bamboo
        'TRAVIS_BRANCH'                 { (Get-Item -Path "ENV:$_").Value; break } # Travis CI
        'GITHUB_REF'                    { (Get-Item -Path "ENV:$_").Value.Replace('refs/heads/', ''); break } # GitHub Actions
    }
    if(-not $BuildBranch)
    {
        if($WeCanGit)
        {
            # Using older than 1.6.3 in your build system? Yuck
            # Thanks to earl: http://stackoverflow.com/a/1418022/3067642
            $BuildBranch = Invoke-Git @IGParams -Arguments "rev-parse --abbrev-ref HEAD"
        }
    }

    # Find the git commit message
    $CommitMessage = switch ($Environment.Name)
    {
        'APPVEYOR_REPO_COMMIT_MESSAGE' {
            "$env:APPVEYOR_REPO_COMMIT_MESSAGE $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED".TrimEnd()
            break
        }
        'CI_COMMIT_SHA' {
            if($WeCanGit)
            {
                Invoke-Git @IGParams -Arguments "log --format=%B -n 1 $( (Get-Item -Path "ENV:$_").Value )"
                break
            } # Gitlab 9.0+ - thanks to mipadi http://stackoverflow.com/a/3357357/3067642
        }
        'CI_BUILD_REF' {
            if($WeCanGit)
            {
                Invoke-Git @IGParams -Arguments "log --format=%B -n 1 $( (Get-Item -Path "ENV:$_").Value )"
                break
            } # Gitlab 8.x - thanks to mipadi http://stackoverflow.com/a/3357357/3067642
        }
        'GIT_COMMIT' {
            if($WeCanGit)
            {
                Invoke-Git @IGParams -Arguments "log --format=%B -n 1 $( (Get-Item -Path "ENV:$_").Value )"
                break
            } # Jenkins - thanks to mipadi http://stackoverflow.com/a/3357357/3067642
        }
        'BUILD_SOURCEVERSIONMESSAGE' { #Azure Pipelines, present in classic build pipelines, and all YAML pipelines, but not classic release pipelines
            ($env:BUILD_SOURCEVERSIONMESSAGE).split([Environment]::NewLine,[System.StringSplitOptions]::RemoveEmptyEntries) -join " "
            break
            # Azure Pipelines Classic Build & YAML(https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables)
        }
        'BUILD_SOURCEVERSION' { #Azure Pipelines, this will be triggered in the case of a classic release pipeline
            if($WeCanGit)
            {
                Invoke-Git @IGParams -Arguments "log --format=%B -n 1 $( (Get-Item -Path "ENV:$_").Value )"
                break
            } # Azure Pipelines Classic Release (https://docs.microsoft.com/en-us/azure/devops/pipelines/release/variables)
        }
        'BUILD_VCS_NUMBER' {
            if($WeCanGit)
            {
                Invoke-Git @IGParams -Arguments "log --format=%B -n 1 $( (Get-Item -Path "ENV:$_").Value )"
                break
            } # Teamcity https://confluence.jetbrains.com/display/TCD10/Predefined+Build+Parameters
        }
        'BAMBOO_REPOSITORY_REVISION_NUMBER' {
            if($WeCanGit)
            {
                Invoke-Git @IGParams -Arguments "log --format=%B -n 1 $( (Get-Item -Path "ENV:$_").Value )"
                break
            } # Bamboo https://confluence.atlassian.com/bamboo/bamboo-variables-289277087.html
        }
        'TRAVIS_COMMIT_MESSAGE' {
            "$env:TRAVIS_COMMIT_MESSAGE"
            break
        }
        'GITHUB_SHA' {
            if($WeCanGit)
            {
                Invoke-Git @IGParams -Arguments "log --format=%B -n 1 $( (Get-Item -Path "ENV:$_").Value )"
                break
            } # GitHub Actions https://developer.github.com/actions/creating-github-actions/accessing-the-runtime-environment/#environment-variables
        }

    }
    if(-not $CommitMessage)
    {
        if($WeCanGit)
        {
            $CommitMessage = Invoke-Git @IGParams -Arguments "log --format=%B -n 1"
        }
    }
    if($CommitMessage) {$CommitMessage = $CommitMessage -join "`n"}

    # find the commit hash
    $CommitHash = switch ($Environment.Name)
    {
        'APPVEYOR_REPO_COMMIT'           { (Get-Item -Path "ENV:$_").Value; break } # AppVeyor
        'CI_COMMIT_SHA'                  { (Get-Item -Path "ENV:$_").Value; break } # GitLab CI
        'GIT_COMMIT'                     { (Get-Item -Path "ENV:$_").Value; break } # Jenkins
        'BUILD_VCS_NUMBER'               { (Get-Item -Path "ENV:$_").Value; break } # Teamcity
        'BUILD_SOURCEVERSION'            { (Get-Item -Path "ENV:$_").Value; break } # Azure Pipelines
        'BAMBOO_PLANREPOSITORY_REVISION' { (Get-Item -Path "ENV:$_").Value; break } # Bamboo
        'GO_REVISION'                    { (Get-Item -Path "ENV:$_").Value; break } # GoCD
        'TRAVIS_COMMIT'                  { (Get-Item -Path "ENV:$_").Value; break } # Travis CI
        'GITHUB_SHA'                     { (Get-Item -Path "ENV:$_").Value; break } # Github Actions
    }
    if(-not $CommitHash)
    {
        if($WeCanGit)
        {
            $CommitHash = Invoke-Git @IGParams -Arguments "log --format=%H -n 1"
        }        
    }
    # Build number
    $BuildNumber = switch ($Environment.Name)
    {
        'APPVEYOR_BUILD_NUMBER' { (Get-Item -Path "ENV:$_").Value; break } # AppVeyor
        'CI_JOB_ID'             { (Get-Item -Path "ENV:$_").Value; break } # GitLab CI 9.0+ - not perfect https://gitlab.com/gitlab-org/gitlab-ce/issues/3691
        'CI_BUILD_ID'           { (Get-Item -Path "ENV:$_").Value; break } # GitLab CI 8.x - not perfect https://gitlab.com/gitlab-org/gitlab-ce/issues/3691
        'BUILD_NUMBER'          { (Get-Item -Path "ENV:$_").Value; break } # Jenkins, Teamcity ... seems generic.
        'BUILD_BUILDNUMBER'     { (Get-Item -Path "ENV:$_").Value; break } # Azure Pipelines
        'BAMBOO_BUILDNUMBER'    { (Get-Item -Path "ENV:$_").Value; break } # Bamboo
        'GOCD_PIPELINE_COUNTER' { (Get-Item -Path "ENV:$_").Value; break } # GoCD
        'TRAVIS_BUILD_NUMBER'   { (Get-Item -Path "ENV:$_").Value; break } # Travis CI
    }
    if(-not $BuildNumber)
    {
        $BuildNumber = 0
    }

    [pscustomobject]@{
        BuildSystem = $BuildSystem
        ProjectPath = $BuildRoot
        BranchName = $BuildBranch
        CommitMessage = $CommitMessage
        CommitHash = $CommitHash
        BuildNumber = $BuildNumber
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlGZzPOqCyHMSN3EkM/X3bbSJ
# efugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTlApWX
# WsfDmeI+Ry62n54OAdgYRzANBgkqhkiG9w0BAQEFAASBgJpz9z+2yJ6AwBYXeikZ
# CE0MH9hE1px/6JPQtAdbfuJ0gumOpDh1rJPrjv6sIL6/9VgoDufo1DFphmBT2s9c
# DAr/RcTDAHOM92fWJ59GbZ1djkJkTUp8/2NENm7V+tPcv205KJmaNZcCcrE7A2An
# uojOsh3cw17elKzi9OLW+beo
# SIG # End signature block
