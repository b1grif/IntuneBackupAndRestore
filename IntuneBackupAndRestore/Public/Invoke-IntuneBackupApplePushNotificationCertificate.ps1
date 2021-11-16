function Invoke-IntuneBackupApplePushNotificationCertificate {
    <#
    .SYNOPSIS
    Backup Intune Apple Push Notification Certificate

    .DESCRIPTION
    Backup Intune Apple Push Notification Certificate as JSON files to the specified Path.

    .PARAMETER Path
    Path to store backup files

    .EXAMPLE
    Invoke-IntuneBackupApplePushNotificationCertificate -Path "C:\temp"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Folder = 'Apple Certificate',

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

    # Get all Certificates
    $Certificates = Get-IntuneApplePushNotificationCertificate

    foreach ($Certificate in $Certificates) {
        $fileName = ($Certificate.CertificateSerialNumber)
        $Certificate | ConvertTo-Json -Depth 100 | Out-File -LiteralPath "$Path\$Folder\$fileName.json"

        [PSCustomObject]@{
            'Action' = 'Backup'
            'Type'   = "$Folder"
            'Name'   = $FileName
            'Path'   = "$Folder\$fileName.json"
        }
    }
}