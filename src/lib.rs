use std::collections::BTreeMap;

#[cfg(feature = "wasm")]
use wasm_bindgen::prelude::*;
#[cfg(feature = "wasm")]
use base64::prelude::*;

use naga::back::{glsl, hlsl, msl, spv, wgsl};
use naga::front::wgsl as front_wgsl;
use naga::valid::{Capabilities, ValidationFlags, Validator};

#[cfg(feature = "wasm")]
#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

#[derive(Debug, Clone)]
pub enum OutputFormat {
    Wgsl,
    Spirv,
    Glsl,
    Hlsl,
    Metal,
}

impl From<&str> for OutputFormat {
    fn from(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "wgsl" => OutputFormat::Wgsl,
            "spirv" => OutputFormat::Spirv,
            "glsl" => OutputFormat::Glsl,
            "hlsl" => OutputFormat::Hlsl,
            "metal" => OutputFormat::Metal,
            _ => OutputFormat::Wgsl,
        }
    }
}

pub fn compile_shader_core(
    wgsl_source: &str,
    format: &OutputFormat,
) -> Result<Vec<u8>, String> {
    // Parse WGSL
    let module = front_wgsl::parse_str(wgsl_source)
        .map_err(|e| format!("Failed to parse WGSL: {}", e))?;

    // Validate
    let module_info = Validator::new(ValidationFlags::all(), Capabilities::all())
        .validate(&module)
        .map_err(|e| format!("Validation failed: {}", e))?;

    // Generate output
    match format {
        OutputFormat::Wgsl => {
            let output = generate_wgsl(&module, &module_info)?;
            Ok(output.into_bytes())
        }
        OutputFormat::Spirv => generate_spirv(&module, &module_info),
        OutputFormat::Glsl => {
            let output = generate_glsl(&module, &module_info)?;
            Ok(output.into_bytes())
        }
        OutputFormat::Hlsl => {
            let output = generate_hlsl(&module, &module_info)?;
            Ok(output.into_bytes())
        }
        OutputFormat::Metal => {
            let output = generate_metal(&module, &module_info)?;
            Ok(output.into_bytes())
        }
    }
}

#[cfg(feature = "wasm")]
#[wasm_bindgen]
pub fn compile_shader(wgsl_source: &str, format: &str) -> Result<String, JsValue> {
    console_error_panic_hook::set_once();

    let output_format = OutputFormat::from(format);

    match compile_shader_core(wgsl_source, &output_format) {
        Ok(bytes) => {
            match output_format {
                OutputFormat::Spirv => {
                    // For SPIR-V, return base64 encoded binary
                    Ok(BASE64_STANDARD.encode(&bytes))
                }
                _ => {
                    // For text formats, convert bytes to string
                    String::from_utf8(bytes)
                        .map_err(|e| JsValue::from_str(&format!("UTF-8 conversion error: {}", e)))
                }
            }
        }
        Err(e) => Err(JsValue::from_str(&e)),
    }
}

#[cfg(feature = "wasm")]
#[wasm_bindgen]
pub fn get_supported_formats() -> js_sys::Array {
    let formats = js_sys::Array::new();
    formats.push(&JsValue::from_str("wgsl"));
    formats.push(&JsValue::from_str("spirv"));
    formats.push(&JsValue::from_str("glsl"));
    formats.push(&JsValue::from_str("hlsl"));
    formats.push(&JsValue::from_str("metal"));
    formats
}

#[cfg(feature = "wasm")]
#[wasm_bindgen]
pub fn init() {
    console_error_panic_hook::set_once();
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
        binding_map: BTreeMap::new(),
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

    let options = glsl::Options {
        version: glsl::Version::Desktop(330),
        writer_flags: glsl::WriterFlags::empty(),
        binding_map: BTreeMap::new(),
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
        per_entry_point_map: BTreeMap::new(),
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



// Re-export the main function for CLI use
#[cfg(feature = "cli")]
pub use compile_shader_core as compile_shader_cli;
