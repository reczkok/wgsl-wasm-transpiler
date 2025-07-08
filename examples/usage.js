/**
 * WGSL Analysis Tool - JavaScript Usage Examples
 *
 * This file demonstrates how to use the WGSL Analysis Tool WebAssembly module
 * in various JavaScript environments (Node.js, browsers, bundlers).
 */

// ===============================
// Node.js Usage Example
// ===============================

function nodeJsExample() {
  console.log("=== Node.js Usage Example ===");

  // Import the WebAssembly module
  const { compile_shader, get_supported_formats, init } = require(
    "../pkg-nodejs/wgsl_analysis.js",
  );

  // Initialize the WebAssembly module
  init();

  // Example WGSL shader
  const wgslShader = `
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

  // Get supported formats
  const formats = get_supported_formats();
  console.log("Supported formats:", formats);

  // Compile to different formats
  try {
    // Compile to GLSL
    const glslCode = compile_shader(wgslShader, "glsl");
    console.log("\nGLSL Output:");
    console.log(glslCode);

    // Compile to HLSL
    const hlslCode = compile_shader(wgslShader, "hlsl");
    console.log("\nHLSL Output:");
    console.log(hlslCode);

    // Compile to Metal
    const metalCode = compile_shader(wgslShader, "metal");
    console.log("\nMetal Output:");
    console.log(metalCode);

    // Compile to SPIR-V (returns base64 encoded binary)
    const spirvCode = compile_shader(wgslShader, "spirv");
    console.log("\nSPIR-V Output (Base64):");
    console.log(spirvCode.substring(0, 100) + "...");
  } catch (error) {
    console.error("Compilation error:", error.message);
  }
}

// ===============================
// Browser Usage Example (ES6 Modules)
// ===============================

const browserExample = `
// For use in browsers with ES6 modules
import init, { compile_shader, get_supported_formats } from './pkg/wgsl_analysis.js';

async function initializeWGSLTool() {
    // Initialize the WebAssembly module
    await init();

    // Example usage
    const wgslCode = \`
        @fragment
        fn main() -> @location(0) vec4<f32> {
            return vec4<f32>(1.0, 0.0, 0.0, 1.0);
        }
    \`;

    try {
        const glslOutput = compile_shader(wgslCode, 'glsl');
        console.log('GLSL Output:', glslOutput);

        const formats = get_supported_formats();
        console.log('Supported formats:', formats);
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Call the initialization function
initializeWGSLTool();
`;

// ===============================
// Bundler Usage Example (Webpack, Vite, etc.)
// ===============================

const bundlerExample = `
// For use with bundlers like Webpack, Vite, Parcel, etc.
import { compile_shader, get_supported_formats } from './pkg-bundler/wgsl_analysis.js';

// Note: With bundlers, the WASM module is typically auto-initialized

class WGSLCompiler {
    constructor() {
        this.formats = get_supported_formats();
    }

    compile(wgslCode, outputFormat) {
        if (!this.formats.includes(outputFormat)) {
            throw new Error(\`Unsupported format: \${outputFormat}\`);
        }

        try {
            return compile_shader(wgslCode, outputFormat);
        } catch (error) {
            throw new Error(\`Compilation failed: \${error.message}\`);
        }
    }

    getSupportedFormats() {
        return [...this.formats];
    }
}

// Usage
const compiler = new WGSLCompiler();
const result = compiler.compile(wgslCode, 'glsl');
`;

// ===============================
// TypeScript Usage Example
// ===============================

const typescriptExample = `
// TypeScript usage with proper type definitions
import { compile_shader, get_supported_formats } from './pkg-bundler/wgsl_analysis.js';

// Define types
type OutputFormat = 'wgsl' | 'spirv' | 'glsl' | 'hlsl' | 'metal';

interface CompilationResult {
    format: OutputFormat;
    code: string;
    success: boolean;
    error?: string;
}

class TypedWGSLCompiler {
    private supportedFormats: OutputFormat[];

    constructor() {
        this.supportedFormats = get_supported_formats() as OutputFormat[];
    }

    compile(wgslCode: string, outputFormat: OutputFormat): CompilationResult {
        if (!this.supportedFormats.includes(outputFormat)) {
            return {
                format: outputFormat,
                code: '',
                success: false,
                error: \`Unsupported format: \${outputFormat}\`
            };
        }

        try {
            const code = compile_shader(wgslCode, outputFormat);
            return {
                format: outputFormat,
                code,
                success: true
            };
        } catch (error) {
            return {
                format: outputFormat,
                code: '',
                success: false,
                error: error instanceof Error ? error.message : String(error)
            };
        }
    }

    getSupportedFormats(): OutputFormat[] {
        return [...this.supportedFormats];
    }
}

// Usage
const compiler = new TypedWGSLCompiler();
const result = compiler.compile(wgslCode, 'glsl');
if (result.success) {
    console.log('Compilation successful:', result.code);
} else {
    console.error('Compilation failed:', result.error);
}
`;

// ===============================
// Advanced Usage Examples
// ===============================

function advancedExamples() {
  console.log("\n=== Advanced Usage Examples ===");

  const { compile_shader, init } = require("../pkg-nodejs/wgsl_analysis.js");
  init();

  // Example 1: Batch compilation
  const batchCompile = (wgslCode, formats) => {
    const results = {};

    for (const format of formats) {
      try {
        results[format] = {
          success: true,
          code: compile_shader(wgslCode, format),
        };
      } catch (error) {
        results[format] = {
          success: false,
          error: error.message,
        };
      }
    }

    return results;
  };

  // Example 2: Validation function
  const validateWGSL = (wgslCode) => {
    try {
      compile_shader(wgslCode, "wgsl");
      return { valid: true };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  };

  // Example 3: Cross-platform shader generation
  const generateCrossPlatformShaders = (wgslCode) => {
    const platforms = {
      webgpu: "wgsl",
      opengl: "glsl",
      directx: "hlsl",
      metal: "metal",
      vulkan: "spirv",
    };

    const shaders = {};

    for (const [platform, format] of Object.entries(platforms)) {
      try {
        shaders[platform] = compile_shader(wgslCode, format);
      } catch (error) {
        console.warn(`Failed to compile for ${platform}:`, error.message);
      }
    }

    return shaders;
  };

  // Test the advanced examples
  const testShader = `
        @fragment
        fn main() -> @location(0) vec4<f32> {
            return vec4<f32>(1.0, 0.0, 0.0, 1.0);
        }
    `;

  console.log("Validation result:", validateWGSL(testShader));

  const batchResults = batchCompile(testShader, ["glsl", "hlsl", "metal"]);
  console.log("Batch compilation results:", Object.keys(batchResults));

  const crossPlatformShaders = generateCrossPlatformShaders(testShader);
  console.log(
    "Cross-platform shaders generated for:",
    Object.keys(crossPlatformShaders),
  );
}

// ===============================
// Error Handling Examples
// ===============================

function errorHandlingExamples() {
  console.log("\n=== Error Handling Examples ===");

  const { compile_shader, init } = require("../pkg-nodejs/wgsl_analysis.js");
  init();

  // Example 1: Invalid WGSL syntax
  const invalidWGSL = `
        @fragment
        fn main() -> @location(0) vec4<f32> {
            return invalid_function();
        }
    `;

  try {
    compile_shader(invalidWGSL, "glsl");
  } catch (error) {
    const errorMessage = error && error.message ? error.message : String(error);
    console.log("Caught syntax error:", errorMessage);
  }

  // Example 2: Comprehensive error handling
  const safeCompile = (wgslCode, format) => {
    try {
      const result = compile_shader(wgslCode, format);
      return {
        success: true,
        data: result,
        format: format,
      };
    } catch (error) {
      // Parse error message for better user feedback
      let errorType = "Unknown";
      const errorMessage = error && error.message
        ? error.message
        : String(error);

      if (errorMessage.includes("parse")) {
        errorType = "Syntax Error";
      } else if (errorMessage.includes("validation")) {
        errorType = "Validation Error";
      } else if (errorMessage.includes("generate")) {
        errorType = "Code Generation Error";
      }

      return {
        success: false,
        error: {
          type: errorType,
          message: errorMessage,
          format: format,
        },
      };
    }
  };

  const result = safeCompile(invalidWGSL, "glsl");
  console.log("Safe compilation result:", result);
}

// ===============================
// Performance Examples
// ===============================

function performanceExamples() {
  console.log("\n=== Performance Examples ===");

  const { compile_shader, init } = require("../pkg-nodejs/wgsl_analysis.js");
  init();

  const testShader = `
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

  // Benchmark compilation
  const benchmark = (iterations = 100) => {
    const results = {};
    const formats = ["glsl", "hlsl", "metal", "spirv"];

    for (const format of formats) {
      const start = process.hrtime.bigint();

      for (let i = 0; i < iterations; i++) {
        compile_shader(testShader, format);
      }

      const end = process.hrtime.bigint();
      const duration = Number(end - start) / 1000000; // Convert to milliseconds

      results[format] = {
        totalTime: duration,
        averageTime: duration / iterations,
        iterations: iterations,
      };
    }

    return results;
  };

  console.log("Performance benchmark results:");
  const benchmarkResults = benchmark(10);
  for (const [format, stats] of Object.entries(benchmarkResults)) {
    console.log(
      `${format}: ${
        stats.averageTime.toFixed(2)
      }ms avg (${stats.iterations} iterations)`,
    );
  }
}

// Run examples if this file is executed directly
if (require.main === module) {
  nodeJsExample();
  advancedExamples();
  errorHandlingExamples();
  performanceExamples();

  console.log("\n=== Browser and Bundler Examples ===");
  console.log("// Browser usage:");
  console.log(browserExample);

  console.log("\n// Bundler usage:");
  console.log(bundlerExample);

  console.log("\n// TypeScript usage:");
  console.log(typescriptExample);
}

// Export for use in other modules
module.exports = {
  nodeJsExample,
  advancedExamples,
  errorHandlingExamples,
  performanceExamples,
  browserExample,
  bundlerExample,
  typescriptExample,
};
