param apiManagementServiceName string
param location string
param apiManagementServicePublisherName string
param apiManagementServicePublisherEmail string
param logAnalyticsWorkspaceName string
param managedIdentityName string
param apiManagementServiceApiEndpoint string
param apiManagementServiceApiApplicationEndpoint string
param appInsightsName string
param apiManagementServicePublicIpAddressName string
param vNetName string
param apiManagementServiceSubnetName string
param functionAppName string
param tenantId string
param functionAppAADAudience string

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentityName
}

resource apiManagementServiceSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: '${vNetName}/${apiManagementServiceSubnetName}'
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionAppName
}

resource apiManagementServicePublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: apiManagementServicePublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower(apiManagementServiceName)
    }
  }
}

var apiProductName = 'appProduct'
var apiSubscriptionName = 'appSubscription'
var apiPolicyName = 'policy'
var apiName = 'appApi'

resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apiManagementServiceName
  location: location
  sku: {
    capacity: 1
    name: 'Developer'
  }
  properties: {
    publisherEmail: apiManagementServicePublisherEmail
    publisherName: apiManagementServicePublisherName
    virtualNetworkType: 'External'
    publicIpAddressId: apiManagementServicePublicIpAddress.id
    virtualNetworkConfiguration: {
      subnetResourceId: apiManagementServiceSubnet.id
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }

  resource logger 'loggers@2021-08-01' = {
    name: appInsightsName
    properties: {
      loggerType: 'applicationInsights'
      credentials: {
        instrumentationKey: appInsights.properties.InstrumentationKey
      }
    }
  }

  resource api 'apis@2021-08-01' = {
    name: apiName
    properties: {
      displayName: 'App Api'
      apiRevision: '1.0.0.0'
      subscriptionRequired: false
      protocols: [
        'https'
      ]
      path: apiManagementServiceApiEndpoint
      serviceUrl: 'https://${functionApp.properties.defaultHostName}/api'
      isCurrent: true
    }
    resource apiOperation 'operations@2021-08-01' = {
      name: 'get-api-data'
      properties: {
        displayName: 'Get API data'
        method: 'GET'
        urlTemplate: '/api'
        templateParameters: []
        description: 'Get API data'
        responses: []
      }
      resource policy 'policies@2021-08-01' = {
        name: apiPolicyName
        properties: {
          format: 'rawxml'
          value: '<policies><inbound><validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Access token is missing or invalid."><openid-config url="https://login.microsoftonline.com/${tenantId}/.well-known/openid-configuration" /><audiences><audience>${functionAppAADAudience}</audience></audiences></validate-jwt><set-variable name="key" value="@(context.Request.Url.Query["key"].First())" /><set-variable name="secret" value="@(context.Request.Url.Query["secret"].First())" /><set-variable name="client" value="@(context.Request.Url.Query["client"].First())" /><set-variable name="duration" value="@(context.Request.Url.Query["duration"].First())" /><send-request mode="new" response-variable-name="accessToken" timeout="20" ignore-error="true"><set-url>@($"https://${functionAppName}.azurewebsites.net/api/token?key={context.Variables["key"]}&secret={context.Variables["secret"]}&client={context.Variables["client"]}&duration={context.Variables["duration"]}")</set-url><set-method>POST</set-method></send-request><set-header name="Authorization" exists-action="override"><value>@($"Bearer {((IResponse)context.Variables["accessToken"]).Body.As<JObject>(preserveContent: true)["Data"]["Token"]}")</value></set-header><set-query-parameter name="key" exists-action="delete" /><set-query-parameter name="secret" exists-action="delete" /><set-query-parameter name="client" exists-action="override"><value>@((string)(context.Variables["client"]))</value></set-query-parameter><set-query-parameter name="duration" exists-action="override"><value>@((string)(context.Variables["duration"]))</value></set-query-parameter><base /></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>'
        }
      }
    }
    resource logging 'diagnostics@2021-08-01' = {
      name: 'applicationinsights'
      properties: {
        loggerId: '/loggers/${logger.name}'
        alwaysLog: 'allErrors'
        sampling: {
          percentage: 100
          samplingType: 'fixed'
        }
        frontend: {
          request: {
            headers: []
            body: {}
          }
          response: {
            headers: []
            body: {}
          }
        }
        backend: {
          request: {
            headers: []
            body: {}
          }
          response: {
            headers: []
            body: {}
          }
        }
        httpCorrelationProtocol: 'W3C'
        operationNameFormat: 'Name'
        logClientIp: true
        verbosity: 'information'
      }
    }
  }

  resource product 'products@2021-08-01' = {
    name: apiProductName
    properties: {
      displayName: 'App Product'
      subscriptionRequired: true
      approvalRequired: false
      state: 'published'
      description: 'App Product Description'
      subscriptionsLimit: 1
    }
    resource api 'apis@2021-08-01' = {
      name: apiName
    }
  }

  resource subscription 'subscriptions@2021-08-01' = {
    name: apiSubscriptionName
    properties: {
      scope: resourceId('Microsoft.ApiManagement/service/products', apiManagementServiceName, product.name)
      displayName: 'App Subscription'
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: apiManagementService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'GatewayLogs'
        enabled: true
      }
      {
        category: 'WebSocketConnectionLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output apiManagementServiceName string = apiManagementService.name
output apiManagementServiceEndpoint string = '${apiManagementService.properties.gatewayUrl}/${apiManagementServiceApiEndpoint}/${apiManagementServiceApiApplicationEndpoint}'
