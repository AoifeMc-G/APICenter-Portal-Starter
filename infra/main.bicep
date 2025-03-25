targetScope = 'subscription'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

@minLength(1)
@maxLength(64)
@description('Name of the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

// Limited to the following locations due to the availability of API Center
@minLength(1)
@description('Primary location for all resources')
@allowed([
  'australiaeast'
  'centralindia'
  'eastus'
  'uksouth'
  'westeurope'
])
@metadata({
  azd: {
    type: 'location'
  }
})
param location string

var supportedRegions = [
  'East US'
  'West Europe'
  'UK South'
  'Central India'
  'Australia East'
  'France Central'
  'Sweden Central'
  'Canada Central'
]

// Tagging for all resources
var tags = {
  'azd-env-name': environmentName
}

// Existing API Center Resource
resource apiCenterExisting 'Microsoft.ApiCenter/services@2024-03-01' existing = {
  name: apiCenterName
  scope: rgApiCenter
}

param resourceGroupName string = 'rsg-neu-rsv-cloudops'

@description('Value indicating whether to use existing API Center instance or not.')
param apiCenterExisted bool = true
@description('Name of the API Center. You can omit this value if `apiCenterExisted` value is set to `False`.')
param apiCenterName string = 'apiCenter-ki-api-dev-westeurope-001'

// Set API Center location the same location as the main location
var apiCenterRegion = location

@description('Name of the API Center resource group. You can omit this value if `apiCenterExisted` value is set to `False`.')
param apiCenterResourceGroupName string = 'rsg-neu-rsv-cloudops'

@description('Use monitoring and performance tracing')
param useMonitoring bool // Set in main.parameters.json

param logAnalyticsName string = ''
param applicationInsightsName string = ''
param applicationInsightsDashboardName string = ''

// Limited to the following locations due to the availability of Static Web Apps
@minLength(1)
@description('Location for Static Web Apps')
@allowed([
  'centralus'
  'eastasia'
  'eastus2'
  'westeurope'
  'westus2'
])
@metadata({
  azd: {
    type: 'location'
  }
})
param staticAppLocation string
param staticAppSkuName string = 'Free'

var abbrs = loadJsonContent('./abbreviations.json')

// Generate a unique token to be used in naming resources.
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Name of the service defined in azure.yaml
var azdServiceName = 'staticapp-portal'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource rgApiCenter 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: apiCenterResourceGroupName
}

// Provision API Center
module apiCenter './core/gateway/apicenter.bicep' = if (apiCenterExisted != true) {
  name: 'apicenter'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: apiCenterName
    location: apiCenterRegion
    tags: tags
  }
}

// Provision monitoring resource with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = if (useMonitoring == true) {
  name: 'monitoring'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

// Provision Static Web Apps for each application
module staticApp './core/host/staticwebapp.bicep' = {
  name: 'staticapp'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'webapp-dev-apicenter-portal'
    location: staticAppLocation
    tags: union(tags, { 'azd-service-name': azdServiceName })
    sku: {
      name: staticAppSkuName
      tier: staticAppSkuName
    }
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId

output USE_EXISTING_API_CENTER bool = apiCenterExisted
output AZURE_API_CENTER string = apiCenterExisted ? apiCenterExisting.name : apiCenter.outputs.name
output AZURE_API_CENTER_LOCATION string = apiCenterExisted ? apiCenterExisting.location : apiCenter.outputs.location
output AZURE_API_CENTER_RESOURCE_GROUP string = apiCenterExisted ? rgApiCenter.name : rg.name

output AZURE_STATIC_APP string = staticApp.outputs.name
output AZURE_STATIC_APP_URL string = staticApp.outputs.uri
output AZURE_STATIC_APP_LOCATION string = staticApp.outputs.location
