shader_type canvas_item;
uniform float motion : hint_range(0.0,1.0) = 1.0;
uniform float shop : hint_range(0.0,1.0) = 0.0;
void fragment() {
 vec2 uv=floor(UV*vec2(480.0,300.0))/vec2(480.0,300.0);
 vec2 p=uv*vec2(1.6,1.0);
 float t=TIME*0.015*motion;
 vec2 a=p-vec2(0.7,-0.72);
 float bend=sin(atan(a.y,a.x)*2.2+t)*0.15;
 float bands=sin((length(a)+bend)*14.0+t);
 vec3 base=mix(vec3(0.045,0.115,0.145),vec3(0.09,0.235,0.215),smoothstep(1.1,0.0,distance(p,vec2(1.15,0.65))));
 base+=floor(smoothstep(-0.5,0.5,bands)*3.0)*0.006;
 base=mix(base,base*vec3(1.12,0.98,0.90),shop*0.55);
 base=floor(base*60.0)/60.0;
 float vignette=1.0-smoothstep(0.4,1.1,length((uv-0.5)*vec2(1.1,0.9)))*0.18;
 COLOR=vec4(base*vignette,1.0);
}
