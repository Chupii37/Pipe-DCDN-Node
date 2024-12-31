#!/bin/bash

# Fungsi untuk menampilkan pesan dengan warna
function info {
    echo -e "\033[34m$1\033[0m"
}

function success {
    echo -e "\033[32m$1\033[0m"
}

function warning {
    echo -e "\033[33m$1\033[0m"
}

function error {
    echo -e "\033[31m$1\033[0m"
}

# Mengecek pembaruan sistem
info "Memeriksa pembaruan sistem..."
sudo apt update -y && sudo apt upgrade -y
success "Pembaruan selesai."

# Memastikan systemctl terinstal
info "Memeriksa apakah systemctl terinstal..."
if ! command -v systemctl &> /dev/null
then
    error "systemctl tidak ditemukan. Menginstal systemd..."
    sudo apt install -y systemd
    success "systemd berhasil diinstal."
else
    success "systemctl sudah terinstal."
fi

# Menampilkan pesan setelah logo
success "Showing Aniani!!!"

# Menampilkan logo tanpa menyimpan file, langsung dari URL
info "Menampilkan logo..."
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash

# Meminta input dari pengguna untuk PIPE-URL dan DCDND-URL
info "Masukkan PIPE-URL dan DCDND-URL untuk melanjutkan..."
echo -n "Masukkan PIPE-URL: "
read PIPE_URL
echo -n "Masukkan DCDND-URL: "
read DCDND_URL

# Membuat folder /opt/dcdn jika belum ada
info "Membuat folder /opt/dcdn..."
sudo mkdir -p /opt/dcdn

# Mengunduh file dari URL yang diberikan oleh pengguna
info "Mengunduh pipe-tool dari $PIPE_URL..."
sudo curl -L "$PIPE_URL" -o /opt/dcdn/pipe-tool

info "Mengunduh dcdnd dari $DCDND_URL..."
sudo curl -L "$DCDND_URL" -o /opt/dcdn/dcdnd

# Memberikan izin eksekusi pada file yang diunduh
info "Memberikan izin eksekusi pada file..."
sudo chmod +x /opt/dcdn/pipe-tool
sudo chmod +x /opt/dcdn/dcdnd

# Log in to generate access token
info "Melakukan login untuk menghasilkan access token..."
/opt/dcdn/pipe-tool login --node-registry-url="https://rpc.pipedev.network"
success "Login berhasil!"

# Generate Registration Token
info "Menghasilkan registration token..."
/opt/dcdn/pipe-tool generate-registration-token --node-registry-url="https://rpc.pipedev.network"
success "Registration token berhasil dihasilkan!"

# Setup the dcdnd node systemd service
info "Menyiapkan layanan dcdnd dengan systemd..."

# Membuat file service dcdnd
sudo tee /etc/systemd/system/dcdnd.service << 'EOF'
[Unit]
Description=DCDN Node Service
After=network.target
Wants=network-online.target

[Service]
# Path to the executable and its arguments
ExecStart=/opt/dcdn/dcdnd \
                --grpc-server-url=0.0.0.0:8002 \
                --http-server-url=0.0.0.0:8003 \
                --node-registry-url="https://rpc.pipedev.network" \
                --cache-max-capacity-mb=1024 \
                --credentials-dir=/root/.permissionless \
                --allow-origin=*

# Restart policy
Restart=always
RestartSec=5

# Resource and file descriptor limits
LimitNOFILE=65536
LimitNPROC=4096

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node

# Working directory
WorkingDirectory=/opt/dcdn

[Install]
WantedBy=multi-user.target
EOF

# Menyeting firewall untuk mengizinkan koneksi ke port yang digunakan
info "Mengatur firewall untuk mengizinkan port 8002 dan 8003..."
sudo ufw allow 8002/tcp
sudo ufw allow 8003/tcp
sudo ufw reload

# Reload systemd dan enable serta mulai service dcdnd
info "Memuat ulang systemd dan memulai layanan dcdnd..."
sudo systemctl daemon-reload
sudo systemctl enable dcdnd
sudo systemctl start dcdnd

# Memberikan jeda agar systemd selesai dimulai
success "Layanan dcdnd berhasil dijalankan. Menunggu beberapa detik..."
sleep 5

# Generate dan Register Wallet
info "Menghasilkan wallet baru..."
/opt/dcdn/pipe-tool generate-wallet --node-registry-url="https://rpc.pipedev.network"

info "Mendaftarkan wallet..."
/opt/dcdn/pipe-tool link-wallet --node-registry-url="https://rpc.pipedev.network"
success "Wallet berhasil didaftarkan!"

success "Proses selesai. Semua langkah telah berhasil dilaksanakan."
