#!/bin/bash

# Simple build script for WebAssembly

set -e

echo "Building WGSL Analysis Tool for WebAssembly..."

# Check if wasm-pack is installed
if ! command -v wasm-pack &> /dev/null; then
    echo "Error: wasm-pack not found. Install with: cargo install wasm-pack"
    exit 1
fi

# Clean previous builds
rm -rf pkg/ pkg-bundler/ pkg-nodejs/

# Build for different targets
echo "Building for web browsers..."
wasm-pack build --target web --out-dir pkg --features wasm

echo "Building for bundlers..."
wasm-pack build --target bundler --out-dir pkg-bundler --features wasm

echo "Building for Node.js..."
wasm-pack build --target nodejs --out-dir pkg-nodejs --features wasm

echo "✓ Build complete!"
echo "Test with: node examples/nodejs-example.js"
