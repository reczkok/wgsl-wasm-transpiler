#!/bin/bash

# Build script for WebAssembly compilation of WGSL Analysis Tool

set -e

echo "Building WGSL Analysis Tool for WebAssembly..."

# Check if wasm-pack is installed
if ! command -v wasm-pack &> /dev/null; then
    echo "wasm-pack is not installed. Please install it first:"
    echo "cargo install wasm-pack"
    exit 1
fi

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf pkg/

# Build the WebAssembly package
echo "Building WebAssembly package..."
wasm-pack build --target web --out-dir pkg --features wasm

# Build for bundler target as well
echo "Building for bundler target..."
wasm-pack build --target bundler --out-dir pkg-bundler --features wasm

# Build for Node.js target
echo "Building for Node.js target..."
wasm-pack build --target nodejs --out-dir pkg-nodejs --features wasm

echo "Build complete!"
echo "Output directories:"
echo "  - pkg/         (web target)"
echo "  - pkg-bundler/ (bundler target)"
echo "  - pkg-nodejs/  (nodejs target)"
echo ""
echo "Usage examples:"
echo "  Web: import init, { compile_shader } from './pkg/wgsl_analysis.js';"
echo "  Node: const { compile_shader } = require('./pkg-nodejs/wgsl_analysis.js');"
echo "  Bundler: import { compile_shader } from './pkg-bundler/wgsl_analysis.js';"
