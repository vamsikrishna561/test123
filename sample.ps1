
# PowerShell code
########################################################
# Log in to Azure with AZ (standard code)
########################################################
Write-Verbose -Message 'Connecting to Azure'
  
# Name of the Azure Run As connection
$ConnectionName = 'AzureRunAsConnection'
try
{
    # Get the connection properties
    $ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName      
   
    'Log in to Azure...'
    $null = Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $ServicePrincipalConnection.TenantId `
        -ApplicationId $ServicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint 
}
catch 
{
    if (!$ServicePrincipalConnection)
    {
        # You forgot to turn on 'Create Azure Run As account' 
        $ErrorMessage = "Connection $ConnectionName not found."
        throw $ErrorMessage
    }
    else
    {
        # Something else went wrong
        Write-Error -Message $_.Exception.Message
        throw $_.Exception
    }
}
########################################################
 
# Variables for retrieving the correct secret from the correct vault
$VaultName = "samplekeyvault12"
$SecretName = "vamsi"
 
# Retrieve value from Key Vault
$MySecretValue = (Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName)
#$keyVaultValue=  | ConvertFrom-SecureString -AsPlainText

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MySecretValue.SecretValue)
$plaintext = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
 
# Write value to screen for testing purposes
Write-Output "The value of my secret is $($plaintext)"