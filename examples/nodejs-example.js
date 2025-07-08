const { compile_shader, get_supported_formats, init } = require(
  "../pkg-nodejs/wgsl_analysis.js",
);

// Initialize the WebAssembly module
init();

// Example WGSL shader code
const wgslCode = `
@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> @builtin(position) vec4<f32> {
    var pos = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>( 1.0, -1.0),
        vec2<f32>( 0.0,  1.0)
    );
    return vec4<f32>(pos[vertex_index], 0.0, 1.0);
}

@fragment
fn fs_main() -> @location(0) vec4<f32> {
    return vec4<f32>(1.0, 0.0, 0.0, 1.0);
}
`;

async function demonstrateCompilation() {
  console.log("WGSL Analysis Tool - Node.js Example");
  console.log("=====================================\n");

  // Get supported formats
  const formats = get_supported_formats();
  console.log("Supported output formats:", formats);
  console.log("");

  // Input shader
  console.log("Input WGSL Shader:");
  console.log(wgslCode);
  console.log("");

  // Compile to different formats
  const outputFormats = ["wgsl", "glsl", "hlsl", "metal", "spirv"];

  for (const format of outputFormats) {
    console.log(`\n--- Compiling to ${format.toUpperCase()} ---`);

    try {
      const result = compile_shader(wgslCode, format);

      if (format === "spirv") {
        console.log(`SPIR-V Binary (Base64): ${result.substring(0, 100)}...`);
        console.log(`Full length: ${result.length} characters`);
      } else {
        console.log(`${format.toUpperCase()} Output:`);
        console.log(result);
      }

      console.log("✓ Compilation successful!");
    } catch (error) {
      console.error("✗ Compilation failed:", error.message);
    }
  }
}

// Function to compile from command line arguments
function compileFromArgs() {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log("Usage: node nodejs-example.js <input-file> <output-format>");
    console.log("Available formats: wgsl, glsl, hlsl, metal, spirv");
    return;
  }

  const inputFile = args[0];
  const outputFormat = args[1];

  const fs = require("fs");

  try {
    const wgslContent = fs.readFileSync(inputFile, "utf8");
    const result = compile_shader(wgslContent, outputFormat);

    // Write to output file
    const outputFile = inputFile.replace(
      /\.[^/.]+$/,
      `.${getExtension(outputFormat)}`,
    );

    if (outputFormat === "spirv") {
      // For SPIR-V, decode base64 and write binary
      const binaryData = Buffer.from(result, "base64");
      fs.writeFileSync(outputFile, binaryData);
    } else {
      fs.writeFileSync(outputFile, result);
    }

    console.log(`✓ Compiled '${inputFile}' to '${outputFile}'`);
  } catch (error) {
    console.error("✗ Error:", error.message);
    process.exit(1);
  }
}

function getExtension(format) {
  switch (format) {
    case "wgsl":
      return "wgsl";
    case "spirv":
      return "spv";
    case "glsl":
      return "glsl";
    case "hlsl":
      return "hlsl";
    case "metal":
      return "metal";
    default:
      return "out";
  }
}

// Run the demonstration
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length >= 2) {
    compileFromArgs();
  } else {
    demonstrateCompilation();
  }
}

module.exports = {
  compile_shader,
  get_supported_formats,
  init,
};
