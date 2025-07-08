@vertex 
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> @builtin(position) vec4<f32> {
    var pos: array<vec2<f32>, 3> = array<vec2<f32>, 3>(vec2<f32>(-1f, -1f), vec2<f32>(3f, -1f), vec2<f32>(-1f, 3f));

    let _e13 = pos[vertex_index];
    return vec4<f32>(_e13, 0f, 1f);
}

@fragment 
fn fs_main(@builtin(position) position: vec4<f32>) -> @location(0) vec4<f32> {
    let uv = (position.xy / vec2<f32>(800f, 600f));
    let color = vec3<f32>(uv.x, uv.y, 0.5f);
    return vec4<f32>(color, 1f);
}

@compute @workgroup_size(8, 8, 1) 
fn cs_main(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let index = (global_id.x + (global_id.y * 64u));
    return;
}
