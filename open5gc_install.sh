#!/bin/bash

echo "=============================="
echo " Open5GS Lab Auto Installer "
echo "=============================="

# Update system
echo "[1/6] Updating system..."
sudo dnf update -y

# Install required tools
echo "[2/6] Installing base packages..."
sudo dnf install -y yum-utils git curl wget

# Add Docker repo
echo "[3/6] Adding Docker repo..."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
echo "[4/6] Installing Docker..."
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start Docker
echo "[5/6] Starting Docker..."
sudo systemctl enable --now docker

# Install Docker Compose
echo "[6/6] Installing Docker Compose..."
sudo dnf install -y docker-compose-plugin

echo "✅ Installation Completed!"
