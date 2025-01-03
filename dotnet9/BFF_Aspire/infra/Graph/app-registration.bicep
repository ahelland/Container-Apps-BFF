extension microsoftGraphV1_0

@description('The name of the Key Vault where the certificate for authentication will be stored')
param keyVaultName string

@description('The location used for all deployed resources')
param location string

@description('Specifies the short certificate prefix for the full certificate name')
param certificateName string = 'cert-${uniqueString('kv')}'

@description('Specifies the certificate subject name')
param subjectName string

@description('Specifies the current time in utc to use in a deployment script')
param utcValue string = utcNow()

@description('The name of the App Registration')
param appName string

param identifierUri string  = 'api://${tenant().tenantId}/${appName}'

param uamiName string

param caeDomainName string

resource vault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

resource webIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: uamiName
}

// Assign the Managed Identity the role (Key Vault Certificates Officer) to create certificates in the Key Vault
resource kvMiRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vault.id, webIdentity.id, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985'))
  scope: vault
  properties: {
    principalId: webIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId:  subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')
  }
}

// Deployment script run by the webIdentity MSI to create cert and get the public key and cert metadata
resource createAddCertificate 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createAddCertificate'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${webIdentity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '8.3'
    timeout: 'PT30M'
    arguments: ' -vaultName ${vault.name} -certificateName ${certificateName} -subjectName ${subjectName}'
    scriptContent: '''
      param(
        [string] [Parameter(Mandatory=$true)] $vaultName,
        [string] [Parameter(Mandatory=$true)] $certificateName,
        [string] [Parameter(Mandatory=$true)] $subjectName
      )
      $ErrorActionPreference = 'Stop'
      $DeploymentScriptOutputs = @{}
      $existingCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName
      if ($existingCert -and $existingCert.Certificate.Subject -eq $subjectName) {
        Write-Host 'Certificate $certificateName in vault $vaultName is already present.'

        $certValue = (Get-AzKeyVaultSecret -VaultName $vaultName -Name $certificateName).SecretValue | ConvertFrom-SecureString -AsPlainText
        $pfxCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @([Convert]::FromBase64String($certValue),"",[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        $publicKey = [System.Convert]::ToBase64String($pfxCert.GetRawCertData())

        $DeploymentScriptOutputs['certStart'] = $existingCert.notBefore
        $DeploymentScriptOutputs['certEnd'] = $existingCert.expires
        $DeploymentScriptOutputs['certThumbprint'] = $existingCert.Thumbprint
        $DeploymentScriptOutputs['certKey'] = $publicKey
        $DeploymentScriptOutputs | Out-String
      }
      else {
        $policy = New-AzKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 12 -Verbose
        # private key is added as a secret that can be retrieved in the ARM template
        Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose
        $newCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName
        # it takes a few seconds for KeyVault to finish
        $tries = 0
        do {
          Write-Host 'Waiting for certificate creation completion...'
          Start-Sleep -Seconds 10
          $operation = Get-AzKeyVaultCertificateOperation -VaultName $vaultName -Name $certificateName
          $tries++
          if ($operation.Status -eq 'failed')
          {
            throw 'Creating certificate $certificateName in vault $vaultName failed with error $($operation.ErrorMessage)'
          }
          if ($tries -gt 120)
          {
            throw 'Timed out waiting for creation of certificate $certificateName in vault $vaultName'
          }
        } while ($operation.Status -ne 'completed')

        $certValue = (Get-AzKeyVaultSecret -VaultName $vaultName -Name $certificateName).SecretValue | ConvertFrom-SecureString -AsPlainText
        $pfxCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @([Convert]::FromBase64String($certValue),"",[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        $publicKey = [System.Convert]::ToBase64String($pfxCert.GetRawCertData())

        $DeploymentScriptOutputs['certStart'] = $newCert.notBefore
        $DeploymentScriptOutputs['certEnd'] = $newCert.expires
        $DeploymentScriptOutputs['certThumbprint'] = $newCert.Thumbprint
        $DeploymentScriptOutputs['certKey'] = $publicKey
        $DeploymentScriptOutputs| Out-String
      }
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    kvMiRoleAssignment
  ]
}

resource app 'Microsoft.Graph/applications@v1.0' = {
  displayName: appName
  uniqueName: appName
  keyCredentials: [
    {
      displayName: 'Credential from KV'
      usage: 'Verify'
      type: 'AsymmetricX509Cert'
      key: createAddCertificate.properties.outputs.certKey
      startDateTime: createAddCertificate.properties.outputs.certStart
      endDateTime: createAddCertificate.properties.outputs.certEnd
    }
  ]
  resource myMsiFic 'federatedIdentityCredentials@v1.0' = {
    name: '${app.uniqueName}/msiAsFic'
    description: 'Trust the workloads UAMI to impersonate the App'
    audiences: [
       'api://AzureADTokenExchange'
    ]
    issuer: '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'
    subject: webIdentity.properties.principalId
  }
  identifierUris: [
    identifierUri
  ]
  web: {
    redirectUris: [
      'https://localhost:7109/signin-oidc'
      'https://bff-web-app.${caeDomainName}/signin-oidc'
      'https://bff-web-app.internal.${caeDomainName}/signin-oidc'
    ]
  }
  api: {
    requestedAccessTokenVersion: 2
    oauth2PermissionScopes: [
      {
        adminConsentDescription: 'Weather.Get'
        adminConsentDisplayName: 'Weather.Get'
        value: 'Weather.Get'
        type: 'User'
        isEnabled: true
        userConsentDescription: 'Weather.Get'
        userConsentDisplayName: 'Weather.Get'
        id: guid('Weather.Get')
      }
    ]
  }
}

// Create a service principal for the client app
resource clientSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: app.appId
}

output tenantId string        = tenant().tenantId
output clientId string        = app.appId
output uamiId string          = webIdentity.id
output identifierUri string   = identifierUri
output keyVaultUrl string     = vault.properties.vaultUri
output keyVaultSecret string  = certificateName
output certThumbprint string  = createAddCertificate.properties.outputs.certThumbprint
