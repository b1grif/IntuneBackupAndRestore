function Invoke-IntuneBackupRoleAssignment {
    <#
    .SYNOPSIS
    Backup Intune Role Assignments

    .DESCRIPTION
    Backup Intune Role Assignments as JSON files to the specified Path.

    .PARAMETER Path
    Path to store backup files

    .EXAMPLE
    Invoke-IntuneBackupRoleAssignment -Path "C:\temp"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Folder = 'Roles',

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

    # Get all Role Assignments
    $Assignments = Get-IntuneRoleAssignment

    foreach ($Assignment in $Assignments) {
        $fileName = ($Assignment.displayName)
        $Assignment | ConvertTo-Json -Depth 100 | Out-File -LiteralPath "$Path\$Folder\Assignments\$fileName.json"

        [PSCustomObject]@{
            'Action' = 'Backup'
            'Type'   = "$Folder Assignments"
            'Name'   = $Assignment.displayName
            'Path'   = "$Folder\Assignments\$fileName.json"
        }
    }
}