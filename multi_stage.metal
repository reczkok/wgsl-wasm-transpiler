// language: metal2.0
#include <metal_stdlib>
#include <simd/simd.h>

using metal::uint;

struct type_3 {
    metal::float2 inner[3];
};

struct vs_mainInput {
};
struct vs_mainOutput {
    metal::float4 member [[position]];
};
vertex vs_mainOutput vs_main(
  uint vertex_index [[vertex_id]]
) {
    type_3 pos = type_3 {metal::float2(-1.0, -1.0), metal::float2(3.0, -1.0), metal::float2(-1.0, 3.0)};
    metal::float2 _e13 = pos.inner[vertex_index];
    return vs_mainOutput { metal::float4(_e13, 0.0, 1.0) };
}


struct fs_mainInput {
};
struct fs_mainOutput {
    metal::float4 member_1 [[color(0)]];
};
fragment fs_mainOutput fs_main(
  metal::float4 position [[position]]
) {
    metal::float2 uv = position.xy / metal::float2(800.0, 600.0);
    metal::float3 color = metal::float3(uv.x, uv.y, 0.5);
    return fs_mainOutput { metal::float4(color, 1.0) };
}


struct cs_mainInput {
};
kernel void cs_main(
  metal::uint3 global_id [[thread_position_in_grid]]
) {
    uint index = global_id.x + (global_id.y * 64u);
    return;
}
