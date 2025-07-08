float4 test_optimization() : SV_Target0
{
    if (false) {
        return float4(999.0, 999.0, 999.0, 1.0);
    }
    return float4(0.5, (5.0 / 5.0), 0.0, 1.0);
}

float4 test_vertex(uint index : SV_VertexID) : SV_Position
{
    return float4((float(index) * 0.5), 0.0, 0.0, 1.0);
}

[numthreads(1, 1, 1)]
void test_compute(uint3 id : SV_DispatchThreadID)
{
    float result = (0.5 * float(id.x));
    return;
}
