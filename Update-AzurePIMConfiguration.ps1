Function Update-AzurePIMConfiguration {
    <#
.SYNOPSIS
    Update Azure PIM Configuration
.DESCRIPTION    
    Update Azure PIM Configuration for Azure Resources
.COMPONENT  
    EasyPIM 
.EXAMPLE    
    Update-AzurePIMConfiguration.ps1 -tenantID $tenantId -AzurePimConfiguration $AzurePimConfigurationInput
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
        # Input Object that contains Azure PIM resources that must be updated. Use Get-AzurePIMConfiguration to prepare the input object
        [Parameter(Mandatory = $true)]
        [array]$AzurePimConfiguration
    )

    ForEach ($resource in $AzurePimConfiguration) {
        if ($PSCmdlet.ShouldProcess("$($resource.scopeName) - Role: $($resource.RoleName)", "Update PIM settings for Group/User: $($resource.PrincipalName)")) {
            Set-PIMAzureResourcePolicy -tenantID $tenantID -scope $resource.ScopeId -rolename $resource.RoleName `
                -AllowPermanentEligibility $true `
                -AllowPermanentActiveAssignment $true
        }
    }
}
