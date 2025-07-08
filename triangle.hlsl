typedef float2 ret_Constructarray3_float2_[3];
ret_Constructarray3_float2_ Constructarray3_float2_(float2 arg0, float2 arg1, float2 arg2) {
    float2 ret[3] = { arg0, arg1, arg2 };
    return ret;
}

float4 vs_main(uint vertex_index : SV_VertexID) : SV_Position
{
    float2 pos[3] = Constructarray3_float2_(float2(-1.0, -1.0), float2(1.0, -1.0), float2(0.0, 1.0));

    float2 _e13 = pos[min(uint(vertex_index), 2u)];
    return float4(_e13, 0.0, 1.0);
}

float4 fs_main() : SV_Target0
{
    return float4(1.0, 0.0, 0.0, 1.0);
}
