param privateDnsZoneName string
param vNetName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource vNetRegion 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vNetName
}

resource privateDnsZoneLinkRegion1 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZone.name}/${privateDnsZoneName}-${vNetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNetRegion.id
    }
  }
}

output privateDnsZoneName string = privateDnsZone.name
