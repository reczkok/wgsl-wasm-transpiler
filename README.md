# WGSL Tool

A simple command-line tool to compile WGSL shaders to various output formats.

## Usage

```bash
# Compile to WGSL (default - useful for optimization analysis)
wgsl-tool shader.wgsl

# Compile to different formats
wgsl-tool shader.wgsl --format spirv
wgsl-tool shader.wgsl --format glsl
wgsl-tool shader.wgsl --format hlsl
wgsl-tool shader.wgsl --format metal

# Specify output file
wgsl-tool shader.wgsl --format glsl --output output.glsl

# Verbose output
wgsl-tool shader.wgsl --verbose
```

## Supported Formats

- **wgsl** - WebGPU Shading Language (default)
- **spirv** - SPIR-V binary format
- **glsl** - OpenGL Shading Language
- **hlsl** - High Level Shading Language (DirectX)
- **metal** - Metal Shading Language (Apple)

## Installation

```bash
# Build the tool
make release

# Install to system (optional)
make install
```

## Examples

The `examples/` directory contains sample shaders:

```bash
# Try the examples
make example-glsl    # Convert simple shader to GLSL
make example-hlsl    # Convert simple shader to HLSL
make example-metal   # Convert simple shader to Metal
make example-spirv   # Convert to SPIR-V binary
make example-multi   # Convert multi-stage shader
```

### Basic Fragment Shader

```wgsl
@fragment
fn main() -> @location(0) vec4<f32> {
    return vec4<f32>(1.0, 0.0, 0.0, 1.0);
}
```

Compiles to GLSL:
```glsl
#version 330 core
layout(location = 0) out vec4 _fs2p_location0;

void main() {
    _fs2p_location0 = vec4(1.0, 0.0, 0.0, 1.0);
    return;
}
```

### Optimization Analysis

The tool reveals how WGSL code is optimized during compilation:

```wgsl
// Original
let result = f32(1.0) / f32(u32(f32(2.0)));

// Optimized to
return vec4<f32>(0.5f, 0f, 0f, 1f);
```

Complex constant expressions are perfectly optimized to literal values!

## Testing

```bash
make test    # Run all tests
```

## Options

- `-f, --format <FORMAT>` - Output format (wgsl, spirv, glsl, hlsl, metal)
- `-o, --output <FILE>` - Output file path
- `-v, --verbose` - Verbose output
- `-h, --help` - Show help

## Project Structure

```
wgsl_analysis/
├── src/main.rs          # Main application
├── examples/            # Example shaders
├── scripts/             # Build and test scripts
└── docs/                # Documentation
```

Simple, focused, and effective for WGSL shader compilation and analysis.