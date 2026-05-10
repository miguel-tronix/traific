resource "azurerm_kubernetes_cluster" "traific" {
  name                = var.cluster_name
  location            = azurerm_resource_group.traific.location
  resource_group_name = azurerm_resource_group.traific.name
  dns_prefix          = "traific"
  sku_tier            = "Free"

  kubernetes_version = "1.29"

  default_node_pool {
    name                = "stateless"
    node_count          = 2
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 8
    os_disk_size_gb     = 30

    labels = {
      "workload-type" = "stateless"
    }
  }

  node_pool {
    name                = "redis"
    node_count          = 1
    vm_size             = "Standard_B2s"
    os_disk_size_gb     = 30

    labels = {
      "workload-type" = "stateful"
      "component"      = "redis"
    }

    taints = [{
      key    = "workload"
      value  = "redis"
      effect = "NoSchedule"
    }]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  azure_policy_enabled = true
}

data "azurerm_kubernetes_cluster" "traific" {
  name                = azurerm_kubernetes_cluster.traific.name
  resource_group_name = azurerm_resource_group.traific.name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.traific.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.traific.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.traific.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.traific.kube_config.0.cluster_ca_certificate)
}
