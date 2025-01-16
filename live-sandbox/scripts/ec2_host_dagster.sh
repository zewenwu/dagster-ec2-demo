#!/bin/bash

# Install necessary packages
sudo yum update -y
sudo yum install -y wget bzip2

# Download and install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

# Create a Dagster environment
conda create -n dagster_env python=3.12 -y
source activate dagster_env

# Install Dagster and Dagster webserver
pip install dagster dagster-webserver

# Set up Dagster home directory
export DAGSTER_HOME=/opt/dagster/dagster_home
mkdir -p $DAGSTER_HOME/logs

# Create a systemd service for Dagster webserver
cat <<EOF | sudo tee /etc/systemd/system/dagster-webserver.service
[Unit]
Description=Dagster Webserver
After=network.target

[Service]
Environment="DAGSTER_HOME=/opt/dagster/dagster_home"
ExecStart=/root/miniconda/envs/dagster_env/bin/dagster-webserver -h 0.0.0.0 -p 3000
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Create a systemd service for Dagster daemon
cat <<EOF | sudo tee /etc/systemd/system/dagster-daemon.service
[Unit]
Description=Dagster Daemon
After=network.target

[Service]
Environment="DAGSTER_HOME=/opt/dagster/dagster_home"
ExecStart=/root/miniconda/envs/dagster_env/bin/dagster-daemon run
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start services
sudo systemctl daemon-reload
sudo systemctl enable dagster-webserver
sudo systemctl start dagster-webserver
sudo systemctl enable dagster-daemon
sudo systemctl start dagster-daemon

echo "Dagster webserver and daemon have been set up and started."

# Check the status of the services
# sudo journalctl -u dagster-webserver
# sudo journalctl -u dagster-daemon
