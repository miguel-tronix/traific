resource "azurerm_resource_group" "traific" {
  name     = "traific-rg"
  location = var.azure_location
}

resource "azurerm_virtual_network" "traific" {
  name                = "traific-vnet"
  location            = azurerm_resource_group.traific.location
  resource_group_name = azurerm_resource_group.traific.name
  address_space       = [var.vpc_cidr]

  subnet {
    name           = "traific-subnet"
    address_prefixes = [cidrsubnet(var.vpc_cidr, 8, 1)]
  }
}

resource "azurerm_nat_gateway" "traific" {
  name                = "traific-nat"
  location            = azurerm_resource_group.traific.location
  resource_group_name = azurerm_resource_group.traific.name
}

resource "azurerm_subnet_nat_gateway_association" "traific" {
  subnet_id      = azurerm_virtual_network.traific.subnet[0].id
  nat_gateway_id = azurerm_nat_gateway.traific.id
}
