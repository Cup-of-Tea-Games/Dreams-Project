//////////////////////////////////////////////////////
// MegaSplat - 256 texture splat mapping
// Copyright (c) Jason Booth, slipster216@gmail.com
//
// Auto-generated shader code, don't hand edit!
//   Compiled with MegaSplat 1.51
//   Unity : 2017.2.0f3
//   Platform : WindowsEditor
//////////////////////////////////////////////////////

Shader "MegaSplat/Terrain" {
   Properties {
      // terrain
      [NoScaleOffset]_SplatControl("Splat Control", 2D) = "black" {}
      [NoScaleOffset]_SplatParams("Splat Params", 2D) = "black" {}
      // glitter
      [NoScaleOffset]_GlitterTexture("Glitter Texture", 2D) = "grey" {}
      _GlitterParams("Glitter Params", Vector) = (80, 80, .21, 5) // uv scale, scale, flutterspeed, flutterscale
      _GlitterSurfaces("Glitter Snow/Water", Vector) = (1, 8, 1, 8) //shine/reflect snow, shine/reflect water
      // Splats
      _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.0
      [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0

      [NoScaleOffset]_Diffuse ("Diffuse Array", 2DArray) = "white" {}
      [NoScaleOffset]_Normal ("Normal Array", 2DArray) = "bump" {}
      [NoScaleOffset]_AlphaArray("Alpha Array", 2DArray) = "white" {}

      _TexScales("Texure Scales",  Vector) = (10,10,10,10)

      _Contrast("Blend Contrast", Range(0.01, 0.99)) = 0.4
      _Parallax ("Parallax Scale", Vector) = (0.08, 20, 0, 0)

      _DistanceFades("Detail Fade Start/End", Vector) = (500,2000, 500, 2000)
      _DistanceFadesCached("Detail Fade Start/End", Vector) = (500,2000, 500, 2000)

      _GlobalPorosityWetness("Default Porosity and Wetness", Vector) = (0.4, 0.0, 0.0, 0.0)
      _Cutoff("Alpha Clip", Float) = 0.5



      _TessData1("TessData1", Vector) = (4, 0.5, 2, 15)   // tess, displacement, mipBias, edge length
      _TessData2("TessData2", Vector) = (10, 25, 0.3, 0.5) // distance min, max, shaping, upbias
         // pertex
      _PropertyTex("Properties Map", 2D) = "black" {}
      _PerTexScaleRange("Per Tex Scale Modifier", Vector) = (1, 2, 0, 0)
      // puddles
      _PuddleFlowParams("Puddle Flow Params", Vector) = (1,1,0.1, 0.5)
      _PuddleBlend("Puddle Blend", Range(1, 60)) = 6
      _PuddleNormalFoam("Puddle Normal/Foam", Vector) = (0.6, 2, 0, 0)
      _PuddleTint("Puddle Tint", Color) = (0.5,0.5,0.5,0)
      _MaxPuddles("Max Puddles", Range(0,1)) = 1

      // wetness
      _MaxWetness("Max Wetness", Range(0,1)) = 1

   }
   SubShader {
      Tags {"RenderType"="Opaque"}
      Pass 
      {
         Name "DEFERRED"
         Tags { "LightMode"="Deferred" }
      
         CGPROGRAM
         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "Tessellation.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"
         #include "UnityMetaPass.cginc"

         #pragma exclude_renderers d3d9 nomrt
         #define UNITY_PASS_DEFERRED
         #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
         #define _GLOSSYENV 1

         #pragma multi_compile_shadowcaster
         #pragma multi_compile ___ UNITY_HDR_ON
         #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
         #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
         #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
         #pragma multi_compile_fog
          
         #pragma target 4.6
         #define _PASSDEFERRED 1

         #pragma hull hull
         #pragma domain domain
         #pragma vertex tessvert
         #pragma fragment frag

      #define _NORMALMAP 1
      #define _PERTEXAOSTRENGTH 1
      #define _PERTEXCONTRAST 1
      #define _PERTEXDISPLACEPARAMS 1
      #define _PERTEXGLITTER 1
      #define _PERTEXMATPARAMS 1
      #define _PERTEXNORMALSTRENGTH 1
      #define _PERTEXUV 1
      #define _PUDDLEGLITTER 1
      #define _PUDDLES 1
      #define _PUDDLESPUSHTERRAIN 1
      #define _TERRAIN 1
      #define _TESSCENTERBIAS 1
      #define _TESSDAMPENING 1
      #define _TESSDISTANCE 1
      #define _TESSFALLBACK 1
      #define _TWOLAYER 1
      #define _WETNESS 1



         struct MegaSplatLayer
         {
            half3 Albedo;
            half3 Normal;
            half3 Emission;
            half  Metallic;
            half  Smoothness;
            half  Occlusion;
            half  Height;
            half  Alpha;
         };

         struct SplatInput
         {
            float3 weights;
            float2 splatUV;
            float2 macroUV;
            float3 valuesMain;
            half3 viewDir;
            float4 camDist;

            #if _TWOLAYER || _ALPHALAYER
            float3 valuesSecond;
            half layerBlend;
            #endif

            #if _TRIPLANAR
            float3 triplanarUVW;
            #endif
            half3 triplanarBlend; // passed to func, so always present

            #if _FLOW || _FLOWREFRACTION || _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half2 flowDir;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half puddleHeight;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            float3 waterNormalFoam;
            #endif

            #if _WETNESS
            half wetness;
            #endif

            #if _TESSDAMPENING
            half displacementDampening;
            #endif

            #if _SNOW
            half snowHeightFade;
            #endif

            #if _SNOW || _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsNormal;
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsView;
            #endif

            #if _GEOMAP
            float3 worldPos;
            #endif
         };


         struct LayerParams
         {
            float3 uv0, uv1, uv2;
            float2 mipUV; // uv for mip selection
            #if _TRIPLANAR
            float3 tpuv0_x, tpuv0_y, tpuv0_z;
            float3 tpuv1_x, tpuv1_y, tpuv1_z;
            float3 tpuv2_x, tpuv2_y, tpuv2_z;
            #endif
            #if _FLOW || _FLOWREFRACTION
            float3 fuv0a, fuv0b;
            float3 fuv1a, fuv1b;
            float3 fuv2a, fuv2b;
            #endif

            #if _DISTANCERESAMPLE
               half distanceBlend;
               float3 db_uv0, db_uv1, db_uv2;
               #if _TRIPLANAR
               float3 db_tpuv0_x, db_tpuv0_y, db_tpuv0_z;
               float3 db_tpuv1_x, db_tpuv1_y, db_tpuv1_z;
               float3 db_tpuv2_x, db_tpuv2_y, db_tpuv2_z;
               #endif
            #endif

            half layerBlend;
            half3 metallic;
            half3 smoothness;
            half3 porosity;
            #if _FLOW || _FLOWREFRACTION
            half3 flowIntensity;
            half flowOn;
            half3 flowAlphas;
            half3 flowRefracts;
            half3 flowInterps;
            #endif
            half3 weights;

            #if _TESSDISTANCE || _TESSEDGE
            half3 displacementScale;
            half3 upBias;
            #endif

            #if _PERTEXNOISESTRENGTH
            half3 detailNoiseStrength;
            #endif

            #if _PERTEXNORMALSTRENGTH
            half3 normalStrength;
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            half3 parallaxStrength;
            #endif

            #if _PERTEXAOSTRENGTH
            half3 aoStrength;
            #endif

            #if _PERTEXGLITTER
            half3 perTexGlitterReflect;
            #endif

            half3 contrast;
         };

         struct VirtualMapping
         {
            float3 weights;
            fixed4 c0, c1, c2;
            fixed4 param;
         };



         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"

         // splat
         UNITY_DECLARE_TEX2DARRAY(_Diffuse);
         float4 _Diffuse_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_Normal);
         float4 _Normal_TexelSize;
         #if _EMISMAP
         UNITY_DECLARE_TEX2DARRAY(_Emissive);
         float4 _Emissive_TexelSize;
         #endif
         #if _DETAILMAP
         UNITY_DECLARE_TEX2DARRAY(_DetailAlbedo);
         float4 _DetailAlbedo_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_DetailNormal);
         float4 _DetailNormal_TexelSize;
         half _DetailTextureStrength;
         #endif

         #if _ALPHA || _ALPHATEST
         UNITY_DECLARE_TEX2DARRAY(_AlphaArray);
         float4 _AlphaArray_TexelSize;
         #endif

         #if _LOWPOLY
         half _EdgeHardness;
         #endif

         #if _TERRAIN
         sampler2D _SplatControl;
         sampler2D _SplatParams;
         #endif

         #if _ALPHAHOLE
         int _AlphaHoleIdx;
         #endif

         #if _RAMPLIGHTING
         sampler2D _Ramp;
         #endif

         #if _UVLOCALTOP || _UVWORLDTOP || _UVLOCALFRONT || _UVWORLDFRONT || _UVLOCALSIDE || _UVWORLDSIDE
         float4 _UVProjectOffsetScale;
         #endif
         #if _UVLOCALTOP2 || _UVWORLDTOP2 || _UVLOCALFRONT2 || _UVWORLDFRONT2 || _UVLOCALSIDE2 || _UVWORLDSIDE2
         float4 _UVProjectOffsetScale2;
         #endif

         half _Contrast;

         #if _ALPHALAYER || _USEMACROTEXTURE
         // macro texturing
         sampler2D _MacroDiff;
         sampler2D _MacroBump;
         sampler2D _MetallicGlossMap;
         sampler2D _MacroAlpha;
         half2 _MacroTexScale;
         half _MacroTextureStrength;
         half2 _MacroTexNormAOScales;
         #endif

         // default spec
         half _Glossiness;
         half _Metallic;

         #if _DISTANCERESAMPLE
         float3  _ResampleDistanceParams;
         #endif

         #if _FLOW || _FLOWREFRACTION
         // flow
         half _FlowSpeed;
         half _FlowAlpha;
         half _FlowIntensity;
         half _FlowRefraction;
         #endif

         half2 _PerTexScaleRange;
         sampler2D _PropertyTex;

         // etc
         half2 _Parallax;
         half4 _TexScales;

         float4 _DistanceFades;
         float4 _DistanceFadesCached;
         int _ControlSize;

         #if _TRIPLANAR
         half _TriplanarTexScale;
         half _TriplanarContrast;
         float3 _TriplanarOffset;
         #endif

         #if _GEOMAP
         sampler2D _GeoTex;
         float3 _GeoParams;
         #endif

         #if _PROJECTTEXTURE_LOCAL || _PROJECTTEXTURE_WORLD
         half3 _ProjectTexTop;
         half3 _ProjectTexSide;
         half3 _ProjectTexBottom;
         half3 _ProjectTexThresholdFreq;
         #endif

         #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
         half3 _ProjectTexTop2;
         half3 _ProjectTexSide2;
         half3 _ProjectTexBottom2;
         half3 _ProjectTexThresholdFreq2;
         half4 _ProjectTexBlendParams;
         #endif

         #if _TESSDISTANCE || _TESSEDGE
         float4 _TessData1; // distance tessellation, displacement, edgelength
         float4 _TessData2; // min, max
         #endif

         #if _DETAILNOISE
         sampler2D _DetailNoise;
         half3 _DetailNoiseScaleStrengthFade;
         #endif

         #if _DISTANCENOISE
         sampler2D _DistanceNoise;
         half4 _DistanceNoiseScaleStrengthFade;
         #endif

         #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
         half3 _PuddleTint;
         half _PuddleBlend;
         half _MaxPuddles;
         half4 _PuddleFlowParams;
         half2 _PuddleNormalFoam;
         #endif

         #if _RAINDROPS
         sampler2D _RainDropTexture;
         half _RainIntensity;
         float2 _RainUVScales;
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         float2 _PuddleUVScales;
         sampler2D _PuddleNormal;
         #endif

         #if _LAVA
         sampler2D _LavaDiffuse;
         sampler2D _LavaNormal;
         half4 _LavaParams;
         half4 _LavaParams2;
         half3 _LavaEdgeColor;
         half3 _LavaColorLow;
         half3 _LavaColorHighlight;
         float2 _LavaUVScale;
         #endif

         #if _WETNESS
         half _MaxWetness;
         #endif

         half2 _GlobalPorosityWetness;

         #if _SNOW
         sampler2D _SnowDiff;
         sampler2D _SnowNormal;
         half4 _SnowParams; // influence, erosion, crystal, melt
         half _SnowAmount;
         half2 _SnowUVScales;
         half2 _SnowHeightRange;
         half3 _SnowUpVector;
         #endif

         #if _SNOWDISTANCENOISE
         sampler2D _SnowDistanceNoise;
         float4 _SnowDistanceNoiseScaleStrengthFade;
         #endif

         #if _SNOWDISTANCERESAMPLE
         float4 _SnowDistanceResampleScaleStrengthFade;
         #endif

         #if _PERTEXGLITTER || _SNOWGLITTER || _PUDDLEGLITTER
         sampler2D _GlitterTexture;
         half4 _GlitterParams;
         half4 _GlitterSurfaces;
         #endif


         struct VertexOutput 
         {
             float4 pos          : SV_POSITION;
             #if !_TERRAIN
             fixed3 weights      : TEXCOORD0;
             float4 valuesMain   : TEXCOORD1;      //index rgb, triplanar W
                #if _TWOLAYER || _ALPHALAYER
                float4 valuesSecond : TEXCOORD2;      //index rgb + alpha
                #endif
             #elif _TRIPLANAR
             float3 triplanarUVW : TEXCOORD3;
             #endif
             float2 coords       : TEXCOORD4;      // uv, or triplanar UV
             float3 posWorld     : TEXCOORD5;
             float3 normal       : TEXCOORD6;

             float4 camDist      : TEXCOORD7;      // distance from camera (for fades) and fog
             float4 extraData    : TEXCOORD8;      // flowdir + fades, or if triplanar triplanarView + detailFade
             float3 tangent      : TEXCOORD9;
             float3 bitangent    : TEXCOORD10;
             float4 ambientOrLightmapUV : TEXCOORD14;


             #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
             LIGHTING_COORDS(11,12)
             UNITY_FOG_COORDS(13)
             #endif

             #if _PASSSHADOWCASTER
             float3 vec : TEXCOORD11;  // nice naming, Unity...
             #endif

             #if _WETNESS
             half wetness : TEXCOORD15;   //wetness
             #endif

             #if _SECONDUV
             float3 macroUV : TEXCOORD16;
             #endif

         };

         void OffsetUVs(inout LayerParams p, float2 offset)
         {
            p.uv0.xy += offset;
            p.uv1.xy += offset;
            p.uv2.xy += offset;
            #if _TRIPLANAR
            p.tpuv0_x.xy += offset;
            p.tpuv0_y.xy += offset;
            p.tpuv0_z.xy += offset;
            p.tpuv1_x.xy += offset;
            p.tpuv1_y.xy += offset;
            p.tpuv1_z.xy += offset;
            p.tpuv2_x.xy += offset;
            p.tpuv2_y.xy += offset;
            p.tpuv2_z.xy += offset;
            #endif
         }


         void InitDistanceResample(inout LayerParams lp, float dist)
         {
            #if _DISTANCERESAMPLE
               lp.distanceBlend = saturate((dist - _ResampleDistanceParams.y) / (_ResampleDistanceParams.z - _ResampleDistanceParams.y));
               lp.db_uv0 = lp.uv0;
               lp.db_uv1 = lp.uv1;
               lp.db_uv2 = lp.uv2;

               lp.db_uv0.xy *= _ResampleDistanceParams.xx;
               lp.db_uv1.xy *= _ResampleDistanceParams.xx;
               lp.db_uv2.xy *= _ResampleDistanceParams.xx;


               #if _TRIPLANAR
               lp.db_tpuv0_x = lp.tpuv0_x;
               lp.db_tpuv1_x = lp.tpuv1_x;
               lp.db_tpuv2_x = lp.tpuv2_x;
               lp.db_tpuv0_y = lp.tpuv0_y;
               lp.db_tpuv1_y = lp.tpuv1_y;
               lp.db_tpuv2_y = lp.tpuv2_y;
               lp.db_tpuv0_z = lp.tpuv0_z;
               lp.db_tpuv1_z = lp.tpuv1_z;
               lp.db_tpuv2_z = lp.tpuv2_z;

               lp.db_tpuv0_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_z.xy *= _ResampleDistanceParams.xx;
               #endif
            #endif
         }


         LayerParams NewLayerParams()
         {
            LayerParams l = (LayerParams)0;
            l.metallic = _Metallic.xxx;
            l.smoothness = _Glossiness.xxx;
            l.porosity = _GlobalPorosityWetness.xxx;

            l.layerBlend = 0;
            #if _FLOW || _FLOWREFRACTION
            l.flowIntensity = 0;
            l.flowOn = 0;
            l.flowAlphas = half3(1,1,1);
            l.flowRefracts = half3(1,1,1);
            #endif

            #if _TESSDISTANCE || _TESSEDGE
            l.displacementScale = half3(1,1,1);
            l.upBias = half3(0,0,0);
            #endif

            #if _PERTEXNOISESTRENGTH
            l.detailNoiseStrength = half3(1,1,1);
            #endif

            #if _PERTEXNORMALSTRENGTH
            l.normalStrength = half3(1,1,1);
            #endif

            #if _PERTEXAOSTRENGTH
            l.aoStrength = half3(1,1,1);
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            l.parallaxStrength = half3(1,1,1);
            #endif

            l.contrast = _Contrast;

            return l;
         }

         half AOContrast(half ao, half scalar)
         {
            scalar += 0.5;  // 0.5 -> 1.5
            scalar *= scalar; // 0.25 -> 2.25
            return pow(ao, scalar);
         }

         half MacroAOContrast(half ao, half scalar)
         {
            #if _MACROAOSCALE
            return AOContrast(ao, scalar);
            #else
            return ao;
            #endif
         }
         #if _USEMACROTEXTURE || _ALPHALAYER
         MegaSplatLayer SampleMacro(float2 uv)
         {
             MegaSplatLayer o = (MegaSplatLayer)0;
             float2 macroUV = uv * _MacroTexScale.xy;
             half4 macAlb = tex2D(_MacroDiff, macroUV);
             o.Albedo = macAlb.rgb;
             o.Height = macAlb.a;
             // defaults
             o.Normal = half3(0,0,1);
             o.Occlusion = 1;
             o.Smoothness = _Glossiness;
             o.Metallic = _Metallic;
             o.Emission = half3(0,0,0);

             // unpack normal
             #if !_NOSPECTEX
             half4 normSample = tex2D(_MacroBump, macroUV);
             o.Normal = UnpackNormal(normSample);
             o.Normal.xy *= _MacroTexNormAOScales.x;
             #else
             o.Normal = half3(0,0,1);
             #endif


             #if _ALPHA || _ALPHATEST
             o.Alpha = tex2D(_MacroAlpha, macroUV).r;
             #endif
             return o;
         }
         #endif


         #if _NOSPECTEX
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = UnpackNormal(norm); 

         #elif _NOSPECNORMAL   
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = half3(0,0,1);

         #else
            #define SAMPLESPEC(o, params) \
              half4 spec0, spec1, spec2; \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.yw =  norm.zw; \
              specFinal.x = (params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z); \
              norm.xy *= 2; \
              norm.xy -= 1; \
              o.Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy)))); \

         #endif

         void SamplePerTex(sampler2D pt, inout LayerParams params, float2 scaleRange)
         {
            const half cent = 1.0 / 512.0;
            const half pixelStep = 1.0 / 256.0;
            const half vertStep = 1.0 / 8.0;

            // pixel layout for per tex properties
            // metal/smooth/porosity/uv scale
            // flow speed, intensity, alpha, refraction
            // detailNoiseStrength, contrast, displacementAmount, displaceUpBias

            #if _PERTEXMATPARAMS || _PERTEXUV
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, 0, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, 0, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, 0, 0, 0));
               params.porosity = half3(0.4, 0.4, 0.4);
               #if _PERTEXMATPARAMS
               params.metallic = half3(props0.r, props1.r, props2.r);
               params.smoothness = half3(props0.g, props1.g, props2.g);
               params.porosity = half3(props0.b, props1.b, props2.b);
               #endif
               #if _PERTEXUV
               float3 uvScale = float3(props0.a, props1.a, props2.a);
               uvScale = lerp(scaleRange.xxx, scaleRange.yyy, uvScale);
               params.uv0.xy *= uvScale.x;
               params.uv1.xy *= uvScale.y;
               params.uv2.xy *= uvScale.z;

                  #if _TRIPLANAR
                  params.tpuv0_x.xy *= uvScale.xx; params.tpuv0_y.xy *= uvScale.xx; params.tpuv0_z.xy *= uvScale.xx;
                  params.tpuv1_x.xy *= uvScale.yy; params.tpuv1_y.xy *= uvScale.yy; params.tpuv1_z.xy *= uvScale.yy;
                  params.tpuv2_x.xy *= uvScale.zz; params.tpuv2_y.xy *= uvScale.zz; params.tpuv2_z.xy *= uvScale.zz;
                  #endif

               #endif
            }
            #endif


            #if _FLOW || _FLOWREFRACTION
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 3, 0, 0));

               params.flowIntensity = half3(props0.r, props1.r, props2.r);
               params.flowOn = params.flowIntensity.x + params.flowIntensity.y + params.flowIntensity.z;

               params.flowAlphas = half3(props0.b, props1.b, props2.b);
               params.flowRefracts = half3(props0.a, props1.a, props2.a);
            }
            #endif

            #if _PERTEXDISPLACEPARAMS || _PERTEXCONTRAST || _PERTEXNOISESTRENGTH
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 5, 0, 0));

               #if _PERTEXDISPLACEPARAMS && (_TESSDISTANCE || _TESSEDGE)
               params.displacementScale = half3(props0.b, props1.b, props2.b);
               params.upBias = half3(props0.a, props1.a, props2.a);
               #endif

               #if _PERTEXCONTRAST
               params.contrast = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXNOISESTRENGTH
               params.detailNoiseStrength = half3(props0.r, props1.r, props2.r);
               #endif
            }
            #endif

            #if _PERTEXNORMALSTRENGTH || _PERTEXPARALLAXSTRENGTH || _PERTEXAOSTRENGTH || _PERTEXGLITTER
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 7, 0, 0));

               #if _PERTEXNORMALSTRENGTH
               params.normalStrength = half3(props0.r, props1.r, props2.r);
               #endif

               #if _PERTEXPARALLAXSTRENGTH
               params.parallaxStrength = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXAOSTRENGTH
               params.aoStrength = half3(props0.b, props1.b, props2.b);
               #endif

               #if _PERTEXGLITTER
               params.perTexGlitterReflect = half3(props0.a, props1.a, props2.a);
               #endif

            }
            #endif
         }

         float FlowRefract(MegaSplatLayer tex, inout LayerParams main, inout LayerParams second, half3 weights)
         {
            #if _FLOWREFRACTION
            float totalFlow = second.flowIntensity.x * weights.x + second.flowIntensity.y * weights.y + second.flowIntensity.z * weights.z;
            float falpha = second.flowAlphas.x * weights.x + second.flowAlphas.y * weights.y + second.flowAlphas.z * weights.z;
            float frefract = second.flowRefracts.x * weights.x + second.flowRefracts.y * weights.y + second.flowRefracts.z * weights.z;
            float refractOn = min(1, totalFlow * 10000);
            float ratio = lerp(1.0, _FlowAlpha * falpha, refractOn);
            float2 rOff = tex.Normal.xy * _FlowRefraction * frefract * ratio;
            main.uv0.xy += rOff;
            main.uv1.xy += rOff;
            main.uv2.xy += rOff;
            return ratio;
            #endif
            return 1;
         }

         float MipLevel(float2 uv, float2 textureSize)
         {
            uv *= textureSize;
            float2  dx_vtc        = ddx(uv);
            float2  dy_vtc        = ddy(uv);
            float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
            return 0.5 * log2(delta_max_sqr);
         }


         #if _DISTANCERESAMPLE
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l); \
                  { \
                     half4 st0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_z, l); \
                     half4 st1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_z, l); \
                     half4 st2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_z, l); \
                     t0 = lerp(t0, st0, lp.distanceBlend); \
                     t1 = lerp(t1, st1, lp.distanceBlend); \
                     t2 = lerp(t2, st2, lp.distanceBlend); \
                  }
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); 
               #endif
            #endif
         #else // not distance resample
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l);
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l);
               #endif
            #endif
         #endif


         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, lod);
         #else
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, lod);
         #endif

         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z + offset, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z + offset, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z + offset, lod);
         #else
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0 + offset, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1 + offset, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2 + offset, lod);
         #endif

         void Flow(float3 uv, half2 flow, half speed, float intensity, out float3 uv1, out float3 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));
            uv1.z = uv.z;
            uv2.z = uv.z;

            interp = abs(0.5 - phase.x) / 0.5;
         }

         void Flow(float2 uv, half2 flow, half speed, float intensity, out float2 uv1, out float2 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));

            interp = abs(0.5 - phase.x) / 0.5;
         }

         half3 ComputeWeights(half3 iWeights, half4 tex0, half4 tex1, half4 tex2, half contrast)
         {
             // compute weight with height map
             const half epsilon = 1.0f / 1024.0f;
             half3 weights = half3(iWeights.x * (tex0.a + epsilon), 
                                      iWeights.y * (tex1.a + epsilon),
                                      iWeights.z * (tex2.a + epsilon));

             // Contrast weights
             half maxWeight = max(weights.x, max(weights.y, weights.z));
             half transition = contrast * maxWeight;
             half threshold = maxWeight - transition;
             half scale = 1.0f / transition;
             weights = saturate((weights - threshold) * scale);
             // Normalize weights.
             half weightScale = 1.0f / (weights.x + weights.y + weights.z);
             weights *= weightScale;
             #if _LINEARBIAS
             weights = lerp(weights, iWeights, contrast);
             #endif
             return weights;
         }

         float2 ProjectUVs(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP
            return (vertex.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALSIDE
            return (vertex.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALFRONT
            return (vertex.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDTOP
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(1,0,0));
               tangent.w = worldNormal.y > 0 ? -1 : 1;
               #endif
            return (worldPos.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDFRONT
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,0,1));
               tangent.w = worldNormal.x > 0 ? 1 : -1;
               #endif
            return (worldPos.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDSIDE
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,1,0));
               tangent.w = worldNormal.z > 0 ? 1 : -1;
               #endif
            return (worldPos.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #endif
            return coords;
         }

         float2 ProjectUV2(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP2
            return (vertex.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALSIDE2
            return (vertex.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALFRONT2
            return (vertex.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDTOP2
            return (worldPos.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDFRONT2
            return (worldPos.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDSIDE2
            return (worldPos.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #endif
            return coords;
         }

         void WaterBRDF (inout half3 Albedo, inout half Smoothness, half metalness, half wetFactor, half surfPorosity) 
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS
            half porosity = saturate((( (1 - Smoothness) - 0.5)) / max(surfPorosity, 0.001));
            half factor = lerp(1, 0.2, (1 - metalness) * porosity);
            Albedo *= lerp(1.0, factor, wetFactor);
            Smoothness = lerp(1.0, Smoothness, lerp(1.0, factor, wetFactor));
            #endif
         }

         #if _RAINDROPS
         float3 ComputeRipple(float2 uv, float time, float weight)
         {
            float4 ripple = tex2D(_RainDropTexture, uv);
            ripple.yz = ripple.yz * 2 - 1;

            float dropFrac = frac(ripple.w + time);
            float timeFrac = dropFrac - 1.0 + ripple.x;
            float dropFactor = saturate(0.2f + weight * 0.8 - dropFrac);
            float finalFactor = dropFactor * ripple.x * 
                                 sin( clamp(timeFrac * 9.0f, 0.0f, 3.0f) * 3.14159265359);

            return float3(ripple.yz * finalFactor * 0.35f, 1.0f);
         }
         #endif

         // water normal only
         half2 DoPuddleRefract(float3 waterNorm, half puddleLevel, float2 flowDir, half height)
         {
            #if _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - height) * _PuddleBlend);
            waterBlend *= waterBlend;

            waterNorm.xy *= puddleLevel * waterBlend;
               #if _PUDDLEDEPTHDAMPEN
               return lerp(waterNorm.xy, waterNorm.xy * height, _PuddleFlowParams.w);
               #endif
            return waterNorm.xy;

            #endif
            return half2(0,0);
         }

         // modity lighting terms for water..
         float DoPuddles(inout MegaSplatLayer o, float2 uv, half3 waterNormFoam, half puddleLevel, half2 flowDir, half porosity, float3 worldNormal)
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - o.Height) * _PuddleBlend);

            half3 waterNorm = half3(0,0,1);
            #if _PUDDLEFLOW || _PUDDLEREFRACT

               waterNorm = half3(waterNormFoam.x, waterNormFoam.y, sqrt(1 - saturate(dot(waterNormFoam.xy, waterNormFoam.xy))));

               #if _PUDDLEFOAM
               half pmh = puddleLevel - o.Height;
               // refactor to compute flow UVs in previous step?
               float2 foamUV0;
               float2 foamUV1;
               half foamInterp;
               Flow(uv * 1.75 + waterNormFoam.xy * waterNormFoam.b, flowDir, _PuddleFlowParams.y/3, _PuddleFlowParams.z/3, foamUV0, foamUV1, foamInterp);
               half foam0 = tex2D(_PuddleNormal, foamUV0).b;
               half foam1 = tex2D(_PuddleNormal, foamUV1).b;
               half foam = lerp(foam0, foam1, foamInterp);
               foam = foam * abs(pmh) + (foam * o.Height);
               foam *= 1.0 - (saturate(pmh * 1.5));
               foam *= foam;
               foam *= _PuddleNormalFoam.y;
               #endif // foam
            #endif // flow, refract

            half3 wetAlbedo = o.Albedo * _PuddleTint * 2;
            half wetSmoothness = o.Smoothness;

            WaterBRDF(wetAlbedo, wetSmoothness, o.Metallic, waterBlend, porosity);

            #if _RAINDROPS
               float dropStrength = _RainIntensity;
               #if _RAINDROPFLATONLY
               dropStrength = saturate(dot(float3(0,1,0), worldNormal));
               #endif
               const float4 timeMul = float4(1.0f, 0.85f, 0.93f, 1.13f); 
               float4 timeAdd = float4(0.0f, 0.2f, 0.45f, 0.7f);
               float4 times = _Time.yyyy;
               times = frac((times * float4(1, 0.85, 0.93, 1.13) + float4(0, 0.2, 0.45, 0.7)) * 1.6);

               float2 ruv1 = uv * _RainUVScales.xy;
               float2 ruv2 = ruv1;

               float4 weights = _RainIntensity.xxxx - float4(0, 0.25, 0.5, 0.75);
               float3 ripple1 = ComputeRipple(ruv1 + float2( 0.25f,0.0f), times.x, weights.x);
               float3 ripple2 = ComputeRipple(ruv2 + float2(-0.55f,0.3f), times.y, weights.y);
               float3 ripple3 = ComputeRipple(ruv1 + float2(0.6f, 0.85f), times.z, weights.z);
               float3 ripple4 = ComputeRipple(ruv2 + float2(0.5f,-0.75f), times.w, weights.w);
               weights = saturate(weights * 4);

               float4 z = lerp(float4(1,1,1,1), float4(ripple1.z, ripple2.z, ripple3.z, ripple4.z), weights);
               float3 rippleNormal = float3( weights.x * ripple1.xy +
                           weights.y * ripple2.xy + 
                           weights.z * ripple3.xy + 
                           weights.w * ripple4.xy, 
                           z.x * z.y * z.z * z.w);

               waterNorm = lerp(waterNorm, normalize(rippleNormal+waterNorm), _RainIntensity * dropStrength);                         
            #endif

            #if _PUDDLEFOAM
            wetAlbedo += foam;
            wetSmoothness -= foam;
            #endif

            o.Normal = lerp(o.Normal, waterNorm, waterBlend * _PuddleNormalFoam.x);
            o.Occlusion = lerp(o.Occlusion, 1, waterBlend);
            o.Smoothness = lerp(o.Smoothness, wetSmoothness, waterBlend);
            o.Albedo = lerp(o.Albedo, wetAlbedo, waterBlend);
            return waterBlend;
            #endif
            return 0;
         }

         float DoLava(inout MegaSplatLayer o, float2 uv, half lavaLevel, half2 flowDir)
         {
            #if _LAVA

            half distortionSize = _LavaParams2.x;
            half distortionRate = _LavaParams2.y;
            half distortionScale = _LavaParams2.z;
            half darkening = _LavaParams2.w;
            half3 edgeColor = _LavaEdgeColor;
            half3 lavaColorLow = _LavaColorLow;
            half3 lavaColorHighlight = _LavaColorHighlight;


            half maxLava = _LavaParams.y;
            half lavaSpeed = _LavaParams.z;
            half lavaInterp = _LavaParams.w;

            lavaLevel *= maxLava;
            float lvh = lavaLevel - o.Height;
            float lavaBlend = saturate(lvh * _LavaParams.x);

            float2 uv1;
            float2 uv2;
            half interp;
            half drag = lerp(0.1, 1, saturate(lvh));
            Flow(uv, flowDir, lavaInterp, lavaSpeed * drag, uv1, uv2, interp);

            float2 dist_uv1;
            float2 dist_uv2;
            half dist_interp;
            Flow(uv * distortionScale, flowDir, distortionRate, distortionSize, dist_uv1, dist_uv2, dist_interp);

            half4 lavaDist = lerp(tex2D(_LavaDiffuse, dist_uv1*0.51), tex2D(_LavaDiffuse, dist_uv2), dist_interp);
            half4 dist = lavaDist * (distortionSize * 2) - distortionSize;

            half4 lavaTex = lerp(tex2D(_LavaDiffuse, uv1*1.1 + dist.xy), tex2D(_LavaDiffuse, uv2 + dist.zw), interp);

            lavaTex.xy = lavaTex.xy * 2 - 1;
            half3 lavaNorm = half3(lavaTex.xy, sqrt(1 - saturate(dot(lavaTex.xy, lavaTex.xy))));

            // base lava color, based on heights
            half3 lavaColor = lerp(lavaColorLow, lavaColorHighlight, lavaTex.b);

            // edges
            float lavaBlendWide = saturate((lavaLevel - o.Height) * _LavaParams.x * 0.5);
            float edge = saturate((1 - lavaBlendWide) * 3);

            // darkening
            darkening = saturate(lavaTex.a * darkening * saturate(lvh*2));
            lavaColor = lerp(lavaColor, lavaDist.bbb * 0.3, darkening);
            // edges
            lavaColor = lerp(lavaColor, edgeColor, edge);

            o.Albedo = lerp(o.Albedo, lavaColor, lavaBlend);
            o.Normal = lerp(o.Normal, lavaNorm, lavaBlend);
            o.Smoothness = lerp(o.Smoothness, 0.3, lavaBlend * darkening);

            half3 emis = lavaColor * lavaBlend;
            o.Emission = lerp(o.Emission, emis, lavaBlend);
            // bleed
            o.Emission += edgeColor * 0.3 * (saturate((lavaLevel*1.2 - o.Height) * _LavaParams.x) - lavaBlend);
            return lavaBlend;
            #endif
            return 0;
         }

         // no trig based hash, not a great hash, but fast..
         float Hash(float3 p)
         {
             p  = frac( p*0.3183099+.1 );
             p *= 17.0;
             return frac( p.x*p.y*p.z*(p.x+p.y+p.z) );
         }

         float Noise( float3 x )
         {
             float3 p = floor(x);
             float3 f = frac(x);
             f = f*f*(3.0-2.0*f);
            
             return lerp(lerp(lerp( Hash(p+float3(0,0,0)), Hash(p+float3(1,0,0)),f.x), lerp( Hash(p+float3(0,1,0)), Hash(p+float3(1,1,0)),f.x),f.y),
                       lerp(lerp(Hash(p+float3(0,0,1)), Hash(p+float3(1,0,1)),f.x), lerp(Hash(p+float3(0,1,1)), Hash(p+float3(1,1,1)),f.x),f.y),f.z);
         }

         // given 4 texture choices for each projection, return texture index based on normal
         // seems like we could remove some branching here.. hmm..
         float ProjectTexture(float3 worldPos, float3 normal, half3 threshFreq, half3 top, half3 side, half3 bottom)
         {
            half d = dot(normal, float3(0, 1, 0));
            half3 cvec = side;
            if (d < threshFreq.x)
            {
               cvec = bottom;
            }
            else if (d > threshFreq.y)
            {
               cvec = top;
            }

            float n = Noise(worldPos * threshFreq.z);
            if (n < 0.333)
               return cvec.x;
            else if (n < 0.666)
               return cvec.y;
            else
               return cvec.z;
         }

         void ProceduralTexture(float3 localPos, float3 worldPos, float3 normal, float3 worldNormal, inout float4 valuesMain, inout float4 valuesSecond, half3 weights)
         {
            #if _PROJECTTEXTURE_LOCAL
            half choice = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif
            #if _PROJECTTEXTURE_WORLD
            half choice = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif

            #if _PROJECTTEXTURE2_LOCAL
            half choice2 = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif
            #if _PROJECTTEXTURE2_WORLD
            half choice2 = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif

            #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
            float blendNoise = Noise(worldPos * _ProjectTexBlendParams.x) - 0.5;
            blendNoise *= _ProjectTexBlendParams.y;
            blendNoise += 0.5;
            blendNoise = min(max(blendNoise, _ProjectTexBlendParams.z), _ProjectTexBlendParams.w);
            valuesSecond.a = saturate(blendNoise);
            #endif
         }


         // manually compute barycentric coordinates
         float3 Barycentric(float2 p, float2 a, float2 b, float2 c)
         {
             float2 v0 = b - a;
             float2 v1 = c - a;
             float2 v2 = p - a;
             float d00 = dot(v0, v0);
             float d01 = dot(v0, v1);
             float d11 = dot(v1, v1);
             float d20 = dot(v2, v0);
             float d21 = dot(v2, v1);
             float denom = d00 * d11 - d01 * d01;
             float v = (d11 * d20 - d01 * d21) / denom;
             float w = (d00 * d21 - d01 * d20) / denom;
             float u = 1.0f - v - w;
             return float3(u, v, w);
         }

         // given two height values (from textures) and a height value for the current pixel (from vertex)
         // compute the blend factor between the two with a small blending area between them.
         half HeightBlend(half h1, half h2, half slope, half contrast)
         {
            h2 = 1 - h2;
            half tween = saturate((slope - min(h1, h2)) / max(abs(h1 - h2), 0.001)); 
            half blend = saturate( ( tween - (1-contrast) ) / max(contrast, 0.001));
            #if _LINEARBIAS
            blend = lerp(slope, blend, contrast);
            #endif
            return blend;
         }

         void BlendSpec(inout MegaSplatLayer base, MegaSplatLayer macro, half r, float3 albedo)
         {
            base.Metallic = lerp(base.Metallic, macro.Metallic, r);
            base.Smoothness = lerp(base.Smoothness, macro.Smoothness, r);
            base.Emission = albedo * lerp(base.Emission, macro.Emission, r);
         }

         half3 BlendOverlay(half3 base, half3 blend) { return (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))); }
         half3 BlendMult2X(half3  base, half3 blend) { return (base * (blend * 2)); }


         MegaSplatLayer SampleDetail(half3 weights, float3 viewDir, inout LayerParams params, half3 tpw)
         {
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.ga *= params.normalStrength.x;
               norm1.ga *= params.normalStrength.y;
               norm2.ga *= params.normalStrength.z;
               #endif
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif

            SAMPLESPEC(o, params);

            o.Emission = albedo.rgb * specFinal.z;
            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            return o;
         }


         float SampleLayerHeight(half3 biWeights, float3 viewDir, inout LayerParams params, half3 tpw, float lod, float contrast)
         { 
            #if _TESSDISTANCE || _TESSEDGE
            half4 tex0, tex1, tex2;

            SAMPLETEXARRAYLOD(tex0, tex1, tex2, _Diffuse, params, lod);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, contrast);
            params.weights = weights;
            return (tex0.a * params.displacementScale.x * weights.x + 
                    tex1.a * params.displacementScale.y * weights.y + 
                    tex2.a * params.displacementScale.z * weights.z);
            #endif
            return 0.5;
         }

         #if _TESSDISTANCE || _TESSEDGE
         float4 MegaSplatDistanceBasedTess (float d0, float d1, float d2, float tess)
         {
            float3 f;
            f.x = clamp(d0, 0.01, 1.0) * tess;
            f.y = clamp(d1, 0.01, 1.0) * tess;
            f.z = clamp(d2, 0.01, 1.0) * tess;

            return UnityCalcTriEdgeTessFactors (f);
         }
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         half3 GetWaterNormal(float2 uv, float2 flowDir)
         {
            float2 uv1;
            float2 uv2;
            half interp;
            Flow(uv, flowDir, _PuddleFlowParams.y, _PuddleFlowParams.z, uv1, uv2, interp);

            half3 fd = lerp(tex2D(_PuddleNormal, uv1), tex2D(_PuddleNormal, uv2), interp).xyz;
            fd.xy = fd.xy * 2 - 1;
            return fd;
         }
         #endif

         MegaSplatLayer SampleLayer(inout LayerParams params, SplatInput si)
         { 
            half3 biWeights = si.weights;
            float3 viewDir = si.viewDir;
            half3 tpw = si.triplanarBlend;

            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
            params.weights = weights;
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
                  params.uv1.xy += refractOffset;
                  params.uv2.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * biWeights.x + params.parallaxStrength.y * biWeights.y + params.parallaxStrength.z * biWeights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, viewDir);
                  params.uv0.xy += pOffset;
                  params.uv1.xy += pOffset;
                  params.uv2.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
                  weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
                  albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0, alpha1, alpha2;
            mipLevel = MipLevel(params.mipUV, _AlphaArray_TexelSize.zw);
            SAMPLETEXARRAY(alpha0, alpha1, alpha2, _AlphaArray, params, mipLevel);
            o.Alpha = alpha0.r * weights.x + alpha1.r * weights.y + alpha2.r * weights.z;
            #endif

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.xy -= 0.5; norm1.xy -= 0.5; norm2.xy -= 0.5;
               norm0.xy *= params.normalStrength.x;
               norm1.xy *= params.normalStrength.y;
               norm2.xy *= params.normalStrength.z;
               norm0.xy += 0.5; norm1.xy += 0.5; norm2.xy += 0.5;
               #endif
            
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif


            SAMPLESPEC(o, params);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            half4 emis0, emis1, emis2;
            mipLevel = MipLevel(params.mipUV, _Emissive_TexelSize.zw);
            SAMPLETEXARRAY(emis0, emis1, emis2, _Emissive, params, mipLevel);
            half4 emis = emis0 * weights.x + emis1 * weights.y + emis2 * weights.z;
            o.Emission = emis.rgb;
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _EMISMAP
            o.Metallic = emis.a;
            #endif

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x * params.weights.x + params.aoStrength.y * params.weights.y + params.aoStrength.z * params.weights.z;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif
            return o;
         }

         half4 SampleSpecNoBlend(LayerParams params, in half4 norm, out half3 Normal)
         {
            half4 specFinal = half4(0,0,0,1);
            Normal = half3(0,0,1);
            specFinal.x = params.metallic.x;
            specFinal.y = params.smoothness.x;

            #if _NOSPECTEX
               Normal = UnpackNormal(norm); 
            #else
               specFinal.yw = norm.zw;
               specFinal.x = params.metallic.x;
               norm.xy *= 2;
               norm.xy -= 1;
               Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy))));
            #endif

            return specFinal;
         }

         MegaSplatLayer SampleLayerNoBlend(inout LayerParams params, SplatInput si)
         { 
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0;
            half4 norm0 = half4(0,0,1,1);

            tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
            fixed4 albedo = tex0;


             #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT
  

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * si.weights.x + params.parallaxStrength.y * si.weights.y + params.parallaxStrength.z * si.weights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, si.viewDir);
                  params.uv0.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0 = UNITY_SAMPLE_TEX2DARRAY(_AlphaArray, params.uv0); 
            o.Alpha = alpha0.r;
            #endif


            #if !_NOSPECNORMAL
            norm0 = UNITY_SAMPLE_TEX2DARRAY(_Normal, params.uv0); 
               #if _PERTEXNORMALSTRENGTH
               norm0.xy *= params.normalStrength.x;
               #endif
            #endif

            half4 specFinal = SampleSpecNoBlend(params, norm0, o.Normal);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            o.Emission = UNITY_SAMPLE_TEX2DARRAY(_Emissive, params.uv0).rgb; 
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif

            return o;
         }

         MegaSplatLayer BlendResults(MegaSplatLayer a, MegaSplatLayer b, half r)
         {
            a.Height = lerp(a.Height, b.Height, r);
            a.Albedo = lerp(a.Albedo, b.Albedo, r);
            #if !_NOSPECNORMAL
            a.Normal = lerp(a.Normal, b.Normal, r);
            #endif
            a.Metallic = lerp(a.Metallic, b.Metallic, r);
            a.Smoothness = lerp(a.Smoothness, b.Smoothness, r);
            a.Occlusion = lerp(a.Occlusion, b.Occlusion, r);
            a.Emission = lerp(a.Emission, b.Emission, r);
            #if _ALPHA || _ALPHATEST
            a.Alpha = lerp(a.Alpha, b.Alpha, r);
            #endif
            return a;
         }

         MegaSplatLayer OverlayResults(MegaSplatLayer splats, MegaSplatLayer macro, half r)
         {
            #if !_SPLATSONTOP
            r = 1 - r;
            #endif

            #if _ALPHA || _ALPHATEST
            splats.Alpha = min(macro.Alpha, splats.Alpha);
            #endif

            #if _MACROMULT2X
               splats.Albedo = lerp(BlendMult2X(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROOVERLAY
               splats.Albedo = lerp(BlendOverlay(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROMULT
               splats.Albedo = lerp(splats.Albedo * macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #else
               splats.Albedo = lerp(macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(macro.Normal, splats.Normal, r); 
               #endif
               splats.Occlusion = lerp(macro.Occlusion, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #endif

            return splats;
         }

         MegaSplatLayer BlendDetail(MegaSplatLayer splats, MegaSplatLayer detail, float detailBlend)
         {
            #if _DETAILMAP
            detailBlend *= _DetailTextureStrength;
            #endif
            #if _DETAILMULT2X
               splats.Albedo = lerp(detail.Albedo, BlendMult2X(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILOVERLAY
               splats.Albedo = lerp(detail.Albedo, BlendOverlay(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILMULT
               splats.Albedo = lerp(detail.Albedo, splats.Albedo * detail.Albedo, detailBlend);
            #else
               splats.Albedo = lerp(detail.Albedo, splats.Albedo, detailBlend);
            #endif 

            #if !_NOSPECNORMAL
            splats.Normal = lerp(splats.Normal, BlendNormals(splats.Normal, detail.Normal), detailBlend);
            #endif
            return splats;
         }

         float DoSnowDisplace(float splat_height, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);

            float height = splat_height * _SnowParams.x;
            float erosion = lerp(0, height, _SnowParams.y);
            float snowMask = saturate((snowFade - erosion));
            float snowMask2 = saturate((snowFade - erosion) * 8);
            snowMask *= snowMask * snowMask * snowMask * snowMask * snowMask2;
            snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));

            return snowAmount;
            #endif
            return 0;
         }

         float DoSnow(inout MegaSplatLayer o, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight, half surfPorosity, float camDist)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            #if _SNOWDISTANCERESAMPLE
            float2 snowResampleUV = uv * _SnowDistanceResampleScaleStrengthFade.x;

            if (camDist > _SnowDistanceResampleScaleStrengthFade.z)
               {
                  half4 snowAlb2 = tex2D(_SnowDiff, snowResampleUV);
                  half4 snowNsao2 = tex2D(_SnowNormal, snowResampleUV);
                  float fade = saturate ((camDist - _SnowDistanceResampleScaleStrengthFade.z) / _SnowDistanceResampleScaleStrengthFade.w);
                  fade *= _SnowDistanceResampleScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb, snowAlb2, fade);
                  snowNsao = lerp(snowNsao, snowNsao2, fade);
               }
            #endif

            #if _SNOWDISTANCENOISE
               float2 snowNoiseUV = uv * _SnowDistanceNoiseScaleStrengthFade.x;
               if (camDist > _SnowDistanceNoiseScaleStrengthFade.z)
               {
                  half4 noise = tex2D(_SnowDistanceNoise, uv * _SnowDistanceNoiseScaleStrengthFade.x);
                  float fade = saturate ((camDist - _SnowDistanceNoiseScaleStrengthFade.z) / _SnowDistanceNoiseScaleStrengthFade.w);
                  fade *= _SnowDistanceNoiseScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb.rgb, BlendMult2X(snowAlb.rgb, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  snowNsao.xy += ((noise.xy-0.25) * fade);
                  #endif
               }
            #endif



            half3 snowNormal = half3(snowNsao.xy * 2 - 1, 1);
            snowNormal.z = sqrt(1 - saturate(dot(snowNormal.xy, snowNormal.xy)));

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);
            float ao = o.Occlusion;
            if (snowFade > 0)
            {
               float height = o.Height * _SnowParams.x;
               float erosion = lerp(1-ao, (height + ao) * 0.5, _SnowParams.y);
               float snowMask = saturate((snowFade - erosion) * 8);
               snowMask *= snowMask * snowMask * snowMask;
               snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));  // up
               wetnessMask = saturate((_SnowParams.w * (4.0 * snowFade) - (height + snowNsao.b) * 0.5));
               snowAmount = saturate(snowAmount * 8);
               snowNormalAmount = snowAmount * snowAmount;

               float porosity = saturate((((1.0 - o.Smoothness) - 0.5)) / max(surfPorosity, 0.001));
               float factor = lerp(1, 0.4, porosity);

               o.Albedo *= lerp(1.0, factor, wetnessMask);
               o.Normal = lerp(o.Normal, float3(0,0,1), wetnessMask);
               o.Smoothness = lerp(o.Smoothness, 0.8, wetnessMask);

            }
            o.Albedo = lerp(o.Albedo, snowAlb.rgb, snowAmount);
            o.Normal = lerp(o.Normal, snowNormal, snowNormalAmount);
            o.Smoothness = lerp(o.Smoothness, (snowNsao.b) * _SnowParams.z, snowAmount);
            o.Occlusion = lerp(o.Occlusion, snowNsao.w, snowAmount);
            o.Height = lerp(o.Height, snowAlb.a, snowAmount);
            o.Metallic = lerp(o.Metallic, 0.01, snowAmount);
            float crystals = saturate(0.65 - snowNsao.b);
            o.Smoothness = lerp(o.Smoothness, crystals * _SnowParams.z, snowAmount);
            return snowAmount;
            #endif
            return 0;
         }

         half4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten)
         {
            return half4(s.Albedo, 1);
         }

         #if _RAMPLIGHTING
         half3 DoLightingRamp(half3 albedo, float3 normal, float3 emission, half3 lightDir, half atten)
         {
            half NdotL = dot (normal, lightDir);
            half diff = NdotL * 0.5 + 0.5;
            half3 ramp = tex2D (_Ramp, diff.xx).rgb;
            return (albedo * _LightColor0.rgb * ramp * atten) + emission;
         }

         half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) 
         {
            half4 c;
            c.rgb = DoLightingRamp(s.Albedo, s.Normal, s.Emission, lightDir, atten);
            c.a = s.Alpha;
            return c;
         }
         #endif

         void ApplyDetailNoise(inout half3 albedo, inout half3 norm, inout half smoothness, in LayerParams data, float camDist, float3 tpw)
         {
            #if _DETAILNOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv1_y.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv2_z.xy * _DetailNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DetailNoiseScaleStrengthFade.x;
               #endif


               if (camDist < _DetailNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DetailNoise, uv0) * tpw.x + 
                     tex2D(_DetailNoise, uv1) * tpw.y + 
                     tex2D(_DetailNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DetailNoise, uv).rgb;
                  #endif

                  float fade = 1.0 - ((_DetailNoiseScaleStrengthFade.z - camDist) / _DetailNoiseScaleStrengthFade.z);
                  fade = 1.0 - (fade*fade);
                  fade *= _DetailNoiseScaleStrengthFade.y;

                  #if _PERTEXNOISESTRENGTH
                  fade *= (data.detailNoiseStrength.x * data.weights.x + data.detailNoiseStrength.y * data.weights.y + data.detailNoiseStrength.z * data.weights.z);
                  #endif

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }

            }
            #endif // detail normal

            #if _DISTANCENOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv0_y.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv1_z.xy * _DistanceNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DistanceNoiseScaleStrengthFade.x;
               #endif


               if (camDist > _DistanceNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DistanceNoise, uv0) * tpw.x + 
                     tex2D(_DistanceNoise, uv1) * tpw.y + 
                     tex2D(_DistanceNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DistanceNoise, uv).rgb;
                  #endif

                  float fade = saturate ((camDist - _DistanceNoiseScaleStrengthFade.z) / _DistanceNoiseScaleStrengthFade.w);
                  fade *= _DistanceNoiseScaleStrengthFade.y;

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }
            }
            #endif
         }

         void DoGlitter(inout MegaSplatLayer splats, half shine, half reflectAmt, float3 wsNormal, float3 wsView, float2 uv)
         {
            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            half3 lightDir = normalize(_WorldSpaceLightPos0);

            half3 viewDir = normalize(wsView);
            half NdotL = saturate(dot(splats.Normal, lightDir));
            lightDir = reflect(lightDir, splats.Normal);
            half specular = saturate(abs(dot(lightDir, viewDir)));


            //float2 offset = float2(viewDir.z, wsNormal.x) + splats.Normal.xy * 0.1;
            float2 offset = splats.Normal * 0.1;
            offset = fmod(offset, 1.0);

            half detail = tex2D(_GlitterTexture, uv * _GlitterParams.xy + offset).x;

            #if _GLITTERMOVES
               float2 uv0 = uv * _GlitterParams.w + _Time.y * _GlitterParams.z;
               float2 uv1 = uv * _GlitterParams.w + _Time.y  * 1.04 * -_GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               half detail3 = tex2D(_GlitterTexture, uv1).y;
               detail *= sqrt(detail2 * detail3);
            #else
               float2 uv0 = uv * _GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               detail *= detail2;
            #endif
            detail *= saturate(splats.Height + 0.5);

            specular = pow(specular, shine) * floor(detail * reflectAmt);

            splats.Smoothness += specular;
            splats.Smoothness = min(splats.Smoothness, 1);
            #endif
         }


         LayerParams InitLayerParams(SplatInput si, float3 values, half2 texScale)
         {
            LayerParams data = NewLayerParams();
            #if _TERRAIN
            int i0 = round(values.x * 255);
            int i1 = round(values.y * 255);
            int i2 = round(values.z * 255);
            #else
            int i0 = round(values.x / max(si.weights.x, 0.00001));
            int i1 = round(values.y / max(si.weights.y, 0.00001));
            int i2 = round(values.z / max(si.weights.z, 0.00001));
            #endif

            #if _TRIPLANAR
            float3 coords = si.triplanarUVW * texScale.x;
            data.tpuv0_x = float3(coords.zy, i0);
            data.tpuv0_y = float3(coords.xz, i0);
            data.tpuv0_z = float3(coords.xy, i0);
            data.tpuv1_x = float3(coords.zy, i1);
            data.tpuv1_y = float3(coords.xz, i1);
            data.tpuv1_z = float3(coords.xy, i1);
            data.tpuv2_x = float3(coords.zy, i2);
            data.tpuv2_y = float3(coords.xz, i2);
            data.tpuv2_z = float3(coords.xy, i2);
            data.mipUV = coords.xz;

            float2 splatUV = si.splatUV * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);

            #else
            float2 splatUV = si.splatUV.xy * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);
            data.mipUV = splatUV.xy;
            #endif



            #if _FLOW || _FLOWREFRACTION
            data.flowOn = 0;
            #endif

            #if _DISTANCERESAMPLE
            InitDistanceResample(data, si.camDist.y);
            #endif

            return data;
         }

         MegaSplatLayer DoSurf(inout SplatInput si, MegaSplatLayer macro, float3x3 tangentToWorld)
         {
            #if _ALPHALAYER
            LayerParams mData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.xy);
            #else
            LayerParams mData = InitLayerParams(si, si.valuesMain.xyz, _TexScales.xy);
            #endif

            #if _ALPHAHOLE
            if (mData.uv0.z == _AlphaHoleIdx || mData.uv1.z == _AlphaHoleIdx || mData.uv2.z == _AlphaHoleIdx)
            {
               clip(-1);
            } 
            #endif

            #if _PARALLAX && (_TESSEDGE || _TESSDISTANCE || _LOWPOLY || _ALPHATEST)
            si.viewDir = mul(si.viewDir, tangentToWorld);
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT
            float2 puddleUV = si.macroUV * _PuddleUVScales.xy;
            #elif _PUDDLES
            float2 puddleUV = 0;
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT

            si.waterNormalFoam = float3(0,0,0);
            if (si.puddleHeight > 0 && si.camDist.y < 40)
            {
               float str = 1.0 - ((si.camDist.y - 20) / 20);
               si.waterNormalFoam = GetWaterNormal(puddleUV, si.flowDir) * str;
            }
            #endif

            SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

            #if _FLOWREFRACTION
            // see through
            //sampleBottom = sampleBottom || mData.flowOn > 0;
            #endif

            half porosity = _GlobalPorosityWetness.x;
            #if _PERTEXMATPARAMS
            porosity = mData.porosity.x * mData.weights.x + mData.porosity.y * mData.weights.y + mData.porosity.z * mData.weights.z;
            #endif

            #if _TWOLAYER
               LayerParams sData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.zw);

               #if _ALPHAHOLE
               if (sData.uv0.z == _AlphaHoleIdx || sData.uv1.z == _AlphaHoleIdx || sData.uv2.z == _AlphaHoleIdx)
               {
                  clip(-1);
               } 
               #endif

               sData.layerBlend = si.layerBlend;
               SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(sData.uv0, si.flowDir, _FlowSpeed * sData.flowIntensity.x, _FlowIntensity, sData.fuv0a, sData.fuv0b, sData.flowInterps.x);
                  Flow(sData.uv1, si.flowDir, _FlowSpeed * sData.flowIntensity.y, _FlowIntensity, sData.fuv1a, sData.fuv1b, sData.flowInterps.y);
                  Flow(sData.uv2, si.flowDir, _FlowSpeed * sData.flowIntensity.z, _FlowIntensity, sData.fuv2a, sData.fuv2b, sData.flowInterps.z);
                  mData.flowOn = 0;
               #endif

               MegaSplatLayer second = SampleLayer(sData, si);

               #if _FLOWREFRACTION
                  float hMod = FlowRefract(second, mData, sData, si.weights);
               #endif
            #else // _TWOLAYER

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(mData.uv0, si.flowDir, _FlowSpeed * mData.flowIntensity.x, _FlowIntensity, mData.fuv0a, mData.fuv0b, mData.flowInterps.x);
                  Flow(mData.uv1, si.flowDir, _FlowSpeed * mData.flowIntensity.y, _FlowIntensity, mData.fuv1a, mData.fuv1b, mData.flowInterps.y);
                  Flow(mData.uv2, si.flowDir, _FlowSpeed * mData.flowIntensity.z, _FlowIntensity, mData.fuv2a, mData.fuv2b, mData.flowInterps.z);
               #endif
            #endif

            #if _NOBLENDBOTTOM
               MegaSplatLayer splats = SampleLayerNoBlend(mData, si);
            #else
               MegaSplatLayer splats = SampleLayer(mData, si);
            #endif

            #if _TWOLAYER
               // blend layers together..
               float hfac = HeightBlend(splats.Height, second.Height, sData.layerBlend, _Contrast);
               #if _FLOWREFRACTION
                  hfac *= hMod;
               #endif
               splats = BlendResults(splats, second, hfac);
               porosity = lerp(porosity, 
                     sData.porosity.x * sData.weights.x + 
                     sData.porosity.y * sData.weights.y + 
                     sData.porosity.z * sData.weights.z,
                     hfac);
            #endif

            #if _GEOMAP
            float2 geoUV = float2(0, si.worldPos.y * _GeoParams.y + _GeoParams.z);
            half4 geoTex = tex2D(_GeoTex, geoUV);
            splats.Albedo = lerp(splats.Albedo, BlendMult2X(splats.Albedo, geoTex), _GeoParams.x * geoTex.a);
            #endif

            half macroBlend = 1;
            #if _USEMACROTEXTURE
            macroBlend = saturate(_MacroTextureStrength * si.camDist.x);
            #endif

            #if _DETAILMAP
               float dist = si.camDist.y;
               if (dist > _DistanceFades.w)
               {
                  MegaSplatLayer o = (MegaSplatLayer)0;
                  UNITY_INITIALIZE_OUTPUT(MegaSplatLayer,o);
                  #if _USEMACROTEXTURE
                  splats = OverlayResults(splats, macro, macroBlend);
                  #endif
                  o.Albedo = splats.Albedo;
                  o.Normal = splats.Normal;
                  o.Emission = splats.Emission;
                  o.Occlusion = splats.Occlusion;
                  #if !_RAMPLIGHTING
                  o.Metallic = splats.Metallic;
                  o.Smoothness = splats.Smoothness;
                  #endif
                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_Final(si, o);
                  #endif
                  return o;
               }

               LayerParams sData = InitLayerParams(si, si.valuesMain, _TexScales.zw);
               MegaSplatLayer second = SampleDetail(mData.weights, si.viewDir, sData, si.triplanarBlend);   // use prev weights for detail

               float detailBlend = 1.0 - saturate((dist - _DistanceFades.z) / (_DistanceFades.w - _DistanceFades.z));
               splats = BlendDetail(splats, second, detailBlend); 
            #endif

            ApplyDetailNoise(splats.Albedo, splats.Normal, splats.Smoothness, mData, si.camDist.y, si.triplanarBlend);

            float3 worldNormal = float3(0,0,1);
            #if _SNOW || _RAINDROPFLATONLY
            worldNormal = mul(tangentToWorld, normalize(splats.Normal));
            #endif

            #if _SNOWGLITTER || _PERTEXGLITTER || _PUDDLEGLITTER
            half glitterShine = 0;
            half glitterReflect = 0;
            #endif

            #if _PERTEXGLITTER
            glitterReflect = mData.perTexGlitterReflect.x * mData.weights.x + mData.perTexGlitterReflect.y * mData.weights.y + mData.perTexGlitterReflect.z * mData.weights.z;
               #if _TWOLAYER || _ALPHALAYER
               float glitterReflect2 = sData.perTexGlitterReflect.x * sData.weights.x + sData.perTexGlitterReflect.y * sData.weights.y + sData.perTexGlitterReflect.z * sData.weights.z;
               glitterReflect = lerp(glitterReflect, glitterReflect2, hfac);
               #endif
            glitterReflect *= 14;
            glitterShine = 1.5;
            #endif


            float pud = 0;
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
               if (si.puddleHeight > 0)
               {
                  pud = DoPuddles(splats, puddleUV, si.waterNormalFoam, si.puddleHeight, si.flowDir, porosity, worldNormal);
               }
            #endif

            #if _LAVA
               float2 lavaUV = si.macroUV * _LavaUVScale.xy;


               if (si.puddleHeight > 0)
               {
                  pud = DoLava(splats, lavaUV, si.puddleHeight, si.flowDir);
               }
            #endif

            #if _PUDDLEGLITTER
            glitterShine = lerp(glitterShine, _GlitterSurfaces.z, pud);
            glitterReflect = lerp(glitterReflect, _GlitterSurfaces.w, pud);
            #endif


            #if _SNOW && !_SNOWOVERMACRO
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOW && _SNOWOVERMACRO
            half preserveAO = splats.Occlusion;
            #endif

            #if _WETNESS
            WaterBRDF(splats.Albedo, splats.Smoothness, splats.Metallic, max( si.wetness, _GlobalPorosityWetness.y) * _MaxWetness, porosity); 
            #endif


            #if _ALPHALAYER
            half blend = HeightBlend(splats.Height, 1 - macro.Height, si.layerBlend * macroBlend, _Contrast);
            splats = OverlayResults(splats, macro, blend);
            #elif _USEMACROTEXTURE
            splats = OverlayResults(splats, macro, macroBlend);
            #endif

            #if _SNOW && _SNOWOVERMACRO
               splats.Occlusion = preserveAO;
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            DoGlitter(splats, glitterShine, glitterReflect, si.wsNormal, si.wsView, si.macroUV);
            #endif

            #if _CUSTOMUSERFUNCTION
            CustomMegaSplatFunction_Final(si, splats);
            #endif

            return splats;
         }

         #if _DEBUG_OUTPUT_SPLATDATA
         float3 DebugSplatOutput(SplatInput si)
         {
            float3 data = float3(0,0,0);
            int i0 = round(si.valuesMain.x / max(si.weights.x, 0.00001));
            int i1 = round(si.valuesMain.y / max(si.weights.y, 0.00001));
            int i2 = round(si.valuesMain.z / max(si.weights.z, 0.00001));

            #if _TWOLAYER || _ALPHALAYER
            int i3 = round(si.valuesSecond.x / max(si.weights.x, 0.00001));
            int i4 = round(si.valuesSecond.y / max(si.weights.y, 0.00001));
            int i5 = round(si.valuesSecond.z / max(si.weights.z, 0.00001));
            data.z = si.layerBlend;
            #endif

            if (si.weights.x > si.weights.y && si.weights.x > si.weights.z)
            {
               data.x = i0 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i3 / 255.0;
               #endif
            }
            else if (si.weights.y > si.weights.x && si.weights.y > si.weights.z)
            {
               data.x = i1 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i4 / 255.0;
               #endif
            }
            else
            {
               data.x = i2 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i5 / 255.0;
               #endif
            }
            return data;
         }
         #endif

 
            UnityLight AdditiveLight (half3 normalWorld, half3 lightDir, half atten)
            {
               UnityLight l;

               l.color = _LightColor0.rgb;
               l.dir = lightDir;
               #ifndef USING_DIRECTIONAL_LIGHT
                  l.dir = normalize(l.dir);
               #endif
               l.ndotl = LambertTerm (normalWorld, l.dir);

               // shadow the light
               l.color *= atten;
               return l;
            }

            UnityLight MainLight (half3 normalWorld)
            {
               UnityLight l;
               #ifdef LIGHTMAP_OFF
                  
                  l.color = _LightColor0.rgb;
                  l.dir = _WorldSpaceLightPos0.xyz;
                  l.ndotl = LambertTerm (normalWorld, l.dir);
               #else
                  // no light specified by the engine
                  // analytical light might be extracted from Lightmap data later on in the shader depending on the Lightmap type
                  l.color = half3(0.f, 0.f, 0.f);
                  l.ndotl  = 0.f;
                  l.dir = half3(0.f, 0.f, 0.f);
               #endif

               return l;
            }

            inline half4 VertexGIForward(float2 uv1, float2 uv2, float3 posWorld, half3 normalWorld)
            {
               half4 ambientOrLightmapUV = 0;
               // Static lightmaps
               #ifdef LIGHTMAP_ON
                  ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                  ambientOrLightmapUV.zw = 0;
               // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
               #elif UNITY_SHOULD_SAMPLE_SH
                  #ifdef VERTEXLIGHT_ON
                     // Approximated illumination from non-important point lights
                     ambientOrLightmapUV.rgb = Shade4PointLights (
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, posWorld, normalWorld);
                  #endif

                  ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);     
               #endif

               #ifdef DYNAMICLIGHTMAP_ON
                  ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
               #endif

               return ambientOrLightmapUV;
            }

            void LightPBRDeferred(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic,
                           half occlusion, half alpha, float3 viewDir,
                           inout half3 indirectDiffuse, inout half3 indirectSpecular, inout half3 diffuseColor, inout half3 specularColor)
            {
               #if _PASSDEFERRED
               half lightAtten = 1;
               half roughness = 1 - smoothness;

               UnityLight light = MainLight (normalDirection);

               UnityGIInput d;
               UNITY_INITIALIZE_OUTPUT(UnityGIInput, d);
               d.light = light;
               d.worldPos = i.posWorld.xyz;
               d.worldViewDir = viewDir;
               d.atten = lightAtten;
               #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                  d.ambient = 0;
                  d.lightmapUV = i.ambientOrLightmapUV;
               #else
                  d.ambient = i.ambientOrLightmapUV.rgb;
                  d.lightmapUV = 0;
               #endif
               d.boxMax[0] = unity_SpecCube0_BoxMax;
               d.boxMin[0] = unity_SpecCube0_BoxMin;
               d.probePosition[0] = unity_SpecCube0_ProbePosition;
               d.probeHDR[0] = unity_SpecCube0_HDR;
               d.boxMax[1] = unity_SpecCube1_BoxMax;
               d.boxMin[1] = unity_SpecCube1_BoxMin;
               d.probePosition[1] = unity_SpecCube1_ProbePosition;
               d.probeHDR[1] = unity_SpecCube1_HDR;

               UnityGI gi = UnityGlobalIllumination(d, occlusion, 1.0 - smoothness, normalDirection );

               specularColor = metallic.xxx;
               float specularMonochrome;
               diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, specularMonochrome );

               indirectSpecular = (gi.indirect.specular);
               float NdotV = max(0.0,dot( normalDirection, viewDir ));
               specularMonochrome = 1.0-specularMonochrome;
               half grazingTerm = saturate( smoothness + specularMonochrome );
               indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
               indirectDiffuse = half3(0,0,0);
               indirectDiffuse += gi.indirect.diffuse;
               indirectDiffuse *= occlusion;

               #endif
            }


            half4 LightPBR(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic, 
                            half occlusion, half alpha, float3 viewDir, float4 ambientOrLightmapUV)
            {
                

                #if _PASSFORWARDBASE
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG(i.fogCoord, ramped);
                   return ramped;
                }
                #endif

                UnityLight light = MainLight (normalDirection);

                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDir;
                d.atten = lightAtten;
                #if LIGHTMAP_ON || DYNAMICLIGHTMAP_ON
                    d.ambient = 0;
                    d.lightmapUV = i.ambientOrLightmapUV;
                #else
                    d.ambient = i.ambientOrLightmapUV;
                    d.lightmapUV = 0;
                #endif

                d.boxMax[0] = unity_SpecCube0_BoxMax;
                d.boxMin[0] = unity_SpecCube0_BoxMin;
                d.probePosition[0] = unity_SpecCube0_ProbePosition;
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.boxMax[1] = unity_SpecCube1_BoxMax;
                d.boxMin[1] = unity_SpecCube1_BoxMin;
                d.probePosition[1] = unity_SpecCube1_ProbePosition;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = roughness;
                ugls_en_data.reflUVW = reflect( -viewDir, normalDirection );
                UnityGI gi = UnityGlobalIllumination(d, occlusion, normalDirection, ugls_en_data );

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, oneMinusReflectivity );
                

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, gi.light, gi.indirect);
                c.rgb += UNITY_BRDF_GI (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, occlusion, gi);
                c.rgb += emission;
                c.a = alpha;
                UNITY_APPLY_FOG(i.fogCoord, c.rgb);
                return c;

                #elif _PASSFORWARDADD
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG_COLOR(i.fogCoord, ramped.rgb, half4(0,0,0,0));
                   return ramped;
                }
                #endif

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, oneMinusReflectivity );

                UnityLight light = AdditiveLight (normalDirection, normalDirection, lightAtten);
                UnityIndirect noIndirect = (UnityIndirect)0;
                noIndirect.diffuse = 0;
                noIndirect.specular = 0;

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, light, noIndirect);
   
                UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
                c.a = alpha;
                return c;

                #endif
                return half4(1, 1, 0, 0);
            }

            float4 _SplatControl_TexelSize;

            struct VertexInput 
            {
                float4 vertex        : POSITION;
                float3 normal        : NORMAL;
                float2 texcoord0     : TEXCOORD0;
                #if !_PASSSHADOWCASTER && !_PASSMETA
                    float2 texcoord1 : TEXCOORD1;
                    float2 texcoord2 : TEXCOORD2;
                #endif
            };

            VirtualMapping GetMapping(VertexOutput i, sampler2D splatControl, sampler2D paramControl)
            {
               float2 texSize = _SplatControl_TexelSize.zw;
               float2 stp = _SplatControl_TexelSize.xy;
               // scale coords so we can take floor/frac to construct a cell
               float2 stepped = i.coords.xy * texSize;
               float2 uvBottom = floor(stepped);
               float2 uvFrac = frac(stepped);
               uvBottom /= texSize;

               float2 center = stp * 0.5;
               uvBottom += center;

               // construct uv/positions of triangle based on our interpolation point
               float2 cuv0, cuv1, cuv2;
               // make virtual triangle
               if (uvFrac.x > uvFrac.y)
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(stp.x, 0);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }
               else
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(0, stp.y);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }

               float2 uvBaryFrac = uvFrac * stp + uvBottom;
               float3 weights = Barycentric(uvBaryFrac, cuv0, cuv1, cuv2);
               VirtualMapping m = (VirtualMapping)0;
               m.weights = weights;
               m.c0 = tex2Dlod(splatControl, float4(cuv0, 0, 0));
               m.c1 = tex2Dlod(splatControl, float4(cuv1, 0, 0));
               m.c2 = tex2Dlod(splatControl, float4(cuv2, 0, 0));

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS || _FLOW || _FLOWREFRACTION || _LAVA
               fixed4 p0 = tex2Dlod(paramControl, float4(cuv0, 0, 0));
               fixed4 p1 = tex2Dlod(paramControl, float4(cuv1, 0, 0));
               fixed4 p2 = tex2Dlod(paramControl, float4(cuv2, 0, 0));
               m.param = p0 * weights.x + p1 * weights.y + p2 * weights.z;
               #endif
               return m;
            }

            SplatInput ToSplatInput(VertexOutput i, VirtualMapping m)
            {
               SplatInput o = (SplatInput)0;
               UNITY_INITIALIZE_OUTPUT(SplatInput,o);

               o.camDist = i.camDist;
               o.splatUV = i.coords;
               o.macroUV = i.coords;
               #if _SECONDUV
               o.macroUV = i.macroUV;
               #endif
               o.weights = m.weights;


               o.valuesMain = float3(m.c0.r, m.c1.r, m.c2.r);
               #if _TWOLAYER || _ALPHALAYER
               o.valuesSecond = float3(m.c0.g, m.c1.g, m.c2.g);
               o.layerBlend = m.c0.b * o.weights.x + m.c1.b * o.weights.y + m.c2.b * o.weights.z;
               #endif

               #if _TRIPLANAR
               o.triplanarUVW = i.triplanarUVW;
               o.triplanarBlend = i.extraData.xyz;
               #endif

               #if _FLOW || _FLOWREFRACTION || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.flowDir = m.param.xy;
               #endif

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.puddleHeight = m.param.a;
               #endif

               #if _WETNESS
               o.wetness = m.param.b;
               #endif

               #if _GEOMAP
               o.worldPos = i.posWorld;
               #endif

               return o;
            }

            LayerParams GetMainParams(VertexOutput i, inout VirtualMapping m, half2 texScale)
            {
               
               int i0 = (int)(m.c0.r * 255);
               int i1 = (int)(m.c1.r * 255);
               int i2 = (int)(m.c2.r * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               data.layerBlend = m.weights.x * m.c0.b + m.weights.y * m.c1.b + m.weights.z * m.c2.b;

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;
            }

            LayerParams GetSecondParams(VertexOutput i, VirtualMapping m, half2 texScale)
            {
               int i0 = (int)(m.c0.g * 255);
               int i1 = (int)(m.c1.g * 255);
               int i2 = (int)(m.c2.g * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;   
            }


            VertexOutput NoTessVert(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;

               o.tangent.xyz = cross(v.normal, float3(0,0,1));
               float4 tangent = float4(o.tangent, 1);
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(o.tangent, 1);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  o.tangent = tangent.xyz;
                  #endif
               }

               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(o.tangent, 1);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  o.tangent = tangent.xyz;
                  #endif
               }

               UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

               o.normal = UnityObjectToWorldNormal(v.normal);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

               o.coords.xy = v.texcoord0;
               #if _SECONDUV
               o.macroUV = v.texcoord0;
               o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
               #endif

               o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);


               #if !_PASSSHADOWCASTER && !_PASSMETA
               o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
               #endif

               float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
               o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
               float3 viewSpace = UnityObjectToViewPos(v.vertex);
               o.camDist.y = length(viewSpace.xyz);
               #if _TRIPLANAR
                  float3 norm = v.normal;
                  #if _TRIPLANAR_WORLDSPACE
                  o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                  norm = normalize(mul(unity_ObjectToWorld, norm));
                  #else
                  o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                  #endif
                  o.extraData.xyz = pow(abs(norm), _TriplanarContrast);
               #endif


               o.bitangent = normalize(cross(o.normal, o.tangent) * -1);  
               

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #elif !_PASSMETA && !_PASSDEFERRED
               UNITY_TRANSFER_FOG(o,o.pos);
               TRANSFER_VERTEX_TO_FRAGMENT(o)
               #endif
               return o;
            }


            #if _TESSDISTANCE || _TESSEDGE
            VertexOutput NoTessShadowVertBiased(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(0,0,0,0);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  #endif
               }
               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(0,0,0,0);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  #endif
                  UNITY_INITIALIZE_OUTPUT(VertexOutput,o);
               }
             
               o.normal = UnityObjectToWorldNormal(v.normal);
               v.vertex.xyz -= o.normal * _TessData1.yyy * half3(0.5, 0.5, 0.5);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.coords = v.texcoord0;

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #endif

               return o;
            }
            #endif

            #ifdef UNITY_CAN_COMPILE_TESSELLATION
            #if _TESSDISTANCE || _TESSEDGE 
            struct TessVertex 
            {
                 float4 vertex       : INTERNALTESSPOS;
                 float3 normal       : NORMAL;
                 float2 coords       : TEXCOORD0;      // uv, or triplanar UV
                 #if _TRIPLANAR
                 float3 triplanarUVW : TEXCOORD1;
                 float4 extraData    : TEXCOORD2;
                 #endif
                 float4 camDist      : TEXCOORD3;      // distance from camera (for fades) and fog

                 float3 posWorld     : TEXCOORD4;
                 float4 tangent      : TEXCOORD5;
                 float2 macroUV      : TEDCOORD6;
                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    LIGHTING_COORDS(7,8)
                    UNITY_FOG_COORDS(9)
                 #endif
                 float4 ambientOrLightmapUV : TEXCOORD10;
 
             };


            VertexOutput vert (TessVertex v) 
            {
                VertexOutput o = (VertexOutput)0;

                UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

                #if _CUSTOMUSERFUNCTION
                CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, v.tangent, v.coords.xy);
                #endif
                #if _USECURVEDWORLD
                V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                #endif

                o.ambientOrLightmapUV = v.ambientOrLightmapUV;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangent = normalize(cross(o.normal, o.tangent) * v.tangent.w);  
                o.pos = UnityObjectToClipPos(v.vertex);
                o.coords = v.coords;
                o.camDist = v.camDist;
                o.posWorld = v.posWorld;
                #if _SECONDUV
                o.macroUV = v.macroUV;
                #endif

                #if _TRIPLANAR
                o.triplanarUVW = v.triplanarUVW;
                o.extraData = v.extraData;
                #endif

                #if _PASSSHADOWCASTER
                TRANSFER_SHADOW_CASTER(o)
                #elif !_PASSMETA && !_PASSDEFERRED
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                #endif

                return o;
            }


                
             struct OutputPatchConstant {
                 float edge[3]         : SV_TessFactor;
                 float inside          : SV_InsideTessFactor;
                 float3 vTangent[4]    : TANGENT;
                 float2 vUV[4]         : TEXCOORD;
                 float3 vTanUCorner[4] : TANUCORNER;
                 float3 vTanVCorner[4] : TANVCORNER;
                 float4 vCWts          : TANWEIGHTS;
             };

             TessVertex tessvert (VertexInput v) 
             {
                 TessVertex o;
                 UNITY_INITIALIZE_OUTPUT(TessVertex,o);
                 #if _USECURVEDWORLD
                 V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                 #endif

                 o.vertex = v.vertex;
                 o.normal = v.normal;
                 o.coords.xy = v.texcoord0;
                 o.normal = UnityObjectToWorldNormal(v.normal);
                 o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

                 float4 tangent = float4(o.tangent.xyz, 1);
                 #if _SECONDUV
                 o.macroUV = v.texcoord0;
                 o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
                 #endif

                 o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);



                 #if !_PASSSHADOWCASTER && !_PASSMETA
                 o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
                 #endif

                 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
                 o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
                 float3 viewSpace = UnityObjectToViewPos(v.vertex);
                 o.camDist.y = length(viewSpace.xyz);
                 #if _TRIPLANAR
                    #if _TRIPLANAR_WORLDSPACE
                    o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #else
                    o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #endif
                    o.extraData.xyz = pow(abs(v.normal), _TriplanarContrast);
                 #endif

                 o.tangent.xyz = cross(v.normal, float3(0,0,1));
                 o.tangent.w = -1;

                 float tessFade = saturate((dist - _TessData2.x) / (_TessData2.y - _TessData2.x));
                 tessFade *= tessFade;
                 o.camDist.w = 1 - tessFade;

                 return o;
             }

             void displacement (inout TessVertex i)
             {
                  VertexOutput o = vert(i);
                  float3 viewDir = float3(0,0,1);

                  VirtualMapping mapping = GetMapping(o, _SplatControl, _SplatParams);
                  LayerParams mData = GetMainParams(o, mapping, _TexScales.xy);
                  SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

                  half3 extraData = float3(0,0,0);
                  #if _TRIPLANAR
                  extraData = o.extraData.xyz;
                  #endif

                  #if _TWOLAYER || _DETAILMAP
                  LayerParams sData = GetSecondParams(o, mapping, _TexScales.zw);
                  sData.layerBlend = mData.layerBlend;
                  SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);
                  float second = SampleLayerHeight(mapping.weights, viewDir, sData, extraData.xyz, _TessData1.z, _TessData2.z);
                  #endif

                  float splats = SampleLayerHeight(mapping.weights, viewDir, mData, extraData.xyz, _TessData1.z, _TessData2.z);

                  #if _TWOLAYER
                     // blend layers together..
                     float hfac = HeightBlend(splats, second, sData.layerBlend, _TessData2.z);
                     splats = lerp(splats, second, hfac);
                  #endif

                  half upBias = _TessData2.w;
                  #if _PERTEXDISPLACEPARAMS
                  float3 upBias3 = mData.upBias;
                     #if _TWOLAYER
                        upBias3 = lerp(upBias3, sData.upBias, hfac);
                     #endif
                  upBias = upBias3.x * mapping.weights.x + upBias3.y * mapping.weights.y + upBias3.z * mapping.weights.z;
                  #endif

                  #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
                     #if _PUDDLESPUSHTERRAIN
                     splats = max(splats - mapping.param.a, 0);
                     #else
                     splats = max(splats, mapping.param.a);
                     #endif
                  #endif

                  #if _TESSCENTERBIAS
                  splats -= 0.5;
                  #endif

                  #if _SNOW
                  float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                  float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                  float snowHeightFade = saturate((worldPos.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
                  splats += DoSnowDisplace(splats, i.coords.xy, worldNormal, snowHeightFade, mapping.param.a);
                  #endif

                  float3 offset = (lerp(i.normal, float3(0,1,0), upBias) * (i.camDist.w * _TessData1.y * splats));

                  #if _TESSDAMPENING
                  offset *= (mapping.c0.a * mapping.weights.x + mapping.c1.a * mapping.weights.y + mapping.c2.a * mapping.weights.z);
                  #endif

                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_PostDisplacement(i.vertex.xyz, offset, i.normal, i.tangent, i.coords.xy);
                  #else
                  i.vertex.xyz += offset;
                  #endif

             }

             #if _TESSEDGE
             float4 Tessellation(TessVertex v, TessVertex v1, TessVertex v2)
             {
                 return UnityEdgeLengthBasedTess(v.vertex, v1.vertex, v2.vertex, _TessData1.w);
             }
             #elif _TESSDISTANCE
             float4 Tessellation (TessVertex v0, TessVertex v1, TessVertex v2) 
             {
                return MegaSplatDistanceBasedTess( v0.camDist.w, v1.camDist.w, v2.camDist.w, _TessData1.x );
             }
             #endif

             OutputPatchConstant hullconst (InputPatch<TessVertex,3> v) {
                 OutputPatchConstant o = (OutputPatchConstant)0;
                 float4 ts = Tessellation( v[0], v[1], v[2] );
                 o.edge[0] = ts.x;
                 o.edge[1] = ts.y;
                 o.edge[2] = ts.z;
                 o.inside = ts.w;
                 return o;
             }
             [UNITY_domain("tri")]
             [UNITY_partitioning("fractional_odd")]
             [UNITY_outputtopology("triangle_cw")]
             [UNITY_patchconstantfunc("hullconst")]
             [UNITY_outputcontrolpoints(3)]
             TessVertex hull (InputPatch<TessVertex,3> v, uint id : SV_OutputControlPointID) 
             {
                 return v[id];
             }

             [UNITY_domain("tri")]
             VertexOutput domain (OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> vi, float3 bary : SV_DomainLocation) 
             {
                 TessVertex v = (TessVertex)0;
                 v.vertex =         vi[0].vertex * bary.x +       vi[1].vertex * bary.y +       vi[2].vertex * bary.z;
                 v.normal =         vi[0].normal * bary.x +       vi[1].normal * bary.y +       vi[2].normal * bary.z;
                 v.coords =         vi[0].coords * bary.x +       vi[1].coords * bary.y +       vi[2].coords * bary.z;
                 v.camDist =        vi[0].camDist * bary.x +      vi[1].camDist * bary.y +      vi[2].camDist * bary.z;
                 #if _TRIPLANAR
                 v.extraData =      vi[0].extraData * bary.x +    vi[1].extraData * bary.y +    vi[2].extraData * bary.z;
                 v.triplanarUVW =   vi[0].triplanarUVW * bary.x + vi[1].triplanarUVW * bary.y + vi[2].triplanarUVW * bary.z; 
                 #endif
                 v.tangent =        vi[0].tangent * bary.x +      vi[1].tangent * bary.y +      vi[2].tangent * bary.z;
                 v.macroUV =        vi[0].macroUV * bary.x +      vi[1].macroUV * bary.y +      vi[2].macroUV * bary.z;
                 v.posWorld =       vi[0].posWorld * bary.x +     vi[1].posWorld * bary.y +     vi[2].posWorld * bary.z;

                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    #if FOG_LINEAR || FOG_EXP || FOG_EXP2
                       v.fogCoord = vi[0].fogCoord * bary.x + vi[1].fogCoord * bary.y + vi[2].fogCoord * bary.z;
                    #endif
                    #if  SPOT || POINT_COOKIE || DIRECTIONAL_COOKIE 
                       v._LightCoord = vi[0]._LightCoord * bary.x + vi[1]._LightCoord * bary.y + vi[2]._LightCoord * bary.z; 
                       #if (SHADOWS_DEPTH && SPOT) || SHADOWS_CUBE || SHADOWS_DEPTH
                          v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y * vi[2]._ShadowCoord * bary.z; 
                       #endif
                    #elif DIRECTIONAL && (SHADOWS_CUBE || SHADOWS_DEPTH)
                       v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y + vi[2]._ShadowCoord * bary.z; 
                    #endif
                 #endif
                 v.ambientOrLightmapUV = vi[0].ambientOrLightmapUV * bary.x + vi[1].ambientOrLightmapUV * bary.y + vi[2].ambientOrLightmapUV * bary.z;

                 #if _TESSPHONG
                 float3 p = v.vertex.xyz;

                 // Calculate deltas to project onto three tangent planes
                 float3 p0 = dot(vi[0].vertex.xyz - p, vi[0].normal) * vi[0].normal;
                 float3 p1 = dot(vi[1].vertex.xyz - p, vi[1].normal) * vi[1].normal;
                 float3 p2 = dot(vi[2].vertex.xyz - p, vi[2].normal) * vi[2].normal;

                 // Lerp between projection vectors
                 float3 vecOffset = bary.x * p0 + bary.y * p1 + bary.z * p2;

                 // Add a fraction of the offset vector to the lerped position
                 p += 0.5 * vecOffset;

                 v.vertex.xyz = p;
                 #endif

                 displacement(v);
                 VertexOutput o = vert(v);
                 return o;
             }
            #endif
            #endif

            struct LightingTerms
            {
               half3 Albedo;
               half3 Normal;
               half  Smoothness;
               half  Metallic;
               half  Occlusion;
               half3 Emission;
               #if _ALPHA || _ALPHATEST
               half Alpha;
               #endif
            };

            void Splat(VertexOutput i, inout LightingTerms o, float3 viewDir, float3x3 tangentTransform)
            {
               VirtualMapping mapping = GetMapping(i, _SplatControl, _SplatParams);
               SplatInput si = ToSplatInput(i, mapping);
               si.viewDir = viewDir;
               #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
               si.wsView = viewDir;
               #endif

               MegaSplatLayer macro = (MegaSplatLayer)0;
               #if _SNOW
               float snowHeightFade = saturate((i.posWorld.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
               #endif

               #if _USEMACROTEXTURE || _ALPHALAYER
                  float2 muv = i.coords.xy;

                  #if _SECONDUV
                  muv = i.macroUV.xy;
                  #endif
                  macro = SampleMacro(muv);
                  #if _SNOW && _SNOWOVERMACRO

                  DoSnow(macro, muv, mul(tangentTransform, normalize(macro.Normal)), snowHeightFade, 0, _GlobalPorosityWetness.x, i.camDist.y);
                  #endif

                  #if _DISABLESPLATSINDISTANCE
                  if (i.camDist.x <= 0.0)
                  {
                     #if _CUSTOMUSERFUNCTION
                     CustomMegaSplatFunction_Final(si, macro);
                     #endif
                     o.Albedo = macro.Albedo;
                     o.Normal = macro.Normal;
                     o.Emission = macro.Emission;
                     #if !_RAMPLIGHTING
                     o.Smoothness = macro.Smoothness;
                     o.Metallic = macro.Metallic;
                     o.Occlusion = macro.Occlusion;
                     #endif
                     #if _ALPHA || _ALPHATEST
                     o.Alpha = macro.Alpha;
                     #endif

                     return;
                  }
                  #endif
               #endif

               #if _SNOW
               si.snowHeightFade = snowHeightFade;
               #endif

               MegaSplatLayer splats = DoSurf(si, macro, tangentTransform);

               #if _DEBUG_OUTPUT_ALBEDO
               o.Albedo = splats.Albedo;
               #elif _DEBUG_OUTPUT_HEIGHT
               o.Albedo = splats.Height.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_NORMAL
               o.Albedo = splats.Normal * 0.5 + 0.5 * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SMOOTHNESS
               o.Albedo = splats.Smoothness.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_METAL
               o.Albedo = splats.Metallic.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_AO
               o.Albedo = splats.Occlusion.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_EMISSION
               o.Albedo = splats.Emission * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SPLATDATA
               o.Albedo = DebugSplatOutput(si);
               #else
               o.Albedo = splats.Albedo;
               o.Normal = splats.Normal;
               o.Metallic = splats.Metallic;
               o.Smoothness = splats.Smoothness;
               o.Occlusion = splats.Occlusion;
               o.Emission = splats.Emission;
                  
               #endif

               #if _ALPHA || _ALPHATEST
                  o.Alpha = splats.Alpha;
               #endif
            }



            #if _PASSMETA
            half4 frag(VertexOutput i) : SV_Target 
            {
                i.normal = normalize(i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normal;
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );

                LightingTerms lt = (LightingTerms)0;

                float3x3 tangentTransform = (float3x3)0;
                #if _SNOW
                tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                #endif

                Splat(i, lt, viewDirection, tangentTransform);

                o.Emission = lt.Emission;
                
                float3 diffColor = lt.Albedo;
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, lt.Metallic, specColor, specularMonochrome );
                float roughness = 1.0 - lt.Smoothness;
                o.Albedo = diffColor + specColor * roughness * roughness * 0.5;
                return UnityMetaFragment( o );

            }
            #elif _PASSSHADOWCASTER
            half4 frag(VertexOutput i) : COLOR
            {
               SHADOW_CASTER_FRAGMENT(i)
            }
            #elif _PASSDEFERRED
            void frag(
                VertexOutput i,
                out half4 outDiffuse : SV_Target0,
                out half4 outSpecSmoothness : SV_Target1,
                out half4 outNormal : SV_Target2,
                out half4 outEmission : SV_Target3 )
            {
                i.normal = normalize(i.normal);
                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;
                Splat(i, o, viewDirection, tangentTransform);
                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif
                float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                
                half3 specularColor;
                half3 diffuseColor;
                half3 indirectDiffuse;
                half3 indirectSpecular;
                LightPBRDeferred(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, 
                  indirectDiffuse, indirectSpecular, diffuseColor, specularColor);
                
                outSpecSmoothness = half4(specularColor, o.Smoothness);
                outEmission = half4( o.Emission, 1 );
                outEmission.rgb += indirectSpecular * o.Occlusion;
                outEmission.rgb += indirectDiffuse * diffuseColor;
                #ifndef UNITY_HDR_ON
                    outEmission.rgb = exp2(-outEmission.rgb);
                #endif
                outDiffuse = half4(diffuseColor, o.Occlusion);
                outNormal = half4( normalDirection * 0.5 + 0.5, 1 );



            }
            #else
            half4 frag(VertexOutput i) : COLOR 
            {

                i.normal = normalize(i.normal);

                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;

                Splat(i, o, viewDirection, tangentTransform);

                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif

                #if _DEBUG_OUTPUT_ALBEDO || _DEBUG_OUTPUT_HEIGHT || _DEBUG_OUTPUT_NORMAL || _DEBUG_OUTPUT_SMOOTHNESS || _DEBUG_OUTPUT_METAL || _DEBUG_OUTPUT_AO || _DEBUG_OUTPUT_EMISSION
                   return half4(o.Albedo,1);
                #else
                   float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                   half4 lit = LightPBR(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, i.ambientOrLightmapUV);
                   #if _ALPHA || _ALPHATEST
                   lit.a = o.Alpha;
                   #endif
                   return lit;
                #endif

            }
            #endif


            #if _LOWPOLY
            [maxvertexcount(3)]
            void geom(triangle VertexOutput input[3], inout TriangleStream<VertexOutput> s)
            {
               VertexOutput v0 = input[0];
               VertexOutput v1 = input[1];
               VertexOutput v2 = input[2];

               float3 norm = input[0].normal + input[1].normal + input[2].normal;
               norm /= 3;
               float3 tangent = input[0].tangent + input[1].tangent + input[2].tangent;
               tangent /= 3;
              
               float3 bitangent = input[0].bitangent + input[1].bitangent + input[2].bitangent;
               bitangent /= 3;

               #if _LOWPOLYADJUST
               v0.normal = lerp(v0.normal, norm, _EdgeHardness);
               v1.normal = lerp(v1.normal, norm, _EdgeHardness);
               v2.normal = lerp(v2.normal, norm, _EdgeHardness);
              
               v0.tangent = lerp(v0.tangent, tangent, _EdgeHardness);
               v1.tangent = lerp(v1.tangent, tangent, _EdgeHardness);
               v2.tangent = lerp(v2.tangent, tangent, _EdgeHardness);
              
               v0.bitangent = lerp(v0.bitangent, bitangent, _EdgeHardness);;
               v1.bitangent = lerp(v1.bitangent, bitangent, _EdgeHardness);;
               v2.bitangent = lerp(v2.bitangent, bitangent, _EdgeHardness);;
               #else
               v0.normal = norm;
               v1.normal = norm;
               v2.normal = norm;
              
               v0.tangent = tangent;
               v1.tangent = tangent;
               v2.tangent = tangent;
              
               v0.bitangent = bitangent;
               v1.bitangent = bitangent;
               v2.bitangent = bitangent;
               #endif


               s.Append(v0);
               s.Append(v1);
               s.Append(v2);
            }
            #endif
            ENDCG
        }


      Pass 
      {
         Name "FORWARD"
         Tags { "LightMode"="ForwardBase" }
      
         CGPROGRAM
         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "Tessellation.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"
         #include "UnityMetaPass.cginc"

         #pragma exclude_renderers d3d9
         #define UNITY_PASS_FORWARDBASE
         #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
         #define _GLOSSYENV 1

         #pragma multi_compile_fwdbase_fullshadows
         #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
         #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
         #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
         #pragma multi_compile_fog
          
         #pragma target 4.6
         #define _PASSFORWARDBASE 1

         #pragma hull hull
         #pragma domain domain
         #pragma vertex tessvert
         #pragma fragment frag

      #define _NORMALMAP 1
      #define _PERTEXAOSTRENGTH 1
      #define _PERTEXCONTRAST 1
      #define _PERTEXDISPLACEPARAMS 1
      #define _PERTEXGLITTER 1
      #define _PERTEXMATPARAMS 1
      #define _PERTEXNORMALSTRENGTH 1
      #define _PERTEXUV 1
      #define _PUDDLEGLITTER 1
      #define _PUDDLES 1
      #define _PUDDLESPUSHTERRAIN 1
      #define _TERRAIN 1
      #define _TESSCENTERBIAS 1
      #define _TESSDAMPENING 1
      #define _TESSDISTANCE 1
      #define _TESSFALLBACK 1
      #define _TWOLAYER 1
      #define _WETNESS 1



         struct MegaSplatLayer
         {
            half3 Albedo;
            half3 Normal;
            half3 Emission;
            half  Metallic;
            half  Smoothness;
            half  Occlusion;
            half  Height;
            half  Alpha;
         };

         struct SplatInput
         {
            float3 weights;
            float2 splatUV;
            float2 macroUV;
            float3 valuesMain;
            half3 viewDir;
            float4 camDist;

            #if _TWOLAYER || _ALPHALAYER
            float3 valuesSecond;
            half layerBlend;
            #endif

            #if _TRIPLANAR
            float3 triplanarUVW;
            #endif
            half3 triplanarBlend; // passed to func, so always present

            #if _FLOW || _FLOWREFRACTION || _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half2 flowDir;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half puddleHeight;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            float3 waterNormalFoam;
            #endif

            #if _WETNESS
            half wetness;
            #endif

            #if _TESSDAMPENING
            half displacementDampening;
            #endif

            #if _SNOW
            half snowHeightFade;
            #endif

            #if _SNOW || _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsNormal;
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsView;
            #endif

            #if _GEOMAP
            float3 worldPos;
            #endif
         };


         struct LayerParams
         {
            float3 uv0, uv1, uv2;
            float2 mipUV; // uv for mip selection
            #if _TRIPLANAR
            float3 tpuv0_x, tpuv0_y, tpuv0_z;
            float3 tpuv1_x, tpuv1_y, tpuv1_z;
            float3 tpuv2_x, tpuv2_y, tpuv2_z;
            #endif
            #if _FLOW || _FLOWREFRACTION
            float3 fuv0a, fuv0b;
            float3 fuv1a, fuv1b;
            float3 fuv2a, fuv2b;
            #endif

            #if _DISTANCERESAMPLE
               half distanceBlend;
               float3 db_uv0, db_uv1, db_uv2;
               #if _TRIPLANAR
               float3 db_tpuv0_x, db_tpuv0_y, db_tpuv0_z;
               float3 db_tpuv1_x, db_tpuv1_y, db_tpuv1_z;
               float3 db_tpuv2_x, db_tpuv2_y, db_tpuv2_z;
               #endif
            #endif

            half layerBlend;
            half3 metallic;
            half3 smoothness;
            half3 porosity;
            #if _FLOW || _FLOWREFRACTION
            half3 flowIntensity;
            half flowOn;
            half3 flowAlphas;
            half3 flowRefracts;
            half3 flowInterps;
            #endif
            half3 weights;

            #if _TESSDISTANCE || _TESSEDGE
            half3 displacementScale;
            half3 upBias;
            #endif

            #if _PERTEXNOISESTRENGTH
            half3 detailNoiseStrength;
            #endif

            #if _PERTEXNORMALSTRENGTH
            half3 normalStrength;
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            half3 parallaxStrength;
            #endif

            #if _PERTEXAOSTRENGTH
            half3 aoStrength;
            #endif

            #if _PERTEXGLITTER
            half3 perTexGlitterReflect;
            #endif

            half3 contrast;
         };

         struct VirtualMapping
         {
            float3 weights;
            fixed4 c0, c1, c2;
            fixed4 param;
         };



         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"

         // splat
         UNITY_DECLARE_TEX2DARRAY(_Diffuse);
         float4 _Diffuse_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_Normal);
         float4 _Normal_TexelSize;
         #if _EMISMAP
         UNITY_DECLARE_TEX2DARRAY(_Emissive);
         float4 _Emissive_TexelSize;
         #endif
         #if _DETAILMAP
         UNITY_DECLARE_TEX2DARRAY(_DetailAlbedo);
         float4 _DetailAlbedo_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_DetailNormal);
         float4 _DetailNormal_TexelSize;
         half _DetailTextureStrength;
         #endif

         #if _ALPHA || _ALPHATEST
         UNITY_DECLARE_TEX2DARRAY(_AlphaArray);
         float4 _AlphaArray_TexelSize;
         #endif

         #if _LOWPOLY
         half _EdgeHardness;
         #endif

         #if _TERRAIN
         sampler2D _SplatControl;
         sampler2D _SplatParams;
         #endif

         #if _ALPHAHOLE
         int _AlphaHoleIdx;
         #endif

         #if _RAMPLIGHTING
         sampler2D _Ramp;
         #endif

         #if _UVLOCALTOP || _UVWORLDTOP || _UVLOCALFRONT || _UVWORLDFRONT || _UVLOCALSIDE || _UVWORLDSIDE
         float4 _UVProjectOffsetScale;
         #endif
         #if _UVLOCALTOP2 || _UVWORLDTOP2 || _UVLOCALFRONT2 || _UVWORLDFRONT2 || _UVLOCALSIDE2 || _UVWORLDSIDE2
         float4 _UVProjectOffsetScale2;
         #endif

         half _Contrast;

         #if _ALPHALAYER || _USEMACROTEXTURE
         // macro texturing
         sampler2D _MacroDiff;
         sampler2D _MacroBump;
         sampler2D _MetallicGlossMap;
         sampler2D _MacroAlpha;
         half2 _MacroTexScale;
         half _MacroTextureStrength;
         half2 _MacroTexNormAOScales;
         #endif

         // default spec
         half _Glossiness;
         half _Metallic;

         #if _DISTANCERESAMPLE
         float3  _ResampleDistanceParams;
         #endif

         #if _FLOW || _FLOWREFRACTION
         // flow
         half _FlowSpeed;
         half _FlowAlpha;
         half _FlowIntensity;
         half _FlowRefraction;
         #endif

         half2 _PerTexScaleRange;
         sampler2D _PropertyTex;

         // etc
         half2 _Parallax;
         half4 _TexScales;

         float4 _DistanceFades;
         float4 _DistanceFadesCached;
         int _ControlSize;

         #if _TRIPLANAR
         half _TriplanarTexScale;
         half _TriplanarContrast;
         float3 _TriplanarOffset;
         #endif

         #if _GEOMAP
         sampler2D _GeoTex;
         float3 _GeoParams;
         #endif

         #if _PROJECTTEXTURE_LOCAL || _PROJECTTEXTURE_WORLD
         half3 _ProjectTexTop;
         half3 _ProjectTexSide;
         half3 _ProjectTexBottom;
         half3 _ProjectTexThresholdFreq;
         #endif

         #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
         half3 _ProjectTexTop2;
         half3 _ProjectTexSide2;
         half3 _ProjectTexBottom2;
         half3 _ProjectTexThresholdFreq2;
         half4 _ProjectTexBlendParams;
         #endif

         #if _TESSDISTANCE || _TESSEDGE
         float4 _TessData1; // distance tessellation, displacement, edgelength
         float4 _TessData2; // min, max
         #endif

         #if _DETAILNOISE
         sampler2D _DetailNoise;
         half3 _DetailNoiseScaleStrengthFade;
         #endif

         #if _DISTANCENOISE
         sampler2D _DistanceNoise;
         half4 _DistanceNoiseScaleStrengthFade;
         #endif

         #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
         half3 _PuddleTint;
         half _PuddleBlend;
         half _MaxPuddles;
         half4 _PuddleFlowParams;
         half2 _PuddleNormalFoam;
         #endif

         #if _RAINDROPS
         sampler2D _RainDropTexture;
         half _RainIntensity;
         float2 _RainUVScales;
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         float2 _PuddleUVScales;
         sampler2D _PuddleNormal;
         #endif

         #if _LAVA
         sampler2D _LavaDiffuse;
         sampler2D _LavaNormal;
         half4 _LavaParams;
         half4 _LavaParams2;
         half3 _LavaEdgeColor;
         half3 _LavaColorLow;
         half3 _LavaColorHighlight;
         float2 _LavaUVScale;
         #endif

         #if _WETNESS
         half _MaxWetness;
         #endif

         half2 _GlobalPorosityWetness;

         #if _SNOW
         sampler2D _SnowDiff;
         sampler2D _SnowNormal;
         half4 _SnowParams; // influence, erosion, crystal, melt
         half _SnowAmount;
         half2 _SnowUVScales;
         half2 _SnowHeightRange;
         half3 _SnowUpVector;
         #endif

         #if _SNOWDISTANCENOISE
         sampler2D _SnowDistanceNoise;
         float4 _SnowDistanceNoiseScaleStrengthFade;
         #endif

         #if _SNOWDISTANCERESAMPLE
         float4 _SnowDistanceResampleScaleStrengthFade;
         #endif

         #if _PERTEXGLITTER || _SNOWGLITTER || _PUDDLEGLITTER
         sampler2D _GlitterTexture;
         half4 _GlitterParams;
         half4 _GlitterSurfaces;
         #endif


         struct VertexOutput 
         {
             float4 pos          : SV_POSITION;
             #if !_TERRAIN
             fixed3 weights      : TEXCOORD0;
             float4 valuesMain   : TEXCOORD1;      //index rgb, triplanar W
                #if _TWOLAYER || _ALPHALAYER
                float4 valuesSecond : TEXCOORD2;      //index rgb + alpha
                #endif
             #elif _TRIPLANAR
             float3 triplanarUVW : TEXCOORD3;
             #endif
             float2 coords       : TEXCOORD4;      // uv, or triplanar UV
             float3 posWorld     : TEXCOORD5;
             float3 normal       : TEXCOORD6;

             float4 camDist      : TEXCOORD7;      // distance from camera (for fades) and fog
             float4 extraData    : TEXCOORD8;      // flowdir + fades, or if triplanar triplanarView + detailFade
             float3 tangent      : TEXCOORD9;
             float3 bitangent    : TEXCOORD10;
             float4 ambientOrLightmapUV : TEXCOORD14;


             #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
             LIGHTING_COORDS(11,12)
             UNITY_FOG_COORDS(13)
             #endif

             #if _PASSSHADOWCASTER
             float3 vec : TEXCOORD11;  // nice naming, Unity...
             #endif

             #if _WETNESS
             half wetness : TEXCOORD15;   //wetness
             #endif

             #if _SECONDUV
             float3 macroUV : TEXCOORD16;
             #endif

         };

         void OffsetUVs(inout LayerParams p, float2 offset)
         {
            p.uv0.xy += offset;
            p.uv1.xy += offset;
            p.uv2.xy += offset;
            #if _TRIPLANAR
            p.tpuv0_x.xy += offset;
            p.tpuv0_y.xy += offset;
            p.tpuv0_z.xy += offset;
            p.tpuv1_x.xy += offset;
            p.tpuv1_y.xy += offset;
            p.tpuv1_z.xy += offset;
            p.tpuv2_x.xy += offset;
            p.tpuv2_y.xy += offset;
            p.tpuv2_z.xy += offset;
            #endif
         }


         void InitDistanceResample(inout LayerParams lp, float dist)
         {
            #if _DISTANCERESAMPLE
               lp.distanceBlend = saturate((dist - _ResampleDistanceParams.y) / (_ResampleDistanceParams.z - _ResampleDistanceParams.y));
               lp.db_uv0 = lp.uv0;
               lp.db_uv1 = lp.uv1;
               lp.db_uv2 = lp.uv2;

               lp.db_uv0.xy *= _ResampleDistanceParams.xx;
               lp.db_uv1.xy *= _ResampleDistanceParams.xx;
               lp.db_uv2.xy *= _ResampleDistanceParams.xx;


               #if _TRIPLANAR
               lp.db_tpuv0_x = lp.tpuv0_x;
               lp.db_tpuv1_x = lp.tpuv1_x;
               lp.db_tpuv2_x = lp.tpuv2_x;
               lp.db_tpuv0_y = lp.tpuv0_y;
               lp.db_tpuv1_y = lp.tpuv1_y;
               lp.db_tpuv2_y = lp.tpuv2_y;
               lp.db_tpuv0_z = lp.tpuv0_z;
               lp.db_tpuv1_z = lp.tpuv1_z;
               lp.db_tpuv2_z = lp.tpuv2_z;

               lp.db_tpuv0_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_z.xy *= _ResampleDistanceParams.xx;
               #endif
            #endif
         }


         LayerParams NewLayerParams()
         {
            LayerParams l = (LayerParams)0;
            l.metallic = _Metallic.xxx;
            l.smoothness = _Glossiness.xxx;
            l.porosity = _GlobalPorosityWetness.xxx;

            l.layerBlend = 0;
            #if _FLOW || _FLOWREFRACTION
            l.flowIntensity = 0;
            l.flowOn = 0;
            l.flowAlphas = half3(1,1,1);
            l.flowRefracts = half3(1,1,1);
            #endif

            #if _TESSDISTANCE || _TESSEDGE
            l.displacementScale = half3(1,1,1);
            l.upBias = half3(0,0,0);
            #endif

            #if _PERTEXNOISESTRENGTH
            l.detailNoiseStrength = half3(1,1,1);
            #endif

            #if _PERTEXNORMALSTRENGTH
            l.normalStrength = half3(1,1,1);
            #endif

            #if _PERTEXAOSTRENGTH
            l.aoStrength = half3(1,1,1);
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            l.parallaxStrength = half3(1,1,1);
            #endif

            l.contrast = _Contrast;

            return l;
         }

         half AOContrast(half ao, half scalar)
         {
            scalar += 0.5;  // 0.5 -> 1.5
            scalar *= scalar; // 0.25 -> 2.25
            return pow(ao, scalar);
         }

         half MacroAOContrast(half ao, half scalar)
         {
            #if _MACROAOSCALE
            return AOContrast(ao, scalar);
            #else
            return ao;
            #endif
         }
         #if _USEMACROTEXTURE || _ALPHALAYER
         MegaSplatLayer SampleMacro(float2 uv)
         {
             MegaSplatLayer o = (MegaSplatLayer)0;
             float2 macroUV = uv * _MacroTexScale.xy;
             half4 macAlb = tex2D(_MacroDiff, macroUV);
             o.Albedo = macAlb.rgb;
             o.Height = macAlb.a;
             // defaults
             o.Normal = half3(0,0,1);
             o.Occlusion = 1;
             o.Smoothness = _Glossiness;
             o.Metallic = _Metallic;
             o.Emission = half3(0,0,0);

             // unpack normal
             #if !_NOSPECTEX
             half4 normSample = tex2D(_MacroBump, macroUV);
             o.Normal = UnpackNormal(normSample);
             o.Normal.xy *= _MacroTexNormAOScales.x;
             #else
             o.Normal = half3(0,0,1);
             #endif


             #if _ALPHA || _ALPHATEST
             o.Alpha = tex2D(_MacroAlpha, macroUV).r;
             #endif
             return o;
         }
         #endif


         #if _NOSPECTEX
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = UnpackNormal(norm); 

         #elif _NOSPECNORMAL   
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = half3(0,0,1);

         #else
            #define SAMPLESPEC(o, params) \
              half4 spec0, spec1, spec2; \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.yw =  norm.zw; \
              specFinal.x = (params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z); \
              norm.xy *= 2; \
              norm.xy -= 1; \
              o.Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy)))); \

         #endif

         void SamplePerTex(sampler2D pt, inout LayerParams params, float2 scaleRange)
         {
            const half cent = 1.0 / 512.0;
            const half pixelStep = 1.0 / 256.0;
            const half vertStep = 1.0 / 8.0;

            // pixel layout for per tex properties
            // metal/smooth/porosity/uv scale
            // flow speed, intensity, alpha, refraction
            // detailNoiseStrength, contrast, displacementAmount, displaceUpBias

            #if _PERTEXMATPARAMS || _PERTEXUV
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, 0, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, 0, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, 0, 0, 0));
               params.porosity = half3(0.4, 0.4, 0.4);
               #if _PERTEXMATPARAMS
               params.metallic = half3(props0.r, props1.r, props2.r);
               params.smoothness = half3(props0.g, props1.g, props2.g);
               params.porosity = half3(props0.b, props1.b, props2.b);
               #endif
               #if _PERTEXUV
               float3 uvScale = float3(props0.a, props1.a, props2.a);
               uvScale = lerp(scaleRange.xxx, scaleRange.yyy, uvScale);
               params.uv0.xy *= uvScale.x;
               params.uv1.xy *= uvScale.y;
               params.uv2.xy *= uvScale.z;

                  #if _TRIPLANAR
                  params.tpuv0_x.xy *= uvScale.xx; params.tpuv0_y.xy *= uvScale.xx; params.tpuv0_z.xy *= uvScale.xx;
                  params.tpuv1_x.xy *= uvScale.yy; params.tpuv1_y.xy *= uvScale.yy; params.tpuv1_z.xy *= uvScale.yy;
                  params.tpuv2_x.xy *= uvScale.zz; params.tpuv2_y.xy *= uvScale.zz; params.tpuv2_z.xy *= uvScale.zz;
                  #endif

               #endif
            }
            #endif


            #if _FLOW || _FLOWREFRACTION
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 3, 0, 0));

               params.flowIntensity = half3(props0.r, props1.r, props2.r);
               params.flowOn = params.flowIntensity.x + params.flowIntensity.y + params.flowIntensity.z;

               params.flowAlphas = half3(props0.b, props1.b, props2.b);
               params.flowRefracts = half3(props0.a, props1.a, props2.a);
            }
            #endif

            #if _PERTEXDISPLACEPARAMS || _PERTEXCONTRAST || _PERTEXNOISESTRENGTH
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 5, 0, 0));

               #if _PERTEXDISPLACEPARAMS && (_TESSDISTANCE || _TESSEDGE)
               params.displacementScale = half3(props0.b, props1.b, props2.b);
               params.upBias = half3(props0.a, props1.a, props2.a);
               #endif

               #if _PERTEXCONTRAST
               params.contrast = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXNOISESTRENGTH
               params.detailNoiseStrength = half3(props0.r, props1.r, props2.r);
               #endif
            }
            #endif

            #if _PERTEXNORMALSTRENGTH || _PERTEXPARALLAXSTRENGTH || _PERTEXAOSTRENGTH || _PERTEXGLITTER
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 7, 0, 0));

               #if _PERTEXNORMALSTRENGTH
               params.normalStrength = half3(props0.r, props1.r, props2.r);
               #endif

               #if _PERTEXPARALLAXSTRENGTH
               params.parallaxStrength = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXAOSTRENGTH
               params.aoStrength = half3(props0.b, props1.b, props2.b);
               #endif

               #if _PERTEXGLITTER
               params.perTexGlitterReflect = half3(props0.a, props1.a, props2.a);
               #endif

            }
            #endif
         }

         float FlowRefract(MegaSplatLayer tex, inout LayerParams main, inout LayerParams second, half3 weights)
         {
            #if _FLOWREFRACTION
            float totalFlow = second.flowIntensity.x * weights.x + second.flowIntensity.y * weights.y + second.flowIntensity.z * weights.z;
            float falpha = second.flowAlphas.x * weights.x + second.flowAlphas.y * weights.y + second.flowAlphas.z * weights.z;
            float frefract = second.flowRefracts.x * weights.x + second.flowRefracts.y * weights.y + second.flowRefracts.z * weights.z;
            float refractOn = min(1, totalFlow * 10000);
            float ratio = lerp(1.0, _FlowAlpha * falpha, refractOn);
            float2 rOff = tex.Normal.xy * _FlowRefraction * frefract * ratio;
            main.uv0.xy += rOff;
            main.uv1.xy += rOff;
            main.uv2.xy += rOff;
            return ratio;
            #endif
            return 1;
         }

         float MipLevel(float2 uv, float2 textureSize)
         {
            uv *= textureSize;
            float2  dx_vtc        = ddx(uv);
            float2  dy_vtc        = ddy(uv);
            float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
            return 0.5 * log2(delta_max_sqr);
         }


         #if _DISTANCERESAMPLE
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l); \
                  { \
                     half4 st0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_z, l); \
                     half4 st1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_z, l); \
                     half4 st2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_z, l); \
                     t0 = lerp(t0, st0, lp.distanceBlend); \
                     t1 = lerp(t1, st1, lp.distanceBlend); \
                     t2 = lerp(t2, st2, lp.distanceBlend); \
                  }
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); 
               #endif
            #endif
         #else // not distance resample
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l);
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l);
               #endif
            #endif
         #endif


         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, lod);
         #else
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, lod);
         #endif

         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z + offset, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z + offset, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z + offset, lod);
         #else
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0 + offset, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1 + offset, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2 + offset, lod);
         #endif

         void Flow(float3 uv, half2 flow, half speed, float intensity, out float3 uv1, out float3 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));
            uv1.z = uv.z;
            uv2.z = uv.z;

            interp = abs(0.5 - phase.x) / 0.5;
         }

         void Flow(float2 uv, half2 flow, half speed, float intensity, out float2 uv1, out float2 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));

            interp = abs(0.5 - phase.x) / 0.5;
         }

         half3 ComputeWeights(half3 iWeights, half4 tex0, half4 tex1, half4 tex2, half contrast)
         {
             // compute weight with height map
             const half epsilon = 1.0f / 1024.0f;
             half3 weights = half3(iWeights.x * (tex0.a + epsilon), 
                                      iWeights.y * (tex1.a + epsilon),
                                      iWeights.z * (tex2.a + epsilon));

             // Contrast weights
             half maxWeight = max(weights.x, max(weights.y, weights.z));
             half transition = contrast * maxWeight;
             half threshold = maxWeight - transition;
             half scale = 1.0f / transition;
             weights = saturate((weights - threshold) * scale);
             // Normalize weights.
             half weightScale = 1.0f / (weights.x + weights.y + weights.z);
             weights *= weightScale;
             #if _LINEARBIAS
             weights = lerp(weights, iWeights, contrast);
             #endif
             return weights;
         }

         float2 ProjectUVs(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP
            return (vertex.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALSIDE
            return (vertex.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALFRONT
            return (vertex.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDTOP
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(1,0,0));
               tangent.w = worldNormal.y > 0 ? -1 : 1;
               #endif
            return (worldPos.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDFRONT
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,0,1));
               tangent.w = worldNormal.x > 0 ? 1 : -1;
               #endif
            return (worldPos.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDSIDE
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,1,0));
               tangent.w = worldNormal.z > 0 ? 1 : -1;
               #endif
            return (worldPos.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #endif
            return coords;
         }

         float2 ProjectUV2(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP2
            return (vertex.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALSIDE2
            return (vertex.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALFRONT2
            return (vertex.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDTOP2
            return (worldPos.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDFRONT2
            return (worldPos.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDSIDE2
            return (worldPos.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #endif
            return coords;
         }

         void WaterBRDF (inout half3 Albedo, inout half Smoothness, half metalness, half wetFactor, half surfPorosity) 
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS
            half porosity = saturate((( (1 - Smoothness) - 0.5)) / max(surfPorosity, 0.001));
            half factor = lerp(1, 0.2, (1 - metalness) * porosity);
            Albedo *= lerp(1.0, factor, wetFactor);
            Smoothness = lerp(1.0, Smoothness, lerp(1.0, factor, wetFactor));
            #endif
         }

         #if _RAINDROPS
         float3 ComputeRipple(float2 uv, float time, float weight)
         {
            float4 ripple = tex2D(_RainDropTexture, uv);
            ripple.yz = ripple.yz * 2 - 1;

            float dropFrac = frac(ripple.w + time);
            float timeFrac = dropFrac - 1.0 + ripple.x;
            float dropFactor = saturate(0.2f + weight * 0.8 - dropFrac);
            float finalFactor = dropFactor * ripple.x * 
                                 sin( clamp(timeFrac * 9.0f, 0.0f, 3.0f) * 3.14159265359);

            return float3(ripple.yz * finalFactor * 0.35f, 1.0f);
         }
         #endif

         // water normal only
         half2 DoPuddleRefract(float3 waterNorm, half puddleLevel, float2 flowDir, half height)
         {
            #if _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - height) * _PuddleBlend);
            waterBlend *= waterBlend;

            waterNorm.xy *= puddleLevel * waterBlend;
               #if _PUDDLEDEPTHDAMPEN
               return lerp(waterNorm.xy, waterNorm.xy * height, _PuddleFlowParams.w);
               #endif
            return waterNorm.xy;

            #endif
            return half2(0,0);
         }

         // modity lighting terms for water..
         float DoPuddles(inout MegaSplatLayer o, float2 uv, half3 waterNormFoam, half puddleLevel, half2 flowDir, half porosity, float3 worldNormal)
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - o.Height) * _PuddleBlend);

            half3 waterNorm = half3(0,0,1);
            #if _PUDDLEFLOW || _PUDDLEREFRACT

               waterNorm = half3(waterNormFoam.x, waterNormFoam.y, sqrt(1 - saturate(dot(waterNormFoam.xy, waterNormFoam.xy))));

               #if _PUDDLEFOAM
               half pmh = puddleLevel - o.Height;
               // refactor to compute flow UVs in previous step?
               float2 foamUV0;
               float2 foamUV1;
               half foamInterp;
               Flow(uv * 1.75 + waterNormFoam.xy * waterNormFoam.b, flowDir, _PuddleFlowParams.y/3, _PuddleFlowParams.z/3, foamUV0, foamUV1, foamInterp);
               half foam0 = tex2D(_PuddleNormal, foamUV0).b;
               half foam1 = tex2D(_PuddleNormal, foamUV1).b;
               half foam = lerp(foam0, foam1, foamInterp);
               foam = foam * abs(pmh) + (foam * o.Height);
               foam *= 1.0 - (saturate(pmh * 1.5));
               foam *= foam;
               foam *= _PuddleNormalFoam.y;
               #endif // foam
            #endif // flow, refract

            half3 wetAlbedo = o.Albedo * _PuddleTint * 2;
            half wetSmoothness = o.Smoothness;

            WaterBRDF(wetAlbedo, wetSmoothness, o.Metallic, waterBlend, porosity);

            #if _RAINDROPS
               float dropStrength = _RainIntensity;
               #if _RAINDROPFLATONLY
               dropStrength = saturate(dot(float3(0,1,0), worldNormal));
               #endif
               const float4 timeMul = float4(1.0f, 0.85f, 0.93f, 1.13f); 
               float4 timeAdd = float4(0.0f, 0.2f, 0.45f, 0.7f);
               float4 times = _Time.yyyy;
               times = frac((times * float4(1, 0.85, 0.93, 1.13) + float4(0, 0.2, 0.45, 0.7)) * 1.6);

               float2 ruv1 = uv * _RainUVScales.xy;
               float2 ruv2 = ruv1;

               float4 weights = _RainIntensity.xxxx - float4(0, 0.25, 0.5, 0.75);
               float3 ripple1 = ComputeRipple(ruv1 + float2( 0.25f,0.0f), times.x, weights.x);
               float3 ripple2 = ComputeRipple(ruv2 + float2(-0.55f,0.3f), times.y, weights.y);
               float3 ripple3 = ComputeRipple(ruv1 + float2(0.6f, 0.85f), times.z, weights.z);
               float3 ripple4 = ComputeRipple(ruv2 + float2(0.5f,-0.75f), times.w, weights.w);
               weights = saturate(weights * 4);

               float4 z = lerp(float4(1,1,1,1), float4(ripple1.z, ripple2.z, ripple3.z, ripple4.z), weights);
               float3 rippleNormal = float3( weights.x * ripple1.xy +
                           weights.y * ripple2.xy + 
                           weights.z * ripple3.xy + 
                           weights.w * ripple4.xy, 
                           z.x * z.y * z.z * z.w);

               waterNorm = lerp(waterNorm, normalize(rippleNormal+waterNorm), _RainIntensity * dropStrength);                         
            #endif

            #if _PUDDLEFOAM
            wetAlbedo += foam;
            wetSmoothness -= foam;
            #endif

            o.Normal = lerp(o.Normal, waterNorm, waterBlend * _PuddleNormalFoam.x);
            o.Occlusion = lerp(o.Occlusion, 1, waterBlend);
            o.Smoothness = lerp(o.Smoothness, wetSmoothness, waterBlend);
            o.Albedo = lerp(o.Albedo, wetAlbedo, waterBlend);
            return waterBlend;
            #endif
            return 0;
         }

         float DoLava(inout MegaSplatLayer o, float2 uv, half lavaLevel, half2 flowDir)
         {
            #if _LAVA

            half distortionSize = _LavaParams2.x;
            half distortionRate = _LavaParams2.y;
            half distortionScale = _LavaParams2.z;
            half darkening = _LavaParams2.w;
            half3 edgeColor = _LavaEdgeColor;
            half3 lavaColorLow = _LavaColorLow;
            half3 lavaColorHighlight = _LavaColorHighlight;


            half maxLava = _LavaParams.y;
            half lavaSpeed = _LavaParams.z;
            half lavaInterp = _LavaParams.w;

            lavaLevel *= maxLava;
            float lvh = lavaLevel - o.Height;
            float lavaBlend = saturate(lvh * _LavaParams.x);

            float2 uv1;
            float2 uv2;
            half interp;
            half drag = lerp(0.1, 1, saturate(lvh));
            Flow(uv, flowDir, lavaInterp, lavaSpeed * drag, uv1, uv2, interp);

            float2 dist_uv1;
            float2 dist_uv2;
            half dist_interp;
            Flow(uv * distortionScale, flowDir, distortionRate, distortionSize, dist_uv1, dist_uv2, dist_interp);

            half4 lavaDist = lerp(tex2D(_LavaDiffuse, dist_uv1*0.51), tex2D(_LavaDiffuse, dist_uv2), dist_interp);
            half4 dist = lavaDist * (distortionSize * 2) - distortionSize;

            half4 lavaTex = lerp(tex2D(_LavaDiffuse, uv1*1.1 + dist.xy), tex2D(_LavaDiffuse, uv2 + dist.zw), interp);

            lavaTex.xy = lavaTex.xy * 2 - 1;
            half3 lavaNorm = half3(lavaTex.xy, sqrt(1 - saturate(dot(lavaTex.xy, lavaTex.xy))));

            // base lava color, based on heights
            half3 lavaColor = lerp(lavaColorLow, lavaColorHighlight, lavaTex.b);

            // edges
            float lavaBlendWide = saturate((lavaLevel - o.Height) * _LavaParams.x * 0.5);
            float edge = saturate((1 - lavaBlendWide) * 3);

            // darkening
            darkening = saturate(lavaTex.a * darkening * saturate(lvh*2));
            lavaColor = lerp(lavaColor, lavaDist.bbb * 0.3, darkening);
            // edges
            lavaColor = lerp(lavaColor, edgeColor, edge);

            o.Albedo = lerp(o.Albedo, lavaColor, lavaBlend);
            o.Normal = lerp(o.Normal, lavaNorm, lavaBlend);
            o.Smoothness = lerp(o.Smoothness, 0.3, lavaBlend * darkening);

            half3 emis = lavaColor * lavaBlend;
            o.Emission = lerp(o.Emission, emis, lavaBlend);
            // bleed
            o.Emission += edgeColor * 0.3 * (saturate((lavaLevel*1.2 - o.Height) * _LavaParams.x) - lavaBlend);
            return lavaBlend;
            #endif
            return 0;
         }

         // no trig based hash, not a great hash, but fast..
         float Hash(float3 p)
         {
             p  = frac( p*0.3183099+.1 );
             p *= 17.0;
             return frac( p.x*p.y*p.z*(p.x+p.y+p.z) );
         }

         float Noise( float3 x )
         {
             float3 p = floor(x);
             float3 f = frac(x);
             f = f*f*(3.0-2.0*f);
            
             return lerp(lerp(lerp( Hash(p+float3(0,0,0)), Hash(p+float3(1,0,0)),f.x), lerp( Hash(p+float3(0,1,0)), Hash(p+float3(1,1,0)),f.x),f.y),
                       lerp(lerp(Hash(p+float3(0,0,1)), Hash(p+float3(1,0,1)),f.x), lerp(Hash(p+float3(0,1,1)), Hash(p+float3(1,1,1)),f.x),f.y),f.z);
         }

         // given 4 texture choices for each projection, return texture index based on normal
         // seems like we could remove some branching here.. hmm..
         float ProjectTexture(float3 worldPos, float3 normal, half3 threshFreq, half3 top, half3 side, half3 bottom)
         {
            half d = dot(normal, float3(0, 1, 0));
            half3 cvec = side;
            if (d < threshFreq.x)
            {
               cvec = bottom;
            }
            else if (d > threshFreq.y)
            {
               cvec = top;
            }

            float n = Noise(worldPos * threshFreq.z);
            if (n < 0.333)
               return cvec.x;
            else if (n < 0.666)
               return cvec.y;
            else
               return cvec.z;
         }

         void ProceduralTexture(float3 localPos, float3 worldPos, float3 normal, float3 worldNormal, inout float4 valuesMain, inout float4 valuesSecond, half3 weights)
         {
            #if _PROJECTTEXTURE_LOCAL
            half choice = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif
            #if _PROJECTTEXTURE_WORLD
            half choice = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif

            #if _PROJECTTEXTURE2_LOCAL
            half choice2 = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif
            #if _PROJECTTEXTURE2_WORLD
            half choice2 = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif

            #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
            float blendNoise = Noise(worldPos * _ProjectTexBlendParams.x) - 0.5;
            blendNoise *= _ProjectTexBlendParams.y;
            blendNoise += 0.5;
            blendNoise = min(max(blendNoise, _ProjectTexBlendParams.z), _ProjectTexBlendParams.w);
            valuesSecond.a = saturate(blendNoise);
            #endif
         }


         // manually compute barycentric coordinates
         float3 Barycentric(float2 p, float2 a, float2 b, float2 c)
         {
             float2 v0 = b - a;
             float2 v1 = c - a;
             float2 v2 = p - a;
             float d00 = dot(v0, v0);
             float d01 = dot(v0, v1);
             float d11 = dot(v1, v1);
             float d20 = dot(v2, v0);
             float d21 = dot(v2, v1);
             float denom = d00 * d11 - d01 * d01;
             float v = (d11 * d20 - d01 * d21) / denom;
             float w = (d00 * d21 - d01 * d20) / denom;
             float u = 1.0f - v - w;
             return float3(u, v, w);
         }

         // given two height values (from textures) and a height value for the current pixel (from vertex)
         // compute the blend factor between the two with a small blending area between them.
         half HeightBlend(half h1, half h2, half slope, half contrast)
         {
            h2 = 1 - h2;
            half tween = saturate((slope - min(h1, h2)) / max(abs(h1 - h2), 0.001)); 
            half blend = saturate( ( tween - (1-contrast) ) / max(contrast, 0.001));
            #if _LINEARBIAS
            blend = lerp(slope, blend, contrast);
            #endif
            return blend;
         }

         void BlendSpec(inout MegaSplatLayer base, MegaSplatLayer macro, half r, float3 albedo)
         {
            base.Metallic = lerp(base.Metallic, macro.Metallic, r);
            base.Smoothness = lerp(base.Smoothness, macro.Smoothness, r);
            base.Emission = albedo * lerp(base.Emission, macro.Emission, r);
         }

         half3 BlendOverlay(half3 base, half3 blend) { return (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))); }
         half3 BlendMult2X(half3  base, half3 blend) { return (base * (blend * 2)); }


         MegaSplatLayer SampleDetail(half3 weights, float3 viewDir, inout LayerParams params, half3 tpw)
         {
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.ga *= params.normalStrength.x;
               norm1.ga *= params.normalStrength.y;
               norm2.ga *= params.normalStrength.z;
               #endif
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif

            SAMPLESPEC(o, params);

            o.Emission = albedo.rgb * specFinal.z;
            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            return o;
         }


         float SampleLayerHeight(half3 biWeights, float3 viewDir, inout LayerParams params, half3 tpw, float lod, float contrast)
         { 
            #if _TESSDISTANCE || _TESSEDGE
            half4 tex0, tex1, tex2;

            SAMPLETEXARRAYLOD(tex0, tex1, tex2, _Diffuse, params, lod);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, contrast);
            params.weights = weights;
            return (tex0.a * params.displacementScale.x * weights.x + 
                    tex1.a * params.displacementScale.y * weights.y + 
                    tex2.a * params.displacementScale.z * weights.z);
            #endif
            return 0.5;
         }

         #if _TESSDISTANCE || _TESSEDGE
         float4 MegaSplatDistanceBasedTess (float d0, float d1, float d2, float tess)
         {
            float3 f;
            f.x = clamp(d0, 0.01, 1.0) * tess;
            f.y = clamp(d1, 0.01, 1.0) * tess;
            f.z = clamp(d2, 0.01, 1.0) * tess;

            return UnityCalcTriEdgeTessFactors (f);
         }
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         half3 GetWaterNormal(float2 uv, float2 flowDir)
         {
            float2 uv1;
            float2 uv2;
            half interp;
            Flow(uv, flowDir, _PuddleFlowParams.y, _PuddleFlowParams.z, uv1, uv2, interp);

            half3 fd = lerp(tex2D(_PuddleNormal, uv1), tex2D(_PuddleNormal, uv2), interp).xyz;
            fd.xy = fd.xy * 2 - 1;
            return fd;
         }
         #endif

         MegaSplatLayer SampleLayer(inout LayerParams params, SplatInput si)
         { 
            half3 biWeights = si.weights;
            float3 viewDir = si.viewDir;
            half3 tpw = si.triplanarBlend;

            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
            params.weights = weights;
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
                  params.uv1.xy += refractOffset;
                  params.uv2.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * biWeights.x + params.parallaxStrength.y * biWeights.y + params.parallaxStrength.z * biWeights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, viewDir);
                  params.uv0.xy += pOffset;
                  params.uv1.xy += pOffset;
                  params.uv2.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
                  weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
                  albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0, alpha1, alpha2;
            mipLevel = MipLevel(params.mipUV, _AlphaArray_TexelSize.zw);
            SAMPLETEXARRAY(alpha0, alpha1, alpha2, _AlphaArray, params, mipLevel);
            o.Alpha = alpha0.r * weights.x + alpha1.r * weights.y + alpha2.r * weights.z;
            #endif

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.xy -= 0.5; norm1.xy -= 0.5; norm2.xy -= 0.5;
               norm0.xy *= params.normalStrength.x;
               norm1.xy *= params.normalStrength.y;
               norm2.xy *= params.normalStrength.z;
               norm0.xy += 0.5; norm1.xy += 0.5; norm2.xy += 0.5;
               #endif
            
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif


            SAMPLESPEC(o, params);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            half4 emis0, emis1, emis2;
            mipLevel = MipLevel(params.mipUV, _Emissive_TexelSize.zw);
            SAMPLETEXARRAY(emis0, emis1, emis2, _Emissive, params, mipLevel);
            half4 emis = emis0 * weights.x + emis1 * weights.y + emis2 * weights.z;
            o.Emission = emis.rgb;
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _EMISMAP
            o.Metallic = emis.a;
            #endif

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x * params.weights.x + params.aoStrength.y * params.weights.y + params.aoStrength.z * params.weights.z;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif
            return o;
         }

         half4 SampleSpecNoBlend(LayerParams params, in half4 norm, out half3 Normal)
         {
            half4 specFinal = half4(0,0,0,1);
            Normal = half3(0,0,1);
            specFinal.x = params.metallic.x;
            specFinal.y = params.smoothness.x;

            #if _NOSPECTEX
               Normal = UnpackNormal(norm); 
            #else
               specFinal.yw = norm.zw;
               specFinal.x = params.metallic.x;
               norm.xy *= 2;
               norm.xy -= 1;
               Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy))));
            #endif

            return specFinal;
         }

         MegaSplatLayer SampleLayerNoBlend(inout LayerParams params, SplatInput si)
         { 
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0;
            half4 norm0 = half4(0,0,1,1);

            tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
            fixed4 albedo = tex0;


             #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT
  

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * si.weights.x + params.parallaxStrength.y * si.weights.y + params.parallaxStrength.z * si.weights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, si.viewDir);
                  params.uv0.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0 = UNITY_SAMPLE_TEX2DARRAY(_AlphaArray, params.uv0); 
            o.Alpha = alpha0.r;
            #endif


            #if !_NOSPECNORMAL
            norm0 = UNITY_SAMPLE_TEX2DARRAY(_Normal, params.uv0); 
               #if _PERTEXNORMALSTRENGTH
               norm0.xy *= params.normalStrength.x;
               #endif
            #endif

            half4 specFinal = SampleSpecNoBlend(params, norm0, o.Normal);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            o.Emission = UNITY_SAMPLE_TEX2DARRAY(_Emissive, params.uv0).rgb; 
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif

            return o;
         }

         MegaSplatLayer BlendResults(MegaSplatLayer a, MegaSplatLayer b, half r)
         {
            a.Height = lerp(a.Height, b.Height, r);
            a.Albedo = lerp(a.Albedo, b.Albedo, r);
            #if !_NOSPECNORMAL
            a.Normal = lerp(a.Normal, b.Normal, r);
            #endif
            a.Metallic = lerp(a.Metallic, b.Metallic, r);
            a.Smoothness = lerp(a.Smoothness, b.Smoothness, r);
            a.Occlusion = lerp(a.Occlusion, b.Occlusion, r);
            a.Emission = lerp(a.Emission, b.Emission, r);
            #if _ALPHA || _ALPHATEST
            a.Alpha = lerp(a.Alpha, b.Alpha, r);
            #endif
            return a;
         }

         MegaSplatLayer OverlayResults(MegaSplatLayer splats, MegaSplatLayer macro, half r)
         {
            #if !_SPLATSONTOP
            r = 1 - r;
            #endif

            #if _ALPHA || _ALPHATEST
            splats.Alpha = min(macro.Alpha, splats.Alpha);
            #endif

            #if _MACROMULT2X
               splats.Albedo = lerp(BlendMult2X(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROOVERLAY
               splats.Albedo = lerp(BlendOverlay(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROMULT
               splats.Albedo = lerp(splats.Albedo * macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #else
               splats.Albedo = lerp(macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(macro.Normal, splats.Normal, r); 
               #endif
               splats.Occlusion = lerp(macro.Occlusion, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #endif

            return splats;
         }

         MegaSplatLayer BlendDetail(MegaSplatLayer splats, MegaSplatLayer detail, float detailBlend)
         {
            #if _DETAILMAP
            detailBlend *= _DetailTextureStrength;
            #endif
            #if _DETAILMULT2X
               splats.Albedo = lerp(detail.Albedo, BlendMult2X(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILOVERLAY
               splats.Albedo = lerp(detail.Albedo, BlendOverlay(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILMULT
               splats.Albedo = lerp(detail.Albedo, splats.Albedo * detail.Albedo, detailBlend);
            #else
               splats.Albedo = lerp(detail.Albedo, splats.Albedo, detailBlend);
            #endif 

            #if !_NOSPECNORMAL
            splats.Normal = lerp(splats.Normal, BlendNormals(splats.Normal, detail.Normal), detailBlend);
            #endif
            return splats;
         }

         float DoSnowDisplace(float splat_height, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);

            float height = splat_height * _SnowParams.x;
            float erosion = lerp(0, height, _SnowParams.y);
            float snowMask = saturate((snowFade - erosion));
            float snowMask2 = saturate((snowFade - erosion) * 8);
            snowMask *= snowMask * snowMask * snowMask * snowMask * snowMask2;
            snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));

            return snowAmount;
            #endif
            return 0;
         }

         float DoSnow(inout MegaSplatLayer o, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight, half surfPorosity, float camDist)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            #if _SNOWDISTANCERESAMPLE
            float2 snowResampleUV = uv * _SnowDistanceResampleScaleStrengthFade.x;

            if (camDist > _SnowDistanceResampleScaleStrengthFade.z)
               {
                  half4 snowAlb2 = tex2D(_SnowDiff, snowResampleUV);
                  half4 snowNsao2 = tex2D(_SnowNormal, snowResampleUV);
                  float fade = saturate ((camDist - _SnowDistanceResampleScaleStrengthFade.z) / _SnowDistanceResampleScaleStrengthFade.w);
                  fade *= _SnowDistanceResampleScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb, snowAlb2, fade);
                  snowNsao = lerp(snowNsao, snowNsao2, fade);
               }
            #endif

            #if _SNOWDISTANCENOISE
               float2 snowNoiseUV = uv * _SnowDistanceNoiseScaleStrengthFade.x;
               if (camDist > _SnowDistanceNoiseScaleStrengthFade.z)
               {
                  half4 noise = tex2D(_SnowDistanceNoise, uv * _SnowDistanceNoiseScaleStrengthFade.x);
                  float fade = saturate ((camDist - _SnowDistanceNoiseScaleStrengthFade.z) / _SnowDistanceNoiseScaleStrengthFade.w);
                  fade *= _SnowDistanceNoiseScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb.rgb, BlendMult2X(snowAlb.rgb, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  snowNsao.xy += ((noise.xy-0.25) * fade);
                  #endif
               }
            #endif



            half3 snowNormal = half3(snowNsao.xy * 2 - 1, 1);
            snowNormal.z = sqrt(1 - saturate(dot(snowNormal.xy, snowNormal.xy)));

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);
            float ao = o.Occlusion;
            if (snowFade > 0)
            {
               float height = o.Height * _SnowParams.x;
               float erosion = lerp(1-ao, (height + ao) * 0.5, _SnowParams.y);
               float snowMask = saturate((snowFade - erosion) * 8);
               snowMask *= snowMask * snowMask * snowMask;
               snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));  // up
               wetnessMask = saturate((_SnowParams.w * (4.0 * snowFade) - (height + snowNsao.b) * 0.5));
               snowAmount = saturate(snowAmount * 8);
               snowNormalAmount = snowAmount * snowAmount;

               float porosity = saturate((((1.0 - o.Smoothness) - 0.5)) / max(surfPorosity, 0.001));
               float factor = lerp(1, 0.4, porosity);

               o.Albedo *= lerp(1.0, factor, wetnessMask);
               o.Normal = lerp(o.Normal, float3(0,0,1), wetnessMask);
               o.Smoothness = lerp(o.Smoothness, 0.8, wetnessMask);

            }
            o.Albedo = lerp(o.Albedo, snowAlb.rgb, snowAmount);
            o.Normal = lerp(o.Normal, snowNormal, snowNormalAmount);
            o.Smoothness = lerp(o.Smoothness, (snowNsao.b) * _SnowParams.z, snowAmount);
            o.Occlusion = lerp(o.Occlusion, snowNsao.w, snowAmount);
            o.Height = lerp(o.Height, snowAlb.a, snowAmount);
            o.Metallic = lerp(o.Metallic, 0.01, snowAmount);
            float crystals = saturate(0.65 - snowNsao.b);
            o.Smoothness = lerp(o.Smoothness, crystals * _SnowParams.z, snowAmount);
            return snowAmount;
            #endif
            return 0;
         }

         half4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten)
         {
            return half4(s.Albedo, 1);
         }

         #if _RAMPLIGHTING
         half3 DoLightingRamp(half3 albedo, float3 normal, float3 emission, half3 lightDir, half atten)
         {
            half NdotL = dot (normal, lightDir);
            half diff = NdotL * 0.5 + 0.5;
            half3 ramp = tex2D (_Ramp, diff.xx).rgb;
            return (albedo * _LightColor0.rgb * ramp * atten) + emission;
         }

         half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) 
         {
            half4 c;
            c.rgb = DoLightingRamp(s.Albedo, s.Normal, s.Emission, lightDir, atten);
            c.a = s.Alpha;
            return c;
         }
         #endif

         void ApplyDetailNoise(inout half3 albedo, inout half3 norm, inout half smoothness, in LayerParams data, float camDist, float3 tpw)
         {
            #if _DETAILNOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv1_y.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv2_z.xy * _DetailNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DetailNoiseScaleStrengthFade.x;
               #endif


               if (camDist < _DetailNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DetailNoise, uv0) * tpw.x + 
                     tex2D(_DetailNoise, uv1) * tpw.y + 
                     tex2D(_DetailNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DetailNoise, uv).rgb;
                  #endif

                  float fade = 1.0 - ((_DetailNoiseScaleStrengthFade.z - camDist) / _DetailNoiseScaleStrengthFade.z);
                  fade = 1.0 - (fade*fade);
                  fade *= _DetailNoiseScaleStrengthFade.y;

                  #if _PERTEXNOISESTRENGTH
                  fade *= (data.detailNoiseStrength.x * data.weights.x + data.detailNoiseStrength.y * data.weights.y + data.detailNoiseStrength.z * data.weights.z);
                  #endif

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }

            }
            #endif // detail normal

            #if _DISTANCENOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv0_y.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv1_z.xy * _DistanceNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DistanceNoiseScaleStrengthFade.x;
               #endif


               if (camDist > _DistanceNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DistanceNoise, uv0) * tpw.x + 
                     tex2D(_DistanceNoise, uv1) * tpw.y + 
                     tex2D(_DistanceNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DistanceNoise, uv).rgb;
                  #endif

                  float fade = saturate ((camDist - _DistanceNoiseScaleStrengthFade.z) / _DistanceNoiseScaleStrengthFade.w);
                  fade *= _DistanceNoiseScaleStrengthFade.y;

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }
            }
            #endif
         }

         void DoGlitter(inout MegaSplatLayer splats, half shine, half reflectAmt, float3 wsNormal, float3 wsView, float2 uv)
         {
            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            half3 lightDir = normalize(_WorldSpaceLightPos0);

            half3 viewDir = normalize(wsView);
            half NdotL = saturate(dot(splats.Normal, lightDir));
            lightDir = reflect(lightDir, splats.Normal);
            half specular = saturate(abs(dot(lightDir, viewDir)));


            //float2 offset = float2(viewDir.z, wsNormal.x) + splats.Normal.xy * 0.1;
            float2 offset = splats.Normal * 0.1;
            offset = fmod(offset, 1.0);

            half detail = tex2D(_GlitterTexture, uv * _GlitterParams.xy + offset).x;

            #if _GLITTERMOVES
               float2 uv0 = uv * _GlitterParams.w + _Time.y * _GlitterParams.z;
               float2 uv1 = uv * _GlitterParams.w + _Time.y  * 1.04 * -_GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               half detail3 = tex2D(_GlitterTexture, uv1).y;
               detail *= sqrt(detail2 * detail3);
            #else
               float2 uv0 = uv * _GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               detail *= detail2;
            #endif
            detail *= saturate(splats.Height + 0.5);

            specular = pow(specular, shine) * floor(detail * reflectAmt);

            splats.Smoothness += specular;
            splats.Smoothness = min(splats.Smoothness, 1);
            #endif
         }


         LayerParams InitLayerParams(SplatInput si, float3 values, half2 texScale)
         {
            LayerParams data = NewLayerParams();
            #if _TERRAIN
            int i0 = round(values.x * 255);
            int i1 = round(values.y * 255);
            int i2 = round(values.z * 255);
            #else
            int i0 = round(values.x / max(si.weights.x, 0.00001));
            int i1 = round(values.y / max(si.weights.y, 0.00001));
            int i2 = round(values.z / max(si.weights.z, 0.00001));
            #endif

            #if _TRIPLANAR
            float3 coords = si.triplanarUVW * texScale.x;
            data.tpuv0_x = float3(coords.zy, i0);
            data.tpuv0_y = float3(coords.xz, i0);
            data.tpuv0_z = float3(coords.xy, i0);
            data.tpuv1_x = float3(coords.zy, i1);
            data.tpuv1_y = float3(coords.xz, i1);
            data.tpuv1_z = float3(coords.xy, i1);
            data.tpuv2_x = float3(coords.zy, i2);
            data.tpuv2_y = float3(coords.xz, i2);
            data.tpuv2_z = float3(coords.xy, i2);
            data.mipUV = coords.xz;

            float2 splatUV = si.splatUV * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);

            #else
            float2 splatUV = si.splatUV.xy * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);
            data.mipUV = splatUV.xy;
            #endif



            #if _FLOW || _FLOWREFRACTION
            data.flowOn = 0;
            #endif

            #if _DISTANCERESAMPLE
            InitDistanceResample(data, si.camDist.y);
            #endif

            return data;
         }

         MegaSplatLayer DoSurf(inout SplatInput si, MegaSplatLayer macro, float3x3 tangentToWorld)
         {
            #if _ALPHALAYER
            LayerParams mData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.xy);
            #else
            LayerParams mData = InitLayerParams(si, si.valuesMain.xyz, _TexScales.xy);
            #endif

            #if _ALPHAHOLE
            if (mData.uv0.z == _AlphaHoleIdx || mData.uv1.z == _AlphaHoleIdx || mData.uv2.z == _AlphaHoleIdx)
            {
               clip(-1);
            } 
            #endif

            #if _PARALLAX && (_TESSEDGE || _TESSDISTANCE || _LOWPOLY || _ALPHATEST)
            si.viewDir = mul(si.viewDir, tangentToWorld);
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT
            float2 puddleUV = si.macroUV * _PuddleUVScales.xy;
            #elif _PUDDLES
            float2 puddleUV = 0;
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT

            si.waterNormalFoam = float3(0,0,0);
            if (si.puddleHeight > 0 && si.camDist.y < 40)
            {
               float str = 1.0 - ((si.camDist.y - 20) / 20);
               si.waterNormalFoam = GetWaterNormal(puddleUV, si.flowDir) * str;
            }
            #endif

            SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

            #if _FLOWREFRACTION
            // see through
            //sampleBottom = sampleBottom || mData.flowOn > 0;
            #endif

            half porosity = _GlobalPorosityWetness.x;
            #if _PERTEXMATPARAMS
            porosity = mData.porosity.x * mData.weights.x + mData.porosity.y * mData.weights.y + mData.porosity.z * mData.weights.z;
            #endif

            #if _TWOLAYER
               LayerParams sData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.zw);

               #if _ALPHAHOLE
               if (sData.uv0.z == _AlphaHoleIdx || sData.uv1.z == _AlphaHoleIdx || sData.uv2.z == _AlphaHoleIdx)
               {
                  clip(-1);
               } 
               #endif

               sData.layerBlend = si.layerBlend;
               SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(sData.uv0, si.flowDir, _FlowSpeed * sData.flowIntensity.x, _FlowIntensity, sData.fuv0a, sData.fuv0b, sData.flowInterps.x);
                  Flow(sData.uv1, si.flowDir, _FlowSpeed * sData.flowIntensity.y, _FlowIntensity, sData.fuv1a, sData.fuv1b, sData.flowInterps.y);
                  Flow(sData.uv2, si.flowDir, _FlowSpeed * sData.flowIntensity.z, _FlowIntensity, sData.fuv2a, sData.fuv2b, sData.flowInterps.z);
                  mData.flowOn = 0;
               #endif

               MegaSplatLayer second = SampleLayer(sData, si);

               #if _FLOWREFRACTION
                  float hMod = FlowRefract(second, mData, sData, si.weights);
               #endif
            #else // _TWOLAYER

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(mData.uv0, si.flowDir, _FlowSpeed * mData.flowIntensity.x, _FlowIntensity, mData.fuv0a, mData.fuv0b, mData.flowInterps.x);
                  Flow(mData.uv1, si.flowDir, _FlowSpeed * mData.flowIntensity.y, _FlowIntensity, mData.fuv1a, mData.fuv1b, mData.flowInterps.y);
                  Flow(mData.uv2, si.flowDir, _FlowSpeed * mData.flowIntensity.z, _FlowIntensity, mData.fuv2a, mData.fuv2b, mData.flowInterps.z);
               #endif
            #endif

            #if _NOBLENDBOTTOM
               MegaSplatLayer splats = SampleLayerNoBlend(mData, si);
            #else
               MegaSplatLayer splats = SampleLayer(mData, si);
            #endif

            #if _TWOLAYER
               // blend layers together..
               float hfac = HeightBlend(splats.Height, second.Height, sData.layerBlend, _Contrast);
               #if _FLOWREFRACTION
                  hfac *= hMod;
               #endif
               splats = BlendResults(splats, second, hfac);
               porosity = lerp(porosity, 
                     sData.porosity.x * sData.weights.x + 
                     sData.porosity.y * sData.weights.y + 
                     sData.porosity.z * sData.weights.z,
                     hfac);
            #endif

            #if _GEOMAP
            float2 geoUV = float2(0, si.worldPos.y * _GeoParams.y + _GeoParams.z);
            half4 geoTex = tex2D(_GeoTex, geoUV);
            splats.Albedo = lerp(splats.Albedo, BlendMult2X(splats.Albedo, geoTex), _GeoParams.x * geoTex.a);
            #endif

            half macroBlend = 1;
            #if _USEMACROTEXTURE
            macroBlend = saturate(_MacroTextureStrength * si.camDist.x);
            #endif

            #if _DETAILMAP
               float dist = si.camDist.y;
               if (dist > _DistanceFades.w)
               {
                  MegaSplatLayer o = (MegaSplatLayer)0;
                  UNITY_INITIALIZE_OUTPUT(MegaSplatLayer,o);
                  #if _USEMACROTEXTURE
                  splats = OverlayResults(splats, macro, macroBlend);
                  #endif
                  o.Albedo = splats.Albedo;
                  o.Normal = splats.Normal;
                  o.Emission = splats.Emission;
                  o.Occlusion = splats.Occlusion;
                  #if !_RAMPLIGHTING
                  o.Metallic = splats.Metallic;
                  o.Smoothness = splats.Smoothness;
                  #endif
                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_Final(si, o);
                  #endif
                  return o;
               }

               LayerParams sData = InitLayerParams(si, si.valuesMain, _TexScales.zw);
               MegaSplatLayer second = SampleDetail(mData.weights, si.viewDir, sData, si.triplanarBlend);   // use prev weights for detail

               float detailBlend = 1.0 - saturate((dist - _DistanceFades.z) / (_DistanceFades.w - _DistanceFades.z));
               splats = BlendDetail(splats, second, detailBlend); 
            #endif

            ApplyDetailNoise(splats.Albedo, splats.Normal, splats.Smoothness, mData, si.camDist.y, si.triplanarBlend);

            float3 worldNormal = float3(0,0,1);
            #if _SNOW || _RAINDROPFLATONLY
            worldNormal = mul(tangentToWorld, normalize(splats.Normal));
            #endif

            #if _SNOWGLITTER || _PERTEXGLITTER || _PUDDLEGLITTER
            half glitterShine = 0;
            half glitterReflect = 0;
            #endif

            #if _PERTEXGLITTER
            glitterReflect = mData.perTexGlitterReflect.x * mData.weights.x + mData.perTexGlitterReflect.y * mData.weights.y + mData.perTexGlitterReflect.z * mData.weights.z;
               #if _TWOLAYER || _ALPHALAYER
               float glitterReflect2 = sData.perTexGlitterReflect.x * sData.weights.x + sData.perTexGlitterReflect.y * sData.weights.y + sData.perTexGlitterReflect.z * sData.weights.z;
               glitterReflect = lerp(glitterReflect, glitterReflect2, hfac);
               #endif
            glitterReflect *= 14;
            glitterShine = 1.5;
            #endif


            float pud = 0;
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
               if (si.puddleHeight > 0)
               {
                  pud = DoPuddles(splats, puddleUV, si.waterNormalFoam, si.puddleHeight, si.flowDir, porosity, worldNormal);
               }
            #endif

            #if _LAVA
               float2 lavaUV = si.macroUV * _LavaUVScale.xy;


               if (si.puddleHeight > 0)
               {
                  pud = DoLava(splats, lavaUV, si.puddleHeight, si.flowDir);
               }
            #endif

            #if _PUDDLEGLITTER
            glitterShine = lerp(glitterShine, _GlitterSurfaces.z, pud);
            glitterReflect = lerp(glitterReflect, _GlitterSurfaces.w, pud);
            #endif


            #if _SNOW && !_SNOWOVERMACRO
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOW && _SNOWOVERMACRO
            half preserveAO = splats.Occlusion;
            #endif

            #if _WETNESS
            WaterBRDF(splats.Albedo, splats.Smoothness, splats.Metallic, max( si.wetness, _GlobalPorosityWetness.y) * _MaxWetness, porosity); 
            #endif


            #if _ALPHALAYER
            half blend = HeightBlend(splats.Height, 1 - macro.Height, si.layerBlend * macroBlend, _Contrast);
            splats = OverlayResults(splats, macro, blend);
            #elif _USEMACROTEXTURE
            splats = OverlayResults(splats, macro, macroBlend);
            #endif

            #if _SNOW && _SNOWOVERMACRO
               splats.Occlusion = preserveAO;
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            DoGlitter(splats, glitterShine, glitterReflect, si.wsNormal, si.wsView, si.macroUV);
            #endif

            #if _CUSTOMUSERFUNCTION
            CustomMegaSplatFunction_Final(si, splats);
            #endif

            return splats;
         }

         #if _DEBUG_OUTPUT_SPLATDATA
         float3 DebugSplatOutput(SplatInput si)
         {
            float3 data = float3(0,0,0);
            int i0 = round(si.valuesMain.x / max(si.weights.x, 0.00001));
            int i1 = round(si.valuesMain.y / max(si.weights.y, 0.00001));
            int i2 = round(si.valuesMain.z / max(si.weights.z, 0.00001));

            #if _TWOLAYER || _ALPHALAYER
            int i3 = round(si.valuesSecond.x / max(si.weights.x, 0.00001));
            int i4 = round(si.valuesSecond.y / max(si.weights.y, 0.00001));
            int i5 = round(si.valuesSecond.z / max(si.weights.z, 0.00001));
            data.z = si.layerBlend;
            #endif

            if (si.weights.x > si.weights.y && si.weights.x > si.weights.z)
            {
               data.x = i0 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i3 / 255.0;
               #endif
            }
            else if (si.weights.y > si.weights.x && si.weights.y > si.weights.z)
            {
               data.x = i1 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i4 / 255.0;
               #endif
            }
            else
            {
               data.x = i2 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i5 / 255.0;
               #endif
            }
            return data;
         }
         #endif

 
            UnityLight AdditiveLight (half3 normalWorld, half3 lightDir, half atten)
            {
               UnityLight l;

               l.color = _LightColor0.rgb;
               l.dir = lightDir;
               #ifndef USING_DIRECTIONAL_LIGHT
                  l.dir = normalize(l.dir);
               #endif
               l.ndotl = LambertTerm (normalWorld, l.dir);

               // shadow the light
               l.color *= atten;
               return l;
            }

            UnityLight MainLight (half3 normalWorld)
            {
               UnityLight l;
               #ifdef LIGHTMAP_OFF
                  
                  l.color = _LightColor0.rgb;
                  l.dir = _WorldSpaceLightPos0.xyz;
                  l.ndotl = LambertTerm (normalWorld, l.dir);
               #else
                  // no light specified by the engine
                  // analytical light might be extracted from Lightmap data later on in the shader depending on the Lightmap type
                  l.color = half3(0.f, 0.f, 0.f);
                  l.ndotl  = 0.f;
                  l.dir = half3(0.f, 0.f, 0.f);
               #endif

               return l;
            }

            inline half4 VertexGIForward(float2 uv1, float2 uv2, float3 posWorld, half3 normalWorld)
            {
               half4 ambientOrLightmapUV = 0;
               // Static lightmaps
               #ifdef LIGHTMAP_ON
                  ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                  ambientOrLightmapUV.zw = 0;
               // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
               #elif UNITY_SHOULD_SAMPLE_SH
                  #ifdef VERTEXLIGHT_ON
                     // Approximated illumination from non-important point lights
                     ambientOrLightmapUV.rgb = Shade4PointLights (
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, posWorld, normalWorld);
                  #endif

                  ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);     
               #endif

               #ifdef DYNAMICLIGHTMAP_ON
                  ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
               #endif

               return ambientOrLightmapUV;
            }

            void LightPBRDeferred(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic,
                           half occlusion, half alpha, float3 viewDir,
                           inout half3 indirectDiffuse, inout half3 indirectSpecular, inout half3 diffuseColor, inout half3 specularColor)
            {
               #if _PASSDEFERRED
               half lightAtten = 1;
               half roughness = 1 - smoothness;

               UnityLight light = MainLight (normalDirection);

               UnityGIInput d;
               UNITY_INITIALIZE_OUTPUT(UnityGIInput, d);
               d.light = light;
               d.worldPos = i.posWorld.xyz;
               d.worldViewDir = viewDir;
               d.atten = lightAtten;
               #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                  d.ambient = 0;
                  d.lightmapUV = i.ambientOrLightmapUV;
               #else
                  d.ambient = i.ambientOrLightmapUV.rgb;
                  d.lightmapUV = 0;
               #endif
               d.boxMax[0] = unity_SpecCube0_BoxMax;
               d.boxMin[0] = unity_SpecCube0_BoxMin;
               d.probePosition[0] = unity_SpecCube0_ProbePosition;
               d.probeHDR[0] = unity_SpecCube0_HDR;
               d.boxMax[1] = unity_SpecCube1_BoxMax;
               d.boxMin[1] = unity_SpecCube1_BoxMin;
               d.probePosition[1] = unity_SpecCube1_ProbePosition;
               d.probeHDR[1] = unity_SpecCube1_HDR;

               UnityGI gi = UnityGlobalIllumination(d, occlusion, 1.0 - smoothness, normalDirection );

               specularColor = metallic.xxx;
               float specularMonochrome;
               diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, specularMonochrome );

               indirectSpecular = (gi.indirect.specular);
               float NdotV = max(0.0,dot( normalDirection, viewDir ));
               specularMonochrome = 1.0-specularMonochrome;
               half grazingTerm = saturate( smoothness + specularMonochrome );
               indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
               indirectDiffuse = half3(0,0,0);
               indirectDiffuse += gi.indirect.diffuse;
               indirectDiffuse *= occlusion;

               #endif
            }


            half4 LightPBR(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic, 
                            half occlusion, half alpha, float3 viewDir, float4 ambientOrLightmapUV)
            {
                

                #if _PASSFORWARDBASE
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG(i.fogCoord, ramped);
                   return ramped;
                }
                #endif

                UnityLight light = MainLight (normalDirection);

                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDir;
                d.atten = lightAtten;
                #if LIGHTMAP_ON || DYNAMICLIGHTMAP_ON
                    d.ambient = 0;
                    d.lightmapUV = i.ambientOrLightmapUV;
                #else
                    d.ambient = i.ambientOrLightmapUV;
                    d.lightmapUV = 0;
                #endif

                d.boxMax[0] = unity_SpecCube0_BoxMax;
                d.boxMin[0] = unity_SpecCube0_BoxMin;
                d.probePosition[0] = unity_SpecCube0_ProbePosition;
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.boxMax[1] = unity_SpecCube1_BoxMax;
                d.boxMin[1] = unity_SpecCube1_BoxMin;
                d.probePosition[1] = unity_SpecCube1_ProbePosition;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = roughness;
                ugls_en_data.reflUVW = reflect( -viewDir, normalDirection );
                UnityGI gi = UnityGlobalIllumination(d, occlusion, normalDirection, ugls_en_data );

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, oneMinusReflectivity );
                

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, gi.light, gi.indirect);
                c.rgb += UNITY_BRDF_GI (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, occlusion, gi);
                c.rgb += emission;
                c.a = alpha;
                UNITY_APPLY_FOG(i.fogCoord, c.rgb);
                return c;

                #elif _PASSFORWARDADD
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG_COLOR(i.fogCoord, ramped.rgb, half4(0,0,0,0));
                   return ramped;
                }
                #endif

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, oneMinusReflectivity );

                UnityLight light = AdditiveLight (normalDirection, normalDirection, lightAtten);
                UnityIndirect noIndirect = (UnityIndirect)0;
                noIndirect.diffuse = 0;
                noIndirect.specular = 0;

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, light, noIndirect);
   
                UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
                c.a = alpha;
                return c;

                #endif
                return half4(1, 1, 0, 0);
            }

            float4 _SplatControl_TexelSize;

            struct VertexInput 
            {
                float4 vertex        : POSITION;
                float3 normal        : NORMAL;
                float2 texcoord0     : TEXCOORD0;
                #if !_PASSSHADOWCASTER && !_PASSMETA
                    float2 texcoord1 : TEXCOORD1;
                    float2 texcoord2 : TEXCOORD2;
                #endif
            };

            VirtualMapping GetMapping(VertexOutput i, sampler2D splatControl, sampler2D paramControl)
            {
               float2 texSize = _SplatControl_TexelSize.zw;
               float2 stp = _SplatControl_TexelSize.xy;
               // scale coords so we can take floor/frac to construct a cell
               float2 stepped = i.coords.xy * texSize;
               float2 uvBottom = floor(stepped);
               float2 uvFrac = frac(stepped);
               uvBottom /= texSize;

               float2 center = stp * 0.5;
               uvBottom += center;

               // construct uv/positions of triangle based on our interpolation point
               float2 cuv0, cuv1, cuv2;
               // make virtual triangle
               if (uvFrac.x > uvFrac.y)
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(stp.x, 0);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }
               else
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(0, stp.y);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }

               float2 uvBaryFrac = uvFrac * stp + uvBottom;
               float3 weights = Barycentric(uvBaryFrac, cuv0, cuv1, cuv2);
               VirtualMapping m = (VirtualMapping)0;
               m.weights = weights;
               m.c0 = tex2Dlod(splatControl, float4(cuv0, 0, 0));
               m.c1 = tex2Dlod(splatControl, float4(cuv1, 0, 0));
               m.c2 = tex2Dlod(splatControl, float4(cuv2, 0, 0));

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS || _FLOW || _FLOWREFRACTION || _LAVA
               fixed4 p0 = tex2Dlod(paramControl, float4(cuv0, 0, 0));
               fixed4 p1 = tex2Dlod(paramControl, float4(cuv1, 0, 0));
               fixed4 p2 = tex2Dlod(paramControl, float4(cuv2, 0, 0));
               m.param = p0 * weights.x + p1 * weights.y + p2 * weights.z;
               #endif
               return m;
            }

            SplatInput ToSplatInput(VertexOutput i, VirtualMapping m)
            {
               SplatInput o = (SplatInput)0;
               UNITY_INITIALIZE_OUTPUT(SplatInput,o);

               o.camDist = i.camDist;
               o.splatUV = i.coords;
               o.macroUV = i.coords;
               #if _SECONDUV
               o.macroUV = i.macroUV;
               #endif
               o.weights = m.weights;


               o.valuesMain = float3(m.c0.r, m.c1.r, m.c2.r);
               #if _TWOLAYER || _ALPHALAYER
               o.valuesSecond = float3(m.c0.g, m.c1.g, m.c2.g);
               o.layerBlend = m.c0.b * o.weights.x + m.c1.b * o.weights.y + m.c2.b * o.weights.z;
               #endif

               #if _TRIPLANAR
               o.triplanarUVW = i.triplanarUVW;
               o.triplanarBlend = i.extraData.xyz;
               #endif

               #if _FLOW || _FLOWREFRACTION || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.flowDir = m.param.xy;
               #endif

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.puddleHeight = m.param.a;
               #endif

               #if _WETNESS
               o.wetness = m.param.b;
               #endif

               #if _GEOMAP
               o.worldPos = i.posWorld;
               #endif

               return o;
            }

            LayerParams GetMainParams(VertexOutput i, inout VirtualMapping m, half2 texScale)
            {
               
               int i0 = (int)(m.c0.r * 255);
               int i1 = (int)(m.c1.r * 255);
               int i2 = (int)(m.c2.r * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               data.layerBlend = m.weights.x * m.c0.b + m.weights.y * m.c1.b + m.weights.z * m.c2.b;

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;
            }

            LayerParams GetSecondParams(VertexOutput i, VirtualMapping m, half2 texScale)
            {
               int i0 = (int)(m.c0.g * 255);
               int i1 = (int)(m.c1.g * 255);
               int i2 = (int)(m.c2.g * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;   
            }


            VertexOutput NoTessVert(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;

               o.tangent.xyz = cross(v.normal, float3(0,0,1));
               float4 tangent = float4(o.tangent, 1);
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(o.tangent, 1);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  o.tangent = tangent.xyz;
                  #endif
               }

               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(o.tangent, 1);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  o.tangent = tangent.xyz;
                  #endif
               }

               UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

               o.normal = UnityObjectToWorldNormal(v.normal);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

               o.coords.xy = v.texcoord0;
               #if _SECONDUV
               o.macroUV = v.texcoord0;
               o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
               #endif

               o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);


               #if !_PASSSHADOWCASTER && !_PASSMETA
               o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
               #endif

               float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
               o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
               float3 viewSpace = UnityObjectToViewPos(v.vertex);
               o.camDist.y = length(viewSpace.xyz);
               #if _TRIPLANAR
                  float3 norm = v.normal;
                  #if _TRIPLANAR_WORLDSPACE
                  o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                  norm = normalize(mul(unity_ObjectToWorld, norm));
                  #else
                  o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                  #endif
                  o.extraData.xyz = pow(abs(norm), _TriplanarContrast);
               #endif


               o.bitangent = normalize(cross(o.normal, o.tangent) * -1);  
               

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #elif !_PASSMETA && !_PASSDEFERRED
               UNITY_TRANSFER_FOG(o,o.pos);
               TRANSFER_VERTEX_TO_FRAGMENT(o)
               #endif
               return o;
            }


            #if _TESSDISTANCE || _TESSEDGE
            VertexOutput NoTessShadowVertBiased(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(0,0,0,0);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  #endif
               }
               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(0,0,0,0);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  #endif
                  UNITY_INITIALIZE_OUTPUT(VertexOutput,o);
               }
             
               o.normal = UnityObjectToWorldNormal(v.normal);
               v.vertex.xyz -= o.normal * _TessData1.yyy * half3(0.5, 0.5, 0.5);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.coords = v.texcoord0;

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #endif

               return o;
            }
            #endif

            #ifdef UNITY_CAN_COMPILE_TESSELLATION
            #if _TESSDISTANCE || _TESSEDGE 
            struct TessVertex 
            {
                 float4 vertex       : INTERNALTESSPOS;
                 float3 normal       : NORMAL;
                 float2 coords       : TEXCOORD0;      // uv, or triplanar UV
                 #if _TRIPLANAR
                 float3 triplanarUVW : TEXCOORD1;
                 float4 extraData    : TEXCOORD2;
                 #endif
                 float4 camDist      : TEXCOORD3;      // distance from camera (for fades) and fog

                 float3 posWorld     : TEXCOORD4;
                 float4 tangent      : TEXCOORD5;
                 float2 macroUV      : TEDCOORD6;
                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    LIGHTING_COORDS(7,8)
                    UNITY_FOG_COORDS(9)
                 #endif
                 float4 ambientOrLightmapUV : TEXCOORD10;
 
             };


            VertexOutput vert (TessVertex v) 
            {
                VertexOutput o = (VertexOutput)0;

                UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

                #if _CUSTOMUSERFUNCTION
                CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, v.tangent, v.coords.xy);
                #endif
                #if _USECURVEDWORLD
                V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                #endif

                o.ambientOrLightmapUV = v.ambientOrLightmapUV;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangent = normalize(cross(o.normal, o.tangent) * v.tangent.w);  
                o.pos = UnityObjectToClipPos(v.vertex);
                o.coords = v.coords;
                o.camDist = v.camDist;
                o.posWorld = v.posWorld;
                #if _SECONDUV
                o.macroUV = v.macroUV;
                #endif

                #if _TRIPLANAR
                o.triplanarUVW = v.triplanarUVW;
                o.extraData = v.extraData;
                #endif

                #if _PASSSHADOWCASTER
                TRANSFER_SHADOW_CASTER(o)
                #elif !_PASSMETA && !_PASSDEFERRED
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                #endif

                return o;
            }


                
             struct OutputPatchConstant {
                 float edge[3]         : SV_TessFactor;
                 float inside          : SV_InsideTessFactor;
                 float3 vTangent[4]    : TANGENT;
                 float2 vUV[4]         : TEXCOORD;
                 float3 vTanUCorner[4] : TANUCORNER;
                 float3 vTanVCorner[4] : TANVCORNER;
                 float4 vCWts          : TANWEIGHTS;
             };

             TessVertex tessvert (VertexInput v) 
             {
                 TessVertex o;
                 UNITY_INITIALIZE_OUTPUT(TessVertex,o);
                 #if _USECURVEDWORLD
                 V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                 #endif

                 o.vertex = v.vertex;
                 o.normal = v.normal;
                 o.coords.xy = v.texcoord0;
                 o.normal = UnityObjectToWorldNormal(v.normal);
                 o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

                 float4 tangent = float4(o.tangent.xyz, 1);
                 #if _SECONDUV
                 o.macroUV = v.texcoord0;
                 o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
                 #endif

                 o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);



                 #if !_PASSSHADOWCASTER && !_PASSMETA
                 o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
                 #endif

                 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
                 o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
                 float3 viewSpace = UnityObjectToViewPos(v.vertex);
                 o.camDist.y = length(viewSpace.xyz);
                 #if _TRIPLANAR
                    #if _TRIPLANAR_WORLDSPACE
                    o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #else
                    o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #endif
                    o.extraData.xyz = pow(abs(v.normal), _TriplanarContrast);
                 #endif

                 o.tangent.xyz = cross(v.normal, float3(0,0,1));
                 o.tangent.w = -1;

                 float tessFade = saturate((dist - _TessData2.x) / (_TessData2.y - _TessData2.x));
                 tessFade *= tessFade;
                 o.camDist.w = 1 - tessFade;

                 return o;
             }

             void displacement (inout TessVertex i)
             {
                  VertexOutput o = vert(i);
                  float3 viewDir = float3(0,0,1);

                  VirtualMapping mapping = GetMapping(o, _SplatControl, _SplatParams);
                  LayerParams mData = GetMainParams(o, mapping, _TexScales.xy);
                  SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

                  half3 extraData = float3(0,0,0);
                  #if _TRIPLANAR
                  extraData = o.extraData.xyz;
                  #endif

                  #if _TWOLAYER || _DETAILMAP
                  LayerParams sData = GetSecondParams(o, mapping, _TexScales.zw);
                  sData.layerBlend = mData.layerBlend;
                  SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);
                  float second = SampleLayerHeight(mapping.weights, viewDir, sData, extraData.xyz, _TessData1.z, _TessData2.z);
                  #endif

                  float splats = SampleLayerHeight(mapping.weights, viewDir, mData, extraData.xyz, _TessData1.z, _TessData2.z);

                  #if _TWOLAYER
                     // blend layers together..
                     float hfac = HeightBlend(splats, second, sData.layerBlend, _TessData2.z);
                     splats = lerp(splats, second, hfac);
                  #endif

                  half upBias = _TessData2.w;
                  #if _PERTEXDISPLACEPARAMS
                  float3 upBias3 = mData.upBias;
                     #if _TWOLAYER
                        upBias3 = lerp(upBias3, sData.upBias, hfac);
                     #endif
                  upBias = upBias3.x * mapping.weights.x + upBias3.y * mapping.weights.y + upBias3.z * mapping.weights.z;
                  #endif

                  #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
                     #if _PUDDLESPUSHTERRAIN
                     splats = max(splats - mapping.param.a, 0);
                     #else
                     splats = max(splats, mapping.param.a);
                     #endif
                  #endif

                  #if _TESSCENTERBIAS
                  splats -= 0.5;
                  #endif

                  #if _SNOW
                  float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                  float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                  float snowHeightFade = saturate((worldPos.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
                  splats += DoSnowDisplace(splats, i.coords.xy, worldNormal, snowHeightFade, mapping.param.a);
                  #endif

                  float3 offset = (lerp(i.normal, float3(0,1,0), upBias) * (i.camDist.w * _TessData1.y * splats));

                  #if _TESSDAMPENING
                  offset *= (mapping.c0.a * mapping.weights.x + mapping.c1.a * mapping.weights.y + mapping.c2.a * mapping.weights.z);
                  #endif

                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_PostDisplacement(i.vertex.xyz, offset, i.normal, i.tangent, i.coords.xy);
                  #else
                  i.vertex.xyz += offset;
                  #endif

             }

             #if _TESSEDGE
             float4 Tessellation(TessVertex v, TessVertex v1, TessVertex v2)
             {
                 return UnityEdgeLengthBasedTess(v.vertex, v1.vertex, v2.vertex, _TessData1.w);
             }
             #elif _TESSDISTANCE
             float4 Tessellation (TessVertex v0, TessVertex v1, TessVertex v2) 
             {
                return MegaSplatDistanceBasedTess( v0.camDist.w, v1.camDist.w, v2.camDist.w, _TessData1.x );
             }
             #endif

             OutputPatchConstant hullconst (InputPatch<TessVertex,3> v) {
                 OutputPatchConstant o = (OutputPatchConstant)0;
                 float4 ts = Tessellation( v[0], v[1], v[2] );
                 o.edge[0] = ts.x;
                 o.edge[1] = ts.y;
                 o.edge[2] = ts.z;
                 o.inside = ts.w;
                 return o;
             }
             [UNITY_domain("tri")]
             [UNITY_partitioning("fractional_odd")]
             [UNITY_outputtopology("triangle_cw")]
             [UNITY_patchconstantfunc("hullconst")]
             [UNITY_outputcontrolpoints(3)]
             TessVertex hull (InputPatch<TessVertex,3> v, uint id : SV_OutputControlPointID) 
             {
                 return v[id];
             }

             [UNITY_domain("tri")]
             VertexOutput domain (OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> vi, float3 bary : SV_DomainLocation) 
             {
                 TessVertex v = (TessVertex)0;
                 v.vertex =         vi[0].vertex * bary.x +       vi[1].vertex * bary.y +       vi[2].vertex * bary.z;
                 v.normal =         vi[0].normal * bary.x +       vi[1].normal * bary.y +       vi[2].normal * bary.z;
                 v.coords =         vi[0].coords * bary.x +       vi[1].coords * bary.y +       vi[2].coords * bary.z;
                 v.camDist =        vi[0].camDist * bary.x +      vi[1].camDist * bary.y +      vi[2].camDist * bary.z;
                 #if _TRIPLANAR
                 v.extraData =      vi[0].extraData * bary.x +    vi[1].extraData * bary.y +    vi[2].extraData * bary.z;
                 v.triplanarUVW =   vi[0].triplanarUVW * bary.x + vi[1].triplanarUVW * bary.y + vi[2].triplanarUVW * bary.z; 
                 #endif
                 v.tangent =        vi[0].tangent * bary.x +      vi[1].tangent * bary.y +      vi[2].tangent * bary.z;
                 v.macroUV =        vi[0].macroUV * bary.x +      vi[1].macroUV * bary.y +      vi[2].macroUV * bary.z;
                 v.posWorld =       vi[0].posWorld * bary.x +     vi[1].posWorld * bary.y +     vi[2].posWorld * bary.z;

                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    #if FOG_LINEAR || FOG_EXP || FOG_EXP2
                       v.fogCoord = vi[0].fogCoord * bary.x + vi[1].fogCoord * bary.y + vi[2].fogCoord * bary.z;
                    #endif
                    #if  SPOT || POINT_COOKIE || DIRECTIONAL_COOKIE 
                       v._LightCoord = vi[0]._LightCoord * bary.x + vi[1]._LightCoord * bary.y + vi[2]._LightCoord * bary.z; 
                       #if (SHADOWS_DEPTH && SPOT) || SHADOWS_CUBE || SHADOWS_DEPTH
                          v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y * vi[2]._ShadowCoord * bary.z; 
                       #endif
                    #elif DIRECTIONAL && (SHADOWS_CUBE || SHADOWS_DEPTH)
                       v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y + vi[2]._ShadowCoord * bary.z; 
                    #endif
                 #endif
                 v.ambientOrLightmapUV = vi[0].ambientOrLightmapUV * bary.x + vi[1].ambientOrLightmapUV * bary.y + vi[2].ambientOrLightmapUV * bary.z;

                 #if _TESSPHONG
                 float3 p = v.vertex.xyz;

                 // Calculate deltas to project onto three tangent planes
                 float3 p0 = dot(vi[0].vertex.xyz - p, vi[0].normal) * vi[0].normal;
                 float3 p1 = dot(vi[1].vertex.xyz - p, vi[1].normal) * vi[1].normal;
                 float3 p2 = dot(vi[2].vertex.xyz - p, vi[2].normal) * vi[2].normal;

                 // Lerp between projection vectors
                 float3 vecOffset = bary.x * p0 + bary.y * p1 + bary.z * p2;

                 // Add a fraction of the offset vector to the lerped position
                 p += 0.5 * vecOffset;

                 v.vertex.xyz = p;
                 #endif

                 displacement(v);
                 VertexOutput o = vert(v);
                 return o;
             }
            #endif
            #endif

            struct LightingTerms
            {
               half3 Albedo;
               half3 Normal;
               half  Smoothness;
               half  Metallic;
               half  Occlusion;
               half3 Emission;
               #if _ALPHA || _ALPHATEST
               half Alpha;
               #endif
            };

            void Splat(VertexOutput i, inout LightingTerms o, float3 viewDir, float3x3 tangentTransform)
            {
               VirtualMapping mapping = GetMapping(i, _SplatControl, _SplatParams);
               SplatInput si = ToSplatInput(i, mapping);
               si.viewDir = viewDir;
               #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
               si.wsView = viewDir;
               #endif

               MegaSplatLayer macro = (MegaSplatLayer)0;
               #if _SNOW
               float snowHeightFade = saturate((i.posWorld.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
               #endif

               #if _USEMACROTEXTURE || _ALPHALAYER
                  float2 muv = i.coords.xy;

                  #if _SECONDUV
                  muv = i.macroUV.xy;
                  #endif
                  macro = SampleMacro(muv);
                  #if _SNOW && _SNOWOVERMACRO

                  DoSnow(macro, muv, mul(tangentTransform, normalize(macro.Normal)), snowHeightFade, 0, _GlobalPorosityWetness.x, i.camDist.y);
                  #endif

                  #if _DISABLESPLATSINDISTANCE
                  if (i.camDist.x <= 0.0)
                  {
                     #if _CUSTOMUSERFUNCTION
                     CustomMegaSplatFunction_Final(si, macro);
                     #endif
                     o.Albedo = macro.Albedo;
                     o.Normal = macro.Normal;
                     o.Emission = macro.Emission;
                     #if !_RAMPLIGHTING
                     o.Smoothness = macro.Smoothness;
                     o.Metallic = macro.Metallic;
                     o.Occlusion = macro.Occlusion;
                     #endif
                     #if _ALPHA || _ALPHATEST
                     o.Alpha = macro.Alpha;
                     #endif

                     return;
                  }
                  #endif
               #endif

               #if _SNOW
               si.snowHeightFade = snowHeightFade;
               #endif

               MegaSplatLayer splats = DoSurf(si, macro, tangentTransform);

               #if _DEBUG_OUTPUT_ALBEDO
               o.Albedo = splats.Albedo;
               #elif _DEBUG_OUTPUT_HEIGHT
               o.Albedo = splats.Height.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_NORMAL
               o.Albedo = splats.Normal * 0.5 + 0.5 * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SMOOTHNESS
               o.Albedo = splats.Smoothness.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_METAL
               o.Albedo = splats.Metallic.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_AO
               o.Albedo = splats.Occlusion.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_EMISSION
               o.Albedo = splats.Emission * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SPLATDATA
               o.Albedo = DebugSplatOutput(si);
               #else
               o.Albedo = splats.Albedo;
               o.Normal = splats.Normal;
               o.Metallic = splats.Metallic;
               o.Smoothness = splats.Smoothness;
               o.Occlusion = splats.Occlusion;
               o.Emission = splats.Emission;
                  
               #endif

               #if _ALPHA || _ALPHATEST
                  o.Alpha = splats.Alpha;
               #endif
            }



            #if _PASSMETA
            half4 frag(VertexOutput i) : SV_Target 
            {
                i.normal = normalize(i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normal;
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );

                LightingTerms lt = (LightingTerms)0;

                float3x3 tangentTransform = (float3x3)0;
                #if _SNOW
                tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                #endif

                Splat(i, lt, viewDirection, tangentTransform);

                o.Emission = lt.Emission;
                
                float3 diffColor = lt.Albedo;
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, lt.Metallic, specColor, specularMonochrome );
                float roughness = 1.0 - lt.Smoothness;
                o.Albedo = diffColor + specColor * roughness * roughness * 0.5;
                return UnityMetaFragment( o );

            }
            #elif _PASSSHADOWCASTER
            half4 frag(VertexOutput i) : COLOR
            {
               SHADOW_CASTER_FRAGMENT(i)
            }
            #elif _PASSDEFERRED
            void frag(
                VertexOutput i,
                out half4 outDiffuse : SV_Target0,
                out half4 outSpecSmoothness : SV_Target1,
                out half4 outNormal : SV_Target2,
                out half4 outEmission : SV_Target3 )
            {
                i.normal = normalize(i.normal);
                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;
                Splat(i, o, viewDirection, tangentTransform);
                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif
                float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                
                half3 specularColor;
                half3 diffuseColor;
                half3 indirectDiffuse;
                half3 indirectSpecular;
                LightPBRDeferred(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, 
                  indirectDiffuse, indirectSpecular, diffuseColor, specularColor);
                
                outSpecSmoothness = half4(specularColor, o.Smoothness);
                outEmission = half4( o.Emission, 1 );
                outEmission.rgb += indirectSpecular * o.Occlusion;
                outEmission.rgb += indirectDiffuse * diffuseColor;
                #ifndef UNITY_HDR_ON
                    outEmission.rgb = exp2(-outEmission.rgb);
                #endif
                outDiffuse = half4(diffuseColor, o.Occlusion);
                outNormal = half4( normalDirection * 0.5 + 0.5, 1 );



            }
            #else
            half4 frag(VertexOutput i) : COLOR 
            {

                i.normal = normalize(i.normal);

                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;

                Splat(i, o, viewDirection, tangentTransform);

                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif

                #if _DEBUG_OUTPUT_ALBEDO || _DEBUG_OUTPUT_HEIGHT || _DEBUG_OUTPUT_NORMAL || _DEBUG_OUTPUT_SMOOTHNESS || _DEBUG_OUTPUT_METAL || _DEBUG_OUTPUT_AO || _DEBUG_OUTPUT_EMISSION
                   return half4(o.Albedo,1);
                #else
                   float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                   half4 lit = LightPBR(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, i.ambientOrLightmapUV);
                   #if _ALPHA || _ALPHATEST
                   lit.a = o.Alpha;
                   #endif
                   return lit;
                #endif

            }
            #endif


            #if _LOWPOLY
            [maxvertexcount(3)]
            void geom(triangle VertexOutput input[3], inout TriangleStream<VertexOutput> s)
            {
               VertexOutput v0 = input[0];
               VertexOutput v1 = input[1];
               VertexOutput v2 = input[2];

               float3 norm = input[0].normal + input[1].normal + input[2].normal;
               norm /= 3;
               float3 tangent = input[0].tangent + input[1].tangent + input[2].tangent;
               tangent /= 3;
              
               float3 bitangent = input[0].bitangent + input[1].bitangent + input[2].bitangent;
               bitangent /= 3;

               #if _LOWPOLYADJUST
               v0.normal = lerp(v0.normal, norm, _EdgeHardness);
               v1.normal = lerp(v1.normal, norm, _EdgeHardness);
               v2.normal = lerp(v2.normal, norm, _EdgeHardness);
              
               v0.tangent = lerp(v0.tangent, tangent, _EdgeHardness);
               v1.tangent = lerp(v1.tangent, tangent, _EdgeHardness);
               v2.tangent = lerp(v2.tangent, tangent, _EdgeHardness);
              
               v0.bitangent = lerp(v0.bitangent, bitangent, _EdgeHardness);;
               v1.bitangent = lerp(v1.bitangent, bitangent, _EdgeHardness);;
               v2.bitangent = lerp(v2.bitangent, bitangent, _EdgeHardness);;
               #else
               v0.normal = norm;
               v1.normal = norm;
               v2.normal = norm;
              
               v0.tangent = tangent;
               v1.tangent = tangent;
               v2.tangent = tangent;
              
               v0.bitangent = bitangent;
               v1.bitangent = bitangent;
               v2.bitangent = bitangent;
               #endif


               s.Append(v0);
               s.Append(v1);
               s.Append(v2);
            }
            #endif
            ENDCG
        }


      Pass 
      {
         Name "FORWARD_DELTA"
         Tags { "LightMode"="ForwardAdd" }
         Blend One One
         
         
         CGPROGRAM
         #define UNITY_PASS_FORWARDADD
         #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
         #define _GLOSSYENV 1
         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "Tessellation.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"
         #include "UnityMetaPass.cginc"
         #pragma multi_compile_fwdadd_fullshadows
         #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
         #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
         #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
         #pragma multi_compile_fog
         #pragma target 4.6
         #define _PASSFORWARDADD 1
         #pragma hull hull
         #pragma domain domain
         #pragma vertex tessvert
         #pragma fragment frag

      #define _NORMALMAP 1
      #define _PERTEXAOSTRENGTH 1
      #define _PERTEXCONTRAST 1
      #define _PERTEXDISPLACEPARAMS 1
      #define _PERTEXGLITTER 1
      #define _PERTEXMATPARAMS 1
      #define _PERTEXNORMALSTRENGTH 1
      #define _PERTEXUV 1
      #define _PUDDLEGLITTER 1
      #define _PUDDLES 1
      #define _PUDDLESPUSHTERRAIN 1
      #define _TERRAIN 1
      #define _TESSCENTERBIAS 1
      #define _TESSDAMPENING 1
      #define _TESSDISTANCE 1
      #define _TESSFALLBACK 1
      #define _TWOLAYER 1
      #define _WETNESS 1



         struct MegaSplatLayer
         {
            half3 Albedo;
            half3 Normal;
            half3 Emission;
            half  Metallic;
            half  Smoothness;
            half  Occlusion;
            half  Height;
            half  Alpha;
         };

         struct SplatInput
         {
            float3 weights;
            float2 splatUV;
            float2 macroUV;
            float3 valuesMain;
            half3 viewDir;
            float4 camDist;

            #if _TWOLAYER || _ALPHALAYER
            float3 valuesSecond;
            half layerBlend;
            #endif

            #if _TRIPLANAR
            float3 triplanarUVW;
            #endif
            half3 triplanarBlend; // passed to func, so always present

            #if _FLOW || _FLOWREFRACTION || _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half2 flowDir;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half puddleHeight;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            float3 waterNormalFoam;
            #endif

            #if _WETNESS
            half wetness;
            #endif

            #if _TESSDAMPENING
            half displacementDampening;
            #endif

            #if _SNOW
            half snowHeightFade;
            #endif

            #if _SNOW || _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsNormal;
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsView;
            #endif

            #if _GEOMAP
            float3 worldPos;
            #endif
         };


         struct LayerParams
         {
            float3 uv0, uv1, uv2;
            float2 mipUV; // uv for mip selection
            #if _TRIPLANAR
            float3 tpuv0_x, tpuv0_y, tpuv0_z;
            float3 tpuv1_x, tpuv1_y, tpuv1_z;
            float3 tpuv2_x, tpuv2_y, tpuv2_z;
            #endif
            #if _FLOW || _FLOWREFRACTION
            float3 fuv0a, fuv0b;
            float3 fuv1a, fuv1b;
            float3 fuv2a, fuv2b;
            #endif

            #if _DISTANCERESAMPLE
               half distanceBlend;
               float3 db_uv0, db_uv1, db_uv2;
               #if _TRIPLANAR
               float3 db_tpuv0_x, db_tpuv0_y, db_tpuv0_z;
               float3 db_tpuv1_x, db_tpuv1_y, db_tpuv1_z;
               float3 db_tpuv2_x, db_tpuv2_y, db_tpuv2_z;
               #endif
            #endif

            half layerBlend;
            half3 metallic;
            half3 smoothness;
            half3 porosity;
            #if _FLOW || _FLOWREFRACTION
            half3 flowIntensity;
            half flowOn;
            half3 flowAlphas;
            half3 flowRefracts;
            half3 flowInterps;
            #endif
            half3 weights;

            #if _TESSDISTANCE || _TESSEDGE
            half3 displacementScale;
            half3 upBias;
            #endif

            #if _PERTEXNOISESTRENGTH
            half3 detailNoiseStrength;
            #endif

            #if _PERTEXNORMALSTRENGTH
            half3 normalStrength;
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            half3 parallaxStrength;
            #endif

            #if _PERTEXAOSTRENGTH
            half3 aoStrength;
            #endif

            #if _PERTEXGLITTER
            half3 perTexGlitterReflect;
            #endif

            half3 contrast;
         };

         struct VirtualMapping
         {
            float3 weights;
            fixed4 c0, c1, c2;
            fixed4 param;
         };



         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"

         // splat
         UNITY_DECLARE_TEX2DARRAY(_Diffuse);
         float4 _Diffuse_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_Normal);
         float4 _Normal_TexelSize;
         #if _EMISMAP
         UNITY_DECLARE_TEX2DARRAY(_Emissive);
         float4 _Emissive_TexelSize;
         #endif
         #if _DETAILMAP
         UNITY_DECLARE_TEX2DARRAY(_DetailAlbedo);
         float4 _DetailAlbedo_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_DetailNormal);
         float4 _DetailNormal_TexelSize;
         half _DetailTextureStrength;
         #endif

         #if _ALPHA || _ALPHATEST
         UNITY_DECLARE_TEX2DARRAY(_AlphaArray);
         float4 _AlphaArray_TexelSize;
         #endif

         #if _LOWPOLY
         half _EdgeHardness;
         #endif

         #if _TERRAIN
         sampler2D _SplatControl;
         sampler2D _SplatParams;
         #endif

         #if _ALPHAHOLE
         int _AlphaHoleIdx;
         #endif

         #if _RAMPLIGHTING
         sampler2D _Ramp;
         #endif

         #if _UVLOCALTOP || _UVWORLDTOP || _UVLOCALFRONT || _UVWORLDFRONT || _UVLOCALSIDE || _UVWORLDSIDE
         float4 _UVProjectOffsetScale;
         #endif
         #if _UVLOCALTOP2 || _UVWORLDTOP2 || _UVLOCALFRONT2 || _UVWORLDFRONT2 || _UVLOCALSIDE2 || _UVWORLDSIDE2
         float4 _UVProjectOffsetScale2;
         #endif

         half _Contrast;

         #if _ALPHALAYER || _USEMACROTEXTURE
         // macro texturing
         sampler2D _MacroDiff;
         sampler2D _MacroBump;
         sampler2D _MetallicGlossMap;
         sampler2D _MacroAlpha;
         half2 _MacroTexScale;
         half _MacroTextureStrength;
         half2 _MacroTexNormAOScales;
         #endif

         // default spec
         half _Glossiness;
         half _Metallic;

         #if _DISTANCERESAMPLE
         float3  _ResampleDistanceParams;
         #endif

         #if _FLOW || _FLOWREFRACTION
         // flow
         half _FlowSpeed;
         half _FlowAlpha;
         half _FlowIntensity;
         half _FlowRefraction;
         #endif

         half2 _PerTexScaleRange;
         sampler2D _PropertyTex;

         // etc
         half2 _Parallax;
         half4 _TexScales;

         float4 _DistanceFades;
         float4 _DistanceFadesCached;
         int _ControlSize;

         #if _TRIPLANAR
         half _TriplanarTexScale;
         half _TriplanarContrast;
         float3 _TriplanarOffset;
         #endif

         #if _GEOMAP
         sampler2D _GeoTex;
         float3 _GeoParams;
         #endif

         #if _PROJECTTEXTURE_LOCAL || _PROJECTTEXTURE_WORLD
         half3 _ProjectTexTop;
         half3 _ProjectTexSide;
         half3 _ProjectTexBottom;
         half3 _ProjectTexThresholdFreq;
         #endif

         #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
         half3 _ProjectTexTop2;
         half3 _ProjectTexSide2;
         half3 _ProjectTexBottom2;
         half3 _ProjectTexThresholdFreq2;
         half4 _ProjectTexBlendParams;
         #endif

         #if _TESSDISTANCE || _TESSEDGE
         float4 _TessData1; // distance tessellation, displacement, edgelength
         float4 _TessData2; // min, max
         #endif

         #if _DETAILNOISE
         sampler2D _DetailNoise;
         half3 _DetailNoiseScaleStrengthFade;
         #endif

         #if _DISTANCENOISE
         sampler2D _DistanceNoise;
         half4 _DistanceNoiseScaleStrengthFade;
         #endif

         #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
         half3 _PuddleTint;
         half _PuddleBlend;
         half _MaxPuddles;
         half4 _PuddleFlowParams;
         half2 _PuddleNormalFoam;
         #endif

         #if _RAINDROPS
         sampler2D _RainDropTexture;
         half _RainIntensity;
         float2 _RainUVScales;
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         float2 _PuddleUVScales;
         sampler2D _PuddleNormal;
         #endif

         #if _LAVA
         sampler2D _LavaDiffuse;
         sampler2D _LavaNormal;
         half4 _LavaParams;
         half4 _LavaParams2;
         half3 _LavaEdgeColor;
         half3 _LavaColorLow;
         half3 _LavaColorHighlight;
         float2 _LavaUVScale;
         #endif

         #if _WETNESS
         half _MaxWetness;
         #endif

         half2 _GlobalPorosityWetness;

         #if _SNOW
         sampler2D _SnowDiff;
         sampler2D _SnowNormal;
         half4 _SnowParams; // influence, erosion, crystal, melt
         half _SnowAmount;
         half2 _SnowUVScales;
         half2 _SnowHeightRange;
         half3 _SnowUpVector;
         #endif

         #if _SNOWDISTANCENOISE
         sampler2D _SnowDistanceNoise;
         float4 _SnowDistanceNoiseScaleStrengthFade;
         #endif

         #if _SNOWDISTANCERESAMPLE
         float4 _SnowDistanceResampleScaleStrengthFade;
         #endif

         #if _PERTEXGLITTER || _SNOWGLITTER || _PUDDLEGLITTER
         sampler2D _GlitterTexture;
         half4 _GlitterParams;
         half4 _GlitterSurfaces;
         #endif


         struct VertexOutput 
         {
             float4 pos          : SV_POSITION;
             #if !_TERRAIN
             fixed3 weights      : TEXCOORD0;
             float4 valuesMain   : TEXCOORD1;      //index rgb, triplanar W
                #if _TWOLAYER || _ALPHALAYER
                float4 valuesSecond : TEXCOORD2;      //index rgb + alpha
                #endif
             #elif _TRIPLANAR
             float3 triplanarUVW : TEXCOORD3;
             #endif
             float2 coords       : TEXCOORD4;      // uv, or triplanar UV
             float3 posWorld     : TEXCOORD5;
             float3 normal       : TEXCOORD6;

             float4 camDist      : TEXCOORD7;      // distance from camera (for fades) and fog
             float4 extraData    : TEXCOORD8;      // flowdir + fades, or if triplanar triplanarView + detailFade
             float3 tangent      : TEXCOORD9;
             float3 bitangent    : TEXCOORD10;
             float4 ambientOrLightmapUV : TEXCOORD14;


             #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
             LIGHTING_COORDS(11,12)
             UNITY_FOG_COORDS(13)
             #endif

             #if _PASSSHADOWCASTER
             float3 vec : TEXCOORD11;  // nice naming, Unity...
             #endif

             #if _WETNESS
             half wetness : TEXCOORD15;   //wetness
             #endif

             #if _SECONDUV
             float3 macroUV : TEXCOORD16;
             #endif

         };

         void OffsetUVs(inout LayerParams p, float2 offset)
         {
            p.uv0.xy += offset;
            p.uv1.xy += offset;
            p.uv2.xy += offset;
            #if _TRIPLANAR
            p.tpuv0_x.xy += offset;
            p.tpuv0_y.xy += offset;
            p.tpuv0_z.xy += offset;
            p.tpuv1_x.xy += offset;
            p.tpuv1_y.xy += offset;
            p.tpuv1_z.xy += offset;
            p.tpuv2_x.xy += offset;
            p.tpuv2_y.xy += offset;
            p.tpuv2_z.xy += offset;
            #endif
         }


         void InitDistanceResample(inout LayerParams lp, float dist)
         {
            #if _DISTANCERESAMPLE
               lp.distanceBlend = saturate((dist - _ResampleDistanceParams.y) / (_ResampleDistanceParams.z - _ResampleDistanceParams.y));
               lp.db_uv0 = lp.uv0;
               lp.db_uv1 = lp.uv1;
               lp.db_uv2 = lp.uv2;

               lp.db_uv0.xy *= _ResampleDistanceParams.xx;
               lp.db_uv1.xy *= _ResampleDistanceParams.xx;
               lp.db_uv2.xy *= _ResampleDistanceParams.xx;


               #if _TRIPLANAR
               lp.db_tpuv0_x = lp.tpuv0_x;
               lp.db_tpuv1_x = lp.tpuv1_x;
               lp.db_tpuv2_x = lp.tpuv2_x;
               lp.db_tpuv0_y = lp.tpuv0_y;
               lp.db_tpuv1_y = lp.tpuv1_y;
               lp.db_tpuv2_y = lp.tpuv2_y;
               lp.db_tpuv0_z = lp.tpuv0_z;
               lp.db_tpuv1_z = lp.tpuv1_z;
               lp.db_tpuv2_z = lp.tpuv2_z;

               lp.db_tpuv0_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_z.xy *= _ResampleDistanceParams.xx;
               #endif
            #endif
         }


         LayerParams NewLayerParams()
         {
            LayerParams l = (LayerParams)0;
            l.metallic = _Metallic.xxx;
            l.smoothness = _Glossiness.xxx;
            l.porosity = _GlobalPorosityWetness.xxx;

            l.layerBlend = 0;
            #if _FLOW || _FLOWREFRACTION
            l.flowIntensity = 0;
            l.flowOn = 0;
            l.flowAlphas = half3(1,1,1);
            l.flowRefracts = half3(1,1,1);
            #endif

            #if _TESSDISTANCE || _TESSEDGE
            l.displacementScale = half3(1,1,1);
            l.upBias = half3(0,0,0);
            #endif

            #if _PERTEXNOISESTRENGTH
            l.detailNoiseStrength = half3(1,1,1);
            #endif

            #if _PERTEXNORMALSTRENGTH
            l.normalStrength = half3(1,1,1);
            #endif

            #if _PERTEXAOSTRENGTH
            l.aoStrength = half3(1,1,1);
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            l.parallaxStrength = half3(1,1,1);
            #endif

            l.contrast = _Contrast;

            return l;
         }

         half AOContrast(half ao, half scalar)
         {
            scalar += 0.5;  // 0.5 -> 1.5
            scalar *= scalar; // 0.25 -> 2.25
            return pow(ao, scalar);
         }

         half MacroAOContrast(half ao, half scalar)
         {
            #if _MACROAOSCALE
            return AOContrast(ao, scalar);
            #else
            return ao;
            #endif
         }
         #if _USEMACROTEXTURE || _ALPHALAYER
         MegaSplatLayer SampleMacro(float2 uv)
         {
             MegaSplatLayer o = (MegaSplatLayer)0;
             float2 macroUV = uv * _MacroTexScale.xy;
             half4 macAlb = tex2D(_MacroDiff, macroUV);
             o.Albedo = macAlb.rgb;
             o.Height = macAlb.a;
             // defaults
             o.Normal = half3(0,0,1);
             o.Occlusion = 1;
             o.Smoothness = _Glossiness;
             o.Metallic = _Metallic;
             o.Emission = half3(0,0,0);

             // unpack normal
             #if !_NOSPECTEX
             half4 normSample = tex2D(_MacroBump, macroUV);
             o.Normal = UnpackNormal(normSample);
             o.Normal.xy *= _MacroTexNormAOScales.x;
             #else
             o.Normal = half3(0,0,1);
             #endif


             #if _ALPHA || _ALPHATEST
             o.Alpha = tex2D(_MacroAlpha, macroUV).r;
             #endif
             return o;
         }
         #endif


         #if _NOSPECTEX
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = UnpackNormal(norm); 

         #elif _NOSPECNORMAL   
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = half3(0,0,1);

         #else
            #define SAMPLESPEC(o, params) \
              half4 spec0, spec1, spec2; \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.yw =  norm.zw; \
              specFinal.x = (params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z); \
              norm.xy *= 2; \
              norm.xy -= 1; \
              o.Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy)))); \

         #endif

         void SamplePerTex(sampler2D pt, inout LayerParams params, float2 scaleRange)
         {
            const half cent = 1.0 / 512.0;
            const half pixelStep = 1.0 / 256.0;
            const half vertStep = 1.0 / 8.0;

            // pixel layout for per tex properties
            // metal/smooth/porosity/uv scale
            // flow speed, intensity, alpha, refraction
            // detailNoiseStrength, contrast, displacementAmount, displaceUpBias

            #if _PERTEXMATPARAMS || _PERTEXUV
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, 0, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, 0, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, 0, 0, 0));
               params.porosity = half3(0.4, 0.4, 0.4);
               #if _PERTEXMATPARAMS
               params.metallic = half3(props0.r, props1.r, props2.r);
               params.smoothness = half3(props0.g, props1.g, props2.g);
               params.porosity = half3(props0.b, props1.b, props2.b);
               #endif
               #if _PERTEXUV
               float3 uvScale = float3(props0.a, props1.a, props2.a);
               uvScale = lerp(scaleRange.xxx, scaleRange.yyy, uvScale);
               params.uv0.xy *= uvScale.x;
               params.uv1.xy *= uvScale.y;
               params.uv2.xy *= uvScale.z;

                  #if _TRIPLANAR
                  params.tpuv0_x.xy *= uvScale.xx; params.tpuv0_y.xy *= uvScale.xx; params.tpuv0_z.xy *= uvScale.xx;
                  params.tpuv1_x.xy *= uvScale.yy; params.tpuv1_y.xy *= uvScale.yy; params.tpuv1_z.xy *= uvScale.yy;
                  params.tpuv2_x.xy *= uvScale.zz; params.tpuv2_y.xy *= uvScale.zz; params.tpuv2_z.xy *= uvScale.zz;
                  #endif

               #endif
            }
            #endif


            #if _FLOW || _FLOWREFRACTION
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 3, 0, 0));

               params.flowIntensity = half3(props0.r, props1.r, props2.r);
               params.flowOn = params.flowIntensity.x + params.flowIntensity.y + params.flowIntensity.z;

               params.flowAlphas = half3(props0.b, props1.b, props2.b);
               params.flowRefracts = half3(props0.a, props1.a, props2.a);
            }
            #endif

            #if _PERTEXDISPLACEPARAMS || _PERTEXCONTRAST || _PERTEXNOISESTRENGTH
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 5, 0, 0));

               #if _PERTEXDISPLACEPARAMS && (_TESSDISTANCE || _TESSEDGE)
               params.displacementScale = half3(props0.b, props1.b, props2.b);
               params.upBias = half3(props0.a, props1.a, props2.a);
               #endif

               #if _PERTEXCONTRAST
               params.contrast = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXNOISESTRENGTH
               params.detailNoiseStrength = half3(props0.r, props1.r, props2.r);
               #endif
            }
            #endif

            #if _PERTEXNORMALSTRENGTH || _PERTEXPARALLAXSTRENGTH || _PERTEXAOSTRENGTH || _PERTEXGLITTER
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 7, 0, 0));

               #if _PERTEXNORMALSTRENGTH
               params.normalStrength = half3(props0.r, props1.r, props2.r);
               #endif

               #if _PERTEXPARALLAXSTRENGTH
               params.parallaxStrength = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXAOSTRENGTH
               params.aoStrength = half3(props0.b, props1.b, props2.b);
               #endif

               #if _PERTEXGLITTER
               params.perTexGlitterReflect = half3(props0.a, props1.a, props2.a);
               #endif

            }
            #endif
         }

         float FlowRefract(MegaSplatLayer tex, inout LayerParams main, inout LayerParams second, half3 weights)
         {
            #if _FLOWREFRACTION
            float totalFlow = second.flowIntensity.x * weights.x + second.flowIntensity.y * weights.y + second.flowIntensity.z * weights.z;
            float falpha = second.flowAlphas.x * weights.x + second.flowAlphas.y * weights.y + second.flowAlphas.z * weights.z;
            float frefract = second.flowRefracts.x * weights.x + second.flowRefracts.y * weights.y + second.flowRefracts.z * weights.z;
            float refractOn = min(1, totalFlow * 10000);
            float ratio = lerp(1.0, _FlowAlpha * falpha, refractOn);
            float2 rOff = tex.Normal.xy * _FlowRefraction * frefract * ratio;
            main.uv0.xy += rOff;
            main.uv1.xy += rOff;
            main.uv2.xy += rOff;
            return ratio;
            #endif
            return 1;
         }

         float MipLevel(float2 uv, float2 textureSize)
         {
            uv *= textureSize;
            float2  dx_vtc        = ddx(uv);
            float2  dy_vtc        = ddy(uv);
            float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
            return 0.5 * log2(delta_max_sqr);
         }


         #if _DISTANCERESAMPLE
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l); \
                  { \
                     half4 st0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_z, l); \
                     half4 st1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_z, l); \
                     half4 st2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_z, l); \
                     t0 = lerp(t0, st0, lp.distanceBlend); \
                     t1 = lerp(t1, st1, lp.distanceBlend); \
                     t2 = lerp(t2, st2, lp.distanceBlend); \
                  }
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); 
               #endif
            #endif
         #else // not distance resample
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l);
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l);
               #endif
            #endif
         #endif


         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, lod);
         #else
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, lod);
         #endif

         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z + offset, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z + offset, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z + offset, lod);
         #else
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0 + offset, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1 + offset, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2 + offset, lod);
         #endif

         void Flow(float3 uv, half2 flow, half speed, float intensity, out float3 uv1, out float3 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));
            uv1.z = uv.z;
            uv2.z = uv.z;

            interp = abs(0.5 - phase.x) / 0.5;
         }

         void Flow(float2 uv, half2 flow, half speed, float intensity, out float2 uv1, out float2 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));

            interp = abs(0.5 - phase.x) / 0.5;
         }

         half3 ComputeWeights(half3 iWeights, half4 tex0, half4 tex1, half4 tex2, half contrast)
         {
             // compute weight with height map
             const half epsilon = 1.0f / 1024.0f;
             half3 weights = half3(iWeights.x * (tex0.a + epsilon), 
                                      iWeights.y * (tex1.a + epsilon),
                                      iWeights.z * (tex2.a + epsilon));

             // Contrast weights
             half maxWeight = max(weights.x, max(weights.y, weights.z));
             half transition = contrast * maxWeight;
             half threshold = maxWeight - transition;
             half scale = 1.0f / transition;
             weights = saturate((weights - threshold) * scale);
             // Normalize weights.
             half weightScale = 1.0f / (weights.x + weights.y + weights.z);
             weights *= weightScale;
             #if _LINEARBIAS
             weights = lerp(weights, iWeights, contrast);
             #endif
             return weights;
         }

         float2 ProjectUVs(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP
            return (vertex.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALSIDE
            return (vertex.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALFRONT
            return (vertex.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDTOP
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(1,0,0));
               tangent.w = worldNormal.y > 0 ? -1 : 1;
               #endif
            return (worldPos.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDFRONT
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,0,1));
               tangent.w = worldNormal.x > 0 ? 1 : -1;
               #endif
            return (worldPos.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDSIDE
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,1,0));
               tangent.w = worldNormal.z > 0 ? 1 : -1;
               #endif
            return (worldPos.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #endif
            return coords;
         }

         float2 ProjectUV2(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP2
            return (vertex.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALSIDE2
            return (vertex.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALFRONT2
            return (vertex.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDTOP2
            return (worldPos.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDFRONT2
            return (worldPos.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDSIDE2
            return (worldPos.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #endif
            return coords;
         }

         void WaterBRDF (inout half3 Albedo, inout half Smoothness, half metalness, half wetFactor, half surfPorosity) 
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS
            half porosity = saturate((( (1 - Smoothness) - 0.5)) / max(surfPorosity, 0.001));
            half factor = lerp(1, 0.2, (1 - metalness) * porosity);
            Albedo *= lerp(1.0, factor, wetFactor);
            Smoothness = lerp(1.0, Smoothness, lerp(1.0, factor, wetFactor));
            #endif
         }

         #if _RAINDROPS
         float3 ComputeRipple(float2 uv, float time, float weight)
         {
            float4 ripple = tex2D(_RainDropTexture, uv);
            ripple.yz = ripple.yz * 2 - 1;

            float dropFrac = frac(ripple.w + time);
            float timeFrac = dropFrac - 1.0 + ripple.x;
            float dropFactor = saturate(0.2f + weight * 0.8 - dropFrac);
            float finalFactor = dropFactor * ripple.x * 
                                 sin( clamp(timeFrac * 9.0f, 0.0f, 3.0f) * 3.14159265359);

            return float3(ripple.yz * finalFactor * 0.35f, 1.0f);
         }
         #endif

         // water normal only
         half2 DoPuddleRefract(float3 waterNorm, half puddleLevel, float2 flowDir, half height)
         {
            #if _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - height) * _PuddleBlend);
            waterBlend *= waterBlend;

            waterNorm.xy *= puddleLevel * waterBlend;
               #if _PUDDLEDEPTHDAMPEN
               return lerp(waterNorm.xy, waterNorm.xy * height, _PuddleFlowParams.w);
               #endif
            return waterNorm.xy;

            #endif
            return half2(0,0);
         }

         // modity lighting terms for water..
         float DoPuddles(inout MegaSplatLayer o, float2 uv, half3 waterNormFoam, half puddleLevel, half2 flowDir, half porosity, float3 worldNormal)
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - o.Height) * _PuddleBlend);

            half3 waterNorm = half3(0,0,1);
            #if _PUDDLEFLOW || _PUDDLEREFRACT

               waterNorm = half3(waterNormFoam.x, waterNormFoam.y, sqrt(1 - saturate(dot(waterNormFoam.xy, waterNormFoam.xy))));

               #if _PUDDLEFOAM
               half pmh = puddleLevel - o.Height;
               // refactor to compute flow UVs in previous step?
               float2 foamUV0;
               float2 foamUV1;
               half foamInterp;
               Flow(uv * 1.75 + waterNormFoam.xy * waterNormFoam.b, flowDir, _PuddleFlowParams.y/3, _PuddleFlowParams.z/3, foamUV0, foamUV1, foamInterp);
               half foam0 = tex2D(_PuddleNormal, foamUV0).b;
               half foam1 = tex2D(_PuddleNormal, foamUV1).b;
               half foam = lerp(foam0, foam1, foamInterp);
               foam = foam * abs(pmh) + (foam * o.Height);
               foam *= 1.0 - (saturate(pmh * 1.5));
               foam *= foam;
               foam *= _PuddleNormalFoam.y;
               #endif // foam
            #endif // flow, refract

            half3 wetAlbedo = o.Albedo * _PuddleTint * 2;
            half wetSmoothness = o.Smoothness;

            WaterBRDF(wetAlbedo, wetSmoothness, o.Metallic, waterBlend, porosity);

            #if _RAINDROPS
               float dropStrength = _RainIntensity;
               #if _RAINDROPFLATONLY
               dropStrength = saturate(dot(float3(0,1,0), worldNormal));
               #endif
               const float4 timeMul = float4(1.0f, 0.85f, 0.93f, 1.13f); 
               float4 timeAdd = float4(0.0f, 0.2f, 0.45f, 0.7f);
               float4 times = _Time.yyyy;
               times = frac((times * float4(1, 0.85, 0.93, 1.13) + float4(0, 0.2, 0.45, 0.7)) * 1.6);

               float2 ruv1 = uv * _RainUVScales.xy;
               float2 ruv2 = ruv1;

               float4 weights = _RainIntensity.xxxx - float4(0, 0.25, 0.5, 0.75);
               float3 ripple1 = ComputeRipple(ruv1 + float2( 0.25f,0.0f), times.x, weights.x);
               float3 ripple2 = ComputeRipple(ruv2 + float2(-0.55f,0.3f), times.y, weights.y);
               float3 ripple3 = ComputeRipple(ruv1 + float2(0.6f, 0.85f), times.z, weights.z);
               float3 ripple4 = ComputeRipple(ruv2 + float2(0.5f,-0.75f), times.w, weights.w);
               weights = saturate(weights * 4);

               float4 z = lerp(float4(1,1,1,1), float4(ripple1.z, ripple2.z, ripple3.z, ripple4.z), weights);
               float3 rippleNormal = float3( weights.x * ripple1.xy +
                           weights.y * ripple2.xy + 
                           weights.z * ripple3.xy + 
                           weights.w * ripple4.xy, 
                           z.x * z.y * z.z * z.w);

               waterNorm = lerp(waterNorm, normalize(rippleNormal+waterNorm), _RainIntensity * dropStrength);                         
            #endif

            #if _PUDDLEFOAM
            wetAlbedo += foam;
            wetSmoothness -= foam;
            #endif

            o.Normal = lerp(o.Normal, waterNorm, waterBlend * _PuddleNormalFoam.x);
            o.Occlusion = lerp(o.Occlusion, 1, waterBlend);
            o.Smoothness = lerp(o.Smoothness, wetSmoothness, waterBlend);
            o.Albedo = lerp(o.Albedo, wetAlbedo, waterBlend);
            return waterBlend;
            #endif
            return 0;
         }

         float DoLava(inout MegaSplatLayer o, float2 uv, half lavaLevel, half2 flowDir)
         {
            #if _LAVA

            half distortionSize = _LavaParams2.x;
            half distortionRate = _LavaParams2.y;
            half distortionScale = _LavaParams2.z;
            half darkening = _LavaParams2.w;
            half3 edgeColor = _LavaEdgeColor;
            half3 lavaColorLow = _LavaColorLow;
            half3 lavaColorHighlight = _LavaColorHighlight;


            half maxLava = _LavaParams.y;
            half lavaSpeed = _LavaParams.z;
            half lavaInterp = _LavaParams.w;

            lavaLevel *= maxLava;
            float lvh = lavaLevel - o.Height;
            float lavaBlend = saturate(lvh * _LavaParams.x);

            float2 uv1;
            float2 uv2;
            half interp;
            half drag = lerp(0.1, 1, saturate(lvh));
            Flow(uv, flowDir, lavaInterp, lavaSpeed * drag, uv1, uv2, interp);

            float2 dist_uv1;
            float2 dist_uv2;
            half dist_interp;
            Flow(uv * distortionScale, flowDir, distortionRate, distortionSize, dist_uv1, dist_uv2, dist_interp);

            half4 lavaDist = lerp(tex2D(_LavaDiffuse, dist_uv1*0.51), tex2D(_LavaDiffuse, dist_uv2), dist_interp);
            half4 dist = lavaDist * (distortionSize * 2) - distortionSize;

            half4 lavaTex = lerp(tex2D(_LavaDiffuse, uv1*1.1 + dist.xy), tex2D(_LavaDiffuse, uv2 + dist.zw), interp);

            lavaTex.xy = lavaTex.xy * 2 - 1;
            half3 lavaNorm = half3(lavaTex.xy, sqrt(1 - saturate(dot(lavaTex.xy, lavaTex.xy))));

            // base lava color, based on heights
            half3 lavaColor = lerp(lavaColorLow, lavaColorHighlight, lavaTex.b);

            // edges
            float lavaBlendWide = saturate((lavaLevel - o.Height) * _LavaParams.x * 0.5);
            float edge = saturate((1 - lavaBlendWide) * 3);

            // darkening
            darkening = saturate(lavaTex.a * darkening * saturate(lvh*2));
            lavaColor = lerp(lavaColor, lavaDist.bbb * 0.3, darkening);
            // edges
            lavaColor = lerp(lavaColor, edgeColor, edge);

            o.Albedo = lerp(o.Albedo, lavaColor, lavaBlend);
            o.Normal = lerp(o.Normal, lavaNorm, lavaBlend);
            o.Smoothness = lerp(o.Smoothness, 0.3, lavaBlend * darkening);

            half3 emis = lavaColor * lavaBlend;
            o.Emission = lerp(o.Emission, emis, lavaBlend);
            // bleed
            o.Emission += edgeColor * 0.3 * (saturate((lavaLevel*1.2 - o.Height) * _LavaParams.x) - lavaBlend);
            return lavaBlend;
            #endif
            return 0;
         }

         // no trig based hash, not a great hash, but fast..
         float Hash(float3 p)
         {
             p  = frac( p*0.3183099+.1 );
             p *= 17.0;
             return frac( p.x*p.y*p.z*(p.x+p.y+p.z) );
         }

         float Noise( float3 x )
         {
             float3 p = floor(x);
             float3 f = frac(x);
             f = f*f*(3.0-2.0*f);
            
             return lerp(lerp(lerp( Hash(p+float3(0,0,0)), Hash(p+float3(1,0,0)),f.x), lerp( Hash(p+float3(0,1,0)), Hash(p+float3(1,1,0)),f.x),f.y),
                       lerp(lerp(Hash(p+float3(0,0,1)), Hash(p+float3(1,0,1)),f.x), lerp(Hash(p+float3(0,1,1)), Hash(p+float3(1,1,1)),f.x),f.y),f.z);
         }

         // given 4 texture choices for each projection, return texture index based on normal
         // seems like we could remove some branching here.. hmm..
         float ProjectTexture(float3 worldPos, float3 normal, half3 threshFreq, half3 top, half3 side, half3 bottom)
         {
            half d = dot(normal, float3(0, 1, 0));
            half3 cvec = side;
            if (d < threshFreq.x)
            {
               cvec = bottom;
            }
            else if (d > threshFreq.y)
            {
               cvec = top;
            }

            float n = Noise(worldPos * threshFreq.z);
            if (n < 0.333)
               return cvec.x;
            else if (n < 0.666)
               return cvec.y;
            else
               return cvec.z;
         }

         void ProceduralTexture(float3 localPos, float3 worldPos, float3 normal, float3 worldNormal, inout float4 valuesMain, inout float4 valuesSecond, half3 weights)
         {
            #if _PROJECTTEXTURE_LOCAL
            half choice = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif
            #if _PROJECTTEXTURE_WORLD
            half choice = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif

            #if _PROJECTTEXTURE2_LOCAL
            half choice2 = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif
            #if _PROJECTTEXTURE2_WORLD
            half choice2 = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif

            #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
            float blendNoise = Noise(worldPos * _ProjectTexBlendParams.x) - 0.5;
            blendNoise *= _ProjectTexBlendParams.y;
            blendNoise += 0.5;
            blendNoise = min(max(blendNoise, _ProjectTexBlendParams.z), _ProjectTexBlendParams.w);
            valuesSecond.a = saturate(blendNoise);
            #endif
         }


         // manually compute barycentric coordinates
         float3 Barycentric(float2 p, float2 a, float2 b, float2 c)
         {
             float2 v0 = b - a;
             float2 v1 = c - a;
             float2 v2 = p - a;
             float d00 = dot(v0, v0);
             float d01 = dot(v0, v1);
             float d11 = dot(v1, v1);
             float d20 = dot(v2, v0);
             float d21 = dot(v2, v1);
             float denom = d00 * d11 - d01 * d01;
             float v = (d11 * d20 - d01 * d21) / denom;
             float w = (d00 * d21 - d01 * d20) / denom;
             float u = 1.0f - v - w;
             return float3(u, v, w);
         }

         // given two height values (from textures) and a height value for the current pixel (from vertex)
         // compute the blend factor between the two with a small blending area between them.
         half HeightBlend(half h1, half h2, half slope, half contrast)
         {
            h2 = 1 - h2;
            half tween = saturate((slope - min(h1, h2)) / max(abs(h1 - h2), 0.001)); 
            half blend = saturate( ( tween - (1-contrast) ) / max(contrast, 0.001));
            #if _LINEARBIAS
            blend = lerp(slope, blend, contrast);
            #endif
            return blend;
         }

         void BlendSpec(inout MegaSplatLayer base, MegaSplatLayer macro, half r, float3 albedo)
         {
            base.Metallic = lerp(base.Metallic, macro.Metallic, r);
            base.Smoothness = lerp(base.Smoothness, macro.Smoothness, r);
            base.Emission = albedo * lerp(base.Emission, macro.Emission, r);
         }

         half3 BlendOverlay(half3 base, half3 blend) { return (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))); }
         half3 BlendMult2X(half3  base, half3 blend) { return (base * (blend * 2)); }


         MegaSplatLayer SampleDetail(half3 weights, float3 viewDir, inout LayerParams params, half3 tpw)
         {
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.ga *= params.normalStrength.x;
               norm1.ga *= params.normalStrength.y;
               norm2.ga *= params.normalStrength.z;
               #endif
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif

            SAMPLESPEC(o, params);

            o.Emission = albedo.rgb * specFinal.z;
            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            return o;
         }


         float SampleLayerHeight(half3 biWeights, float3 viewDir, inout LayerParams params, half3 tpw, float lod, float contrast)
         { 
            #if _TESSDISTANCE || _TESSEDGE
            half4 tex0, tex1, tex2;

            SAMPLETEXARRAYLOD(tex0, tex1, tex2, _Diffuse, params, lod);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, contrast);
            params.weights = weights;
            return (tex0.a * params.displacementScale.x * weights.x + 
                    tex1.a * params.displacementScale.y * weights.y + 
                    tex2.a * params.displacementScale.z * weights.z);
            #endif
            return 0.5;
         }

         #if _TESSDISTANCE || _TESSEDGE
         float4 MegaSplatDistanceBasedTess (float d0, float d1, float d2, float tess)
         {
            float3 f;
            f.x = clamp(d0, 0.01, 1.0) * tess;
            f.y = clamp(d1, 0.01, 1.0) * tess;
            f.z = clamp(d2, 0.01, 1.0) * tess;

            return UnityCalcTriEdgeTessFactors (f);
         }
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         half3 GetWaterNormal(float2 uv, float2 flowDir)
         {
            float2 uv1;
            float2 uv2;
            half interp;
            Flow(uv, flowDir, _PuddleFlowParams.y, _PuddleFlowParams.z, uv1, uv2, interp);

            half3 fd = lerp(tex2D(_PuddleNormal, uv1), tex2D(_PuddleNormal, uv2), interp).xyz;
            fd.xy = fd.xy * 2 - 1;
            return fd;
         }
         #endif

         MegaSplatLayer SampleLayer(inout LayerParams params, SplatInput si)
         { 
            half3 biWeights = si.weights;
            float3 viewDir = si.viewDir;
            half3 tpw = si.triplanarBlend;

            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
            params.weights = weights;
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
                  params.uv1.xy += refractOffset;
                  params.uv2.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * biWeights.x + params.parallaxStrength.y * biWeights.y + params.parallaxStrength.z * biWeights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, viewDir);
                  params.uv0.xy += pOffset;
                  params.uv1.xy += pOffset;
                  params.uv2.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
                  weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
                  albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0, alpha1, alpha2;
            mipLevel = MipLevel(params.mipUV, _AlphaArray_TexelSize.zw);
            SAMPLETEXARRAY(alpha0, alpha1, alpha2, _AlphaArray, params, mipLevel);
            o.Alpha = alpha0.r * weights.x + alpha1.r * weights.y + alpha2.r * weights.z;
            #endif

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.xy -= 0.5; norm1.xy -= 0.5; norm2.xy -= 0.5;
               norm0.xy *= params.normalStrength.x;
               norm1.xy *= params.normalStrength.y;
               norm2.xy *= params.normalStrength.z;
               norm0.xy += 0.5; norm1.xy += 0.5; norm2.xy += 0.5;
               #endif
            
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif


            SAMPLESPEC(o, params);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            half4 emis0, emis1, emis2;
            mipLevel = MipLevel(params.mipUV, _Emissive_TexelSize.zw);
            SAMPLETEXARRAY(emis0, emis1, emis2, _Emissive, params, mipLevel);
            half4 emis = emis0 * weights.x + emis1 * weights.y + emis2 * weights.z;
            o.Emission = emis.rgb;
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _EMISMAP
            o.Metallic = emis.a;
            #endif

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x * params.weights.x + params.aoStrength.y * params.weights.y + params.aoStrength.z * params.weights.z;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif
            return o;
         }

         half4 SampleSpecNoBlend(LayerParams params, in half4 norm, out half3 Normal)
         {
            half4 specFinal = half4(0,0,0,1);
            Normal = half3(0,0,1);
            specFinal.x = params.metallic.x;
            specFinal.y = params.smoothness.x;

            #if _NOSPECTEX
               Normal = UnpackNormal(norm); 
            #else
               specFinal.yw = norm.zw;
               specFinal.x = params.metallic.x;
               norm.xy *= 2;
               norm.xy -= 1;
               Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy))));
            #endif

            return specFinal;
         }

         MegaSplatLayer SampleLayerNoBlend(inout LayerParams params, SplatInput si)
         { 
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0;
            half4 norm0 = half4(0,0,1,1);

            tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
            fixed4 albedo = tex0;


             #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT
  

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * si.weights.x + params.parallaxStrength.y * si.weights.y + params.parallaxStrength.z * si.weights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, si.viewDir);
                  params.uv0.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0 = UNITY_SAMPLE_TEX2DARRAY(_AlphaArray, params.uv0); 
            o.Alpha = alpha0.r;
            #endif


            #if !_NOSPECNORMAL
            norm0 = UNITY_SAMPLE_TEX2DARRAY(_Normal, params.uv0); 
               #if _PERTEXNORMALSTRENGTH
               norm0.xy *= params.normalStrength.x;
               #endif
            #endif

            half4 specFinal = SampleSpecNoBlend(params, norm0, o.Normal);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            o.Emission = UNITY_SAMPLE_TEX2DARRAY(_Emissive, params.uv0).rgb; 
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif

            return o;
         }

         MegaSplatLayer BlendResults(MegaSplatLayer a, MegaSplatLayer b, half r)
         {
            a.Height = lerp(a.Height, b.Height, r);
            a.Albedo = lerp(a.Albedo, b.Albedo, r);
            #if !_NOSPECNORMAL
            a.Normal = lerp(a.Normal, b.Normal, r);
            #endif
            a.Metallic = lerp(a.Metallic, b.Metallic, r);
            a.Smoothness = lerp(a.Smoothness, b.Smoothness, r);
            a.Occlusion = lerp(a.Occlusion, b.Occlusion, r);
            a.Emission = lerp(a.Emission, b.Emission, r);
            #if _ALPHA || _ALPHATEST
            a.Alpha = lerp(a.Alpha, b.Alpha, r);
            #endif
            return a;
         }

         MegaSplatLayer OverlayResults(MegaSplatLayer splats, MegaSplatLayer macro, half r)
         {
            #if !_SPLATSONTOP
            r = 1 - r;
            #endif

            #if _ALPHA || _ALPHATEST
            splats.Alpha = min(macro.Alpha, splats.Alpha);
            #endif

            #if _MACROMULT2X
               splats.Albedo = lerp(BlendMult2X(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROOVERLAY
               splats.Albedo = lerp(BlendOverlay(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROMULT
               splats.Albedo = lerp(splats.Albedo * macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #else
               splats.Albedo = lerp(macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(macro.Normal, splats.Normal, r); 
               #endif
               splats.Occlusion = lerp(macro.Occlusion, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #endif

            return splats;
         }

         MegaSplatLayer BlendDetail(MegaSplatLayer splats, MegaSplatLayer detail, float detailBlend)
         {
            #if _DETAILMAP
            detailBlend *= _DetailTextureStrength;
            #endif
            #if _DETAILMULT2X
               splats.Albedo = lerp(detail.Albedo, BlendMult2X(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILOVERLAY
               splats.Albedo = lerp(detail.Albedo, BlendOverlay(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILMULT
               splats.Albedo = lerp(detail.Albedo, splats.Albedo * detail.Albedo, detailBlend);
            #else
               splats.Albedo = lerp(detail.Albedo, splats.Albedo, detailBlend);
            #endif 

            #if !_NOSPECNORMAL
            splats.Normal = lerp(splats.Normal, BlendNormals(splats.Normal, detail.Normal), detailBlend);
            #endif
            return splats;
         }

         float DoSnowDisplace(float splat_height, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);

            float height = splat_height * _SnowParams.x;
            float erosion = lerp(0, height, _SnowParams.y);
            float snowMask = saturate((snowFade - erosion));
            float snowMask2 = saturate((snowFade - erosion) * 8);
            snowMask *= snowMask * snowMask * snowMask * snowMask * snowMask2;
            snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));

            return snowAmount;
            #endif
            return 0;
         }

         float DoSnow(inout MegaSplatLayer o, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight, half surfPorosity, float camDist)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            #if _SNOWDISTANCERESAMPLE
            float2 snowResampleUV = uv * _SnowDistanceResampleScaleStrengthFade.x;

            if (camDist > _SnowDistanceResampleScaleStrengthFade.z)
               {
                  half4 snowAlb2 = tex2D(_SnowDiff, snowResampleUV);
                  half4 snowNsao2 = tex2D(_SnowNormal, snowResampleUV);
                  float fade = saturate ((camDist - _SnowDistanceResampleScaleStrengthFade.z) / _SnowDistanceResampleScaleStrengthFade.w);
                  fade *= _SnowDistanceResampleScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb, snowAlb2, fade);
                  snowNsao = lerp(snowNsao, snowNsao2, fade);
               }
            #endif

            #if _SNOWDISTANCENOISE
               float2 snowNoiseUV = uv * _SnowDistanceNoiseScaleStrengthFade.x;
               if (camDist > _SnowDistanceNoiseScaleStrengthFade.z)
               {
                  half4 noise = tex2D(_SnowDistanceNoise, uv * _SnowDistanceNoiseScaleStrengthFade.x);
                  float fade = saturate ((camDist - _SnowDistanceNoiseScaleStrengthFade.z) / _SnowDistanceNoiseScaleStrengthFade.w);
                  fade *= _SnowDistanceNoiseScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb.rgb, BlendMult2X(snowAlb.rgb, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  snowNsao.xy += ((noise.xy-0.25) * fade);
                  #endif
               }
            #endif



            half3 snowNormal = half3(snowNsao.xy * 2 - 1, 1);
            snowNormal.z = sqrt(1 - saturate(dot(snowNormal.xy, snowNormal.xy)));

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);
            float ao = o.Occlusion;
            if (snowFade > 0)
            {
               float height = o.Height * _SnowParams.x;
               float erosion = lerp(1-ao, (height + ao) * 0.5, _SnowParams.y);
               float snowMask = saturate((snowFade - erosion) * 8);
               snowMask *= snowMask * snowMask * snowMask;
               snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));  // up
               wetnessMask = saturate((_SnowParams.w * (4.0 * snowFade) - (height + snowNsao.b) * 0.5));
               snowAmount = saturate(snowAmount * 8);
               snowNormalAmount = snowAmount * snowAmount;

               float porosity = saturate((((1.0 - o.Smoothness) - 0.5)) / max(surfPorosity, 0.001));
               float factor = lerp(1, 0.4, porosity);

               o.Albedo *= lerp(1.0, factor, wetnessMask);
               o.Normal = lerp(o.Normal, float3(0,0,1), wetnessMask);
               o.Smoothness = lerp(o.Smoothness, 0.8, wetnessMask);

            }
            o.Albedo = lerp(o.Albedo, snowAlb.rgb, snowAmount);
            o.Normal = lerp(o.Normal, snowNormal, snowNormalAmount);
            o.Smoothness = lerp(o.Smoothness, (snowNsao.b) * _SnowParams.z, snowAmount);
            o.Occlusion = lerp(o.Occlusion, snowNsao.w, snowAmount);
            o.Height = lerp(o.Height, snowAlb.a, snowAmount);
            o.Metallic = lerp(o.Metallic, 0.01, snowAmount);
            float crystals = saturate(0.65 - snowNsao.b);
            o.Smoothness = lerp(o.Smoothness, crystals * _SnowParams.z, snowAmount);
            return snowAmount;
            #endif
            return 0;
         }

         half4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten)
         {
            return half4(s.Albedo, 1);
         }

         #if _RAMPLIGHTING
         half3 DoLightingRamp(half3 albedo, float3 normal, float3 emission, half3 lightDir, half atten)
         {
            half NdotL = dot (normal, lightDir);
            half diff = NdotL * 0.5 + 0.5;
            half3 ramp = tex2D (_Ramp, diff.xx).rgb;
            return (albedo * _LightColor0.rgb * ramp * atten) + emission;
         }

         half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) 
         {
            half4 c;
            c.rgb = DoLightingRamp(s.Albedo, s.Normal, s.Emission, lightDir, atten);
            c.a = s.Alpha;
            return c;
         }
         #endif

         void ApplyDetailNoise(inout half3 albedo, inout half3 norm, inout half smoothness, in LayerParams data, float camDist, float3 tpw)
         {
            #if _DETAILNOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv1_y.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv2_z.xy * _DetailNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DetailNoiseScaleStrengthFade.x;
               #endif


               if (camDist < _DetailNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DetailNoise, uv0) * tpw.x + 
                     tex2D(_DetailNoise, uv1) * tpw.y + 
                     tex2D(_DetailNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DetailNoise, uv).rgb;
                  #endif

                  float fade = 1.0 - ((_DetailNoiseScaleStrengthFade.z - camDist) / _DetailNoiseScaleStrengthFade.z);
                  fade = 1.0 - (fade*fade);
                  fade *= _DetailNoiseScaleStrengthFade.y;

                  #if _PERTEXNOISESTRENGTH
                  fade *= (data.detailNoiseStrength.x * data.weights.x + data.detailNoiseStrength.y * data.weights.y + data.detailNoiseStrength.z * data.weights.z);
                  #endif

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }

            }
            #endif // detail normal

            #if _DISTANCENOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv0_y.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv1_z.xy * _DistanceNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DistanceNoiseScaleStrengthFade.x;
               #endif


               if (camDist > _DistanceNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DistanceNoise, uv0) * tpw.x + 
                     tex2D(_DistanceNoise, uv1) * tpw.y + 
                     tex2D(_DistanceNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DistanceNoise, uv).rgb;
                  #endif

                  float fade = saturate ((camDist - _DistanceNoiseScaleStrengthFade.z) / _DistanceNoiseScaleStrengthFade.w);
                  fade *= _DistanceNoiseScaleStrengthFade.y;

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }
            }
            #endif
         }

         void DoGlitter(inout MegaSplatLayer splats, half shine, half reflectAmt, float3 wsNormal, float3 wsView, float2 uv)
         {
            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            half3 lightDir = normalize(_WorldSpaceLightPos0);

            half3 viewDir = normalize(wsView);
            half NdotL = saturate(dot(splats.Normal, lightDir));
            lightDir = reflect(lightDir, splats.Normal);
            half specular = saturate(abs(dot(lightDir, viewDir)));


            //float2 offset = float2(viewDir.z, wsNormal.x) + splats.Normal.xy * 0.1;
            float2 offset = splats.Normal * 0.1;
            offset = fmod(offset, 1.0);

            half detail = tex2D(_GlitterTexture, uv * _GlitterParams.xy + offset).x;

            #if _GLITTERMOVES
               float2 uv0 = uv * _GlitterParams.w + _Time.y * _GlitterParams.z;
               float2 uv1 = uv * _GlitterParams.w + _Time.y  * 1.04 * -_GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               half detail3 = tex2D(_GlitterTexture, uv1).y;
               detail *= sqrt(detail2 * detail3);
            #else
               float2 uv0 = uv * _GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               detail *= detail2;
            #endif
            detail *= saturate(splats.Height + 0.5);

            specular = pow(specular, shine) * floor(detail * reflectAmt);

            splats.Smoothness += specular;
            splats.Smoothness = min(splats.Smoothness, 1);
            #endif
         }


         LayerParams InitLayerParams(SplatInput si, float3 values, half2 texScale)
         {
            LayerParams data = NewLayerParams();
            #if _TERRAIN
            int i0 = round(values.x * 255);
            int i1 = round(values.y * 255);
            int i2 = round(values.z * 255);
            #else
            int i0 = round(values.x / max(si.weights.x, 0.00001));
            int i1 = round(values.y / max(si.weights.y, 0.00001));
            int i2 = round(values.z / max(si.weights.z, 0.00001));
            #endif

            #if _TRIPLANAR
            float3 coords = si.triplanarUVW * texScale.x;
            data.tpuv0_x = float3(coords.zy, i0);
            data.tpuv0_y = float3(coords.xz, i0);
            data.tpuv0_z = float3(coords.xy, i0);
            data.tpuv1_x = float3(coords.zy, i1);
            data.tpuv1_y = float3(coords.xz, i1);
            data.tpuv1_z = float3(coords.xy, i1);
            data.tpuv2_x = float3(coords.zy, i2);
            data.tpuv2_y = float3(coords.xz, i2);
            data.tpuv2_z = float3(coords.xy, i2);
            data.mipUV = coords.xz;

            float2 splatUV = si.splatUV * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);

            #else
            float2 splatUV = si.splatUV.xy * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);
            data.mipUV = splatUV.xy;
            #endif



            #if _FLOW || _FLOWREFRACTION
            data.flowOn = 0;
            #endif

            #if _DISTANCERESAMPLE
            InitDistanceResample(data, si.camDist.y);
            #endif

            return data;
         }

         MegaSplatLayer DoSurf(inout SplatInput si, MegaSplatLayer macro, float3x3 tangentToWorld)
         {
            #if _ALPHALAYER
            LayerParams mData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.xy);
            #else
            LayerParams mData = InitLayerParams(si, si.valuesMain.xyz, _TexScales.xy);
            #endif

            #if _ALPHAHOLE
            if (mData.uv0.z == _AlphaHoleIdx || mData.uv1.z == _AlphaHoleIdx || mData.uv2.z == _AlphaHoleIdx)
            {
               clip(-1);
            } 
            #endif

            #if _PARALLAX && (_TESSEDGE || _TESSDISTANCE || _LOWPOLY || _ALPHATEST)
            si.viewDir = mul(si.viewDir, tangentToWorld);
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT
            float2 puddleUV = si.macroUV * _PuddleUVScales.xy;
            #elif _PUDDLES
            float2 puddleUV = 0;
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT

            si.waterNormalFoam = float3(0,0,0);
            if (si.puddleHeight > 0 && si.camDist.y < 40)
            {
               float str = 1.0 - ((si.camDist.y - 20) / 20);
               si.waterNormalFoam = GetWaterNormal(puddleUV, si.flowDir) * str;
            }
            #endif

            SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

            #if _FLOWREFRACTION
            // see through
            //sampleBottom = sampleBottom || mData.flowOn > 0;
            #endif

            half porosity = _GlobalPorosityWetness.x;
            #if _PERTEXMATPARAMS
            porosity = mData.porosity.x * mData.weights.x + mData.porosity.y * mData.weights.y + mData.porosity.z * mData.weights.z;
            #endif

            #if _TWOLAYER
               LayerParams sData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.zw);

               #if _ALPHAHOLE
               if (sData.uv0.z == _AlphaHoleIdx || sData.uv1.z == _AlphaHoleIdx || sData.uv2.z == _AlphaHoleIdx)
               {
                  clip(-1);
               } 
               #endif

               sData.layerBlend = si.layerBlend;
               SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(sData.uv0, si.flowDir, _FlowSpeed * sData.flowIntensity.x, _FlowIntensity, sData.fuv0a, sData.fuv0b, sData.flowInterps.x);
                  Flow(sData.uv1, si.flowDir, _FlowSpeed * sData.flowIntensity.y, _FlowIntensity, sData.fuv1a, sData.fuv1b, sData.flowInterps.y);
                  Flow(sData.uv2, si.flowDir, _FlowSpeed * sData.flowIntensity.z, _FlowIntensity, sData.fuv2a, sData.fuv2b, sData.flowInterps.z);
                  mData.flowOn = 0;
               #endif

               MegaSplatLayer second = SampleLayer(sData, si);

               #if _FLOWREFRACTION
                  float hMod = FlowRefract(second, mData, sData, si.weights);
               #endif
            #else // _TWOLAYER

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(mData.uv0, si.flowDir, _FlowSpeed * mData.flowIntensity.x, _FlowIntensity, mData.fuv0a, mData.fuv0b, mData.flowInterps.x);
                  Flow(mData.uv1, si.flowDir, _FlowSpeed * mData.flowIntensity.y, _FlowIntensity, mData.fuv1a, mData.fuv1b, mData.flowInterps.y);
                  Flow(mData.uv2, si.flowDir, _FlowSpeed * mData.flowIntensity.z, _FlowIntensity, mData.fuv2a, mData.fuv2b, mData.flowInterps.z);
               #endif
            #endif

            #if _NOBLENDBOTTOM
               MegaSplatLayer splats = SampleLayerNoBlend(mData, si);
            #else
               MegaSplatLayer splats = SampleLayer(mData, si);
            #endif

            #if _TWOLAYER
               // blend layers together..
               float hfac = HeightBlend(splats.Height, second.Height, sData.layerBlend, _Contrast);
               #if _FLOWREFRACTION
                  hfac *= hMod;
               #endif
               splats = BlendResults(splats, second, hfac);
               porosity = lerp(porosity, 
                     sData.porosity.x * sData.weights.x + 
                     sData.porosity.y * sData.weights.y + 
                     sData.porosity.z * sData.weights.z,
                     hfac);
            #endif

            #if _GEOMAP
            float2 geoUV = float2(0, si.worldPos.y * _GeoParams.y + _GeoParams.z);
            half4 geoTex = tex2D(_GeoTex, geoUV);
            splats.Albedo = lerp(splats.Albedo, BlendMult2X(splats.Albedo, geoTex), _GeoParams.x * geoTex.a);
            #endif

            half macroBlend = 1;
            #if _USEMACROTEXTURE
            macroBlend = saturate(_MacroTextureStrength * si.camDist.x);
            #endif

            #if _DETAILMAP
               float dist = si.camDist.y;
               if (dist > _DistanceFades.w)
               {
                  MegaSplatLayer o = (MegaSplatLayer)0;
                  UNITY_INITIALIZE_OUTPUT(MegaSplatLayer,o);
                  #if _USEMACROTEXTURE
                  splats = OverlayResults(splats, macro, macroBlend);
                  #endif
                  o.Albedo = splats.Albedo;
                  o.Normal = splats.Normal;
                  o.Emission = splats.Emission;
                  o.Occlusion = splats.Occlusion;
                  #if !_RAMPLIGHTING
                  o.Metallic = splats.Metallic;
                  o.Smoothness = splats.Smoothness;
                  #endif
                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_Final(si, o);
                  #endif
                  return o;
               }

               LayerParams sData = InitLayerParams(si, si.valuesMain, _TexScales.zw);
               MegaSplatLayer second = SampleDetail(mData.weights, si.viewDir, sData, si.triplanarBlend);   // use prev weights for detail

               float detailBlend = 1.0 - saturate((dist - _DistanceFades.z) / (_DistanceFades.w - _DistanceFades.z));
               splats = BlendDetail(splats, second, detailBlend); 
            #endif

            ApplyDetailNoise(splats.Albedo, splats.Normal, splats.Smoothness, mData, si.camDist.y, si.triplanarBlend);

            float3 worldNormal = float3(0,0,1);
            #if _SNOW || _RAINDROPFLATONLY
            worldNormal = mul(tangentToWorld, normalize(splats.Normal));
            #endif

            #if _SNOWGLITTER || _PERTEXGLITTER || _PUDDLEGLITTER
            half glitterShine = 0;
            half glitterReflect = 0;
            #endif

            #if _PERTEXGLITTER
            glitterReflect = mData.perTexGlitterReflect.x * mData.weights.x + mData.perTexGlitterReflect.y * mData.weights.y + mData.perTexGlitterReflect.z * mData.weights.z;
               #if _TWOLAYER || _ALPHALAYER
               float glitterReflect2 = sData.perTexGlitterReflect.x * sData.weights.x + sData.perTexGlitterReflect.y * sData.weights.y + sData.perTexGlitterReflect.z * sData.weights.z;
               glitterReflect = lerp(glitterReflect, glitterReflect2, hfac);
               #endif
            glitterReflect *= 14;
            glitterShine = 1.5;
            #endif


            float pud = 0;
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
               if (si.puddleHeight > 0)
               {
                  pud = DoPuddles(splats, puddleUV, si.waterNormalFoam, si.puddleHeight, si.flowDir, porosity, worldNormal);
               }
            #endif

            #if _LAVA
               float2 lavaUV = si.macroUV * _LavaUVScale.xy;


               if (si.puddleHeight > 0)
               {
                  pud = DoLava(splats, lavaUV, si.puddleHeight, si.flowDir);
               }
            #endif

            #if _PUDDLEGLITTER
            glitterShine = lerp(glitterShine, _GlitterSurfaces.z, pud);
            glitterReflect = lerp(glitterReflect, _GlitterSurfaces.w, pud);
            #endif


            #if _SNOW && !_SNOWOVERMACRO
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOW && _SNOWOVERMACRO
            half preserveAO = splats.Occlusion;
            #endif

            #if _WETNESS
            WaterBRDF(splats.Albedo, splats.Smoothness, splats.Metallic, max( si.wetness, _GlobalPorosityWetness.y) * _MaxWetness, porosity); 
            #endif


            #if _ALPHALAYER
            half blend = HeightBlend(splats.Height, 1 - macro.Height, si.layerBlend * macroBlend, _Contrast);
            splats = OverlayResults(splats, macro, blend);
            #elif _USEMACROTEXTURE
            splats = OverlayResults(splats, macro, macroBlend);
            #endif

            #if _SNOW && _SNOWOVERMACRO
               splats.Occlusion = preserveAO;
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            DoGlitter(splats, glitterShine, glitterReflect, si.wsNormal, si.wsView, si.macroUV);
            #endif

            #if _CUSTOMUSERFUNCTION
            CustomMegaSplatFunction_Final(si, splats);
            #endif

            return splats;
         }

         #if _DEBUG_OUTPUT_SPLATDATA
         float3 DebugSplatOutput(SplatInput si)
         {
            float3 data = float3(0,0,0);
            int i0 = round(si.valuesMain.x / max(si.weights.x, 0.00001));
            int i1 = round(si.valuesMain.y / max(si.weights.y, 0.00001));
            int i2 = round(si.valuesMain.z / max(si.weights.z, 0.00001));

            #if _TWOLAYER || _ALPHALAYER
            int i3 = round(si.valuesSecond.x / max(si.weights.x, 0.00001));
            int i4 = round(si.valuesSecond.y / max(si.weights.y, 0.00001));
            int i5 = round(si.valuesSecond.z / max(si.weights.z, 0.00001));
            data.z = si.layerBlend;
            #endif

            if (si.weights.x > si.weights.y && si.weights.x > si.weights.z)
            {
               data.x = i0 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i3 / 255.0;
               #endif
            }
            else if (si.weights.y > si.weights.x && si.weights.y > si.weights.z)
            {
               data.x = i1 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i4 / 255.0;
               #endif
            }
            else
            {
               data.x = i2 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i5 / 255.0;
               #endif
            }
            return data;
         }
         #endif

 
            UnityLight AdditiveLight (half3 normalWorld, half3 lightDir, half atten)
            {
               UnityLight l;

               l.color = _LightColor0.rgb;
               l.dir = lightDir;
               #ifndef USING_DIRECTIONAL_LIGHT
                  l.dir = normalize(l.dir);
               #endif
               l.ndotl = LambertTerm (normalWorld, l.dir);

               // shadow the light
               l.color *= atten;
               return l;
            }

            UnityLight MainLight (half3 normalWorld)
            {
               UnityLight l;
               #ifdef LIGHTMAP_OFF
                  
                  l.color = _LightColor0.rgb;
                  l.dir = _WorldSpaceLightPos0.xyz;
                  l.ndotl = LambertTerm (normalWorld, l.dir);
               #else
                  // no light specified by the engine
                  // analytical light might be extracted from Lightmap data later on in the shader depending on the Lightmap type
                  l.color = half3(0.f, 0.f, 0.f);
                  l.ndotl  = 0.f;
                  l.dir = half3(0.f, 0.f, 0.f);
               #endif

               return l;
            }

            inline half4 VertexGIForward(float2 uv1, float2 uv2, float3 posWorld, half3 normalWorld)
            {
               half4 ambientOrLightmapUV = 0;
               // Static lightmaps
               #ifdef LIGHTMAP_ON
                  ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                  ambientOrLightmapUV.zw = 0;
               // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
               #elif UNITY_SHOULD_SAMPLE_SH
                  #ifdef VERTEXLIGHT_ON
                     // Approximated illumination from non-important point lights
                     ambientOrLightmapUV.rgb = Shade4PointLights (
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, posWorld, normalWorld);
                  #endif

                  ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);     
               #endif

               #ifdef DYNAMICLIGHTMAP_ON
                  ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
               #endif

               return ambientOrLightmapUV;
            }

            void LightPBRDeferred(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic,
                           half occlusion, half alpha, float3 viewDir,
                           inout half3 indirectDiffuse, inout half3 indirectSpecular, inout half3 diffuseColor, inout half3 specularColor)
            {
               #if _PASSDEFERRED
               half lightAtten = 1;
               half roughness = 1 - smoothness;

               UnityLight light = MainLight (normalDirection);

               UnityGIInput d;
               UNITY_INITIALIZE_OUTPUT(UnityGIInput, d);
               d.light = light;
               d.worldPos = i.posWorld.xyz;
               d.worldViewDir = viewDir;
               d.atten = lightAtten;
               #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                  d.ambient = 0;
                  d.lightmapUV = i.ambientOrLightmapUV;
               #else
                  d.ambient = i.ambientOrLightmapUV.rgb;
                  d.lightmapUV = 0;
               #endif
               d.boxMax[0] = unity_SpecCube0_BoxMax;
               d.boxMin[0] = unity_SpecCube0_BoxMin;
               d.probePosition[0] = unity_SpecCube0_ProbePosition;
               d.probeHDR[0] = unity_SpecCube0_HDR;
               d.boxMax[1] = unity_SpecCube1_BoxMax;
               d.boxMin[1] = unity_SpecCube1_BoxMin;
               d.probePosition[1] = unity_SpecCube1_ProbePosition;
               d.probeHDR[1] = unity_SpecCube1_HDR;

               UnityGI gi = UnityGlobalIllumination(d, occlusion, 1.0 - smoothness, normalDirection );

               specularColor = metallic.xxx;
               float specularMonochrome;
               diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, specularMonochrome );

               indirectSpecular = (gi.indirect.specular);
               float NdotV = max(0.0,dot( normalDirection, viewDir ));
               specularMonochrome = 1.0-specularMonochrome;
               half grazingTerm = saturate( smoothness + specularMonochrome );
               indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
               indirectDiffuse = half3(0,0,0);
               indirectDiffuse += gi.indirect.diffuse;
               indirectDiffuse *= occlusion;

               #endif
            }


            half4 LightPBR(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic, 
                            half occlusion, half alpha, float3 viewDir, float4 ambientOrLightmapUV)
            {
                

                #if _PASSFORWARDBASE
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG(i.fogCoord, ramped);
                   return ramped;
                }
                #endif

                UnityLight light = MainLight (normalDirection);

                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDir;
                d.atten = lightAtten;
                #if LIGHTMAP_ON || DYNAMICLIGHTMAP_ON
                    d.ambient = 0;
                    d.lightmapUV = i.ambientOrLightmapUV;
                #else
                    d.ambient = i.ambientOrLightmapUV;
                    d.lightmapUV = 0;
                #endif

                d.boxMax[0] = unity_SpecCube0_BoxMax;
                d.boxMin[0] = unity_SpecCube0_BoxMin;
                d.probePosition[0] = unity_SpecCube0_ProbePosition;
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.boxMax[1] = unity_SpecCube1_BoxMax;
                d.boxMin[1] = unity_SpecCube1_BoxMin;
                d.probePosition[1] = unity_SpecCube1_ProbePosition;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = roughness;
                ugls_en_data.reflUVW = reflect( -viewDir, normalDirection );
                UnityGI gi = UnityGlobalIllumination(d, occlusion, normalDirection, ugls_en_data );

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, oneMinusReflectivity );
                

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, gi.light, gi.indirect);
                c.rgb += UNITY_BRDF_GI (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, occlusion, gi);
                c.rgb += emission;
                c.a = alpha;
                UNITY_APPLY_FOG(i.fogCoord, c.rgb);
                return c;

                #elif _PASSFORWARDADD
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG_COLOR(i.fogCoord, ramped.rgb, half4(0,0,0,0));
                   return ramped;
                }
                #endif

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, oneMinusReflectivity );

                UnityLight light = AdditiveLight (normalDirection, normalDirection, lightAtten);
                UnityIndirect noIndirect = (UnityIndirect)0;
                noIndirect.diffuse = 0;
                noIndirect.specular = 0;

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, light, noIndirect);
   
                UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
                c.a = alpha;
                return c;

                #endif
                return half4(1, 1, 0, 0);
            }

            float4 _SplatControl_TexelSize;

            struct VertexInput 
            {
                float4 vertex        : POSITION;
                float3 normal        : NORMAL;
                float2 texcoord0     : TEXCOORD0;
                #if !_PASSSHADOWCASTER && !_PASSMETA
                    float2 texcoord1 : TEXCOORD1;
                    float2 texcoord2 : TEXCOORD2;
                #endif
            };

            VirtualMapping GetMapping(VertexOutput i, sampler2D splatControl, sampler2D paramControl)
            {
               float2 texSize = _SplatControl_TexelSize.zw;
               float2 stp = _SplatControl_TexelSize.xy;
               // scale coords so we can take floor/frac to construct a cell
               float2 stepped = i.coords.xy * texSize;
               float2 uvBottom = floor(stepped);
               float2 uvFrac = frac(stepped);
               uvBottom /= texSize;

               float2 center = stp * 0.5;
               uvBottom += center;

               // construct uv/positions of triangle based on our interpolation point
               float2 cuv0, cuv1, cuv2;
               // make virtual triangle
               if (uvFrac.x > uvFrac.y)
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(stp.x, 0);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }
               else
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(0, stp.y);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }

               float2 uvBaryFrac = uvFrac * stp + uvBottom;
               float3 weights = Barycentric(uvBaryFrac, cuv0, cuv1, cuv2);
               VirtualMapping m = (VirtualMapping)0;
               m.weights = weights;
               m.c0 = tex2Dlod(splatControl, float4(cuv0, 0, 0));
               m.c1 = tex2Dlod(splatControl, float4(cuv1, 0, 0));
               m.c2 = tex2Dlod(splatControl, float4(cuv2, 0, 0));

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS || _FLOW || _FLOWREFRACTION || _LAVA
               fixed4 p0 = tex2Dlod(paramControl, float4(cuv0, 0, 0));
               fixed4 p1 = tex2Dlod(paramControl, float4(cuv1, 0, 0));
               fixed4 p2 = tex2Dlod(paramControl, float4(cuv2, 0, 0));
               m.param = p0 * weights.x + p1 * weights.y + p2 * weights.z;
               #endif
               return m;
            }

            SplatInput ToSplatInput(VertexOutput i, VirtualMapping m)
            {
               SplatInput o = (SplatInput)0;
               UNITY_INITIALIZE_OUTPUT(SplatInput,o);

               o.camDist = i.camDist;
               o.splatUV = i.coords;
               o.macroUV = i.coords;
               #if _SECONDUV
               o.macroUV = i.macroUV;
               #endif
               o.weights = m.weights;


               o.valuesMain = float3(m.c0.r, m.c1.r, m.c2.r);
               #if _TWOLAYER || _ALPHALAYER
               o.valuesSecond = float3(m.c0.g, m.c1.g, m.c2.g);
               o.layerBlend = m.c0.b * o.weights.x + m.c1.b * o.weights.y + m.c2.b * o.weights.z;
               #endif

               #if _TRIPLANAR
               o.triplanarUVW = i.triplanarUVW;
               o.triplanarBlend = i.extraData.xyz;
               #endif

               #if _FLOW || _FLOWREFRACTION || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.flowDir = m.param.xy;
               #endif

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.puddleHeight = m.param.a;
               #endif

               #if _WETNESS
               o.wetness = m.param.b;
               #endif

               #if _GEOMAP
               o.worldPos = i.posWorld;
               #endif

               return o;
            }

            LayerParams GetMainParams(VertexOutput i, inout VirtualMapping m, half2 texScale)
            {
               
               int i0 = (int)(m.c0.r * 255);
               int i1 = (int)(m.c1.r * 255);
               int i2 = (int)(m.c2.r * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               data.layerBlend = m.weights.x * m.c0.b + m.weights.y * m.c1.b + m.weights.z * m.c2.b;

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;
            }

            LayerParams GetSecondParams(VertexOutput i, VirtualMapping m, half2 texScale)
            {
               int i0 = (int)(m.c0.g * 255);
               int i1 = (int)(m.c1.g * 255);
               int i2 = (int)(m.c2.g * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;   
            }


            VertexOutput NoTessVert(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;

               o.tangent.xyz = cross(v.normal, float3(0,0,1));
               float4 tangent = float4(o.tangent, 1);
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(o.tangent, 1);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  o.tangent = tangent.xyz;
                  #endif
               }

               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(o.tangent, 1);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  o.tangent = tangent.xyz;
                  #endif
               }

               UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

               o.normal = UnityObjectToWorldNormal(v.normal);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

               o.coords.xy = v.texcoord0;
               #if _SECONDUV
               o.macroUV = v.texcoord0;
               o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
               #endif

               o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);


               #if !_PASSSHADOWCASTER && !_PASSMETA
               o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
               #endif

               float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
               o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
               float3 viewSpace = UnityObjectToViewPos(v.vertex);
               o.camDist.y = length(viewSpace.xyz);
               #if _TRIPLANAR
                  float3 norm = v.normal;
                  #if _TRIPLANAR_WORLDSPACE
                  o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                  norm = normalize(mul(unity_ObjectToWorld, norm));
                  #else
                  o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                  #endif
                  o.extraData.xyz = pow(abs(norm), _TriplanarContrast);
               #endif


               o.bitangent = normalize(cross(o.normal, o.tangent) * -1);  
               

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #elif !_PASSMETA && !_PASSDEFERRED
               UNITY_TRANSFER_FOG(o,o.pos);
               TRANSFER_VERTEX_TO_FRAGMENT(o)
               #endif
               return o;
            }


            #if _TESSDISTANCE || _TESSEDGE
            VertexOutput NoTessShadowVertBiased(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(0,0,0,0);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  #endif
               }
               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(0,0,0,0);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  #endif
                  UNITY_INITIALIZE_OUTPUT(VertexOutput,o);
               }
             
               o.normal = UnityObjectToWorldNormal(v.normal);
               v.vertex.xyz -= o.normal * _TessData1.yyy * half3(0.5, 0.5, 0.5);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.coords = v.texcoord0;

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #endif

               return o;
            }
            #endif

            #ifdef UNITY_CAN_COMPILE_TESSELLATION
            #if _TESSDISTANCE || _TESSEDGE 
            struct TessVertex 
            {
                 float4 vertex       : INTERNALTESSPOS;
                 float3 normal       : NORMAL;
                 float2 coords       : TEXCOORD0;      // uv, or triplanar UV
                 #if _TRIPLANAR
                 float3 triplanarUVW : TEXCOORD1;
                 float4 extraData    : TEXCOORD2;
                 #endif
                 float4 camDist      : TEXCOORD3;      // distance from camera (for fades) and fog

                 float3 posWorld     : TEXCOORD4;
                 float4 tangent      : TEXCOORD5;
                 float2 macroUV      : TEDCOORD6;
                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    LIGHTING_COORDS(7,8)
                    UNITY_FOG_COORDS(9)
                 #endif
                 float4 ambientOrLightmapUV : TEXCOORD10;
 
             };


            VertexOutput vert (TessVertex v) 
            {
                VertexOutput o = (VertexOutput)0;

                UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

                #if _CUSTOMUSERFUNCTION
                CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, v.tangent, v.coords.xy);
                #endif
                #if _USECURVEDWORLD
                V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                #endif

                o.ambientOrLightmapUV = v.ambientOrLightmapUV;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangent = normalize(cross(o.normal, o.tangent) * v.tangent.w);  
                o.pos = UnityObjectToClipPos(v.vertex);
                o.coords = v.coords;
                o.camDist = v.camDist;
                o.posWorld = v.posWorld;
                #if _SECONDUV
                o.macroUV = v.macroUV;
                #endif

                #if _TRIPLANAR
                o.triplanarUVW = v.triplanarUVW;
                o.extraData = v.extraData;
                #endif

                #if _PASSSHADOWCASTER
                TRANSFER_SHADOW_CASTER(o)
                #elif !_PASSMETA && !_PASSDEFERRED
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                #endif

                return o;
            }


                
             struct OutputPatchConstant {
                 float edge[3]         : SV_TessFactor;
                 float inside          : SV_InsideTessFactor;
                 float3 vTangent[4]    : TANGENT;
                 float2 vUV[4]         : TEXCOORD;
                 float3 vTanUCorner[4] : TANUCORNER;
                 float3 vTanVCorner[4] : TANVCORNER;
                 float4 vCWts          : TANWEIGHTS;
             };

             TessVertex tessvert (VertexInput v) 
             {
                 TessVertex o;
                 UNITY_INITIALIZE_OUTPUT(TessVertex,o);
                 #if _USECURVEDWORLD
                 V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                 #endif

                 o.vertex = v.vertex;
                 o.normal = v.normal;
                 o.coords.xy = v.texcoord0;
                 o.normal = UnityObjectToWorldNormal(v.normal);
                 o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

                 float4 tangent = float4(o.tangent.xyz, 1);
                 #if _SECONDUV
                 o.macroUV = v.texcoord0;
                 o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
                 #endif

                 o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);



                 #if !_PASSSHADOWCASTER && !_PASSMETA
                 o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
                 #endif

                 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
                 o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
                 float3 viewSpace = UnityObjectToViewPos(v.vertex);
                 o.camDist.y = length(viewSpace.xyz);
                 #if _TRIPLANAR
                    #if _TRIPLANAR_WORLDSPACE
                    o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #else
                    o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #endif
                    o.extraData.xyz = pow(abs(v.normal), _TriplanarContrast);
                 #endif

                 o.tangent.xyz = cross(v.normal, float3(0,0,1));
                 o.tangent.w = -1;

                 float tessFade = saturate((dist - _TessData2.x) / (_TessData2.y - _TessData2.x));
                 tessFade *= tessFade;
                 o.camDist.w = 1 - tessFade;

                 return o;
             }

             void displacement (inout TessVertex i)
             {
                  VertexOutput o = vert(i);
                  float3 viewDir = float3(0,0,1);

                  VirtualMapping mapping = GetMapping(o, _SplatControl, _SplatParams);
                  LayerParams mData = GetMainParams(o, mapping, _TexScales.xy);
                  SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

                  half3 extraData = float3(0,0,0);
                  #if _TRIPLANAR
                  extraData = o.extraData.xyz;
                  #endif

                  #if _TWOLAYER || _DETAILMAP
                  LayerParams sData = GetSecondParams(o, mapping, _TexScales.zw);
                  sData.layerBlend = mData.layerBlend;
                  SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);
                  float second = SampleLayerHeight(mapping.weights, viewDir, sData, extraData.xyz, _TessData1.z, _TessData2.z);
                  #endif

                  float splats = SampleLayerHeight(mapping.weights, viewDir, mData, extraData.xyz, _TessData1.z, _TessData2.z);

                  #if _TWOLAYER
                     // blend layers together..
                     float hfac = HeightBlend(splats, second, sData.layerBlend, _TessData2.z);
                     splats = lerp(splats, second, hfac);
                  #endif

                  half upBias = _TessData2.w;
                  #if _PERTEXDISPLACEPARAMS
                  float3 upBias3 = mData.upBias;
                     #if _TWOLAYER
                        upBias3 = lerp(upBias3, sData.upBias, hfac);
                     #endif
                  upBias = upBias3.x * mapping.weights.x + upBias3.y * mapping.weights.y + upBias3.z * mapping.weights.z;
                  #endif

                  #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
                     #if _PUDDLESPUSHTERRAIN
                     splats = max(splats - mapping.param.a, 0);
                     #else
                     splats = max(splats, mapping.param.a);
                     #endif
                  #endif

                  #if _TESSCENTERBIAS
                  splats -= 0.5;
                  #endif

                  #if _SNOW
                  float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                  float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                  float snowHeightFade = saturate((worldPos.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
                  splats += DoSnowDisplace(splats, i.coords.xy, worldNormal, snowHeightFade, mapping.param.a);
                  #endif

                  float3 offset = (lerp(i.normal, float3(0,1,0), upBias) * (i.camDist.w * _TessData1.y * splats));

                  #if _TESSDAMPENING
                  offset *= (mapping.c0.a * mapping.weights.x + mapping.c1.a * mapping.weights.y + mapping.c2.a * mapping.weights.z);
                  #endif

                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_PostDisplacement(i.vertex.xyz, offset, i.normal, i.tangent, i.coords.xy);
                  #else
                  i.vertex.xyz += offset;
                  #endif

             }

             #if _TESSEDGE
             float4 Tessellation(TessVertex v, TessVertex v1, TessVertex v2)
             {
                 return UnityEdgeLengthBasedTess(v.vertex, v1.vertex, v2.vertex, _TessData1.w);
             }
             #elif _TESSDISTANCE
             float4 Tessellation (TessVertex v0, TessVertex v1, TessVertex v2) 
             {
                return MegaSplatDistanceBasedTess( v0.camDist.w, v1.camDist.w, v2.camDist.w, _TessData1.x );
             }
             #endif

             OutputPatchConstant hullconst (InputPatch<TessVertex,3> v) {
                 OutputPatchConstant o = (OutputPatchConstant)0;
                 float4 ts = Tessellation( v[0], v[1], v[2] );
                 o.edge[0] = ts.x;
                 o.edge[1] = ts.y;
                 o.edge[2] = ts.z;
                 o.inside = ts.w;
                 return o;
             }
             [UNITY_domain("tri")]
             [UNITY_partitioning("fractional_odd")]
             [UNITY_outputtopology("triangle_cw")]
             [UNITY_patchconstantfunc("hullconst")]
             [UNITY_outputcontrolpoints(3)]
             TessVertex hull (InputPatch<TessVertex,3> v, uint id : SV_OutputControlPointID) 
             {
                 return v[id];
             }

             [UNITY_domain("tri")]
             VertexOutput domain (OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> vi, float3 bary : SV_DomainLocation) 
             {
                 TessVertex v = (TessVertex)0;
                 v.vertex =         vi[0].vertex * bary.x +       vi[1].vertex * bary.y +       vi[2].vertex * bary.z;
                 v.normal =         vi[0].normal * bary.x +       vi[1].normal * bary.y +       vi[2].normal * bary.z;
                 v.coords =         vi[0].coords * bary.x +       vi[1].coords * bary.y +       vi[2].coords * bary.z;
                 v.camDist =        vi[0].camDist * bary.x +      vi[1].camDist * bary.y +      vi[2].camDist * bary.z;
                 #if _TRIPLANAR
                 v.extraData =      vi[0].extraData * bary.x +    vi[1].extraData * bary.y +    vi[2].extraData * bary.z;
                 v.triplanarUVW =   vi[0].triplanarUVW * bary.x + vi[1].triplanarUVW * bary.y + vi[2].triplanarUVW * bary.z; 
                 #endif
                 v.tangent =        vi[0].tangent * bary.x +      vi[1].tangent * bary.y +      vi[2].tangent * bary.z;
                 v.macroUV =        vi[0].macroUV * bary.x +      vi[1].macroUV * bary.y +      vi[2].macroUV * bary.z;
                 v.posWorld =       vi[0].posWorld * bary.x +     vi[1].posWorld * bary.y +     vi[2].posWorld * bary.z;

                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    #if FOG_LINEAR || FOG_EXP || FOG_EXP2
                       v.fogCoord = vi[0].fogCoord * bary.x + vi[1].fogCoord * bary.y + vi[2].fogCoord * bary.z;
                    #endif
                    #if  SPOT || POINT_COOKIE || DIRECTIONAL_COOKIE 
                       v._LightCoord = vi[0]._LightCoord * bary.x + vi[1]._LightCoord * bary.y + vi[2]._LightCoord * bary.z; 
                       #if (SHADOWS_DEPTH && SPOT) || SHADOWS_CUBE || SHADOWS_DEPTH
                          v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y * vi[2]._ShadowCoord * bary.z; 
                       #endif
                    #elif DIRECTIONAL && (SHADOWS_CUBE || SHADOWS_DEPTH)
                       v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y + vi[2]._ShadowCoord * bary.z; 
                    #endif
                 #endif
                 v.ambientOrLightmapUV = vi[0].ambientOrLightmapUV * bary.x + vi[1].ambientOrLightmapUV * bary.y + vi[2].ambientOrLightmapUV * bary.z;

                 #if _TESSPHONG
                 float3 p = v.vertex.xyz;

                 // Calculate deltas to project onto three tangent planes
                 float3 p0 = dot(vi[0].vertex.xyz - p, vi[0].normal) * vi[0].normal;
                 float3 p1 = dot(vi[1].vertex.xyz - p, vi[1].normal) * vi[1].normal;
                 float3 p2 = dot(vi[2].vertex.xyz - p, vi[2].normal) * vi[2].normal;

                 // Lerp between projection vectors
                 float3 vecOffset = bary.x * p0 + bary.y * p1 + bary.z * p2;

                 // Add a fraction of the offset vector to the lerped position
                 p += 0.5 * vecOffset;

                 v.vertex.xyz = p;
                 #endif

                 displacement(v);
                 VertexOutput o = vert(v);
                 return o;
             }
            #endif
            #endif

            struct LightingTerms
            {
               half3 Albedo;
               half3 Normal;
               half  Smoothness;
               half  Metallic;
               half  Occlusion;
               half3 Emission;
               #if _ALPHA || _ALPHATEST
               half Alpha;
               #endif
            };

            void Splat(VertexOutput i, inout LightingTerms o, float3 viewDir, float3x3 tangentTransform)
            {
               VirtualMapping mapping = GetMapping(i, _SplatControl, _SplatParams);
               SplatInput si = ToSplatInput(i, mapping);
               si.viewDir = viewDir;
               #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
               si.wsView = viewDir;
               #endif

               MegaSplatLayer macro = (MegaSplatLayer)0;
               #if _SNOW
               float snowHeightFade = saturate((i.posWorld.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
               #endif

               #if _USEMACROTEXTURE || _ALPHALAYER
                  float2 muv = i.coords.xy;

                  #if _SECONDUV
                  muv = i.macroUV.xy;
                  #endif
                  macro = SampleMacro(muv);
                  #if _SNOW && _SNOWOVERMACRO

                  DoSnow(macro, muv, mul(tangentTransform, normalize(macro.Normal)), snowHeightFade, 0, _GlobalPorosityWetness.x, i.camDist.y);
                  #endif

                  #if _DISABLESPLATSINDISTANCE
                  if (i.camDist.x <= 0.0)
                  {
                     #if _CUSTOMUSERFUNCTION
                     CustomMegaSplatFunction_Final(si, macro);
                     #endif
                     o.Albedo = macro.Albedo;
                     o.Normal = macro.Normal;
                     o.Emission = macro.Emission;
                     #if !_RAMPLIGHTING
                     o.Smoothness = macro.Smoothness;
                     o.Metallic = macro.Metallic;
                     o.Occlusion = macro.Occlusion;
                     #endif
                     #if _ALPHA || _ALPHATEST
                     o.Alpha = macro.Alpha;
                     #endif

                     return;
                  }
                  #endif
               #endif

               #if _SNOW
               si.snowHeightFade = snowHeightFade;
               #endif

               MegaSplatLayer splats = DoSurf(si, macro, tangentTransform);

               #if _DEBUG_OUTPUT_ALBEDO
               o.Albedo = splats.Albedo;
               #elif _DEBUG_OUTPUT_HEIGHT
               o.Albedo = splats.Height.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_NORMAL
               o.Albedo = splats.Normal * 0.5 + 0.5 * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SMOOTHNESS
               o.Albedo = splats.Smoothness.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_METAL
               o.Albedo = splats.Metallic.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_AO
               o.Albedo = splats.Occlusion.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_EMISSION
               o.Albedo = splats.Emission * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SPLATDATA
               o.Albedo = DebugSplatOutput(si);
               #else
               o.Albedo = splats.Albedo;
               o.Normal = splats.Normal;
               o.Metallic = splats.Metallic;
               o.Smoothness = splats.Smoothness;
               o.Occlusion = splats.Occlusion;
               o.Emission = splats.Emission;
                  
               #endif

               #if _ALPHA || _ALPHATEST
                  o.Alpha = splats.Alpha;
               #endif
            }



            #if _PASSMETA
            half4 frag(VertexOutput i) : SV_Target 
            {
                i.normal = normalize(i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normal;
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );

                LightingTerms lt = (LightingTerms)0;

                float3x3 tangentTransform = (float3x3)0;
                #if _SNOW
                tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                #endif

                Splat(i, lt, viewDirection, tangentTransform);

                o.Emission = lt.Emission;
                
                float3 diffColor = lt.Albedo;
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, lt.Metallic, specColor, specularMonochrome );
                float roughness = 1.0 - lt.Smoothness;
                o.Albedo = diffColor + specColor * roughness * roughness * 0.5;
                return UnityMetaFragment( o );

            }
            #elif _PASSSHADOWCASTER
            half4 frag(VertexOutput i) : COLOR
            {
               SHADOW_CASTER_FRAGMENT(i)
            }
            #elif _PASSDEFERRED
            void frag(
                VertexOutput i,
                out half4 outDiffuse : SV_Target0,
                out half4 outSpecSmoothness : SV_Target1,
                out half4 outNormal : SV_Target2,
                out half4 outEmission : SV_Target3 )
            {
                i.normal = normalize(i.normal);
                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;
                Splat(i, o, viewDirection, tangentTransform);
                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif
                float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                
                half3 specularColor;
                half3 diffuseColor;
                half3 indirectDiffuse;
                half3 indirectSpecular;
                LightPBRDeferred(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, 
                  indirectDiffuse, indirectSpecular, diffuseColor, specularColor);
                
                outSpecSmoothness = half4(specularColor, o.Smoothness);
                outEmission = half4( o.Emission, 1 );
                outEmission.rgb += indirectSpecular * o.Occlusion;
                outEmission.rgb += indirectDiffuse * diffuseColor;
                #ifndef UNITY_HDR_ON
                    outEmission.rgb = exp2(-outEmission.rgb);
                #endif
                outDiffuse = half4(diffuseColor, o.Occlusion);
                outNormal = half4( normalDirection * 0.5 + 0.5, 1 );



            }
            #else
            half4 frag(VertexOutput i) : COLOR 
            {

                i.normal = normalize(i.normal);

                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;

                Splat(i, o, viewDirection, tangentTransform);

                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif

                #if _DEBUG_OUTPUT_ALBEDO || _DEBUG_OUTPUT_HEIGHT || _DEBUG_OUTPUT_NORMAL || _DEBUG_OUTPUT_SMOOTHNESS || _DEBUG_OUTPUT_METAL || _DEBUG_OUTPUT_AO || _DEBUG_OUTPUT_EMISSION
                   return half4(o.Albedo,1);
                #else
                   float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                   half4 lit = LightPBR(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, i.ambientOrLightmapUV);
                   #if _ALPHA || _ALPHATEST
                   lit.a = o.Alpha;
                   #endif
                   return lit;
                #endif

            }
            #endif


            #if _LOWPOLY
            [maxvertexcount(3)]
            void geom(triangle VertexOutput input[3], inout TriangleStream<VertexOutput> s)
            {
               VertexOutput v0 = input[0];
               VertexOutput v1 = input[1];
               VertexOutput v2 = input[2];

               float3 norm = input[0].normal + input[1].normal + input[2].normal;
               norm /= 3;
               float3 tangent = input[0].tangent + input[1].tangent + input[2].tangent;
               tangent /= 3;
              
               float3 bitangent = input[0].bitangent + input[1].bitangent + input[2].bitangent;
               bitangent /= 3;

               #if _LOWPOLYADJUST
               v0.normal = lerp(v0.normal, norm, _EdgeHardness);
               v1.normal = lerp(v1.normal, norm, _EdgeHardness);
               v2.normal = lerp(v2.normal, norm, _EdgeHardness);
              
               v0.tangent = lerp(v0.tangent, tangent, _EdgeHardness);
               v1.tangent = lerp(v1.tangent, tangent, _EdgeHardness);
               v2.tangent = lerp(v2.tangent, tangent, _EdgeHardness);
              
               v0.bitangent = lerp(v0.bitangent, bitangent, _EdgeHardness);;
               v1.bitangent = lerp(v1.bitangent, bitangent, _EdgeHardness);;
               v2.bitangent = lerp(v2.bitangent, bitangent, _EdgeHardness);;
               #else
               v0.normal = norm;
               v1.normal = norm;
               v2.normal = norm;
              
               v0.tangent = tangent;
               v1.tangent = tangent;
               v2.tangent = tangent;
              
               v0.bitangent = bitangent;
               v1.bitangent = bitangent;
               v2.bitangent = bitangent;
               #endif


               s.Append(v0);
               s.Append(v1);
               s.Append(v2);
            }
            #endif
            ENDCG
        }


         Pass 
         {
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            Offset 1, 1
            
            CGPROGRAM
            #define UNITY_PASS_SHADOWCASTER
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            //#include "UnityMetaPass.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc" // could remove
            #include "Tessellation.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma target 4.6
            #define _PASSSHADOWCASTER 1

         #pragma vertex NoTessShadowVertBiased
         #pragma fragment frag

      #define _NORMALMAP 1
      #define _PERTEXAOSTRENGTH 1
      #define _PERTEXCONTRAST 1
      #define _PERTEXDISPLACEPARAMS 1
      #define _PERTEXGLITTER 1
      #define _PERTEXMATPARAMS 1
      #define _PERTEXNORMALSTRENGTH 1
      #define _PERTEXUV 1
      #define _PUDDLEGLITTER 1
      #define _PUDDLES 1
      #define _PUDDLESPUSHTERRAIN 1
      #define _TERRAIN 1
      #define _TESSCENTERBIAS 1
      #define _TESSDAMPENING 1
      #define _TESSDISTANCE 1
      #define _TESSFALLBACK 1
      #define _TWOLAYER 1
      #define _WETNESS 1



         struct MegaSplatLayer
         {
            half3 Albedo;
            half3 Normal;
            half3 Emission;
            half  Metallic;
            half  Smoothness;
            half  Occlusion;
            half  Height;
            half  Alpha;
         };

         struct SplatInput
         {
            float3 weights;
            float2 splatUV;
            float2 macroUV;
            float3 valuesMain;
            half3 viewDir;
            float4 camDist;

            #if _TWOLAYER || _ALPHALAYER
            float3 valuesSecond;
            half layerBlend;
            #endif

            #if _TRIPLANAR
            float3 triplanarUVW;
            #endif
            half3 triplanarBlend; // passed to func, so always present

            #if _FLOW || _FLOWREFRACTION || _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half2 flowDir;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half puddleHeight;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            float3 waterNormalFoam;
            #endif

            #if _WETNESS
            half wetness;
            #endif

            #if _TESSDAMPENING
            half displacementDampening;
            #endif

            #if _SNOW
            half snowHeightFade;
            #endif

            #if _SNOW || _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsNormal;
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsView;
            #endif

            #if _GEOMAP
            float3 worldPos;
            #endif
         };


         struct LayerParams
         {
            float3 uv0, uv1, uv2;
            float2 mipUV; // uv for mip selection
            #if _TRIPLANAR
            float3 tpuv0_x, tpuv0_y, tpuv0_z;
            float3 tpuv1_x, tpuv1_y, tpuv1_z;
            float3 tpuv2_x, tpuv2_y, tpuv2_z;
            #endif
            #if _FLOW || _FLOWREFRACTION
            float3 fuv0a, fuv0b;
            float3 fuv1a, fuv1b;
            float3 fuv2a, fuv2b;
            #endif

            #if _DISTANCERESAMPLE
               half distanceBlend;
               float3 db_uv0, db_uv1, db_uv2;
               #if _TRIPLANAR
               float3 db_tpuv0_x, db_tpuv0_y, db_tpuv0_z;
               float3 db_tpuv1_x, db_tpuv1_y, db_tpuv1_z;
               float3 db_tpuv2_x, db_tpuv2_y, db_tpuv2_z;
               #endif
            #endif

            half layerBlend;
            half3 metallic;
            half3 smoothness;
            half3 porosity;
            #if _FLOW || _FLOWREFRACTION
            half3 flowIntensity;
            half flowOn;
            half3 flowAlphas;
            half3 flowRefracts;
            half3 flowInterps;
            #endif
            half3 weights;

            #if _TESSDISTANCE || _TESSEDGE
            half3 displacementScale;
            half3 upBias;
            #endif

            #if _PERTEXNOISESTRENGTH
            half3 detailNoiseStrength;
            #endif

            #if _PERTEXNORMALSTRENGTH
            half3 normalStrength;
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            half3 parallaxStrength;
            #endif

            #if _PERTEXAOSTRENGTH
            half3 aoStrength;
            #endif

            #if _PERTEXGLITTER
            half3 perTexGlitterReflect;
            #endif

            half3 contrast;
         };

         struct VirtualMapping
         {
            float3 weights;
            fixed4 c0, c1, c2;
            fixed4 param;
         };



         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"

         // splat
         UNITY_DECLARE_TEX2DARRAY(_Diffuse);
         float4 _Diffuse_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_Normal);
         float4 _Normal_TexelSize;
         #if _EMISMAP
         UNITY_DECLARE_TEX2DARRAY(_Emissive);
         float4 _Emissive_TexelSize;
         #endif
         #if _DETAILMAP
         UNITY_DECLARE_TEX2DARRAY(_DetailAlbedo);
         float4 _DetailAlbedo_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_DetailNormal);
         float4 _DetailNormal_TexelSize;
         half _DetailTextureStrength;
         #endif

         #if _ALPHA || _ALPHATEST
         UNITY_DECLARE_TEX2DARRAY(_AlphaArray);
         float4 _AlphaArray_TexelSize;
         #endif

         #if _LOWPOLY
         half _EdgeHardness;
         #endif

         #if _TERRAIN
         sampler2D _SplatControl;
         sampler2D _SplatParams;
         #endif

         #if _ALPHAHOLE
         int _AlphaHoleIdx;
         #endif

         #if _RAMPLIGHTING
         sampler2D _Ramp;
         #endif

         #if _UVLOCALTOP || _UVWORLDTOP || _UVLOCALFRONT || _UVWORLDFRONT || _UVLOCALSIDE || _UVWORLDSIDE
         float4 _UVProjectOffsetScale;
         #endif
         #if _UVLOCALTOP2 || _UVWORLDTOP2 || _UVLOCALFRONT2 || _UVWORLDFRONT2 || _UVLOCALSIDE2 || _UVWORLDSIDE2
         float4 _UVProjectOffsetScale2;
         #endif

         half _Contrast;

         #if _ALPHALAYER || _USEMACROTEXTURE
         // macro texturing
         sampler2D _MacroDiff;
         sampler2D _MacroBump;
         sampler2D _MetallicGlossMap;
         sampler2D _MacroAlpha;
         half2 _MacroTexScale;
         half _MacroTextureStrength;
         half2 _MacroTexNormAOScales;
         #endif

         // default spec
         half _Glossiness;
         half _Metallic;

         #if _DISTANCERESAMPLE
         float3  _ResampleDistanceParams;
         #endif

         #if _FLOW || _FLOWREFRACTION
         // flow
         half _FlowSpeed;
         half _FlowAlpha;
         half _FlowIntensity;
         half _FlowRefraction;
         #endif

         half2 _PerTexScaleRange;
         sampler2D _PropertyTex;

         // etc
         half2 _Parallax;
         half4 _TexScales;

         float4 _DistanceFades;
         float4 _DistanceFadesCached;
         int _ControlSize;

         #if _TRIPLANAR
         half _TriplanarTexScale;
         half _TriplanarContrast;
         float3 _TriplanarOffset;
         #endif

         #if _GEOMAP
         sampler2D _GeoTex;
         float3 _GeoParams;
         #endif

         #if _PROJECTTEXTURE_LOCAL || _PROJECTTEXTURE_WORLD
         half3 _ProjectTexTop;
         half3 _ProjectTexSide;
         half3 _ProjectTexBottom;
         half3 _ProjectTexThresholdFreq;
         #endif

         #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
         half3 _ProjectTexTop2;
         half3 _ProjectTexSide2;
         half3 _ProjectTexBottom2;
         half3 _ProjectTexThresholdFreq2;
         half4 _ProjectTexBlendParams;
         #endif

         #if _TESSDISTANCE || _TESSEDGE
         float4 _TessData1; // distance tessellation, displacement, edgelength
         float4 _TessData2; // min, max
         #endif

         #if _DETAILNOISE
         sampler2D _DetailNoise;
         half3 _DetailNoiseScaleStrengthFade;
         #endif

         #if _DISTANCENOISE
         sampler2D _DistanceNoise;
         half4 _DistanceNoiseScaleStrengthFade;
         #endif

         #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
         half3 _PuddleTint;
         half _PuddleBlend;
         half _MaxPuddles;
         half4 _PuddleFlowParams;
         half2 _PuddleNormalFoam;
         #endif

         #if _RAINDROPS
         sampler2D _RainDropTexture;
         half _RainIntensity;
         float2 _RainUVScales;
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         float2 _PuddleUVScales;
         sampler2D _PuddleNormal;
         #endif

         #if _LAVA
         sampler2D _LavaDiffuse;
         sampler2D _LavaNormal;
         half4 _LavaParams;
         half4 _LavaParams2;
         half3 _LavaEdgeColor;
         half3 _LavaColorLow;
         half3 _LavaColorHighlight;
         float2 _LavaUVScale;
         #endif

         #if _WETNESS
         half _MaxWetness;
         #endif

         half2 _GlobalPorosityWetness;

         #if _SNOW
         sampler2D _SnowDiff;
         sampler2D _SnowNormal;
         half4 _SnowParams; // influence, erosion, crystal, melt
         half _SnowAmount;
         half2 _SnowUVScales;
         half2 _SnowHeightRange;
         half3 _SnowUpVector;
         #endif

         #if _SNOWDISTANCENOISE
         sampler2D _SnowDistanceNoise;
         float4 _SnowDistanceNoiseScaleStrengthFade;
         #endif

         #if _SNOWDISTANCERESAMPLE
         float4 _SnowDistanceResampleScaleStrengthFade;
         #endif

         #if _PERTEXGLITTER || _SNOWGLITTER || _PUDDLEGLITTER
         sampler2D _GlitterTexture;
         half4 _GlitterParams;
         half4 _GlitterSurfaces;
         #endif


         struct VertexOutput 
         {
             float4 pos          : SV_POSITION;
             #if !_TERRAIN
             fixed3 weights      : TEXCOORD0;
             float4 valuesMain   : TEXCOORD1;      //index rgb, triplanar W
                #if _TWOLAYER || _ALPHALAYER
                float4 valuesSecond : TEXCOORD2;      //index rgb + alpha
                #endif
             #elif _TRIPLANAR
             float3 triplanarUVW : TEXCOORD3;
             #endif
             float2 coords       : TEXCOORD4;      // uv, or triplanar UV
             float3 posWorld     : TEXCOORD5;
             float3 normal       : TEXCOORD6;

             float4 camDist      : TEXCOORD7;      // distance from camera (for fades) and fog
             float4 extraData    : TEXCOORD8;      // flowdir + fades, or if triplanar triplanarView + detailFade
             float3 tangent      : TEXCOORD9;
             float3 bitangent    : TEXCOORD10;
             float4 ambientOrLightmapUV : TEXCOORD14;


             #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
             LIGHTING_COORDS(11,12)
             UNITY_FOG_COORDS(13)
             #endif

             #if _PASSSHADOWCASTER
             float3 vec : TEXCOORD11;  // nice naming, Unity...
             #endif

             #if _WETNESS
             half wetness : TEXCOORD15;   //wetness
             #endif

             #if _SECONDUV
             float3 macroUV : TEXCOORD16;
             #endif

         };

         void OffsetUVs(inout LayerParams p, float2 offset)
         {
            p.uv0.xy += offset;
            p.uv1.xy += offset;
            p.uv2.xy += offset;
            #if _TRIPLANAR
            p.tpuv0_x.xy += offset;
            p.tpuv0_y.xy += offset;
            p.tpuv0_z.xy += offset;
            p.tpuv1_x.xy += offset;
            p.tpuv1_y.xy += offset;
            p.tpuv1_z.xy += offset;
            p.tpuv2_x.xy += offset;
            p.tpuv2_y.xy += offset;
            p.tpuv2_z.xy += offset;
            #endif
         }


         void InitDistanceResample(inout LayerParams lp, float dist)
         {
            #if _DISTANCERESAMPLE
               lp.distanceBlend = saturate((dist - _ResampleDistanceParams.y) / (_ResampleDistanceParams.z - _ResampleDistanceParams.y));
               lp.db_uv0 = lp.uv0;
               lp.db_uv1 = lp.uv1;
               lp.db_uv2 = lp.uv2;

               lp.db_uv0.xy *= _ResampleDistanceParams.xx;
               lp.db_uv1.xy *= _ResampleDistanceParams.xx;
               lp.db_uv2.xy *= _ResampleDistanceParams.xx;


               #if _TRIPLANAR
               lp.db_tpuv0_x = lp.tpuv0_x;
               lp.db_tpuv1_x = lp.tpuv1_x;
               lp.db_tpuv2_x = lp.tpuv2_x;
               lp.db_tpuv0_y = lp.tpuv0_y;
               lp.db_tpuv1_y = lp.tpuv1_y;
               lp.db_tpuv2_y = lp.tpuv2_y;
               lp.db_tpuv0_z = lp.tpuv0_z;
               lp.db_tpuv1_z = lp.tpuv1_z;
               lp.db_tpuv2_z = lp.tpuv2_z;

               lp.db_tpuv0_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_z.xy *= _ResampleDistanceParams.xx;
               #endif
            #endif
         }


         LayerParams NewLayerParams()
         {
            LayerParams l = (LayerParams)0;
            l.metallic = _Metallic.xxx;
            l.smoothness = _Glossiness.xxx;
            l.porosity = _GlobalPorosityWetness.xxx;

            l.layerBlend = 0;
            #if _FLOW || _FLOWREFRACTION
            l.flowIntensity = 0;
            l.flowOn = 0;
            l.flowAlphas = half3(1,1,1);
            l.flowRefracts = half3(1,1,1);
            #endif

            #if _TESSDISTANCE || _TESSEDGE
            l.displacementScale = half3(1,1,1);
            l.upBias = half3(0,0,0);
            #endif

            #if _PERTEXNOISESTRENGTH
            l.detailNoiseStrength = half3(1,1,1);
            #endif

            #if _PERTEXNORMALSTRENGTH
            l.normalStrength = half3(1,1,1);
            #endif

            #if _PERTEXAOSTRENGTH
            l.aoStrength = half3(1,1,1);
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            l.parallaxStrength = half3(1,1,1);
            #endif

            l.contrast = _Contrast;

            return l;
         }

         half AOContrast(half ao, half scalar)
         {
            scalar += 0.5;  // 0.5 -> 1.5
            scalar *= scalar; // 0.25 -> 2.25
            return pow(ao, scalar);
         }

         half MacroAOContrast(half ao, half scalar)
         {
            #if _MACROAOSCALE
            return AOContrast(ao, scalar);
            #else
            return ao;
            #endif
         }
         #if _USEMACROTEXTURE || _ALPHALAYER
         MegaSplatLayer SampleMacro(float2 uv)
         {
             MegaSplatLayer o = (MegaSplatLayer)0;
             float2 macroUV = uv * _MacroTexScale.xy;
             half4 macAlb = tex2D(_MacroDiff, macroUV);
             o.Albedo = macAlb.rgb;
             o.Height = macAlb.a;
             // defaults
             o.Normal = half3(0,0,1);
             o.Occlusion = 1;
             o.Smoothness = _Glossiness;
             o.Metallic = _Metallic;
             o.Emission = half3(0,0,0);

             // unpack normal
             #if !_NOSPECTEX
             half4 normSample = tex2D(_MacroBump, macroUV);
             o.Normal = UnpackNormal(normSample);
             o.Normal.xy *= _MacroTexNormAOScales.x;
             #else
             o.Normal = half3(0,0,1);
             #endif


             #if _ALPHA || _ALPHATEST
             o.Alpha = tex2D(_MacroAlpha, macroUV).r;
             #endif
             return o;
         }
         #endif


         #if _NOSPECTEX
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = UnpackNormal(norm); 

         #elif _NOSPECNORMAL   
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = half3(0,0,1);

         #else
            #define SAMPLESPEC(o, params) \
              half4 spec0, spec1, spec2; \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.yw =  norm.zw; \
              specFinal.x = (params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z); \
              norm.xy *= 2; \
              norm.xy -= 1; \
              o.Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy)))); \

         #endif

         void SamplePerTex(sampler2D pt, inout LayerParams params, float2 scaleRange)
         {
            const half cent = 1.0 / 512.0;
            const half pixelStep = 1.0 / 256.0;
            const half vertStep = 1.0 / 8.0;

            // pixel layout for per tex properties
            // metal/smooth/porosity/uv scale
            // flow speed, intensity, alpha, refraction
            // detailNoiseStrength, contrast, displacementAmount, displaceUpBias

            #if _PERTEXMATPARAMS || _PERTEXUV
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, 0, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, 0, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, 0, 0, 0));
               params.porosity = half3(0.4, 0.4, 0.4);
               #if _PERTEXMATPARAMS
               params.metallic = half3(props0.r, props1.r, props2.r);
               params.smoothness = half3(props0.g, props1.g, props2.g);
               params.porosity = half3(props0.b, props1.b, props2.b);
               #endif
               #if _PERTEXUV
               float3 uvScale = float3(props0.a, props1.a, props2.a);
               uvScale = lerp(scaleRange.xxx, scaleRange.yyy, uvScale);
               params.uv0.xy *= uvScale.x;
               params.uv1.xy *= uvScale.y;
               params.uv2.xy *= uvScale.z;

                  #if _TRIPLANAR
                  params.tpuv0_x.xy *= uvScale.xx; params.tpuv0_y.xy *= uvScale.xx; params.tpuv0_z.xy *= uvScale.xx;
                  params.tpuv1_x.xy *= uvScale.yy; params.tpuv1_y.xy *= uvScale.yy; params.tpuv1_z.xy *= uvScale.yy;
                  params.tpuv2_x.xy *= uvScale.zz; params.tpuv2_y.xy *= uvScale.zz; params.tpuv2_z.xy *= uvScale.zz;
                  #endif

               #endif
            }
            #endif


            #if _FLOW || _FLOWREFRACTION
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 3, 0, 0));

               params.flowIntensity = half3(props0.r, props1.r, props2.r);
               params.flowOn = params.flowIntensity.x + params.flowIntensity.y + params.flowIntensity.z;

               params.flowAlphas = half3(props0.b, props1.b, props2.b);
               params.flowRefracts = half3(props0.a, props1.a, props2.a);
            }
            #endif

            #if _PERTEXDISPLACEPARAMS || _PERTEXCONTRAST || _PERTEXNOISESTRENGTH
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 5, 0, 0));

               #if _PERTEXDISPLACEPARAMS && (_TESSDISTANCE || _TESSEDGE)
               params.displacementScale = half3(props0.b, props1.b, props2.b);
               params.upBias = half3(props0.a, props1.a, props2.a);
               #endif

               #if _PERTEXCONTRAST
               params.contrast = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXNOISESTRENGTH
               params.detailNoiseStrength = half3(props0.r, props1.r, props2.r);
               #endif
            }
            #endif

            #if _PERTEXNORMALSTRENGTH || _PERTEXPARALLAXSTRENGTH || _PERTEXAOSTRENGTH || _PERTEXGLITTER
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 7, 0, 0));

               #if _PERTEXNORMALSTRENGTH
               params.normalStrength = half3(props0.r, props1.r, props2.r);
               #endif

               #if _PERTEXPARALLAXSTRENGTH
               params.parallaxStrength = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXAOSTRENGTH
               params.aoStrength = half3(props0.b, props1.b, props2.b);
               #endif

               #if _PERTEXGLITTER
               params.perTexGlitterReflect = half3(props0.a, props1.a, props2.a);
               #endif

            }
            #endif
         }

         float FlowRefract(MegaSplatLayer tex, inout LayerParams main, inout LayerParams second, half3 weights)
         {
            #if _FLOWREFRACTION
            float totalFlow = second.flowIntensity.x * weights.x + second.flowIntensity.y * weights.y + second.flowIntensity.z * weights.z;
            float falpha = second.flowAlphas.x * weights.x + second.flowAlphas.y * weights.y + second.flowAlphas.z * weights.z;
            float frefract = second.flowRefracts.x * weights.x + second.flowRefracts.y * weights.y + second.flowRefracts.z * weights.z;
            float refractOn = min(1, totalFlow * 10000);
            float ratio = lerp(1.0, _FlowAlpha * falpha, refractOn);
            float2 rOff = tex.Normal.xy * _FlowRefraction * frefract * ratio;
            main.uv0.xy += rOff;
            main.uv1.xy += rOff;
            main.uv2.xy += rOff;
            return ratio;
            #endif
            return 1;
         }

         float MipLevel(float2 uv, float2 textureSize)
         {
            uv *= textureSize;
            float2  dx_vtc        = ddx(uv);
            float2  dy_vtc        = ddy(uv);
            float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
            return 0.5 * log2(delta_max_sqr);
         }


         #if _DISTANCERESAMPLE
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l); \
                  { \
                     half4 st0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_z, l); \
                     half4 st1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_z, l); \
                     half4 st2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_z, l); \
                     t0 = lerp(t0, st0, lp.distanceBlend); \
                     t1 = lerp(t1, st1, lp.distanceBlend); \
                     t2 = lerp(t2, st2, lp.distanceBlend); \
                  }
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); 
               #endif
            #endif
         #else // not distance resample
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l);
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l);
               #endif
            #endif
         #endif


         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, lod);
         #else
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, lod);
         #endif

         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z + offset, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z + offset, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z + offset, lod);
         #else
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0 + offset, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1 + offset, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2 + offset, lod);
         #endif

         void Flow(float3 uv, half2 flow, half speed, float intensity, out float3 uv1, out float3 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));
            uv1.z = uv.z;
            uv2.z = uv.z;

            interp = abs(0.5 - phase.x) / 0.5;
         }

         void Flow(float2 uv, half2 flow, half speed, float intensity, out float2 uv1, out float2 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));

            interp = abs(0.5 - phase.x) / 0.5;
         }

         half3 ComputeWeights(half3 iWeights, half4 tex0, half4 tex1, half4 tex2, half contrast)
         {
             // compute weight with height map
             const half epsilon = 1.0f / 1024.0f;
             half3 weights = half3(iWeights.x * (tex0.a + epsilon), 
                                      iWeights.y * (tex1.a + epsilon),
                                      iWeights.z * (tex2.a + epsilon));

             // Contrast weights
             half maxWeight = max(weights.x, max(weights.y, weights.z));
             half transition = contrast * maxWeight;
             half threshold = maxWeight - transition;
             half scale = 1.0f / transition;
             weights = saturate((weights - threshold) * scale);
             // Normalize weights.
             half weightScale = 1.0f / (weights.x + weights.y + weights.z);
             weights *= weightScale;
             #if _LINEARBIAS
             weights = lerp(weights, iWeights, contrast);
             #endif
             return weights;
         }

         float2 ProjectUVs(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP
            return (vertex.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALSIDE
            return (vertex.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALFRONT
            return (vertex.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDTOP
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(1,0,0));
               tangent.w = worldNormal.y > 0 ? -1 : 1;
               #endif
            return (worldPos.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDFRONT
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,0,1));
               tangent.w = worldNormal.x > 0 ? 1 : -1;
               #endif
            return (worldPos.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDSIDE
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,1,0));
               tangent.w = worldNormal.z > 0 ? 1 : -1;
               #endif
            return (worldPos.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #endif
            return coords;
         }

         float2 ProjectUV2(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP2
            return (vertex.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALSIDE2
            return (vertex.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALFRONT2
            return (vertex.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDTOP2
            return (worldPos.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDFRONT2
            return (worldPos.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDSIDE2
            return (worldPos.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #endif
            return coords;
         }

         void WaterBRDF (inout half3 Albedo, inout half Smoothness, half metalness, half wetFactor, half surfPorosity) 
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS
            half porosity = saturate((( (1 - Smoothness) - 0.5)) / max(surfPorosity, 0.001));
            half factor = lerp(1, 0.2, (1 - metalness) * porosity);
            Albedo *= lerp(1.0, factor, wetFactor);
            Smoothness = lerp(1.0, Smoothness, lerp(1.0, factor, wetFactor));
            #endif
         }

         #if _RAINDROPS
         float3 ComputeRipple(float2 uv, float time, float weight)
         {
            float4 ripple = tex2D(_RainDropTexture, uv);
            ripple.yz = ripple.yz * 2 - 1;

            float dropFrac = frac(ripple.w + time);
            float timeFrac = dropFrac - 1.0 + ripple.x;
            float dropFactor = saturate(0.2f + weight * 0.8 - dropFrac);
            float finalFactor = dropFactor * ripple.x * 
                                 sin( clamp(timeFrac * 9.0f, 0.0f, 3.0f) * 3.14159265359);

            return float3(ripple.yz * finalFactor * 0.35f, 1.0f);
         }
         #endif

         // water normal only
         half2 DoPuddleRefract(float3 waterNorm, half puddleLevel, float2 flowDir, half height)
         {
            #if _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - height) * _PuddleBlend);
            waterBlend *= waterBlend;

            waterNorm.xy *= puddleLevel * waterBlend;
               #if _PUDDLEDEPTHDAMPEN
               return lerp(waterNorm.xy, waterNorm.xy * height, _PuddleFlowParams.w);
               #endif
            return waterNorm.xy;

            #endif
            return half2(0,0);
         }

         // modity lighting terms for water..
         float DoPuddles(inout MegaSplatLayer o, float2 uv, half3 waterNormFoam, half puddleLevel, half2 flowDir, half porosity, float3 worldNormal)
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - o.Height) * _PuddleBlend);

            half3 waterNorm = half3(0,0,1);
            #if _PUDDLEFLOW || _PUDDLEREFRACT

               waterNorm = half3(waterNormFoam.x, waterNormFoam.y, sqrt(1 - saturate(dot(waterNormFoam.xy, waterNormFoam.xy))));

               #if _PUDDLEFOAM
               half pmh = puddleLevel - o.Height;
               // refactor to compute flow UVs in previous step?
               float2 foamUV0;
               float2 foamUV1;
               half foamInterp;
               Flow(uv * 1.75 + waterNormFoam.xy * waterNormFoam.b, flowDir, _PuddleFlowParams.y/3, _PuddleFlowParams.z/3, foamUV0, foamUV1, foamInterp);
               half foam0 = tex2D(_PuddleNormal, foamUV0).b;
               half foam1 = tex2D(_PuddleNormal, foamUV1).b;
               half foam = lerp(foam0, foam1, foamInterp);
               foam = foam * abs(pmh) + (foam * o.Height);
               foam *= 1.0 - (saturate(pmh * 1.5));
               foam *= foam;
               foam *= _PuddleNormalFoam.y;
               #endif // foam
            #endif // flow, refract

            half3 wetAlbedo = o.Albedo * _PuddleTint * 2;
            half wetSmoothness = o.Smoothness;

            WaterBRDF(wetAlbedo, wetSmoothness, o.Metallic, waterBlend, porosity);

            #if _RAINDROPS
               float dropStrength = _RainIntensity;
               #if _RAINDROPFLATONLY
               dropStrength = saturate(dot(float3(0,1,0), worldNormal));
               #endif
               const float4 timeMul = float4(1.0f, 0.85f, 0.93f, 1.13f); 
               float4 timeAdd = float4(0.0f, 0.2f, 0.45f, 0.7f);
               float4 times = _Time.yyyy;
               times = frac((times * float4(1, 0.85, 0.93, 1.13) + float4(0, 0.2, 0.45, 0.7)) * 1.6);

               float2 ruv1 = uv * _RainUVScales.xy;
               float2 ruv2 = ruv1;

               float4 weights = _RainIntensity.xxxx - float4(0, 0.25, 0.5, 0.75);
               float3 ripple1 = ComputeRipple(ruv1 + float2( 0.25f,0.0f), times.x, weights.x);
               float3 ripple2 = ComputeRipple(ruv2 + float2(-0.55f,0.3f), times.y, weights.y);
               float3 ripple3 = ComputeRipple(ruv1 + float2(0.6f, 0.85f), times.z, weights.z);
               float3 ripple4 = ComputeRipple(ruv2 + float2(0.5f,-0.75f), times.w, weights.w);
               weights = saturate(weights * 4);

               float4 z = lerp(float4(1,1,1,1), float4(ripple1.z, ripple2.z, ripple3.z, ripple4.z), weights);
               float3 rippleNormal = float3( weights.x * ripple1.xy +
                           weights.y * ripple2.xy + 
                           weights.z * ripple3.xy + 
                           weights.w * ripple4.xy, 
                           z.x * z.y * z.z * z.w);

               waterNorm = lerp(waterNorm, normalize(rippleNormal+waterNorm), _RainIntensity * dropStrength);                         
            #endif

            #if _PUDDLEFOAM
            wetAlbedo += foam;
            wetSmoothness -= foam;
            #endif

            o.Normal = lerp(o.Normal, waterNorm, waterBlend * _PuddleNormalFoam.x);
            o.Occlusion = lerp(o.Occlusion, 1, waterBlend);
            o.Smoothness = lerp(o.Smoothness, wetSmoothness, waterBlend);
            o.Albedo = lerp(o.Albedo, wetAlbedo, waterBlend);
            return waterBlend;
            #endif
            return 0;
         }

         float DoLava(inout MegaSplatLayer o, float2 uv, half lavaLevel, half2 flowDir)
         {
            #if _LAVA

            half distortionSize = _LavaParams2.x;
            half distortionRate = _LavaParams2.y;
            half distortionScale = _LavaParams2.z;
            half darkening = _LavaParams2.w;
            half3 edgeColor = _LavaEdgeColor;
            half3 lavaColorLow = _LavaColorLow;
            half3 lavaColorHighlight = _LavaColorHighlight;


            half maxLava = _LavaParams.y;
            half lavaSpeed = _LavaParams.z;
            half lavaInterp = _LavaParams.w;

            lavaLevel *= maxLava;
            float lvh = lavaLevel - o.Height;
            float lavaBlend = saturate(lvh * _LavaParams.x);

            float2 uv1;
            float2 uv2;
            half interp;
            half drag = lerp(0.1, 1, saturate(lvh));
            Flow(uv, flowDir, lavaInterp, lavaSpeed * drag, uv1, uv2, interp);

            float2 dist_uv1;
            float2 dist_uv2;
            half dist_interp;
            Flow(uv * distortionScale, flowDir, distortionRate, distortionSize, dist_uv1, dist_uv2, dist_interp);

            half4 lavaDist = lerp(tex2D(_LavaDiffuse, dist_uv1*0.51), tex2D(_LavaDiffuse, dist_uv2), dist_interp);
            half4 dist = lavaDist * (distortionSize * 2) - distortionSize;

            half4 lavaTex = lerp(tex2D(_LavaDiffuse, uv1*1.1 + dist.xy), tex2D(_LavaDiffuse, uv2 + dist.zw), interp);

            lavaTex.xy = lavaTex.xy * 2 - 1;
            half3 lavaNorm = half3(lavaTex.xy, sqrt(1 - saturate(dot(lavaTex.xy, lavaTex.xy))));

            // base lava color, based on heights
            half3 lavaColor = lerp(lavaColorLow, lavaColorHighlight, lavaTex.b);

            // edges
            float lavaBlendWide = saturate((lavaLevel - o.Height) * _LavaParams.x * 0.5);
            float edge = saturate((1 - lavaBlendWide) * 3);

            // darkening
            darkening = saturate(lavaTex.a * darkening * saturate(lvh*2));
            lavaColor = lerp(lavaColor, lavaDist.bbb * 0.3, darkening);
            // edges
            lavaColor = lerp(lavaColor, edgeColor, edge);

            o.Albedo = lerp(o.Albedo, lavaColor, lavaBlend);
            o.Normal = lerp(o.Normal, lavaNorm, lavaBlend);
            o.Smoothness = lerp(o.Smoothness, 0.3, lavaBlend * darkening);

            half3 emis = lavaColor * lavaBlend;
            o.Emission = lerp(o.Emission, emis, lavaBlend);
            // bleed
            o.Emission += edgeColor * 0.3 * (saturate((lavaLevel*1.2 - o.Height) * _LavaParams.x) - lavaBlend);
            return lavaBlend;
            #endif
            return 0;
         }

         // no trig based hash, not a great hash, but fast..
         float Hash(float3 p)
         {
             p  = frac( p*0.3183099+.1 );
             p *= 17.0;
             return frac( p.x*p.y*p.z*(p.x+p.y+p.z) );
         }

         float Noise( float3 x )
         {
             float3 p = floor(x);
             float3 f = frac(x);
             f = f*f*(3.0-2.0*f);
            
             return lerp(lerp(lerp( Hash(p+float3(0,0,0)), Hash(p+float3(1,0,0)),f.x), lerp( Hash(p+float3(0,1,0)), Hash(p+float3(1,1,0)),f.x),f.y),
                       lerp(lerp(Hash(p+float3(0,0,1)), Hash(p+float3(1,0,1)),f.x), lerp(Hash(p+float3(0,1,1)), Hash(p+float3(1,1,1)),f.x),f.y),f.z);
         }

         // given 4 texture choices for each projection, return texture index based on normal
         // seems like we could remove some branching here.. hmm..
         float ProjectTexture(float3 worldPos, float3 normal, half3 threshFreq, half3 top, half3 side, half3 bottom)
         {
            half d = dot(normal, float3(0, 1, 0));
            half3 cvec = side;
            if (d < threshFreq.x)
            {
               cvec = bottom;
            }
            else if (d > threshFreq.y)
            {
               cvec = top;
            }

            float n = Noise(worldPos * threshFreq.z);
            if (n < 0.333)
               return cvec.x;
            else if (n < 0.666)
               return cvec.y;
            else
               return cvec.z;
         }

         void ProceduralTexture(float3 localPos, float3 worldPos, float3 normal, float3 worldNormal, inout float4 valuesMain, inout float4 valuesSecond, half3 weights)
         {
            #if _PROJECTTEXTURE_LOCAL
            half choice = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif
            #if _PROJECTTEXTURE_WORLD
            half choice = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif

            #if _PROJECTTEXTURE2_LOCAL
            half choice2 = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif
            #if _PROJECTTEXTURE2_WORLD
            half choice2 = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif

            #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
            float blendNoise = Noise(worldPos * _ProjectTexBlendParams.x) - 0.5;
            blendNoise *= _ProjectTexBlendParams.y;
            blendNoise += 0.5;
            blendNoise = min(max(blendNoise, _ProjectTexBlendParams.z), _ProjectTexBlendParams.w);
            valuesSecond.a = saturate(blendNoise);
            #endif
         }


         // manually compute barycentric coordinates
         float3 Barycentric(float2 p, float2 a, float2 b, float2 c)
         {
             float2 v0 = b - a;
             float2 v1 = c - a;
             float2 v2 = p - a;
             float d00 = dot(v0, v0);
             float d01 = dot(v0, v1);
             float d11 = dot(v1, v1);
             float d20 = dot(v2, v0);
             float d21 = dot(v2, v1);
             float denom = d00 * d11 - d01 * d01;
             float v = (d11 * d20 - d01 * d21) / denom;
             float w = (d00 * d21 - d01 * d20) / denom;
             float u = 1.0f - v - w;
             return float3(u, v, w);
         }

         // given two height values (from textures) and a height value for the current pixel (from vertex)
         // compute the blend factor between the two with a small blending area between them.
         half HeightBlend(half h1, half h2, half slope, half contrast)
         {
            h2 = 1 - h2;
            half tween = saturate((slope - min(h1, h2)) / max(abs(h1 - h2), 0.001)); 
            half blend = saturate( ( tween - (1-contrast) ) / max(contrast, 0.001));
            #if _LINEARBIAS
            blend = lerp(slope, blend, contrast);
            #endif
            return blend;
         }

         void BlendSpec(inout MegaSplatLayer base, MegaSplatLayer macro, half r, float3 albedo)
         {
            base.Metallic = lerp(base.Metallic, macro.Metallic, r);
            base.Smoothness = lerp(base.Smoothness, macro.Smoothness, r);
            base.Emission = albedo * lerp(base.Emission, macro.Emission, r);
         }

         half3 BlendOverlay(half3 base, half3 blend) { return (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))); }
         half3 BlendMult2X(half3  base, half3 blend) { return (base * (blend * 2)); }


         MegaSplatLayer SampleDetail(half3 weights, float3 viewDir, inout LayerParams params, half3 tpw)
         {
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.ga *= params.normalStrength.x;
               norm1.ga *= params.normalStrength.y;
               norm2.ga *= params.normalStrength.z;
               #endif
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif

            SAMPLESPEC(o, params);

            o.Emission = albedo.rgb * specFinal.z;
            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            return o;
         }


         float SampleLayerHeight(half3 biWeights, float3 viewDir, inout LayerParams params, half3 tpw, float lod, float contrast)
         { 
            #if _TESSDISTANCE || _TESSEDGE
            half4 tex0, tex1, tex2;

            SAMPLETEXARRAYLOD(tex0, tex1, tex2, _Diffuse, params, lod);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, contrast);
            params.weights = weights;
            return (tex0.a * params.displacementScale.x * weights.x + 
                    tex1.a * params.displacementScale.y * weights.y + 
                    tex2.a * params.displacementScale.z * weights.z);
            #endif
            return 0.5;
         }

         #if _TESSDISTANCE || _TESSEDGE
         float4 MegaSplatDistanceBasedTess (float d0, float d1, float d2, float tess)
         {
            float3 f;
            f.x = clamp(d0, 0.01, 1.0) * tess;
            f.y = clamp(d1, 0.01, 1.0) * tess;
            f.z = clamp(d2, 0.01, 1.0) * tess;

            return UnityCalcTriEdgeTessFactors (f);
         }
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         half3 GetWaterNormal(float2 uv, float2 flowDir)
         {
            float2 uv1;
            float2 uv2;
            half interp;
            Flow(uv, flowDir, _PuddleFlowParams.y, _PuddleFlowParams.z, uv1, uv2, interp);

            half3 fd = lerp(tex2D(_PuddleNormal, uv1), tex2D(_PuddleNormal, uv2), interp).xyz;
            fd.xy = fd.xy * 2 - 1;
            return fd;
         }
         #endif

         MegaSplatLayer SampleLayer(inout LayerParams params, SplatInput si)
         { 
            half3 biWeights = si.weights;
            float3 viewDir = si.viewDir;
            half3 tpw = si.triplanarBlend;

            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
            params.weights = weights;
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
                  params.uv1.xy += refractOffset;
                  params.uv2.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * biWeights.x + params.parallaxStrength.y * biWeights.y + params.parallaxStrength.z * biWeights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, viewDir);
                  params.uv0.xy += pOffset;
                  params.uv1.xy += pOffset;
                  params.uv2.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
                  weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
                  albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0, alpha1, alpha2;
            mipLevel = MipLevel(params.mipUV, _AlphaArray_TexelSize.zw);
            SAMPLETEXARRAY(alpha0, alpha1, alpha2, _AlphaArray, params, mipLevel);
            o.Alpha = alpha0.r * weights.x + alpha1.r * weights.y + alpha2.r * weights.z;
            #endif

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.xy -= 0.5; norm1.xy -= 0.5; norm2.xy -= 0.5;
               norm0.xy *= params.normalStrength.x;
               norm1.xy *= params.normalStrength.y;
               norm2.xy *= params.normalStrength.z;
               norm0.xy += 0.5; norm1.xy += 0.5; norm2.xy += 0.5;
               #endif
            
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif


            SAMPLESPEC(o, params);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            half4 emis0, emis1, emis2;
            mipLevel = MipLevel(params.mipUV, _Emissive_TexelSize.zw);
            SAMPLETEXARRAY(emis0, emis1, emis2, _Emissive, params, mipLevel);
            half4 emis = emis0 * weights.x + emis1 * weights.y + emis2 * weights.z;
            o.Emission = emis.rgb;
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _EMISMAP
            o.Metallic = emis.a;
            #endif

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x * params.weights.x + params.aoStrength.y * params.weights.y + params.aoStrength.z * params.weights.z;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif
            return o;
         }

         half4 SampleSpecNoBlend(LayerParams params, in half4 norm, out half3 Normal)
         {
            half4 specFinal = half4(0,0,0,1);
            Normal = half3(0,0,1);
            specFinal.x = params.metallic.x;
            specFinal.y = params.smoothness.x;

            #if _NOSPECTEX
               Normal = UnpackNormal(norm); 
            #else
               specFinal.yw = norm.zw;
               specFinal.x = params.metallic.x;
               norm.xy *= 2;
               norm.xy -= 1;
               Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy))));
            #endif

            return specFinal;
         }

         MegaSplatLayer SampleLayerNoBlend(inout LayerParams params, SplatInput si)
         { 
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0;
            half4 norm0 = half4(0,0,1,1);

            tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
            fixed4 albedo = tex0;


             #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT
  

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * si.weights.x + params.parallaxStrength.y * si.weights.y + params.parallaxStrength.z * si.weights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, si.viewDir);
                  params.uv0.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0 = UNITY_SAMPLE_TEX2DARRAY(_AlphaArray, params.uv0); 
            o.Alpha = alpha0.r;
            #endif


            #if !_NOSPECNORMAL
            norm0 = UNITY_SAMPLE_TEX2DARRAY(_Normal, params.uv0); 
               #if _PERTEXNORMALSTRENGTH
               norm0.xy *= params.normalStrength.x;
               #endif
            #endif

            half4 specFinal = SampleSpecNoBlend(params, norm0, o.Normal);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            o.Emission = UNITY_SAMPLE_TEX2DARRAY(_Emissive, params.uv0).rgb; 
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif

            return o;
         }

         MegaSplatLayer BlendResults(MegaSplatLayer a, MegaSplatLayer b, half r)
         {
            a.Height = lerp(a.Height, b.Height, r);
            a.Albedo = lerp(a.Albedo, b.Albedo, r);
            #if !_NOSPECNORMAL
            a.Normal = lerp(a.Normal, b.Normal, r);
            #endif
            a.Metallic = lerp(a.Metallic, b.Metallic, r);
            a.Smoothness = lerp(a.Smoothness, b.Smoothness, r);
            a.Occlusion = lerp(a.Occlusion, b.Occlusion, r);
            a.Emission = lerp(a.Emission, b.Emission, r);
            #if _ALPHA || _ALPHATEST
            a.Alpha = lerp(a.Alpha, b.Alpha, r);
            #endif
            return a;
         }

         MegaSplatLayer OverlayResults(MegaSplatLayer splats, MegaSplatLayer macro, half r)
         {
            #if !_SPLATSONTOP
            r = 1 - r;
            #endif

            #if _ALPHA || _ALPHATEST
            splats.Alpha = min(macro.Alpha, splats.Alpha);
            #endif

            #if _MACROMULT2X
               splats.Albedo = lerp(BlendMult2X(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROOVERLAY
               splats.Albedo = lerp(BlendOverlay(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROMULT
               splats.Albedo = lerp(splats.Albedo * macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #else
               splats.Albedo = lerp(macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(macro.Normal, splats.Normal, r); 
               #endif
               splats.Occlusion = lerp(macro.Occlusion, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #endif

            return splats;
         }

         MegaSplatLayer BlendDetail(MegaSplatLayer splats, MegaSplatLayer detail, float detailBlend)
         {
            #if _DETAILMAP
            detailBlend *= _DetailTextureStrength;
            #endif
            #if _DETAILMULT2X
               splats.Albedo = lerp(detail.Albedo, BlendMult2X(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILOVERLAY
               splats.Albedo = lerp(detail.Albedo, BlendOverlay(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILMULT
               splats.Albedo = lerp(detail.Albedo, splats.Albedo * detail.Albedo, detailBlend);
            #else
               splats.Albedo = lerp(detail.Albedo, splats.Albedo, detailBlend);
            #endif 

            #if !_NOSPECNORMAL
            splats.Normal = lerp(splats.Normal, BlendNormals(splats.Normal, detail.Normal), detailBlend);
            #endif
            return splats;
         }

         float DoSnowDisplace(float splat_height, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);

            float height = splat_height * _SnowParams.x;
            float erosion = lerp(0, height, _SnowParams.y);
            float snowMask = saturate((snowFade - erosion));
            float snowMask2 = saturate((snowFade - erosion) * 8);
            snowMask *= snowMask * snowMask * snowMask * snowMask * snowMask2;
            snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));

            return snowAmount;
            #endif
            return 0;
         }

         float DoSnow(inout MegaSplatLayer o, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight, half surfPorosity, float camDist)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            #if _SNOWDISTANCERESAMPLE
            float2 snowResampleUV = uv * _SnowDistanceResampleScaleStrengthFade.x;

            if (camDist > _SnowDistanceResampleScaleStrengthFade.z)
               {
                  half4 snowAlb2 = tex2D(_SnowDiff, snowResampleUV);
                  half4 snowNsao2 = tex2D(_SnowNormal, snowResampleUV);
                  float fade = saturate ((camDist - _SnowDistanceResampleScaleStrengthFade.z) / _SnowDistanceResampleScaleStrengthFade.w);
                  fade *= _SnowDistanceResampleScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb, snowAlb2, fade);
                  snowNsao = lerp(snowNsao, snowNsao2, fade);
               }
            #endif

            #if _SNOWDISTANCENOISE
               float2 snowNoiseUV = uv * _SnowDistanceNoiseScaleStrengthFade.x;
               if (camDist > _SnowDistanceNoiseScaleStrengthFade.z)
               {
                  half4 noise = tex2D(_SnowDistanceNoise, uv * _SnowDistanceNoiseScaleStrengthFade.x);
                  float fade = saturate ((camDist - _SnowDistanceNoiseScaleStrengthFade.z) / _SnowDistanceNoiseScaleStrengthFade.w);
                  fade *= _SnowDistanceNoiseScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb.rgb, BlendMult2X(snowAlb.rgb, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  snowNsao.xy += ((noise.xy-0.25) * fade);
                  #endif
               }
            #endif



            half3 snowNormal = half3(snowNsao.xy * 2 - 1, 1);
            snowNormal.z = sqrt(1 - saturate(dot(snowNormal.xy, snowNormal.xy)));

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);
            float ao = o.Occlusion;
            if (snowFade > 0)
            {
               float height = o.Height * _SnowParams.x;
               float erosion = lerp(1-ao, (height + ao) * 0.5, _SnowParams.y);
               float snowMask = saturate((snowFade - erosion) * 8);
               snowMask *= snowMask * snowMask * snowMask;
               snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));  // up
               wetnessMask = saturate((_SnowParams.w * (4.0 * snowFade) - (height + snowNsao.b) * 0.5));
               snowAmount = saturate(snowAmount * 8);
               snowNormalAmount = snowAmount * snowAmount;

               float porosity = saturate((((1.0 - o.Smoothness) - 0.5)) / max(surfPorosity, 0.001));
               float factor = lerp(1, 0.4, porosity);

               o.Albedo *= lerp(1.0, factor, wetnessMask);
               o.Normal = lerp(o.Normal, float3(0,0,1), wetnessMask);
               o.Smoothness = lerp(o.Smoothness, 0.8, wetnessMask);

            }
            o.Albedo = lerp(o.Albedo, snowAlb.rgb, snowAmount);
            o.Normal = lerp(o.Normal, snowNormal, snowNormalAmount);
            o.Smoothness = lerp(o.Smoothness, (snowNsao.b) * _SnowParams.z, snowAmount);
            o.Occlusion = lerp(o.Occlusion, snowNsao.w, snowAmount);
            o.Height = lerp(o.Height, snowAlb.a, snowAmount);
            o.Metallic = lerp(o.Metallic, 0.01, snowAmount);
            float crystals = saturate(0.65 - snowNsao.b);
            o.Smoothness = lerp(o.Smoothness, crystals * _SnowParams.z, snowAmount);
            return snowAmount;
            #endif
            return 0;
         }

         half4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten)
         {
            return half4(s.Albedo, 1);
         }

         #if _RAMPLIGHTING
         half3 DoLightingRamp(half3 albedo, float3 normal, float3 emission, half3 lightDir, half atten)
         {
            half NdotL = dot (normal, lightDir);
            half diff = NdotL * 0.5 + 0.5;
            half3 ramp = tex2D (_Ramp, diff.xx).rgb;
            return (albedo * _LightColor0.rgb * ramp * atten) + emission;
         }

         half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) 
         {
            half4 c;
            c.rgb = DoLightingRamp(s.Albedo, s.Normal, s.Emission, lightDir, atten);
            c.a = s.Alpha;
            return c;
         }
         #endif

         void ApplyDetailNoise(inout half3 albedo, inout half3 norm, inout half smoothness, in LayerParams data, float camDist, float3 tpw)
         {
            #if _DETAILNOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv1_y.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv2_z.xy * _DetailNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DetailNoiseScaleStrengthFade.x;
               #endif


               if (camDist < _DetailNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DetailNoise, uv0) * tpw.x + 
                     tex2D(_DetailNoise, uv1) * tpw.y + 
                     tex2D(_DetailNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DetailNoise, uv).rgb;
                  #endif

                  float fade = 1.0 - ((_DetailNoiseScaleStrengthFade.z - camDist) / _DetailNoiseScaleStrengthFade.z);
                  fade = 1.0 - (fade*fade);
                  fade *= _DetailNoiseScaleStrengthFade.y;

                  #if _PERTEXNOISESTRENGTH
                  fade *= (data.detailNoiseStrength.x * data.weights.x + data.detailNoiseStrength.y * data.weights.y + data.detailNoiseStrength.z * data.weights.z);
                  #endif

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }

            }
            #endif // detail normal

            #if _DISTANCENOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv0_y.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv1_z.xy * _DistanceNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DistanceNoiseScaleStrengthFade.x;
               #endif


               if (camDist > _DistanceNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DistanceNoise, uv0) * tpw.x + 
                     tex2D(_DistanceNoise, uv1) * tpw.y + 
                     tex2D(_DistanceNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DistanceNoise, uv).rgb;
                  #endif

                  float fade = saturate ((camDist - _DistanceNoiseScaleStrengthFade.z) / _DistanceNoiseScaleStrengthFade.w);
                  fade *= _DistanceNoiseScaleStrengthFade.y;

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }
            }
            #endif
         }

         void DoGlitter(inout MegaSplatLayer splats, half shine, half reflectAmt, float3 wsNormal, float3 wsView, float2 uv)
         {
            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            half3 lightDir = normalize(_WorldSpaceLightPos0);

            half3 viewDir = normalize(wsView);
            half NdotL = saturate(dot(splats.Normal, lightDir));
            lightDir = reflect(lightDir, splats.Normal);
            half specular = saturate(abs(dot(lightDir, viewDir)));


            //float2 offset = float2(viewDir.z, wsNormal.x) + splats.Normal.xy * 0.1;
            float2 offset = splats.Normal * 0.1;
            offset = fmod(offset, 1.0);

            half detail = tex2D(_GlitterTexture, uv * _GlitterParams.xy + offset).x;

            #if _GLITTERMOVES
               float2 uv0 = uv * _GlitterParams.w + _Time.y * _GlitterParams.z;
               float2 uv1 = uv * _GlitterParams.w + _Time.y  * 1.04 * -_GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               half detail3 = tex2D(_GlitterTexture, uv1).y;
               detail *= sqrt(detail2 * detail3);
            #else
               float2 uv0 = uv * _GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               detail *= detail2;
            #endif
            detail *= saturate(splats.Height + 0.5);

            specular = pow(specular, shine) * floor(detail * reflectAmt);

            splats.Smoothness += specular;
            splats.Smoothness = min(splats.Smoothness, 1);
            #endif
         }


         LayerParams InitLayerParams(SplatInput si, float3 values, half2 texScale)
         {
            LayerParams data = NewLayerParams();
            #if _TERRAIN
            int i0 = round(values.x * 255);
            int i1 = round(values.y * 255);
            int i2 = round(values.z * 255);
            #else
            int i0 = round(values.x / max(si.weights.x, 0.00001));
            int i1 = round(values.y / max(si.weights.y, 0.00001));
            int i2 = round(values.z / max(si.weights.z, 0.00001));
            #endif

            #if _TRIPLANAR
            float3 coords = si.triplanarUVW * texScale.x;
            data.tpuv0_x = float3(coords.zy, i0);
            data.tpuv0_y = float3(coords.xz, i0);
            data.tpuv0_z = float3(coords.xy, i0);
            data.tpuv1_x = float3(coords.zy, i1);
            data.tpuv1_y = float3(coords.xz, i1);
            data.tpuv1_z = float3(coords.xy, i1);
            data.tpuv2_x = float3(coords.zy, i2);
            data.tpuv2_y = float3(coords.xz, i2);
            data.tpuv2_z = float3(coords.xy, i2);
            data.mipUV = coords.xz;

            float2 splatUV = si.splatUV * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);

            #else
            float2 splatUV = si.splatUV.xy * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);
            data.mipUV = splatUV.xy;
            #endif



            #if _FLOW || _FLOWREFRACTION
            data.flowOn = 0;
            #endif

            #if _DISTANCERESAMPLE
            InitDistanceResample(data, si.camDist.y);
            #endif

            return data;
         }

         MegaSplatLayer DoSurf(inout SplatInput si, MegaSplatLayer macro, float3x3 tangentToWorld)
         {
            #if _ALPHALAYER
            LayerParams mData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.xy);
            #else
            LayerParams mData = InitLayerParams(si, si.valuesMain.xyz, _TexScales.xy);
            #endif

            #if _ALPHAHOLE
            if (mData.uv0.z == _AlphaHoleIdx || mData.uv1.z == _AlphaHoleIdx || mData.uv2.z == _AlphaHoleIdx)
            {
               clip(-1);
            } 
            #endif

            #if _PARALLAX && (_TESSEDGE || _TESSDISTANCE || _LOWPOLY || _ALPHATEST)
            si.viewDir = mul(si.viewDir, tangentToWorld);
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT
            float2 puddleUV = si.macroUV * _PuddleUVScales.xy;
            #elif _PUDDLES
            float2 puddleUV = 0;
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT

            si.waterNormalFoam = float3(0,0,0);
            if (si.puddleHeight > 0 && si.camDist.y < 40)
            {
               float str = 1.0 - ((si.camDist.y - 20) / 20);
               si.waterNormalFoam = GetWaterNormal(puddleUV, si.flowDir) * str;
            }
            #endif

            SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

            #if _FLOWREFRACTION
            // see through
            //sampleBottom = sampleBottom || mData.flowOn > 0;
            #endif

            half porosity = _GlobalPorosityWetness.x;
            #if _PERTEXMATPARAMS
            porosity = mData.porosity.x * mData.weights.x + mData.porosity.y * mData.weights.y + mData.porosity.z * mData.weights.z;
            #endif

            #if _TWOLAYER
               LayerParams sData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.zw);

               #if _ALPHAHOLE
               if (sData.uv0.z == _AlphaHoleIdx || sData.uv1.z == _AlphaHoleIdx || sData.uv2.z == _AlphaHoleIdx)
               {
                  clip(-1);
               } 
               #endif

               sData.layerBlend = si.layerBlend;
               SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(sData.uv0, si.flowDir, _FlowSpeed * sData.flowIntensity.x, _FlowIntensity, sData.fuv0a, sData.fuv0b, sData.flowInterps.x);
                  Flow(sData.uv1, si.flowDir, _FlowSpeed * sData.flowIntensity.y, _FlowIntensity, sData.fuv1a, sData.fuv1b, sData.flowInterps.y);
                  Flow(sData.uv2, si.flowDir, _FlowSpeed * sData.flowIntensity.z, _FlowIntensity, sData.fuv2a, sData.fuv2b, sData.flowInterps.z);
                  mData.flowOn = 0;
               #endif

               MegaSplatLayer second = SampleLayer(sData, si);

               #if _FLOWREFRACTION
                  float hMod = FlowRefract(second, mData, sData, si.weights);
               #endif
            #else // _TWOLAYER

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(mData.uv0, si.flowDir, _FlowSpeed * mData.flowIntensity.x, _FlowIntensity, mData.fuv0a, mData.fuv0b, mData.flowInterps.x);
                  Flow(mData.uv1, si.flowDir, _FlowSpeed * mData.flowIntensity.y, _FlowIntensity, mData.fuv1a, mData.fuv1b, mData.flowInterps.y);
                  Flow(mData.uv2, si.flowDir, _FlowSpeed * mData.flowIntensity.z, _FlowIntensity, mData.fuv2a, mData.fuv2b, mData.flowInterps.z);
               #endif
            #endif

            #if _NOBLENDBOTTOM
               MegaSplatLayer splats = SampleLayerNoBlend(mData, si);
            #else
               MegaSplatLayer splats = SampleLayer(mData, si);
            #endif

            #if _TWOLAYER
               // blend layers together..
               float hfac = HeightBlend(splats.Height, second.Height, sData.layerBlend, _Contrast);
               #if _FLOWREFRACTION
                  hfac *= hMod;
               #endif
               splats = BlendResults(splats, second, hfac);
               porosity = lerp(porosity, 
                     sData.porosity.x * sData.weights.x + 
                     sData.porosity.y * sData.weights.y + 
                     sData.porosity.z * sData.weights.z,
                     hfac);
            #endif

            #if _GEOMAP
            float2 geoUV = float2(0, si.worldPos.y * _GeoParams.y + _GeoParams.z);
            half4 geoTex = tex2D(_GeoTex, geoUV);
            splats.Albedo = lerp(splats.Albedo, BlendMult2X(splats.Albedo, geoTex), _GeoParams.x * geoTex.a);
            #endif

            half macroBlend = 1;
            #if _USEMACROTEXTURE
            macroBlend = saturate(_MacroTextureStrength * si.camDist.x);
            #endif

            #if _DETAILMAP
               float dist = si.camDist.y;
               if (dist > _DistanceFades.w)
               {
                  MegaSplatLayer o = (MegaSplatLayer)0;
                  UNITY_INITIALIZE_OUTPUT(MegaSplatLayer,o);
                  #if _USEMACROTEXTURE
                  splats = OverlayResults(splats, macro, macroBlend);
                  #endif
                  o.Albedo = splats.Albedo;
                  o.Normal = splats.Normal;
                  o.Emission = splats.Emission;
                  o.Occlusion = splats.Occlusion;
                  #if !_RAMPLIGHTING
                  o.Metallic = splats.Metallic;
                  o.Smoothness = splats.Smoothness;
                  #endif
                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_Final(si, o);
                  #endif
                  return o;
               }

               LayerParams sData = InitLayerParams(si, si.valuesMain, _TexScales.zw);
               MegaSplatLayer second = SampleDetail(mData.weights, si.viewDir, sData, si.triplanarBlend);   // use prev weights for detail

               float detailBlend = 1.0 - saturate((dist - _DistanceFades.z) / (_DistanceFades.w - _DistanceFades.z));
               splats = BlendDetail(splats, second, detailBlend); 
            #endif

            ApplyDetailNoise(splats.Albedo, splats.Normal, splats.Smoothness, mData, si.camDist.y, si.triplanarBlend);

            float3 worldNormal = float3(0,0,1);
            #if _SNOW || _RAINDROPFLATONLY
            worldNormal = mul(tangentToWorld, normalize(splats.Normal));
            #endif

            #if _SNOWGLITTER || _PERTEXGLITTER || _PUDDLEGLITTER
            half glitterShine = 0;
            half glitterReflect = 0;
            #endif

            #if _PERTEXGLITTER
            glitterReflect = mData.perTexGlitterReflect.x * mData.weights.x + mData.perTexGlitterReflect.y * mData.weights.y + mData.perTexGlitterReflect.z * mData.weights.z;
               #if _TWOLAYER || _ALPHALAYER
               float glitterReflect2 = sData.perTexGlitterReflect.x * sData.weights.x + sData.perTexGlitterReflect.y * sData.weights.y + sData.perTexGlitterReflect.z * sData.weights.z;
               glitterReflect = lerp(glitterReflect, glitterReflect2, hfac);
               #endif
            glitterReflect *= 14;
            glitterShine = 1.5;
            #endif


            float pud = 0;
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
               if (si.puddleHeight > 0)
               {
                  pud = DoPuddles(splats, puddleUV, si.waterNormalFoam, si.puddleHeight, si.flowDir, porosity, worldNormal);
               }
            #endif

            #if _LAVA
               float2 lavaUV = si.macroUV * _LavaUVScale.xy;


               if (si.puddleHeight > 0)
               {
                  pud = DoLava(splats, lavaUV, si.puddleHeight, si.flowDir);
               }
            #endif

            #if _PUDDLEGLITTER
            glitterShine = lerp(glitterShine, _GlitterSurfaces.z, pud);
            glitterReflect = lerp(glitterReflect, _GlitterSurfaces.w, pud);
            #endif


            #if _SNOW && !_SNOWOVERMACRO
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOW && _SNOWOVERMACRO
            half preserveAO = splats.Occlusion;
            #endif

            #if _WETNESS
            WaterBRDF(splats.Albedo, splats.Smoothness, splats.Metallic, max( si.wetness, _GlobalPorosityWetness.y) * _MaxWetness, porosity); 
            #endif


            #if _ALPHALAYER
            half blend = HeightBlend(splats.Height, 1 - macro.Height, si.layerBlend * macroBlend, _Contrast);
            splats = OverlayResults(splats, macro, blend);
            #elif _USEMACROTEXTURE
            splats = OverlayResults(splats, macro, macroBlend);
            #endif

            #if _SNOW && _SNOWOVERMACRO
               splats.Occlusion = preserveAO;
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            DoGlitter(splats, glitterShine, glitterReflect, si.wsNormal, si.wsView, si.macroUV);
            #endif

            #if _CUSTOMUSERFUNCTION
            CustomMegaSplatFunction_Final(si, splats);
            #endif

            return splats;
         }

         #if _DEBUG_OUTPUT_SPLATDATA
         float3 DebugSplatOutput(SplatInput si)
         {
            float3 data = float3(0,0,0);
            int i0 = round(si.valuesMain.x / max(si.weights.x, 0.00001));
            int i1 = round(si.valuesMain.y / max(si.weights.y, 0.00001));
            int i2 = round(si.valuesMain.z / max(si.weights.z, 0.00001));

            #if _TWOLAYER || _ALPHALAYER
            int i3 = round(si.valuesSecond.x / max(si.weights.x, 0.00001));
            int i4 = round(si.valuesSecond.y / max(si.weights.y, 0.00001));
            int i5 = round(si.valuesSecond.z / max(si.weights.z, 0.00001));
            data.z = si.layerBlend;
            #endif

            if (si.weights.x > si.weights.y && si.weights.x > si.weights.z)
            {
               data.x = i0 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i3 / 255.0;
               #endif
            }
            else if (si.weights.y > si.weights.x && si.weights.y > si.weights.z)
            {
               data.x = i1 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i4 / 255.0;
               #endif
            }
            else
            {
               data.x = i2 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i5 / 255.0;
               #endif
            }
            return data;
         }
         #endif

 
            UnityLight AdditiveLight (half3 normalWorld, half3 lightDir, half atten)
            {
               UnityLight l;

               l.color = _LightColor0.rgb;
               l.dir = lightDir;
               #ifndef USING_DIRECTIONAL_LIGHT
                  l.dir = normalize(l.dir);
               #endif
               l.ndotl = LambertTerm (normalWorld, l.dir);

               // shadow the light
               l.color *= atten;
               return l;
            }

            UnityLight MainLight (half3 normalWorld)
            {
               UnityLight l;
               #ifdef LIGHTMAP_OFF
                  
                  l.color = _LightColor0.rgb;
                  l.dir = _WorldSpaceLightPos0.xyz;
                  l.ndotl = LambertTerm (normalWorld, l.dir);
               #else
                  // no light specified by the engine
                  // analytical light might be extracted from Lightmap data later on in the shader depending on the Lightmap type
                  l.color = half3(0.f, 0.f, 0.f);
                  l.ndotl  = 0.f;
                  l.dir = half3(0.f, 0.f, 0.f);
               #endif

               return l;
            }

            inline half4 VertexGIForward(float2 uv1, float2 uv2, float3 posWorld, half3 normalWorld)
            {
               half4 ambientOrLightmapUV = 0;
               // Static lightmaps
               #ifdef LIGHTMAP_ON
                  ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                  ambientOrLightmapUV.zw = 0;
               // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
               #elif UNITY_SHOULD_SAMPLE_SH
                  #ifdef VERTEXLIGHT_ON
                     // Approximated illumination from non-important point lights
                     ambientOrLightmapUV.rgb = Shade4PointLights (
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, posWorld, normalWorld);
                  #endif

                  ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);     
               #endif

               #ifdef DYNAMICLIGHTMAP_ON
                  ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
               #endif

               return ambientOrLightmapUV;
            }

            void LightPBRDeferred(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic,
                           half occlusion, half alpha, float3 viewDir,
                           inout half3 indirectDiffuse, inout half3 indirectSpecular, inout half3 diffuseColor, inout half3 specularColor)
            {
               #if _PASSDEFERRED
               half lightAtten = 1;
               half roughness = 1 - smoothness;

               UnityLight light = MainLight (normalDirection);

               UnityGIInput d;
               UNITY_INITIALIZE_OUTPUT(UnityGIInput, d);
               d.light = light;
               d.worldPos = i.posWorld.xyz;
               d.worldViewDir = viewDir;
               d.atten = lightAtten;
               #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                  d.ambient = 0;
                  d.lightmapUV = i.ambientOrLightmapUV;
               #else
                  d.ambient = i.ambientOrLightmapUV.rgb;
                  d.lightmapUV = 0;
               #endif
               d.boxMax[0] = unity_SpecCube0_BoxMax;
               d.boxMin[0] = unity_SpecCube0_BoxMin;
               d.probePosition[0] = unity_SpecCube0_ProbePosition;
               d.probeHDR[0] = unity_SpecCube0_HDR;
               d.boxMax[1] = unity_SpecCube1_BoxMax;
               d.boxMin[1] = unity_SpecCube1_BoxMin;
               d.probePosition[1] = unity_SpecCube1_ProbePosition;
               d.probeHDR[1] = unity_SpecCube1_HDR;

               UnityGI gi = UnityGlobalIllumination(d, occlusion, 1.0 - smoothness, normalDirection );

               specularColor = metallic.xxx;
               float specularMonochrome;
               diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, specularMonochrome );

               indirectSpecular = (gi.indirect.specular);
               float NdotV = max(0.0,dot( normalDirection, viewDir ));
               specularMonochrome = 1.0-specularMonochrome;
               half grazingTerm = saturate( smoothness + specularMonochrome );
               indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
               indirectDiffuse = half3(0,0,0);
               indirectDiffuse += gi.indirect.diffuse;
               indirectDiffuse *= occlusion;

               #endif
            }


            half4 LightPBR(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic, 
                            half occlusion, half alpha, float3 viewDir, float4 ambientOrLightmapUV)
            {
                

                #if _PASSFORWARDBASE
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG(i.fogCoord, ramped);
                   return ramped;
                }
                #endif

                UnityLight light = MainLight (normalDirection);

                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDir;
                d.atten = lightAtten;
                #if LIGHTMAP_ON || DYNAMICLIGHTMAP_ON
                    d.ambient = 0;
                    d.lightmapUV = i.ambientOrLightmapUV;
                #else
                    d.ambient = i.ambientOrLightmapUV;
                    d.lightmapUV = 0;
                #endif

                d.boxMax[0] = unity_SpecCube0_BoxMax;
                d.boxMin[0] = unity_SpecCube0_BoxMin;
                d.probePosition[0] = unity_SpecCube0_ProbePosition;
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.boxMax[1] = unity_SpecCube1_BoxMax;
                d.boxMin[1] = unity_SpecCube1_BoxMin;
                d.probePosition[1] = unity_SpecCube1_ProbePosition;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = roughness;
                ugls_en_data.reflUVW = reflect( -viewDir, normalDirection );
                UnityGI gi = UnityGlobalIllumination(d, occlusion, normalDirection, ugls_en_data );

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, oneMinusReflectivity );
                

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, gi.light, gi.indirect);
                c.rgb += UNITY_BRDF_GI (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, occlusion, gi);
                c.rgb += emission;
                c.a = alpha;
                UNITY_APPLY_FOG(i.fogCoord, c.rgb);
                return c;

                #elif _PASSFORWARDADD
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG_COLOR(i.fogCoord, ramped.rgb, half4(0,0,0,0));
                   return ramped;
                }
                #endif

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, oneMinusReflectivity );

                UnityLight light = AdditiveLight (normalDirection, normalDirection, lightAtten);
                UnityIndirect noIndirect = (UnityIndirect)0;
                noIndirect.diffuse = 0;
                noIndirect.specular = 0;

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, light, noIndirect);
   
                UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
                c.a = alpha;
                return c;

                #endif
                return half4(1, 1, 0, 0);
            }

            float4 _SplatControl_TexelSize;

            struct VertexInput 
            {
                float4 vertex        : POSITION;
                float3 normal        : NORMAL;
                float2 texcoord0     : TEXCOORD0;
                #if !_PASSSHADOWCASTER && !_PASSMETA
                    float2 texcoord1 : TEXCOORD1;
                    float2 texcoord2 : TEXCOORD2;
                #endif
            };

            VirtualMapping GetMapping(VertexOutput i, sampler2D splatControl, sampler2D paramControl)
            {
               float2 texSize = _SplatControl_TexelSize.zw;
               float2 stp = _SplatControl_TexelSize.xy;
               // scale coords so we can take floor/frac to construct a cell
               float2 stepped = i.coords.xy * texSize;
               float2 uvBottom = floor(stepped);
               float2 uvFrac = frac(stepped);
               uvBottom /= texSize;

               float2 center = stp * 0.5;
               uvBottom += center;

               // construct uv/positions of triangle based on our interpolation point
               float2 cuv0, cuv1, cuv2;
               // make virtual triangle
               if (uvFrac.x > uvFrac.y)
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(stp.x, 0);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }
               else
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(0, stp.y);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }

               float2 uvBaryFrac = uvFrac * stp + uvBottom;
               float3 weights = Barycentric(uvBaryFrac, cuv0, cuv1, cuv2);
               VirtualMapping m = (VirtualMapping)0;
               m.weights = weights;
               m.c0 = tex2Dlod(splatControl, float4(cuv0, 0, 0));
               m.c1 = tex2Dlod(splatControl, float4(cuv1, 0, 0));
               m.c2 = tex2Dlod(splatControl, float4(cuv2, 0, 0));

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS || _FLOW || _FLOWREFRACTION || _LAVA
               fixed4 p0 = tex2Dlod(paramControl, float4(cuv0, 0, 0));
               fixed4 p1 = tex2Dlod(paramControl, float4(cuv1, 0, 0));
               fixed4 p2 = tex2Dlod(paramControl, float4(cuv2, 0, 0));
               m.param = p0 * weights.x + p1 * weights.y + p2 * weights.z;
               #endif
               return m;
            }

            SplatInput ToSplatInput(VertexOutput i, VirtualMapping m)
            {
               SplatInput o = (SplatInput)0;
               UNITY_INITIALIZE_OUTPUT(SplatInput,o);

               o.camDist = i.camDist;
               o.splatUV = i.coords;
               o.macroUV = i.coords;
               #if _SECONDUV
               o.macroUV = i.macroUV;
               #endif
               o.weights = m.weights;


               o.valuesMain = float3(m.c0.r, m.c1.r, m.c2.r);
               #if _TWOLAYER || _ALPHALAYER
               o.valuesSecond = float3(m.c0.g, m.c1.g, m.c2.g);
               o.layerBlend = m.c0.b * o.weights.x + m.c1.b * o.weights.y + m.c2.b * o.weights.z;
               #endif

               #if _TRIPLANAR
               o.triplanarUVW = i.triplanarUVW;
               o.triplanarBlend = i.extraData.xyz;
               #endif

               #if _FLOW || _FLOWREFRACTION || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.flowDir = m.param.xy;
               #endif

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.puddleHeight = m.param.a;
               #endif

               #if _WETNESS
               o.wetness = m.param.b;
               #endif

               #if _GEOMAP
               o.worldPos = i.posWorld;
               #endif

               return o;
            }

            LayerParams GetMainParams(VertexOutput i, inout VirtualMapping m, half2 texScale)
            {
               
               int i0 = (int)(m.c0.r * 255);
               int i1 = (int)(m.c1.r * 255);
               int i2 = (int)(m.c2.r * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               data.layerBlend = m.weights.x * m.c0.b + m.weights.y * m.c1.b + m.weights.z * m.c2.b;

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;
            }

            LayerParams GetSecondParams(VertexOutput i, VirtualMapping m, half2 texScale)
            {
               int i0 = (int)(m.c0.g * 255);
               int i1 = (int)(m.c1.g * 255);
               int i2 = (int)(m.c2.g * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;   
            }


            VertexOutput NoTessVert(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;

               o.tangent.xyz = cross(v.normal, float3(0,0,1));
               float4 tangent = float4(o.tangent, 1);
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(o.tangent, 1);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  o.tangent = tangent.xyz;
                  #endif
               }

               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(o.tangent, 1);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  o.tangent = tangent.xyz;
                  #endif
               }

               UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

               o.normal = UnityObjectToWorldNormal(v.normal);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

               o.coords.xy = v.texcoord0;
               #if _SECONDUV
               o.macroUV = v.texcoord0;
               o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
               #endif

               o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);


               #if !_PASSSHADOWCASTER && !_PASSMETA
               o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
               #endif

               float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
               o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
               float3 viewSpace = UnityObjectToViewPos(v.vertex);
               o.camDist.y = length(viewSpace.xyz);
               #if _TRIPLANAR
                  float3 norm = v.normal;
                  #if _TRIPLANAR_WORLDSPACE
                  o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                  norm = normalize(mul(unity_ObjectToWorld, norm));
                  #else
                  o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                  #endif
                  o.extraData.xyz = pow(abs(norm), _TriplanarContrast);
               #endif


               o.bitangent = normalize(cross(o.normal, o.tangent) * -1);  
               

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #elif !_PASSMETA && !_PASSDEFERRED
               UNITY_TRANSFER_FOG(o,o.pos);
               TRANSFER_VERTEX_TO_FRAGMENT(o)
               #endif
               return o;
            }


            #if _TESSDISTANCE || _TESSEDGE
            VertexOutput NoTessShadowVertBiased(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(0,0,0,0);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  #endif
               }
               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(0,0,0,0);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  #endif
                  UNITY_INITIALIZE_OUTPUT(VertexOutput,o);
               }
             
               o.normal = UnityObjectToWorldNormal(v.normal);
               v.vertex.xyz -= o.normal * _TessData1.yyy * half3(0.5, 0.5, 0.5);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.coords = v.texcoord0;

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #endif

               return o;
            }
            #endif

            #ifdef UNITY_CAN_COMPILE_TESSELLATION
            #if _TESSDISTANCE || _TESSEDGE 
            struct TessVertex 
            {
                 float4 vertex       : INTERNALTESSPOS;
                 float3 normal       : NORMAL;
                 float2 coords       : TEXCOORD0;      // uv, or triplanar UV
                 #if _TRIPLANAR
                 float3 triplanarUVW : TEXCOORD1;
                 float4 extraData    : TEXCOORD2;
                 #endif
                 float4 camDist      : TEXCOORD3;      // distance from camera (for fades) and fog

                 float3 posWorld     : TEXCOORD4;
                 float4 tangent      : TEXCOORD5;
                 float2 macroUV      : TEDCOORD6;
                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    LIGHTING_COORDS(7,8)
                    UNITY_FOG_COORDS(9)
                 #endif
                 float4 ambientOrLightmapUV : TEXCOORD10;
 
             };


            VertexOutput vert (TessVertex v) 
            {
                VertexOutput o = (VertexOutput)0;

                UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

                #if _CUSTOMUSERFUNCTION
                CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, v.tangent, v.coords.xy);
                #endif
                #if _USECURVEDWORLD
                V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                #endif

                o.ambientOrLightmapUV = v.ambientOrLightmapUV;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangent = normalize(cross(o.normal, o.tangent) * v.tangent.w);  
                o.pos = UnityObjectToClipPos(v.vertex);
                o.coords = v.coords;
                o.camDist = v.camDist;
                o.posWorld = v.posWorld;
                #if _SECONDUV
                o.macroUV = v.macroUV;
                #endif

                #if _TRIPLANAR
                o.triplanarUVW = v.triplanarUVW;
                o.extraData = v.extraData;
                #endif

                #if _PASSSHADOWCASTER
                TRANSFER_SHADOW_CASTER(o)
                #elif !_PASSMETA && !_PASSDEFERRED
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                #endif

                return o;
            }


                
             struct OutputPatchConstant {
                 float edge[3]         : SV_TessFactor;
                 float inside          : SV_InsideTessFactor;
                 float3 vTangent[4]    : TANGENT;
                 float2 vUV[4]         : TEXCOORD;
                 float3 vTanUCorner[4] : TANUCORNER;
                 float3 vTanVCorner[4] : TANVCORNER;
                 float4 vCWts          : TANWEIGHTS;
             };

             TessVertex tessvert (VertexInput v) 
             {
                 TessVertex o;
                 UNITY_INITIALIZE_OUTPUT(TessVertex,o);
                 #if _USECURVEDWORLD
                 V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                 #endif

                 o.vertex = v.vertex;
                 o.normal = v.normal;
                 o.coords.xy = v.texcoord0;
                 o.normal = UnityObjectToWorldNormal(v.normal);
                 o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

                 float4 tangent = float4(o.tangent.xyz, 1);
                 #if _SECONDUV
                 o.macroUV = v.texcoord0;
                 o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
                 #endif

                 o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);



                 #if !_PASSSHADOWCASTER && !_PASSMETA
                 o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
                 #endif

                 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
                 o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
                 float3 viewSpace = UnityObjectToViewPos(v.vertex);
                 o.camDist.y = length(viewSpace.xyz);
                 #if _TRIPLANAR
                    #if _TRIPLANAR_WORLDSPACE
                    o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #else
                    o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #endif
                    o.extraData.xyz = pow(abs(v.normal), _TriplanarContrast);
                 #endif

                 o.tangent.xyz = cross(v.normal, float3(0,0,1));
                 o.tangent.w = -1;

                 float tessFade = saturate((dist - _TessData2.x) / (_TessData2.y - _TessData2.x));
                 tessFade *= tessFade;
                 o.camDist.w = 1 - tessFade;

                 return o;
             }

             void displacement (inout TessVertex i)
             {
                  VertexOutput o = vert(i);
                  float3 viewDir = float3(0,0,1);

                  VirtualMapping mapping = GetMapping(o, _SplatControl, _SplatParams);
                  LayerParams mData = GetMainParams(o, mapping, _TexScales.xy);
                  SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

                  half3 extraData = float3(0,0,0);
                  #if _TRIPLANAR
                  extraData = o.extraData.xyz;
                  #endif

                  #if _TWOLAYER || _DETAILMAP
                  LayerParams sData = GetSecondParams(o, mapping, _TexScales.zw);
                  sData.layerBlend = mData.layerBlend;
                  SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);
                  float second = SampleLayerHeight(mapping.weights, viewDir, sData, extraData.xyz, _TessData1.z, _TessData2.z);
                  #endif

                  float splats = SampleLayerHeight(mapping.weights, viewDir, mData, extraData.xyz, _TessData1.z, _TessData2.z);

                  #if _TWOLAYER
                     // blend layers together..
                     float hfac = HeightBlend(splats, second, sData.layerBlend, _TessData2.z);
                     splats = lerp(splats, second, hfac);
                  #endif

                  half upBias = _TessData2.w;
                  #if _PERTEXDISPLACEPARAMS
                  float3 upBias3 = mData.upBias;
                     #if _TWOLAYER
                        upBias3 = lerp(upBias3, sData.upBias, hfac);
                     #endif
                  upBias = upBias3.x * mapping.weights.x + upBias3.y * mapping.weights.y + upBias3.z * mapping.weights.z;
                  #endif

                  #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
                     #if _PUDDLESPUSHTERRAIN
                     splats = max(splats - mapping.param.a, 0);
                     #else
                     splats = max(splats, mapping.param.a);
                     #endif
                  #endif

                  #if _TESSCENTERBIAS
                  splats -= 0.5;
                  #endif

                  #if _SNOW
                  float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                  float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                  float snowHeightFade = saturate((worldPos.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
                  splats += DoSnowDisplace(splats, i.coords.xy, worldNormal, snowHeightFade, mapping.param.a);
                  #endif

                  float3 offset = (lerp(i.normal, float3(0,1,0), upBias) * (i.camDist.w * _TessData1.y * splats));

                  #if _TESSDAMPENING
                  offset *= (mapping.c0.a * mapping.weights.x + mapping.c1.a * mapping.weights.y + mapping.c2.a * mapping.weights.z);
                  #endif

                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_PostDisplacement(i.vertex.xyz, offset, i.normal, i.tangent, i.coords.xy);
                  #else
                  i.vertex.xyz += offset;
                  #endif

             }

             #if _TESSEDGE
             float4 Tessellation(TessVertex v, TessVertex v1, TessVertex v2)
             {
                 return UnityEdgeLengthBasedTess(v.vertex, v1.vertex, v2.vertex, _TessData1.w);
             }
             #elif _TESSDISTANCE
             float4 Tessellation (TessVertex v0, TessVertex v1, TessVertex v2) 
             {
                return MegaSplatDistanceBasedTess( v0.camDist.w, v1.camDist.w, v2.camDist.w, _TessData1.x );
             }
             #endif

             OutputPatchConstant hullconst (InputPatch<TessVertex,3> v) {
                 OutputPatchConstant o = (OutputPatchConstant)0;
                 float4 ts = Tessellation( v[0], v[1], v[2] );
                 o.edge[0] = ts.x;
                 o.edge[1] = ts.y;
                 o.edge[2] = ts.z;
                 o.inside = ts.w;
                 return o;
             }
             [UNITY_domain("tri")]
             [UNITY_partitioning("fractional_odd")]
             [UNITY_outputtopology("triangle_cw")]
             [UNITY_patchconstantfunc("hullconst")]
             [UNITY_outputcontrolpoints(3)]
             TessVertex hull (InputPatch<TessVertex,3> v, uint id : SV_OutputControlPointID) 
             {
                 return v[id];
             }

             [UNITY_domain("tri")]
             VertexOutput domain (OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> vi, float3 bary : SV_DomainLocation) 
             {
                 TessVertex v = (TessVertex)0;
                 v.vertex =         vi[0].vertex * bary.x +       vi[1].vertex * bary.y +       vi[2].vertex * bary.z;
                 v.normal =         vi[0].normal * bary.x +       vi[1].normal * bary.y +       vi[2].normal * bary.z;
                 v.coords =         vi[0].coords * bary.x +       vi[1].coords * bary.y +       vi[2].coords * bary.z;
                 v.camDist =        vi[0].camDist * bary.x +      vi[1].camDist * bary.y +      vi[2].camDist * bary.z;
                 #if _TRIPLANAR
                 v.extraData =      vi[0].extraData * bary.x +    vi[1].extraData * bary.y +    vi[2].extraData * bary.z;
                 v.triplanarUVW =   vi[0].triplanarUVW * bary.x + vi[1].triplanarUVW * bary.y + vi[2].triplanarUVW * bary.z; 
                 #endif
                 v.tangent =        vi[0].tangent * bary.x +      vi[1].tangent * bary.y +      vi[2].tangent * bary.z;
                 v.macroUV =        vi[0].macroUV * bary.x +      vi[1].macroUV * bary.y +      vi[2].macroUV * bary.z;
                 v.posWorld =       vi[0].posWorld * bary.x +     vi[1].posWorld * bary.y +     vi[2].posWorld * bary.z;

                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    #if FOG_LINEAR || FOG_EXP || FOG_EXP2
                       v.fogCoord = vi[0].fogCoord * bary.x + vi[1].fogCoord * bary.y + vi[2].fogCoord * bary.z;
                    #endif
                    #if  SPOT || POINT_COOKIE || DIRECTIONAL_COOKIE 
                       v._LightCoord = vi[0]._LightCoord * bary.x + vi[1]._LightCoord * bary.y + vi[2]._LightCoord * bary.z; 
                       #if (SHADOWS_DEPTH && SPOT) || SHADOWS_CUBE || SHADOWS_DEPTH
                          v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y * vi[2]._ShadowCoord * bary.z; 
                       #endif
                    #elif DIRECTIONAL && (SHADOWS_CUBE || SHADOWS_DEPTH)
                       v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y + vi[2]._ShadowCoord * bary.z; 
                    #endif
                 #endif
                 v.ambientOrLightmapUV = vi[0].ambientOrLightmapUV * bary.x + vi[1].ambientOrLightmapUV * bary.y + vi[2].ambientOrLightmapUV * bary.z;

                 #if _TESSPHONG
                 float3 p = v.vertex.xyz;

                 // Calculate deltas to project onto three tangent planes
                 float3 p0 = dot(vi[0].vertex.xyz - p, vi[0].normal) * vi[0].normal;
                 float3 p1 = dot(vi[1].vertex.xyz - p, vi[1].normal) * vi[1].normal;
                 float3 p2 = dot(vi[2].vertex.xyz - p, vi[2].normal) * vi[2].normal;

                 // Lerp between projection vectors
                 float3 vecOffset = bary.x * p0 + bary.y * p1 + bary.z * p2;

                 // Add a fraction of the offset vector to the lerped position
                 p += 0.5 * vecOffset;

                 v.vertex.xyz = p;
                 #endif

                 displacement(v);
                 VertexOutput o = vert(v);
                 return o;
             }
            #endif
            #endif

            struct LightingTerms
            {
               half3 Albedo;
               half3 Normal;
               half  Smoothness;
               half  Metallic;
               half  Occlusion;
               half3 Emission;
               #if _ALPHA || _ALPHATEST
               half Alpha;
               #endif
            };

            void Splat(VertexOutput i, inout LightingTerms o, float3 viewDir, float3x3 tangentTransform)
            {
               VirtualMapping mapping = GetMapping(i, _SplatControl, _SplatParams);
               SplatInput si = ToSplatInput(i, mapping);
               si.viewDir = viewDir;
               #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
               si.wsView = viewDir;
               #endif

               MegaSplatLayer macro = (MegaSplatLayer)0;
               #if _SNOW
               float snowHeightFade = saturate((i.posWorld.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
               #endif

               #if _USEMACROTEXTURE || _ALPHALAYER
                  float2 muv = i.coords.xy;

                  #if _SECONDUV
                  muv = i.macroUV.xy;
                  #endif
                  macro = SampleMacro(muv);
                  #if _SNOW && _SNOWOVERMACRO

                  DoSnow(macro, muv, mul(tangentTransform, normalize(macro.Normal)), snowHeightFade, 0, _GlobalPorosityWetness.x, i.camDist.y);
                  #endif

                  #if _DISABLESPLATSINDISTANCE
                  if (i.camDist.x <= 0.0)
                  {
                     #if _CUSTOMUSERFUNCTION
                     CustomMegaSplatFunction_Final(si, macro);
                     #endif
                     o.Albedo = macro.Albedo;
                     o.Normal = macro.Normal;
                     o.Emission = macro.Emission;
                     #if !_RAMPLIGHTING
                     o.Smoothness = macro.Smoothness;
                     o.Metallic = macro.Metallic;
                     o.Occlusion = macro.Occlusion;
                     #endif
                     #if _ALPHA || _ALPHATEST
                     o.Alpha = macro.Alpha;
                     #endif

                     return;
                  }
                  #endif
               #endif

               #if _SNOW
               si.snowHeightFade = snowHeightFade;
               #endif

               MegaSplatLayer splats = DoSurf(si, macro, tangentTransform);

               #if _DEBUG_OUTPUT_ALBEDO
               o.Albedo = splats.Albedo;
               #elif _DEBUG_OUTPUT_HEIGHT
               o.Albedo = splats.Height.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_NORMAL
               o.Albedo = splats.Normal * 0.5 + 0.5 * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SMOOTHNESS
               o.Albedo = splats.Smoothness.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_METAL
               o.Albedo = splats.Metallic.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_AO
               o.Albedo = splats.Occlusion.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_EMISSION
               o.Albedo = splats.Emission * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SPLATDATA
               o.Albedo = DebugSplatOutput(si);
               #else
               o.Albedo = splats.Albedo;
               o.Normal = splats.Normal;
               o.Metallic = splats.Metallic;
               o.Smoothness = splats.Smoothness;
               o.Occlusion = splats.Occlusion;
               o.Emission = splats.Emission;
                  
               #endif

               #if _ALPHA || _ALPHATEST
                  o.Alpha = splats.Alpha;
               #endif
            }



            #if _PASSMETA
            half4 frag(VertexOutput i) : SV_Target 
            {
                i.normal = normalize(i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normal;
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );

                LightingTerms lt = (LightingTerms)0;

                float3x3 tangentTransform = (float3x3)0;
                #if _SNOW
                tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                #endif

                Splat(i, lt, viewDirection, tangentTransform);

                o.Emission = lt.Emission;
                
                float3 diffColor = lt.Albedo;
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, lt.Metallic, specColor, specularMonochrome );
                float roughness = 1.0 - lt.Smoothness;
                o.Albedo = diffColor + specColor * roughness * roughness * 0.5;
                return UnityMetaFragment( o );

            }
            #elif _PASSSHADOWCASTER
            half4 frag(VertexOutput i) : COLOR
            {
               SHADOW_CASTER_FRAGMENT(i)
            }
            #elif _PASSDEFERRED
            void frag(
                VertexOutput i,
                out half4 outDiffuse : SV_Target0,
                out half4 outSpecSmoothness : SV_Target1,
                out half4 outNormal : SV_Target2,
                out half4 outEmission : SV_Target3 )
            {
                i.normal = normalize(i.normal);
                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;
                Splat(i, o, viewDirection, tangentTransform);
                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif
                float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                
                half3 specularColor;
                half3 diffuseColor;
                half3 indirectDiffuse;
                half3 indirectSpecular;
                LightPBRDeferred(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, 
                  indirectDiffuse, indirectSpecular, diffuseColor, specularColor);
                
                outSpecSmoothness = half4(specularColor, o.Smoothness);
                outEmission = half4( o.Emission, 1 );
                outEmission.rgb += indirectSpecular * o.Occlusion;
                outEmission.rgb += indirectDiffuse * diffuseColor;
                #ifndef UNITY_HDR_ON
                    outEmission.rgb = exp2(-outEmission.rgb);
                #endif
                outDiffuse = half4(diffuseColor, o.Occlusion);
                outNormal = half4( normalDirection * 0.5 + 0.5, 1 );



            }
            #else
            half4 frag(VertexOutput i) : COLOR 
            {

                i.normal = normalize(i.normal);

                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;

                Splat(i, o, viewDirection, tangentTransform);

                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif

                #if _DEBUG_OUTPUT_ALBEDO || _DEBUG_OUTPUT_HEIGHT || _DEBUG_OUTPUT_NORMAL || _DEBUG_OUTPUT_SMOOTHNESS || _DEBUG_OUTPUT_METAL || _DEBUG_OUTPUT_AO || _DEBUG_OUTPUT_EMISSION
                   return half4(o.Albedo,1);
                #else
                   float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                   half4 lit = LightPBR(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, i.ambientOrLightmapUV);
                   #if _ALPHA || _ALPHATEST
                   lit.a = o.Alpha;
                   #endif
                   return lit;
                #endif

            }
            #endif


            #if _LOWPOLY
            [maxvertexcount(3)]
            void geom(triangle VertexOutput input[3], inout TriangleStream<VertexOutput> s)
            {
               VertexOutput v0 = input[0];
               VertexOutput v1 = input[1];
               VertexOutput v2 = input[2];

               float3 norm = input[0].normal + input[1].normal + input[2].normal;
               norm /= 3;
               float3 tangent = input[0].tangent + input[1].tangent + input[2].tangent;
               tangent /= 3;
              
               float3 bitangent = input[0].bitangent + input[1].bitangent + input[2].bitangent;
               bitangent /= 3;

               #if _LOWPOLYADJUST
               v0.normal = lerp(v0.normal, norm, _EdgeHardness);
               v1.normal = lerp(v1.normal, norm, _EdgeHardness);
               v2.normal = lerp(v2.normal, norm, _EdgeHardness);
              
               v0.tangent = lerp(v0.tangent, tangent, _EdgeHardness);
               v1.tangent = lerp(v1.tangent, tangent, _EdgeHardness);
               v2.tangent = lerp(v2.tangent, tangent, _EdgeHardness);
              
               v0.bitangent = lerp(v0.bitangent, bitangent, _EdgeHardness);;
               v1.bitangent = lerp(v1.bitangent, bitangent, _EdgeHardness);;
               v2.bitangent = lerp(v2.bitangent, bitangent, _EdgeHardness);;
               #else
               v0.normal = norm;
               v1.normal = norm;
               v2.normal = norm;
              
               v0.tangent = tangent;
               v1.tangent = tangent;
               v2.tangent = tangent;
              
               v0.bitangent = bitangent;
               v1.bitangent = bitangent;
               v2.bitangent = bitangent;
               #endif


               s.Append(v0);
               s.Append(v1);
               s.Append(v2);
            }
            #endif
            ENDCG
        }


         Pass 
         {
            Name "Meta"
            Tags { "LightMode"="Meta" }
            Cull Off
            
            CGPROGRAM
            #define UNITY_PASS_META 1
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Tessellation.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "UnityMetaPass.cginc"
            #include "AutoLight.cginc" // could remove
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma target 4.6

            #define _PASSMETA 1
         #pragma hull hull
         #pragma domain domain
         #pragma vertex tessvert
         #pragma fragment frag

      #define _NORMALMAP 1
      #define _PERTEXAOSTRENGTH 1
      #define _PERTEXCONTRAST 1
      #define _PERTEXDISPLACEPARAMS 1
      #define _PERTEXGLITTER 1
      #define _PERTEXMATPARAMS 1
      #define _PERTEXNORMALSTRENGTH 1
      #define _PERTEXUV 1
      #define _PUDDLEGLITTER 1
      #define _PUDDLES 1
      #define _PUDDLESPUSHTERRAIN 1
      #define _TERRAIN 1
      #define _TESSCENTERBIAS 1
      #define _TESSDAMPENING 1
      #define _TESSDISTANCE 1
      #define _TESSFALLBACK 1
      #define _TWOLAYER 1
      #define _WETNESS 1



         struct MegaSplatLayer
         {
            half3 Albedo;
            half3 Normal;
            half3 Emission;
            half  Metallic;
            half  Smoothness;
            half  Occlusion;
            half  Height;
            half  Alpha;
         };

         struct SplatInput
         {
            float3 weights;
            float2 splatUV;
            float2 macroUV;
            float3 valuesMain;
            half3 viewDir;
            float4 camDist;

            #if _TWOLAYER || _ALPHALAYER
            float3 valuesSecond;
            half layerBlend;
            #endif

            #if _TRIPLANAR
            float3 triplanarUVW;
            #endif
            half3 triplanarBlend; // passed to func, so always present

            #if _FLOW || _FLOWREFRACTION || _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half2 flowDir;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
            half puddleHeight;
            #endif

            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            float3 waterNormalFoam;
            #endif

            #if _WETNESS
            half wetness;
            #endif

            #if _TESSDAMPENING
            half displacementDampening;
            #endif

            #if _SNOW
            half snowHeightFade;
            #endif

            #if _SNOW || _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsNormal;
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            float3 wsView;
            #endif

            #if _GEOMAP
            float3 worldPos;
            #endif
         };


         struct LayerParams
         {
            float3 uv0, uv1, uv2;
            float2 mipUV; // uv for mip selection
            #if _TRIPLANAR
            float3 tpuv0_x, tpuv0_y, tpuv0_z;
            float3 tpuv1_x, tpuv1_y, tpuv1_z;
            float3 tpuv2_x, tpuv2_y, tpuv2_z;
            #endif
            #if _FLOW || _FLOWREFRACTION
            float3 fuv0a, fuv0b;
            float3 fuv1a, fuv1b;
            float3 fuv2a, fuv2b;
            #endif

            #if _DISTANCERESAMPLE
               half distanceBlend;
               float3 db_uv0, db_uv1, db_uv2;
               #if _TRIPLANAR
               float3 db_tpuv0_x, db_tpuv0_y, db_tpuv0_z;
               float3 db_tpuv1_x, db_tpuv1_y, db_tpuv1_z;
               float3 db_tpuv2_x, db_tpuv2_y, db_tpuv2_z;
               #endif
            #endif

            half layerBlend;
            half3 metallic;
            half3 smoothness;
            half3 porosity;
            #if _FLOW || _FLOWREFRACTION
            half3 flowIntensity;
            half flowOn;
            half3 flowAlphas;
            half3 flowRefracts;
            half3 flowInterps;
            #endif
            half3 weights;

            #if _TESSDISTANCE || _TESSEDGE
            half3 displacementScale;
            half3 upBias;
            #endif

            #if _PERTEXNOISESTRENGTH
            half3 detailNoiseStrength;
            #endif

            #if _PERTEXNORMALSTRENGTH
            half3 normalStrength;
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            half3 parallaxStrength;
            #endif

            #if _PERTEXAOSTRENGTH
            half3 aoStrength;
            #endif

            #if _PERTEXGLITTER
            half3 perTexGlitterReflect;
            #endif

            half3 contrast;
         };

         struct VirtualMapping
         {
            float3 weights;
            fixed4 c0, c1, c2;
            fixed4 param;
         };



         #include "UnityCG.cginc"
         #include "AutoLight.cginc"
         #include "Lighting.cginc"
         #include "UnityPBSLighting.cginc"
         #include "UnityStandardBRDF.cginc"

         // splat
         UNITY_DECLARE_TEX2DARRAY(_Diffuse);
         float4 _Diffuse_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_Normal);
         float4 _Normal_TexelSize;
         #if _EMISMAP
         UNITY_DECLARE_TEX2DARRAY(_Emissive);
         float4 _Emissive_TexelSize;
         #endif
         #if _DETAILMAP
         UNITY_DECLARE_TEX2DARRAY(_DetailAlbedo);
         float4 _DetailAlbedo_TexelSize;
         UNITY_DECLARE_TEX2DARRAY(_DetailNormal);
         float4 _DetailNormal_TexelSize;
         half _DetailTextureStrength;
         #endif

         #if _ALPHA || _ALPHATEST
         UNITY_DECLARE_TEX2DARRAY(_AlphaArray);
         float4 _AlphaArray_TexelSize;
         #endif

         #if _LOWPOLY
         half _EdgeHardness;
         #endif

         #if _TERRAIN
         sampler2D _SplatControl;
         sampler2D _SplatParams;
         #endif

         #if _ALPHAHOLE
         int _AlphaHoleIdx;
         #endif

         #if _RAMPLIGHTING
         sampler2D _Ramp;
         #endif

         #if _UVLOCALTOP || _UVWORLDTOP || _UVLOCALFRONT || _UVWORLDFRONT || _UVLOCALSIDE || _UVWORLDSIDE
         float4 _UVProjectOffsetScale;
         #endif
         #if _UVLOCALTOP2 || _UVWORLDTOP2 || _UVLOCALFRONT2 || _UVWORLDFRONT2 || _UVLOCALSIDE2 || _UVWORLDSIDE2
         float4 _UVProjectOffsetScale2;
         #endif

         half _Contrast;

         #if _ALPHALAYER || _USEMACROTEXTURE
         // macro texturing
         sampler2D _MacroDiff;
         sampler2D _MacroBump;
         sampler2D _MetallicGlossMap;
         sampler2D _MacroAlpha;
         half2 _MacroTexScale;
         half _MacroTextureStrength;
         half2 _MacroTexNormAOScales;
         #endif

         // default spec
         half _Glossiness;
         half _Metallic;

         #if _DISTANCERESAMPLE
         float3  _ResampleDistanceParams;
         #endif

         #if _FLOW || _FLOWREFRACTION
         // flow
         half _FlowSpeed;
         half _FlowAlpha;
         half _FlowIntensity;
         half _FlowRefraction;
         #endif

         half2 _PerTexScaleRange;
         sampler2D _PropertyTex;

         // etc
         half2 _Parallax;
         half4 _TexScales;

         float4 _DistanceFades;
         float4 _DistanceFadesCached;
         int _ControlSize;

         #if _TRIPLANAR
         half _TriplanarTexScale;
         half _TriplanarContrast;
         float3 _TriplanarOffset;
         #endif

         #if _GEOMAP
         sampler2D _GeoTex;
         float3 _GeoParams;
         #endif

         #if _PROJECTTEXTURE_LOCAL || _PROJECTTEXTURE_WORLD
         half3 _ProjectTexTop;
         half3 _ProjectTexSide;
         half3 _ProjectTexBottom;
         half3 _ProjectTexThresholdFreq;
         #endif

         #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
         half3 _ProjectTexTop2;
         half3 _ProjectTexSide2;
         half3 _ProjectTexBottom2;
         half3 _ProjectTexThresholdFreq2;
         half4 _ProjectTexBlendParams;
         #endif

         #if _TESSDISTANCE || _TESSEDGE
         float4 _TessData1; // distance tessellation, displacement, edgelength
         float4 _TessData2; // min, max
         #endif

         #if _DETAILNOISE
         sampler2D _DetailNoise;
         half3 _DetailNoiseScaleStrengthFade;
         #endif

         #if _DISTANCENOISE
         sampler2D _DistanceNoise;
         half4 _DistanceNoiseScaleStrengthFade;
         #endif

         #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
         half3 _PuddleTint;
         half _PuddleBlend;
         half _MaxPuddles;
         half4 _PuddleFlowParams;
         half2 _PuddleNormalFoam;
         #endif

         #if _RAINDROPS
         sampler2D _RainDropTexture;
         half _RainIntensity;
         float2 _RainUVScales;
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         float2 _PuddleUVScales;
         sampler2D _PuddleNormal;
         #endif

         #if _LAVA
         sampler2D _LavaDiffuse;
         sampler2D _LavaNormal;
         half4 _LavaParams;
         half4 _LavaParams2;
         half3 _LavaEdgeColor;
         half3 _LavaColorLow;
         half3 _LavaColorHighlight;
         float2 _LavaUVScale;
         #endif

         #if _WETNESS
         half _MaxWetness;
         #endif

         half2 _GlobalPorosityWetness;

         #if _SNOW
         sampler2D _SnowDiff;
         sampler2D _SnowNormal;
         half4 _SnowParams; // influence, erosion, crystal, melt
         half _SnowAmount;
         half2 _SnowUVScales;
         half2 _SnowHeightRange;
         half3 _SnowUpVector;
         #endif

         #if _SNOWDISTANCENOISE
         sampler2D _SnowDistanceNoise;
         float4 _SnowDistanceNoiseScaleStrengthFade;
         #endif

         #if _SNOWDISTANCERESAMPLE
         float4 _SnowDistanceResampleScaleStrengthFade;
         #endif

         #if _PERTEXGLITTER || _SNOWGLITTER || _PUDDLEGLITTER
         sampler2D _GlitterTexture;
         half4 _GlitterParams;
         half4 _GlitterSurfaces;
         #endif


         struct VertexOutput 
         {
             float4 pos          : SV_POSITION;
             #if !_TERRAIN
             fixed3 weights      : TEXCOORD0;
             float4 valuesMain   : TEXCOORD1;      //index rgb, triplanar W
                #if _TWOLAYER || _ALPHALAYER
                float4 valuesSecond : TEXCOORD2;      //index rgb + alpha
                #endif
             #elif _TRIPLANAR
             float3 triplanarUVW : TEXCOORD3;
             #endif
             float2 coords       : TEXCOORD4;      // uv, or triplanar UV
             float3 posWorld     : TEXCOORD5;
             float3 normal       : TEXCOORD6;

             float4 camDist      : TEXCOORD7;      // distance from camera (for fades) and fog
             float4 extraData    : TEXCOORD8;      // flowdir + fades, or if triplanar triplanarView + detailFade
             float3 tangent      : TEXCOORD9;
             float3 bitangent    : TEXCOORD10;
             float4 ambientOrLightmapUV : TEXCOORD14;


             #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
             LIGHTING_COORDS(11,12)
             UNITY_FOG_COORDS(13)
             #endif

             #if _PASSSHADOWCASTER
             float3 vec : TEXCOORD11;  // nice naming, Unity...
             #endif

             #if _WETNESS
             half wetness : TEXCOORD15;   //wetness
             #endif

             #if _SECONDUV
             float3 macroUV : TEXCOORD16;
             #endif

         };

         void OffsetUVs(inout LayerParams p, float2 offset)
         {
            p.uv0.xy += offset;
            p.uv1.xy += offset;
            p.uv2.xy += offset;
            #if _TRIPLANAR
            p.tpuv0_x.xy += offset;
            p.tpuv0_y.xy += offset;
            p.tpuv0_z.xy += offset;
            p.tpuv1_x.xy += offset;
            p.tpuv1_y.xy += offset;
            p.tpuv1_z.xy += offset;
            p.tpuv2_x.xy += offset;
            p.tpuv2_y.xy += offset;
            p.tpuv2_z.xy += offset;
            #endif
         }


         void InitDistanceResample(inout LayerParams lp, float dist)
         {
            #if _DISTANCERESAMPLE
               lp.distanceBlend = saturate((dist - _ResampleDistanceParams.y) / (_ResampleDistanceParams.z - _ResampleDistanceParams.y));
               lp.db_uv0 = lp.uv0;
               lp.db_uv1 = lp.uv1;
               lp.db_uv2 = lp.uv2;

               lp.db_uv0.xy *= _ResampleDistanceParams.xx;
               lp.db_uv1.xy *= _ResampleDistanceParams.xx;
               lp.db_uv2.xy *= _ResampleDistanceParams.xx;


               #if _TRIPLANAR
               lp.db_tpuv0_x = lp.tpuv0_x;
               lp.db_tpuv1_x = lp.tpuv1_x;
               lp.db_tpuv2_x = lp.tpuv2_x;
               lp.db_tpuv0_y = lp.tpuv0_y;
               lp.db_tpuv1_y = lp.tpuv1_y;
               lp.db_tpuv2_y = lp.tpuv2_y;
               lp.db_tpuv0_z = lp.tpuv0_z;
               lp.db_tpuv1_z = lp.tpuv1_z;
               lp.db_tpuv2_z = lp.tpuv2_z;

               lp.db_tpuv0_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_x.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_y.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv0_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv1_z.xy *= _ResampleDistanceParams.xx;
               lp.db_tpuv2_z.xy *= _ResampleDistanceParams.xx;
               #endif
            #endif
         }


         LayerParams NewLayerParams()
         {
            LayerParams l = (LayerParams)0;
            l.metallic = _Metallic.xxx;
            l.smoothness = _Glossiness.xxx;
            l.porosity = _GlobalPorosityWetness.xxx;

            l.layerBlend = 0;
            #if _FLOW || _FLOWREFRACTION
            l.flowIntensity = 0;
            l.flowOn = 0;
            l.flowAlphas = half3(1,1,1);
            l.flowRefracts = half3(1,1,1);
            #endif

            #if _TESSDISTANCE || _TESSEDGE
            l.displacementScale = half3(1,1,1);
            l.upBias = half3(0,0,0);
            #endif

            #if _PERTEXNOISESTRENGTH
            l.detailNoiseStrength = half3(1,1,1);
            #endif

            #if _PERTEXNORMALSTRENGTH
            l.normalStrength = half3(1,1,1);
            #endif

            #if _PERTEXAOSTRENGTH
            l.aoStrength = half3(1,1,1);
            #endif

            #if _PERTEXPARALLAXSTRENGTH
            l.parallaxStrength = half3(1,1,1);
            #endif

            l.contrast = _Contrast;

            return l;
         }

         half AOContrast(half ao, half scalar)
         {
            scalar += 0.5;  // 0.5 -> 1.5
            scalar *= scalar; // 0.25 -> 2.25
            return pow(ao, scalar);
         }

         half MacroAOContrast(half ao, half scalar)
         {
            #if _MACROAOSCALE
            return AOContrast(ao, scalar);
            #else
            return ao;
            #endif
         }
         #if _USEMACROTEXTURE || _ALPHALAYER
         MegaSplatLayer SampleMacro(float2 uv)
         {
             MegaSplatLayer o = (MegaSplatLayer)0;
             float2 macroUV = uv * _MacroTexScale.xy;
             half4 macAlb = tex2D(_MacroDiff, macroUV);
             o.Albedo = macAlb.rgb;
             o.Height = macAlb.a;
             // defaults
             o.Normal = half3(0,0,1);
             o.Occlusion = 1;
             o.Smoothness = _Glossiness;
             o.Metallic = _Metallic;
             o.Emission = half3(0,0,0);

             // unpack normal
             #if !_NOSPECTEX
             half4 normSample = tex2D(_MacroBump, macroUV);
             o.Normal = UnpackNormal(normSample);
             o.Normal.xy *= _MacroTexNormAOScales.x;
             #else
             o.Normal = half3(0,0,1);
             #endif


             #if _ALPHA || _ALPHATEST
             o.Alpha = tex2D(_MacroAlpha, macroUV).r;
             #endif
             return o;
         }
         #endif


         #if _NOSPECTEX
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = UnpackNormal(norm); 

         #elif _NOSPECNORMAL   
           #define SAMPLESPEC(o, params) \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.x = params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z; \
              specFinal.y = params.smoothness.x * weights.x + params.smoothness.y * weights.y + params.smoothness.z * weights.z; \
              o.Normal = half3(0,0,1);

         #else
            #define SAMPLESPEC(o, params) \
              half4 spec0, spec1, spec2; \
              half4 specFinal = half4(0,0,0,1); \
              specFinal.yw =  norm.zw; \
              specFinal.x = (params.metallic.x * weights.x + params.metallic.y * weights.y + params.metallic.z * weights.z); \
              norm.xy *= 2; \
              norm.xy -= 1; \
              o.Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy)))); \

         #endif

         void SamplePerTex(sampler2D pt, inout LayerParams params, float2 scaleRange)
         {
            const half cent = 1.0 / 512.0;
            const half pixelStep = 1.0 / 256.0;
            const half vertStep = 1.0 / 8.0;

            // pixel layout for per tex properties
            // metal/smooth/porosity/uv scale
            // flow speed, intensity, alpha, refraction
            // detailNoiseStrength, contrast, displacementAmount, displaceUpBias

            #if _PERTEXMATPARAMS || _PERTEXUV
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, 0, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, 0, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, 0, 0, 0));
               params.porosity = half3(0.4, 0.4, 0.4);
               #if _PERTEXMATPARAMS
               params.metallic = half3(props0.r, props1.r, props2.r);
               params.smoothness = half3(props0.g, props1.g, props2.g);
               params.porosity = half3(props0.b, props1.b, props2.b);
               #endif
               #if _PERTEXUV
               float3 uvScale = float3(props0.a, props1.a, props2.a);
               uvScale = lerp(scaleRange.xxx, scaleRange.yyy, uvScale);
               params.uv0.xy *= uvScale.x;
               params.uv1.xy *= uvScale.y;
               params.uv2.xy *= uvScale.z;

                  #if _TRIPLANAR
                  params.tpuv0_x.xy *= uvScale.xx; params.tpuv0_y.xy *= uvScale.xx; params.tpuv0_z.xy *= uvScale.xx;
                  params.tpuv1_x.xy *= uvScale.yy; params.tpuv1_y.xy *= uvScale.yy; params.tpuv1_z.xy *= uvScale.yy;
                  params.tpuv2_x.xy *= uvScale.zz; params.tpuv2_y.xy *= uvScale.zz; params.tpuv2_z.xy *= uvScale.zz;
                  #endif

               #endif
            }
            #endif


            #if _FLOW || _FLOWREFRACTION
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 3, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 3, 0, 0));

               params.flowIntensity = half3(props0.r, props1.r, props2.r);
               params.flowOn = params.flowIntensity.x + params.flowIntensity.y + params.flowIntensity.z;

               params.flowAlphas = half3(props0.b, props1.b, props2.b);
               params.flowRefracts = half3(props0.a, props1.a, props2.a);
            }
            #endif

            #if _PERTEXDISPLACEPARAMS || _PERTEXCONTRAST || _PERTEXNOISESTRENGTH
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 5, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 5, 0, 0));

               #if _PERTEXDISPLACEPARAMS && (_TESSDISTANCE || _TESSEDGE)
               params.displacementScale = half3(props0.b, props1.b, props2.b);
               params.upBias = half3(props0.a, props1.a, props2.a);
               #endif

               #if _PERTEXCONTRAST
               params.contrast = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXNOISESTRENGTH
               params.detailNoiseStrength = half3(props0.r, props1.r, props2.r);
               #endif
            }
            #endif

            #if _PERTEXNORMALSTRENGTH || _PERTEXPARALLAXSTRENGTH || _PERTEXAOSTRENGTH || _PERTEXGLITTER
            {
               half4 props0 = tex2Dlod(pt, half4(params.uv0.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props1 = tex2Dlod(pt, half4(params.uv1.z * pixelStep + cent, vertStep * 7, 0, 0));
               half4 props2 = tex2Dlod(pt, half4(params.uv2.z * pixelStep + cent, vertStep * 7, 0, 0));

               #if _PERTEXNORMALSTRENGTH
               params.normalStrength = half3(props0.r, props1.r, props2.r);
               #endif

               #if _PERTEXPARALLAXSTRENGTH
               params.parallaxStrength = half3(props0.g, props1.g, props2.g);
               #endif

               #if _PERTEXAOSTRENGTH
               params.aoStrength = half3(props0.b, props1.b, props2.b);
               #endif

               #if _PERTEXGLITTER
               params.perTexGlitterReflect = half3(props0.a, props1.a, props2.a);
               #endif

            }
            #endif
         }

         float FlowRefract(MegaSplatLayer tex, inout LayerParams main, inout LayerParams second, half3 weights)
         {
            #if _FLOWREFRACTION
            float totalFlow = second.flowIntensity.x * weights.x + second.flowIntensity.y * weights.y + second.flowIntensity.z * weights.z;
            float falpha = second.flowAlphas.x * weights.x + second.flowAlphas.y * weights.y + second.flowAlphas.z * weights.z;
            float frefract = second.flowRefracts.x * weights.x + second.flowRefracts.y * weights.y + second.flowRefracts.z * weights.z;
            float refractOn = min(1, totalFlow * 10000);
            float ratio = lerp(1.0, _FlowAlpha * falpha, refractOn);
            float2 rOff = tex.Normal.xy * _FlowRefraction * frefract * ratio;
            main.uv0.xy += rOff;
            main.uv1.xy += rOff;
            main.uv2.xy += rOff;
            return ratio;
            #endif
            return 1;
         }

         float MipLevel(float2 uv, float2 textureSize)
         {
            uv *= textureSize;
            float2  dx_vtc        = ddx(uv);
            float2  dy_vtc        = ddy(uv);
            float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
            return 0.5 * log2(delta_max_sqr);
         }


         #if _DISTANCERESAMPLE
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l); \
                  { \
                     half4 st0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv0_z, l); \
                     half4 st1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv1_z, l); \
                     half4 st2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_tpuv2_z, l); \
                     t0 = lerp(t0, st0, lp.distanceBlend); \
                     t1 = lerp(t1, st1, lp.distanceBlend); \
                     t2 = lerp(t2, st2, lp.distanceBlend); \
                  }
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv0, l), lp.distanceBlend); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv1, l), lp.distanceBlend); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.db_uv2, l), lp.distanceBlend); 
               #endif
            #endif
         #else // not distance resample
            #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
               #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, l); \
                  t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, l); \
                  t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, l) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, l) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, l);
            #else
               #if _FLOW || _FLOWREFRACTION
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                  if (lp.flowOn > 0) \
                  { \
                     t0 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv0b, l), lp.flowInterps.x); \
                     t1 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv1b, l), lp.flowInterps.y); \
                     t2 = lerp(UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2a, l), UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.fuv2b, l), lp.flowInterps.z); \
                  } \
                  else \
                  { \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l); \
                  }
               #else
                  #define SAMPLETEXARRAY(t0, t1, t2, TA, lp, l) \
                     t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, l); \
                     t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, l); \
                     t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, l);
               #endif
            #endif
         #endif


         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z, lod);
         #else
            #define SAMPLETEXARRAYLOD(t0, t1, t2, TA, lp, lod) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2, lod);
         #endif

         #if _TRIPLANAR && !_FLOW && !_FLOWREFRACTION
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv0_z + offset, lod); \
               t1  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv1_z + offset, lod); \
               t2  = tpw.x * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_x + offset, lod) + tpw.y * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_y + offset, lod) + tpw.z * UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.tpuv2_z + offset, lod);
         #else
            #define SAMPLETEXARRAYLODOFFSET(t0, t1, t2, TA, lp, lod, offset) \
               t0 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv0 + offset, lod); \
               t1 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv1 + offset, lod); \
               t2 = UNITY_SAMPLE_TEX2DARRAY_LOD(TA, lp.uv2 + offset, lod);
         #endif

         void Flow(float3 uv, half2 flow, half speed, float intensity, out float3 uv1, out float3 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));
            uv1.z = uv.z;
            uv2.z = uv.z;

            interp = abs(0.5 - phase.x) / 0.5;
         }

         void Flow(float2 uv, half2 flow, half speed, float intensity, out float2 uv1, out float2 uv2, out half interp)
         {
            float2 flowVector = (flow * 2.0 - 1.0) * intensity;
            
            float timeScale = _Time.y * speed;
            float2 phase = frac(float2(timeScale, timeScale + .5));

            uv1.xy = (uv.xy - flowVector * half2(phase.x, phase.x));
            uv2.xy = (uv.xy - flowVector * half2(phase.y, phase.y));

            interp = abs(0.5 - phase.x) / 0.5;
         }

         half3 ComputeWeights(half3 iWeights, half4 tex0, half4 tex1, half4 tex2, half contrast)
         {
             // compute weight with height map
             const half epsilon = 1.0f / 1024.0f;
             half3 weights = half3(iWeights.x * (tex0.a + epsilon), 
                                      iWeights.y * (tex1.a + epsilon),
                                      iWeights.z * (tex2.a + epsilon));

             // Contrast weights
             half maxWeight = max(weights.x, max(weights.y, weights.z));
             half transition = contrast * maxWeight;
             half threshold = maxWeight - transition;
             half scale = 1.0f / transition;
             weights = saturate((weights - threshold) * scale);
             // Normalize weights.
             half weightScale = 1.0f / (weights.x + weights.y + weights.z);
             weights *= weightScale;
             #if _LINEARBIAS
             weights = lerp(weights, iWeights, contrast);
             #endif
             return weights;
         }

         float2 ProjectUVs(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP
            return (vertex.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALSIDE
            return (vertex.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVLOCALFRONT
            return (vertex.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDTOP
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(1,0,0));
               tangent.w = worldNormal.y > 0 ? -1 : 1;
               #endif
            return (worldPos.xz * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDFRONT
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,0,1));
               tangent.w = worldNormal.x > 0 ? 1 : -1;
               #endif
            return (worldPos.zy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #elif _UVWORLDSIDE
               #if _PROJECTTANGENTS
               tangent.xyz = mul(unity_WorldToObject, float3(0,1,0));
               tangent.w = worldNormal.z > 0 ? 1 : -1;
               #endif
            return (worldPos.xy * _UVProjectOffsetScale.zw) + _UVProjectOffsetScale.xy;
            #endif
            return coords;
         }

         float2 ProjectUV2(float3 vertex, float2 coords, float3 worldPos, float3 worldNormal, inout float4 tangent)
         {
            #if _UVLOCALTOP2
            return (vertex.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALSIDE2
            return (vertex.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVLOCALFRONT2
            return (vertex.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDTOP2
            return (worldPos.xz * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDFRONT2
            return (worldPos.zy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #elif _UVWORLDSIDE2
            return (worldPos.xy * _UVProjectOffsetScale2.zw) + _UVProjectOffsetScale2.xy;
            #endif
            return coords;
         }

         void WaterBRDF (inout half3 Albedo, inout half Smoothness, half metalness, half wetFactor, half surfPorosity) 
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS
            half porosity = saturate((( (1 - Smoothness) - 0.5)) / max(surfPorosity, 0.001));
            half factor = lerp(1, 0.2, (1 - metalness) * porosity);
            Albedo *= lerp(1.0, factor, wetFactor);
            Smoothness = lerp(1.0, Smoothness, lerp(1.0, factor, wetFactor));
            #endif
         }

         #if _RAINDROPS
         float3 ComputeRipple(float2 uv, float time, float weight)
         {
            float4 ripple = tex2D(_RainDropTexture, uv);
            ripple.yz = ripple.yz * 2 - 1;

            float dropFrac = frac(ripple.w + time);
            float timeFrac = dropFrac - 1.0 + ripple.x;
            float dropFactor = saturate(0.2f + weight * 0.8 - dropFrac);
            float finalFactor = dropFactor * ripple.x * 
                                 sin( clamp(timeFrac * 9.0f, 0.0f, 3.0f) * 3.14159265359);

            return float3(ripple.yz * finalFactor * 0.35f, 1.0f);
         }
         #endif

         // water normal only
         half2 DoPuddleRefract(float3 waterNorm, half puddleLevel, float2 flowDir, half height)
         {
            #if _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - height) * _PuddleBlend);
            waterBlend *= waterBlend;

            waterNorm.xy *= puddleLevel * waterBlend;
               #if _PUDDLEDEPTHDAMPEN
               return lerp(waterNorm.xy, waterNorm.xy * height, _PuddleFlowParams.w);
               #endif
            return waterNorm.xy;

            #endif
            return half2(0,0);
         }

         // modity lighting terms for water..
         float DoPuddles(inout MegaSplatLayer o, float2 uv, half3 waterNormFoam, half puddleLevel, half2 flowDir, half porosity, float3 worldNormal)
         {
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
            puddleLevel *= _MaxPuddles;
            float waterBlend = saturate((puddleLevel - o.Height) * _PuddleBlend);

            half3 waterNorm = half3(0,0,1);
            #if _PUDDLEFLOW || _PUDDLEREFRACT

               waterNorm = half3(waterNormFoam.x, waterNormFoam.y, sqrt(1 - saturate(dot(waterNormFoam.xy, waterNormFoam.xy))));

               #if _PUDDLEFOAM
               half pmh = puddleLevel - o.Height;
               // refactor to compute flow UVs in previous step?
               float2 foamUV0;
               float2 foamUV1;
               half foamInterp;
               Flow(uv * 1.75 + waterNormFoam.xy * waterNormFoam.b, flowDir, _PuddleFlowParams.y/3, _PuddleFlowParams.z/3, foamUV0, foamUV1, foamInterp);
               half foam0 = tex2D(_PuddleNormal, foamUV0).b;
               half foam1 = tex2D(_PuddleNormal, foamUV1).b;
               half foam = lerp(foam0, foam1, foamInterp);
               foam = foam * abs(pmh) + (foam * o.Height);
               foam *= 1.0 - (saturate(pmh * 1.5));
               foam *= foam;
               foam *= _PuddleNormalFoam.y;
               #endif // foam
            #endif // flow, refract

            half3 wetAlbedo = o.Albedo * _PuddleTint * 2;
            half wetSmoothness = o.Smoothness;

            WaterBRDF(wetAlbedo, wetSmoothness, o.Metallic, waterBlend, porosity);

            #if _RAINDROPS
               float dropStrength = _RainIntensity;
               #if _RAINDROPFLATONLY
               dropStrength = saturate(dot(float3(0,1,0), worldNormal));
               #endif
               const float4 timeMul = float4(1.0f, 0.85f, 0.93f, 1.13f); 
               float4 timeAdd = float4(0.0f, 0.2f, 0.45f, 0.7f);
               float4 times = _Time.yyyy;
               times = frac((times * float4(1, 0.85, 0.93, 1.13) + float4(0, 0.2, 0.45, 0.7)) * 1.6);

               float2 ruv1 = uv * _RainUVScales.xy;
               float2 ruv2 = ruv1;

               float4 weights = _RainIntensity.xxxx - float4(0, 0.25, 0.5, 0.75);
               float3 ripple1 = ComputeRipple(ruv1 + float2( 0.25f,0.0f), times.x, weights.x);
               float3 ripple2 = ComputeRipple(ruv2 + float2(-0.55f,0.3f), times.y, weights.y);
               float3 ripple3 = ComputeRipple(ruv1 + float2(0.6f, 0.85f), times.z, weights.z);
               float3 ripple4 = ComputeRipple(ruv2 + float2(0.5f,-0.75f), times.w, weights.w);
               weights = saturate(weights * 4);

               float4 z = lerp(float4(1,1,1,1), float4(ripple1.z, ripple2.z, ripple3.z, ripple4.z), weights);
               float3 rippleNormal = float3( weights.x * ripple1.xy +
                           weights.y * ripple2.xy + 
                           weights.z * ripple3.xy + 
                           weights.w * ripple4.xy, 
                           z.x * z.y * z.z * z.w);

               waterNorm = lerp(waterNorm, normalize(rippleNormal+waterNorm), _RainIntensity * dropStrength);                         
            #endif

            #if _PUDDLEFOAM
            wetAlbedo += foam;
            wetSmoothness -= foam;
            #endif

            o.Normal = lerp(o.Normal, waterNorm, waterBlend * _PuddleNormalFoam.x);
            o.Occlusion = lerp(o.Occlusion, 1, waterBlend);
            o.Smoothness = lerp(o.Smoothness, wetSmoothness, waterBlend);
            o.Albedo = lerp(o.Albedo, wetAlbedo, waterBlend);
            return waterBlend;
            #endif
            return 0;
         }

         float DoLava(inout MegaSplatLayer o, float2 uv, half lavaLevel, half2 flowDir)
         {
            #if _LAVA

            half distortionSize = _LavaParams2.x;
            half distortionRate = _LavaParams2.y;
            half distortionScale = _LavaParams2.z;
            half darkening = _LavaParams2.w;
            half3 edgeColor = _LavaEdgeColor;
            half3 lavaColorLow = _LavaColorLow;
            half3 lavaColorHighlight = _LavaColorHighlight;


            half maxLava = _LavaParams.y;
            half lavaSpeed = _LavaParams.z;
            half lavaInterp = _LavaParams.w;

            lavaLevel *= maxLava;
            float lvh = lavaLevel - o.Height;
            float lavaBlend = saturate(lvh * _LavaParams.x);

            float2 uv1;
            float2 uv2;
            half interp;
            half drag = lerp(0.1, 1, saturate(lvh));
            Flow(uv, flowDir, lavaInterp, lavaSpeed * drag, uv1, uv2, interp);

            float2 dist_uv1;
            float2 dist_uv2;
            half dist_interp;
            Flow(uv * distortionScale, flowDir, distortionRate, distortionSize, dist_uv1, dist_uv2, dist_interp);

            half4 lavaDist = lerp(tex2D(_LavaDiffuse, dist_uv1*0.51), tex2D(_LavaDiffuse, dist_uv2), dist_interp);
            half4 dist = lavaDist * (distortionSize * 2) - distortionSize;

            half4 lavaTex = lerp(tex2D(_LavaDiffuse, uv1*1.1 + dist.xy), tex2D(_LavaDiffuse, uv2 + dist.zw), interp);

            lavaTex.xy = lavaTex.xy * 2 - 1;
            half3 lavaNorm = half3(lavaTex.xy, sqrt(1 - saturate(dot(lavaTex.xy, lavaTex.xy))));

            // base lava color, based on heights
            half3 lavaColor = lerp(lavaColorLow, lavaColorHighlight, lavaTex.b);

            // edges
            float lavaBlendWide = saturate((lavaLevel - o.Height) * _LavaParams.x * 0.5);
            float edge = saturate((1 - lavaBlendWide) * 3);

            // darkening
            darkening = saturate(lavaTex.a * darkening * saturate(lvh*2));
            lavaColor = lerp(lavaColor, lavaDist.bbb * 0.3, darkening);
            // edges
            lavaColor = lerp(lavaColor, edgeColor, edge);

            o.Albedo = lerp(o.Albedo, lavaColor, lavaBlend);
            o.Normal = lerp(o.Normal, lavaNorm, lavaBlend);
            o.Smoothness = lerp(o.Smoothness, 0.3, lavaBlend * darkening);

            half3 emis = lavaColor * lavaBlend;
            o.Emission = lerp(o.Emission, emis, lavaBlend);
            // bleed
            o.Emission += edgeColor * 0.3 * (saturate((lavaLevel*1.2 - o.Height) * _LavaParams.x) - lavaBlend);
            return lavaBlend;
            #endif
            return 0;
         }

         // no trig based hash, not a great hash, but fast..
         float Hash(float3 p)
         {
             p  = frac( p*0.3183099+.1 );
             p *= 17.0;
             return frac( p.x*p.y*p.z*(p.x+p.y+p.z) );
         }

         float Noise( float3 x )
         {
             float3 p = floor(x);
             float3 f = frac(x);
             f = f*f*(3.0-2.0*f);
            
             return lerp(lerp(lerp( Hash(p+float3(0,0,0)), Hash(p+float3(1,0,0)),f.x), lerp( Hash(p+float3(0,1,0)), Hash(p+float3(1,1,0)),f.x),f.y),
                       lerp(lerp(Hash(p+float3(0,0,1)), Hash(p+float3(1,0,1)),f.x), lerp(Hash(p+float3(0,1,1)), Hash(p+float3(1,1,1)),f.x),f.y),f.z);
         }

         // given 4 texture choices for each projection, return texture index based on normal
         // seems like we could remove some branching here.. hmm..
         float ProjectTexture(float3 worldPos, float3 normal, half3 threshFreq, half3 top, half3 side, half3 bottom)
         {
            half d = dot(normal, float3(0, 1, 0));
            half3 cvec = side;
            if (d < threshFreq.x)
            {
               cvec = bottom;
            }
            else if (d > threshFreq.y)
            {
               cvec = top;
            }

            float n = Noise(worldPos * threshFreq.z);
            if (n < 0.333)
               return cvec.x;
            else if (n < 0.666)
               return cvec.y;
            else
               return cvec.z;
         }

         void ProceduralTexture(float3 localPos, float3 worldPos, float3 normal, float3 worldNormal, inout float4 valuesMain, inout float4 valuesSecond, half3 weights)
         {
            #if _PROJECTTEXTURE_LOCAL
            half choice = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif
            #if _PROJECTTEXTURE_WORLD
            half choice = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq, _ProjectTexTop, _ProjectTexSide, _ProjectTexBottom);
            valuesMain.xyz = weights.rgb * choice;
            #endif

            #if _PROJECTTEXTURE2_LOCAL
            half choice2 = ProjectTexture(localPos, normal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif
            #if _PROJECTTEXTURE2_WORLD
            half choice2 = ProjectTexture(worldPos, worldNormal, _ProjectTexThresholdFreq2, _ProjectTexTop2, _ProjectTexSide2, _ProjectTexBottom2);
            valuesSecond.xyz = weights.rgb * choice2;
            #endif

            #if _PROJECTTEXTURE2_LOCAL || _PROJECTTEXTURE2_WORLD
            float blendNoise = Noise(worldPos * _ProjectTexBlendParams.x) - 0.5;
            blendNoise *= _ProjectTexBlendParams.y;
            blendNoise += 0.5;
            blendNoise = min(max(blendNoise, _ProjectTexBlendParams.z), _ProjectTexBlendParams.w);
            valuesSecond.a = saturate(blendNoise);
            #endif
         }


         // manually compute barycentric coordinates
         float3 Barycentric(float2 p, float2 a, float2 b, float2 c)
         {
             float2 v0 = b - a;
             float2 v1 = c - a;
             float2 v2 = p - a;
             float d00 = dot(v0, v0);
             float d01 = dot(v0, v1);
             float d11 = dot(v1, v1);
             float d20 = dot(v2, v0);
             float d21 = dot(v2, v1);
             float denom = d00 * d11 - d01 * d01;
             float v = (d11 * d20 - d01 * d21) / denom;
             float w = (d00 * d21 - d01 * d20) / denom;
             float u = 1.0f - v - w;
             return float3(u, v, w);
         }

         // given two height values (from textures) and a height value for the current pixel (from vertex)
         // compute the blend factor between the two with a small blending area between them.
         half HeightBlend(half h1, half h2, half slope, half contrast)
         {
            h2 = 1 - h2;
            half tween = saturate((slope - min(h1, h2)) / max(abs(h1 - h2), 0.001)); 
            half blend = saturate( ( tween - (1-contrast) ) / max(contrast, 0.001));
            #if _LINEARBIAS
            blend = lerp(slope, blend, contrast);
            #endif
            return blend;
         }

         void BlendSpec(inout MegaSplatLayer base, MegaSplatLayer macro, half r, float3 albedo)
         {
            base.Metallic = lerp(base.Metallic, macro.Metallic, r);
            base.Smoothness = lerp(base.Smoothness, macro.Smoothness, r);
            base.Emission = albedo * lerp(base.Emission, macro.Emission, r);
         }

         half3 BlendOverlay(half3 base, half3 blend) { return (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))); }
         half3 BlendMult2X(half3  base, half3 blend) { return (base * (blend * 2)); }


         MegaSplatLayer SampleDetail(half3 weights, float3 viewDir, inout LayerParams params, half3 tpw)
         {
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.ga *= params.normalStrength.x;
               norm1.ga *= params.normalStrength.y;
               norm2.ga *= params.normalStrength.z;
               #endif
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif

            SAMPLESPEC(o, params);

            o.Emission = albedo.rgb * specFinal.z;
            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            return o;
         }


         float SampleLayerHeight(half3 biWeights, float3 viewDir, inout LayerParams params, half3 tpw, float lod, float contrast)
         { 
            #if _TESSDISTANCE || _TESSEDGE
            half4 tex0, tex1, tex2;

            SAMPLETEXARRAYLOD(tex0, tex1, tex2, _Diffuse, params, lod);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, contrast);
            params.weights = weights;
            return (tex0.a * params.displacementScale.x * weights.x + 
                    tex1.a * params.displacementScale.y * weights.y + 
                    tex2.a * params.displacementScale.z * weights.z);
            #endif
            return 0.5;
         }

         #if _TESSDISTANCE || _TESSEDGE
         float4 MegaSplatDistanceBasedTess (float d0, float d1, float d2, float tess)
         {
            float3 f;
            f.x = clamp(d0, 0.01, 1.0) * tess;
            f.y = clamp(d1, 0.01, 1.0) * tess;
            f.z = clamp(d2, 0.01, 1.0) * tess;

            return UnityCalcTriEdgeTessFactors (f);
         }
         #endif

         #if _PUDDLEFLOW || _PUDDLEREFRACT
         half3 GetWaterNormal(float2 uv, float2 flowDir)
         {
            float2 uv1;
            float2 uv2;
            half interp;
            Flow(uv, flowDir, _PuddleFlowParams.y, _PuddleFlowParams.z, uv1, uv2, interp);

            half3 fd = lerp(tex2D(_PuddleNormal, uv1), tex2D(_PuddleNormal, uv2), interp).xyz;
            fd.xy = fd.xy * 2 - 1;
            return fd;
         }
         #endif

         MegaSplatLayer SampleLayer(inout LayerParams params, SplatInput si)
         { 
            half3 biWeights = si.weights;
            float3 viewDir = si.viewDir;
            half3 tpw = si.triplanarBlend;

            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0, tex1, tex2;
            half4 norm0, norm1, norm2;

            float mipLevel = MipLevel(params.mipUV, _Diffuse_TexelSize.zw);
            SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
            half3 weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
            params.weights = weights;
            fixed4 albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;

            #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
                  params.uv1.xy += refractOffset;
                  params.uv2.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * biWeights.x + params.parallaxStrength.y * biWeights.y + params.parallaxStrength.z * biWeights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, viewDir);
                  params.uv0.xy += pOffset;
                  params.uv1.xy += pOffset;
                  params.uv2.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  SAMPLETEXARRAY(tex0, tex1, tex2, _Diffuse, params, mipLevel);
                  weights = ComputeWeights(biWeights, tex0, tex1, tex2, params.contrast);
                  albedo = tex0 * weights.x + tex1 * weights.y + tex2 * weights.z;
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0, alpha1, alpha2;
            mipLevel = MipLevel(params.mipUV, _AlphaArray_TexelSize.zw);
            SAMPLETEXARRAY(alpha0, alpha1, alpha2, _AlphaArray, params, mipLevel);
            o.Alpha = alpha0.r * weights.x + alpha1.r * weights.y + alpha2.r * weights.z;
            #endif

            #if _NOSPECNORMAL
            half4 norm = half4(0,0,1,1);
            #else
            mipLevel = MipLevel(params.mipUV, _Normal_TexelSize.zw);
            SAMPLETEXARRAY(norm0, norm1, norm2, _Normal, params, mipLevel);
               #if _PERTEXNORMALSTRENGTH
               norm0.xy -= 0.5; norm1.xy -= 0.5; norm2.xy -= 0.5;
               norm0.xy *= params.normalStrength.x;
               norm1.xy *= params.normalStrength.y;
               norm2.xy *= params.normalStrength.z;
               norm0.xy += 0.5; norm1.xy += 0.5; norm2.xy += 0.5;
               #endif
            
            half4 norm = norm0 * weights.x + norm1 * weights.y + norm2 * weights.z;
            norm = norm.garb;
            #endif


            SAMPLESPEC(o, params);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            half4 emis0, emis1, emis2;
            mipLevel = MipLevel(params.mipUV, _Emissive_TexelSize.zw);
            SAMPLETEXARRAY(emis0, emis1, emis2, _Emissive, params, mipLevel);
            half4 emis = emis0 * weights.x + emis1 * weights.y + emis2 * weights.z;
            o.Emission = emis.rgb;
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _EMISMAP
            o.Metallic = emis.a;
            #endif

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x * params.weights.x + params.aoStrength.y * params.weights.y + params.aoStrength.z * params.weights.z;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif
            return o;
         }

         half4 SampleSpecNoBlend(LayerParams params, in half4 norm, out half3 Normal)
         {
            half4 specFinal = half4(0,0,0,1);
            Normal = half3(0,0,1);
            specFinal.x = params.metallic.x;
            specFinal.y = params.smoothness.x;

            #if _NOSPECTEX
               Normal = UnpackNormal(norm); 
            #else
               specFinal.yw = norm.zw;
               specFinal.x = params.metallic.x;
               norm.xy *= 2;
               norm.xy -= 1;
               Normal = half3(norm.x, norm.y, sqrt(1 - saturate(dot(norm.xy, norm.xy))));
            #endif

            return specFinal;
         }

         MegaSplatLayer SampleLayerNoBlend(inout LayerParams params, SplatInput si)
         { 
            MegaSplatLayer o = (MegaSplatLayer)0;
            half4 tex0;
            half4 norm0 = half4(0,0,1,1);

            tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
            fixed4 albedo = tex0;


             #if _PARALLAX || _PUDDLEREFRACT
               bool resample = false;
               #if _PUDDLEREFRACT
  

               resample = si.puddleHeight > 0 && si.camDist.y < 30;
               if (resample)
               {
                  float2 refractOffset = DoPuddleRefract(si.waterNormalFoam, si.puddleHeight, si.flowDir, albedo.a);
                  refractOffset *= _PuddleFlowParams.x;
                  params.uv0.xy += refractOffset;
               }
               #endif

               #if _PARALLAX
                  resample = resample || si.camDist.y < _Parallax.y*2;
                  float pamt = _Parallax.x * (1.0 - saturate((si.camDist.y - _Parallax.y) / _Parallax.y));
                  #if _PERTEXPARALLAXSTRENGTH
                  // can't really do per-tex, because that would require parallaxing each texture independently. So blend..
                  pamt *= (params.parallaxStrength.x * si.weights.x + params.parallaxStrength.y * si.weights.y + params.parallaxStrength.z * si.weights.z); 
                  #endif
                  float2 pOffset = ParallaxOffset (albedo.a, pamt, si.viewDir);
                  params.uv0.xy += pOffset;
               #endif

               //  resample
               if (resample)
               {
                  tex0 = UNITY_SAMPLE_TEX2DARRAY(_Diffuse, params.uv0); 
               }
            #endif

            #if _ALPHA || _ALPHATEST
            half4 alpha0 = UNITY_SAMPLE_TEX2DARRAY(_AlphaArray, params.uv0); 
            o.Alpha = alpha0.r;
            #endif


            #if !_NOSPECNORMAL
            norm0 = UNITY_SAMPLE_TEX2DARRAY(_Normal, params.uv0); 
               #if _PERTEXNORMALSTRENGTH
               norm0.xy *= params.normalStrength.x;
               #endif
            #endif

            half4 specFinal = SampleSpecNoBlend(params, norm0, o.Normal);
            o.Emission = albedo.rgb * specFinal.z;
            #if _EMISMAP
            o.Emission = UNITY_SAMPLE_TEX2DARRAY(_Emissive, params.uv0).rgb; 
            #endif

            o.Albedo = albedo.rgb;
            o.Height = albedo.a;
            o.Metallic = specFinal.x;
            o.Smoothness = specFinal.y;
            o.Occlusion = specFinal.w;

            #if _PERTEXAOSTRENGTH
            float aoStr = params.aoStrength.x;
            o.Occlusion = AOContrast(o.Occlusion, aoStr);
            #endif

            return o;
         }

         MegaSplatLayer BlendResults(MegaSplatLayer a, MegaSplatLayer b, half r)
         {
            a.Height = lerp(a.Height, b.Height, r);
            a.Albedo = lerp(a.Albedo, b.Albedo, r);
            #if !_NOSPECNORMAL
            a.Normal = lerp(a.Normal, b.Normal, r);
            #endif
            a.Metallic = lerp(a.Metallic, b.Metallic, r);
            a.Smoothness = lerp(a.Smoothness, b.Smoothness, r);
            a.Occlusion = lerp(a.Occlusion, b.Occlusion, r);
            a.Emission = lerp(a.Emission, b.Emission, r);
            #if _ALPHA || _ALPHATEST
            a.Alpha = lerp(a.Alpha, b.Alpha, r);
            #endif
            return a;
         }

         MegaSplatLayer OverlayResults(MegaSplatLayer splats, MegaSplatLayer macro, half r)
         {
            #if !_SPLATSONTOP
            r = 1 - r;
            #endif

            #if _ALPHA || _ALPHATEST
            splats.Alpha = min(macro.Alpha, splats.Alpha);
            #endif

            #if _MACROMULT2X
               splats.Albedo = lerp(BlendMult2X(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROOVERLAY
               splats.Albedo = lerp(BlendOverlay(macro.Albedo, splats.Albedo), splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #elif _MACROMULT
               splats.Albedo = lerp(splats.Albedo * macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(BlendNormals(macro.Normal, splats.Normal), splats.Normal, r); 
               #endif
               splats.Occlusion = lerp((macro.Occlusion + splats.Occlusion) * 0.5, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #else
               splats.Albedo = lerp(macro.Albedo, splats.Albedo, r);
               #if !_NOSPECNORMAL
               splats.Normal  = lerp(macro.Normal, splats.Normal, r); 
               #endif
               splats.Occlusion = lerp(macro.Occlusion, splats.Occlusion, r);
               BlendSpec(macro, splats, r, splats.Albedo);
            #endif

            return splats;
         }

         MegaSplatLayer BlendDetail(MegaSplatLayer splats, MegaSplatLayer detail, float detailBlend)
         {
            #if _DETAILMAP
            detailBlend *= _DetailTextureStrength;
            #endif
            #if _DETAILMULT2X
               splats.Albedo = lerp(detail.Albedo, BlendMult2X(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILOVERLAY
               splats.Albedo = lerp(detail.Albedo, BlendOverlay(splats.Albedo, detail.Albedo), detailBlend);
            #elif _DETAILMULT
               splats.Albedo = lerp(detail.Albedo, splats.Albedo * detail.Albedo, detailBlend);
            #else
               splats.Albedo = lerp(detail.Albedo, splats.Albedo, detailBlend);
            #endif 

            #if !_NOSPECNORMAL
            splats.Normal = lerp(splats.Normal, BlendNormals(splats.Normal, detail.Normal), detailBlend);
            #endif
            return splats;
         }

         float DoSnowDisplace(float splat_height, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);

            float height = splat_height * _SnowParams.x;
            float erosion = lerp(0, height, _SnowParams.y);
            float snowMask = saturate((snowFade - erosion));
            float snowMask2 = saturate((snowFade - erosion) * 8);
            snowMask *= snowMask * snowMask * snowMask * snowMask * snowMask2;
            snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));

            return snowAmount;
            #endif
            return 0;
         }

         float DoSnow(inout MegaSplatLayer o, float2 uv, float3 worldNormal, half snowHeightFade, float puddleHeight, half surfPorosity, float camDist)
         {
            // could force a branch and avoid texsamples
            #if _SNOW
            uv *= _SnowUVScales.xy;
            half4 snowAlb = tex2D(_SnowDiff, uv);
            half4 snowNsao = tex2D(_SnowNormal, uv);

            #if _SNOWDISTANCERESAMPLE
            float2 snowResampleUV = uv * _SnowDistanceResampleScaleStrengthFade.x;

            if (camDist > _SnowDistanceResampleScaleStrengthFade.z)
               {
                  half4 snowAlb2 = tex2D(_SnowDiff, snowResampleUV);
                  half4 snowNsao2 = tex2D(_SnowNormal, snowResampleUV);
                  float fade = saturate ((camDist - _SnowDistanceResampleScaleStrengthFade.z) / _SnowDistanceResampleScaleStrengthFade.w);
                  fade *= _SnowDistanceResampleScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb, snowAlb2, fade);
                  snowNsao = lerp(snowNsao, snowNsao2, fade);
               }
            #endif

            #if _SNOWDISTANCENOISE
               float2 snowNoiseUV = uv * _SnowDistanceNoiseScaleStrengthFade.x;
               if (camDist > _SnowDistanceNoiseScaleStrengthFade.z)
               {
                  half4 noise = tex2D(_SnowDistanceNoise, uv * _SnowDistanceNoiseScaleStrengthFade.x);
                  float fade = saturate ((camDist - _SnowDistanceNoiseScaleStrengthFade.z) / _SnowDistanceNoiseScaleStrengthFade.w);
                  fade *= _SnowDistanceNoiseScaleStrengthFade.y;

                  snowAlb.rgb = lerp(snowAlb.rgb, BlendMult2X(snowAlb.rgb, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  snowNsao.xy += ((noise.xy-0.25) * fade);
                  #endif
               }
            #endif



            half3 snowNormal = half3(snowNsao.xy * 2 - 1, 1);
            snowNormal.z = sqrt(1 - saturate(dot(snowNormal.xy, snowNormal.xy)));

            float snowAmount, wetnessMask, snowNormalAmount;
            float snowFade = saturate((_SnowAmount - puddleHeight) * snowHeightFade);
            float ao = o.Occlusion;
            if (snowFade > 0)
            {
               float height = o.Height * _SnowParams.x;
               float erosion = lerp(1-ao, (height + ao) * 0.5, _SnowParams.y);
               float snowMask = saturate((snowFade - erosion) * 8);
               snowMask *= snowMask * snowMask * snowMask;
               snowAmount = snowMask * saturate(dot(worldNormal, _SnowUpVector));  // up
               wetnessMask = saturate((_SnowParams.w * (4.0 * snowFade) - (height + snowNsao.b) * 0.5));
               snowAmount = saturate(snowAmount * 8);
               snowNormalAmount = snowAmount * snowAmount;

               float porosity = saturate((((1.0 - o.Smoothness) - 0.5)) / max(surfPorosity, 0.001));
               float factor = lerp(1, 0.4, porosity);

               o.Albedo *= lerp(1.0, factor, wetnessMask);
               o.Normal = lerp(o.Normal, float3(0,0,1), wetnessMask);
               o.Smoothness = lerp(o.Smoothness, 0.8, wetnessMask);

            }
            o.Albedo = lerp(o.Albedo, snowAlb.rgb, snowAmount);
            o.Normal = lerp(o.Normal, snowNormal, snowNormalAmount);
            o.Smoothness = lerp(o.Smoothness, (snowNsao.b) * _SnowParams.z, snowAmount);
            o.Occlusion = lerp(o.Occlusion, snowNsao.w, snowAmount);
            o.Height = lerp(o.Height, snowAlb.a, snowAmount);
            o.Metallic = lerp(o.Metallic, 0.01, snowAmount);
            float crystals = saturate(0.65 - snowNsao.b);
            o.Smoothness = lerp(o.Smoothness, crystals * _SnowParams.z, snowAmount);
            return snowAmount;
            #endif
            return 0;
         }

         half4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten)
         {
            return half4(s.Albedo, 1);
         }

         #if _RAMPLIGHTING
         half3 DoLightingRamp(half3 albedo, float3 normal, float3 emission, half3 lightDir, half atten)
         {
            half NdotL = dot (normal, lightDir);
            half diff = NdotL * 0.5 + 0.5;
            half3 ramp = tex2D (_Ramp, diff.xx).rgb;
            return (albedo * _LightColor0.rgb * ramp * atten) + emission;
         }

         half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) 
         {
            half4 c;
            c.rgb = DoLightingRamp(s.Albedo, s.Normal, s.Emission, lightDir, atten);
            c.a = s.Alpha;
            return c;
         }
         #endif

         void ApplyDetailNoise(inout half3 albedo, inout half3 norm, inout half smoothness, in LayerParams data, float camDist, float3 tpw)
         {
            #if _DETAILNOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv1_y.xy * _DetailNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv2_z.xy * _DetailNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DetailNoiseScaleStrengthFade.x;
               #endif


               if (camDist < _DetailNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DetailNoise, uv0) * tpw.x + 
                     tex2D(_DetailNoise, uv1) * tpw.y + 
                     tex2D(_DetailNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DetailNoise, uv).rgb;
                  #endif

                  float fade = 1.0 - ((_DetailNoiseScaleStrengthFade.z - camDist) / _DetailNoiseScaleStrengthFade.z);
                  fade = 1.0 - (fade*fade);
                  fade *= _DetailNoiseScaleStrengthFade.y;

                  #if _PERTEXNOISESTRENGTH
                  fade *= (data.detailNoiseStrength.x * data.weights.x + data.detailNoiseStrength.y * data.weights.y + data.detailNoiseStrength.z * data.weights.z);
                  #endif

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }

            }
            #endif // detail normal

            #if _DISTANCENOISE
            {
               #if _TRIPLANAR
               float2 uv0 = data.tpuv0_x.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv1 = data.tpuv0_y.xy * _DistanceNoiseScaleStrengthFade.x;
               float2 uv2 = data.tpuv1_z.xy * _DistanceNoiseScaleStrengthFade.x;
               #else
               float2 uv = data.uv0.xy * _DistanceNoiseScaleStrengthFade.x;
               #endif


               if (camDist > _DistanceNoiseScaleStrengthFade.z)
               {
                  #if _TRIPLANAR
                  half3 noise = (tex2D(_DistanceNoise, uv0) * tpw.x + 
                     tex2D(_DistanceNoise, uv1) * tpw.y + 
                     tex2D(_DistanceNoise, uv2) * tpw.z).rgb; 
                  #else
                  half3 noise = tex2D(_DistanceNoise, uv).rgb;
                  #endif

                  float fade = saturate ((camDist - _DistanceNoiseScaleStrengthFade.z) / _DistanceNoiseScaleStrengthFade.w);
                  fade *= _DistanceNoiseScaleStrengthFade.y;

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  #if !_NOSPECNORMAL
                  norm.xy += ((noise.xy-0.25) * fade);
                  #endif
                  #if !_NOSPECNORMAL || _NOSPECTEX
                  smoothness += (abs(noise.x-0.25) * fade);
                  #endif
               }
            }
            #endif
         }

         void DoGlitter(inout MegaSplatLayer splats, half shine, half reflectAmt, float3 wsNormal, float3 wsView, float2 uv)
         {
            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            half3 lightDir = normalize(_WorldSpaceLightPos0);

            half3 viewDir = normalize(wsView);
            half NdotL = saturate(dot(splats.Normal, lightDir));
            lightDir = reflect(lightDir, splats.Normal);
            half specular = saturate(abs(dot(lightDir, viewDir)));


            //float2 offset = float2(viewDir.z, wsNormal.x) + splats.Normal.xy * 0.1;
            float2 offset = splats.Normal * 0.1;
            offset = fmod(offset, 1.0);

            half detail = tex2D(_GlitterTexture, uv * _GlitterParams.xy + offset).x;

            #if _GLITTERMOVES
               float2 uv0 = uv * _GlitterParams.w + _Time.y * _GlitterParams.z;
               float2 uv1 = uv * _GlitterParams.w + _Time.y  * 1.04 * -_GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               half detail3 = tex2D(_GlitterTexture, uv1).y;
               detail *= sqrt(detail2 * detail3);
            #else
               float2 uv0 = uv * _GlitterParams.z;
               half detail2 = tex2D(_GlitterTexture, uv0).y;
               detail *= detail2;
            #endif
            detail *= saturate(splats.Height + 0.5);

            specular = pow(specular, shine) * floor(detail * reflectAmt);

            splats.Smoothness += specular;
            splats.Smoothness = min(splats.Smoothness, 1);
            #endif
         }


         LayerParams InitLayerParams(SplatInput si, float3 values, half2 texScale)
         {
            LayerParams data = NewLayerParams();
            #if _TERRAIN
            int i0 = round(values.x * 255);
            int i1 = round(values.y * 255);
            int i2 = round(values.z * 255);
            #else
            int i0 = round(values.x / max(si.weights.x, 0.00001));
            int i1 = round(values.y / max(si.weights.y, 0.00001));
            int i2 = round(values.z / max(si.weights.z, 0.00001));
            #endif

            #if _TRIPLANAR
            float3 coords = si.triplanarUVW * texScale.x;
            data.tpuv0_x = float3(coords.zy, i0);
            data.tpuv0_y = float3(coords.xz, i0);
            data.tpuv0_z = float3(coords.xy, i0);
            data.tpuv1_x = float3(coords.zy, i1);
            data.tpuv1_y = float3(coords.xz, i1);
            data.tpuv1_z = float3(coords.xy, i1);
            data.tpuv2_x = float3(coords.zy, i2);
            data.tpuv2_y = float3(coords.xz, i2);
            data.tpuv2_z = float3(coords.xy, i2);
            data.mipUV = coords.xz;

            float2 splatUV = si.splatUV * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);

            #else
            float2 splatUV = si.splatUV.xy * texScale.xy;
            data.uv0 = float3(splatUV, i0);
            data.uv1 = float3(splatUV, i1);
            data.uv2 = float3(splatUV, i2);
            data.mipUV = splatUV.xy;
            #endif



            #if _FLOW || _FLOWREFRACTION
            data.flowOn = 0;
            #endif

            #if _DISTANCERESAMPLE
            InitDistanceResample(data, si.camDist.y);
            #endif

            return data;
         }

         MegaSplatLayer DoSurf(inout SplatInput si, MegaSplatLayer macro, float3x3 tangentToWorld)
         {
            #if _ALPHALAYER
            LayerParams mData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.xy);
            #else
            LayerParams mData = InitLayerParams(si, si.valuesMain.xyz, _TexScales.xy);
            #endif

            #if _ALPHAHOLE
            if (mData.uv0.z == _AlphaHoleIdx || mData.uv1.z == _AlphaHoleIdx || mData.uv2.z == _AlphaHoleIdx)
            {
               clip(-1);
            } 
            #endif

            #if _PARALLAX && (_TESSEDGE || _TESSDISTANCE || _LOWPOLY || _ALPHATEST)
            si.viewDir = mul(si.viewDir, tangentToWorld);
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT
            float2 puddleUV = si.macroUV * _PuddleUVScales.xy;
            #elif _PUDDLES
            float2 puddleUV = 0;
            #endif

            #if _PUDDLEFLOW || _PUDDLEREFRACT

            si.waterNormalFoam = float3(0,0,0);
            if (si.puddleHeight > 0 && si.camDist.y < 40)
            {
               float str = 1.0 - ((si.camDist.y - 20) / 20);
               si.waterNormalFoam = GetWaterNormal(puddleUV, si.flowDir) * str;
            }
            #endif

            SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

            #if _FLOWREFRACTION
            // see through
            //sampleBottom = sampleBottom || mData.flowOn > 0;
            #endif

            half porosity = _GlobalPorosityWetness.x;
            #if _PERTEXMATPARAMS
            porosity = mData.porosity.x * mData.weights.x + mData.porosity.y * mData.weights.y + mData.porosity.z * mData.weights.z;
            #endif

            #if _TWOLAYER
               LayerParams sData = InitLayerParams(si, si.valuesSecond.xyz, _TexScales.zw);

               #if _ALPHAHOLE
               if (sData.uv0.z == _AlphaHoleIdx || sData.uv1.z == _AlphaHoleIdx || sData.uv2.z == _AlphaHoleIdx)
               {
                  clip(-1);
               } 
               #endif

               sData.layerBlend = si.layerBlend;
               SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(sData.uv0, si.flowDir, _FlowSpeed * sData.flowIntensity.x, _FlowIntensity, sData.fuv0a, sData.fuv0b, sData.flowInterps.x);
                  Flow(sData.uv1, si.flowDir, _FlowSpeed * sData.flowIntensity.y, _FlowIntensity, sData.fuv1a, sData.fuv1b, sData.flowInterps.y);
                  Flow(sData.uv2, si.flowDir, _FlowSpeed * sData.flowIntensity.z, _FlowIntensity, sData.fuv2a, sData.fuv2b, sData.flowInterps.z);
                  mData.flowOn = 0;
               #endif

               MegaSplatLayer second = SampleLayer(sData, si);

               #if _FLOWREFRACTION
                  float hMod = FlowRefract(second, mData, sData, si.weights);
               #endif
            #else // _TWOLAYER

               #if (_FLOW || _FLOWREFRACTION)
                  Flow(mData.uv0, si.flowDir, _FlowSpeed * mData.flowIntensity.x, _FlowIntensity, mData.fuv0a, mData.fuv0b, mData.flowInterps.x);
                  Flow(mData.uv1, si.flowDir, _FlowSpeed * mData.flowIntensity.y, _FlowIntensity, mData.fuv1a, mData.fuv1b, mData.flowInterps.y);
                  Flow(mData.uv2, si.flowDir, _FlowSpeed * mData.flowIntensity.z, _FlowIntensity, mData.fuv2a, mData.fuv2b, mData.flowInterps.z);
               #endif
            #endif

            #if _NOBLENDBOTTOM
               MegaSplatLayer splats = SampleLayerNoBlend(mData, si);
            #else
               MegaSplatLayer splats = SampleLayer(mData, si);
            #endif

            #if _TWOLAYER
               // blend layers together..
               float hfac = HeightBlend(splats.Height, second.Height, sData.layerBlend, _Contrast);
               #if _FLOWREFRACTION
                  hfac *= hMod;
               #endif
               splats = BlendResults(splats, second, hfac);
               porosity = lerp(porosity, 
                     sData.porosity.x * sData.weights.x + 
                     sData.porosity.y * sData.weights.y + 
                     sData.porosity.z * sData.weights.z,
                     hfac);
            #endif

            #if _GEOMAP
            float2 geoUV = float2(0, si.worldPos.y * _GeoParams.y + _GeoParams.z);
            half4 geoTex = tex2D(_GeoTex, geoUV);
            splats.Albedo = lerp(splats.Albedo, BlendMult2X(splats.Albedo, geoTex), _GeoParams.x * geoTex.a);
            #endif

            half macroBlend = 1;
            #if _USEMACROTEXTURE
            macroBlend = saturate(_MacroTextureStrength * si.camDist.x);
            #endif

            #if _DETAILMAP
               float dist = si.camDist.y;
               if (dist > _DistanceFades.w)
               {
                  MegaSplatLayer o = (MegaSplatLayer)0;
                  UNITY_INITIALIZE_OUTPUT(MegaSplatLayer,o);
                  #if _USEMACROTEXTURE
                  splats = OverlayResults(splats, macro, macroBlend);
                  #endif
                  o.Albedo = splats.Albedo;
                  o.Normal = splats.Normal;
                  o.Emission = splats.Emission;
                  o.Occlusion = splats.Occlusion;
                  #if !_RAMPLIGHTING
                  o.Metallic = splats.Metallic;
                  o.Smoothness = splats.Smoothness;
                  #endif
                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_Final(si, o);
                  #endif
                  return o;
               }

               LayerParams sData = InitLayerParams(si, si.valuesMain, _TexScales.zw);
               MegaSplatLayer second = SampleDetail(mData.weights, si.viewDir, sData, si.triplanarBlend);   // use prev weights for detail

               float detailBlend = 1.0 - saturate((dist - _DistanceFades.z) / (_DistanceFades.w - _DistanceFades.z));
               splats = BlendDetail(splats, second, detailBlend); 
            #endif

            ApplyDetailNoise(splats.Albedo, splats.Normal, splats.Smoothness, mData, si.camDist.y, si.triplanarBlend);

            float3 worldNormal = float3(0,0,1);
            #if _SNOW || _RAINDROPFLATONLY
            worldNormal = mul(tangentToWorld, normalize(splats.Normal));
            #endif

            #if _SNOWGLITTER || _PERTEXGLITTER || _PUDDLEGLITTER
            half glitterShine = 0;
            half glitterReflect = 0;
            #endif

            #if _PERTEXGLITTER
            glitterReflect = mData.perTexGlitterReflect.x * mData.weights.x + mData.perTexGlitterReflect.y * mData.weights.y + mData.perTexGlitterReflect.z * mData.weights.z;
               #if _TWOLAYER || _ALPHALAYER
               float glitterReflect2 = sData.perTexGlitterReflect.x * sData.weights.x + sData.perTexGlitterReflect.y * sData.weights.y + sData.perTexGlitterReflect.z * sData.weights.z;
               glitterReflect = lerp(glitterReflect, glitterReflect2, hfac);
               #endif
            glitterReflect *= 14;
            glitterShine = 1.5;
            #endif


            float pud = 0;
            #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT
               if (si.puddleHeight > 0)
               {
                  pud = DoPuddles(splats, puddleUV, si.waterNormalFoam, si.puddleHeight, si.flowDir, porosity, worldNormal);
               }
            #endif

            #if _LAVA
               float2 lavaUV = si.macroUV * _LavaUVScale.xy;


               if (si.puddleHeight > 0)
               {
                  pud = DoLava(splats, lavaUV, si.puddleHeight, si.flowDir);
               }
            #endif

            #if _PUDDLEGLITTER
            glitterShine = lerp(glitterShine, _GlitterSurfaces.z, pud);
            glitterReflect = lerp(glitterReflect, _GlitterSurfaces.w, pud);
            #endif


            #if _SNOW && !_SNOWOVERMACRO
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOW && _SNOWOVERMACRO
            half preserveAO = splats.Occlusion;
            #endif

            #if _WETNESS
            WaterBRDF(splats.Albedo, splats.Smoothness, splats.Metallic, max( si.wetness, _GlobalPorosityWetness.y) * _MaxWetness, porosity); 
            #endif


            #if _ALPHALAYER
            half blend = HeightBlend(splats.Height, 1 - macro.Height, si.layerBlend * macroBlend, _Contrast);
            splats = OverlayResults(splats, macro, blend);
            #elif _USEMACROTEXTURE
            splats = OverlayResults(splats, macro, macroBlend);
            #endif

            #if _SNOW && _SNOWOVERMACRO
               splats.Occlusion = preserveAO;
               float snwAmt = DoSnow(splats, si.macroUV, worldNormal, si.snowHeightFade, pud, porosity, si.camDist.y);
               #if _SNOWGLITTER
               glitterShine = lerp(glitterShine, _GlitterSurfaces.x, snwAmt);
               glitterReflect = lerp(glitterReflect, _GlitterSurfaces.y, snwAmt);
               #endif
            #endif

            #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
            DoGlitter(splats, glitterShine, glitterReflect, si.wsNormal, si.wsView, si.macroUV);
            #endif

            #if _CUSTOMUSERFUNCTION
            CustomMegaSplatFunction_Final(si, splats);
            #endif

            return splats;
         }

         #if _DEBUG_OUTPUT_SPLATDATA
         float3 DebugSplatOutput(SplatInput si)
         {
            float3 data = float3(0,0,0);
            int i0 = round(si.valuesMain.x / max(si.weights.x, 0.00001));
            int i1 = round(si.valuesMain.y / max(si.weights.y, 0.00001));
            int i2 = round(si.valuesMain.z / max(si.weights.z, 0.00001));

            #if _TWOLAYER || _ALPHALAYER
            int i3 = round(si.valuesSecond.x / max(si.weights.x, 0.00001));
            int i4 = round(si.valuesSecond.y / max(si.weights.y, 0.00001));
            int i5 = round(si.valuesSecond.z / max(si.weights.z, 0.00001));
            data.z = si.layerBlend;
            #endif

            if (si.weights.x > si.weights.y && si.weights.x > si.weights.z)
            {
               data.x = i0 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i3 / 255.0;
               #endif
            }
            else if (si.weights.y > si.weights.x && si.weights.y > si.weights.z)
            {
               data.x = i1 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i4 / 255.0;
               #endif
            }
            else
            {
               data.x = i2 / 255.0;
               #if _TWOLAYER || _ALPHALAYER
               data.y = i5 / 255.0;
               #endif
            }
            return data;
         }
         #endif

 
            UnityLight AdditiveLight (half3 normalWorld, half3 lightDir, half atten)
            {
               UnityLight l;

               l.color = _LightColor0.rgb;
               l.dir = lightDir;
               #ifndef USING_DIRECTIONAL_LIGHT
                  l.dir = normalize(l.dir);
               #endif
               l.ndotl = LambertTerm (normalWorld, l.dir);

               // shadow the light
               l.color *= atten;
               return l;
            }

            UnityLight MainLight (half3 normalWorld)
            {
               UnityLight l;
               #ifdef LIGHTMAP_OFF
                  
                  l.color = _LightColor0.rgb;
                  l.dir = _WorldSpaceLightPos0.xyz;
                  l.ndotl = LambertTerm (normalWorld, l.dir);
               #else
                  // no light specified by the engine
                  // analytical light might be extracted from Lightmap data later on in the shader depending on the Lightmap type
                  l.color = half3(0.f, 0.f, 0.f);
                  l.ndotl  = 0.f;
                  l.dir = half3(0.f, 0.f, 0.f);
               #endif

               return l;
            }

            inline half4 VertexGIForward(float2 uv1, float2 uv2, float3 posWorld, half3 normalWorld)
            {
               half4 ambientOrLightmapUV = 0;
               // Static lightmaps
               #ifdef LIGHTMAP_ON
                  ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                  ambientOrLightmapUV.zw = 0;
               // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
               #elif UNITY_SHOULD_SAMPLE_SH
                  #ifdef VERTEXLIGHT_ON
                     // Approximated illumination from non-important point lights
                     ambientOrLightmapUV.rgb = Shade4PointLights (
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, posWorld, normalWorld);
                  #endif

                  ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);     
               #endif

               #ifdef DYNAMICLIGHTMAP_ON
                  ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
               #endif

               return ambientOrLightmapUV;
            }

            void LightPBRDeferred(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic,
                           half occlusion, half alpha, float3 viewDir,
                           inout half3 indirectDiffuse, inout half3 indirectSpecular, inout half3 diffuseColor, inout half3 specularColor)
            {
               #if _PASSDEFERRED
               half lightAtten = 1;
               half roughness = 1 - smoothness;

               UnityLight light = MainLight (normalDirection);

               UnityGIInput d;
               UNITY_INITIALIZE_OUTPUT(UnityGIInput, d);
               d.light = light;
               d.worldPos = i.posWorld.xyz;
               d.worldViewDir = viewDir;
               d.atten = lightAtten;
               #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                  d.ambient = 0;
                  d.lightmapUV = i.ambientOrLightmapUV;
               #else
                  d.ambient = i.ambientOrLightmapUV.rgb;
                  d.lightmapUV = 0;
               #endif
               d.boxMax[0] = unity_SpecCube0_BoxMax;
               d.boxMin[0] = unity_SpecCube0_BoxMin;
               d.probePosition[0] = unity_SpecCube0_ProbePosition;
               d.probeHDR[0] = unity_SpecCube0_HDR;
               d.boxMax[1] = unity_SpecCube1_BoxMax;
               d.boxMin[1] = unity_SpecCube1_BoxMin;
               d.probePosition[1] = unity_SpecCube1_ProbePosition;
               d.probeHDR[1] = unity_SpecCube1_HDR;

               UnityGI gi = UnityGlobalIllumination(d, occlusion, 1.0 - smoothness, normalDirection );

               specularColor = metallic.xxx;
               float specularMonochrome;
               diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, specularMonochrome );

               indirectSpecular = (gi.indirect.specular);
               float NdotV = max(0.0,dot( normalDirection, viewDir ));
               specularMonochrome = 1.0-specularMonochrome;
               half grazingTerm = saturate( smoothness + specularMonochrome );
               indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
               indirectDiffuse = half3(0,0,0);
               indirectDiffuse += gi.indirect.diffuse;
               indirectDiffuse *= occlusion;

               #endif
            }


            half4 LightPBR(VertexOutput i, half3 albedo, half3 normalDirection, half3 emission, half smoothness, half metallic, 
                            half occlusion, half alpha, float3 viewDir, float4 ambientOrLightmapUV)
            {
                

                #if _PASSFORWARDBASE
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG(i.fogCoord, ramped);
                   return ramped;
                }
                #endif

                UnityLight light = MainLight (normalDirection);

                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDir;
                d.atten = lightAtten;
                #if LIGHTMAP_ON || DYNAMICLIGHTMAP_ON
                    d.ambient = 0;
                    d.lightmapUV = i.ambientOrLightmapUV;
                #else
                    d.ambient = i.ambientOrLightmapUV;
                    d.lightmapUV = 0;
                #endif

                d.boxMax[0] = unity_SpecCube0_BoxMax;
                d.boxMin[0] = unity_SpecCube0_BoxMin;
                d.probePosition[0] = unity_SpecCube0_ProbePosition;
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.boxMax[1] = unity_SpecCube1_BoxMax;
                d.boxMin[1] = unity_SpecCube1_BoxMin;
                d.probePosition[1] = unity_SpecCube1_ProbePosition;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = roughness;
                ugls_en_data.reflUVW = reflect( -viewDir, normalDirection );
                UnityGI gi = UnityGlobalIllumination(d, occlusion, normalDirection, ugls_en_data );

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( albedo, specularColor, specularColor, oneMinusReflectivity );
                

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, gi.light, gi.indirect);
                c.rgb += UNITY_BRDF_GI (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, occlusion, gi);
                c.rgb += emission;
                c.a = alpha;
                UNITY_APPLY_FOG(i.fogCoord, c.rgb);
                return c;

                #elif _PASSFORWARDADD
                half lightAtten = LIGHT_ATTENUATION(i);
                half roughness = 1 - smoothness;

                #if _RAMPLIGHTING
                {
                   float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                   half4 ramped = half4(DoLightingRamp(albedo * occlusion, normalDirection, emission, lightDirection, lightAtten), 1);
                   UNITY_APPLY_FOG_COLOR(i.fogCoord, ramped.rgb, half4(0,0,0,0));
                   return ramped;
                }
                #endif

                half3 specularColor = metallic.xxx;
                half oneMinusReflectivity;
                half3 diffuseColor = albedo;
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, oneMinusReflectivity );

                UnityLight light = AdditiveLight (normalDirection, normalDirection, lightAtten);
                UnityIndirect noIndirect = (UnityIndirect)0;
                noIndirect.diffuse = 0;
                noIndirect.specular = 0;

                half4 c = UNITY_BRDF_PBS (diffuseColor, specularColor, oneMinusReflectivity, smoothness, normalDirection, viewDir, light, noIndirect);
   
                UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
                c.a = alpha;
                return c;

                #endif
                return half4(1, 1, 0, 0);
            }

            float4 _SplatControl_TexelSize;

            struct VertexInput 
            {
                float4 vertex        : POSITION;
                float3 normal        : NORMAL;
                float2 texcoord0     : TEXCOORD0;
                #if !_PASSSHADOWCASTER && !_PASSMETA
                    float2 texcoord1 : TEXCOORD1;
                    float2 texcoord2 : TEXCOORD2;
                #endif
            };

            VirtualMapping GetMapping(VertexOutput i, sampler2D splatControl, sampler2D paramControl)
            {
               float2 texSize = _SplatControl_TexelSize.zw;
               float2 stp = _SplatControl_TexelSize.xy;
               // scale coords so we can take floor/frac to construct a cell
               float2 stepped = i.coords.xy * texSize;
               float2 uvBottom = floor(stepped);
               float2 uvFrac = frac(stepped);
               uvBottom /= texSize;

               float2 center = stp * 0.5;
               uvBottom += center;

               // construct uv/positions of triangle based on our interpolation point
               float2 cuv0, cuv1, cuv2;
               // make virtual triangle
               if (uvFrac.x > uvFrac.y)
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(stp.x, 0);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }
               else
               {
                  cuv0 = uvBottom;
                  cuv1 = uvBottom + float2(0, stp.y);
                  cuv2 = uvBottom + float2(stp.x, stp.y);
               }

               float2 uvBaryFrac = uvFrac * stp + uvBottom;
               float3 weights = Barycentric(uvBaryFrac, cuv0, cuv1, cuv2);
               VirtualMapping m = (VirtualMapping)0;
               m.weights = weights;
               m.c0 = tex2Dlod(splatControl, float4(cuv0, 0, 0));
               m.c1 = tex2Dlod(splatControl, float4(cuv1, 0, 0));
               m.c2 = tex2Dlod(splatControl, float4(cuv2, 0, 0));

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _WETNESS || _FLOW || _FLOWREFRACTION || _LAVA
               fixed4 p0 = tex2Dlod(paramControl, float4(cuv0, 0, 0));
               fixed4 p1 = tex2Dlod(paramControl, float4(cuv1, 0, 0));
               fixed4 p2 = tex2Dlod(paramControl, float4(cuv2, 0, 0));
               m.param = p0 * weights.x + p1 * weights.y + p2 * weights.z;
               #endif
               return m;
            }

            SplatInput ToSplatInput(VertexOutput i, VirtualMapping m)
            {
               SplatInput o = (SplatInput)0;
               UNITY_INITIALIZE_OUTPUT(SplatInput,o);

               o.camDist = i.camDist;
               o.splatUV = i.coords;
               o.macroUV = i.coords;
               #if _SECONDUV
               o.macroUV = i.macroUV;
               #endif
               o.weights = m.weights;


               o.valuesMain = float3(m.c0.r, m.c1.r, m.c2.r);
               #if _TWOLAYER || _ALPHALAYER
               o.valuesSecond = float3(m.c0.g, m.c1.g, m.c2.g);
               o.layerBlend = m.c0.b * o.weights.x + m.c1.b * o.weights.y + m.c2.b * o.weights.z;
               #endif

               #if _TRIPLANAR
               o.triplanarUVW = i.triplanarUVW;
               o.triplanarBlend = i.extraData.xyz;
               #endif

               #if _FLOW || _FLOWREFRACTION || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.flowDir = m.param.xy;
               #endif

               #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
               o.puddleHeight = m.param.a;
               #endif

               #if _WETNESS
               o.wetness = m.param.b;
               #endif

               #if _GEOMAP
               o.worldPos = i.posWorld;
               #endif

               return o;
            }

            LayerParams GetMainParams(VertexOutput i, inout VirtualMapping m, half2 texScale)
            {
               
               int i0 = (int)(m.c0.r * 255);
               int i1 = (int)(m.c1.r * 255);
               int i2 = (int)(m.c2.r * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               data.layerBlend = m.weights.x * m.c0.b + m.weights.y * m.c1.b + m.weights.z * m.c2.b;

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;
            }

            LayerParams GetSecondParams(VertexOutput i, VirtualMapping m, half2 texScale)
            {
               int i0 = (int)(m.c0.g * 255);
               int i1 = (int)(m.c1.g * 255);
               int i2 = (int)(m.c2.g * 255);

               LayerParams data = NewLayerParams();

               float2 splatUV = i.coords.xy * texScale.xy;
               data.uv0 = float3(splatUV, i0);
               data.uv1 = float3(splatUV, i1);
               data.uv2 = float3(splatUV, i2);


               #if _TRIPLANAR
               float3 coords = i.triplanarUVW.xyz * texScale.x;
               data.tpuv0_x = float3(coords.zy, i0);
               data.tpuv0_y = float3(coords.xz, i0);
               data.tpuv0_z = float3(coords.xy, i0);
               data.tpuv1_x = float3(coords.zy, i1);
               data.tpuv1_y = float3(coords.xz, i1);
               data.tpuv1_z = float3(coords.xy, i1);
               data.tpuv2_x = float3(coords.zy, i2);
               data.tpuv2_y = float3(coords.xz, i2);
               data.tpuv2_z = float3(coords.xy, i2);
               #endif

               #if _FLOW || _FLOWREFRACTION
               data.flowOn = 0;
               #endif

               return data;   
            }


            VertexOutput NoTessVert(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;

               o.tangent.xyz = cross(v.normal, float3(0,0,1));
               float4 tangent = float4(o.tangent, 1);
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(o.tangent, 1);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  o.tangent = tangent.xyz;
                  #endif
               }

               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(o.tangent, 1);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  o.tangent = tangent.xyz;
                  #endif
               }

               UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

               o.normal = UnityObjectToWorldNormal(v.normal);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

               o.coords.xy = v.texcoord0;
               #if _SECONDUV
               o.macroUV = v.texcoord0;
               o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
               #endif

               o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);


               #if !_PASSSHADOWCASTER && !_PASSMETA
               o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
               #endif

               float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
               o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
               float3 viewSpace = UnityObjectToViewPos(v.vertex);
               o.camDist.y = length(viewSpace.xyz);
               #if _TRIPLANAR
                  float3 norm = v.normal;
                  #if _TRIPLANAR_WORLDSPACE
                  o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                  norm = normalize(mul(unity_ObjectToWorld, norm));
                  #else
                  o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                  #endif
                  o.extraData.xyz = pow(abs(norm), _TriplanarContrast);
               #endif


               o.bitangent = normalize(cross(o.normal, o.tangent) * -1);  
               

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #elif !_PASSMETA && !_PASSDEFERRED
               UNITY_TRANSFER_FOG(o,o.pos);
               TRANSFER_VERTEX_TO_FRAGMENT(o)
               #endif
               return o;
            }


            #if _TESSDISTANCE || _TESSEDGE
            VertexOutput NoTessShadowVertBiased(VertexInput v)
            {
               VertexOutput o = (VertexOutput)0;
               {
                  #if _CUSTOMUSERFUNCTION
                  float4 tangent = float4(0,0,0,0);
                  CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, tangent, v.texcoord0.xy);
                  #endif
               }
               {
                  #if _USECURVEDWORLD
                  float4 tangent = float4(0,0,0,0);
                  V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
                  #endif
                  UNITY_INITIALIZE_OUTPUT(VertexOutput,o);
               }
             
               o.normal = UnityObjectToWorldNormal(v.normal);
               v.vertex.xyz -= o.normal * _TessData1.yyy * half3(0.5, 0.5, 0.5);
               o.pos = UnityObjectToClipPos(v.vertex);
               o.coords = v.texcoord0;

               #if _PASSSHADOWCASTER
               TRANSFER_SHADOW_CASTER(o)
               #endif

               return o;
            }
            #endif

            #ifdef UNITY_CAN_COMPILE_TESSELLATION
            #if _TESSDISTANCE || _TESSEDGE 
            struct TessVertex 
            {
                 float4 vertex       : INTERNALTESSPOS;
                 float3 normal       : NORMAL;
                 float2 coords       : TEXCOORD0;      // uv, or triplanar UV
                 #if _TRIPLANAR
                 float3 triplanarUVW : TEXCOORD1;
                 float4 extraData    : TEXCOORD2;
                 #endif
                 float4 camDist      : TEXCOORD3;      // distance from camera (for fades) and fog

                 float3 posWorld     : TEXCOORD4;
                 float4 tangent      : TEXCOORD5;
                 float2 macroUV      : TEDCOORD6;
                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    LIGHTING_COORDS(7,8)
                    UNITY_FOG_COORDS(9)
                 #endif
                 float4 ambientOrLightmapUV : TEXCOORD10;
 
             };


            VertexOutput vert (TessVertex v) 
            {
                VertexOutput o = (VertexOutput)0;

                UNITY_INITIALIZE_OUTPUT(VertexOutput,o);

                #if _CUSTOMUSERFUNCTION
                CustomMegaSplatFunction_PreVertex(v.vertex, v.normal, v.tangent, v.coords.xy);
                #endif
                #if _USECURVEDWORLD
                V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                #endif

                o.ambientOrLightmapUV = v.ambientOrLightmapUV;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangent = normalize(cross(o.normal, o.tangent) * v.tangent.w);  
                o.pos = UnityObjectToClipPos(v.vertex);
                o.coords = v.coords;
                o.camDist = v.camDist;
                o.posWorld = v.posWorld;
                #if _SECONDUV
                o.macroUV = v.macroUV;
                #endif

                #if _TRIPLANAR
                o.triplanarUVW = v.triplanarUVW;
                o.extraData = v.extraData;
                #endif

                #if _PASSSHADOWCASTER
                TRANSFER_SHADOW_CASTER(o)
                #elif !_PASSMETA && !_PASSDEFERRED
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                #endif

                return o;
            }


                
             struct OutputPatchConstant {
                 float edge[3]         : SV_TessFactor;
                 float inside          : SV_InsideTessFactor;
                 float3 vTangent[4]    : TANGENT;
                 float2 vUV[4]         : TEXCOORD;
                 float3 vTanUCorner[4] : TANUCORNER;
                 float3 vTanVCorner[4] : TANVCORNER;
                 float4 vCWts          : TANWEIGHTS;
             };

             TessVertex tessvert (VertexInput v) 
             {
                 TessVertex o;
                 UNITY_INITIALIZE_OUTPUT(TessVertex,o);
                 #if _USECURVEDWORLD
                 V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
                 #endif

                 o.vertex = v.vertex;
                 o.normal = v.normal;
                 o.coords.xy = v.texcoord0;
                 o.normal = UnityObjectToWorldNormal(v.normal);
                 o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

                 float4 tangent = float4(o.tangent.xyz, 1);
                 #if _SECONDUV
                 o.macroUV = v.texcoord0;
                 o.macroUV = ProjectUV2(v.vertex, o.macroUV.xy, o.posWorld, o.normal, tangent);
                 #endif

                 o.coords.xy = ProjectUVs(v.vertex, o.coords.xy, o.posWorld, o.normal, tangent);



                 #if !_PASSSHADOWCASTER && !_PASSMETA
                 o.ambientOrLightmapUV = VertexGIForward(v.texcoord1.xy, v.texcoord2.xy, o.posWorld, o.normal);
                 #endif

                 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
                 o.camDist.x = 1.0 - saturate((dist - _DistanceFades.x) / (_DistanceFades.y - _DistanceFades.x));
                 float3 viewSpace = UnityObjectToViewPos(v.vertex);
                 o.camDist.y = length(viewSpace.xyz);
                 #if _TRIPLANAR
                    #if _TRIPLANAR_WORLDSPACE
                    o.triplanarUVW.xyz = o.posWorld.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #else
                    o.triplanarUVW.xyz = v.vertex.xyz * _TriplanarTexScale + _TriplanarOffset;
                    #endif
                    o.extraData.xyz = pow(abs(v.normal), _TriplanarContrast);
                 #endif

                 o.tangent.xyz = cross(v.normal, float3(0,0,1));
                 o.tangent.w = -1;

                 float tessFade = saturate((dist - _TessData2.x) / (_TessData2.y - _TessData2.x));
                 tessFade *= tessFade;
                 o.camDist.w = 1 - tessFade;

                 return o;
             }

             void displacement (inout TessVertex i)
             {
                  VertexOutput o = vert(i);
                  float3 viewDir = float3(0,0,1);

                  VirtualMapping mapping = GetMapping(o, _SplatControl, _SplatParams);
                  LayerParams mData = GetMainParams(o, mapping, _TexScales.xy);
                  SamplePerTex(_PropertyTex, mData, _PerTexScaleRange);

                  half3 extraData = float3(0,0,0);
                  #if _TRIPLANAR
                  extraData = o.extraData.xyz;
                  #endif

                  #if _TWOLAYER || _DETAILMAP
                  LayerParams sData = GetSecondParams(o, mapping, _TexScales.zw);
                  sData.layerBlend = mData.layerBlend;
                  SamplePerTex(_PropertyTex, sData, _PerTexScaleRange);
                  float second = SampleLayerHeight(mapping.weights, viewDir, sData, extraData.xyz, _TessData1.z, _TessData2.z);
                  #endif

                  float splats = SampleLayerHeight(mapping.weights, viewDir, mData, extraData.xyz, _TessData1.z, _TessData2.z);

                  #if _TWOLAYER
                     // blend layers together..
                     float hfac = HeightBlend(splats, second, sData.layerBlend, _TessData2.z);
                     splats = lerp(splats, second, hfac);
                  #endif

                  half upBias = _TessData2.w;
                  #if _PERTEXDISPLACEPARAMS
                  float3 upBias3 = mData.upBias;
                     #if _TWOLAYER
                        upBias3 = lerp(upBias3, sData.upBias, hfac);
                     #endif
                  upBias = upBias3.x * mapping.weights.x + upBias3.y * mapping.weights.y + upBias3.z * mapping.weights.z;
                  #endif

                  #if _PUDDLES || _PUDDLEFLOW || _PUDDLEREFRACT || _LAVA
                     #if _PUDDLESPUSHTERRAIN
                     splats = max(splats - mapping.param.a, 0);
                     #else
                     splats = max(splats, mapping.param.a);
                     #endif
                  #endif

                  #if _TESSCENTERBIAS
                  splats -= 0.5;
                  #endif

                  #if _SNOW
                  float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                  float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                  float snowHeightFade = saturate((worldPos.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
                  splats += DoSnowDisplace(splats, i.coords.xy, worldNormal, snowHeightFade, mapping.param.a);
                  #endif

                  float3 offset = (lerp(i.normal, float3(0,1,0), upBias) * (i.camDist.w * _TessData1.y * splats));

                  #if _TESSDAMPENING
                  offset *= (mapping.c0.a * mapping.weights.x + mapping.c1.a * mapping.weights.y + mapping.c2.a * mapping.weights.z);
                  #endif

                  #if _CUSTOMUSERFUNCTION
                  CustomMegaSplatFunction_PostDisplacement(i.vertex.xyz, offset, i.normal, i.tangent, i.coords.xy);
                  #else
                  i.vertex.xyz += offset;
                  #endif

             }

             #if _TESSEDGE
             float4 Tessellation(TessVertex v, TessVertex v1, TessVertex v2)
             {
                 return UnityEdgeLengthBasedTess(v.vertex, v1.vertex, v2.vertex, _TessData1.w);
             }
             #elif _TESSDISTANCE
             float4 Tessellation (TessVertex v0, TessVertex v1, TessVertex v2) 
             {
                return MegaSplatDistanceBasedTess( v0.camDist.w, v1.camDist.w, v2.camDist.w, _TessData1.x );
             }
             #endif

             OutputPatchConstant hullconst (InputPatch<TessVertex,3> v) {
                 OutputPatchConstant o = (OutputPatchConstant)0;
                 float4 ts = Tessellation( v[0], v[1], v[2] );
                 o.edge[0] = ts.x;
                 o.edge[1] = ts.y;
                 o.edge[2] = ts.z;
                 o.inside = ts.w;
                 return o;
             }
             [UNITY_domain("tri")]
             [UNITY_partitioning("fractional_odd")]
             [UNITY_outputtopology("triangle_cw")]
             [UNITY_patchconstantfunc("hullconst")]
             [UNITY_outputcontrolpoints(3)]
             TessVertex hull (InputPatch<TessVertex,3> v, uint id : SV_OutputControlPointID) 
             {
                 return v[id];
             }

             [UNITY_domain("tri")]
             VertexOutput domain (OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> vi, float3 bary : SV_DomainLocation) 
             {
                 TessVertex v = (TessVertex)0;
                 v.vertex =         vi[0].vertex * bary.x +       vi[1].vertex * bary.y +       vi[2].vertex * bary.z;
                 v.normal =         vi[0].normal * bary.x +       vi[1].normal * bary.y +       vi[2].normal * bary.z;
                 v.coords =         vi[0].coords * bary.x +       vi[1].coords * bary.y +       vi[2].coords * bary.z;
                 v.camDist =        vi[0].camDist * bary.x +      vi[1].camDist * bary.y +      vi[2].camDist * bary.z;
                 #if _TRIPLANAR
                 v.extraData =      vi[0].extraData * bary.x +    vi[1].extraData * bary.y +    vi[2].extraData * bary.z;
                 v.triplanarUVW =   vi[0].triplanarUVW * bary.x + vi[1].triplanarUVW * bary.y + vi[2].triplanarUVW * bary.z; 
                 #endif
                 v.tangent =        vi[0].tangent * bary.x +      vi[1].tangent * bary.y +      vi[2].tangent * bary.z;
                 v.macroUV =        vi[0].macroUV * bary.x +      vi[1].macroUV * bary.y +      vi[2].macroUV * bary.z;
                 v.posWorld =       vi[0].posWorld * bary.x +     vi[1].posWorld * bary.y +     vi[2].posWorld * bary.z;

                 #if !_PASSMETA && !_PASSSHADOWCASTER && !_PASSDEFERRED
                    #if FOG_LINEAR || FOG_EXP || FOG_EXP2
                       v.fogCoord = vi[0].fogCoord * bary.x + vi[1].fogCoord * bary.y + vi[2].fogCoord * bary.z;
                    #endif
                    #if  SPOT || POINT_COOKIE || DIRECTIONAL_COOKIE 
                       v._LightCoord = vi[0]._LightCoord * bary.x + vi[1]._LightCoord * bary.y + vi[2]._LightCoord * bary.z; 
                       #if (SHADOWS_DEPTH && SPOT) || SHADOWS_CUBE || SHADOWS_DEPTH
                          v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y * vi[2]._ShadowCoord * bary.z; 
                       #endif
                    #elif DIRECTIONAL && (SHADOWS_CUBE || SHADOWS_DEPTH)
                       v._ShadowCoord = vi[0]._ShadowCoord * bary.x + vi[1]._ShadowCoord * bary.y + vi[2]._ShadowCoord * bary.z; 
                    #endif
                 #endif
                 v.ambientOrLightmapUV = vi[0].ambientOrLightmapUV * bary.x + vi[1].ambientOrLightmapUV * bary.y + vi[2].ambientOrLightmapUV * bary.z;

                 #if _TESSPHONG
                 float3 p = v.vertex.xyz;

                 // Calculate deltas to project onto three tangent planes
                 float3 p0 = dot(vi[0].vertex.xyz - p, vi[0].normal) * vi[0].normal;
                 float3 p1 = dot(vi[1].vertex.xyz - p, vi[1].normal) * vi[1].normal;
                 float3 p2 = dot(vi[2].vertex.xyz - p, vi[2].normal) * vi[2].normal;

                 // Lerp between projection vectors
                 float3 vecOffset = bary.x * p0 + bary.y * p1 + bary.z * p2;

                 // Add a fraction of the offset vector to the lerped position
                 p += 0.5 * vecOffset;

                 v.vertex.xyz = p;
                 #endif

                 displacement(v);
                 VertexOutput o = vert(v);
                 return o;
             }
            #endif
            #endif

            struct LightingTerms
            {
               half3 Albedo;
               half3 Normal;
               half  Smoothness;
               half  Metallic;
               half  Occlusion;
               half3 Emission;
               #if _ALPHA || _ALPHATEST
               half Alpha;
               #endif
            };

            void Splat(VertexOutput i, inout LightingTerms o, float3 viewDir, float3x3 tangentTransform)
            {
               VirtualMapping mapping = GetMapping(i, _SplatControl, _SplatParams);
               SplatInput si = ToSplatInput(i, mapping);
               si.viewDir = viewDir;
               #if _SNOWGLITTER || _PUDDLEGLITTER || _PERTEXGLITTER
               si.wsView = viewDir;
               #endif

               MegaSplatLayer macro = (MegaSplatLayer)0;
               #if _SNOW
               float snowHeightFade = saturate((i.posWorld.y - _SnowHeightRange.x) / max(_SnowHeightRange.y, 0.001));
               #endif

               #if _USEMACROTEXTURE || _ALPHALAYER
                  float2 muv = i.coords.xy;

                  #if _SECONDUV
                  muv = i.macroUV.xy;
                  #endif
                  macro = SampleMacro(muv);
                  #if _SNOW && _SNOWOVERMACRO

                  DoSnow(macro, muv, mul(tangentTransform, normalize(macro.Normal)), snowHeightFade, 0, _GlobalPorosityWetness.x, i.camDist.y);
                  #endif

                  #if _DISABLESPLATSINDISTANCE
                  if (i.camDist.x <= 0.0)
                  {
                     #if _CUSTOMUSERFUNCTION
                     CustomMegaSplatFunction_Final(si, macro);
                     #endif
                     o.Albedo = macro.Albedo;
                     o.Normal = macro.Normal;
                     o.Emission = macro.Emission;
                     #if !_RAMPLIGHTING
                     o.Smoothness = macro.Smoothness;
                     o.Metallic = macro.Metallic;
                     o.Occlusion = macro.Occlusion;
                     #endif
                     #if _ALPHA || _ALPHATEST
                     o.Alpha = macro.Alpha;
                     #endif

                     return;
                  }
                  #endif
               #endif

               #if _SNOW
               si.snowHeightFade = snowHeightFade;
               #endif

               MegaSplatLayer splats = DoSurf(si, macro, tangentTransform);

               #if _DEBUG_OUTPUT_ALBEDO
               o.Albedo = splats.Albedo;
               #elif _DEBUG_OUTPUT_HEIGHT
               o.Albedo = splats.Height.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_NORMAL
               o.Albedo = splats.Normal * 0.5 + 0.5 * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SMOOTHNESS
               o.Albedo = splats.Smoothness.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_METAL
               o.Albedo = splats.Metallic.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_AO
               o.Albedo = splats.Occlusion.xxx * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_EMISSION
               o.Albedo = splats.Emission * saturate(splats.Albedo+1);
               #elif _DEBUG_OUTPUT_SPLATDATA
               o.Albedo = DebugSplatOutput(si);
               #else
               o.Albedo = splats.Albedo;
               o.Normal = splats.Normal;
               o.Metallic = splats.Metallic;
               o.Smoothness = splats.Smoothness;
               o.Occlusion = splats.Occlusion;
               o.Emission = splats.Emission;
                  
               #endif

               #if _ALPHA || _ALPHATEST
                  o.Alpha = splats.Alpha;
               #endif
            }



            #if _PASSMETA
            half4 frag(VertexOutput i) : SV_Target 
            {
                i.normal = normalize(i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normal;
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );

                LightingTerms lt = (LightingTerms)0;

                float3x3 tangentTransform = (float3x3)0;
                #if _SNOW
                tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                #endif

                Splat(i, lt, viewDirection, tangentTransform);

                o.Emission = lt.Emission;
                
                float3 diffColor = lt.Albedo;
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, lt.Metallic, specColor, specularMonochrome );
                float roughness = 1.0 - lt.Smoothness;
                o.Albedo = diffColor + specColor * roughness * roughness * 0.5;
                return UnityMetaFragment( o );

            }
            #elif _PASSSHADOWCASTER
            half4 frag(VertexOutput i) : COLOR
            {
               SHADOW_CASTER_FRAGMENT(i)
            }
            #elif _PASSDEFERRED
            void frag(
                VertexOutput i,
                out half4 outDiffuse : SV_Target0,
                out half4 outSpecSmoothness : SV_Target1,
                out half4 outNormal : SV_Target2,
                out half4 outEmission : SV_Target3 )
            {
                i.normal = normalize(i.normal);
                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;
                Splat(i, o, viewDirection, tangentTransform);
                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif
                float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                
                half3 specularColor;
                half3 diffuseColor;
                half3 indirectDiffuse;
                half3 indirectSpecular;
                LightPBRDeferred(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, 
                  indirectDiffuse, indirectSpecular, diffuseColor, specularColor);
                
                outSpecSmoothness = half4(specularColor, o.Smoothness);
                outEmission = half4( o.Emission, 1 );
                outEmission.rgb += indirectSpecular * o.Occlusion;
                outEmission.rgb += indirectDiffuse * diffuseColor;
                #ifndef UNITY_HDR_ON
                    outEmission.rgb = exp2(-outEmission.rgb);
                #endif
                outDiffuse = half4(diffuseColor, o.Occlusion);
                outNormal = half4( normalDirection * 0.5 + 0.5, 1 );



            }
            #else
            half4 frag(VertexOutput i) : COLOR 
            {

                i.normal = normalize(i.normal);

                float3x3 tangentTransform = float3x3( i.tangent, i.bitangent, i.normal);

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

                LightingTerms o = (LightingTerms)0;

                Splat(i, o, viewDirection, tangentTransform);

                #if _ALPHATEST
                clip(o.Alpha-0.5);
                #endif

                #if _DEBUG_OUTPUT_ALBEDO || _DEBUG_OUTPUT_HEIGHT || _DEBUG_OUTPUT_NORMAL || _DEBUG_OUTPUT_SMOOTHNESS || _DEBUG_OUTPUT_METAL || _DEBUG_OUTPUT_AO || _DEBUG_OUTPUT_EMISSION
                   return half4(o.Albedo,1);
                #else
                   float3 normalDirection = normalize(mul( o.Normal, tangentTransform ));
                   half4 lit = LightPBR(i, o.Albedo, normalDirection, o.Emission, o.Smoothness, o.Metallic, o.Occlusion, 1, viewDirection, i.ambientOrLightmapUV);
                   #if _ALPHA || _ALPHATEST
                   lit.a = o.Alpha;
                   #endif
                   return lit;
                #endif

            }
            #endif


            #if _LOWPOLY
            [maxvertexcount(3)]
            void geom(triangle VertexOutput input[3], inout TriangleStream<VertexOutput> s)
            {
               VertexOutput v0 = input[0];
               VertexOutput v1 = input[1];
               VertexOutput v2 = input[2];

               float3 norm = input[0].normal + input[1].normal + input[2].normal;
               norm /= 3;
               float3 tangent = input[0].tangent + input[1].tangent + input[2].tangent;
               tangent /= 3;
              
               float3 bitangent = input[0].bitangent + input[1].bitangent + input[2].bitangent;
               bitangent /= 3;

               #if _LOWPOLYADJUST
               v0.normal = lerp(v0.normal, norm, _EdgeHardness);
               v1.normal = lerp(v1.normal, norm, _EdgeHardness);
               v2.normal = lerp(v2.normal, norm, _EdgeHardness);
              
               v0.tangent = lerp(v0.tangent, tangent, _EdgeHardness);
               v1.tangent = lerp(v1.tangent, tangent, _EdgeHardness);
               v2.tangent = lerp(v2.tangent, tangent, _EdgeHardness);
              
               v0.bitangent = lerp(v0.bitangent, bitangent, _EdgeHardness);;
               v1.bitangent = lerp(v1.bitangent, bitangent, _EdgeHardness);;
               v2.bitangent = lerp(v2.bitangent, bitangent, _EdgeHardness);;
               #else
               v0.normal = norm;
               v1.normal = norm;
               v2.normal = norm;
              
               v0.tangent = tangent;
               v1.tangent = tangent;
               v2.tangent = tangent;
              
               v0.bitangent = bitangent;
               v1.bitangent = bitangent;
               v2.bitangent = bitangent;
               #endif


               s.Append(v0);
               s.Append(v1);
               s.Append(v2);
            }
            #endif
            ENDCG
        }


   }
   CustomEditor "SplatArrayShaderGUI"
   FallBack "MegaSplat/Terrain_fallback"
}
