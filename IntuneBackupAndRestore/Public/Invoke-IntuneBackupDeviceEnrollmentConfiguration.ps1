function Invoke-IntuneBackupDeviceEnrollmentConfiguration {
    <#
    .SYNOPSIS
    Backup Intune Device Enrollment Configurations

    .DESCRIPTION
    Backup Intune Device Enrollment Configurations as JSON files per Device Enrollment Configuration Policy to the specified Path.

    .PARAMETER Path
    Path to store backup files

    .EXAMPLE
    Invoke-IntuneBackupDeviceEnrollmentConfiguration -Path "C:\temp"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Folder = 'Device Enrollment Configurations',

        [Parameter(Mandatory = $false)]
        [ValidateSet('v1.0', 'Beta')]
        [string]$ApiVersion = 'Beta'
    )

    # Set the Microsoft Graph API endpoint
    if (-not ((Get-MSGraphEnvironment).SchemaVersion -eq $apiVersion)) {
        Update-MSGraphEnvironment -SchemaVersion $apiVersion -Quiet
        Connect-MSGraph -ForceNonInteractive -Quiet
    }

    # Create folder if not exists
    if (-not (Test-Path "$Path\$Folder")) {
        $null = New-Item -Path "$Path\$Folder" -ItemType Directory
    }

    # Get all device configurations
    $EnrollmentConfigurations = Get-DeviceManagement_DeviceEnrollmentConfigurations | Get-MSGraphAllPages


    foreach ($Configuration in $EnrollmentConfigurations) {
        $fileName = ($Configuration.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        switch ($Configuration.'@odata.type') {
            '#microsoft.graph.deviceEnrollmentLimitConfiguration' {
                $fileType = 'DeviceLimitRestrictions'
                break
            }
            '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration' {
                $fileType = 'DeviceTypeRestrictions'
                break
            }
            '#microsoft.graph.deviceEnrollmentWindowsHelloForBusinessConfiguration' {
                $fileType = 'WHfBConfiguration'
                break
            }
            default {
                $fileType = ($Configuration.id).Split('_')[1]
            }
        }
        # Export the Device Configuration Profile
        $Configuration | ConvertTo-Json -Depth 100 | Out-File -LiteralPath "$Path\$Folder\$($fileName)_$($fileType).json"

        [PSCustomObject]@{
            'Action' = 'Backup'
            'Type'   = "$Folder"
            'Name'   = "$($fileName)_$($fileType)"
            'Path'   = "$Folder\$($fileName)_$($fileType).json"
        }
    }
}