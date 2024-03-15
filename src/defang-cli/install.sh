#!/bin/bash

# Define the GitHub API URL for the latest release
RELEASE_API_URL="https://api.github.com/repos/defang-io/defang/releases/latest"

# Use curl to fetch the latest release data
echo "Fetching the latest release information..."
RELEASE_JSON=$(curl -s $RELEASE_API_URL)

# Check for curl failure
if [ $? -ne 0 ]; then
    echo "Error fetching release information. Please check your connection or if the URL is correct."
    exit 1
fi

# Determine system architecture
ARCH=$(uname -m)

# Adjust the architecture string to match the naming convention in the download URLs
case $ARCH in
    x86_64) ARCH_SUFFIX="amd64" ;;
    arm64) ARCH_SUFFIX="arm64" ;;
    aarch64) ARCH_SUFFIX="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Filter the download URL for Linux
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep -o "https://github.com/defang-io/defang/releases/download/v[0-9.]*/defang_[0-9.]*_linux_${ARCH_SUFFIX}.tar.gz" | head -n 1)

# Abort if the download URL is not found
if [ -z "$DOWNLOAD_URL" ]; then
    echo "Could not find a download URL for your architecture ($ARCH_SUFFIX)."
    exit 1
fi

echo "Downloading $DOWNLOAD_URL..."

# Define the output file name
FILENAME="defang_latest.tar.gz"

# Download the file
if ! curl -s -L "$DOWNLOAD_URL" -o "$FILENAME"; then
    echo "Download failed. Please check your internet connection and try again."
    exit 1
fi

# Create a temporary directory for extraction
EXTRACT_DIR=$(mktemp -d)

# Extract the downloaded file to the temporary directory
echo "Extracting the downloaded file to $EXTRACT_DIR..."
if ! tar -xzf "$FILENAME" -C "$EXTRACT_DIR"; then
    echo "Failed to extract the downloaded file. The file might be corrupted."
    exit 1
fi

# Define a global installation directory that should be in the PATH
INSTALL_DIR="/usr/local/bin"

# Move the binary or application to the installation directory from the temporary directory
BINARY_NAME='defang' # Adjust this based on actual content
echo "Moving defang to $INSTALL_DIR"
if ! mv "$EXTRACT_DIR/$BINARY_NAME" "$INSTALL_DIR"; then
    echo "Failed to move defang. Please check your permissions and try again."
    exit 1
fi

# Make the binary executable
if ! chmod +x "$INSTALL_DIR/$BINARY_NAME"; then
    echo "Failed to make defang executable. Please check your permissions and try again."
    exit 1
fi

# Cleanup: Remove the temporary directory and the originally downloaded file
echo "Cleaning up..."
rm -r "$EXTRACT_DIR"
rm "$FILENAME"

echo "Installation completed. You can now use defang by typing '$BINARY_NAME' in the terminal."
