# WGSL Tool

A tool to compile WGSL shaders to various output formats, available as both a CLI tool and WebAssembly module.

## Quick Start

### CLI Usage
```bash
# Build and run
cargo run --features cli -- shader.wgsl --format glsl

# Available formats: wgsl, glsl, hlsl, metal, spirv, spirv-asm
cargo run --features cli -- shader.wgsl --format hlsl --output shader.hlsl
```

### WebAssembly Usage

**Node.js:**
```javascript
const { compileShader, init } = require('./pkg-nodejs/wgsl_tool.js');
init();

const wgsl = '@fragment fn main() -> @location(0) vec4<f32> { return vec4<f32>(1.0, 0.0, 0.0, 1.0); }';
const glsl = compileShader(wgsl, 'glsl');
console.log(glsl);
```

**Browser:**
```javascript
import init, { compileShader } from './pkg/wgsl_tool.js';
await init();
const result = compileShader(wgslCode, 'glsl');
```

## Build

### CLI Tool
```bash
cargo build --release --features cli
```

### WebAssembly Module
```bash
# Install wasm-pack
cargo install wasm-pack

# Build for web
./scripts/build-wasm.sh
```

## Supported Formats

- **WGSL** - WebGPU Shading Language
- **GLSL** - OpenGL Shading Language  
- **HLSL** - DirectX Shading Language
- **Metal** - Apple's Metal Shading Language
- **SPIR-V** - Binary format (base64 encoded in WASM)
- **SPIR-V Assembly** - Human-readable SPIR-V disassembly

### SPIR-V Formats

The tool supports two SPIR-V output formats:

1. **`spirv`** - Binary SPIR-V format
   - CLI: Outputs raw binary `.spv` files
   - WASM: Returns base64-encoded binary data

2. **`spirv-asm`** - Human-readable SPIR-V assembly
   - CLI: Outputs text `.spvasm` files  
   - WASM: Returns disassembled text
   - Useful for debugging and understanding SPIR-V structure

## Examples

- `examples/triangle.wgsl` - Basic triangle shader
- `examples/web-example.html` - Browser demo
- `examples/nodejs-example.js` - Node.js usage

## API

### `compileShader(wgsl_code: string, format: string) -> string`
Compiles WGSL to the specified format.

### `getSupportedFormats() -> string[]`
Returns available output formats.

### `init()` (Node.js only)
Initializes the WebAssembly module.

## Testing

```bash
# Test CLI
cargo test --features cli

# Test WebAssembly  
cargo test --features wasm

# Run comprehensive tests
./scripts/test-all.sh

# Run web example
python3 scripts/serve.py
# Open http://localhost:8000/examples/web-example.html
```

## Project Structure

```
wgsl_analysis/
├── src/
│   ├── main.rs              # CLI application
│   └── lib.rs               # WebAssembly bindings
├── examples/
│   ├── triangle.wgsl        # Example shader
│   ├── web-example.html     # Browser demo
│   └── nodejs-example.js    # Node.js demo
├── scripts/
│   ├── build-wasm.sh        # Build WebAssembly
│   ├── serve.py             # Development server
│   └── test-all.sh          # Run tests
├── pkg/                     # Generated: Web target
├── pkg-bundler/             # Generated: Bundler target
├── pkg-nodejs/              # Generated: Node.js target
├── Cargo.toml               # Rust dependencies
└── package.json             # NPM configuration
```
