# This script updates the existing hostpool registration key as provided by a CSV file.

# ---- Dependencies ---- #
# Before running this script, ensure that the following modules are loaded:
# - Az.DesktopVirtualization
# - Az.KeyVault
# Install as such `Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force`

# Tested with PowerShell 7.1.4

# ---- Required Environment Variables ---- #
# KeyVaultName   -> Name of the Key Vault where the hostpool registration key is stored
# SubscriptionId -> Id of the subscription

# ---- Optional Environment Variables ---- #
# FileLocation -> Location of the directory containing the CSV file

if (-not (Test-Path env:KeyVaultName)) { 
    Write-Host "KeyVaultName is not set, please set this value" 
    exit 1
}

if (-not (Test-Path env:SubscriptionId)) { 
    Write-Host "SubscriptionId is not set, please set this value" 
    exit 1
}

if (-not (Test-Path env:KeyVaultName)) { $Env:FileLocation = "./blobs"}

# Read through the generated CSV
$data = Import-Csv "./hostpools.csv"
foreach ($row in $data) {
    Write-Host "Reading row..."
    $resource_group = $row.resource_group
    $hostpool = $row.hostpool

    # Generate new registration host key
    Write-Host "Updating registration key for: $hostpool in $resource_group"
    $GetToken = New-AzWvdRegistrationInfo `
        -SubscriptionId $Env:SubscriptionId `
        -ResourceGroupName $resource_group `
        -HostPoolName $hostpool `
        -ExpirationTime (Get-Date).AddDays(27) `

    $secret_name = "${resource_group}-hostkey".ToLower() -replace "_", "-"
    $secret_value = ConvertTo-SecureString -String $GetToken.Token -AsPlainText -Force

    # Update host key in Key Vault
    Write-Host "Updating secret: $secret_name"
    $SetContext = Set-AzKeyVaultSecret -VaultName $Env:KeyVaultName -Name $secret_name -SecretValue $secret_value
    Write-Host "Done`r`n"    
}