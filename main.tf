resource "azurerm_resource_group" "k8s" {
    name     = "k8s-resource-group"
    location = "West Europe"
}

resource "azurerm_virtual_network" "k8s_vnet" {
    name                = "k8s-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
}

resource "azurerm_subnet" "k8s_subnet" {
    name                 = "k8s-subnet"
    resource_group_name  = azurerm_resource_group.k8s.name
    virtual_network_name = azurerm_virtual_network.k8s_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "k8s_nsg" {
  name                = "k8s-nsg"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }
    security_rule {
    name                       = "allow-http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
  security_rule {
    name                       = "allow-https"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-internet-outbound"
    priority                   = 1004
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 security_rule {
   name                       = "allow-intra-subnet"
   priority                   = 1000
   direction                  = "Inbound"
   access                     = "Allow"
   protocol                   = "*"
   source_port_range          = "*"
   destination_port_range     = "*"
   source_address_prefix      = "10.0.1.0/24"           # <-- Replace with your subnet CIDR if different
   destination_address_prefix = "10.0.1.0/24"   
 }
 security_rule {
  name                       = "allow-all-outbound"
  priority                   = 1005
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}
}


resource "azurerm_network_interface" "master_nic" {
    name                = "master-nic"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name

    ip_configuration {
        name                          = "internal"
        subnet_id                    = azurerm_subnet.k8s_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.master.id
    }
}
resource "azurerm_network_interface_security_group_association" "master_nic_nsg" {
  network_interface_id      = azurerm_network_interface.master_nic.id
  network_security_group_id = azurerm_network_security_group.k8s_nsg.id
}


resource "azurerm_network_interface" "worker_nic_1" {
    name                = "worker-nic-1"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name

    ip_configuration {
        name                          = "internal"
        subnet_id                    = azurerm_subnet.k8s_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.worker1.id
    }
}
resource "azurerm_network_interface_security_group_association" "worker_nic_1_nsg" {
  network_interface_id      = azurerm_network_interface.worker_nic_1.id
  network_security_group_id = azurerm_network_security_group.k8s_nsg.id
}


resource "azurerm_network_interface" "worker_nic_2" {
    name                = "worker-nic-2"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name

    ip_configuration {
        name                          = "internal"
        subnet_id                    = azurerm_subnet.k8s_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.worker2.id
    }
}

resource "azurerm_network_interface_security_group_association" "worker_nic_2_nsg" {
  network_interface_id      = azurerm_network_interface.worker_nic_2.id
  network_security_group_id = azurerm_network_security_group.k8s_nsg.id
}

resource "azurerm_linux_virtual_machine" "master" {
    name                = "k8s-master"
    resource_group_name = azurerm_resource_group.k8s.name
    location            = azurerm_resource_group.k8s.location
    size                = var.master_vm_size
    admin_username      = var.admin_username
    disable_password_authentication = true
    network_interface_ids = [azurerm_network_interface.master_nic.id]
    admin_ssh_key {
      username   = var.admin_username
      public_key = file("/mnt/c/Users/Daeda/OneDrive/Desktop/Azure project/k8s-terraform/.ssh/azuresshkey.pub") # or path to your public key
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = var.image_publisher
        offer     = var.image_offer
        sku       = var.image_sku
        version   = "latest"
    }
}

resource "azurerm_linux_virtual_machine" "worker_1" {
    name                = "k8s-worker-1"
    resource_group_name = azurerm_resource_group.k8s.name
    location            = azurerm_resource_group.k8s.location
    size                = var.worker_vm_size
    admin_username      = var.admin_username
    disable_password_authentication = true
    network_interface_ids = [azurerm_network_interface.worker_nic_1.id]
    admin_ssh_key {
      username   = var.admin_username
      public_key = file("/mnt/c/Users/Daeda/OneDrive/Desktop/Azure project/k8s-terraform/.ssh/azuresshkey.pub")
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = var.image_publisher
        offer     = var.image_offer
        sku       = var.image_sku
        version   = "latest"
    }
}

resource "azurerm_linux_virtual_machine" "worker_2" {
    name                = "k8s-worker-2"
    resource_group_name = azurerm_resource_group.k8s.name
    location            = azurerm_resource_group.k8s.location
    size                = var.worker_vm_size
    admin_username      = var.admin_username
    disable_password_authentication = true
    network_interface_ids = [azurerm_network_interface.worker_nic_2.id]
    admin_ssh_key {
      username   = var.admin_username
      public_key = file("/mnt/c/Users/Daeda/OneDrive/Desktop/Azure project/k8s-terraform/.ssh/azuresshkey.pub") # or path to your public key
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = var.image_publisher
        offer     = var.image_offer
        sku       = var.image_sku
        version   = "latest"
    }
}
resource "azurerm_public_ip" "master" {
  name                = "master-public-ip"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "worker1" {
  name                = "worker1-public-ip"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "worker2" {
  name                = "worker2-public-ip"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  allocation_method   = "Static"
}
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    master_ip = azurerm_public_ip.master.ip_address
    worker1_ip = azurerm_public_ip.worker1.ip_address
    worker2_ip = azurerm_public_ip.worker2.ip_address
    ansible_user = var.admin_username
  })
  filename = "${path.module}/inventory.ini"
}

resource "null_resource" "ansible_provision" {
  depends_on = [
    azurerm_linux_virtual_machine.master,
    azurerm_linux_virtual_machine.worker_1,
    azurerm_linux_virtual_machine.worker_2,
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/inventory.ini ${path.module}/playbook.yml -vv"
  }
}
