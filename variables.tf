variable "location" {
  description = "The Azure region to deploy the resources."
  default     = "West Europe"
}
# Ubuntu Image Configuration
# Using Ubuntu 22.04 LTS as it's widely available across all Azure regions
# Alternative options:
# For Ubuntu 24.04 LTS: offer = "ubuntu-24_04-lts", sku = "minimal-24_04-lts-gen2"
# For Ubuntu 20.04 LTS: offer = "0001-com-ubuntu-server-focal", sku = "20_04-lts-gen2"

variable "image_publisher" {
  description = "The publisher of the Azure VM image."
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "The offer of the Azure VM image."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "The SKU of the Azure VM image."
  type        = string
  default     = "22_04-lts-gen2"
}

variable "master_vm_size" {
  description = "The size of the master virtual machine."
  default     = "Standard_B2s"
}

variable "worker_vm_size" {
  description = "The size of the worker virtual machines."
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "The admin username for the virtual machines."
  default     = "azureuser"
}
