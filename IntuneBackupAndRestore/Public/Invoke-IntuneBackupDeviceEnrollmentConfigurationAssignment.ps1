function Invoke-IntuneBackupDeviceEnrollmentConfigurationAssignment {
    <#
    .SYNOPSIS
    Backup Intune Device Enrollment Configuration Assignments

    .DESCRIPTION
    Backup Intune Device Enrollment Configuration Assignments as JSON files per Device Enrollment Configuration Policy to the specified Path.

    .PARAMETER Path
    Path to store backup files

    .EXAMPLE
    Invoke-IntuneBackupDeviceEnrollmentConfigurationAssignment -Path "C:\temp"
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
    if (-not (Test-Path "$Path\$Folder\Assignments")) {
        $null = New-Item -Path "$Path\$Folder\Assignments" -ItemType Directory
    }

    # Get all assignments from all policies
    $EnrollmentConfigurations = Get-DeviceManagement_DeviceEnrollmentConfigurations | Get-MSGraphAllPages

    foreach ($deviceConfiguration in $EnrollmentConfigurations) {
        $assignments = Get-DeviceManagement_DeviceEnrollmentConfigurations_Assignments -deviceEnrollmentConfigurationId $deviceConfiguration.id
        if ($assignments) {
            $fileName = ($deviceConfiguration.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $fileType = ($deviceConfiguration.id).Split('_')[1]
            $assignments | ConvertTo-Json | Out-File -LiteralPath "$path\$Folder\Assignments\$($fileName)_$($fileType).json"
            [PSCustomObject]@{
                'Action' = 'Backup'
                'Type'   = "$Folder Assignments"
                'Name'   = "$($fileName)_$($fileType)"
                'Path'   = "$Folder\Assignments\$($fileName)_$($fileType).json"
            }
        }
    }
}