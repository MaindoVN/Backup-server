Hướng dẫn dùng các file trên để tự động backup dữ liệu của máy Monitor Grafana và Prometheus.

Hệ điều hành áp dụng: **Ubuntu Server**.

I) Nếu bạn muốn backup dữ liệu lên một server khác bạn cần thực hiện các bước sau:
  1) Tải file **setup_ssh.sh** cho máy server cần backup dữ liệu vào.
  2) Chạy file **setup_ssh.sh**.
  3) Tải file **build_backup_monitoring.sh** trên máy Monitor Server.
  4) Chạy file **build_backup_monitoring.sh**.

II) Nếu bạn muốn backup dữ liệu lên Google Drive.
  1) Tải file **build_backup_googledrive.sh** trên máy Monitor Server.
  2) Chạy file **build_backup_googledrive.sh**.
