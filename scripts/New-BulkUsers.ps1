<#
.SYNOPSIS
    Bulk-create Active Directory users from a CSV file.

.DESCRIPTION
    Reads FirstName, LastName, Department and Title from a CSV and creates one user per row
    in OU=<Department>,OU=Users,OU=Yardstick. Usernames follow firstname.lastname.

    - Asks for the temporary password at run time. No password is stored in the script.
    - Every new user must change the password at first sign-in.
    - Skips users that already exist, so the script is safe to run more than once.
    - Supports -WhatIf to preview changes without creating anything.

.EXAMPLE
    .\New-BulkUsers.ps1 -CsvPath .\users.csv -WhatIf
    Shows what would be created.

.EXAMPLE
    .\New-BulkUsers.ps1 -CsvPath .\users.csv
    Creates the users.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [string]$Domain = 'yardstick.local',

    [string]$BaseOU = 'OU=Users,OU=Yardstick,DC=yardstick,DC=local'
)

Import-Module ActiveDirectory -ErrorAction Stop

$rows = Import-Csv -Path $CsvPath
$password = Read-Host -Prompt 'Temporary password for the new users' -AsSecureString

$created = 0
$skipped = 0
$failed  = 0

foreach ($row in $rows) {
    $sam = ('{0}.{1}' -f $row.FirstName, $row.LastName).ToLower()
    $ou  = "OU=$($row.Department),$BaseOU"

    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Warning "$sam already exists. Skipped."
        $skipped++
        continue
    }

    if ($PSCmdlet.ShouldProcess($sam, "Create user in $ou")) {
        try {
            $params = @{
                Name                  = "$($row.FirstName) $($row.LastName)"
                GivenName             = $row.FirstName
                Surname               = $row.LastName
                DisplayName           = "$($row.FirstName) $($row.LastName)"
                SamAccountName        = $sam
                UserPrincipalName     = "$sam@$Domain"
                Title                 = $row.Title
                Department            = $row.Department
                Path                  = $ou
                AccountPassword       = $password
                ChangePasswordAtLogon = $true
                Enabled               = $true
                ErrorAction           = 'Stop'
            }
            New-ADUser @params
            Write-Host "Created $sam in $($row.Department)" -ForegroundColor Green
            $created++
        }
        catch {
            Write-Warning "Failed to create $sam : $($_.Exception.Message)"
            $failed++
        }
    }
}

Write-Host ''
Write-Host "Done. Created: $created  Skipped: $skipped  Failed: $failed"
