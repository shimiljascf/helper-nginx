#!/bin/bash

# Define variables
REMOTE_PATH="/etc/nginx/sites-enabled"
CONFIG_FILE="nginx.conf"
REPO_URL="git@github.com:shimiljascf/helper-nginx.git"
CLONE_DIR="$(pwd)"

# Check if the repository is already cloned
if [ ! -d "$CLONE_DIR/.git" ]; then
    echo "Cloning the repository..."
    git clone "$REPO_URL" "$CLONE_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to clone the repository. Exiting."
        exit 1
    fi
else
    echo "Repository already exists. Resetting to the latest state..."
    git -C "$CLONE_DIR" reset --hard HEAD
fi

# Pull the latest changes from the repository
echo "Pulling the latest changes from the repository..."
git -C "$CLONE_DIR" pull origin main
if [ $? -ne 0 ]; then
    echo "Failed to pull changes from the repository. Exiting."
    exit 1
fi

# Log the files in the repository
echo "Listing all files in the repository:"
ls -l "$CLONE_DIR"

# Log the path of the configuration file
echo "Using Nginx configuration file at: $CLONE_DIR/$CONFIG_FILE"

# Copy the updated configuration file to the Nginx directory
echo "Copying the updated Nginx configuration file..."
sudo cp "$CLONE_DIR/$CONFIG_FILE" "$REMOTE_PATH/default"
if [ $? -ne 0 ]; then
    echo "Failed to copy the configuration file. Exiting."
    exit 1
fi

# Test the Nginx configuration
echo "Testing the Nginx configuration..."
sudo nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed. Exiting."
    exit 1
fi

# Reload Nginx to apply changes
echo "Reloading Nginx to apply changes..."
sudo systemctl reload nginx || { echo "Error: Failed to reload Nginx."; exit 1; }

echo "Deployment completed successfully!"
