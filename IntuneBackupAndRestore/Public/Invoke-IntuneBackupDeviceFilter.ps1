function Invoke-IntuneBackupDeviceFilter {
    <#
    .SYNOPSIS
    Backup Intune Device Filters

    .DESCRIPTION
    Backup Intune Device Filters as JSON files per Device Filter to the specified Path.

    .PARAMETER Path
    Path to store backup files

    .EXAMPLE
    Invoke-IntuneBackupDeviceFilter -Path "C:\temp"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Folder = 'Filters',

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
    # Get all Filters
    $Policies = Invoke-MSGraphRequest -Url 'deviceManagement/assignmentFilters' | Get-MSGraphAllPages

    foreach ($Policy in $Policies) {
        $fileName = ($Policy.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $clientAppDetails | ConvertTo-Json | Out-File -LiteralPath "$path\$folder\$($fileName).json"

        [PSCustomObject]@{
            'Action' = 'Backup'
            'Type'   = 'Filters'
            'Name'   = $Policy.displayName
            'Path'   = "$Folder\$($fileName).json"
        }
    }
}
