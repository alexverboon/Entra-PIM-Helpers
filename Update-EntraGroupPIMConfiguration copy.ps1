Function Update-EntraGroupPIMConfiguration {
    <#
.SYNOPSIS
    Update Entra Groups PIM Configuration
.DESCRIPTION    
    Update PIM Configuration for Entra Groups
.COMPONENT  
    EasyPIM 
.EXAMPLE    
    Update-EntraGroupPIMConfiguration.ps1 -tenantID $tenantId -EntragroupPIMConfigurationInput EntragroupPIMConfigurationInput
.NOTES  
    File Name      : Update-AzurePIMConfiguration.ps1
    Author         : Alesx Verboon
    Prerequisite   : PowerShell 7.1.3 or later
#>   
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Tenant ID            
        [Parameter(Mandatory = $true)]
        [string]$tenantID,
        # Input Object that contains Entra ID Group resources that must be updated. Use Get-EntraGroupPIMConfiguration to prepare the input object
        [Parameter(Mandatory = $true)]
        [array]$EntragroupPIMConfiguration
    )

    ForEach ($Group in $EntragroupPIMConfiguration) {
        if ($PSCmdlet.ShouldProcess("$($Group.displayName) ", "Update PIM settings")) {
            Set-PIMGroupPolicy -tenantID $tenantID -groupID $Group.Id -type member `
                -AllowPermanentEligibility $true `
                -AllowPermanentActiveAssignment $true
        }
    }
}
