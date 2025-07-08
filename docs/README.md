# WGSL Roundtrip Tool

A CLI tool that translates WGSL → SPIR-V → WGSL for testing roundtrip compatibility and analyzing how WGSL shaders are transformed through the compilation pipeline.

## Features

- Parses WGSL source code into Naga's intermediate representation
- Translates to SPIR-V binary format
- Translates back from SPIR-V to WGSL
- Validates modules at each step
- Provides verbose output for debugging
- Customizable output file paths

## Installation

Make sure you have Rust installed, then build the project:

```bash
cargo build --release
```

## Usage

### Basic Usage

```bash
# Process a WGSL file (creates input_CP.wgsl)
cargo run -- shader.wgsl

# Or using the built binary
./target/release/wgsl_analysis shader.wgsl
```

### Advanced Usage

```bash
# Specify custom output file
cargo run -- shader.wgsl --output processed_shader.wgsl

# Enable verbose output
cargo run -- shader.wgsl --verbose

# Combine options
cargo run -- shader.wgsl --output result.wgsl --verbose
```

### Command Line Options

- `<input>`: Path to the input WGSL file (required)
- `-o, --output <OUTPUT>`: Custom output file path (optional)
- `-v, --verbose`: Enable verbose output showing each processing step
- `-h, --help`: Show help information
- `-V, --version`: Show version information

## Examples

### Example 1: Basic Vertex/Fragment Shader

Input file `example.wgsl`:
```wgsl
@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> @builtin(position) vec4<f32> {
    var pos = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>(3.0, -1.0),
        vec2<f32>(-1.0, 3.0)
    );
    return vec4<f32>(pos[vertex_index], 0.0, 1.0);
}

@fragment
fn fs_main(@builtin(position) position: vec4<f32>) -> @location(0) vec4<f32> {
    let uv = position.xy / vec2<f32>(800.0, 600.0);
    let color = vec3<f32>(uv.x, uv.y, 0.5);
    return vec4<f32>(color, 1.0);
}
```

Run the tool:
```bash
cargo run -- example.wgsl --verbose
```

This will create `example_CP.wgsl` with the roundtrip-processed WGSL code.

### Example 2: Compute Shader

```wgsl
@compute @workgroup_size(64, 1, 1)
fn cs_main(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let index = global_id.x;
    
    if (index >= arrayLength(&input_data)) {
        return;
    }
    
    let input_value = input_data[index];
    var result = input_value * 2.0;
    
    if (input_value > 0.5) {
        result = result + 1.0;
    } else {
        result = result * 0.5;
    }
    
    output_data[index] = result;
}

@group(0) @binding(0) var<storage, read> input_data: array<f32>;
@group(0) @binding(1) var<storage, read_write> output_data: array<f32>;
```

### Example 3: Complex Vertex/Fragment Shader

Input `shader.wgsl`:
```wgsl
@vertex
fn vs_main(
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @builtin(instance_index) instance_id: u32,
) -> VertexOutput {
    var out: VertexOutput;
    out.position = transform_matrix * vec4<f32>(position, 1.0);
    out.normal = normalize(normal);
    out.instance_color = vec3<f32>(f32(instance_id) / 255.0, 0.5, 1.0);
    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return vec4<f32>(in.instance_color, 1.0);
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) normal: vec3<f32>,
    @location(1) instance_color: vec3<f32>,
}

@group(0) @binding(0) var<uniform> transform_matrix: mat4x4<f32>;
```

Run the tool:
```bash
cargo run -- shader.wgsl --verbose
```

Output `shader_CP.wgsl` (after roundtrip):
```wgsl
var<private> global: vec3<f32>;
var<private> global_1: vec3<f32>;
var<private> global_2: u32;
var<private> global_3: vec4<f32>;
var<private> global_4: vec3<f32>;
var<private> global_5: vec3<f32>;
var<private> global_6: VertexOutput;
var<private> global_7: vec4<f32>;

fn function() {
    let _e19 = global;
    let _e20 = global_1;
    let _e21 = global_2;
    let _e24 = transform_matrix;
    global_3 = (_e24 * vec4<f32>(_e19, 1f));
    global_4 = normalize(_e20);
    global_5 = vec3<f32>((f32(_e21) / 255f), 0.5f, 1f);
    let _e34 = global_3;
    let _e35 = global_4;
    let _e36 = global_5;
    global_6 = VertexOutput(_e34, _e35, _e36);
    return;
}

fn function_1() {
    let _e19 = global_6;
    global_7 = vec4<f32>(_e19.instance_color, 1f);
    return;
}

struct VertexOutput {
    position: vec4<f32>,
    normal: vec3<f32>,
    instance_color: vec3<f32>,
}

@group(0) @binding(0) 
var<uniform> transform_matrix: mat4x4<f32>;

@vertex 
fn vs_main(@location(0) param: vec3<f32>, @location(1) param_1: vec3<f32>, @builtin(instance_index) param_2: u32) -> VertexOutput {
    global = param;
    global_1 = param_1;
    global_2 = param_2;
    function();
    let _e4 = global_6.position.y;
    global_6.position.y = -(_e4);
    let _e6 = global_6;
    return _e6;
}

@fragment 
fn fs_main(param_3: VertexOutput) -> @location(0) vec4<f32> {
    global_6 = param_3;
    function_1();
    let _e3 = global_7;
    return _e3;
}
```

## What the Tool Does

1. **Parse WGSL**: Reads the input WGSL file and parses it into Naga's intermediate representation
2. **Validate**: Validates the parsed module for correctness
3. **Translate to SPIR-V**: Converts the module to SPIR-V binary format
4. **Translate from SPIR-V**: Parses the SPIR-V binary back to Naga's intermediate representation
5. **Translate to WGSL**: Converts the roundtrip module back to WGSL source code
6. **Output**: Writes the result to a file with `_CP` suffix (or custom name)

## Key Transformations

The roundtrip process reveals how WGSL code is transformed:

- **Function Extraction**: Complex expressions are extracted into helper functions
- **Global Variables**: Function parameters and returns are converted to global variables
- **Y-Coordinate Flipping**: Vertex shader output Y-coordinates are flipped for graphics API compatibility
- **Variable Renaming**: Variables are renamed with systematic naming (`_e19`, `global_1`, etc.)
- **Expression Simplification**: Complex expressions are broken down into simpler operations

## Use Cases

- **Testing Roundtrip Compatibility**: Verify that WGSL shaders survive the WGSL → SPIR-V → WGSL roundtrip
- **Debugging Compilation Issues**: See how your WGSL code is transformed through the compilation pipeline
- **Code Analysis**: Compare original vs. roundtrip WGSL to understand transformations
- **Validation**: Ensure your WGSL code is valid and can be properly compiled
- **Learning**: Understand how high-level WGSL constructs map to lower-level representations

## Testing

The project includes a comprehensive test suite:

```bash
# Run all tests
./test_runner.sh

# Clean up test files
./test_runner.sh clean

# Show test help
./test_runner.sh help
```

Test coverage includes:
- Basic shaders (vertex, fragment, compute)
- Complex shaders with multiple features
- Error handling for invalid inputs
- CLI option validation
- Output file verification

## Error Handling

The tool provides detailed error messages for common issues:

- Invalid WGSL syntax
- Module validation failures
- SPIR-V generation errors
- File I/O errors
- Unsupported WGSL features

## Installation Script

Use the provided installation script for easy setup:

```bash
# Make script executable and run
chmod +x install.sh
./install.sh
```

This will:
- Build the release binary
- Create a symlink in `~/.local/bin/wgsl-roundtrip`
- Provide usage instructions

## Dependencies

- **naga**: The core shader translation library (v25.0.1)
- **clap**: Command-line argument parsing (v4.0+)

## Performance

The tool is optimized for performance:
- Release builds provide fast processing
- Efficient SPIR-V binary handling
- Minimal memory allocations

## License

This project uses the same license as the naga crate (MIT OR Apache-2.0).