// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//-----------------------------------------------------
// Deferred screen space decal includes. Version 0.9 [Beta]
// Copyright (c) 2016 by Sycoforge
//-----------------------------------------------------

#ifndef DSSD_SYCO_CG_INCLUDED
#define DSSD_SYCO_CG_INCLUDED

#include "UnityCG.cginc"
#include "Util.cginc"
#include "SycoSSD.cginc"	

uniform sampler2D _BumpMap;
uniform sampler2D _NormalBuffer;

//-------------------------
// Deferred SSD
//-------------------------

#define SETUP_DSSD_DIFF(input,o) \
	SETUP_BASIC_SSD(input,o) \
	o.orientation[0] = V_RIGHT; \
	o.orientation[1] = mul ((float3x3)unity_ObjectToWorld, V_UP); \
	o.orientation[2] = V_FORWARD;

#define SETUP_DSSD_DIFF_NORM(input,o) \
	SETUP_BASIC_SSD(input,o) \
	o.orientation[0] = mul ((float3x3)unity_ObjectToWorld, V_RIGHT); \
	o.orientation[1] = mul ((float3x3)unity_ObjectToWorld, V_UP); \
	o.orientation[2] = mul ((float3x3)unity_ObjectToWorld, V_FORWARD);

#define DSSD_RAW_WORLD_NORMAL(uv) tex2D(_NormalBuffer, uv)

#define DSSD_DECODE_WORLD_NORMAL(rgb) rgb * 2.0f - 1.0f 

#define DSSD_DISCARD_WORLD_NORMAL(worldNormal, input) \
	float c = dot(worldNormal, input.orientation[1]); \
	clip(c - input.normal.x)

#define DSSD_DISCARD_BUFFER_MASK(mask) clip((mask).w - 0.1f)

#define DSSD_DISCARD_ALPHA(color) clip((color).a - 0.25f)

#define DSSD_DISCARD_MASK(color) clip((color).a - 0.25f)

#define DSSD_DISCARD_BORDER(uv) \
	fixed2 uv2 = uv.xz + 0.5f; \
	fixed2 pixelSize = (_ScreenParams.zw - 1.0f)*2; \
	clip(uv2 - pixelSize); \
	clip(uv2 + pixelSize > 1.0f ? -1 : 1)

#define WRITE_ATLAS_NORMALS_LERP(tex, st, input, localPos, worldNormal, output) \
	fixed3 n = UnpackNormal(tex2D((tex), ATLAS_TEXCOORDS((input), (st), (localPos)))); \
	half3x3 norMat = half3x3((input).orientation[0], (input).orientation[2], (input).orientation[1]); \
	n = mul(n, norMat); \
	fixed fac = abs(dot(worldNormal, n)); \
	n = lerp(worldNormal, n, fac); \
	output = fixed4(n * 0.5f + 0.5f, 1.0f)

#define WRITE_ATLAS_NORMALS(tex, st, input, localPos, worldNormal, output) \
	fixed3 n = UnpackNormal(tex2D((tex), ATLAS_TEXCOORDS((input), (st), (localPos)))); \
	half3x3 norMat = half3x3((input).orientation[0], (input).orientation[2], (input).orientation[1]); \
	n = mul(n, norMat); \
	n = worldNormal + n; \
	output = fixed4(n * 0.5f + 0.5f, 1.0f)

#define WRITE_ATLAS_DIFFUSE(tex, st, input, localPos, color, output) color = ATLAS_TEX2D((tex), (st), (input), (localPos)); color.a *= (input.color.a); output = color;

FragmentInputDSSD vert(VertexInput input)
{
	FragmentInputDSSD o;

	SETUP_DSSD_DIFF_NORM(input,o)

	return o;
}

void frag(FragmentInputDSSD input
#ifdef _DIFFUSE 
, out half4 outDiffuse : COLOR0
#endif

#ifdef _NORMALMAP
, out half4 outNormal

// Semantic switch
#ifndef _DIFFUSE 
: COLOR0
#else
: COLOR1
#endif

#endif
		
) 
{
	fixed4 color = fixed4(0.0f, 0.0f, 0.0f, 1.0f);
	float3 localPos;

	PROCESS_BASIC_SSD(input, localPos);

	fixed4 rawWorldNormal = DSSD_RAW_WORLD_NORMAL(uv);
	fixed3 worldNormal = DSSD_DECODE_WORLD_NORMAL(rawWorldNormal);

	DSSD_DISCARD_BUFFER_MASK(rawWorldNormal);

	#ifdef _DIFFUSE
	WRITE_ATLAS_DIFFUSE(_MainTex, _MainTex_ST, input, localPos, color, outDiffuse);
	#endif

	DSSD_DISCARD_WORLD_NORMAL(worldNormal, input);

	#ifdef _DIFFUSE
	DSSD_DISCARD_ALPHA(color);
	#endif

	DSSD_DISCARD_BORDER(localPos);

	#ifdef _NORMALMAP
	WRITE_ATLAS_NORMALS(_BumpMap, _MainTex_ST, input, localPos, worldNormal, outNormal);
	#endif
}


#endif // DSSD_SYCO_CG_INCLUDED
