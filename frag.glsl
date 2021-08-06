#version 300 es

precision highp float;

out vec4 outColor;

uniform vec2 u_resolution;

void main() {
    // Normalized coordinates from 0 to 1
    vec2 uv = gl_FragCoord.xy / u_resolution;

    outColor = vec4(uv.x, uv.y, 0.0, 1.0);
}