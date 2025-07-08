@fragment 
fn test_optimization() -> @location(0) vec4<f32> {
    if false {
        return vec4<f32>(999f, 999f, 999f, 1f);
    }
    return vec4<f32>(0.5f, (5f / 5f), 0f, 1f);
}

@vertex 
fn test_vertex(@builtin(vertex_index) index: u32) -> @builtin(position) vec4<f32> {
    return vec4<f32>((f32(index) * 0.5f), 0f, 0f, 1f);
}

@compute @workgroup_size(1, 1, 1) 
fn test_compute(@builtin(global_invocation_id) id: vec3<u32>) {
    let result = (0.5f * f32(id.x));
    return;
}
