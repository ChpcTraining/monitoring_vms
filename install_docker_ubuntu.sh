#!/bin/bash

set -e  # Exit on error

# Update package lists
echo "Updating system..."
sudo apt update -y

# Install required packages
echo "Installing dependencies..."
sudo apt install -y ca-certificates curl gnupg

# Add Docker’s official GPG key
echo "Adding Docker’s GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y

# Install Docker Engine and dependencies
echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
echo "Docker Version:"
sudo docker --version

echo "Docker Compose Version:"
sudo docker compose version

echo "Docker installation complete!"
