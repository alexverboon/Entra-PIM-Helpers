
Function Get-AzurePIMConfiguration {
    <#
.SYNOPSIS
    Get Azure PIM Configuration
.DESCRIPTION
    Get Azure PIM Configuration for all Azure Resources
.EXAMPLE
    Get-AzurePIMConfiguration.ps1   
.NOTES
    File Name      : Get-AzurePIMConfiguration.ps1
    Author         : Alesx Verboon
    Prerequisite   : PowerShell 7.1.3 or later
#>
    [CmdletBinding()]
    param (
        # Tenant ID
        [Parameter(Mandatory = $true)]
        [string]$tenantid,
        # Subscription ID
        [Parameter(Mandatory = $true)]
        [string]$subscriptionid
    )

    $SubscriptionName = (Get-AzSubscription -SubscriptionId $subscriptionid).Name
    $azureobjects = [System.Collections.ArrayList]::new()

    # Get all Azure Resource PIM Eligible Assignments
    $AzureResourcePIMEligibleAssignments = Get-PIMAzureResourceEligibleAssignment -tenantID $tenantid -subscriptionID $subscriptionid

    ForEach ($resource in $AzureResourcePIMEligibleAssignments) {
        Write-verbose "Processing $($resource.PrincipalName) on scope: $($resource.ScopeName) for Role: $($resource.RoleName)"
        $PIMAzureResourcePolicy = Get-PIMAzureResourcePolicy  -tenantID $tenantID -scope $resource.ScopeId -rolename $resource.RoleName 

        [void]$azureobjects.Add(
            [PSCustomObject][ordered]@{
                SubscriptionName                 = $SubscriptionName
                subscriptionid                   = $subscriptionid
                id                               = $resource.Id
                PrincipalType                    = $resource.PrincipalType
                PrincipalId                      = $resource.PrincipalId
                PrincipalName                    = $resource.PrincipalName
                PrincipalEmail                   = $resource.PrincipalEmail
                RoleId                           = $resource.RoleId
                RoleName                         = $resource.RoleName
                ScopeType                        = $resource.ScopeType
                ScopeName                        = $resource.ScopeName
                ScopeId                          = $resource.ScopeId
                memberType                       = $resource.memberType
                endDateTimeUtc                   = $resource.endDateTimeUtc
                AllowPermanentEligibleAssignment = $PIMAzureResourcePolicy.AllowPermanentEligibleAssignment
                AllowPermanentActiveAssignment   = $PIMAzureResourcePolicy.AllowPermanentActiveAssignment
                #PIMAzureResourcePolicy = $PIMAzureResourcePolicy
            }
        )
    }
    return $azureobjects
}
