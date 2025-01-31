#!/bin/bash

# Define colors for printing
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'  # No Color

# Define emojis
LOGO_EMOJI='🐍'
POP_EMOJI='🚀'
CHECK_EMOJI='✅'
CROSS_EMOJI='❌'
INFO_EMOJI='ℹ️'
FOLDER_EMOJI='📂'
DOWNLOAD_EMOJI='⬇️'
WRENCH_EMOJI='🔧'
MONEY_EMOJI='💸'

# Error handling function
handle_error() {
    echo -e "${RED}${CROSS_EMOJI} Error: $1 ${NC}"
    exit 1
}

# Display logo directly from URL
echo -e "${CYAN}${LOGO_EMOJI} ${MAGENTA}Displaying logo... ${NC}"
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash

# Stop and disable dcdnd service
echo -e "${YELLOW}${INFO_EMOJI} ${RED}Stopping and disabling dcdnd service... ${NC}"
sudo systemctl stop dcdnd || handle_error "Failed to stop dcdnd service"
sudo systemctl disable dcdnd || handle_error "Failed to disable dcdnd service"

# Create necessary directories
echo -e "${GREEN}${FOLDER_EMOJI} ${CYAN}Creating directories... ${NC}"
mkdir -p $HOME/pipenetwork-devnet2 || handle_error "Failed to create directory $HOME/pipenetwork-devnet2"
mkdir -p $HOME/pipenetwork-devnet2/download_cache || handle_error "Failed to create download_cache directory"
cd $HOME/pipenetwork-devnet2 || handle_error "Failed to change to $HOME/pipenetwork-devnet2 directory"

# Prompt user to input POP node download URL (HTTPS)
echo -e "${YELLOW}${INFO_EMOJI} ${CYAN}Enter the URL to download the POP node (HTTPS): ${NC}"
read -p "Download URL: " pop_node_url
echo -e "${CYAN}${DOWNLOAD_EMOJI} ${GREEN}Downloading POP node from $pop_node_url... ${NC}"
wget -q $pop_node_url -O pop || handle_error "Failed to download POP node from $pop_node_url"

# Give execute permissions to the downloaded node
chmod +x pop || handle_error "Failed to give execute permissions to pop node"

echo -e "${GREEN}${CHECK_EMOJI} ${CYAN}Permissions granted to the node. ${NC}"

# Prompt user for RAM and storage configuration
echo -e "${YELLOW}${INFO_EMOJI} ${CYAN}Configuring node resources... ${NC}"
read -p "Enter the amount of RAM to allocate (minimum 4GB): " ram_size
while [ "$ram_size" -lt 4 ]; do
    echo -e "${RED}${CROSS_EMOJI} ${MAGENTA}The minimum RAM size is 4GB. Please enter a valid amount. ${NC}"
    read -p "Enter the amount of RAM to allocate (minimum 4GB): " ram_size
done

read -p "Enter the amount of storage to allocate (minimum 100GB): " storage_size
while [ "$storage_size" -lt 100 ]; do
    echo -e "${RED}${CROSS_EMOJI} ${MAGENTA}The minimum storage size is 100GB. Please enter a valid amount. ${NC}"
    read -p "Enter the amount of storage to allocate (minimum 100GB): " storage_size
done

# Prompt user for their Solana public key (wallet address)
echo -e "${YELLOW}${INFO_EMOJI} ${CYAN}Enter your Solana wallet address (public key): ${NC}"
read -p "Public Key: " pub_key

# Create systemd service for the node
echo -e "${MAGENTA}${WRENCH_EMOJI} ${CYAN}Creating systemd service for the node... ${NC}"
cat << EOF | sudo tee /etc/systemd/system/pipe.service > /dev/null
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/pipenetwork-devnet2
ExecStart=$HOME/pipenetwork-devnet2/pop \
    --ram $ram_size \
    --max-disk $storage_size \
    --cache-dir $HOME/pipenetwork-devnet2/download_cache \
    --pubKey $pub_key
    --signup-by-referral-route 981e34d40a3b66fb
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node

[Install]
WantedBy=multi-user.target
EOF

# Check if the service file was created
if [ $? -ne 0 ]; then
    handle_error "Failed to create systemd service file"
fi

# Reload systemd, enable, and start the service
echo -e "${GREEN}${CHECK_EMOJI} ${CYAN}Reloading systemd and starting the service... ${NC}"
sudo systemctl daemon-reload || handle_error "Failed to reload systemd"
sudo systemctl enable pipe || handle_error "Failed to enable the pipe service"
sudo systemctl start pipe || handle_error "Failed to start the pipe service"

# Prompt user to check logs
echo -e "${YELLOW}${INFO_EMOJI} ${CYAN}To check the node logs in real-time, use the following command: ${NC}"
echo -e "${CYAN}journalctl -u pipe -fo cat ${NC}"
