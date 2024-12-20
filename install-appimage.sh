#!/bin/bash

# Function to convert filename to clean app name
clean_name() {
    # Remove .AppImage extension and convert remaining dots/spaces to underscores
    echo "$1" | sed 's/\.AppImage$//' | tr '. ' '_' | tr -s '_' | tr '[:upper:]' '[:lower:]'
}

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Check and install libfuse2
echo "Checking for libfuse2..."
apt update
if ! dpkg -l | grep -q libfuse2; then
    echo "Installing libfuse2..."
    apt install -y libfuse2
else
    echo "Checking for libfuse2 updates..."
    apt install --only-upgrade -y libfuse2
fi

# Find AppImage and SVG files in current directory
APPIMAGE=$(find . -maxdepth 1 -type f -name "*.AppImage" | head -n 1)
ICON=$(find . -maxdepth 1 -type f -name "*.svg" | head -n 1)

if [ -z "$APPIMAGE" ]; then
    echo "Error: No AppImage file found in current directory"
    exit 1
fi

# Remove ./ from the beginning of paths
APPIMAGE=${APPIMAGE#./}

# Function to create default icon if none provided
create_default_icon() {
    local icon_path="$1"
    cat > "$icon_path" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
    <rect x="5" y="5" width="90" height="90" rx="20" ry="20" fill="#4A90E2"/>
    <circle cx="50" cy="50" r="30" fill="#FFFFFF" opacity="0.2"/>
    <path d="M35 35 L65 35 L65 65 L35 65 Z" fill="none" stroke="#FFFFFF" stroke-width="6"/>
    <path d="M42 42 L58 42 L58 58 L42 58 Z" fill="#FFFFFF"/>
</svg>
EOF
}

# Handle icon - create default if none found
if [ -z "$ICON" ]; then
    echo "No icon found, creating default icon..."
    ICON="default_app_icon.svg"
    create_default_icon "$ICON"
fi

# Get clean name for directory and desktop file
CLEAN_NAME=$(clean_name "$APPIMAGE")
BASENAME=$(basename "$APPIMAGE" .AppImage)

# Optional interactive input
read -p "Enter application name (default: $BASENAME): " APP_NAME
APP_NAME=${APP_NAME:-$BASENAME}

read -p "Enter application description: " DESCRIPTION
DESCRIPTION=${DESCRIPTION:-"Application $APP_NAME"}

echo "Select category:"
echo "1) Utility"
echo "2) Graphics"
echo "3) Development"
echo "4) Office"
echo "5) Network"
read -p "Enter number (default: 1): " CATEGORY_NUM

case $CATEGORY_NUM in
    2) CATEGORY="Graphics;2DGraphics;3DGraphics;";;
    3) CATEGORY="Development;IDE;";;
    4) CATEGORY="Office;";;
    5) CATEGORY="Network;";;
    *) CATEGORY="Utility;";;
esac

# Create and setup application directory
echo "Creating application directory..."
mkdir -p "/opt/$CLEAN_NAME"
cp "$APPIMAGE" "/opt/$CLEAN_NAME/"
chmod +x "/opt/$CLEAN_NAME/$APPIMAGE"

# Setup icon
echo "Setting up icon..."
mkdir -p /usr/share/icons/hicolor/scalable/apps
cp "$ICON" "/usr/share/icons/hicolor/scalable/apps/$CLEAN_NAME.svg"

# Create desktop file
echo "Creating desktop entry..."
cat > "/usr/share/applications/$CLEAN_NAME.desktop" << EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$DESCRIPTION
Exec="/opt/$CLEAN_NAME/$APPIMAGE"
Icon=$CLEAN_NAME
Terminal=false
Type=Application
Categories=$CATEGORY
EOF

# Update system caches
echo "Updating system caches..."
update-desktop-database /usr/share/applications
gtk-update-icon-cache -f /usr/share/icons/hicolor

echo "Installation complete! You may need to log out and back in to see the application in your launcher."
