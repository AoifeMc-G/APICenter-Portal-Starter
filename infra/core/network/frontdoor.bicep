metadata description = 'Creates an Azure Front Door (Standard/Premium) with Static Web App as origin.'

param name string
param location string = 'Global'
param tags object = {}
param skuName string = 'Standard_AzureFrontDoor'

@description('The hostname of the Static Web App origin')
param staticWebAppHostname string

@description('Name of the Static Web App for origin group naming')
param staticWebAppName string

resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {}
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: 'og-${staticWebAppName}'
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: 'origin-${staticWebAppName}'
  parent: originGroup
  properties: {
    hostName: staticWebAppHostname
    httpPort: 80
    httpsPort: 443
    originHostHeader: staticWebAppHostname
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: 'ep-${staticWebAppName}'
  parent: frontDoorProfile
  location: location
  properties: {
    enabledState: 'Enabled'
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: 'route-${staticWebAppName}'
  parent: endpoint
  dependsOn: [
    origin // This explicit dependency is required to ensure that the origin is created before the route
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

// Security Policy to restrict access - this is automatically configured by Front Door
resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = if (skuName == 'Premium_AzureFrontDoor') {
  name: 'SecurityPolicy-${staticWebAppName}'
  parent: frontDoorProfile
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: endpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

// WAF Policy (only for Premium SKU)
resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = if (skuName == 'Premium_AzureFrontDoor') {
  name: 'waf${replace(name, '-', '')}'
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
  }
}

output frontDoorProfileName string = frontDoorProfile.name
output frontDoorProfileId string = frontDoorProfile.id
output endpointHostName string = endpoint.properties.hostName
output frontDoorId string = frontDoorProfile.properties.frontDoorId
