param appName string
param region string
param env string

output appInsightsName string = 'ai-${appName}-${region}-${env}'
output logAnalyticsWorkspaceName string = 'la-${appName}-${region}-${env}'
output storageAccountName string = toLower('sa${appName}${region}${env}')
output apiManagementServiceName string = 'apim-${appName}-${region}-${env}'
output applicationSubnetName string = 'application'
output privateEndpointSubnetName string = 'privateEndpoints'
output apiManagementServiceSubnetName string = 'apim'
output vNetName string = 'vnet-${appName}-${region}-${env}'
output functionAppName string = 'func-${appName}-${region}-${env}'
output appServicePlanName string = 'asp-${appName}-${region}-${env}'
output privateDnsZoneName string = 'privatelink.azurewebsites.net'
output functionAppNetworkInterfaceName string = 'nic-${appName}-${region}-${env}'
output functionAppPrivateEndpointName string = 'pe-${appName}-${region}-${env}'
output apiManagementServicePublicIpAddressName string = 'ip-${appName}-${region}-${env}'
output managedIdentityName string = 'mi-${appName}-${region}-${env}'
output apiManagementServiceApiEndpoint string = 'api'
output apiManagementServiceApiApplicationEndpoint string = 'application'
output apiManagementServiceNetworkSecurityGroupName string = 'nsg-apim-${appName}-${region}-${env}'
