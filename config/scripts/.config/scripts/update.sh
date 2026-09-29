#!/bin/bash

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root. Please use 'sudo'." >&2
    exit 1
fi

echo "🚀 Starting Ultimate Fedora Maintenance..."
echo "-------------------------------------------"

# 1. Update DNF Packages
echo "📦 Step 1: Updating System Packages (DNF)..."
dnf upgrade --refresh -y

# 2. Update Flatpaks (Since you use Obsidian/Todo Flatpaks)
if command -v flatpak &> /dev/null; then
    echo "📦 Step 2: Updating Flatpaks..."
    flatpak update -y
    flatpak uninstall --unused -y
fi

# 3. NVIDIA Driver Check (Crucial for your GTX 1650)
echo "🔧 Step 3: Checking NVIDIA Kernel Modules..."
# This ensures akmods triggers if a new kernel was just installed
akmods --force
# Update dracut to ensure the new drivers are in the boot image
dracut --force

# 4. Firmware Updates
echo "💻 Step 4: Checking for Laptop Firmware updates..."
fwupdmgr get-updates -y
fwupdmgr update -y

# 5. Cleanup
echo "🧹 Step 5: System Cleanup..."
dnf autoremove -y
dnf clean all
# Clean user cache (including your wal/pywal cache)
rm -rf ~/.cache/thumbnails/*

# 6. Check for Failed System Services
echo "🔍 Step 6: Checking for failed services..."
systemctl --failed

echo "-------------------------------------------"
echo "✅ Maintenance complete!"
echo "⚠️  If a new kernel was installed, please REBOOT to apply changes."
