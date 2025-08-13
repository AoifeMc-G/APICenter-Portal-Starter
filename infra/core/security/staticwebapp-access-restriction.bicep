// This file is currently not used as access restrictions are handled via staticwebapp.config.json
// However, keeping this template for future infrastructure-level restrictions if needed

@description('Name of the Static Web App')
param staticWebAppName string

@description('Front Door profile ID for access restrictions')
param frontDoorId string

// Note: Azure Static Web Apps access restrictions are typically configured at the application level
// via staticwebapp.config.json rather than at the infrastructure level.
// This approach provides more granular control over routing and security headers.

// If you need infrastructure-level restrictions in the future, you can implement them here
// using Azure Private Endpoints or Virtual Network integration (Premium SKU required)

output restrictionConfigured bool = true
output message string = 'Access restrictions configured via staticwebapp.config.json'
