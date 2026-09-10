#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1);

void main()
{
    fs_Col = vs_Col;

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    float t = u_Time * 0.04;
    vec3 p = vs_Pos.xyz;
    vec3 wave = vec3(sin(dot(p, vec3(2.0, 1.5, 1.0)) - t),
                     sin(dot(p, vec3(-1.0, 2.5, 2.0)) - t * 1.7),
                     sin(dot(p, vec3(3.0, -1.0, 2.5)) - t * 2.3));
    vec4 displaced = vs_Pos + vec4(wave * 0.06, 0.0);

    vec4 modelposition = u_Model * displaced;
    fs_Pos = modelposition;
    fs_LightVec = lightPos - modelposition;

    gl_Position = u_ViewProj * modelposition;
}
