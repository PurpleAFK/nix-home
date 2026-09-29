#!/bin/bash

# This script launches the wlogout power menu.
# Ensure wlogout is installed on your system.

# You can customize the wlogout configuration in ~/.config/wlogout/layout (and style.css)
# to define the actions (shutdown, reboot, suspend, logout, lock).

wlogout --protocol layer-shell
