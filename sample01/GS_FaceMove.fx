
float4x4 tW : WORLD;
float4x4 tVP : VIEWPROJECTION;
float4x4 tWVP : WORLDVIEWPROJECTION;
float4x4 tWV : WORLDVIEW;

struct VS_IN
{
	float4 pos : POSITION;
	float3 norm : NORMAL;

};

struct vs2gs
{
    float4 pos: POSITION;
    
};

struct PS_IN
{
    float4 pos: SV_POSITION;
	float4 norm : COLOR0;
};

vs2gs VS(VS_IN input)
{
    vs2gs output;
    output.pos  = input.pos;
    return output;
}

PS_IN VS_VNorm(VS_IN input)
{
	//Standard displat, so transform as we would usually do
	PS_IN output;
	output.pos = mul(input.pos,tWVP);
	
	float3 normv = mul(float4(input.norm,0),tWV).xyz;
	output.norm = float4(normalize(normv),1);
    return output;
}
float f;
float3 location;
float FallOffDistance;
int pattern;
[maxvertexcount(3)]
void GS(triangle vs2gs input[3], inout TriangleStream<PS_IN> gsout)
{
	PS_IN o;
	
	//Get triangle face direction
	float3 f1 = input[1].pos.xyz - input[0].pos.xyz;
    float3 f2 = input[2].pos.xyz - input[0].pos.xyz;
    
	//Compute flat normal
	float3 norm = normalize(cross(f1, f2));
	
	//Convert into view space
	float3 normv = mul(float4(norm,0),tWV).xyz;
	normv = normalize(normv);
	
	o.norm = float4(normalize(normv),1);
	float Intensity =0;
	if(pattern==0){
		float d =sin(20*distance(normv,location))*sin(20*distance(normv,location))+cos(20*distance(normv,location));
		Intensity = 1 - saturate(d / FallOffDistance);
		}else if(pattern==1){
			float d =distance(normv,location);
			Intensity =sin( 20*(1 - saturate(d / FallOffDistance)))*cos( 20*(1 - saturate(d / FallOffDistance)));
			
		}
	//Transform trianglesd
	float4 moveDis = float4(normv*Intensity*f,1);
		
		
	
	o.pos = mul(input[0].pos+moveDis,tWVP);
	gsout.Append(o);
	
	o.pos = mul(input[1].pos+moveDis,tWVP);
	gsout.Append(o);
	
	o.pos = mul(input[2].pos+moveDis,tWVP);
	gsout.Append(o);
}

float4 PS(PS_IN input): SV_Target
{
	/*Set normals range form -1 to 1 to 0 -> 1
	for friendly display */
    return float4(1,1,1,1);
}




technique10 MoveFaces
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




