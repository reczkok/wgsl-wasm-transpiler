struct FragmentInput_fs_main {
    float4 position_1 : SV_Position;
};

typedef float2 ret_Constructarray3_float2_[3];
ret_Constructarray3_float2_ Constructarray3_float2_(float2 arg0, float2 arg1, float2 arg2) {
    float2 ret[3] = { arg0, arg1, arg2 };
    return ret;
}

float4 vs_main(uint vertex_index : SV_VertexID) : SV_Position
{
    float2 pos[3] = Constructarray3_float2_(float2(-1.0, -1.0), float2(3.0, -1.0), float2(-1.0, 3.0));

    float2 _e13 = pos[min(uint(vertex_index), 2u)];
    return float4(_e13, 0.0, 1.0);
}

float4 fs_main(FragmentInput_fs_main fragmentinput_fs_main) : SV_Target0
{
    float4 position = fragmentinput_fs_main.position_1;
    float2 uv = (position.xy / float2(800.0, 600.0));
    float3 color = float3(uv.x, uv.y, 0.5);
    return float4(color, 1.0);
}

[numthreads(8, 8, 1)]
void cs_main(uint3 global_id : SV_DispatchThreadID)
{
    uint index = (global_id.x + (global_id.y * 64u));
    return;
}
