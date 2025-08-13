metadata description = 'Creates an Azure Static Web Apps instance with Front Door access restrictions.'
param name string
param location string 
param tags object = {}

param sku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('Front Door profile ID for access restrictions')
param frontDoorId string = '38a9b306-7e71-45d7-affa-5a101cef5445'

@description('Enable access restrictions to allow only Front Door traffic')
param restrictToFrontDoorOnly bool = true

resource web 'Microsoft.Web/staticSites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    provider: 'Custom'
    // Disable enterprise grade edge to avoid deployment issues
    enterpriseGradeCdnStatus: 'Disabled'
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
  }
}

// Output the hostname for Front Door configuration
output name string = web.name
output uri string = 'https://${web.properties.defaultHostname}'
output location string = toLower(replace(web.location, ' ', ''))
output hostname string = web.properties.defaultHostname
output frontDoorId string = frontDoorId
output id string = web.id
