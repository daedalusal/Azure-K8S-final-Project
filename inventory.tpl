[master]
${master_ip} ansible_user=${ansible_user} ansible_ssh_private_key_file=~/.ssh/azuresshkey ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[workers]
${worker1_ip} ansible_user=${ansible_user} ansible_ssh_private_key_file=~/.ssh/azuresshkey ansible_ssh_common_args='-o StrictHostKeyChecking=no'
${worker2_ip} ansible_user=${ansible_user} ansible_ssh_private_key_file=~/.ssh/azuresshkey ansible_ssh_common_args='-o StrictHostKeyChecking=no'