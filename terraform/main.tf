# Azure Public IP for Load Balancer
resource "azurerm_public_ip" "lb" {
  name                = "k8s-lb-public-ip"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Load Balancer
resource "azurerm_lb" "k8s_lb" {
  name                = "k8s-lb"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

# Backend address pool for all K8s nodes
resource "azurerm_lb_backend_address_pool" "k8s_pool" {
  loadbalancer_id = azurerm_lb.k8s_lb.id
  name            = "k8s-backend-pool"
}

# Health probe for HTTP
resource "azurerm_lb_probe" "http" {
  loadbalancer_id     = azurerm_lb.k8s_lb.id
  name                = "http-probe"
  protocol            = "Tcp"
  port                = 30080
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Health probe for HTTPS
resource "azurerm_lb_probe" "https" {
  loadbalancer_id     = azurerm_lb.k8s_lb.id
  name                = "https-probe"
  protocol            = "Tcp"
  port                = 30443
  interval_in_seconds = 5
  number_of_probes    = 2
}

# LB rule for HTTP (80 -> 30080)

# LB rule for HTTP (80 -> 30080)
resource "azurerm_lb_rule" "http" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.k8s_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 30080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.k8s_pool.id]
  probe_id                       = azurerm_lb_probe.http.id
}

# LB rule for HTTPS (443 -> 30443)
resource "azurerm_lb_rule" "https" {
  name                           = "https"
  loadbalancer_id                = azurerm_lb.k8s_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 30443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.k8s_pool.id]
  probe_id                       = azurerm_lb_probe.https.id
}

# Associate all VM NICs with the backend pool

resource "azurerm_network_interface_backend_address_pool_association" "master" {
  network_interface_id    = azurerm_network_interface.master_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.k8s_pool.id
}
resource "azurerm_network_interface_backend_address_pool_association" "worker1" {
  network_interface_id    = azurerm_network_interface.worker_nic_1.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.k8s_pool.id
}
resource "azurerm_network_interface_backend_address_pool_association" "worker2" {
  network_interface_id    = azurerm_network_interface.worker_nic_2.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.k8s_pool.id
}

# Output the public IP for use in Ansible or DNS
output "k8s_lb_public_ip" {
  value = azurerm_public_ip.lb.ip_address
  description = "Public IP address of the Azure Load Balancer for K8s ingress."
}
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

  security_rule {
    name                       = "allow-jenkins"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-kubernetes-nodeports"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
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
  content = templatefile("${path.module}/../ansible/inventory.tpl", {
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
    command = "ansible-playbook -i ${path.module}/inventory.ini ${path.module}/../ansible/playbook.yml -vvv"
  }
}
