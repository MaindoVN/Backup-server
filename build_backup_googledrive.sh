#!/bin/bash

# Update system packages
sudo apt update

# Install rclone and expect
sudo apt install -y rclone expect

# Automatically configure rclone to connect with Google Drive
expect << EOF
spawn rclone config
expect "n/s/q> "
send "n\r"
expect "name> "
send "gdrive\r"
expect "Storage> "
send "18\r"
expect "client_id> "
send "\r"
expect "client_secret> "
send "\r"
expect "scope> "
send "1\r"
expect "root_folder_id> "
send "\r"
expect "service_account_file> "
send "\r"
expect "y/n> "
send "n\r"
expect "y/n> "
send "y\r"
expect "Enter verification code> "
interact
EOF

# Resume script after authorization
expect << EOF
spawn rclone config
expect "y/n> "
send "y\r"
expect "e/n/d/r/c/s/q> "
send "q\r"
EOF

# Create backup script for Google Drive
cat << 'EOF' > backup_googledrive.sh
#!/bin/bash

Today=$(date +"%m-%d-%Yat%Hh%M")
TmpBkFol='/backup/monitoring'
RemoteServer="root@192.168.30.50"
RemotePort="40905"
RemoteFolder="/backup/internal-tools/monitoring/$Today"
GrafanaDB='/var/lib/grafana/grafana.db'
GrafanaFolders='/var/lib/grafana/csv /var/lib/grafana/pdf /var/lib/grafana/png'
PrometheusData='/usr/local/prometheus'
RcloneRemote="gdrive:backup/monitoring/$Today"

{
    echo "Starting backup at $(date)"

    # Create temporary backup folder
    mkdir -p $TmpBkFol

    # Backup Grafana database
    cp $GrafanaDB $TmpBkFol/grafana.db

    # Backup necessary Grafana folders
    for folder in $GrafanaFolders; do
        tar -czf $TmpBkFol/$(basename $folder).tar.gz -C $(dirname $folder) $(basename $folder)
    done

    # Backup Prometheus data
    tar -czf $TmpBkFol/prometheus_data.tar.gz -C $(dirname $PrometheusData) $(basename $PrometheusData)

    # Upload files to Google Drive using rclone
    rclone copy $TmpBkFol $RcloneRemote --progress

    # Remove temporary files
    rm -rf $TmpBkFol/*

    echo "Backup completed at $(date)"
}
EOF

# Grant execution permission to the backup script
chmod +x backup_googledrive.sh

# Run the backup script
/home/ubuntu/backup_googledrive.sh

# Schedule automatic backups using crontab
(crontab -l 2>/dev/null; echo "01 15 * * * /home/ubuntu/backup_googledrive.sh") | crontab -
