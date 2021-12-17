function Publish-PSMDModuleToAutomationAccount {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Will be used 
    Long description
    
    .PARAMETER AutomationAccountSubscriptionId
    Parameter description
    
    .PARAMETER AutomationAccountResourceGroupName
    Parameter description
    
    .PARAMETER AutomationAccountName
    Parameter description
    
    .PARAMETER ModuleLink
    Parameter description
    
    .PARAMETER ModuleName
    Parameter description
    
    .EXAMPLE
    PS C:\> Publish-PSMDModuleToAutomationAccount
    
    An example
    
    .NOTES
    General notes
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$AutomationAccountSubscriptionId = "ee5f8667-c5cd-4990-b756-8360bf2be985",
        [Parameter(Mandatory=$true)][string]$AutomationAccountResourceGroupName = "BASF_RG_RoleAssign_FirstWave",
        [Parameter(Mandatory=$true)][string]$AutomationAccountName = "BASF-AA-RoleAssign-FirstWave",
        [Parameter(Mandatory=$true)][uri]$ModuleLink = "https://samoduletesting.blob.core.windows.net/testcontainer2/RbacAutomationModule_2021-12-16_15-29-30.zip??sv=2020-08-04&ss=b&srt=sco&sp=rwlactfx&se=2021-12-31T22:58:06Z&st=2021-12-16T14:58:06Z&spr=https&sig=Il7PEsc9gdOrRGVS5lcqhTDAxXfb34uhbodYV7LwgLY%3D", #"https://samoduletesting.blob.core.windows.net/testcontainer2/RbacAutomationModule_2021-12-16_15-29-30.zip?sp=r&st=2021-12-17T10:56:40Z&se=2021-12-31T18:56:40Z&spr=https&sv=2020-08-04&sr=b&sig=C1gruzVxC%2Fqn6fHDVZwqqyjeEKACkddjdy5iUUqlma0%3D",
        [Parameter(Mandatory=$true)][string]$ModuleName = "ModuleTesting2"
    )

    $AutomationAccountSubscriptionId = "ee5f8667-c5cd-4990-b756-8360bf2be985"
    $AutomationAccountResourceGroupName = "BASF_RG_RoleAssign_FirstWave"
    $AutomationAccountName = "BASF-AA-RoleAssign-FirstWave"
    [uri]$ModuleLink = "https://samoduletesting.blob.core.windows.net/testcontainer2/RbacAutomationModule_2021-12-16_15-29-30.zip?sv=2020-08-04&ss=b&srt=sco&sp=rwlactfx&se=2021-12-31T22:58:06Z&st=2021-12-16T14:58:06Z&spr=https&sig=Il7PEsc9gdOrRGVS5lcqhTDAxXfb34uhbodYV7LwgLY%3D"
    $ModuleName = "ModuleTesting2"

    # https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules#import-modules-by-using-powershell

    try {
        $null = Set-AzContext -SubscriptionId $StorageAccountSubscriptionId `
                              -ErrorAction Stop
    }
    catch {
        Throw "Please provide a valid tenant or a valid subscription"
    }

    # https://docs.microsoft.com/en-us/powershell/module/az.automation/new-azautomationmodule?view=azps-7.0.0#example-1--import-a-module
    try {
        New-AzAutomationModule -AutomationAccountName $AutomationAccountName `
                               -Name $ModuleName `
                               -ContentLinkUri $ModuleLink `
                               -ResourceGroupName $AutomationAccountResourceGroupName `
                               -ErrorAction Stop
    }
    catch {
        Throw "New-AzAutomationModule"
    }
}