function Invoke-IntuneBackupRoleDefinition {
    <#
    .SYNOPSIS
    Backup Intune Role Definitions

    .DESCRIPTION
    Backup Intune Role Definitions as JSON files to the specified Path.

    .PARAMETER Path
    Path to store backup files

    .EXAMPLE
    Invoke-IntuneBackupRoleDefinition -Path "C:\temp"
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
    if (-not (Test-Path "$Path\$Folder")) {
        $null = New-Item -Path "$Path\$Folder" -ItemType Directory
    }

    # Get all Roles
    $Roles = Get-IntuneRoleDefinition

    foreach ($Role in $Roles) {
        $fileName = ($Role.displayName)
        $Role | ConvertTo-Json -Depth 100 | Out-File -LiteralPath "$Path\$Folder\$fileName.json"

        [PSCustomObject]@{
            'Action' = 'Backup'
            'Type'   = "$Folder"
            'Name'   = $Role.displayName
            'Path'   = "$Folder\$fileName.json"
        }
    }
}