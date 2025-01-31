# Get Started with DevNet 2
Setting up your PoP Node is quick and easy!

## System Requirements:

* Linux

* 4GB+ RAM (configurable, more is better for higher rewards)

* 100GB+ disk space (200–500GB recommended)

* 24/7 internet connectivity

## Installation
Before starting make sure you have gotten an email from the pipe network!!

Run Node
   ```bash
   wget https://raw.githubusercontent.com/Chupii37/Pipe-DCDN-Node/refs/heads/main/PipeNetwork-Devnet2/pipedevnet2.sh && chmod +x pipedevnet2.sh && ./pipedevnet2.sh
   ```

Inside the script will ask for the download url, and public key (solana address)

Copy the download url received in your email 

## Useful Commands
You must already be in the directory where pop is located
   ```bash
   cd $HOME/pipenetwork-devnet2
   ```

* View metrics
   ```bash
   ./pop --status
   ```

* Check points
   ```bash
   ./pop --points-route
   ```

If error: unexpected argument '--points-route' found, u can use this command
   ```bash
   ./pop --points
   ```

If there is an updated version
   ```bash
   mv pop pop.old 
   ```

   ```bash
   wget -q $latest_pop_url -O pop
   ```

Replace $latest_pop_url with the actual URL where the new version is hosted

   ```bash
   chmod +x pop
   ```

   ```bash
   cd
   ```

   ```bash
   sudo systemctl restart pipe
   ```

Check Logs
   ```bash
   journalctl -u pipe -fo cat
   ```

## After End of Project 
* Stop the service immediately
   ```bash
   sudo systemctl stop pipe
   ```

* Disable the service from starting automatically at boot
   ```bash
   sudo systemctl disable pipe
   ```

* Remove the service file
   ```bash
   sudo rm /etc/systemd/system/pipe.service
   ```

* Reload systemd to remove the service from the list of known services
   ```bash
   sudo systemctl daemon-reload
   ```

## Want to See More Cool Projects?

Buy me a coffee so I can stay awake and make more cool stuff (and less bugs)! I’ll be forever grateful and a little bit jittery. 😆☕ 

[Buy me a coffee](https://paypal.me/chupii37 )
