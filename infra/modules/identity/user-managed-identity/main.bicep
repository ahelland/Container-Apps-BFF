metadata name = 'User Managed Identity'
metadata description = 'User Managed Identity'
metadata owner = 'ahelland'

@description('Location')
param location string
@description('Tags retrieved from parameter file.')
param resourceTags object = {}
@description('Name of managed identity.')
param miname string

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: miname
  location: location
  tags: resourceTags
}

@description('Principal of the managed identity.')
output managedIdentityPrincipal string = userManagedIdentity.properties.principalId
@description('ObjectId of the managed identity.')
output id string = userManagedIdentity.id
