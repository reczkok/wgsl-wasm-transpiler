#version 330 core

void main() {
    uint vertex_index = uint(gl_VertexID);
    vec2 pos[3] = vec2[3](vec2(-1.0, -1.0), vec2(1.0, -1.0), vec2(0.0, 1.0));
    vec2 _e13 = pos[vertex_index];
    gl_Position = vec4(_e13, 0.0, 1.0);
    return;
}

