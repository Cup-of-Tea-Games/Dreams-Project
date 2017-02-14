//-----------------------------------------------------
// Deferred screen space decal diffuse shader. Version 0.8 [Beta]
// Copyright (c) 2016 by Sycoforge
//-----------------------------------------------------
Shader "Easy Decal/SSD/Deferred SSD" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
	}
	SubShader 
	{
		Tags 
		{ 
			"RenderType"= "Transparent" 
			"Queue" = "Transparent+10" 
			// Temporarily disable batching -> TODO encoding transform to geometry channels
			"DisableBatching" = "True" 
		}

		Fog { Mode Off } 
		ZWrite On ZTest Always
		Cull Front
		Blend SrcAlpha OneMinusSrcAlpha
		Offset -1,-1

		Pass
		{		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma exclude_renderers nomrt d3d9
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _DIFFUSE
			
			#include "SycoDSSD.cginc"

			ENDCG
		}
	} 
	FallBack "Unlit/Transparent"
	CustomEditor "ch.sycoforge.Decal.Editor.DSSDShaderGUI"
}

