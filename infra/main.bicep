param appName string
param environment string
param region string
param location string = resourceGroup().location
param apiManagementServicePublisherEmail string
param apiManagementServicePublisherName string

module names 'resource-names.bicep' = {
  name: 'resource-names'
  params: {
    appName: appName
    region: region
    env: environment
  }
}

module managedIdentityDeployment 'managed-identity.bicep' = {
  name: 'managed-identity-deployment'
  params: {
    location: location
    managedIdentityName: names.outputs.managedIdentityName
  }
}

module loggingDeployment 'logging.bicep' = {
  name: 'logging-deployment'
  params: {
    logAnalyticsWorkspaceName: names.outputs.logAnalyticsWorkspaceName
    location: location
    appInsightsName: names.outputs.appInsightsName
    functionAppName: names.outputs.functionAppName
  }
}

module storageDeployment 'storage.bicep' = {
  name: 'storage-deployment'
  params: {
    location: location
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    storageAccountName: names.outputs.storageAccountName
  }
}

module virtualNetworkDeployment 'virtual-network.bicep' = {
  name: 'virtual-network-deployment'
  params: {
    apimSubnetName: names.outputs.apimSubnetName
    applicationSubnetName: names.outputs.applicationSubnetName
    location: location
    privateEndpointSubnetName: names.outputs.privateEndpointSubnetName
    vNetName: names.outputs.vNetName
  }
}

module dnsZoneDeployment 'dns.bicep' = {
  name: 'dns-zone-deployment'
  params: {
    privateDnsZoneName: names.outputs.privateDnsZoneName
    vNetName: virtualNetworkDeployment.outputs.vNetName
  }
}

module functionDeployment 'function.bicep' = {
  name: 'function-deployment'
  params: {
    applicationSubnetName: virtualNetworkDeployment.outputs.applicationSubnetName
    appServicePlanName: names.outputs.appServicePlanName
    functionAppName: names.outputs.functionAppName
    functionAppNetworkInterfaceName: names.outputs.functionAppNetworkInterfaceName
    functionAppPrivateEndpointName: names.outputs.functionAppPrivateEndpointName
    location: location
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    privateEndpointSubnetName: virtualNetworkDeployment.outputs.privateEndpointSubnetName
    vNetName: virtualNetworkDeployment.outputs.vNetName
    privateDnsZoneName: dnsZoneDeployment.outputs.privateDnsZoneName
    storageAccountName: storageDeployment.outputs.storageAccountName
    appInsightsName: loggingDeployment.outputs.appInsightsName
  }
}

module apiManagementDeployment 'api-management.bicep' = {
  name: 'api-management-deployment'
  params: {
    apiManagementServiceName: names.outputs.apiManagementServiceName
    apiManagementServicePublisherEmail: apiManagementServicePublisherEmail
    apiManagementServicePublisherName: apiManagementServicePublisherName
    location: location
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
    apiManagementServiceApiEndpoint: names.outputs.apiManagementServiceApiEndpoint
    apiManagementServiceApiApplicationEndpoint: names.outputs.apiManagementServiceApiApplicationEndpoint
    appInsightsName: loggingDeployment.outputs.appInsightsName
  }
}

output apimServiceEndpoint string = apiManagementDeployment.outputs.apiManagementServiceEndpoint
output functionAppEndpoint string = '${functionDeployment.outputs.functionAppEndpoint}/${names.outputs.apiManagementServiceApiEndpoint}/${names.outputs.apiManagementServiceApiApplicationEndpoint}'
