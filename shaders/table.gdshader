shader_type canvas_item;
uniform float motion : hint_range(0.0,1.0) = 1.0;
uniform float shop : hint_range(0.0,1.0) = 0.0;
void fragment() {
 vec2 uv=floor(UV*vec2(480.0,300.0))/vec2(480.0,300.0);
 vec2 p=uv*vec2(1.6,1.0);
 float t=TIME*0.023*motion;
 vec2 a=p-vec2(0.7,-0.72);
 float bend=sin(atan(a.y,a.x)*2.2+t)*0.15;
 float bands=sin((length(a)+bend)*14.0+t);
 float broad=sin((p.x*0.5+p.y)*6.0+sin(p.x*4.0-t));
 vec3 base=mix(vec3(0.055,0.16,0.205),vec3(0.135,0.31,0.30),smoothstep(1.1,0.0,distance(p,vec2(1.15,0.65))));
 base+=floor(smoothstep(-0.5,0.5,bands)*4.0)*0.014+broad*0.012;
 vec3 warm=mix(vec3(0.13,0.15,0.20),vec3(0.30,0.23,0.16),floor((bands*.5+.5)*5.0)/5.0);
 base=mix(base,warm,shop*.8);
 float dither=mod(floor(uv.x*480.0)+floor(uv.y*300.0),2.0);
 base+=dither*0.006;
 base=floor(base*40.0)/40.0;
 float vignette=1.0-smoothstep(0.4,1.1,length((uv-0.5)*vec2(1.1,0.9)))*0.3;
 COLOR=vec4(base*vignette,1.0);
}
