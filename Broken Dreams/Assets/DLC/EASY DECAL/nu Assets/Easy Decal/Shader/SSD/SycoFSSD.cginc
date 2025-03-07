//-----------------------------------------------------
// Forward screen space decal includes. Version 0.8 [Beta]
// Copyright (c) 2016 by Sycoforge
//-----------------------------------------------------

#ifndef FSSD_SYCO_CG_INCLUDED
#define FSSD_SYCO_CG_INCLUDED

#include "UnityCG.cginc"
#include "Util.cginc"
#include "SycoSSD.cginc"	

//-------------------------
// FSSD
//-------------------------
#define FOG_MUL_SSD(color, text, st, input, localPos) \
	color =  ATLAS_TEX2D(_MainTex, st, input, localPos); \
	color = lerp(fixed4(1.0f, 1.0f, 1.0f, 1.0f), color, color.a * input.color.a); \
	UNITY_APPLY_FOG_COLOR(input.fogCoord, color, fixed4(1.0f, 1.0f, 1.0f, 1.0f))

FragmentInputFSSD vert (VertexInput input)
{
	FragmentInputFSSD o;

	SETUP_BASIC_SSD(input, o)
	UNITY_TRANSFER_FOG(o, o.position);

	return o;
}

fixed4 frag(FragmentInputFSSD input) : SV_Target  
{
	fixed4 color;
	float3 localPos;

	PROCESS_BASIC_SSD(input, localPos);
	FOG_MUL_SSD(color, text, _MainTex_ST, input, localPos);

	return color;
}

#endif // FSSD_SYCO_CG_INCLUDED
