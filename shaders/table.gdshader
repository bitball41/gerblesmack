shader_type canvas_item;
uniform float motion : hint_range(0.0,1.0) = 1.0;
void fragment() {
 vec2 p=UV*vec2(1.6,1.0);
 float t=TIME*0.012*motion;
 vec2 a=p-vec2(0.7,-0.72);
 float bend=sin(atan(a.y,a.x)*2.2+t)*0.15;
 float bands=sin((length(a)+bend)*14.0+t);
 float broad=sin((p.x*0.5+p.y)*6.0+sin(p.x*4.0-t));
 vec3 base=mix(vec3(0.055,0.16,0.205),vec3(0.135,0.31,0.30),smoothstep(1.1,0.0,distance(p,vec2(1.15,0.65))));
 base+=smoothstep(-0.15,0.25,bands)*0.038+broad*0.012;
 float grain=fract(sin(dot(FRAGCOORD.xy,vec2(12.9898,78.233)))*43758.5453)-0.5;
 base+=grain*0.014;
 float vignette=1.0-smoothstep(0.4,1.1,length((UV-0.5)*vec2(1.1,0.9)))*0.3;
 COLOR=vec4(base*vignette,1.0);
}
