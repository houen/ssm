#!/usr/bin/env bash
# This script installs ssm to current directory

current_dir=pwd

echo "[INFO] This script will install ssm (https://github.com/houen/ssm) to your current directory."
echo "[INFO] Current directory: $current_dir"
echo "[INPUT] Are you sure you want to install here? (Y/n)"

echo "TODO: Check for gpg installed"

echo "[INPUT] Please enter the name of your pgp key:"
read gpg_key_name

echo "TODO: Check for gpg key exists"

# git clone --depth 1 -q -- git@github.com:houen/ssm.git ssm && rm -Rf ssm/.git