terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.56.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


### Group ###

resource "azurerm_resource_group" "default" {
  name     = "rg${var.app}"
  location = var.location
}


### Network ###

resource "azurerm_virtual_network" "default" {
  name                = "vnet${var.app}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "default" {
  name                 = "subnet-default"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.1.0/24"]
}


### Storage Account ###

resource "azurerm_storage_account" "default" {
  name                     = "stdevupd789"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


### IoT Hub ###

resource "azurerm_iothub" "default" {
  name                = "iot${var.app}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  min_tls_version     = "1.2"

  sku {
    name     = "S1"
    capacity = "1"
  }
}


### Device Update ###

resource "azurerm_iothub_device_update_account" "default" {
  name                = "du${var.app}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_iothub_device_update_instance" "default" {
  name                     = "default"
  device_update_account_id = azurerm_iothub_device_update_account.default.id
  iothub_id                = azurerm_iothub.default.id
  diagnostic_enabled       = true

  diagnostic_storage_account {
    connection_string = azurerm_storage_account.default.primary_connection_string
    id                = azurerm_storage_account.default.id
  }
}


### Simulator ###

resource "azurerm_public_ip" "simulator" {
  name                = "pip${var.app}simulator"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "simulator" {
  name                = "nic${var.app}simulator"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "dns"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.simulator.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "simulator" {
  name                  = "vm${var.app}simulator"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  size                  = var.vm_simulator_size
  admin_username        = "simulator"
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.simulator.id]

  custom_data = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "simulator"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}
