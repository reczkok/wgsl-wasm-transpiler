use clap::{Parser, ValueEnum};
use std::fs;
use std::path::Path;
use std::process;

use naga::back::{glsl, hlsl, msl, spv, wgsl};
use naga::front::wgsl as front_wgsl;
use naga::valid::{Capabilities, ValidationFlags, Validator};

#[derive(Debug, Clone, ValueEnum)]
enum OutputFormat {
    Wgsl,
    Spirv,
    Glsl,
    Hlsl,
    Metal,
}

#[derive(Parser)]
#[command(
    name = "wgsl-tool",
    version = "1.0.0",
    about = "A tool to compile WGSL shaders to various output formats"
)]
struct Args {
    /// Input WGSL file
    input: String,

    /// Output format
    #[arg(short, long, value_enum, default_value_t = OutputFormat::Wgsl)]
    format: OutputFormat,

    /// Output file (optional, defaults to input with appropriate extension)
    #[arg(short, long)]
    output: Option<String>,

    /// Verbose output
    #[arg(short, long)]
    verbose: bool,
}

fn main() {
    let args = Args::parse();

    if args.verbose {
        println!("Input: {}", args.input);
        println!("Format: {:?}", args.format);
    }

    let input_path = Path::new(&args.input);
    if !input_path.exists() {
        eprintln!("Error: Input file '{}' not found", args.input);
        process::exit(1);
    }

    let output_path = get_output_path(&args.input, &args.output, &args.format);

    match compile_shader(&args.input, &output_path, &args.format, args.verbose) {
        Ok(()) => {
            println!("✓ Compiled '{}' -> '{}'", args.input, output_path);
        }
        Err(e) => {
            eprintln!("✗ Error: {}", e);
            process::exit(1);
        }
    }
}

fn get_output_path(input: &str, output: &Option<String>, format: &OutputFormat) -> String {
    if let Some(output) = output {
        return output.clone();
    }

    let input_path = Path::new(input);
    let stem = input_path.file_stem().unwrap().to_str().unwrap();
    let extension = match format {
        OutputFormat::Wgsl => "wgsl",
        OutputFormat::Spirv => "spv",
        OutputFormat::Glsl => "glsl",
        OutputFormat::Hlsl => "hlsl",
        OutputFormat::Metal => "metal",
    };

    format!("{}.{}", stem, extension)
}

fn compile_shader(
    input_path: &str,
    output_path: &str,
    format: &OutputFormat,
    verbose: bool,
) -> Result<(), String> {
    // Read input
    if verbose {
        println!("Reading WGSL file...");
    }
    let wgsl_source = fs::read_to_string(input_path)
        .map_err(|e| format!("Failed to read input file: {}", e))?;

    // Parse WGSL
    if verbose {
        println!("Parsing WGSL...");
    }
    let module = front_wgsl::parse_str(&wgsl_source)
        .map_err(|e| format!("Failed to parse WGSL: {}", e))?;

    // Validate
    if verbose {
        println!("Validating module...");
    }
    let module_info = Validator::new(ValidationFlags::all(), Capabilities::all())
        .validate(&module)
        .map_err(|e| format!("Validation failed: {}", e))?;

    // Generate output
    if verbose {
        println!("Generating {:?} output...", format);
    }
    // Generate and write output
    if verbose {
        println!("Writing output...");
    }
    match format {
        OutputFormat::Wgsl => {
            let output = generate_wgsl(&module, &module_info)?;
            fs::write(output_path, output).map_err(|e| format!("Failed to write output: {}", e))?;
        }
        OutputFormat::Spirv => {
            let output = generate_spirv(&module, &module_info)?;
            fs::write(output_path, output).map_err(|e| format!("Failed to write output: {}", e))?;
        }
        OutputFormat::Glsl => {
            let output = generate_glsl(&module, &module_info)?;
            fs::write(output_path, output).map_err(|e| format!("Failed to write output: {}", e))?;
        }
        OutputFormat::Hlsl => {
            let output = generate_hlsl(&module, &module_info)?;
            fs::write(output_path, output).map_err(|e| format!("Failed to write output: {}", e))?;
        }
        OutputFormat::Metal => {
            let output = generate_metal(&module, &module_info)?;
            fs::write(output_path, output).map_err(|e| format!("Failed to write output: {}", e))?;
        }
    }

    Ok(())
}

fn generate_wgsl(module: &naga::Module, module_info: &naga::valid::ModuleInfo) -> Result<String, String> {
    let mut output = String::new();
    let mut writer = wgsl::Writer::new(&mut output, wgsl::WriterFlags::empty());
    writer.write(module, module_info)
        .map_err(|e| format!("Failed to generate WGSL: {}", e))?;
    Ok(output)
}

fn generate_spirv(module: &naga::Module, module_info: &naga::valid::ModuleInfo) -> Result<Vec<u8>, String> {
    let options = spv::Options {
        lang_version: (1, 0),
        flags: spv::WriterFlags::empty(),
        capabilities: None,
        bounds_check_policies: naga::proc::BoundsCheckPolicies::default(),
        zero_initialize_workgroup_memory: spv::ZeroInitializeWorkgroupMemoryMode::Native,
        binding_map: std::collections::BTreeMap::new(),
        debug_info: None,
        force_loop_bounding: true,
    };

    let mut writer = spv::Writer::new(&options)
        .map_err(|e| format!("Failed to create SPIR-V writer: {}", e))?;

    let mut spirv_binary = Vec::new();
    writer.write(module, module_info, None, &None, &mut spirv_binary)
        .map_err(|e| format!("Failed to generate SPIR-V: {}", e))?;

    // Convert u32 words to bytes
    let bytes = spirv_binary.iter()
        .flat_map(|&word| word.to_le_bytes().to_vec())
        .collect();

    Ok(bytes)
}

fn generate_glsl(module: &naga::Module, module_info: &naga::valid::ModuleInfo) -> Result<String, String> {
    let mut output = String::new();

    // For GLSL, we need to specify pipeline options
    let options = glsl::Options {
        version: glsl::Version::Desktop(330),
        writer_flags: glsl::WriterFlags::empty(),
        binding_map: std::collections::BTreeMap::new(),
        zero_initialize_workgroup_memory: true,
    };

    // Find the first entry point to use
    let entry_point = module.entry_points.iter().next()
        .ok_or("No entry points found in module")?;

    let pipeline_options = glsl::PipelineOptions {
        shader_stage: entry_point.stage,
        entry_point: entry_point.name.clone(),
        multiview: None,
    };

    let mut writer = glsl::Writer::new(
        &mut output,
        module,
        module_info,
        &options,
        &pipeline_options,
        naga::proc::BoundsCheckPolicies::default(),
    ).map_err(|e| format!("Failed to create GLSL writer: {}", e))?;

    writer.write()
        .map_err(|e| format!("Failed to generate GLSL: {}", e))?;

    Ok(output)
}

fn generate_hlsl(module: &naga::Module, module_info: &naga::valid::ModuleInfo) -> Result<String, String> {
    let mut output = String::new();

    let options = hlsl::Options::default();

    let mut writer = hlsl::Writer::new(&mut output, &options);
    writer.write(module, module_info, None)
        .map_err(|e| format!("Failed to generate HLSL: {}", e))?;

    Ok(output)
}

fn generate_metal(module: &naga::Module, module_info: &naga::valid::ModuleInfo) -> Result<String, String> {
    let mut output = String::new();

    let options = msl::Options {
        lang_version: (2, 0),
        per_entry_point_map: std::collections::BTreeMap::new(),
        inline_samplers: Vec::new(),
        spirv_cross_compatibility: false,
        fake_missing_bindings: false,
        bounds_check_policies: naga::proc::BoundsCheckPolicies::default(),
        zero_initialize_workgroup_memory: true,
        force_loop_bounding: true,
    };

    let pipeline_options = msl::PipelineOptions {
        allow_and_force_point_size: false,
        vertex_buffer_mappings: Vec::new(),
        vertex_pulling_transform: false,
    };

    let mut writer = msl::Writer::new(&mut output);
    writer.write(module, module_info, &options, &pipeline_options)
        .map_err(|e| format!("Failed to generate Metal: {}", e))?;

    Ok(output)
}
