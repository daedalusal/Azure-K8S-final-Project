output "master_ip" {
    value = azurerm_linux_virtual_machine.master.public_ip_address
}

output "worker_ips" {
    value = [
        azurerm_linux_virtual_machine.worker_1.public_ip_address,
        azurerm_linux_virtual_machine.worker_2.public_ip_address,
    ]
}