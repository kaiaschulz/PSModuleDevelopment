function Write-PSMDFileToStorageAccount {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    This function will be used to copy the module to a StorageAccount blob container to further use it for Azure AutomationAccount or Azure Functions.

    Long description
    
    .PARAMETER Source
    Full path were the module is located as .zip or folder

    Parameter description
    
    .PARAMETER KeyVaultName
    Name of the KeyVault where the SasToken of the Storage Account is stored.
    Highly recommend to store the SasToken of the Storage Account in a Key Vault.

    Parameter description
    
    .PARAMETER KeyVaultSecretNameSasToken
    Name of the Secret where the SasToken is saved

    Parameter description
    
    .PARAMETER SasToken
    Instead of using a KeyVault for storing the SasToken in a secure way the SasToken can be inserted by this parameter.
    Not recommended, cause it is a string!

    Parameter description
    
    .PARAMETER StorageAccountSubscriptionId
    SubscriptionId where the StorageAccount is located

    Parameter description
    
    .PARAMETER StorageAccountName
    Name of the Storage Account

    Parameter description
    
    .PARAMETER StorageAccountContainer
    Name of the StorageAccount Container.
    Valid names start and end with a lower case letter or a number and has in between a lower case letter, number or dash with no consecutive dashes and is 3 through 63 characters long.
    By default, the inserted name will be converted to lowercase.

    Parameter description
    
    .PARAMETER StorageAccountContainerCreate
    If a container is not available and should be created with this function the parameter need to be $true
    The default parameter is $false

    Parameter description
    
    .PARAMETER StorageAccountBlobName
    Name of the StorageAccount Blob where the module will be copied.
    If nothing will be entered the file/folder-name (leaf) of the source-parameter will be used

    Parameter description
    
    .PARAMETER StorageAccountBlobOverwrite
    If a blob with the same name already exist it can be overwritten with setting the parameter to $true
    The default paramter is $false

    Parameter description
    
    .EXAMPLE
    PS C:\> Write-PSMDFileToStorageAccount

    An example
    
    .NOTES
    General notes
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Source = "C:\Temp\RbacAutomationModule_2021-12-17_12-31-10.zip",

        [Parameter(Mandatory=$false)][string]$KeyVaultName = "kvmoduletesting",
        [Parameter(Mandatory=$false)][string]$KeyVaultSecretNameSasToken = "SasToken",

        [Parameter(Mandatory=$false)][string]$SasToken,
        [Parameter(Mandatory=$true)][string]$StorageAccountSubscriptionId = "ee5f8667-c5cd-4990-b756-8360bf2be985",
        [Parameter(Mandatory=$true)][string]$StorageAccountName = "samoduletesting",
        [Parameter(Mandatory=$true)][string]$StorageAccountContainer = "RbacAutomationModule",
        [Parameter(Mandatory=$false)][bool]$StorageAccountContainerCreate = $false,
        [Parameter(Mandatory=$false)][string]$StorageAccountBlobName = $(Split-Path $Source -leaf),
        [Parameter(Mandatory=$false)][bool]$StorageAccountBlobOverwrite = $false
    )


    $StorageAccountContainer = $StorageAccountContainer.ToLower()

    try {
        $null = Set-AzContext -SubscriptionId $StorageAccountSubscriptionId `
                              -ErrorAction Stop
    }
    catch {
        Throw "Please provide a valid tenant or a valid subscription"
    }

    if($KeyVaultName -and $KeyVaultSecretNameSasToken) {
        try {
            $SasToken = Convert-PSMDSecureString -pass (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecretNameSasToken -ErrorAction Stop).SecretValue
        }
        catch {
            Throw "Unable to receive the secret from the KeyVault"
        }
    }
    elseif (!($SasToken)) {
        Throw "SasToken is needed for the Storage Account context"
    }

    # https://docs.microsoft.com/en-us/powershell/module/az.storage/new-azstoragecontext?view=azps-7.0.0#example-9--create-a-context-by-using-an-sas-token
    try {
        $StorageAccountContext = New-AzStorageContext -StorageAccountName $StorageAccountName `
                                                      -SasToken $SasToken `
                                                      -ErrorAction Stop
    }
    catch {
        Throw "New-AzStorageContext"
    }

    # https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstoragecontainer?view=azps-7.0.0
    try {
        $StorageAccountBlob = Get-AzStorageContainer -Name $StorageAccountContainer `
                                                     -Context $StorageAccountContext `
                                                     -ErrorAction Ignore
    }
    catch {
    }
    finally {
        if($StorageAccountContainerCreate) {
            try {
                # https://docs.microsoft.com/en-us/powershell/module/az.storage/new-azstoragecontainer?view=azps-7.0.0#example-1--create-an-azure-storage-container
                $StorageAccountBlob = New-AzStorageContainer -Name $StorageAccountContainer `
                                                             -Context $StorageAccountContext `
                                                             -Permission Off `
                                                             -ErrorAction Stop
            }
            catch {
                Throw "New-AzureStorageContainer"
            }
        }
        else {
            Throw "No container found or 'StorageAccountContainerCreate'-parameter not `$true"
        }
    }

    # https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageblob?view=azps-7.0.0
    try {
        $StorageAccountBlob = Get-AzStorageBlob -Container $StorageAccountContainer `
                                                -Blob $StorageAccountBlobName `
                                                -Context $StorageAccountContext `
                                                -ErrorAction Ignore
    }
    catch {
    }
    finally {
        if(($StorageAccountBlob -and $StorageAccountBlobOverwrite) `
           -or `
           (!($StorageAccountBlob) -and !($StorageAccountBlobOverwrite)) `
           -or `
           (!($StorageAccountBlob) -and $StorageAccountBlobOverwrite)) {
            try {
                if(Test-Path -Path $Source -PathType Leaf) {
                    if($StorageAccountBlob -and $StorageAccountBlobOverwrite) {
                        # https://docs.microsoft.com/en-us/powershell/module/az.storage/set-azstorageblobcontent?view=azps-7.0.0#example-3--overwrite-an-existing-blob
                        $StorageAccountBlob | Set-AzStorageBlobContent -File $Source `
                                                                       -Context $StorageAccountContext `
                                                                       -Force `
                                                                       -ErrorAction Stop
                    }
                    else {
                        # https://docs.microsoft.com/en-us/powershell/module/az.storage/set-azstorageblobcontent?view=azps-7.0.0#example-1--upload-a-named-file
                        Set-AzStorageBlobContent -Container $StorageAccountContainer `
                                                 -File $Source `
                                                 -Blob $StorageAccountBlobName `
                                                 -Context $StorageAccountContext `
                                                 -ErrorAction Stop
                    }
                }
                elseif(Test-Path -Path $Source -PathType Container) {
                    # https://docs.microsoft.com/en-us/powershell/module/az.storage/set-azstorageblobcontent?view=azps-7.0.0#example-2--upload-all-files-under-the-current-folder
                    Get-ChildItem -Path $Source `
                                  -File `
                                  -Recurse `
                                  | Set-AzStorageBlobContent -Container $StorageAccountContainer `
                                                             -Context $StorageAccountContext `
                                                             -ErrorAction Stop
                }
                else {
                    Throw "Unsupported source"
                }
            }
            catch {
                Throw "Set-AzStorageBlobContent"
            }
        }
        else {
            Throw "Unexpected behavior"
        }
    }
}