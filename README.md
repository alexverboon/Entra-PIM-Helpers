# Entra ID - Privileged Identity Management - Helper Scripts

## Introduction

The below referenced scripts can help you with updating Entra ID and Azure PIM Configuration settings.

1. Retrieve current PIM Configuration settings by using the **Get-AzurePIMConfiguration** or **Get-EntraGroupPIMConfiguration** functions.
2. Then Use the **Update-AzurePIMConfiguration** or **Update-EntraGroupPIMConfiguration** functions to update settings.

    > **Note:** In the examples below we're focusing on the following settings: `AllowPermanentEligibleAssignment` and `AllowPermanentActiveAssignment`
    you can update the **Get** and **Update** functions accordinly to manage other settings.

## References

- [Overview of Privileged Identity Management (PIM) API in Microsoft Graph](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagementv3-overview?view=graph-rest-1.0)
- [Migrate PIM PowerShell scripts to Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-powershell-migration)
- [List eligible Azure Active Directory PIM assignments by Kaido Järvemets](https://kaidojarvemets.com/list-eligible-azure-active-directory-pim-assignments/)
- [PIM for Groups - Part 1 by DikkeKip](https://dikkekip.github.io/posts/pim-for-groups-1/)
- [PrivilegedAssignmentSchedule.Read.AzureADGroup Permission Details by Merill.net](https://graphpermissions.merill.net/permission/PrivilegedAssignmentSchedule.Read.AzureADGroup?tabs=apiv1%2CaccessPackageAssignmentRequest1)

## Prerequisites

Install Microsoft Graph PowerShell Module

```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser -AllowClobber -Force
```

Install EasyPIM Module

Refer to the [EasyPIM Module documentation](https://github.com/kayasax/EasyPIM) for additional requirements

```powershell
Install-Module -Name EasyPIM -Force -AllowClobber -Scope CurrentUser
```

## Connect to the Tenant

Connect to your tenant using the Microsoft Graph Module

For read and write access use the following command to connect.

```powershell
connect-mggraph -scopes "RoleManagementPolicy.ReadWrite.Directory", "RoleManagement.ReadWrite.Directory", "RoleManagementPolicy.ReadWrite.AzureADGroup", "PrivilegedEligibilitySchedule.ReadWrite.AzureADGroup", "PrivilegedAssignmentSchedule.ReadWrite.AzureADGroup", "PrivilegedAccess.ReadWrite.AzureADGroup"
```

For read-only access use the following command to connect.

```powershell
connect-mggraph -scopes "RoleManagementPolicy.Read.Directory", "RoleManagement.Read.Directory", "RoleManagementPolicy.Read.AzureADGroup", "PrivilegedEligibilitySchedule.Read.AzureADGroup", "PrivilegedAssignmentSchedule.Read.AzureADGroup", "PrivilegedAccess.Read.AzureADGroup"
```

## Azure PIM

### Retrieve and review Azure PIM Configuration

```powershell
$AzurePimConfiguration = @()
$tenantid = "<TenantID>"
$subscriptionid = "<SubscriptionID>"
$AzurePimConfiguration = Get-AzurePIMConfiguration -tenantid $tenantid -subscriptionid $subscriptionid -Verbose
```

Show the results

```powershell
$AzurePimConfigurationInput = $AzurePimConfiguration | Select-Object PrincipalName, PrincipalType, RoleName, memberType, ScopeName, ScopeType, ScopeId, AllowPermanentEligibleAssignment, AllowPermanentActiveAssignment
$AzurePimConfigurationInput 
```

Only list results where AllowPermanentEligibleAssignment or AllowPermanentActiveAssignment is false

```powershell
$AzurePimConfigurationInput = $AzurePimConfiguration |  Where-Object { $_.AllowPermanentEligibleAssignment -eq "false" -or $_.AllowPermanentActiveAssignment -eq "false" } | Select-Object PrincipalName, PrincipalType, RoleName, memberType, ScopeName, ScopeId, AllowPermanentEligibleAssignment, AllowPermanentActiveAssignment
$AzurePimConfigurationInput 
```

### Update Azure PIM Configuration

First just see what would be changed

```powershell
Update-AzurePIMConfiguration -tenantID $tenantID -AzurePimConfiguration $AzurePimConfigurationInput -WhatIf
```

Update the settings

```powershell
Update-AzurePIMConfiguration -tenantID $tenantID -AzurePimConfiguration $AzurePimConfigurationInput  -verbose
```

## Entra PIM for Groups

### Retrieve and review Entra ID Groups PIM Configuration

```powershell
$tenantid = "<TenantID>"
```

```powershell
$EntragroupPIMConfigurationInput = Get-EntraPIMGroupConfiguration -tenantid $tenantID -Verbose
$EntragroupPIMConfigurationInput
```

Only list results where AllowPermanentEligibleAssignment or AllowPermanentActiveAssignment is false

```powershell
$EntragroupPIMConfigurationInput | Where-Object { $_.AllowPermanentEligibleAssignment -eq "false" -or $_.AllowPermanentActiveAssignment -eq "false"}
```

### Update PIM Settings

***Note1*** I haven't found a way to filter on groups that are already onboarded into PIM, so when you run the below command against a group that isn't onboarded yet into PIM, it will onboard.

***Note2*** The below function only updates the 'member' settings for the group, change the code -type to owner if you want to update owner settings.

```powershell
Update-EntraGroupPIMConfiguration -tenantID $tenantId -EntragroupPIMConfiguration $EntragroupPIMConfigurationInput -whatif
```
