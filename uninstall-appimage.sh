#!/bin/bash

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# List all .desktop files in the applications directory
echo "Installed AppImage applications:"
echo "--------------------------------"

# Counter for menu options
counter=1
# Array to store desktop files
declare -a desktop_files

while IFS= read -r file; do
    if grep -q "AppImage" "$file"; then
        echo "$counter) $(basename "$file" .desktop)"
        desktop_files+=("$file")
        ((counter++))
    fi
done < <(find /usr/share/applications -name "*.desktop")

if [ ${#desktop_files[@]} -eq 0 ]; then
    echo "No AppImage applications found."
    exit 1
fi

# Get user selection
read -p "Enter number to uninstall (1-$((counter-1))): " selection

# Validate input
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $((counter-1)) ]; then
    echo "Invalid selection"
    exit 1
fi

# Get selected desktop file
selected_file="${desktop_files[$((selection-1))]}"
app_name=$(basename "$selected_file" .desktop)

echo "Uninstalling $app_name..."

# Remove application directory from /opt
if [ -d "/opt/$app_name" ]; then
    echo "Removing application directory..."
    rm -rf "/opt/$app_name"
fi

# Remove desktop file
echo "Removing desktop file..."
rm "$selected_file"

# Remove icon
if [ -f "/usr/share/icons/hicolor/scalable/apps/$app_name.svg" ]; then
    echo "Removing icon..."
    rm "/usr/share/icons/hicolor/scalable/apps/$app_name.svg"
fi

# Update system caches
echo "Updating system caches..."
update-desktop-database /usr/share/applications
gtk-update-icon-cache -f /usr/share/icons/hicolor

echo "Uninstallation complete! You may need to log out and back in to see the changes in your launcher."
