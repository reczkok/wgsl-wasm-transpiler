#!/bin/bash

set -e

echo "Installing WGSL Tool..."

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "Error: Rust is not installed. Please install Rust first:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# Build the project
echo "Building..."
cargo build --release

# Create install directory
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Copy binary
BINARY_PATH="./target/release/wgsl_analysis"
cp "$BINARY_PATH" "$INSTALL_DIR/wgsl-tool"

echo "✓ Installed to $INSTALL_DIR/wgsl-tool"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Warning: $HOME/.local/bin is not in your PATH"
    echo "Add this to your shell profile:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo "Usage: wgsl-tool input.wgsl --format glsl"
