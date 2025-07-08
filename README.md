# WGSL Analysis Tool

A powerful tool to compile WGSL shaders to various output formats, available as both a command-line tool and WebAssembly module for JavaScript integration.

## Usage

### Command Line Tool

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

### WebAssembly Module

#### In Web Browsers

```html
<script type="module">
    import init, { compile_shader, get_supported_formats } from './pkg/wgsl_analysis.js';

    async function compileShader() {
        await init();
        
        const wgslCode = `
            @fragment
            fn main() -> @location(0) vec4<f32> {
                return vec4<f32>(1.0, 0.0, 0.0, 1.0);
            }
        `;
        
        try {
            const glslOutput = compile_shader(wgslCode, "glsl");
            console.log(glslOutput);
        } catch (error) {
            console.error("Compilation failed:", error);
        }
    }
    
    compileShader();
</script>
```

#### In Node.js

```javascript
const { compile_shader, get_supported_formats, init } = require('./pkg-nodejs/wgsl_analysis.js');

init();

const wgslCode = `
    @fragment
    fn main() -> @location(0) vec4<f32> {
        return vec4<f32>(1.0, 0.0, 0.0, 1.0);
    }
`;

try {
    const glslOutput = compile_shader(wgslCode, "glsl");
    console.log(glslOutput);
} catch (error) {
    console.error("Compilation failed:", error);
}
```

#### With Bundlers (Webpack, Vite, etc.)

```javascript
import { compile_shader, get_supported_formats } from './pkg-bundler/wgsl_analysis.js';

const result = compile_shader(wgslCode, "hlsl");
```

## Supported Formats

- **wgsl** - WebGPU Shading Language (default)
- **spirv** - SPIR-V binary format
- **glsl** - OpenGL Shading Language
- **hlsl** - High Level Shading Language (DirectX)
- **metal** - Metal Shading Language (Apple)

## Installation

### Command Line Tool

```bash
# Build the CLI tool
cargo build --release --features cli

# Run directly
./target/release/wgsl_analysis shader.wgsl --format glsl
```

### WebAssembly Module

You need to have `wasm-pack` installed:

```bash
# Install wasm-pack
cargo install wasm-pack

# Build WebAssembly module
./build-wasm.sh

# Or build for specific targets
npm run build:web      # For web browsers
npm run build:bundler  # For bundlers
npm run build:nodejs   # For Node.js
```

### NPM Package (after building)

```bash
# Install locally
npm install ./wgsl-analysis

# Or if published to npm
npm install wgsl-analysis
```

## Examples

The `examples/` directory contains sample implementations:

### Command Line Examples

```bash
# Compile example shaders
cargo run --features cli -- examples/triangle.wgsl --format glsl
cargo run --features cli -- examples/triangle.wgsl --format hlsl
cargo run --features cli -- examples/triangle.wgsl --format metal
```

### WebAssembly Examples

```bash
# Run the web example (after building WASM)
# Open examples/web-example.html in a browser

# Run the Node.js example
node examples/nodejs-example.js

# Compile a file using Node.js example
node examples/nodejs-example.js examples/triangle.wgsl glsl
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
# Test CLI features
cargo test --features cli

# Test WebAssembly features
cargo test --features wasm

# Test both
cargo test --all-features
```

## API Reference

### Command Line Options

- `-f, --format <FORMAT>` - Output format (wgsl, spirv, glsl, hlsl, metal)
- `-o, --output <FILE>` - Output file path
- `-v, --verbose` - Verbose output
- `-h, --help` - Show help

### WebAssembly Functions

#### `compile_shader(wgsl_source: string, format: string) -> string`

Compiles WGSL shader code to the specified output format.

**Parameters:**
- `wgsl_source` - The WGSL shader source code
- `format` - Output format: "wgsl", "spirv", "glsl", "hlsl", or "metal"

**Returns:** Compiled shader code as string (base64 encoded for SPIR-V)

**Throws:** Error with compilation details if compilation fails

#### `get_supported_formats() -> Array<string>`

Returns an array of supported output formats.

#### `init()`

Initializes the WebAssembly module. Call this before using other functions.

## Project Structure

```
wgsl_analysis/
├── src/
│   ├── main.rs          # CLI application
│   └── lib.rs           # WebAssembly bindings
├── examples/
│   ├── triangle.wgsl    # Example shader
│   ├── web-example.html # Browser usage example
│   └── nodejs-example.js # Node.js usage example
├── pkg/                 # WebAssembly output (web)
├── pkg-bundler/         # WebAssembly output (bundler)
├── pkg-nodejs/          # WebAssembly output (Node.js)
├── build-wasm.sh        # Build script for WebAssembly
├── package.json         # NPM package configuration
└── Cargo.toml          # Rust dependencies
```

## Features

- **Cross-platform**: Works on Windows, macOS, and Linux
- **Multiple targets**: CLI tool and WebAssembly module
- **Format support**: WGSL, SPIR-V, GLSL, HLSL, Metal
- **Error handling**: Detailed compilation error messages
- **Validation**: Full shader validation using Naga
- **Optimization**: Shows optimized shader output

Perfect for shader development, WebGPU applications, and cross-platform graphics tools.