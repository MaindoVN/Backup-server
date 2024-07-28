#!/bin/bash

# Cập nhật danh sách gói
sudo apt update

# Cài đặt OpenSSH Server
sudo apt install -y openssh-server

# Thiết lập mật khẩu cho root
echo "root:123456" | sudo chpasswd

# Chỉnh sửa file sshd_config để cho phép đăng nhập root và thay đổi port
sudo sed -i '/^#PermitRootLogin /d' /etc/ssh/sshd_config
sudo sed -i '/^PermitRootLogin /d' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' | sudo tee -a /etc/ssh/sshd_config

sudo sed -i '/^#Port /d' /etc/ssh/sshd_config
sudo sed -i '/^Port /d' /etc/ssh/sshd_config
echo 'Port 40905' | sudo tee -a /etc/ssh/sshd_config

# Khởi động lại dịch vụ SSH
sudo systemctl restart ssh

echo "SSH server has been configured. Root login is enabled and port has been changed to 40905."
