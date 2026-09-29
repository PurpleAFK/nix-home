#!/bin/bash

# A simple system maintenance script for Fedora Linux.
# This script performs the following tasks:
# 1. Updates all installed packages.
# 2. Removes orphaned packages that are no longer needed.
# 3. Cleans up the DNF package cache.
# 4. Removes old kernels, keeping only the latest two.

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo'." >&2
    exit 1
fi

echo "Starting Fedora system maintenance..."
echo "-------------------------------------------"

# Step 1: Update all installed packages
echo "-> Updating all system packages..."
dnf upgrade --refresh -y

# Step 2: Remove orphaned packages
echo "-> Removing orphaned packages that are no longer required..."
dnf autoremove -y

# Step 3: Clean up the DNF cache
echo "-> Cleaning up DNF package cache..."
dnf clean all

# Step 4: Remove old kernels, keeping the latest two
echo "-> Removing old kernels, keeping the latest two..."
# This command finds all installed kernels except the two most recent and removes them.
# The `repoquery` command lists installed kernels.
# The `--installonly` filter targets packages that are "install-only" (like kernels).
# The `--latest-limit=-2` option tells it to list all but the last two versions.
# The `-q` suppresses extra output.
dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q) -y

echo "-------------------------------------------"
echo "Fedora system maintenance complete."
