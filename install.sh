#!/usr/bin/env bash
# This script installs ssm to current directory


echo "==========================="
echo " INSTALLING SSM"
echo "==========================="
echo ""

echo "[INFO] This script will install ssm (https://github.com/houen/ssm) to your current directory."
current_dir=$(pwd)
install_dir="$current_dir/ssm"
echo "[INFO] Installing to $install_dir"

# ====================================
# Have user confirm installation directory
# ====================================
echo ""
read -p "[INPUT] Are you sure you want to install here? (Y/n): " do_install
if [ $do_install == 'n' ] || [ $do_install == 'N' ]; then
    echo "[INFO] Aborting installation"
    exit 1
fi

# ====================================
# Check that gpg command exists
# ====================================
echo ""
echo "[INFO] Checking that gpg is installed..."
gpg_path=$(command -v gpg)
if [ -z $gpg_path ]; then
    echo "[ERROR] gpg is not installed"
    exit 1
fi
echo "...ok!"

# ====================================
# Clone ssm master from github and remove ssm .git dir
# ====================================
echo ""
echo "[INFO] Pulling ssm from git and installing to $install_dir..."
git clone --depth   1 -q -- git@github.com:houen/ssm.git ssm && rm -Rf ssm/.git
echo "...ok!"

# ====================================
# Have ssm encrypted files not ignored by git
# ====================================
echo ""
echo "[INFO] Marking .ssm.gpg files as not ignored in .gitignore..."
# Add gitginore exception
echo '!*.ssm.gpg' >> .gitignore
# Add EOF newline
echo '' >> .gitignore
echo "...ok!"

# ====================================
# Post-install instructions
# ====================================
echo ""
echo ""
echo "==========================="
echo "Success! ssm is now installed."
echo "==========================="
echo ""
echo "Next steps:"
echo ""
echo "- Add your gpg key with bin/import_pubkey YOUR_KEY_ID"
echo "- Add secrets with bin/add_secret_file relative/path/to/file"
echo "- Encrypt secrets with bin/add_secret_file relative/path/to/file"
echo ""
echo "For more information, see README at https://github.com/houen/ssm)"
echo ""
echo ""