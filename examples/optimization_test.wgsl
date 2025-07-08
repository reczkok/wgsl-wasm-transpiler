@fragment
fn test_optimization() -> @location(0) vec4<f32> {
    // Test complex constant expression optimization
    let result = f32(1.0) / f32(u32(f32(2.0)));

    // Test simple arithmetic
    let simple = 2.0 + 3.0;

    // Test dead code branch
    if (false) {
        return vec4<f32>(999.0, 999.0, 999.0, 1.0);
    }

    return vec4<f32>(result, simple / 5.0, 0.0, 1.0);
}

@vertex
fn test_vertex(@builtin(vertex_index) index: u32) -> @builtin(position) vec4<f32> {
    // Test constant folding in vertex shader
    let optimized = f32(1.0) / f32(u32(f32(2.0)));
    return vec4<f32>(f32(index) * optimized, 0.0, 0.0, 1.0);
}

@compute @workgroup_size(1, 1, 1)
fn test_compute(@builtin(global_invocation_id) id: vec3<u32>) {
    // Test optimization in compute context
    let value = f32(1.0) / f32(u32(f32(2.0)));

    // This would write to a buffer in a real shader
    let result = value * f32(id.x);
}
