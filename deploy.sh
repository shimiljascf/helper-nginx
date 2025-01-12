#!/bin/bash

# Define variables
NGINX_DIR="/etc/nginx"
CONFIG_REPO_DIR="$HOME/help-nginx"
BRANCH="main"

# Function: Log messages
log() {
    echo -e "[`date +"%Y-%m-%d %H:%M:%S"`] $@"
}

# Pull latest changes
log "Pulling latest configuration from Bitbucket..."
if [ ! -d "$CONFIG_REPO_DIR" ]; then
    log "Error: Configuration repository directory not found at $CONFIG_REPO_DIR."
    exit 1
fi

cd $CONFIG_REPO_DIR || { log "Error: Could not change directory to $CONFIG_REPO_DIR."; exit 1; }

git fetch origin
git reset --hard origin/$BRANCH || { log "Error: Failed to pull latest changes from branch $BRANCH."; exit 1; }

# Update configuration files
log "Updating Nginx configuration..."
if [ ! -f "$CONFIG_REPO_DIR/nginx.conf" ]; then
    log "Error: nginx.conf not found in $CONFIG_REPO_DIR."
    exit 1
fi

sudo cp $CONFIG_REPO_DIR/nginx.conf $NGINX_DIR/nginx.conf || { log "Error: Failed to update nginx.conf."; exit 1; }
sudo cp -r $CONFIG_REPO_DIR/sites-available/* $NGINX_DIR/sites-available/ || { log "Error: Failed to update sites-available directory."; exit 1; }

# Create symbolic links for enabled sites
log "Creating symbolic links for enabled sites..."
for config in $NGINX_DIR/sites-available/*; do
    site=$(basename $config)
    sudo ln -sf "$NGINX_DIR/sites-available/$site" "$NGINX_DIR/sites-enabled/$site" || { log "Error: Failed to create symbolic link for $site."; exit 1; }
done

# Test and reload Nginx
log "Testing Nginx configuration..."
sudo nginx -t
if [ $? -ne 0 ]; then
    log "Error: Nginx configuration test failed."
    exit 1
fi

log "Reloading Nginx..."
sudo systemctl reload nginx || { log "Error: Failed to reload Nginx."; exit 1; }

log "Deployment completed successfully!"
