metadata description = 'Configures access restrictions for Static Web App to accept traffic only from Front Door.'

param staticWebAppName string
param frontDoorId string

@description('Custom domain name for the Static Web App (if using custom domain approach)')
param customDomainName string = ''

// Reference to existing Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' existing = {
  name: staticWebAppName
}

// Custom domain configuration (recommended approach for access restrictions)
resource customDomain 'Microsoft.Web/staticSites/customDomains@2022-03-01' = if (!empty(customDomainName)) {
  name: customDomainName
  parent: staticWebApp
  properties: {}
}

// Function to create staticwebapp.config.json content for client-side validation
output staticWebAppConfigJson object = {
  routes: [
    {
      route: '/*'
      headers: {
        'X-Frame-Options': 'DENY'
        'X-Content-Type-Options': 'nosniff'
        'X-XSS-Protection': '1; mode=block'
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains'
        'Content-Security-Policy': 'default-src \'self\'; style-src \'self\' \'unsafe-inline\'; script-src \'self\''
      }
    }
  ]
  // Note: For true access restriction, you need to implement validation in your app
  // or use Standard+ SKU with custom domain + Front Door only setup
  responseOverrides: {
    '401': {
      rewrite: '/unauthorized.html'
    }
    '403': {
      rewrite: '/forbidden.html'
    }
  }
}

output instructions string = '''
To properly restrict your Static Web App to Front Door only, you have several options:

1. **Upgrade to Standard+ SKU (Recommended)**:
   - Change your SKU from 'Free' to 'Standard' or higher
   - Use enterprise-grade CDN with built-in access restrictions
   - Configure custom domain through Front Door

2. **Application-level validation (For Free tier)**:
   - Implement validation of the X-Azure-FDID header in your application
   - The X-Azure-FDID header contains the Front Door ID: ${frontDoorId}
   - Block requests that don't have the correct Front Door ID

3. **Custom domain with Front Door only**:
   - Set up a custom domain
   - Configure it only in Front Door, not directly in Static Web App
   - Users can only access via the Front Door custom domain

4. **Network Security Groups (if using VNet integration)**:
   - Only available with Standard+ SKU
   - Configure NSG rules to allow traffic from Front Door IP ranges only
'''
