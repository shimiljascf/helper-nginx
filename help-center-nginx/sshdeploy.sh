#!/bin/bash

# Define variables
REMOTE_PATH="/etc/nginx/sites-enabled"
CONFIG_FILE="help-center-nginx/nginx.conf" # Relative path from the Git root to the nginx.conf file
GIT_ROOT="/home/ec2-user/helper-nginx"     # Root directory of the Git repository

# Validate that the Git root directory is a valid repository
if [ ! -d "$GIT_ROOT/.git" ]; then
    echo "Error: $GIT_ROOT is not a valid Git repository. Exiting."
    exit 1
fi

# Pull the latest changes from the repository
echo "Pulling the latest changes from the repository in $GIT_ROOT..."
git -C "$GIT_ROOT" pull origin main
if [ $? -ne 0 ]; then
    echo "Failed to pull changes from the repository. Exiting."
    exit 1
fi

# Log the files in the repository
echo "Listing all files in the repository:"
ls -l "$GIT_ROOT"

# Log the path of the configuration file
echo "Using Nginx configuration file at: $GIT_ROOT/$CONFIG_FILE"

# Copy the updated configuration file to the Nginx directory
echo "Copying the updated Nginx configuration file..."
sudo cp "$GIT_ROOT/$CONFIG_FILE" "$REMOTE_PATH/default"
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
