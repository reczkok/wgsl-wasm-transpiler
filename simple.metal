// language: metal2.0
#include <metal_stdlib>
#include <simd/simd.h>

using metal::uint;


struct main_Output {
    metal::float4 member [[color(0)]];
};
fragment main_Output main_(
) {
    return main_Output { metal::float4(1.0, 0.0, 0.0, 1.0) };
}
