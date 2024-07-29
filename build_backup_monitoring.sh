#!/bin/bash

# Hỏi người dùng nhập địa chỉ IP của máy muốn SSH
read -p "Nhập địa chỉ IP của máy Backup Server: " backup_ip

# Tạo key cho ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Cài đặt sshpass nếu chưa có
if ! command -v sshpass &> /dev/null
then
    echo "sshpass chưa được cài đặt. Đang cài đặt sshpass..."
    apt-get update && apt-get install -y sshpass
fi

# Copy key đến máy Backup Server bằng sshpass
sshpass -p "123456" ssh-copy-id -p 40905 root@$backup_ip

# Tạo file backup_grafana_prometheus.sh với nội dung sau
cat <<EOL > backup_grafana_prometheus.sh
#!/bin/bash

Today=\$(date +"%m-%d-%Yat%Hh%M")
TmpBkFol='/backup/monitoring'
RemoteServer="root@$backup_ip"
RemotePort="40905"
RemoteFolder="/backup/internal-tools/monitoring/\$Today"
GrafanaDB='/var/lib/grafana/grafana.db'
GrafanaFolders='/var/lib/grafana/csv /var/lib/grafana/pdf /var/lib/grafana/png'
PrometheusData='/usr/local/prometheus'

{
echo "Starting backup at \$(date)"

# Tạo thư mục tạm thời và trên máy chủ từ xa
mkdir -p \$TmpBkFol
ssh -p \$RemotePort \$RemoteServer "mkdir -p \$RemoteFolder"

# Sao lưu cơ sở dữ liệu Grafana
cp \$GrafanaDB \$TmpBkFol/grafana.db

# Sao lưu các thư mục cần thiết của Grafana
for folder in \$GrafanaFolders; do
    tar -czf \$TmpBkFol/\$(basename \$folder).tar.gz -C \$(dirname \$folder) \$(basename \$folder)
done

# Sao lưu dữ liệu Prometheus
tar -czf \$TmpBkFol/prometheus_data.tar.gz -C \$(dirname \$PrometheusData) \$(basename \$PrometheusData)

# Truyền tệp lên máy chủ từ xa
rsync -avzhP -e "ssh -p \$RemotePort" \$TmpBkFol/ \$RemoteServer:\$RemoteFolder

# Xóa tệp tạm thời
rm -rf \$TmpBkFol/*

echo "Backup completed at \$(date)"
}
EOL

# Cấp quyền thực thi cho script
chmod +x backup_grafana_prometheus.sh

# Tạo lịch backup tự động
(crontab -l ; echo "28 13 * * * /home/ubuntu/backup_grafana_prometheus.sh") | crontab -

# Chạy backup test
/home/ubuntu/backup_grafana_prometheus.sh
