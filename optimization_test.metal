// language: metal2.0
#include <metal_stdlib>
#include <simd/simd.h>

using metal::uint;


struct test_optimizationOutput {
    metal::float4 member [[color(0)]];
};
fragment test_optimizationOutput test_optimization(
) {
    if (false) {
        return test_optimizationOutput { metal::float4(999.0, 999.0, 999.0, 1.0) };
    }
    return test_optimizationOutput { metal::float4(0.5, 5.0 / 5.0, 0.0, 1.0) };
}


struct test_vertexInput {
};
struct test_vertexOutput {
    metal::float4 member_1 [[position]];
};
vertex test_vertexOutput test_vertex(
  uint index [[vertex_id]]
) {
    return test_vertexOutput { metal::float4(static_cast<float>(index) * 0.5, 0.0, 0.0, 1.0) };
}


struct test_computeInput {
};
kernel void test_compute(
  metal::uint3 id [[thread_position_in_grid]]
) {
    float result = 0.5 * static_cast<float>(id.x);
    return;
}
