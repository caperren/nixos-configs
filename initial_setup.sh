#!/usr/bin/env bash
# To set up a fresh system, run the following:
# curl -sSL https://raw.githubusercontent.com/caperren/nixos-configs/main/initial_setup.sh | bash
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

GIT_REPO_NAME="nixos-configs"
GIT_RELEASE_BRANCH="playground"
GIT_REPO_URL="git@github.com:caperren/$GIT_REPO_NAME.git"

NIXOS_REPO_CONFIG_PARENT_PATH="/opt"
NIXOS_REPO_CONFIG_PATH="$NIXOS_REPO_CONFIG_PARENT_PATH/$GIT_REPO_NAME"
HOST_CONFIG_PATH="$NIXOS_REPO_CONFIG_PATH/hosts/$(hostname)"

# If the config repo doesn't exist, clone it
if [ ! -d "$NIXOS_REPO_CONFIG_PATH" ]; then
    TEMP_CLONE_DIR="/home/$USER/$GIT_REPO_NAME"

    if [[ ! -d "$NIXOS_REPO_CONFIG_PARENT_PATH" ]]; then
        sudo mkdir -p "$NIXOS_REPO_CONFIG_PARENT_PATH"
    fi

    git clone "$GIT_REPO_URL" "$TEMP_CLONE_DIR" || true

    sudo mv "$TEMP_CLONE_DIR" "$NIXOS_REPO_CONFIG_PARENT_PATH/."
    cd "$NIXOS_REPO_CONFIG_PATH"

    git checkout "$GIT_RELEASE_BRANCH"

    sudo chown -R $USER:users "$NIXOS_REPO_CONFIG_PATH" 
fi

# If we're not running from the repo directory, this script launch is a setup bootstrap
# Exec the same script in the config repo, which should be the right one for the release branch
# we want
if [[ "$SCRIPT_DIR" != "$NIXOS_REPO_CONFIG_PATH" ]]; then
    exec "$NIXOS_REPO_CONFIG_PATH/initial_setup.sh"
    exit
fi

# If this is a new host, create the config path
if [ ! -d "$HOST_CONFIG_PATH" ]; then
    mkdir -p "$HOST_CONFIG_PATH"
fi

# Copy initial config files from nixos setup, and symlink to our repo, if not set up yet
if [ ! -L "/etc/nixos" ]; then
    # Copy the existing config files
    cp /etc/nixos/configuration.nix "$HOST_CONFIG_PATH/."
    cp /etc/nixos/hardware-configuration.nix "$HOST_CONFIG_PATH/."

    # Backup the existing nixos config folder
    sudo mv /etc/nixos /etc/nixos_bkp

    # Create symlink
    sudo ln -s "$NIXOS_REPO_CONFIG_PATH" /etc/nixos
fi
