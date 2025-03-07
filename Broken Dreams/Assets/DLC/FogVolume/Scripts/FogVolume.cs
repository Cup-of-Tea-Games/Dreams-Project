﻿//CHANGE LOG

/*  ---- v 3 ----

* Improved intersection method
* Fixed shadowing direction
* Gradient behaviour fixes
* Added tonemapper
* Added color offset and gamma
* Improved noise shadowing
* Added pointlights
* Better usage of jitter
* Point light dynamic list
* Added custom inspector
* Added light absorption
* Added normal map for direct lighting
* Background image for interface
* We can now combine noise with fog
* Added shadow casting (WIP) Not real shadowmapping yet
* Cube distance field
* 

 */

/* ---- v 3.1 ----
 * We can choose wether to use convolved or original opacity shadow map
 * Stereo single pass done
 * Fog Volume is now rendered offscreen and then injected in the scene to a mesh clone. Its is rendered to the main camera with sample(RT_FogVolume, ScreenCoords).
 * Camera renderer UI design
 * Script icon
 * Blend modes in volumes and surrogates
 * Discarded Shadow rendering when volume is not visible
 * Added height absorption when Height Gradient is active in noise tab

 
/* ---- v 3.1.1----
 * Primitive searching can be turned off now
 * Pointlight and primitive searching were performed all the time. Fixed now
 * Better adjustment of gradient uv.y
 * Added main light exposure
 * Fixed a bug where Surrogate was not rendered in standalone
 
 /* ---- v 3.1.2----
	* Pointlights real-time search is not optional.
	* Scene view is now optionally renderable

	
	----[ v 3.1.3 ]----
	* Pointlight search had volume check disabled
	* Primitives and pointlights turned off by default
	* Pointlight list can be edited manually now when Real-time search is not active
	* Pointlight discard is now working in Scene view too
	* Pointlight screen check is now done via colliders in Game view
	
		----[ v 3.1.4 ]----
	* Primitive list cleared when disabled
	* (Experimental) Pointlights only available for SHADER_API_GLCORE && SHADER_API_D3D11
	* Depth fix for target level 3.0
	* Shadowmap format optimization
	* Fixed shadow camera layer allocation
	
		----[ v 3.1.5 ]----
	* We can now compute pointlights outside the volume
	* Pointlight sphere collider set as trigger.
	* Box collider set as trigger.
	* Box collider size updated when size changes.
	
			----[ v 3.1.6 ]----
	* Fixed script errors when a new Volume was created
	
				----[ v 3.1.7 ]----
	* RenderShadowMap(); was being executed with shadow casting == off by mistake
	* Fixed inspector editor error when creating a new volume
	* Updated TAA
	* Noise intensity won't affect pointlight intensity
	* Increased ranges of "Density" and "Push alpha" sliders
	* Fixed primitive module errors when copy-paste from one scene to another
	* Fixed OnRenderImage() warning when using TAA
	* Pointlight tab was shown in uniform fog mode
	* Light search will ignore inactive lights
	* TAA renamed to DeNoise
	* Uniform fog excluded from low-res process
	* Disabled the ability of uniform fog to be shadow caster
	* Set gameobject icon
	* Disabled all lighting properties in shadow projector and primitive renderer
	* "Render In Scene View" will affect now shadow projector too
	* Inspector background correctly set when "Other" tab is collapsed
	* Fold properties within inspector are now independent across multiple fog volume objects
	* Primitive list is not cleared after disabling "Enable Primitives"
	* Primitives can now be deleted when "Real-time search" is disabled
	* Output color values clamped to safe hdr levels (fixes skybox sundisk crazy pixel)

	 ----[ v 3.1.8 ]----
	* Volume Fog Inscattering was shown in the lighting tab for uniform fog
	* Volume is correctly included and excluded from low-res process when switching from uniform to textured
	* "Create Surrogate" is not shown for the case of uniform fog
	* Solved an issue that was disabling shadows
	* Standard Assets won’t be required in the demos
	* Added a new tab to show general useful info
	* Color tab renamed to “Color Management” and rearranged in the inspector

	 ----[ v 3.1.9 ]----
	* Added "skip frames" to shadow camera
	* Blend mode is set to "traditional" and hidden for uniform fog
	* Fixed blinking of blurred shadow when not in play
	* Fixed eye position for stereo rendering
	* SteamVR dependencies removed
	* Stereo single and multipass fully supported
	* Succesfully tested across 5.5 - 5.6.1p1
	
		----[ v 3.1.10 ]----
	* Inspector error when Primitives enabled and count==0
	* Solved compiling errors on shader Upsample when building
	* Solved issue in Unity 2017.1 where screen resolution was null on screen effect
	* Solved wrong layer allocation on shadowcasters in Unity 2017.1
	* Solved an issue with screen effect image format update
	* "Render in Scene view" updates now outside of the Game viewport
	* Ztest set to Disabled by default
	* Shadow projector transform is now locked. Only vertical position and scale are editable
	* Sun light search improved
	* Info tab moved to the bottom of the interface
	* Added descriptive tooltips to interface parameters
	* Added self shadow color
	* Noise intensity and coverage values has been remapped. Intensity goes now from 0 to 1. Users will have to readjust these sliders to match their previous results
	* Objects with alpha collide now (cutout and transparent)
	* Custom InputManager.asset file is now optional. It is used to support gamepad
	* Assets/FogVolume Folder can be moved now to any other place
	* Object FogVolume data will be deleted after deleting all FV from the scene
	* Fixed a bug where shadow Skip frames was not set correctly causing shadows blinking
	* First implementation of volumetric shadows
	
			----[ v 3.2 ]----
	* Inscattering won't affect pixels affected by volumetric shadow
	* Fog Volume data scene volumes array resized after deleting a volume
	* First implementation of proxy volume support
	* Added focus mode: game object to directional light
	* Fog Volume data won't be deleted after deleting one Fog Volume
	* Corrected target material assignation in Directional light
	* Changes in the lighting model to integrate correctly shadows and ambient light: user will have to adjust ambient color and absorption values to match the previous results
	* Added an option to apply ambient to Fog color
	* Volumetric Fog inscattering color was multplied with fog color by default. Added an option to avoid this.
	* Corrections in volumetric shadows integration in the lighting model

	 ----[ v 3.2.1 ]----
	 * Fog Volume data will ignore cameras without HideFlags.None
	 * Less garbage allocation
	 * Replaced PointLight component with a general purpose FogVolumeLight component
	 * Added a LightManager component that is now responsible for handling lights 
		 It is automatically added to each FogVolume
	 * Added spot lights
	 * Added Fog Volume lights (point and spot) that work without a real point or spotlight
	 * Added Fog Volume to the menu bar, including new options for light creation
	 * New 'Light visibility' option in the inspector allows to modify the culling behaviour of point lights
	 * Depth buffer won't be affected now with the camera clip planes. 
	 * A textured Fog Volume can be now excluded from the low-res process. Useful to render FV with a different camera, i.e water refraction
	 * Directional Light allows now multiple volumes. User will have to reasign the target volume.
     * "Render in scene view" is now a per-volume option
     * Added an option to receive a depth map externally "_CustomCameraDepthTexture"
     * FV shadow map faded at the edges, so pixels are not stretched
     * Added Directional light option to the 'Fog Volume' menu
       - Only available when a directional light and at least one FogVolume is present

     ----[ v 3.2.1p1 ]----
	 * Fixed an error that didn't update FrustumPlanes correctly
     * Camera script shows a message when user adds FogVolume.cs to the camera. The camera is then cleaned OnEnable()
     * Reasigned ShadowProjectorMesh when it is null
       
      ----[ v 3.2.1p2 ]----
	 * Fixed a bug related with visibility
     * Mesh filter is hidden from inspector
     * Lights can now be turned on/off without the need for toggling "Real-time search".
     * Camera script can be removed when "Disable camera script"== ON in FogVolumeData
     * Directional light debug miniature can be moved now
     * Added a culling mask field for depth pass
     * LightManager is correctly hidden from inspector
     * Fixed unneeded shadow work performed in Depth pass
     
/*TODO
 * Lightshaft distance atten
 * Limit primitives amount, pointlights and iterations according to GPU limits
 * Send parameters and keywords only when they change
 * Don't compute directional lighting in shadowed pixels
 * Split primitive list into multiple lists to allow different types (sphere, cone...)
 */

using UnityEngine;
using System.Reflection;
using System.Collections.Generic;
using UnityEngine.Profiling;
using FogVolumeUtilities;

#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif

[ExecuteInEditMode]
//[RequireComponent(typeof(FogVolumeLightManager))]
public class FogVolume : MonoBehaviour
{
    #region InspectorData
#if UNITY_EDITOR
    public bool showLighting,
                                OtherTAB,
                                showGradient,
                                showPointLights,
                                showNoiseProperties,
                                showVolumeProperties,
                                showColorTab,
                                tempShadowCaster,
                                showCustomizationOptions,
                                showDebugOptions,
                                showOtherOptions,
                                generalInfo,
                                TexturesGroup;

    public string BackgroundImagesPath;
#endif
    #endregion

    public enum FogType
    {
        Uniform = 0,
        Textured = 1
    }

    public FogType _FogType;
    public bool RenderableInSceneView = true;
    GameObject FogVolumeGameObject;
    public FogVolume ShadowCaster;
    public Texture2D _PerformanceLUT;
    //public float bias = .5f;
    public Vector3 fogVolumeScale = new Vector3(20, 20, 20);
    [SerializeField]
    public Color FogMainColor = Color.white;
    public Color _FogColor = Color.white;
    public bool _AmbientAffectsFogColor = false;
    [Range(1, 5)]
    public float Exposure = 2.5f;
    [Range(-.5f, .5f)]
    public float Offset = 0;
    [Range(.01f, 3)]
    public float Gamma = 1;
    public bool Tonemap = false;
    public float Visibility = 25;
    [HideInInspector]
    public bool ColorAdjust = false;
    [Header("Lighting")]
    public int _SelfShadowSteps = 3;
    public int ShadowCameraSkippedFrames = 0;
    public Color _SelfShadowColor = Color.black;
    public float VolumeFogInscatteringAnisotropy = .5f;
    public float VolumeFogInscatteringIntensity = .1f;
    public float VolumeFogInscatteringStartDistance = 10f;
    public float VolumeFogInscatteringTransitionWideness = 1;
    public Color VolumeFogInscatteringColor = Color.white;
    public bool VolumeFogInscattering = false;
    public float HeightAbsorption, HeightAbsorptionMin = -1, HeightAbsorptionMax = -1;
    public bool SunAttached;
    [SerializeField]
    public Light Sun = null;
    [SerializeField]
    public bool _ShadeNoise = false;
    public bool _DirectionalLighting = false;
    public float _DirectionalLightingDistance = .01f;
    // public float DirectionalLightingClamp = 2;
    public float DirectLightingShadowDensity = 1;
    public Color LightExtinctionColor = new Color(81 / 255f, 45 / 255f, 26 / 255f, 0);
    public int DirectLightingShadowSteps = 1;
    public bool bAbsorption = true;
    public float Absorption = .5f;
    public float _LightExposure = 1;
    public bool Lambert = false;
    public float LambertianBias = 1;
    public float NormalDistance = .01f;
    public float DirectLightingAmount = 1;
    public float DirectLightingDistance = 10;
    [Range(1, 3)]
    public float ShadowBrightness = 1;
    public Color _AmbientColor = Color.gray;
    bool _ProxyVolume = false;
    // [SerializeField]
    // [Range(1, 10)]
    // public float Shade = 1;
    [SerializeField]
    [Range(.0f, .15f)]
    public float ShadowShift = 0.0094f;
    [Range(0, 5)]
    public float PointLightsIntensity = 1;
    // public PointLight[] PointLights;
    // public List<PointLight> PointLightsList;
    public float PointLightingDistance = 1000, PointLightingDistance2Camera = 50;

    public float PointLightCullSizeMultiplier = 1.0f;
    public bool PointLightsActive = false;

    public bool EnableInscattering = false;
    public Color InscatteringColor = Color.white;
    public Texture2D _LightHaloTexture, CoverageTex;
    public bool LightHalo;
    public float _HaloWidth = .75f;
    public float _HaloOpticalDispersion = 1;
    public float _HaloRadius = 1;
    public float _HaloIntensity = 1;
    public float _HaloAbsorption = .5f;
    [Range(-1, 1)]
    public float
            InscatteringShape = 0;
    public float InscatteringIntensity = .2f, InscatteringStartDistance = 00, InscatteringTransitionWideness = 1;

    [Header("Noise")]
    public bool EnableNoise = false;

    public int Octaves = 1;
    public float _DetailMaskingThreshold = 18;
    // public float DetailSamplingBaseOpacityLimit = .3f;
    public bool bSphericalFade = false;
    public float SphericalFadeDistance = 10;
    public float DetailDistance = 500;
    public float DetailTiling = 1;
    public float _DetailRelativeSpeed = 10;
    public float _BaseRelativeSpeed = 1;
    public float _NoiseDetailRange = .5f, _Curl = .5f;
    public float BaseTiling = 8;
    public float Coverage = 1.5f;
    public float NoiseDensity = 1;
    // [SerializeField]
    // public bool Procedural = false;
    //[SerializeField]
    //bool DoubleLayer = false;
    //[SerializeField]
    public float _3DNoiseScale = 80;
    // [SerializeField]
    [Range(10f, 300)]
    public int Iterations = 85;

    public FogVolumeRenderer.BlendMode _BlendMode = FogVolumeRenderer.BlendMode.TraditionalTransparency;
    //[SerializeField]
    // [Range(10, 2000)]
    public float IterationStep = 500, _OptimizationFactor = 0;
    public enum SamplingMethod
    {
        Eye2Box = 0,
        ViewAligned = 1
    }
    public SamplingMethod _SamplingMethod = (SamplingMethod)0;
    public enum DebugMode
    {
        Lit,
        Iterations,
        Inscattering,
        VolumetricShadows,
        VolumeFogInscatterClamp,
        VolumeFogPhase
    }
    public bool _VisibleByReflectionProbeStatic = true;
    FogVolumeRenderer _FogVolumeRenderer = null;
    public GameObject GameCameraGO = null;
    public DebugMode _DebugMode = DebugMode.Lit;
    public bool useHeightGradient = false;
    public float GradMin = 1, GradMax = -1, GradMin2 = -1, GradMax2 = -1;
    public Texture3D _NoiseVolume2;
    public Texture3D _NoiseVolume = null;
    [Range(0f, 10)]
    public float NoiseIntensity = 0.3f;
	public void setNoiseIntensity(float value)
	{
		NoiseIntensity = value;
	}
    //[Range(1, 200)]

    [Range(0f, 5f)]
    public float
            NoiseContrast = 12;
    public float FadeDistance = 5000;
    [Range(0, 20)]
    public float Vortex = 0;
    public enum VortexAxis
    {
        X = 0,
        Y = 1,
        Z = 2
    }


    public VortexAxis _VortexAxis = (VortexAxis)2;

    public bool bVolumeFog = false;
    public bool VolumeFogInscatterColorAffectedWithFogColor = true;
    public enum LightScatterMethod
    {
        BeersLaw = 0,
        InverseSquare = 1,

        Linear = 2
    }
    public LightScatterMethod _LightScatterMethod = (LightScatterMethod)1;
    [Range(0, 360)]
    public float rotation = 0;
    [Range(0, 10)]
    public float RotationSpeed = 0;
    public Vector4 Speed = new Vector4(0, 0, 0, 0);
    public Vector4 Stretch = new Vector4(0, 0, 0, 0);
    [SerializeField]
    [Header("Collision")]
    public bool SceneCollision = true;
    public bool ShowPrimitives = false;
    public bool EnableDistanceFields = false;
    public List<FogVolumePrimitive> PrimitivesList;
    public float _PrimitiveEdgeSoftener = 1;
    public float _PrimitiveCutout = 0;
    public float Constrain = 0;
    [SerializeField]
    //[Range(1, 200)]
    //float _SceneIntersectionThreshold = 1000;
    //[SerializeField]
    [Range(1, 200)]
    public float _SceneIntersectionSoftness = 1;
    [SerializeField]
    [Range(0, .1f)]
    public float _jitter = 0.0045f;
    public MeshRenderer FogRenderer = null;
    public Texture2D[] _InspectorBackground;
    public int _InspectorBackgroundIndex = 0;

    public string Description = "";
    [Header("Gradient")]
    public bool EnableGradient = false;
    public Texture2D Gradient;

    //  #if UNITY_EDITOR
    [SerializeField]
    public bool HideWireframe = true;
    //  #endif
    [SerializeField]
    public int
            DrawOrder = 0;

    [SerializeField]
    public bool ShowDebugGizmos = false;
    MeshFilter filter;
    Mesh mesh;
    public RenderTexture RT_Opacity, RT_OpacityBlur;

    public float ShadowCutoff = 1f;
    Vector3 currentFogVolume = Vector3.one;
    public bool CastShadows = false;
    Camera ShadowCamera;
    public GameObject ShadowCameraGO;
    public int shadowCameraPosition = 20;
    public int ShadowCameraPosition
    {
        set
        {
            if (value != shadowCameraPosition)
            {

                shadowCameraPosition = value;
                _ShadowCamera.CameraTransform();

            }
        }
        get
        {
            return shadowCameraPosition;
        }
    }
    public ShadowCamera _ShadowCamera;
    public float _PushAlpha = 1;

    public float GetVisibility()
    {
        return Visibility;
    }

    // public Material _FogMaterial { get { return FogMaterial; } }
    Material fogMaterial = null;
    public Material FogMaterial
    {
        get
        {
            if (fogMaterial == null)
            {

                CreateMaterial();
            }
            return fogMaterial;
        }
    }
    public Shader FogVolumeShader;
    void CreateMaterial()
    {
        DestroyImmediate(fogMaterial);
        FogVolumeShader = Shader.Find("Hidden/FogVolume");
        // FogVolumeShader.maximumLOD = 600;
        fogMaterial = new Material(FogVolumeShader);
        try
        {
            fogMaterial.name = FogVolumeGameObject.name + " Material";
        }
        catch {/* print(name); */};
        fogMaterial.hideFlags = HideFlags.HideAndDontSave;
    }

    //void SetCameraDepth()
    //{
    //    if (ForwardRenderingCamera)
    //        ForwardRenderingCamera.depthTextureMode |= DepthTextureMode.Depth;
    //}
#if UNITY_EDITOR
    void CreateLayer(string LayerName)
    {
        //  https://forum.unity3d.com/threads/adding-layer-by-script.41970/reply?quote=2274824
        SerializedObject tagManager = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
        SerializedProperty layers = tagManager.FindProperty("layers");
        bool ExistLayer = false;
        //print(ExistLayer);
        for (int i = 8; i < layers.arraySize; i++)
        {
            SerializedProperty layerSP = layers.GetArrayElementAtIndex(i);

            //print(layerSP.stringValue);
            if (layerSP.stringValue == LayerName)
            {
                ExistLayer = true;
                break;
            }

        }
        for (int j = 8; j < layers.arraySize; j++)
        {
            SerializedProperty layerSP = layers.GetArrayElementAtIndex(j);
            if (layerSP.stringValue == "" && !ExistLayer)
            {
                layerSP.stringValue = LayerName;
                tagManager.ApplyModifiedProperties();

                break;
            }
        }

        // print(layers.arraySize);
    }



#endif
    [SerializeField]
    GameObject ShadowProjector;
    MeshRenderer ShadowProjectorRenderer;
    MeshFilter ShadowProjectorMeshFilter;
    Material ShadowProjectorMaterial;
    //Shader ShadowProjectorShader;
    public Mesh ShadowProjectorMesh;
    public Color ShadowColor = new Color(.5f, .5f, .5f, .25f);
    //Vector3 ShadowProjectorScaleBackup = new Vector3(20, 20, 20);
    //Vector3 ShadowProjectorPositionBackup;
    public UnityEngine.Rendering.CompareFunction _ztest = UnityEngine.Rendering.CompareFunction.Disabled;

    void ShadowProjectorLock()
    {
        if (ShadowProjector)
        {
            ShadowProjector.transform.position = new Vector3(
                    FogVolumeGameObject.transform.position.x,
                    ShadowProjector.transform.position.y,
                     FogVolumeGameObject.transform.position.z);

            Vector3 ShadowProjectorScale = new Vector3(fogVolumeScale.x, ShadowProjector.transform.localScale.y, fogVolumeScale.z);
            ShadowProjector.transform.localScale = ShadowProjectorScale;

            ShadowProjector.transform.localRotation = new Quaternion();
        }
    }
    void ShadowMapSetup()
    {
        if (ShadowCameraGO)
        {
            //print(ShadowCameraGO.name);
            //DestroyImmediate(ShadowCameraGO);
            // ShadowCameraGO.hideFlags = HideFlags.None;
            ShadowCameraGO.hideFlags = HideFlags.HideInHierarchy;
            ShadowCameraGO.GetComponent<Camera>().cullingMask = 1 << LayerMask.NameToLayer("FogVolumeShadowCaster");

            ShadowCameraGO.GetComponent<Camera>().renderingPath = RenderingPath.Forward;
        }
        //The volume must be square, sir
        if (CastShadows)
        {
            fogVolumeScale.z = fogVolumeScale.x;

        }
        if (ShadowCameraGO == null && CastShadows)
        {




            if (ShadowCameraGO == null)
            {
                ShadowCameraGO = new GameObject();

                ShadowCameraGO.transform.parent = FogVolumeGameObject.transform;
                ShadowCameraGO.AddComponent<Camera>();
                ShadowCamera = ShadowCameraGO.GetComponent<Camera>();
                ShadowCamera.orthographic = true;

                ShadowCamera.clearFlags = CameraClearFlags.Color;
                ShadowCamera.backgroundColor = new Color(0, 0, 0, 0);

                ShadowCameraGO.AddComponent<ShadowCamera>();
                ShadowCameraGO.name = FogVolumeGameObject.name + " Shadow Camera";

                //
                // 
            }
            else
            {
                ShadowCameraGO.hideFlags = HideFlags.None;
                ShadowCameraGO = GameObject.Find(FogVolumeGameObject.name + " Shadow Camera");
                ShadowCameraGO.hideFlags = HideFlags.HideInHierarchy;
            }



            _ShadowCamera = ShadowCameraGO.GetComponent<ShadowCamera>();
            _ShadowCamera.CameraTransform();

        }


        //Create shadow projector
        if (CastShadows)
        {
            ShadowProjector = GameObject.Find(FogVolumeGameObject.name + " Shadow Projector");
            if (ShadowProjector == null)
            {
                ShadowProjector = new GameObject();

                ShadowProjector.AddComponent<MeshFilter>();
                ShadowProjector.AddComponent<MeshRenderer>();
                ShadowProjector.transform.parent = FogVolumeGameObject.transform;
                ShadowProjector.transform.position = FogVolumeGameObject.transform.position;
                ShadowProjector.transform.rotation = FogVolumeGameObject.transform.rotation;
                ShadowProjector.transform.localScale = fogVolumeScale;
                ShadowProjector.GetComponent<MeshRenderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                ShadowProjector.GetComponent<MeshRenderer>().receiveShadows = false;
                ShadowProjector.GetComponent<MeshRenderer>().reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
                ShadowProjector.GetComponent<MeshRenderer>().lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            }


            //ShadowProjector.hideFlags = HideFlags.DontSave;


            ShadowProjectorMeshFilter = ShadowProjector.GetComponent<MeshFilter>();
            //doesnt work ShadowProjectorMesh = Resources.Load("ShadowVolume") as Mesh;
            ShadowProjectorMeshFilter.mesh = ShadowProjectorMesh;
            //3.1.3 for some reason, the mesh is lost in the VR showroom
            if (ShadowProjectorMesh == null)
            {
                GameObject tempShadowBoxGO = GameObject.CreatePrimitive(PrimitiveType.Cube);
                ShadowProjectorMesh = tempShadowBoxGO.GetComponent<MeshFilter>().mesh;
                DestroyImmediate(tempShadowBoxGO, true);
            }           

            if (ShadowProjector.GetComponent<MeshFilter>().sharedMesh == null)
                ShadowProjector.GetComponent<MeshFilter>().mesh = ShadowProjectorMesh;

            if (ShadowProjectorMesh == null) print("Missing mesh");

            ShadowProjectorRenderer = ShadowProjector.GetComponent<MeshRenderer>();
            ShadowProjectorRenderer.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            ShadowProjectorRenderer.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
            ShadowProjectorRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            ShadowProjectorRenderer.receiveShadows = false;
            ShadowProjectorMaterial = ShadowProjectorRenderer.sharedMaterial;
            ShadowProjector.name = FogVolumeGameObject.name + " Shadow Projector";
            if (ShadowProjectorMaterial == null)
            {
                ShadowProjectorMaterial = new Material(Shader.Find("Fog Volume/Shadow Projector"));
                //ShadowProjectorMaterial = new Material(Shader.Find("Diffuse"));

                ShadowProjectorMaterial.name = "Shadow Projector Material";
                // ShadowProjectorMaterial.hideFlags = HideFlags.HideAndDontSave;

            }
            ShadowProjectorRenderer.sharedMaterial = ShadowProjectorMaterial;

        }

    }

    void SetShadowProyectorLayer()
    {
        //lets hide it when we don't render it in scene view. We will send it to the UI layer to make it easy
        if (ShadowProjector)
        {
            if (RenderableInSceneView == false)
            {
                if (ShadowProjector.layer == LayerMask.NameToLayer("Default"))
                {
                    ShadowProjector.layer = LayerMask.NameToLayer("UI");
                    // print("switch projector to UI");
                }
            }
            else
            {
                if (ShadowProjector.layer == LayerMask.NameToLayer("UI"))
                {
                    ShadowProjector.layer = LayerMask.NameToLayer("Default");
                    //  print("switch projector to Default");
                }
            }
        }
    }

    void FindDirectionalLight()
    {
        //pick a light
        Light[] SceneLights = FindObjectsOfType<Light>();
        //first, try to get it from light settings
        if (!Sun)
            Sun = RenderSettings.sun;

        //not yet?
        if (!Sun)
            foreach (Light TempLight in SceneLights)
            {

                if (TempLight.type == LightType.Directional)
                {
                    Sun = TempLight;
                    break;
                }
            }

        if (Sun == null)
        {
            Debug.LogError("Fog Volume: No valid light found\nDirectional light is required. Light component can be disabled.");
            return;
        }
        else
        {

            //remove fog layers from light 3.1.8. Light must not affect the volume we want to use as density for the screen effect
            Sun.cullingMask &= ~(1 << LayerMask.NameToLayer("FogVolumeUniform"));
            Sun.cullingMask &= ~(1 << LayerMask.NameToLayer("FogVolume"));
            Sun.cullingMask &= ~(1 << LayerMask.NameToLayer("FogVolumeSurrogate"));
            // Sun.cullingMask &= ~(1 << LayerMask.NameToLayer("FogVolumeShadowCaster"));
        }
    }
    private Plane[] FrustumPlanes;
    Camera GameCamera;
    Material SurrogateMaterial;
    BoxCollider _BoxCollider;
    FogVolumeData _FogVolumeData;
    GameObject _FogVolumeDataGO;
    public void FindFogVolumeData()
    {
        if (_FogVolumeDataGO == null)
        {
            //Check existence first
            _FogVolumeDataGO = GameObject.Find("Fog Volume Data");

            if (FindObjectsOfType<FogVolumeData>().Length < 1 && _FogVolumeDataGO == null)
            {
                _FogVolumeDataGO = new GameObject();
                _FogVolumeData = _FogVolumeDataGO.AddComponent<FogVolumeData>();
                _FogVolumeDataGO.name = "Fog Volume Data";
            }
            else
            {
                _FogVolumeDataGO = GameObject.Find("Fog Volume Data");
                if (_FogVolumeDataGO != null)
                    _FogVolumeData = _FogVolumeDataGO.GetComponent<FogVolumeData>();
            }
        }
        else
            _FogVolumeData = _FogVolumeDataGO.GetComponent<FogVolumeData>();

    }
    /* With ExcludeFromLowRes enabled a textured FV is excluded from the low-res process. 
     * So it can be rendered by another camera, for example, a water reflection or refraction camera
     * Then, we have to feed it with a custom DepthTexture that ignores the clip planes. _CameraDepthTexture is not valid because
     * the clip planes of a camera like MirrorReflection.cs break FV. The provided shader Depth.shader will generate
     * a valid depth texture
     */
    public bool ExcludeFromLowRes = false;
    void MoveToLayer()
    {
        if (!CastShadows)
        {
            if (!ExcludeFromLowRes)
            {
                if (_FogType == FogType.Textured)
                {
                    if (FogVolumeGameObject.layer != LayerMask.NameToLayer("FogVolume"))
                    {
                        FogVolumeGameObject.layer = LayerMask.NameToLayer("FogVolume");
                        // print("Moved to FogVolume layer");
                    }


                }
                else
                {
                    if (FogVolumeGameObject.layer != LayerMask.NameToLayer("FogVolumeUniform"))
                    {
                        FogVolumeGameObject.layer = LayerMask.NameToLayer("FogVolumeUniform");
                        // FogMaterial.DisableKeyword("ExternalDepth");
                    }
                }
            }

        }
    }
    public void AssignCamera()
    {

        FindFogVolumeData();
        if (_FogVolumeDataGO == null) return;//wait til update check       

        if (_FogVolumeData.GetFogVolumeCamera != null)
            GameCameraGO = _FogVolumeData.GetFogVolumeCamera.gameObject;

        if (GameCameraGO == null)
        {

            //Debug.Log("No camera available in "+gameObject.name);
            this.enabled = false;
            return;
        }
        else
            this.enabled = true;

        GameCamera = GameCameraGO.GetComponent<Camera>();

        _FogVolumeRenderer = GameCameraGO.GetComponent<FogVolumeRenderer>();
        if (_FogVolumeRenderer == null)
        {
            if (!_FogVolumeData.ForceNoRenderer)
            {
                _FogVolumeRenderer = GameCameraGO.AddComponent<FogVolumeRenderer>();
                _FogVolumeRenderer.enabled = true;
            }
        }
        else
                if (_FogVolumeData.ForceNoRenderer == false)//3.1.8 Lets preserve that option
            _FogVolumeRenderer.enabled = true;
    }
    void SetIcon()
    {
#if UNITY_EDITOR
        Texture Icon = Resources.Load("FogVolumeIcon") as Texture;
        //Icon.hideFlags = HideFlags.HideAndDontSave;
        var editorGUI = typeof(EditorGUIUtility);
        var bindingFlags = BindingFlags.InvokeMethod | BindingFlags.Static | BindingFlags.NonPublic;
        var args = new object[] { gameObject, Icon };
        editorGUI.InvokeMember("SetIconForObject", bindingFlags, null, null, args);
#endif
    }



    void OnEnable()
    {
        m_lightManager = null;

        SetIcon();
        //Low resolution renderer setup
        AssignCamera();

        SurrogateMaterial = Resources.Load("Fog Volume Surrogate", typeof(Material)) as Material;
        FindDirectionalLight();
        _BoxCollider = GetComponent<BoxCollider>();

        if (_BoxCollider == null)
            _BoxCollider = gameObject.AddComponent<BoxCollider>();

        _BoxCollider.hideFlags = HideFlags.HideAndDontSave;
        
        _BoxCollider.isTrigger = true;

        FogVolumeGameObject = this.gameObject;
#if UNITY_EDITOR
        CreateLayer("FogVolumeShadowCaster");
        CreateLayer("FogVolume");
        CreateLayer("FogVolumeSurrogate");
        CreateLayer("FogVolumeUniform");
#endif


        FogRenderer = FogVolumeGameObject.GetComponent<MeshRenderer>();
        if (FogRenderer == null)
            FogRenderer = FogVolumeGameObject.AddComponent<MeshRenderer>();


        FogRenderer.sharedMaterial = FogMaterial;
        ToggleKeyword();

        // FogRenderer.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;




        if (filter == null)
        {
            filter = gameObject.GetComponent<MeshFilter>();
            CreateBoxMesh(transform.localScale);
            transform.localScale = Vector3.one;
        }
        filter.hideFlags = HideFlags.HideInInspector;
        UpdateBoxMesh();

        ShadowMapSetup();

        _PerformanceLUT = Resources.Load("PerformanceLUT") as Texture2D;

        //first check
        GetShadowMap();
        _FogVolumeData.FindFogVolumes();//3.2
        #region LoadBackgroundImages
#if UNITY_EDITOR

        //   string BackgroundImagesPath = Application.dataPath + "/FogVolume/Scripts/Themes/png";


#endif
        #endregion

        _InitializeLightManagerIfNeccessary();
    }
    public float PointLightCPUMaxDistance = 1;
    GameObject PointLightsCameraGO = null;
    Camera PointLightsCamera = null;
    float GetPointLightDistance2Camera(Vector3 lightPosition)
    {
        PointLightsCameraGO = Camera.current.gameObject;//so it works in scene view too

        float Distance = (lightPosition - PointLightsCameraGO.transform.position).magnitude;
        // print(Distance);
        return Distance;

    }


    public float PointLightScreenMargin = 1f;

    //bool PointLightRangeVisible(PointLight p)
    //{
    //    Collider pCol = p.GetComponent<SphereCollider>();
    //    bool visible = true;
    //    if (Application.isPlaying)
    //    {
    //        if (GeometryUtility.TestPlanesAABB(FrustumPlanes, pCol.bounds))
    //            visible = true;
    //        else
    //            visible = false;

    //    }
    //    else
    //        visible = PointIsVisible(p.transform.position);

    //    // print(visible);
    //    return visible;
    //}

    bool PointIsVisible(Vector3 point)
    {
        PointLightsCamera = PointLightsCameraGO.GetComponent<Camera>();//for scene view!
                                                                       //possible TODO: attenuate light when it is outside view
        float marginNeg = 0 - PointLightScreenMargin;
        float marginPos = 1 + PointLightScreenMargin;
        bool visible = true;
        Vector3 screenPoint = PointLightsCamera.WorldToViewportPoint(point);

        if (screenPoint.z > marginNeg && screenPoint.x > marginNeg && screenPoint.x < marginPos
                && screenPoint.y > marginNeg && screenPoint.y < marginPos)
        {
            // print("visible");
            visible = true;
        }
        else
        {
            //print("no visible");
            visible = false;
        }

        return visible;
    }

    //bool isPointLightInVisibleRange(PointLight light)
    //{
    //    Vector3 position = light.gameObject.transform.position;
    //    float Distance = GetPointLightDistance2Camera(position);


    //    if (Distance > PointLightingDistance2Camera)
    //        return false;
    //    else
    //    {
    //        return PointLightRangeVisible(light);
    //    }
    //}
    public bool PointLightsRealTimeUpdate = true;
    public bool PointLightBoxCheck = true;




    public bool PointIsInsideVolume(Vector3 PointPosition)
    {

        //todo: rotation!
        bool result = false;
        float FogVolumeXmax = gameObject.transform.position.x + fogVolumeScale.x / 2;
        float FogVolumeXmin = gameObject.transform.position.x - fogVolumeScale.x / 2;

        float FogVolumeYmax = gameObject.transform.position.y + fogVolumeScale.y / 2;
        float FogVolumeYmin = gameObject.transform.position.y - fogVolumeScale.y / 2;

        float FogVolumeZmax = gameObject.transform.position.z + fogVolumeScale.z / 2;
        float FogVolumeZmin = gameObject.transform.position.z - fogVolumeScale.z / 2;

        if (FogVolumeXmax > PointPosition.x && FogVolumeXmin < PointPosition.x)
        {
            // print("x dentro");
            if (FogVolumeYmax > PointPosition.y && FogVolumeYmin < PointPosition.y)
            {
                //  print("y dentro");
                if (FogVolumeZmax > PointPosition.z && FogVolumeZmin < PointPosition.z)
                {
                    //  print("dentro");
                    result = true;
                }
            }

        }
        // else
        //  print("fuera");
        //  print("nombre luz: " + FogLights.name);
        //  print("x maximo: " + FogVolumeXmax + " x minimo: " + FogVolumeXmin);
        return result;
    }
    Vector4[] PrimitivePositions = new Vector4[20];
    Transform[] PrimitivePositionsTransform = new Transform[20];
    public Vector4[] GetPrimitivesPositions()
    {
        int index = 0;

        foreach (FogVolumePrimitive guy in PrimitivesList)
        {
            index = Mathf.Min(16, index);
            PrimitivePositionsTransform[index] = guy.GetTransform;

            PrimitivePositions[index] = this.gameObject.transform.
                 InverseTransformPoint(PrimitivePositionsTransform[index].position);
            index++;
        }
        return PrimitivePositions;
    }
    Matrix4x4[] PrimitivesMatrixTransform = new Matrix4x4[20];
    Transform[] PrimitivesTransform = new Transform[20];
    public Matrix4x4[] GetPrimitivesTransform()
    {
        int index = 0;

        foreach (FogVolumePrimitive guy in PrimitivesList)
        {
            PrimitivesTransform[index] = guy.GetTransform;


            PrimitivesMatrixTransform[index].SetTRS(
                        PrimitivesTransform[index].position,
         Quaternion.Inverse(PrimitivesTransform[index].rotation) * (gameObject.transform.rotation),

                        Vector3.one
                         )

                         ;

            // MatrixTransform[index] = MatrixTransform[index].inverse;
            index++;

        }
        return PrimitivesMatrixTransform;
    }

    Vector4[] Scales = new Vector4[20];
    public Vector4[] GetPrimitivesScale()
    {
        int index = 0;

        foreach (FogVolumePrimitive guy in PrimitivesList)
        {
            Scales[index] = guy.GetPrimitiveScale;
            index++;
        }
        return Scales;
    }
    //   Vector4[] PointlightPositions = new Vector4[256];
    //  Transform[] PointlightPositionsTransform = new Transform[256];
    //public Vector4[] GetPointLightPositions()
    //{
    //    int index = 0;


    //    if (PointLightsList.Count > 0)
    //        foreach (PointLight guy in PointLightsList)
    //        {
    //            index = Mathf.Min(255, index);
    //            // Positions[index] = guy.GetPointLightPosition;
    //            if (guy != null)
    //            {
    //                PointlightPositionsTransform[index] = guy.GetTransform;

    //                PointlightPositions[index] = this.gameObject.transform.
    //                     InverseTransformPoint(PointlightPositionsTransform[index].position);
    //            }
    //            index++;

    //        }
    //    return PointlightPositions;
    //}

    Vector3 LocalDirectionalSunLight(Light Sun)
    {
        return transform.InverseTransformVector(-Sun.transform.forward);
    }
    //   Color[] PointlightColors = new Color[256];
    //public Color[] GetPointLightColors()
    //{
    //    int index = 0;

    //    if (PointLightsList.Count > 0)
    //        foreach (PointLight guy in PointLightsList)
    //        {
    //            index = Mathf.Min(255, index);
    //            if (guy != null)
    //                PointlightColors[index] = guy.GetPointLightColor;

    //            index++;
    //        }
    //    return PointlightColors;
    //}

    //  float[] PointLightIntensity = new float[256];
    //public float[] GetPointLightIntensity()
    //{
    //    int index = 0;

    //    if (PointLightsList.Count > 0)
    //        foreach (PointLight guy in PointLightsList)
    //        {
    //            index = Mathf.Min(255, index);
    //            if (guy != null)
    //            {
    //                PointLightIntensity[index] = guy.GetPointLightIntensity * PointLightsIntensity
    //                    //distance fade
    //                    * (1 - Mathf.Clamp01(GetPointLightDistance2Camera(guy.gameObject.transform.position) / PointLightingDistance2Camera));
    //            }
    //            index++;
    //        }
    //    return PointLightIntensity;
    //}
    //   float[] PointlightRange = new float[256];
    //public float[] GetPointLightRanges()
    //{
    //    int index = 0;

    //    if (PointLightsList.Count > 0)
    //        foreach (PointLight guy in PointLightsList)
    //        {
    //            index = Mathf.Min(256, index);
    //            if (guy != null)
    //                PointlightRange[index] = guy.GetPointLightRange;

    //            index++;
    //        }
    //    return PointlightRange;
    //}
    void PrimitivesVisible()
    {
        int index = 0;

        foreach (FogVolumePrimitive guy in PrimitivesList)
        {
            if (guy == null)
            {
                PrimitivesList.Remove(guy);
                break;
            }

            if (guy)
            {
                if (ShowPrimitives)
                    guy.GetComponent<Renderer>().enabled = true;
                else
                    guy.GetComponent<Renderer>().enabled = false;
            }
            index++;
        }
    }
    public bool PrimitivesRealTimeUpdate = true;
    public FogVolumePrimitive[] Primitives;
    void ClearPrimitiveList()
    {
        if (PrimitivesList != null && PrimitivesRealTimeUpdate)
            PrimitivesList.Clear();
        if (PrimitivesList == null)
            PrimitivesList = new List<FogVolumePrimitive>();
    }
    void CreatePrimitiveList()
    {

        if (PrimitivesRealTimeUpdate)
            Primitives = FindObjectsOfType(typeof(FogVolumePrimitive)) as FogVolumePrimitive[];
        ClearPrimitiveList();

        for (int i = 0; i < Primitives.Length; i++)
        {
            if (Primitives[i] != null &&
                    Primitives[i].GetComponent<FogVolumePrimitive>().enabled &&
                    PointIsInsideVolume(Primitives[i].transform.position))
            {
                if (PrimitivesRealTimeUpdate)
                    PrimitivesList.Add(Primitives[i]);

            }
        }



        PrimitivesVisible();
    }
    void OnDisable()
    {
        m_lightManager = null;
    }

    static public void Wireframe(GameObject obj, bool Enable)
    {
#if UNITY_EDITOR
        //not valid in 5.5
        // EditorUtility.SetSelectedWireframeHidden(obj.GetComponent<Renderer>(), Enable);
        if (Enable)
            EditorUtility.SetSelectedRenderState(obj.GetComponent<Renderer>(), EditorSelectedRenderState.Wireframe);
        else
            EditorUtility.SetSelectedRenderState(obj.GetComponent<Renderer>(), EditorSelectedRenderState.Highlight);
#endif
    }
    void OnBecameVisible()
    { }
    public bool IsVisible;
    void GetShadowMap()
    {

        if (FogRenderer == null) FogRenderer = FogVolumeGameObject.GetComponent<MeshRenderer>();

        //if (FogRenderer.isVisible){//Visible by ANY camera '-_-
       
        if (IsVisible)
        {


            if (FogRenderer != null && FogRenderer.shadowCastingMode == UnityEngine.Rendering.ShadowCastingMode.Off)
            {

                CastShadows = false;
            }
            if (FogRenderer.shadowCastingMode == UnityEngine.Rendering.ShadowCastingMode.On)
            {
                if (_FogType == FogType.Textured)
                    CastShadows = true;
                else
                    FogRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;//revert if fog is uniform
            }

            //allow self shadows? not for now, since the result will be incorrect
            //if (FogRenderer.receiveShadows)
            //    CastShadows = false;



            if (CastShadows && _ShadowCamera == null)
            {
                ShadowMapSetup();
                RT_OpacityBlur = _ShadowCamera.GetOpacityBlurRT();

            }

            if (_ShadowCamera)
            {

                _ShadowCamera.enabled = CastShadows;
            }

            if (CastShadows)
            {

                RT_Opacity = _ShadowCamera.GetOpacityRT();

            }
            else
                    if (ShadowCaster && FogRenderer.receiveShadows)
            {
                RT_Opacity = ShadowCaster.RT_Opacity;
                RT_OpacityBlur = ShadowCaster.RT_OpacityBlur;
                //same dimensions than caster
                fogVolumeScale.x = ShadowCaster.fogVolumeScale.x;
                fogVolumeScale.z = fogVolumeScale.x;
            }

            if (CastShadows)
            {
                FogVolumeGameObject.layer = LayerMask.NameToLayer("FogVolumeShadowCaster");
            }
            // else
            //  FogVolumeGameObject.layer = LayerMask.NameToLayer("FogVolume");
            //if (!CastShadows && !RT_Opacity)
            //    FogMaterial.SetTexture("LightshaftTex", null);

            if (CastShadows && ShadowCaster)
                FogMaterial.DisableKeyword("VOLUME_SHADOWS");
            if (ShadowCaster && ShadowCaster.CastShadows || FogRenderer.receiveShadows)
                FogMaterial.EnableKeyword("VOLUME_SHADOWS");

            if (ShadowCaster && !ShadowCaster.CastShadows || !FogRenderer.receiveShadows)
                FogMaterial.DisableKeyword("VOLUME_SHADOWS");


        }
    }

    public bool CreateSurrogate = true;



    //  private float m_cameraNearClipPlane = 0.0f;
    // private float m_cameraFarClipPlane = 0.0f;
    public bool InjectCustomDepthBuffer = false;
    void Update()
    {

        //External depth:
        if (InjectCustomDepthBuffer && FogMaterial.IsKeywordEnabled("ExternalDepth") == false && ExcludeFromLowRes)
        {
            FogMaterial.EnableKeyword("ExternalDepth");
            //  Debug.Log("Enabled keyword ExternalDepth");
        }

        if (FogMaterial.IsKeywordEnabled("ExternalDepth") == true && ExcludeFromLowRes && !InjectCustomDepthBuffer)
        {
            FogMaterial.DisableKeyword("ExternalDepth");
            //  Debug.Log("Disabled keyword ExternalDepth");
        }
        //Debug.Log("Rendering " + gameObject.name + "\n Layer: " + LayerMask.LayerToName(gameObject.layer) + "\n External depth keyword: " + FogMaterial.IsKeywordEnabled("ExternalDepth"));

        //#if UNITY_EDITOR
        if (GameCamera == null)
            AssignCamera();
        //#endif

        m_lightManager.DrawDebugData = ShowDebugGizmos;
        if (PointLightCullSizeMultiplier < 1.0f) { PointLightCullSizeMultiplier = 1.0f; }
        m_lightManager.SetPointLightCullSizeMultiplier(PointLightCullSizeMultiplier);

        if (GameCamera != null)
        {
            //if ((GameCamera.nearClipPlane != m_cameraNearClipPlane) ||
            //        (GameCamera.farClipPlane != m_cameraFarClipPlane))
            //{
            //   m_cameraNearClipPlane = GameCamera.nearClipPlane;
            //    m_cameraFarClipPlane = GameCamera.farClipPlane;
            FrustumPlanes = GeometryUtility.CalculateFrustumPlanes(GameCamera);
            // }


            if (Application.isPlaying)
            {
                if (GeometryUtility.TestPlanesAABB(FrustumPlanes, _BoxCollider.bounds))
                {
                    IsVisible = true;
                    //  Debug.Log(gameObject.name + " Visible by "+ GameCamera.name);
                }
                else
                {
                    IsVisible = false;
                    //  Debug.Log(gameObject.name + " Not visible by " + GameCamera.name);
                }
            }

            else

                IsVisible = true;
        }
      //  print(IsVisible);
        if (EnableNoise || EnableGradient)
            _FogType = FogType.Textured;
        else
            _FogType = FogType.Uniform;

#if UNITY_EDITOR
        UpdateBoxMesh();
        ShadowProjectorLock();
        Visibility = Mathf.Max(1, Visibility);
        IterationStep = Mathf.Max(1, IterationStep);
        //InscatteringIntensity = Mathf.Max(0, InscatteringIntensity);
        //NoiseIntensity = Mathf.Max(0, NoiseIntensity);
        InscatteringTransitionWideness = Mathf.Max(1, InscatteringTransitionWideness);
        InscatteringStartDistance = Mathf.Max(0, InscatteringStartDistance);
        if (_NoiseVolume == null)
            EnableNoise = false;

        fogVolumeScale.x = Mathf.Max(fogVolumeScale.x, .001f);
        fogVolumeScale.y = Mathf.Max(fogVolumeScale.y, .001f);
        fogVolumeScale.z = Mathf.Max(fogVolumeScale.z, .001f);

        if (ShadowProjector == null && CastShadows)
        {
            // print("ShadowMapSetup()");
            ShadowMapSetup();
        }
        SetShadowProyectorLayer();
        if (!Sun) FindDirectionalLight();

        MoveToLayer();

#if UNITY_EDITOR
        StaticEditorFlags flags;
        flags = GameObjectUtility.GetStaticEditorFlags(gameObject);
        if (_VisibleByReflectionProbeStatic && GameObjectUtility.GetStaticEditorFlags(gameObject) != StaticEditorFlags.ReflectionProbeStatic)
        {
            //print("Fog Volume visible for Static reflection probes");
            GameObjectUtility.SetStaticEditorFlags(gameObject, StaticEditorFlags.ReflectionProbeStatic);
        }

        if (!_VisibleByReflectionProbeStatic && flags == StaticEditorFlags.ReflectionProbeStatic)
        {
            // print("Fog Volume not visible for Static reflection probes");
            flags = flags & ~StaticEditorFlags.ReflectionProbeStatic;
            GameObjectUtility.SetStaticEditorFlags(gameObject, flags);
        }
#endif
#endif

        RenderSurrogate();
        if (ShadowProjector != null && CastShadows)
        {

            //  ShadowProjectorMaterial.SetTexture("_MainTex", RT_OpacityBlur);

            ShadowProjectorMaterial.SetColor("_ShadowColor", ShadowColor);
        }
        // FogMaterial.SetTexture("LightshaftTex", RT_Opacity);
        //if (Camera.current != null)
        //{
        //    Vector3 ForwardCameraVector = Camera.current.transform.forward;
        //    FogMaterial.SetVector("_SliceNormal", ForwardCameraVector);
        //    print(ForwardCameraVector);
        //}
        //
        if (FogMaterial.GetTexture("_NoiseVolume") == null && _NoiseVolume != null || FogMaterial.GetTexture("_NoiseVolume") != _NoiseVolume)
        {
            FogMaterial.SetTexture("_NoiseVolume", _NoiseVolume);
            // Debug.Log("Updating tex");
        }
        if (FogMaterial.GetTexture("_NoiseVolume2") == null && _NoiseVolume2 != null || FogMaterial.GetTexture("_NoiseVolume2") != _NoiseVolume2)
        {
            FogMaterial.SetTexture("_NoiseVolume2", _NoiseVolume2);

        }

        if (FogMaterial.GetTexture("CoverageTex") == null && CoverageTex != null || FogMaterial.GetTexture("CoverageTex") != CoverageTex)
        {
            FogMaterial.SetTexture("CoverageTex", CoverageTex);

        }

        //GetComponent<LightProbeProxyVolume>().Update();
    }

    public void RenderSurrogate()
    {

        if (IsVisible)
        {
            if (GameCameraGO == null) AssignCamera();
            var renderer = GameCameraGO.GetComponent<FogVolumeRenderer>();
            if (renderer == null)
            {
                if (!_FogVolumeData.ForceNoRenderer)
                {
                    renderer = GameCameraGO.AddComponent<FogVolumeRenderer>();
                    renderer.enabled = true;
                }
            }
            if (!_FogVolumeData.ForceNoRenderer && renderer._Downsample > 0 && CreateSurrogate && mesh != null &&
                _FogType == FogVolume.FogType.Textured)
            {

                Graphics.DrawMesh(mesh, transform.position, transform.rotation, SurrogateMaterial,
                        LayerMask.NameToLayer("FogVolumeSurrogate"),
                        //GameCamera,//it blinks
                        null,
                        0, null, false, false, false);

                //  if(EnableNoise)
                //  FogMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
            }

        }
    }

    void UpdateParams()
    {
        if (IsVisible)
        {
            if (_PerformanceLUT && _DebugMode == DebugMode.Iterations)
                FogMaterial.SetTexture("_PerformanceLUT", _PerformanceLUT);

            if (_DebugMode != DebugMode.Lit)
                FogMaterial.SetInt("_DebugMode", (int)_DebugMode);

            if (FogType.Textured == _FogType)
            {
                FogMaterial.SetInt("_SrcBlend", (int)_BlendMode);
                //  print((int)_BlendMode);
            }
            else
                //set it as standard alpha blend for uniform fog
                FogMaterial.SetInt("_SrcBlend", (int)FogVolumeRenderer.BlendMode.TraditionalTransparency);
            FogMaterial.SetInt("_ztest", (int)_ztest);

            Profiler.BeginSample("FogVolume Pointlights update");
            if (m_lightManager != null)
            {
                if (m_lightManager.CurrentLightCount > 0 &&
                        PointLightsActive &&
                        SystemInfo.graphicsShaderLevel > 30)
                {
                    FogMaterial.SetVectorArray("_LightPositions",
                                                                         m_lightManager.GetLightPositionArray());
                    FogMaterial.SetVectorArray("_LightRotations", m_lightManager.GetLightRotationArray());
                    FogMaterial.SetColorArray("_LightColors", m_lightManager.GetLightColorArray());
                    FogMaterial.SetVectorArray("_LightData", m_lightManager.GetLightData());

                    FogMaterial.SetFloat("PointLightingDistance", 1.0f / PointLightingDistance);//spherical range clamp
                    FogMaterial.SetFloat("PointLightingDistance2Camera",
                                                                1.0f / PointLightingDistance2Camera);//draw distance


                }
            }
            Profiler.EndSample();
            Profiler.BeginSample("FogVolume Primitives update");
            if (PrimitivesList != null)
                if (PrimitivesList.Count > 0 && EnableDistanceFields)
                {
                    FogMaterial.SetFloat("Constrain", Constrain);
                    FogMaterial.SetVectorArray("_PrimitivePosition", GetPrimitivesPositions());
                    FogMaterial.SetVectorArray("_PrimitiveScale", GetPrimitivesScale());
                    FogMaterial.SetInt("_PrimitiveCount", PrimitivesList.Count);
                    FogMaterial.SetMatrixArray("_PrimitivesTransform", GetPrimitivesTransform());
                    FogMaterial.SetFloat("_PrimitiveEdgeSoftener", 1 / _PrimitiveEdgeSoftener);
                    FogMaterial.SetFloat("_PrimitiveCutout", _PrimitiveCutout);
                }
            Profiler.EndSample();
            Profiler.BeginSample("FogVolume PARAMETERS");
            //  FogMaterial.SetVector("_CameraForward", Camera.current.transform.forward);

            if (Sun && Sun.enabled)
            {
                FogMaterial.SetFloat("_LightExposure", _LightExposure);
                if (LightHalo && _LightHaloTexture)
                {
                    FogMaterial.SetTexture("_LightHaloTexture", _LightHaloTexture);
                    FogMaterial.SetFloat("_HaloOpticalDispersion", _HaloOpticalDispersion);
                    FogMaterial.SetFloat("_HaloWidth", _HaloWidth.Remap(0, 1, 10, 1));
                    FogMaterial.SetFloat("_HaloIntensity", _HaloIntensity * 2000);
                    FogMaterial.SetFloat("_HaloRadius", _HaloRadius.Remap(0, 1, 2, .1f));
                    FogMaterial.SetFloat("_HaloAbsorption", _HaloAbsorption.Remap(0, 1, 0, 16));
                }

                FogMaterial.SetVector("L", -Sun.transform.forward);
                Shader.SetGlobalVector("L", -Sun.transform.forward);
                FogMaterial.SetVector("_LightLocalDirection", LocalDirectionalSunLight(Sun));

                if (EnableInscattering)
                {
                    FogMaterial.SetFloat("_InscatteringIntensity", InscatteringIntensity * 50);
                    FogMaterial.SetFloat("InscatteringShape", InscatteringShape);
                    FogMaterial.SetFloat("InscatteringTransitionWideness", InscatteringTransitionWideness);
                    FogMaterial.SetColor("_InscatteringColor", InscatteringColor);
                }

                if (VolumeFogInscattering)
                {
                    FogMaterial.SetFloat("VolumeFogInscatteringIntensity", VolumeFogInscatteringIntensity * 50);
                    FogMaterial.SetFloat("VolumeFogInscatteringAnisotropy", VolumeFogInscatteringAnisotropy);
                    FogMaterial.SetColor("VolumeFogInscatteringColor", VolumeFogInscatteringColor);
                    VolumeFogInscatteringStartDistance = Mathf.Max(0, VolumeFogInscatteringStartDistance);
                    FogMaterial.SetFloat("VolumeFogInscatteringStartDistance", VolumeFogInscatteringStartDistance);
                    VolumeFogInscatteringTransitionWideness = Mathf.Max(.01f, VolumeFogInscatteringTransitionWideness);
                    FogMaterial.SetFloat("VolumeFogInscatteringTransitionWideness", VolumeFogInscatteringTransitionWideness);
                }

                FogMaterial.SetColor("_LightColor", Sun.color * Sun.intensity);

                if (EnableNoise && _NoiseVolume != null)
                {
                    FogMaterial.SetFloat("_NoiseDetailRange", _NoiseDetailRange * 1f);
                    FogMaterial.SetFloat("_Curl", _Curl);
                    if (_DirectionalLighting)
                    {
                        FogMaterial.SetFloat("_DirectionalLightingDistance", _DirectionalLightingDistance);
                        //FogMaterial.SetFloat("DirectionalLightingClamp", DirectionalLightingClamp);
                        FogMaterial.SetInt("DirectLightingShadowSteps", DirectLightingShadowSteps);
                        FogMaterial.SetFloat("DirectLightingShadowDensity", DirectLightingShadowDensity);
                    }
                }
            }
            FogMaterial.SetFloat("_Cutoff", ShadowCutoff);
            FogMaterial.SetFloat("Absorption", Absorption);
            LightExtinctionColor.r = Mathf.Max(.1f, LightExtinctionColor.r);
            LightExtinctionColor.g = Mathf.Max(.1f, LightExtinctionColor.g);
            LightExtinctionColor.b = Mathf.Max(.1f, LightExtinctionColor.b);
            FogMaterial.SetColor("LightExtinctionColor", LightExtinctionColor);
            //if (Procedural)
            //    FogMaterial.EnableKeyword("USE_PROCEDURAL");
            //else
            //    FogMaterial.DisableKeyword("USE_PROCEDURAL");

            //if (EnableNoise && _NoiseVolume)
            //{
            if (Vortex > 0)
            {
                FogMaterial.SetFloat("_Vortex", Vortex);
                FogMaterial.SetFloat("_Rotation", Mathf.Deg2Rad * rotation);
                FogMaterial.SetFloat("_RotationSpeed", -RotationSpeed);
            }
            DetailDistance = Mathf.Max(1, DetailDistance);
            FogMaterial.SetFloat("DetailDistance", DetailDistance);
            FogMaterial.SetFloat("Octaves", Octaves);
            FogMaterial.SetFloat("_DetailMaskingThreshold", _DetailMaskingThreshold);
            //FogMaterial.SetFloat("_DetailSamplingBaseOpacityLimit", DetailSamplingBaseOpacityLimit);
            // FogMaterial.SetTexture("_NoiseVolume", _NoiseVolume);
            //FogMaterial.SetTexture("noise2D", noise2D);
            FogMaterial.SetVector("_VolumePosition", gameObject.transform.position);
            FogMaterial.SetFloat("gain", NoiseIntensity);
            FogMaterial.SetFloat("threshold", NoiseContrast * 0.5f - 5);
            FogMaterial.SetFloat("_3DNoiseScale", _3DNoiseScale * .001f);
            FadeDistance = Mathf.Max(1, FadeDistance);
            FogMaterial.SetFloat("FadeDistance", FadeDistance);
            FogMaterial.SetFloat("STEP_COUNT", Iterations);
            FogMaterial.SetFloat("DetailTiling", DetailTiling);
            FogMaterial.SetFloat("BaseTiling", BaseTiling * .1f);
            FogMaterial.SetFloat("Coverage", Coverage);
            FogMaterial.SetFloat("NoiseDensity", NoiseDensity);
            FogMaterial.SetVector("Speed", Speed * .1f);
            FogMaterial.SetVector("Stretch", new Vector4(1, 1, 1, 1) + Stretch * .01f);
            if (useHeightGradient)
            {
                //FogMaterial.SetFloat("GradMin", GradMin);
                // FogMaterial.SetFloat("GradMax", GradMax);
                FogMaterial.SetVector("_VerticalGradientParams", new Vector4(GradMin, GradMax, GradMin2, GradMax2));
            }
            FogMaterial.SetColor("_AmbientColor", _AmbientColor);

            if (FogRenderer.lightProbeUsage == UnityEngine.Rendering.LightProbeUsage.UseProxyVolume)
                _ProxyVolume = true;
            else _ProxyVolume = false;

            FogMaterial.SetFloat("_ProxyVolume", _ProxyVolume == false ? 0 : 1);
            //FogMaterial.SetFloat("Shade", Shade);
            FogMaterial.SetFloat("ShadowBrightness", ShadowBrightness);
            FogMaterial.SetFloat("_DetailRelativeSpeed", _DetailRelativeSpeed);
            FogMaterial.SetFloat("_BaseRelativeSpeed", _BaseRelativeSpeed);
            if (bSphericalFade)
            {
                SphericalFadeDistance = Mathf.Max(1, SphericalFadeDistance);
                FogMaterial.SetFloat("SphericalFadeDistance", SphericalFadeDistance);
            }
            FogMaterial.SetVector("VolumeSize", new Vector4(fogVolumeScale.x, fogVolumeScale.y, fogVolumeScale.z, 0));
            // }

            FogMaterial.SetFloat("Exposure", Mathf.Max(0, Exposure));
            FogMaterial.SetFloat("Offset", Offset);
            FogMaterial.SetFloat("Gamma", Gamma);
            if (Gradient != null)
                FogMaterial.SetTexture("_Gradient", Gradient);

            FogMaterial.SetFloat("InscatteringStartDistance", InscatteringStartDistance);
            Vector3 VolumeSize = currentFogVolume;
            FogMaterial.SetVector("_BoxMin", VolumeSize * -.5f);
            FogMaterial.SetVector("_BoxMax", VolumeSize * .5f);
            FogMaterial.SetColor("_Color", FogMainColor);
            FogMaterial.SetColor("_FogColor", _FogColor);
            FogMaterial.SetInt("_AmbientAffectsFogColor", _AmbientAffectsFogColor ? 1 : 0);
            //FogMaterial.SetFloat("_SceneIntersectionThreshold", _SceneIntersectionThreshold);

            FogMaterial.SetFloat("_SceneIntersectionSoftness", _SceneIntersectionSoftness);
            //        FogMaterial.SetFloat("_RayStep", IterationStep * .001f);
            FogMaterial.SetFloat("_RayStep", IterationStep * .001f);
            FogMaterial.SetFloat("_OptimizationFactor", _OptimizationFactor);
            FogMaterial.SetFloat("_Visibility", bVolumeFog && EnableNoise &&
                    _NoiseVolume || EnableGradient ? Visibility * 100 : Visibility);
            FogRenderer.sortingOrder = DrawOrder;
            FogMaterial.SetInt("VolumeFogInscatterColorAffectedWithFogColor", VolumeFogInscatterColorAffectedWithFogColor ? 1 : 0);
            FogMaterial.SetFloat("_FOV", GameCamera.fieldOfView);
            FogMaterial.SetFloat("HeightAbsorption", HeightAbsorption);
            FogMaterial.SetVector("_AmbientHeightAbsorption", new Vector4(HeightAbsorptionMin, HeightAbsorptionMax, HeightAbsorption, 0));
            FogMaterial.SetFloat("NormalDistance", NormalDistance);
            FogMaterial.SetFloat("DirectLightingAmount", DirectLightingAmount);
            DirectLightingDistance = Mathf.Max(1, DirectLightingDistance);
            FogMaterial.SetFloat("DirectLightingDistance", DirectLightingDistance);
            FogMaterial.SetFloat("LambertianBias", LambertianBias);
            //if (SceneCollision)
            FogMaterial.SetFloat("_jitter", _jitter);
            FogMaterial.SetInt("SamplingMethod", (int)_SamplingMethod);

            //if (_FogVolumeRenderer)
                FogMaterial.SetFloat("_PushAlpha", _PushAlpha);

            if (_ShadeNoise && EnableNoise)
            {
                FogMaterial.SetColor("_SelfShadowColor", _SelfShadowColor);
                FogMaterial.SetInt("_SelfShadowSteps", _SelfShadowSteps);
                FogMaterial.SetFloat("ShadowShift", ShadowShift);
            }

            Profiler.EndSample();
        }
    }
    void LateUpdate()
    {

    }

    public bool UseConvolvedLightshafts = false;

    void OnRenderObject()
    {
#if UNITY_EDITOR
        SurrogateMaterial.DisableKeyword("_EDITOR_WINDOW");
#endif
    }

    void OnWillRenderObject()
    {
        GetShadowMap();

#if UNITY_EDITOR
        ToggleKeyword();
        //since I can not set a Camera in DrawMesh (It blinks all the time), I have to make the surrogate not visible in Scene view

        SurrogateMaterial.EnableKeyword("_EDITOR_WINDOW");

        Wireframe(FogVolumeGameObject, HideWireframe);

        if (ShadowProjector != null)
            ShadowProjector.SetActive(CastShadows);

        //3.1.8 added && !ShadowCaster
        if (ShadowCameraGO != null && !ShadowCaster)
            ShadowCameraGO.SetActive(CastShadows);

        //  FogMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
#endif
        // if (SystemInfo.graphicsShaderLevel < 40) PointLightsActive = false;
        if (PointLightsActive && SystemInfo.graphicsShaderLevel > 30)
        {
            _InitializeLightManagerIfNeccessary();
            if (m_lightManager != null)
            {
                if (PointLightsRealTimeUpdate)
                {
                    m_lightManager.Deinitialize();
                    if (PointLightBoxCheck) { m_lightManager.FindLightsInFogVolume(); }
                    else { m_lightManager.FindLightsInScene(); }
                }

                if (m_lightManager.AlreadyUsesTransformForPoI == false)
                {
                    m_lightManager.SetPointOfInterest(_FogVolumeData.GameCamera.transform);
                }

                m_lightManager.ManualUpdate();
            }
            FogMaterial.SetInt("_LightsCount", GetVisibleLightCount());
        }
        else { _DeinitializeLightManagerIfNeccessary(); }
        //  else
        //     FogMaterial.SetInt("_LightsCount", 0);

        if (EnableDistanceFields)
            CreatePrimitiveList();

        //3.1.7 maybe not!
        //else
        //if (PrimitivesList != null)
        //    if (PrimitivesList.Count > 0)
        //        PrimitivesList.Clear();

        if (RT_Opacity != null)
        {

            Shader.SetGlobalTexture("RT_Opacity", RT_Opacity);

            if (UseConvolvedLightshafts)
            {
                FogMaterial.SetTexture("LightshaftTex", RT_OpacityBlur);

            }
            else
            {
                FogMaterial.SetTexture("LightshaftTex", RT_Opacity);

            }
        }

        UpdateParams();
        if (!RenderableInSceneView && (Camera.current.name == "SceneCamera"))
        {
            //			FogMaterial.EnableKeyword("RENDER_SCENE_VIEW");
            FogMaterial.SetVector("_BoxMin", new Vector3(0, 0, 0));
            FogMaterial.SetVector("_BoxMax", new Vector3(0, 0, 0));
        }
        else
        {
            //			FogMaterial.DisableKeyword("RENDER_SCENE_VIEW");
            FogMaterial.SetVector("_BoxMin", currentFogVolume * -.5f);
            FogMaterial.SetVector("_BoxMax", currentFogVolume * .5f);
        }

        //FogMaterial.DisableKeyword("RENDER_SCENE_VIEW");
    }

    void ToggleKeyword()
    {
        if (IsVisible)
        {
            Profiler.BeginSample("FogVolume KEYWORDS");

            if (_jitter > 0)
                FogMaterial.EnableKeyword("JITTER");
            else
                FogMaterial.DisableKeyword("JITTER");

            if (_DebugMode != DebugMode.Lit)
                FogMaterial.EnableKeyword("DEBUG");
            else
                FogMaterial.DisableKeyword("DEBUG");

            switch (_SamplingMethod)
            {
                case SamplingMethod.Eye2Box:
                    FogMaterial.DisableKeyword("SAMPLING_METHOD_ViewAligned");
                    FogMaterial.EnableKeyword("SAMPLING_METHOD_Eye2Box");
                    break;

                case SamplingMethod.ViewAligned:
                    FogMaterial.EnableKeyword("SAMPLING_METHOD_ViewAligned");
                    FogMaterial.DisableKeyword("SAMPLING_METHOD_Eye2Box");
                    break;
            }


            if (LightHalo && _LightHaloTexture)
                FogMaterial.EnableKeyword("HALO");
            else
                FogMaterial.DisableKeyword("HALO");

            if (ShadowCaster != null)
            {
                if (ShadowCaster.SunAttached == true)
                {
                    FogMaterial.EnableKeyword("LIGHT_ATTACHED");
                }
                if (ShadowCaster.SunAttached == false)
                {
                    FogMaterial.DisableKeyword("LIGHT_ATTACHED");

                }
            }

            if (Vortex > 0)
            {
                FogMaterial.EnableKeyword("Twirl");
                //print((int)_VortexAxis);
                switch (_VortexAxis)
                {
                    case VortexAxis.X:
                        FogMaterial.EnableKeyword("Twirl_X");
                        FogMaterial.DisableKeyword("Twirl_Y");
                        FogMaterial.DisableKeyword("Twirl_Z");
                        break;

                    case VortexAxis.Y:
                        FogMaterial.DisableKeyword("Twirl_X");
                        FogMaterial.EnableKeyword("Twirl_Y");
                        FogMaterial.DisableKeyword("Twirl_Z");
                        break;

                    case VortexAxis.Z:
                        FogMaterial.DisableKeyword("Twirl_X");
                        FogMaterial.DisableKeyword("Twirl_Y");
                        FogMaterial.EnableKeyword("Twirl_Z");
                        break;
                }
            }
            else
            {
                FogMaterial.DisableKeyword("Twirl_X");
                FogMaterial.DisableKeyword("Twirl_Y");
                FogMaterial.DisableKeyword("Twirl_Z");
            }
            if (Lambert && Sun && EnableNoise)
                FogMaterial.EnableKeyword("_LAMBERT_SHADING");
            else
                FogMaterial.DisableKeyword("_LAMBERT_SHADING");





            //POINTLIGHTS
            if (/*PointLightsList != null && PointLightsList.Count > 0 &&*/
                     PointLightsActive && SystemInfo.graphicsShaderLevel > 30)
            {
                // FogMaterial.EnableKeyword("POINTLIGHTS");//not in use anymore, not needed

                switch (_LightScatterMethod)
                {
                    case LightScatterMethod.BeersLaw:
                        FogMaterial.EnableKeyword("ATTEN_METHOD_1");
                        FogMaterial.DisableKeyword("ATTEN_METHOD_2");
                        FogMaterial.DisableKeyword("ATTEN_METHOD_3");
                        // FogMaterial.DisableKeyword("ATTEN_METHOD_4");
                        break;

                    case LightScatterMethod.InverseSquare:
                        FogMaterial.DisableKeyword("ATTEN_METHOD_1");
                        FogMaterial.EnableKeyword("ATTEN_METHOD_2");
                        FogMaterial.DisableKeyword("ATTEN_METHOD_3");
                        // FogMaterial.DisableKeyword("ATTEN_METHOD_4");
                        break;

                    //case LightScatterMethod.Gaussian:
                    //    FogMaterial.DisableKeyword("ATTEN_METHOD_1");
                    //    FogMaterial.DisableKeyword("ATTEN_METHOD_2");
                    //    FogMaterial.EnableKeyword("ATTEN_METHOD_3");
                    //    FogMaterial.DisableKeyword("ATTEN_METHOD_4");
                    //    break;


                    case LightScatterMethod.Linear:
                        FogMaterial.DisableKeyword("ATTEN_METHOD_1");
                        FogMaterial.DisableKeyword("ATTEN_METHOD_2");
                        FogMaterial.EnableKeyword("ATTEN_METHOD_3");
                        // FogMaterial.EnableKeyword("ATTEN_METHOD_4");
                        break;
                }
            }
            else
            {
                FogMaterial.DisableKeyword("ATTEN_METHOD_1");
                FogMaterial.DisableKeyword("ATTEN_METHOD_2");
                FogMaterial.DisableKeyword("ATTEN_METHOD_3");
            }

            //////////////////
            if (EnableNoise && _NoiseVolume && useHeightGradient)
                FogMaterial.EnableKeyword("HEIGHT_GRAD");
            else
                FogMaterial.DisableKeyword("HEIGHT_GRAD");

            if (ColorAdjust)
                FogMaterial.EnableKeyword("ColorAdjust");
            else
                FogMaterial.DisableKeyword("ColorAdjust");

            if (bVolumeFog)
                FogMaterial.EnableKeyword("VOLUME_FOG");
            else
                FogMaterial.DisableKeyword("VOLUME_FOG");

            if (FogMaterial)
            {
                if (EnableGradient && Gradient != null)
                    FogMaterial.EnableKeyword("_FOG_GRADIENT");
                else
                    FogMaterial.DisableKeyword("_FOG_GRADIENT");

                if (EnableNoise && !SystemInfo.supports3DTextures)
                    Debug.Log("Noise not supported. SM level found: " + SystemInfo.graphicsShaderLevel / 10);

                if (EnableNoise && SystemInfo.supports3DTextures)
                    FogMaterial.EnableKeyword("_FOG_VOLUME_NOISE");
                else
                {
                    FogMaterial.DisableKeyword("_FOG_VOLUME_NOISE");
                }

                if (EnableInscattering && Sun && Sun.enabled && Sun.isActiveAndEnabled)
                    FogMaterial.EnableKeyword("_INSCATTERING");
                else
                    FogMaterial.DisableKeyword("_INSCATTERING");

                if (VolumeFogInscattering && Sun && Sun.enabled && bVolumeFog)
                    FogMaterial.EnableKeyword("_VOLUME_FOG_INSCATTERING");
                else
                    FogMaterial.DisableKeyword("_VOLUME_FOG_INSCATTERING");

                //if (SceneCollision)
                FogMaterial.SetFloat("Collisions", SceneCollision ? 1 : 0);
                // FogMaterial.EnableKeyword("_COLLISION");
                // else
                // FogMaterial.DisableKeyword("_COLLISION");

                if (ShadowShift > 0 && EnableNoise && Sun && _ShadeNoise)
                    FogMaterial.EnableKeyword("_SHADE");
                else
                    FogMaterial.DisableKeyword("_SHADE");

                //if (EnableNoise && DoubleLayer && SystemInfo.supports3DTextures)
                //    FogMaterial.EnableKeyword("_DOUBLE_LAYER");
                //else
                //    FogMaterial.DisableKeyword("_DOUBLE_LAYER");

                if (Tonemap)
                    FogMaterial.EnableKeyword("_TONEMAP");
                else
                    FogMaterial.DisableKeyword("_TONEMAP");

                if (bSphericalFade)
                    FogMaterial.EnableKeyword("SPHERICAL_FADE");
                else
                    FogMaterial.DisableKeyword("SPHERICAL_FADE");

                if (PrimitivesList != null && PrimitivesList.Count > 0 && EnableDistanceFields)
                    FogMaterial.EnableKeyword("DF");
                else
                    FogMaterial.DisableKeyword("DF");

                if (bAbsorption)
                    FogMaterial.EnableKeyword("ABSORPTION");
                else
                    FogMaterial.DisableKeyword("ABSORPTION");

                if (_DirectionalLighting && EnableNoise && _NoiseVolume != null && _DirectionalLightingDistance > 0 && DirectLightingShadowDensity > 0)
                    FogMaterial.EnableKeyword("DIRECTIONAL_LIGHTING");
                else
                    FogMaterial.DisableKeyword("DIRECTIONAL_LIGHTING");
            }
            Profiler.EndSample();
        }
    }


    public void UpdateBoxMesh()
    {
        if (currentFogVolume != fogVolumeScale || filter == null)
        {
            CreateBoxMesh(fogVolumeScale);
            //update shadow camera too
            ShadowMapSetup();
            //update collider bounds
            _BoxCollider.size = fogVolumeScale;
            m_hasUpdatedBoxMesh = true;
        }
        transform.localScale = Vector3.one;//otherwise, it won't work correctly
    }

    public bool HasUpdatedBoxMesh
    {
        get
        {
            bool ret = m_hasUpdatedBoxMesh;
            m_hasUpdatedBoxMesh = false;
            return ret;
        }
    }

    private bool m_hasUpdatedBoxMesh = false;

    void CreateBoxMesh(Vector3 scale)
    {
        currentFogVolume = scale;

        // You can change that line to provide another MeshFilter
        if (filter == null)
            filter = gameObject.AddComponent<MeshFilter>();

        if (mesh == null)
        {
            mesh = new Mesh();
            mesh.name = gameObject.name;
            filter.sharedMesh = mesh;
        }
        mesh.Clear();



        float width = scale.y;
        float height = scale.z;
        float length = scale.x;

        #region Vertices
        Vector3 p0 = new Vector3(-length * .5f, -width * .5f, height * .5f);
        Vector3 p1 = new Vector3(length * .5f, -width * .5f, height * .5f);
        Vector3 p2 = new Vector3(length * .5f, -width * .5f, -height * .5f);
        Vector3 p3 = new Vector3(-length * .5f, -width * .5f, -height * .5f);

        Vector3 p4 = new Vector3(-length * .5f, width * .5f, height * .5f);
        Vector3 p5 = new Vector3(length * .5f, width * .5f, height * .5f);
        Vector3 p6 = new Vector3(length * .5f, width * .5f, -height * .5f);
        Vector3 p7 = new Vector3(-length * .5f, width * .5f, -height * .5f);

        Vector3[] vertices = new Vector3[]
                {
		// Bottom
				p0, p1, p2, p3,
				
		// Left
				p7, p4, p0, p3,
				
		// Front
				p4, p5, p1, p0,
				
		// Back
				p6, p7, p3, p2,
				
		// Right
				p5, p6, p2, p1,
				
		// Top
				p7, p6, p5, p4
                };
        #endregion

        #region Normales
        Vector3 up = Vector3.up;
        Vector3 down = Vector3.down;
        Vector3 front = Vector3.forward;
        Vector3 back = Vector3.back;
        Vector3 left = Vector3.left;
        Vector3 right = Vector3.right;

        Vector3[] normales = new Vector3[]
        {
	// Bottom
	down, down, down, down,
 
	// Left
	left, left, left, left,
 
	// Front
	front, front, front, front,
 
	// Back
	back, back, back, back,
 
	// Right
	right, right, right, right,
 
	// Top
	up, up, up, up
        };
        #endregion

        #region UVs
        Vector2 _00 = new Vector2(0f, 0f);
        Vector2 _10 = new Vector2(1f, 0f);
        Vector2 _01 = new Vector2(0f, 1f);
        Vector2 _11 = new Vector2(1f, 1f);

        Vector2[] uvs = new Vector2[]
        {
	// Bottom
	_11, _01, _00, _10,
 
	// Left
	_11, _01, _00, _10,
 
	// Front
	_11, _01, _00, _10,
 
	// Back
	_11, _01, _00, _10,
 
	// Right
	_11, _01, _00, _10,
 
	// Top
	_11, _01, _00, _10,
        };
        #endregion

        #region Triangles
        int[] triangles = new int[]
                {
		// Bottom
				3, 1, 0,
                                3, 2, 1,			
				
		// Left
				3 + 4 * 1, 1 + 4 * 1, 0 + 4 * 1,
                                3 + 4 * 1, 2 + 4 * 1, 1 + 4 * 1,
				
		// Front
				3 + 4 * 2, 1 + 4 * 2, 0 + 4 * 2,
                                3 + 4 * 2, 2 + 4 * 2, 1 + 4 * 2,
				
		// Back
				3 + 4 * 3, 1 + 4 * 3, 0 + 4 * 3,
                                3 + 4 * 3, 2 + 4 * 3, 1 + 4 * 3,
				
		// Right
				3 + 4 * 4, 1 + 4 * 4, 0 + 4 * 4,
                                3 + 4 * 4, 2 + 4 * 4, 1 + 4 * 4,
				
		// Top
				3 + 4 * 5, 1 + 4 * 5, 0 + 4 * 5,
                                3 + 4 * 5, 2 + 4 * 5, 1 + 4 * 5,

                };
        #endregion

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.normals = normales;
        mesh.uv = uvs;
        mesh.RecalculateBounds();
        ;
    }
    //won't work if the icon is not in Assets/Gizmos
    //void OnDrawGizmosSelected()
    //{

    //    Gizmos.DrawIcon(transform.position, "FogVolume/Gizmos/FogVolumeIcon.png", true);
    //}


    private FogVolumeLightManager m_lightManager = null;


    private void _InitializeLightManagerIfNeccessary()
    {
        if (m_lightManager == null)
        {
            m_lightManager = GetComponent<FogVolumeLightManager>();
            if (m_lightManager == null)
            {
                m_lightManager = gameObject.AddComponent<FogVolumeLightManager>();
            }
            m_lightManager.Initialize();
            if (PointLightBoxCheck)
            {
                m_lightManager.FindLightsInFogVolume();
            }
            else
            {
                m_lightManager.FindLightsInScene();
            }

        }
    }


    private void _DeinitializeLightManagerIfNeccessary()
    {
        if (m_lightManager != null)
        {
            m_lightManager.Deinitialize();
        }
    }

    public int GetVisibleLightCount()
    {
        if (m_lightManager != null) { return m_lightManager.VisibleLightCount; }
        return 0;
    }
    public int GetTotalLightCount()
    {
        if (m_lightManager != null) { return m_lightManager.CurrentLightCount; }
        return 0;
    }

}

