metadata description = 'Creates an Azure API Center instance.'
param name string
param location string
param tags object


// Create an API center service
resource apiCenter 'Microsoft.ApiCenter/services@2024-03-15-preview' = {
  name: name
  location: location
  tags: tags
  // sku property removed as it is not supported by this resource type
  identity: {
    type: 'SystemAssigned'
  }
}

output name string = apiCenter.name
output id string = apiCenter.id
output location string = apiCenter.location
output identityPrincipalId string = apiCenter.identity.principalId
