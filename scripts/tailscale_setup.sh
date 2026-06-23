#!/bin/bash

if ! command -v curl > /dev/null 2>&1; then
    echo "Installing curl"
    sudo apt install curl -y
fi

if ! command -v tailscale > /dev/null 2>&1; then
    echo "Installing tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
fi

if ! sudo tailscale status > /dev/null 2>&1; then
    echo "Setting up tailscale"
    sudo tailscale up
fi