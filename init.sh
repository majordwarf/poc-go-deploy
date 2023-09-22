#!/bin/bash

# Define variables
VAGRANT_FILE="Vagrantfile"

# Enable the "errexit" option
set -e

# ==============================================================================
# Helper functions
# ==============================================================================

# Function to check if the Vagrant box is already added
is_box_added() {
  if [[ "$PLATFORM" == "docker" ]]; then
    BOX_NAME="ubuntu/focal64"
  else
    BOX_NAME="ilionx/ubuntu2004-minikube"
  fi

  if ! vagrant box list | grep -q "$BOX_NAME"; then
    echo "Vagrant box is missing! Adding the Vagrant box..."
    vagrant box add $BOX_NAME >> /dev/null 2>&1
  else
    echo "Vagrant box is already added."
  fi
}

# Function to initialize the Vagrant environment
is_vagrantfile() {
  if [ ! -f "$VAGRANT_FILE" ]; then
    echo "Vagrantfile is missing! Exiting..."
    exit 1
  else
    echo "Vagrantfile is already present."
  fi
}

# Function to start the Vagrant box
start_vagrant() {
  echo "Starting the Vagrant box with $PLATFORM..."
  PLATFORM=$PLATFORM vagrant up
}

generate_ssl() {
  echo "Generating SSL certificates, please input the following information:"
  read -p "Country (C): " country
  read -p "State (ST): " state
  read -p "City (L): " city
  read -p "Company (O): " company
  read -p "Department (OU): " department
  read -p "Common Name (CN): " common_name
  # Prompt user for certificate validity in days
  read -p "Certificate Validity (in days): " validity_days

  # Check if input is a positive integer
  if ! [[ "$validity_days" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: Input must be a positive integer. Please try again."
    return
  fi

  # Check if all fields are input
  if [[ -z "$country" || -z "$state" || -z "$city" || -z "$company" || -z "$department" || -z "$common_name" || -z "$validity_days" ]]; then
    echo "Error: All fields are required. Please try again."
    return
  fi

  openssl req -x509 -newkey rsa:4096 -keyout configs/nginx/key.pem -out configs/nginx/cert.pem -sha256 -days "${validity_days}" -nodes -subj "/C=${country}/ST=${state}/L=${city}/O=${company}/OU=${department}/CN=${common_name}"
  echo "Certificate and key files generated: cert.pem and key.pem in configs/nginx/"
}

post_setup() {
  if [[ "$PLATFORM" == "docker" ]]; then
    echo "You can now access the app using http at https://localhost:8080"
    echo "You can now access the app using https at https://localhost:4430"
    echo "You can now access Prometheus using http at http://localhost:9090"
    echo "You can now access Grafana using http at http://localhost:3000"
  else
    echo "Currently the app is not accessible from outside the cluster."
    echo "You need to ssh into the Vagrant box to access the app."
    echo 'Once inside the cluster you can run `curl $(minikube ip):8080` to access the app.'
  fi
}

# ==============================================================================
# Main script execution
# ==============================================================================

echo "-------------------------------------------------------------------------"
echo "Welcome to the automation script!"
echo "This script will help you to deploy the app on a Vagrant box."

echo "-------------------------------------------------------------------------"
echo "Do you want to generate SSL certificates for the app [Required for first time]? (y/n)"
read -p "Enter your choice (y/n): " choice
if [[ "$choice" == "y" ]]; then
  generate_ssl
else
  echo "Skipping SSL certificate generation."
fi

echo "-------------------------------------------------------------------------"
# Initialize the Vagrant environment if not already initialized
is_vagrantfile

echo "-------------------------------------------------------------------------"
echo "Which platform do you want to deploy the app on (choose the corresponding number):"
echo "[1] Docker"
echo "[2] Kubernetes"
read -p "Enter your choice (1/2): " choice

if [[ "$choice" == "1" ]]; then
    PLATFORM="docker"
elif [[ "$choice" == "2" ]]; then
    PLATFORM="kubernetes"
else
    echo "Invalid choice. Exiting..."
    exit 1
fi

echo "-------------------------------------------------------------------------"
# Check if the Vagrant box is already added
is_box_added
# Start the Vagrant box
start_vagrant

echo "-------------------------------------------------------------------------"
post_setup

echo "-------------------------------------------------------------------------"
# Script completed
echo "Vagrant box is up and running."
