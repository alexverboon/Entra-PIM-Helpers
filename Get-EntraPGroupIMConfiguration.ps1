Function Get-EntraPIMGroupConfiguration {
    <#
.SYNOPSIS
    Get Entra PIM Group Configuration
.DESCRIPTION    
    Get Entra PIM Group Configuration for all PIM enabled Groups
.EXAMPLE    
    Get-EntraPIMGroupConfiguration.ps1
.NOTES  
    File Name      : Get-AzurePIMConfiguration.ps1
    Author         : Alesx Verboon
    Prerequisite   : PowerShell 7.1.3 or later
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$tenantid
    )

    $groupobjects = [System.Collections.ArrayList]::new()
    $AllGroups = Get-MgGroup -All -Property * 

    ForEach ($group in $AllGroups) {
        Write-Verbose "Processing $($group.DisplayName)"
        $PIMGroupEligibleAssignment = $null
        $PIMGroupActiveAssignment = $null
        $PIMGroupPolicy = $null

        If ($group.GroupTypes -contains "DynamicMembership" -or $group.OnPremisesSyncEnabled -eq $true) {
            Write-Verbose "Skipping $($group.DisplayName) as it is a dynamic group or has on-premises sync enabled"
        }
        Else {
            $PIMGroupEligibleAssignment = Get-PIMGroupEligibleAssignment -tenantID $tenantID -groupID $group.Id -ErrorAction SilentlyContinue
            $PIMGroupActiveAssignment = Get-PIMGroupActiveAssignment -tenantID $tenantID -groupID $group.Id -ErrorAction SilentlyContinue
            $PIMGroupPolicy = Get-PIMGroupPolicy -tenantID $tenantID -groupID $group.Id -type member -ErrorAction SilentlyContinue
            $isAssignableToRole = if ($group.IsAssignableToRole -eq $true) { $true } else { $false }
            $OnPremisesSyncEnabled = if ($group.OnPremisesSyncEnabled -eq $true) { $true } else { $false }

            [void]$groupobjects.Add(
                [PSCustomObject]@{
                    Id                               = $group.Id
                    displayName                      = $group.DisplayName
                    description                      = $group.Description
                    IsAssignableToRole               = $isAssignableToRole
                    GroupTypes                       = $group.GroupTypes
                    AllowPermanentEligibleAssignment = $PIMGroupPolicy.AllowPermanentEligibleAssignment
                    AllowPermanentActiveAssignment   = $PIMGroupPolicy.AllowPermanentActiveAssignment
                    PIMGroupEligibleAssignment       = $PIMGroupEligibleAssignment
                    PIMGroupActiveAssignmen          = $PIMGroupActiveAssignment
                    #PIMGroupPolicy              = $PIMGroupPolicy
                    OnPremisesSyncEnabled            = $OnPremisesSyncEnabled
                }
            )
        }
    }
    return $groupobjects
}
