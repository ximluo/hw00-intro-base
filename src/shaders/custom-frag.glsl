#version 300 es
precision highp float;

uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

vec3 hash3(vec3 p)
{
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453);
}

vec2 worley(vec3 p)
{
    vec3 cell = floor(p);
    vec3 f = fract(p);
    float f1 = 10.0;
    float f2 = 10.0;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            for (int z = -1; z <= 1; z++) {
                vec3 o = vec3(x, y, z);
                vec3 point = o + hash3(cell + o);
                float d = length(point - f);
                if (d < f1) {
                    f2 = f1;
                    f1 = d;
                } else if (d < f2) {
                    f2 = d;
                }
            }
        }
    }
    return vec2(f1, f2);
}

void main()
{
    vec3 drift = vec3(0.0, u_Time * 0.01, u_Time * 0.007);
    vec3 p = fs_Pos.xyz * 2.5 + drift;

    vec2 w1 = worley(p);
    vec2 w2 = worley(p * 2.0 + drift);
    float edge = (w1.y - w1.x) + 0.5 * (w2.y - w2.x);
    float caustic = 1.0 - smoothstep(0.0, 0.2, edge);
    float ripple = w1.x + 0.5 * w2.x;

    vec3 deep = u_Color.rgb * 0.6;
    vec3 shallow = u_Color.rgb * 1.2 + vec3(0.1, 0.25, 0.3);
    vec3 base = mix(deep, shallow, ripple);
    base += caustic * vec3(0.6, 0.85, 1.0);

    vec3 N = normalize(fs_Nor.xyz);
    vec3 L = normalize(fs_LightVec.xyz);
    vec3 V = normalize(-fs_Pos.xyz);
    float diffuse = max(dot(N, L), 0.0);
    float spec = pow(max(dot(reflect(-L, N), V), 0.0), 32.0);
    float light = diffuse + 0.25;

    out_Col = vec4(base * light + spec * 0.5, u_Color.a);
}
