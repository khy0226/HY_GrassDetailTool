Shader "Demo/TerrainGrassCode"
{
    Properties
    {
        [NoScaleOffset]Texture2D_E1B0D043("Base Map", 2D) = "white" {}
        [Normal][NoScaleOffset]Texture2D_9DCAAA49("Normal Map", 2D) = "bump" {}
        Vector1_a6983181c8dc4691ba6a28a34c4223a6("Normal Scale", Range(0, 5)) = 1
        [NoScaleOffset]Texture2D_A5E0646("Mask Map", 2D) = "white" {}
        Vector1_8651797e3e304e108dbd25f9d5a426ba("Smoothness Scale", Range(0, 1)) = 0.5
        Vector1_593c5cea6c4a42e993ed03ced4685732("AO Scale", Range(0, 4)) = 0.5
        _AORemap("AO Remap", Vector) = (0, 1, 0, 0)
        [NoScaleOffset]Texture2D_8713F080("Thickness Map", 2D) = "black" {}
        _Thickness_Remap("Thickness Remap", Vector) = (0, 1, 0, 0)
        Vector1_a5b8b09028ce49a39f4d090894c89e22("Alpha Clip Threshold", Range(0, 1)) = 0.5
        _FadeBias("FadeBias", Float) = 1
        [ToggleUI]_GrassNormal("GrassNormal", Float) = 0
        Distance_Fade_Start("Distance Fade Start", Float) = 40
        Distance_Fade_End("Distance Fade End", Float) = 150
        Fade_Color("Fade Color", Color) = (0, 0, 0, 0)
        Animation_Cutoff("Animation Cutoff", Float) = 100
        Wind_Speed("Wind Speed", Float) = 5
        Wind_Intensity("Wind Intensity", Float) = 0.1
        Wind_Turbulence("Wind Turbulence", Float) = 0
        Wind_Wavelength("Wind Wavelength", Float) = 10
        Wind_Blast("Wind Blast", Float) = 0.05
        Wind_Ripples("Wind Ripples", Float) = 0.05
        Wind_Yaw("Wind Yaw", Float) = 180
        _GroundFalloff("GroundFalloff", Float) = 1
        _SSS_Effect("SSS Effect", Float) = 3
        _SSS_Shadows("SSS Shadows", Float) = 0.5
        [HDR]_SSSColor("SSS Color", Color) = (1, 1, 1, 0)
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [HideInInspector]_WorkflowMode("_WorkflowMode", Float) = 1
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_ReceiveShadows("_ReceiveShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 1
        [HideInInspector]_BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 0
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 0
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
             float FaceSign;
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float4 packed_positionWS_BiasedFade : INTERP7;
             float4 packed_normalWS_Falloff : INTERP8;
             float3 TerrainColorMatch : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.packed_positionWS_BiasedFade.xyz = input.positionWS;
            output.packed_positionWS_BiasedFade.w = input.BiasedFade;
            output.packed_normalWS_Falloff.xyz = input.normalWS;
            output.packed_normalWS_Falloff.w = input.Falloff;
            output.TerrainColorMatch.xyz = input.TerrainColorMatch;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.packed_positionWS_BiasedFade.xyz;
            output.BiasedFade = input.packed_positionWS_BiasedFade.w;
            output.normalWS = input.packed_normalWS_Falloff.xyz;
            output.Falloff = input.packed_normalWS_Falloff.w;
            output.TerrainColorMatch = input.TerrainColorMatch.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        #include "Assets/Demo/Grass/Shader/CustomFunctions/PseudoSubsurface.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Divide_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Subtract_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A - B;
        }
        
        struct Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half
        {
        };
        
        void SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half _ProjectionSize, Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half IN, out half2 UVs_1)
        {
        half _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float = _ProjectionSize;
        half _Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float = _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float;
        half3 _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3;
        Unity_Divide_half3(SHADERGRAPH_OBJECT_POSITION, (_Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float.xxx), _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3);
        half3 _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3;
        Unity_Subtract_half3(_Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3, half3(0.5, 0.5, 0.5), _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3);
        half2 _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2 = _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3.xz;
        UVs_1 = _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2;
        }
        
        void Unity_Multiply_half4_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_half3(half3 A, half3 B, half3 T, out half3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Negate_half(half In, out half Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Branch_half3(half Predicate, half3 True, half3 False, out half3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalBlend_half(half3 A, half3 B, out half3 Out)
        {
            Out = SafeNormalize(half3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_NormalStrength_half(half3 In, half Strength, out half3 Out)
        {
            Out = half3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Remap_half(half In, half2 InMinMax, half2 OutMinMax, out half Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Negate_half3(half3 In, out half3 Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Absolute_half3(half3 In, out half3 Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float
        {
        };
        
        void SG_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float(float3 _WorldPosition, float3 _WorldNormal, float _SubsurfaceRadius, float _ShadowResponse, Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float IN, out half3 Out_Vector4_1)
        {
        float3 _Property_ea43e60c5fb644bb91c953fbd2dbeb97_Out_0_Vector3 = _WorldPosition;
        float3 _Property_f787854d379940b49846c9528a923395_Out_0_Vector3 = _WorldNormal;
        float _Property_df96f9c4b84e479bba8e78be04cb38d6_Out_0_Float = _SubsurfaceRadius;
        float _Property_2a98c51675fc4ff0b5d3f7c3e7fdd3c8_Out_0_Float = _ShadowResponse;
        half3 _PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3;
        PseudoSubsurface_half(_Property_ea43e60c5fb644bb91c953fbd2dbeb97_Out_0_Vector3, _Property_f787854d379940b49846c9528a923395_Out_0_Vector3, _Property_df96f9c4b84e479bba8e78be04cb38d6_Out_0_Float, _Property_2a98c51675fc4ff0b5d3f7c3e7fdd3c8_Out_0_Float, _PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3);
        half3 _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3;
        Unity_Absolute_half3(_PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3, _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3);
        Out_Vector4_1 = _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            half3 TerrainColorMatch;
            float BiasedFade;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half4 _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4 = Fade_Color;
            half _Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float = _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4.w;
            Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea;
            half2 _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2;
            SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half(2048), _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea, _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = half4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).tex, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).GetTransformedUV(_TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2), half(0));
            #endif
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_R_5_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.r;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_G_6_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.g;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_B_7_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.b;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_A_8_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.a;
            half4 _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4;
            Unity_Multiply_half4_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4);
            half4 _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4;
            Unity_Lerp_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4, (_Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float.xxxx), _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4);
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.TerrainColorMatch = (_Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4.xyz);
            description.BiasedFade = _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            half3 NormalTS;
            float3 Emission;
            half Metallic;
            half3 Specular;
            half Smoothness;
            float Occlusion;
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half3 _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            Unity_Lerp_half3((_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.xyz), IN.TerrainColorMatch, (half3(IN.BiasedFade.xxx)), _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3);
            half _Property_07deef7ebc9a4ce8b1912b03dda1a641_Out_0_Boolean = _GrassNormal;
            half3 _Vector3_f03ccace08754bb58f73fc24fa67a7e5_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half3 _Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3;
            {
                half3x3 tangentTransform = half3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3 = TransformWorldToTangent(_Vector3_f03ccace08754bb58f73fc24fa67a7e5_Out_0_Vector3.xyz, tangentTransform, true);
            }
            half _IsFrontFace_ffa786f3eaf044e985046a2068dbbf87_Out_0_Boolean = max(0, IN.FaceSign.x);
            UnityTexture2D _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_9DCAAA49);
            half4 _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.tex, _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.samplerstate, _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4);
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_R_4_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.r;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_G_5_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.g;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_B_6_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.b;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_A_7_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.a;
            half _Split_30812b2f0437422aaae34a09f0e2d341_R_1_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[0];
            half _Split_30812b2f0437422aaae34a09f0e2d341_G_2_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[1];
            half _Split_30812b2f0437422aaae34a09f0e2d341_B_3_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[2];
            half _Split_30812b2f0437422aaae34a09f0e2d341_A_4_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[3];
            half _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float;
            Unity_Negate_half(_Split_30812b2f0437422aaae34a09f0e2d341_B_3_Float, _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float);
            half3 _Vector3_94e14e0492524007bd0809af83c72798_Out_0_Vector3 = half3(_Split_30812b2f0437422aaae34a09f0e2d341_R_1_Float, _Split_30812b2f0437422aaae34a09f0e2d341_G_2_Float, _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float);
            half3 _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3;
            Unity_Branch_half3(_IsFrontFace_ffa786f3eaf044e985046a2068dbbf87_Out_0_Boolean, (_SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.xyz), _Vector3_94e14e0492524007bd0809af83c72798_Out_0_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3);
            half3 _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3;
            Unity_NormalBlend_half(_Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3, _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3);
            half3 _Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3;
            Unity_Branch_half3(_Property_07deef7ebc9a4ce8b1912b03dda1a641_Out_0_Boolean, _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3, _Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3);
            half _Property_3153e067a028407782c7fc60eec8a1ea_Out_0_Float = Vector1_a6983181c8dc4691ba6a28a34c4223a6;
            half3 _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3;
            Unity_NormalStrength_half(_Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3, _Property_3153e067a028407782c7fc60eec8a1ea_Out_0_Float, _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3);
            UnityTexture2D _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_8713F080);
            half4 _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.tex, _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.samplerstate, _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_R_4_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.r;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_G_5_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.g;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_B_6_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.b;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_A_7_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.a;
            half _OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float;
            Unity_OneMinus_half(_SampleTexture2D_417cd518c5ef42039a8069c9866332d8_R_4_Float, _OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float);
            half2 _Property_f87b8494d75448df932c6e590e3de59a_Out_0_Vector2 = _Thickness_Remap;
            half _Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float;
            Unity_Remap_half(_OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float, half2 (0, 1), _Property_f87b8494d75448df932c6e590e3de59a_Out_0_Vector2, _Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float);
            half _IsFrontFace_47618d1c56d0457bb678f769425bd3b5_Out_0_Boolean = max(0, IN.FaceSign.x);
            half3 _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3;
            Unity_Negate_half3(IN.WorldSpaceNormal, _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3);
            half3 _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3;
            Unity_Branch_half3(_IsFrontFace_47618d1c56d0457bb678f769425bd3b5_Out_0_Boolean, IN.WorldSpaceNormal, _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3, _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3);
            half _Property_f1dd973176ef4f79be2e1e91e5c76818_Out_0_Float = _SSS_Effect;
            half _Property_4d163902948249cabc9040bad8dcc4d9_Out_0_Float = _SSS_Shadows;
            Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea;
            half3 _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3;
            SG_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float(IN.WorldSpacePosition, _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3, _Property_f1dd973176ef4f79be2e1e91e5c76818_Out_0_Float, _Property_4d163902948249cabc9040bad8dcc4d9_Out_0_Float, _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea, _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3);
            half4 _Property_59ef6fd7b47644c1a370c943adf84674_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SSSColor) : _SSSColor;
            float3 _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3;
            Unity_Multiply_float3_float3(_PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3, (_Property_59ef6fd7b47644c1a370c943adf84674_Out_0_Vector4.xyz), _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3);
            float3 _Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3, _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3, _Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3);
            float4 _Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float.xxxx), (float4(_Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3, 1.0)), _Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4);
            UnityTexture2D _Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_A5E0646);
            half4 _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D.tex, _Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D.samplerstate, _Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_R_4_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.r;
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_G_5_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.g;
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_B_6_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.b;
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_A_7_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.a;
            half _Property_b644473d3cd24e3080f2805b814e9370_Out_0_Float = Vector1_8651797e3e304e108dbd25f9d5a426ba;
            half _Multiply_82755e28ff5447ea8b0979444e091870_Out_2_Float;
            Unity_Multiply_half_half(_SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_A_7_Float, _Property_b644473d3cd24e3080f2805b814e9370_Out_0_Float, _Multiply_82755e28ff5447ea8b0979444e091870_Out_2_Float);
            float _Split_2200434d6e2747218ba40e04c62ddbb4_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_2200434d6e2747218ba40e04c62ddbb4_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_2200434d6e2747218ba40e04c62ddbb4_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_2200434d6e2747218ba40e04c62ddbb4_A_4_Float = 0;
            half _Property_edb5a06f067e4b1f81889d39d13a8400_Out_0_Float = _GroundFalloff;
            float _Divide_c8f8819c97c84de9a1e5ff22544c7814_Out_2_Float;
            Unity_Divide_float(_Split_2200434d6e2747218ba40e04c62ddbb4_G_2_Float, _Property_edb5a06f067e4b1f81889d39d13a8400_Out_0_Float, _Divide_c8f8819c97c84de9a1e5ff22544c7814_Out_2_Float);
            float _Saturate_39d0ef87016444b69a7d2c21be9246bf_Out_1_Float;
            Unity_Saturate_float(_Divide_c8f8819c97c84de9a1e5ff22544c7814_Out_2_Float, _Saturate_39d0ef87016444b69a7d2c21be9246bf_Out_1_Float);
            float _Power_e7cec0f0c4b34626b9566fb858e90dab_Out_2_Float;
            Unity_Power_float(_Saturate_39d0ef87016444b69a7d2c21be9246bf_Out_1_Float, float(2), _Power_e7cec0f0c4b34626b9566fb858e90dab_Out_2_Float);
            float _Multiply_429cf9906d8e4ee081bcec9a64a71bb8_Out_2_Float;
            Unity_Multiply_float_float(_Power_e7cec0f0c4b34626b9566fb858e90dab_Out_2_Float, _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_G_5_Float, _Multiply_429cf9906d8e4ee081bcec9a64a71bb8_Out_2_Float);
            half2 _Property_ad18c7c390ca4897be81137c29d2ef6e_Out_0_Vector2 = _AORemap;
            float _Remap_aecc6283714446679f580896c2d20262_Out_3_Float;
            Unity_Remap_float(_Multiply_429cf9906d8e4ee081bcec9a64a71bb8_Out_2_Float, float2 (0, 1), _Property_ad18c7c390ca4897be81137c29d2ef6e_Out_0_Vector2, _Remap_aecc6283714446679f580896c2d20262_Out_3_Float);
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.BaseColor = _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            surface.NormalTS = _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3;
            surface.Emission = (_Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4.xyz);
            surface.Metallic = half(0);
            surface.Specular = IsGammaSpace() ? half3(0.5, 0.5, 0.5) : SRGBToLinear(half3(0.5, 0.5, 0.5));
            surface.Smoothness = _Multiply_82755e28ff5447ea8b0979444e091870_Out_2_Float;
            surface.Occlusion = _Remap_aecc6283714446679f580896c2d20262_Out_3_Float;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
             float FaceSign;
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float4 packed_positionWS_BiasedFade : INTERP7;
             float4 packed_normalWS_Falloff : INTERP8;
             float3 TerrainColorMatch : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.packed_positionWS_BiasedFade.xyz = input.positionWS;
            output.packed_positionWS_BiasedFade.w = input.BiasedFade;
            output.packed_normalWS_Falloff.xyz = input.normalWS;
            output.packed_normalWS_Falloff.w = input.Falloff;
            output.TerrainColorMatch.xyz = input.TerrainColorMatch;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.packed_positionWS_BiasedFade.xyz;
            output.BiasedFade = input.packed_positionWS_BiasedFade.w;
            output.normalWS = input.packed_normalWS_Falloff.xyz;
            output.Falloff = input.packed_normalWS_Falloff.w;
            output.TerrainColorMatch = input.TerrainColorMatch.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        #include "Assets/Demo/Grass/Shader/CustomFunctions/PseudoSubsurface.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Divide_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Subtract_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A - B;
        }
        
        struct Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half
        {
        };
        
        void SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half _ProjectionSize, Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half IN, out half2 UVs_1)
        {
        half _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float = _ProjectionSize;
        half _Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float = _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float;
        half3 _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3;
        Unity_Divide_half3(SHADERGRAPH_OBJECT_POSITION, (_Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float.xxx), _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3);
        half3 _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3;
        Unity_Subtract_half3(_Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3, half3(0.5, 0.5, 0.5), _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3);
        half2 _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2 = _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3.xz;
        UVs_1 = _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2;
        }
        
        void Unity_Multiply_half4_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_half3(half3 A, half3 B, half3 T, out half3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Negate_half(half In, out half Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Branch_half3(half Predicate, half3 True, half3 False, out half3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalBlend_half(half3 A, half3 B, out half3 Out)
        {
            Out = SafeNormalize(half3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_NormalStrength_half(half3 In, half Strength, out half3 Out)
        {
            Out = half3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Remap_half(half In, half2 InMinMax, half2 OutMinMax, out half Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Negate_half3(half3 In, out half3 Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Absolute_half3(half3 In, out half3 Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float
        {
        };
        
        void SG_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float(float3 _WorldPosition, float3 _WorldNormal, float _SubsurfaceRadius, float _ShadowResponse, Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float IN, out half3 Out_Vector4_1)
        {
        float3 _Property_ea43e60c5fb644bb91c953fbd2dbeb97_Out_0_Vector3 = _WorldPosition;
        float3 _Property_f787854d379940b49846c9528a923395_Out_0_Vector3 = _WorldNormal;
        float _Property_df96f9c4b84e479bba8e78be04cb38d6_Out_0_Float = _SubsurfaceRadius;
        float _Property_2a98c51675fc4ff0b5d3f7c3e7fdd3c8_Out_0_Float = _ShadowResponse;
        half3 _PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3;
        PseudoSubsurface_half(_Property_ea43e60c5fb644bb91c953fbd2dbeb97_Out_0_Vector3, _Property_f787854d379940b49846c9528a923395_Out_0_Vector3, _Property_df96f9c4b84e479bba8e78be04cb38d6_Out_0_Float, _Property_2a98c51675fc4ff0b5d3f7c3e7fdd3c8_Out_0_Float, _PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3);
        half3 _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3;
        Unity_Absolute_half3(_PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3, _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3);
        Out_Vector4_1 = _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            half3 TerrainColorMatch;
            float BiasedFade;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half4 _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4 = Fade_Color;
            half _Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float = _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4.w;
            Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea;
            half2 _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2;
            SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half(2048), _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea, _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = half4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).tex, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).GetTransformedUV(_TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2), half(0));
            #endif
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_R_5_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.r;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_G_6_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.g;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_B_7_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.b;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_A_8_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.a;
            half4 _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4;
            Unity_Multiply_half4_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4);
            half4 _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4;
            Unity_Lerp_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4, (_Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float.xxxx), _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4);
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.TerrainColorMatch = (_Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4.xyz);
            description.BiasedFade = _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            half3 NormalTS;
            float3 Emission;
            half Metallic;
            half3 Specular;
            half Smoothness;
            float Occlusion;
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half3 _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            Unity_Lerp_half3((_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.xyz), IN.TerrainColorMatch, (half3(IN.BiasedFade.xxx)), _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3);
            half _Property_07deef7ebc9a4ce8b1912b03dda1a641_Out_0_Boolean = _GrassNormal;
            half3 _Vector3_f03ccace08754bb58f73fc24fa67a7e5_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half3 _Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3;
            {
                half3x3 tangentTransform = half3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3 = TransformWorldToTangent(_Vector3_f03ccace08754bb58f73fc24fa67a7e5_Out_0_Vector3.xyz, tangentTransform, true);
            }
            half _IsFrontFace_ffa786f3eaf044e985046a2068dbbf87_Out_0_Boolean = max(0, IN.FaceSign.x);
            UnityTexture2D _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_9DCAAA49);
            half4 _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.tex, _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.samplerstate, _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4);
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_R_4_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.r;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_G_5_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.g;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_B_6_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.b;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_A_7_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.a;
            half _Split_30812b2f0437422aaae34a09f0e2d341_R_1_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[0];
            half _Split_30812b2f0437422aaae34a09f0e2d341_G_2_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[1];
            half _Split_30812b2f0437422aaae34a09f0e2d341_B_3_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[2];
            half _Split_30812b2f0437422aaae34a09f0e2d341_A_4_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[3];
            half _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float;
            Unity_Negate_half(_Split_30812b2f0437422aaae34a09f0e2d341_B_3_Float, _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float);
            half3 _Vector3_94e14e0492524007bd0809af83c72798_Out_0_Vector3 = half3(_Split_30812b2f0437422aaae34a09f0e2d341_R_1_Float, _Split_30812b2f0437422aaae34a09f0e2d341_G_2_Float, _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float);
            half3 _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3;
            Unity_Branch_half3(_IsFrontFace_ffa786f3eaf044e985046a2068dbbf87_Out_0_Boolean, (_SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.xyz), _Vector3_94e14e0492524007bd0809af83c72798_Out_0_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3);
            half3 _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3;
            Unity_NormalBlend_half(_Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3, _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3);
            half3 _Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3;
            Unity_Branch_half3(_Property_07deef7ebc9a4ce8b1912b03dda1a641_Out_0_Boolean, _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3, _Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3);
            half _Property_3153e067a028407782c7fc60eec8a1ea_Out_0_Float = Vector1_a6983181c8dc4691ba6a28a34c4223a6;
            half3 _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3;
            Unity_NormalStrength_half(_Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3, _Property_3153e067a028407782c7fc60eec8a1ea_Out_0_Float, _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3);
            UnityTexture2D _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_8713F080);
            half4 _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.tex, _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.samplerstate, _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_R_4_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.r;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_G_5_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.g;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_B_6_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.b;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_A_7_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.a;
            half _OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float;
            Unity_OneMinus_half(_SampleTexture2D_417cd518c5ef42039a8069c9866332d8_R_4_Float, _OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float);
            half2 _Property_f87b8494d75448df932c6e590e3de59a_Out_0_Vector2 = _Thickness_Remap;
            half _Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float;
            Unity_Remap_half(_OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float, half2 (0, 1), _Property_f87b8494d75448df932c6e590e3de59a_Out_0_Vector2, _Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float);
            half _IsFrontFace_47618d1c56d0457bb678f769425bd3b5_Out_0_Boolean = max(0, IN.FaceSign.x);
            half3 _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3;
            Unity_Negate_half3(IN.WorldSpaceNormal, _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3);
            half3 _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3;
            Unity_Branch_half3(_IsFrontFace_47618d1c56d0457bb678f769425bd3b5_Out_0_Boolean, IN.WorldSpaceNormal, _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3, _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3);
            half _Property_f1dd973176ef4f79be2e1e91e5c76818_Out_0_Float = _SSS_Effect;
            half _Property_4d163902948249cabc9040bad8dcc4d9_Out_0_Float = _SSS_Shadows;
            Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea;
            half3 _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3;
            SG_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float(IN.WorldSpacePosition, _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3, _Property_f1dd973176ef4f79be2e1e91e5c76818_Out_0_Float, _Property_4d163902948249cabc9040bad8dcc4d9_Out_0_Float, _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea, _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3);
            half4 _Property_59ef6fd7b47644c1a370c943adf84674_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SSSColor) : _SSSColor;
            float3 _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3;
            Unity_Multiply_float3_float3(_PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3, (_Property_59ef6fd7b47644c1a370c943adf84674_Out_0_Vector4.xyz), _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3);
            float3 _Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3, _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3, _Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3);
            float4 _Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float.xxxx), (float4(_Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3, 1.0)), _Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4);
            UnityTexture2D _Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_A5E0646);
            half4 _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D.tex, _Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D.samplerstate, _Property_ea9ec22710bd44d497d7185054bf6f59_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_R_4_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.r;
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_G_5_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.g;
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_B_6_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.b;
            half _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_A_7_Float = _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_RGBA_0_Vector4.a;
            half _Property_b644473d3cd24e3080f2805b814e9370_Out_0_Float = Vector1_8651797e3e304e108dbd25f9d5a426ba;
            half _Multiply_82755e28ff5447ea8b0979444e091870_Out_2_Float;
            Unity_Multiply_half_half(_SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_A_7_Float, _Property_b644473d3cd24e3080f2805b814e9370_Out_0_Float, _Multiply_82755e28ff5447ea8b0979444e091870_Out_2_Float);
            float _Split_2200434d6e2747218ba40e04c62ddbb4_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_2200434d6e2747218ba40e04c62ddbb4_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_2200434d6e2747218ba40e04c62ddbb4_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_2200434d6e2747218ba40e04c62ddbb4_A_4_Float = 0;
            half _Property_edb5a06f067e4b1f81889d39d13a8400_Out_0_Float = _GroundFalloff;
            float _Divide_c8f8819c97c84de9a1e5ff22544c7814_Out_2_Float;
            Unity_Divide_float(_Split_2200434d6e2747218ba40e04c62ddbb4_G_2_Float, _Property_edb5a06f067e4b1f81889d39d13a8400_Out_0_Float, _Divide_c8f8819c97c84de9a1e5ff22544c7814_Out_2_Float);
            float _Saturate_39d0ef87016444b69a7d2c21be9246bf_Out_1_Float;
            Unity_Saturate_float(_Divide_c8f8819c97c84de9a1e5ff22544c7814_Out_2_Float, _Saturate_39d0ef87016444b69a7d2c21be9246bf_Out_1_Float);
            float _Power_e7cec0f0c4b34626b9566fb858e90dab_Out_2_Float;
            Unity_Power_float(_Saturate_39d0ef87016444b69a7d2c21be9246bf_Out_1_Float, float(2), _Power_e7cec0f0c4b34626b9566fb858e90dab_Out_2_Float);
            float _Multiply_429cf9906d8e4ee081bcec9a64a71bb8_Out_2_Float;
            Unity_Multiply_float_float(_Power_e7cec0f0c4b34626b9566fb858e90dab_Out_2_Float, _SampleTexture2D_a71cb3893e594bb4ae643bfdbafd7a75_G_5_Float, _Multiply_429cf9906d8e4ee081bcec9a64a71bb8_Out_2_Float);
            half2 _Property_ad18c7c390ca4897be81137c29d2ef6e_Out_0_Vector2 = _AORemap;
            float _Remap_aecc6283714446679f580896c2d20262_Out_3_Float;
            Unity_Remap_float(_Multiply_429cf9906d8e4ee081bcec9a64a71bb8_Out_2_Float, float2 (0, 1), _Property_ad18c7c390ca4897be81137c29d2ef6e_Out_0_Vector2, _Remap_aecc6283714446679f580896c2d20262_Out_3_Float);
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.BaseColor = _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            surface.NormalTS = _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3;
            surface.Emission = (_Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4.xyz);
            surface.Metallic = half(0);
            surface.Specular = IsGammaSpace() ? half3(0.5, 0.5, 0.5) : SRGBToLinear(half3(0.5, 0.5, 0.5));
            surface.Smoothness = _Multiply_82755e28ff5447ea8b0979444e091870_Out_2_Float;
            surface.Occlusion = _Remap_aecc6283714446679f580896c2d20262_Out_3_Float;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 packed_normalWS_Falloff : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.packed_normalWS_Falloff.xyz = input.normalWS;
            output.packed_normalWS_Falloff.w = input.Falloff;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.packed_normalWS_Falloff.xyz;
            output.Falloff = input.packed_normalWS_Falloff.w;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Falloff = input.Falloff;
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float1 Falloff : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.Falloff.x = input.Falloff;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.Falloff = input.Falloff.x;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Falloff = input.Falloff;
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float4 uv0;
             float FaceSign;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float4 packed_normalWS_Falloff : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.packed_normalWS_Falloff.xyz = input.normalWS;
            output.packed_normalWS_Falloff.w = input.Falloff;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.packed_normalWS_Falloff.xyz;
            output.Falloff = input.packed_normalWS_Falloff.w;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Negate_half(half In, out half Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Branch_half3(half Predicate, half3 True, half3 False, out half3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalBlend_half(half3 A, half3 B, out half3 Out)
        {
            Out = SafeNormalize(half3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_NormalStrength_half(half3 In, half Strength, out half3 Out)
        {
            Out = half3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 NormalTS;
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _Property_07deef7ebc9a4ce8b1912b03dda1a641_Out_0_Boolean = _GrassNormal;
            half3 _Vector3_f03ccace08754bb58f73fc24fa67a7e5_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half3 _Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3;
            {
                half3x3 tangentTransform = half3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3 = TransformWorldToTangent(_Vector3_f03ccace08754bb58f73fc24fa67a7e5_Out_0_Vector3.xyz, tangentTransform, true);
            }
            half _IsFrontFace_ffa786f3eaf044e985046a2068dbbf87_Out_0_Boolean = max(0, IN.FaceSign.x);
            UnityTexture2D _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_9DCAAA49);
            half4 _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.tex, _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.samplerstate, _Property_fca282b35ff14c8eae45a907f9d226a5_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4);
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_R_4_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.r;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_G_5_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.g;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_B_6_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.b;
            half _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_A_7_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.a;
            half _Split_30812b2f0437422aaae34a09f0e2d341_R_1_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[0];
            half _Split_30812b2f0437422aaae34a09f0e2d341_G_2_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[1];
            half _Split_30812b2f0437422aaae34a09f0e2d341_B_3_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[2];
            half _Split_30812b2f0437422aaae34a09f0e2d341_A_4_Float = _SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4[3];
            half _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float;
            Unity_Negate_half(_Split_30812b2f0437422aaae34a09f0e2d341_B_3_Float, _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float);
            half3 _Vector3_94e14e0492524007bd0809af83c72798_Out_0_Vector3 = half3(_Split_30812b2f0437422aaae34a09f0e2d341_R_1_Float, _Split_30812b2f0437422aaae34a09f0e2d341_G_2_Float, _Negate_28663df5441d4d71b21c7ef3475101a1_Out_1_Float);
            half3 _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3;
            Unity_Branch_half3(_IsFrontFace_ffa786f3eaf044e985046a2068dbbf87_Out_0_Boolean, (_SampleTexture2D_f7e6b5a8493e4a4281e4c3452c9354a7_RGBA_0_Vector4.xyz), _Vector3_94e14e0492524007bd0809af83c72798_Out_0_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3);
            half3 _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3;
            Unity_NormalBlend_half(_Transform_338cfa69a98b4674a0347868766b2870_Out_1_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3, _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3);
            half3 _Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3;
            Unity_Branch_half3(_Property_07deef7ebc9a4ce8b1912b03dda1a641_Out_0_Boolean, _NormalBlend_c0d9910aceb54b809b8ec419ec2ac0c1_Out_2_Vector3, _Branch_e5ab3aeedb274a4ea538fc73d3d7091f_Out_3_Vector3, _Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3);
            half _Property_3153e067a028407782c7fc60eec8a1ea_Out_0_Float = Vector1_a6983181c8dc4691ba6a28a34c4223a6;
            half3 _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3;
            Unity_NormalStrength_half(_Branch_376bde2ed16e43eb8eeebdd2d5b37fae_Out_3_Vector3, _Property_3153e067a028407782c7fc60eec8a1ea_Out_0_Float, _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3);
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.NormalTS = _NormalStrength_7872635fbdcc481da8bddb0ff3cdd44e_Out_2_Vector3;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Falloff = input.Falloff;
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float4 uv0;
             float FaceSign;
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float4 packed_positionWS_BiasedFade : INTERP3;
             float4 packed_normalWS_Falloff : INTERP4;
             float3 TerrainColorMatch : INTERP5;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.packed_positionWS_BiasedFade.xyz = input.positionWS;
            output.packed_positionWS_BiasedFade.w = input.BiasedFade;
            output.packed_normalWS_Falloff.xyz = input.normalWS;
            output.packed_normalWS_Falloff.w = input.Falloff;
            output.TerrainColorMatch.xyz = input.TerrainColorMatch;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.packed_positionWS_BiasedFade.xyz;
            output.BiasedFade = input.packed_positionWS_BiasedFade.w;
            output.normalWS = input.packed_normalWS_Falloff.xyz;
            output.Falloff = input.packed_normalWS_Falloff.w;
            output.TerrainColorMatch = input.TerrainColorMatch.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        #include "Assets/Demo/Grass/Shader/CustomFunctions/PseudoSubsurface.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Divide_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Subtract_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A - B;
        }
        
        struct Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half
        {
        };
        
        void SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half _ProjectionSize, Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half IN, out half2 UVs_1)
        {
        half _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float = _ProjectionSize;
        half _Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float = _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float;
        half3 _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3;
        Unity_Divide_half3(SHADERGRAPH_OBJECT_POSITION, (_Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float.xxx), _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3);
        half3 _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3;
        Unity_Subtract_half3(_Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3, half3(0.5, 0.5, 0.5), _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3);
        half2 _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2 = _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3.xz;
        UVs_1 = _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2;
        }
        
        void Unity_Multiply_half4_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_half3(half3 A, half3 B, half3 T, out half3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Remap_half(half In, half2 InMinMax, half2 OutMinMax, out half Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Negate_half3(half3 In, out half3 Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Branch_half3(half Predicate, half3 True, half3 False, out half3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Absolute_half3(half3 In, out half3 Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float
        {
        };
        
        void SG_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float(float3 _WorldPosition, float3 _WorldNormal, float _SubsurfaceRadius, float _ShadowResponse, Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float IN, out half3 Out_Vector4_1)
        {
        float3 _Property_ea43e60c5fb644bb91c953fbd2dbeb97_Out_0_Vector3 = _WorldPosition;
        float3 _Property_f787854d379940b49846c9528a923395_Out_0_Vector3 = _WorldNormal;
        float _Property_df96f9c4b84e479bba8e78be04cb38d6_Out_0_Float = _SubsurfaceRadius;
        float _Property_2a98c51675fc4ff0b5d3f7c3e7fdd3c8_Out_0_Float = _ShadowResponse;
        half3 _PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3;
        PseudoSubsurface_half(_Property_ea43e60c5fb644bb91c953fbd2dbeb97_Out_0_Vector3, _Property_f787854d379940b49846c9528a923395_Out_0_Vector3, _Property_df96f9c4b84e479bba8e78be04cb38d6_Out_0_Float, _Property_2a98c51675fc4ff0b5d3f7c3e7fdd3c8_Out_0_Float, _PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3);
        half3 _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3;
        Unity_Absolute_half3(_PseudoSubsurfaceCustomFunction_709e60500d6b41569075bd4864f67b88_ssAmount_1_Vector3, _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3);
        Out_Vector4_1 = _Absolute_96c8aa8f1a594047a395661dafaba9fe_Out_1_Vector3;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            half3 TerrainColorMatch;
            float BiasedFade;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half4 _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4 = Fade_Color;
            half _Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float = _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4.w;
            Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea;
            half2 _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2;
            SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half(2048), _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea, _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = half4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).tex, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).GetTransformedUV(_TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2), half(0));
            #endif
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_R_5_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.r;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_G_6_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.g;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_B_7_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.b;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_A_8_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.a;
            half4 _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4;
            Unity_Multiply_half4_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4);
            half4 _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4;
            Unity_Lerp_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4, (_Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float.xxxx), _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4);
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.TerrainColorMatch = (_Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4.xyz);
            description.BiasedFade = _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            float3 Emission;
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half3 _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            Unity_Lerp_half3((_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.xyz), IN.TerrainColorMatch, (half3(IN.BiasedFade.xxx)), _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3);
            UnityTexture2D _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_8713F080);
            half4 _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.tex, _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.samplerstate, _Property_6ea381afedbf4eb4800f301f2ed16515_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_R_4_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.r;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_G_5_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.g;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_B_6_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.b;
            half _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_A_7_Float = _SampleTexture2D_417cd518c5ef42039a8069c9866332d8_RGBA_0_Vector4.a;
            half _OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float;
            Unity_OneMinus_half(_SampleTexture2D_417cd518c5ef42039a8069c9866332d8_R_4_Float, _OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float);
            half2 _Property_f87b8494d75448df932c6e590e3de59a_Out_0_Vector2 = _Thickness_Remap;
            half _Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float;
            Unity_Remap_half(_OneMinus_96ec1d6c67e64af8ac1f724cf98d569f_Out_1_Float, half2 (0, 1), _Property_f87b8494d75448df932c6e590e3de59a_Out_0_Vector2, _Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float);
            half _IsFrontFace_47618d1c56d0457bb678f769425bd3b5_Out_0_Boolean = max(0, IN.FaceSign.x);
            half3 _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3;
            Unity_Negate_half3(IN.WorldSpaceNormal, _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3);
            half3 _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3;
            Unity_Branch_half3(_IsFrontFace_47618d1c56d0457bb678f769425bd3b5_Out_0_Boolean, IN.WorldSpaceNormal, _Negate_1aa011ab8a85459a99b66b4e381f9bbf_Out_1_Vector3, _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3);
            half _Property_f1dd973176ef4f79be2e1e91e5c76818_Out_0_Float = _SSS_Effect;
            half _Property_4d163902948249cabc9040bad8dcc4d9_Out_0_Float = _SSS_Shadows;
            Bindings_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea;
            half3 _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3;
            SG_PseudoSubsurface_6e3101a6841ddda46b463b30f670fb51_float(IN.WorldSpacePosition, _Branch_4c199d7a9f9547f28202d0ea851cd7ec_Out_3_Vector3, _Property_f1dd973176ef4f79be2e1e91e5c76818_Out_0_Float, _Property_4d163902948249cabc9040bad8dcc4d9_Out_0_Float, _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea, _PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3);
            half4 _Property_59ef6fd7b47644c1a370c943adf84674_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SSSColor) : _SSSColor;
            float3 _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3;
            Unity_Multiply_float3_float3(_PseudoSubsurface_c78dfae3f1dc4dddb4b938c57da83fea_OutVector4_1_Vector3, (_Property_59ef6fd7b47644c1a370c943adf84674_Out_0_Vector4.xyz), _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3);
            float3 _Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3, _Multiply_e1d30447c5944dd5a499139e73d4a2aa_Out_2_Vector3, _Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3);
            float4 _Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Remap_9647b8bf0c064c12bd3c4736a5615f1c_Out_3_Float.xxxx), (float4(_Multiply_b472e82984ef486cab337a451e95d553_Out_2_Vector3, 1.0)), _Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4);
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.BaseColor = _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            surface.Emission = (_Multiply_f6e466f362d142f8956f12baf3235cc6_Out_2_Vector4.xyz);
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float1 Falloff : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.Falloff.x = input.Falloff;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.Falloff = input.Falloff.x;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Falloff = input.Falloff;
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float1 Falloff : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.Falloff.x = input.Falloff;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.Falloff = input.Falloff.x;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Falloff = input.Falloff;
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TerrainColorMatch;
             float BiasedFade;
             float Falloff;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv1;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 packed_TerrainColorMatch_BiasedFade : INTERP1;
             float1 Falloff : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.packed_TerrainColorMatch_BiasedFade.xyz = input.TerrainColorMatch;
            output.packed_TerrainColorMatch_BiasedFade.w = input.BiasedFade;
            output.Falloff.x = input.Falloff;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.TerrainColorMatch = input.packed_TerrainColorMatch_BiasedFade.xyz;
            output.BiasedFade = input.packed_TerrainColorMatch_BiasedFade.w;
            output.Falloff = input.Falloff.x;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D_TexelSize;
        float4 Texture2D_E1B0D043_TexelSize;
        half Vector1_a5b8b09028ce49a39f4d090894c89e22;
        float4 Texture2D_9DCAAA49_TexelSize;
        half Vector1_a6983181c8dc4691ba6a28a34c4223a6;
        float4 Texture2D_A5E0646_TexelSize;
        half Vector1_8651797e3e304e108dbd25f9d5a426ba;
        half Vector1_593c5cea6c4a42e993ed03ced4685732;
        float4 Texture2D_8713F080_TexelSize;
        half Wind_Yaw;
        half Wind_Turbulence;
        half Wind_Wavelength;
        half Wind_Speed;
        half Wind_Ripples;
        half Wind_Intensity;
        half Wind_Blast;
        half Animation_Cutoff;
        half Distance_Fade_End;
        half Distance_Fade_Start;
        half4 Fade_Color;
        half _FadeBias;
        half2 _Thickness_Remap;
        half4 _SSSColor;
        half2 _AORemap;
        half _GrassNormal;
        half _GroundFalloff;
        half _SSS_Effect;
        half _SSS_Shadows;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D);
        TEXTURE2D(Texture2D_E1B0D043);
        SAMPLER(samplerTexture2D_E1B0D043);
        TEXTURE2D(Texture2D_9DCAAA49);
        SAMPLER(samplerTexture2D_9DCAAA49);
        TEXTURE2D(Texture2D_A5E0646);
        SAMPLER(samplerTexture2D_A5E0646);
        TEXTURE2D(Texture2D_8713F080);
        SAMPLER(samplerTexture2D_8713F080);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Divide_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Subtract_half3(half3 A, half3 B, out half3 Out)
        {
            Out = A - B;
        }
        
        struct Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half
        {
        };
        
        void SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half _ProjectionSize, Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half IN, out half2 UVs_1)
        {
        half _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float = _ProjectionSize;
        half _Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float = _Property_aba1d09bf39d4a02bdc7905b2cde45e0_Out_0_Float;
        half3 _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3;
        Unity_Divide_half3(SHADERGRAPH_OBJECT_POSITION, (_Float_9e4d9f1bf87c48e2b380c48c15b4811a_Out_0_Float.xxx), _Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3);
        half3 _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3;
        Unity_Subtract_half3(_Divide_1acca08af17949abbe58c99a966d8a39_Out_2_Vector3, half3(0.5, 0.5, 0.5), _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3);
        half2 _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2 = _Subtract_29c9c1c1717a430a96ae6f407897ce22_Out_2_Vector3.xz;
        UVs_1 = _Swizzle_6f5079fa55ff48ab8d0ceea21aefa7a1_Out_1_Vector2;
        }
        
        void Unity_Multiply_half4_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void SimpleHash_float(float3 in_position, float seed, out float out_hash){
        uint X = asuint(in_position.x);
        
        uint Y = asuint(in_position.y);
        uint Z = asuint(in_position.z);
        
        uint H = X ^ 2747636419u;
        H *= 2654435769u;
        
        H >> 16;
        
        H *= 2654435769u;
        
        H ^= H >> 16;
        
        H *= 2654435769u;
        H ^= Y;
        H ^= Z;
        
        out_hash = asfloat(H / 4294967295.0);
        }
        
        struct Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float
        {
        };
        
        void SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float Vector1_3b97c5182780489686cf16f9de4a9ade, Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float IN, out float out_frac_3)
        {
        float _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float = Vector1_3b97c5182780489686cf16f9de4a9ade;
        float _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        SimpleHash_float(SHADERGRAPH_OBJECT_POSITION, _Property_fdb5ad442b4a491d9104f4eed39a04d6_Out_0_Float, _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float);
        out_frac_3 = _SimpleHashCustomFunction_1a8e3945f7574132b4177e03dd4e812f_outhash_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_half_half(half A, half B, out half Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Clamp_half(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);
        
            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
        Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
        Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
        Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }
        
        void Unity_MatrixTranspose_float4x4(float4x4 In, out float4x4 Out)
        {
            Out = transpose(In);
        }
        
        void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
        {
        Out = mul(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        struct Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float
        {
        float3 TimeParameters;
        };
        
        void SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(float3 Vector3_cd634a1fd8b749e3b0069b61d35a0614, float Vector1_26f01b8484ed48b3878989067150a580, float Vector1_92a32c418a3740aa9fff1cce06eeb97b, float Vector1_dd02a05593804ec68a8b3cbeb2abb926, float Vector1_17f0b423235f4212be9932a8f400b82e, float Vector1_caec47aa96ad4f4890a1197c25550285, Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float IN, out float phase_2)
        {
        float _Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float3 _Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3 = Vector3_cd634a1fd8b749e3b0069b61d35a0614;
        float3 _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3;
        Unity_Normalize_float3(_Property_204f1db56a9b4c22b7c08b56a6cb505c_Out_0_Vector3, _Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3);
        float _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float;
        Unity_Divide_float(float(1), _Property_c72026786ddf4e5489cf130e8d41e646_Out_0_Float, _Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float);
        float3 _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_b25cc8796fa04916b7bc88f28487abe6_Out_1_Vector3, (_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3);
        float3 _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3 = float3(float(0), float(1), float(0));
        float3 _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Divide_e8affae72b954124ad909cf871394bbd_Out_2_Float.xxx), _Vector3_1fe735ca4eea42d5ae6b30a5c6a57900_Out_0_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3);
        float3 _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3;
        Unity_CrossProduct_float(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, _Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, _CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3);
        float4x4 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4;
        float3x3 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3;
        float2x2 _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2;
        Unity_MatrixConstruction_Row_float((float4(_Multiply_777641a2d717494699fef4804fd1d2a4_Out_2_Vector3, 1.0)), (float4(_Multiply_957ac109cc0c411495f051a625fbd405_Out_2_Vector3, 1.0)), (float4(_CrossProduct_dd910c7f6d304120850275a371d0faa8_Out_2_Vector3, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var3x3_5_Matrix3, _MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var2x2_6_Matrix2);
        float4x4 _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4;
        Unity_MatrixTranspose_float4x4(_MatrixConstruction_4d69da6fdcba4e0e913fab0413bdf790_var4x4_4_Matrix4, _MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4);
        float4 _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4;
        Unity_Multiply_float4x4_float4(_MatrixTranspose_6ae8ba7cb2b84842b59241751b20a787_Out_1_Matrix4, (float4(SHADERGRAPH_OBJECT_POSITION, 1.0)), _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4);
        float _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[0];
        float _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[1];
        float _Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[2];
        float _Split_5a8651da50df48e8987e8d47412fb48b_A_4_Float = _Multiply_63b845993e6d4f3fb0e155b72bc6146d_Out_2_Vector4[3];
        float _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float;
        Unity_Add_float(_Split_5a8651da50df48e8987e8d47412fb48b_B_3_Float, _Split_5a8651da50df48e8987e8d47412fb48b_G_2_Float, _Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float);
        float _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float;
        Unity_Multiply_float_float(_Add_88e24b63a4ce43e2af31038aa69af508_Out_2_Float, _Property_4d03e53709cb48e08a236fa4ee9b3bf7_Out_0_Float, _Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float);
        float _Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float = Vector1_17f0b423235f4212be9932a8f400b82e;
        float _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float = Vector1_26f01b8484ed48b3878989067150a580;
        float _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float;
        Unity_Add_float(IN.TimeParameters.x, _Property_dcd04e70c1464d019144225e0d43a021_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float);
        float _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float;
        Unity_Multiply_float_float(_Property_6188b6252e224552afdfc5a12b3f41c6_Out_0_Float, _Add_762c19098e5e4b5694ee670551e177c7_Out_2_Float, _Multiply_04af88773f75489fb7415006600bb138_Out_2_Float);
        float _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float = Vector1_dd02a05593804ec68a8b3cbeb2abb926;
        float _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float;
        Unity_Divide_float(_Multiply_04af88773f75489fb7415006600bb138_Out_2_Float, _Property_a656e3836c524dcc90e89f7cfe8510fa_Out_0_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float);
        float _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float = Vector1_caec47aa96ad4f4890a1197c25550285;
        float _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float;
        Unity_Multiply_float_float(_Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Property_ac344be60c814cbf8f70130e6726bb35_Out_0_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float);
        float _Add_8c99726882e64af685d2bf089a894747_Out_2_Float;
        Unity_Add_float(_Multiply_30ef52ec4ffe433aa27f800972e249e7_Out_2_Float, _Multiply_e55d982f0878493aa47757ea79d0dbfe_Out_2_Float, _Add_8c99726882e64af685d2bf089a894747_Out_2_Float);
        float _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float;
        Unity_Cosine_float(_Add_8c99726882e64af685d2bf089a894747_Out_2_Float, _Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float);
        float _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float = Vector1_92a32c418a3740aa9fff1cce06eeb97b;
        float _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float;
        Unity_Multiply_float_float(_Cosine_cbcc633015fe43d793e3db810c34d8cd_Out_1_Float, _Property_006d5769d8914e0f84d1f07028a858ba_Out_0_Float, _Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float);
        float _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float;
        Unity_Add_float(_Multiply_13ce8a67b8f74bad937d076baceefa12_Out_2_Float, _Split_5a8651da50df48e8987e8d47412fb48b_R_1_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float);
        float _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float;
        Unity_Add_float(_Property_eec4580e5a4f43c693a7622fafb36828_Out_0_Float, _Add_108be203cc1446bbaeb1db1c3d51e3b7_Out_2_Float, _Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float);
        float _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float;
        Unity_Add_float(_Add_e837d1ff47464ab08562c275ac5d3d00_Out_2_Float, _Divide_637b3c596ac24200b82c290dc6068d1b_Out_2_Float, _Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float);
        float _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float;
        Unity_Sine_float(_Add_c9b5f6d8c03d41d59c3a82b8ac85e9cd_Out_2_Float, _Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float);
        float _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float;
        Unity_Multiply_float_float(_Sine_3bebc544dae741b994bed594d80b6467_Out_1_Float, 0.5, _Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float);
        float _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        Unity_Add_float(_Multiply_1f35b99cd51a4eb08d822369ca8021da_Out_2_Float, float(0.5), _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float);
        phase_2 = _Add_b0469ef1a4604ff9ababc1f0f8ab2e86_Out_2_Float;
        }
        
        struct Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half
        {
        half4 uv1;
        float3 TimeParameters;
        };
        
        void SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(half _Wind_Turbulence, half _Wind_Ripples, half _Wind_Blast, half _Wind_Wavelength, half _Wind_Yaw, half _Wind_Speed, half _Wind_Intensity, Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half IN, out float OutVector1_1, out float OutVector11_2, out float3 OutVector3_3)
        {
        half _Property_1cc26fe988b54b0da276c37934277671_Out_0_Float = _Wind_Intensity;
        Bindings_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec;
        float _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        SG_RandomFromPosition_1d3c53100af6f1c4b8e84deb9f652a6f_float(float(999), _RandomFromPosition_6c52686eecf345ba940f654e170b1bec, _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float);
        float _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float);
        float _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_d7039c24b29a44e7aa32cb7d8a1dc43b_Out_2_Float, 0.125, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float);
        float _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float;
        Unity_Add_float(_Property_1cc26fe988b54b0da276c37934277671_Out_0_Float, _Multiply_18a7997b086642e5912c618240334a8b_Out_2_Float, _Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float);
        half4 _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4 = IN.uv1;
        half _Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4.y;
        float _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float;
        Unity_Subtract_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, float(0.5), _Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float);
        half _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float = half(0.5);
        float _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float;
        Unity_Add_float(_Subtract_69002b3778684c91b76c4e6e872ddfe9_Out_2_Float, _Float_72c1d8eca13244cfa7996728e29ffc89_Out_0_Float, _Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float);
        float _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float;
        Unity_Clamp_float(_Add_bab333d2caff42fcb45aa26f74ab1bd1_Out_2_Float, float(0.1), float(16), _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float);
        float _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float;
        Unity_Power_float(_Swizzle_ff44d5789e524326b610c9cba5f81607_Out_1_Float, _Clamp_044bb307eabb4fa48233ab1769186eca_Out_3_Float, _Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float);
        half _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float = _Wind_Yaw;
        half3 _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (1, 0, 0), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3);
        half _Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[0];
        half _Split_0ba8a68af7174085a1087c444f9090f2_G_2_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[1];
        half _Split_0ba8a68af7174085a1087c444f9090f2_B_3_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[2];
        half _Split_0ba8a68af7174085a1087c444f9090f2_A_4_Float = _UV_09846dfa2a6445fa946c6f455435c425_Out_0_Vector4[3];
        float _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float;
        Unity_Multiply_float_float(_RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float, 1, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float);
        float _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float;
        Unity_Add_float(_Split_0ba8a68af7174085a1087c444f9090f2_R_1_Float, _Multiply_6391c2de68b340cab59390045e8cedf2_Out_2_Float, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float);
        half _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float = _Wind_Turbulence;
        half _Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float = _Wind_Wavelength;
        half _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float;
        Unity_Clamp_half(_Property_2f0b478adf574d95b80b2f45bd1dcb6e_Out_0_Float, half(0.001), half(10000), _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float);
        half _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float = _Wind_Speed;
        half _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float;
        Unity_Multiply_half_half(_Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Property_6c0a316092084b89a5abdb57662a4350_Out_0_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float);
        half _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float = _Wind_Ripples;
        Bindings_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float _AnimatedGrassPhase_5a0947857f624419944709d416575eff;
        _AnimatedGrassPhase_5a0947857f624419944709d416575eff.TimeParameters = IN.TimeParameters;
        float _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float;
        SG_AnimatedGrassPhase_baa12ab73b962474eb9afea9483e1f0f_float(_RotateAboutAxis_d927ef32f8174e4e86b320e9712082ea_Out_3_Vector3, _Add_150eb28f44ab4d56a8cf49c6c4c00f03_Out_2_Float, _Property_28cce6b1c38247028aa4ef6a59be19fd_Out_0_Float, _Clamp_1e9448746182480db354ca20a9f280ab_Out_3_Float, _Multiply_648fcbe759a44419a116cb6772146845_Out_2_Float, _Property_2671163296d74b19ad0c575c3668bc96_Out_0_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float);
        float _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float;
        Unity_Multiply_float_float(_Power_5c852d5f4856450db3e7ff5f8c05a398_Out_2_Float, _AnimatedGrassPhase_5a0947857f624419944709d416575eff_phase_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float);
        float _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float;
        Unity_Multiply_float_float(_Add_9e4391735df243b9ac6904df4c1d341a_Out_2_Float, _Multiply_d6e90772a29241ef8b53323f34728247_Out_2_Float, _Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float);
        half _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float = _Wind_Blast;
        float _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        Unity_Add_float(_Multiply_de57ec85656248b4a14d33e187eb70ad_Out_2_Float, _Property_4fc00d47baed4ccdaf0fdb5a5017ab87_Out_0_Float, _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float);
        half3 _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3;
        Unity_Rotate_About_Axis_Degrees_half(half3 (0, 0, 1), half3 (0, 1, 0), _Property_c128b4b8be844a9f988fe9c3d497dad2_Out_0_Float, _RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3);
        half3 _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3 = TransformWorldToObjectDir(_RotateAboutAxis_cf4e665eceb448828ee8bb082283b00e_Out_3_Vector3.xyz, true);
        OutVector1_1 = _Add_252f46b7be3840feaadc8ec2be9f734f_Out_2_Float;
        OutVector11_2 = _RandomFromPosition_6c52686eecf345ba940f654e170b1bec_outfrac_3_Float;
        OutVector3_3 = _Transform_417e977f124c4fc4aa1a7c7518306677_Out_1_Vector3;
        }
        
        void Unity_Add_half(half A, half B, out half Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float
        {
        };
        
        void SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(float Vector1_e557ca4994a347ffa4c827936e25216c, float Vector1_09637ae9919547d78bb477f8aebeaf5e, float Vector1_0f7cf1aa48e34bc0a680792872e719c1, float dither_scale, Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float IN, out float out_movement_1, out float out_fade_2, out float out_dither_3, out float out_falloff_4)
        {
        float _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float;
        Unity_Distance_float3(_WorldSpaceCameraPos, SHADERGRAPH_OBJECT_POSITION, _Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float);
        float _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float = Vector1_e557ca4994a347ffa4c827936e25216c;
        float _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_e212707199c34cc9b80c1b5b07e392fc_Out_0_Float, _Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float);
        float _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        Unity_Saturate_float(_Divide_8b51cf2b00f5460b9677de785fe4f08a_Out_2_Float, _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float);
        float _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float;
        Unity_Subtract_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_208a982ea50e42fa84fe244279695eda_Out_0_Float, _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float);
        float _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float;
        Unity_Maximum_float(float(0), _Subtract_733fb34d6ad44b518164acc63656086f_Out_2_Float, _Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float);
        float _Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float = Vector1_0f7cf1aa48e34bc0a680792872e719c1;
        float _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float;
        Unity_Subtract_float(_Property_cfdc938922ba4908bc711254a3772feb_Out_0_Float, _Property_0248a6dbae79453380b5458d9a7cde82_Out_0_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float);
        float _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float;
        Unity_Divide_float(_Maximum_575c2bf798454a9a979ed23b6847bb0d_Out_2_Float, _Subtract_c83b244914a74896b601fcf51da9a936_Out_2_Float, _Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float);
        float _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        Unity_Saturate_float(_Divide_2d069ce090e7457e86d5f74b8f1732ed_Out_2_Float, _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float);
        float _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float;
        Unity_OneMinus_float(_Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float, _OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float);
        float _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float = dither_scale;
        float _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_977e1686960147e7a8c217be33a23fd2_Out_1_Float, _Property_d60ca8082844422ca5fc821a59d31187_Out_0_Float, _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float);
        float _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float = Vector1_09637ae9919547d78bb477f8aebeaf5e;
        float _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float;
        Unity_Divide_float(_Distance_9070b0f58d9f434db89cf1bc3215addb_Out_2_Float, _Property_b7e2abc577154823b7f35a9d519ad996_Out_0_Float, _Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float);
        float _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        Unity_Saturate_float(_Divide_98a60ea86b0d48938042ded6f43c9af4_Out_2_Float, _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float);
        out_movement_1 = _Saturate_8ca0c77ee32d49b2883a99311865ea41_Out_1_Float;
        out_fade_2 = _Saturate_9088d68cc84d485199bbc748827e0049_Out_1_Float;
        out_dither_3 = _Multiply_3e42b3bab93f4243a95b20393a3a7a3e_Out_2_Float;
        out_falloff_4 = _Saturate_aabc8e0013ea44aeb0d33c3d7cb27280_Out_1_Float;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_half3(half3 A, half3 B, half3 T, out half3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_half(half In, out half Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            half3 TerrainColorMatch;
            float BiasedFade;
            float Falloff;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half4 _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4 = Fade_Color;
            half _Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float = _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4.w;
            Bindings_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea;
            half2 _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2;
            SG_TerrainMatchUV_4bfc6d9830dbb014080890b4b2fe6275_half(half(2048), _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea, _TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = half4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              half4 _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).tex, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_Texture_1_Texture2D).GetTransformedUV(_TerrainMatchUV_48dc9fb787374dc089ba0d4b6e6aa0ea_UVs_1_Vector2), half(0));
            #endif
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_R_5_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.r;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_G_6_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.g;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_B_7_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.b;
            half _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_A_8_Float = _SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4.a;
            half4 _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4;
            Unity_Multiply_half4_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Property_f47bb41cbf0a4426ba0cf0f39d8bce78_Out_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4);
            half4 _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4;
            Unity_Lerp_half4(_SampleTexture2DLOD_4ce76fe7821749c5a93282810d6e42f2_RGBA_0_Vector4, _Multiply_dc8b60c3249a45338fef3a8f822f2c87_Out_2_Vector4, (_Swizzle_205f896926534950958b9b69cbcc0ce4_Out_1_Float.xxxx), _Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4);
            half _Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float = Animation_Cutoff;
            half _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float = Distance_Fade_End;
            half _Property_3a7e846478af4588abee730e138b7600_Out_0_Float = Distance_Fade_Start;
            half _Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float = Wind_Turbulence;
            half _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float = Wind_Ripples;
            half _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float = Wind_Blast;
            half _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float = Wind_Wavelength;
            half _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float = Wind_Yaw;
            half _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float = Wind_Speed;
            half _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float = Wind_Intensity;
            Bindings_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half _Wind_9575c284b6ad41e1a0814b08fbc61484;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.uv1 = IN.uv1;
            _Wind_9575c284b6ad41e1a0814b08fbc61484.TimeParameters = IN.TimeParameters;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float;
            float _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float;
            float3 _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3;
            SG_Wind_1dd746ccdf474aa419f7cfab01d0d20e_half(_Property_faf61269176b454d8d72c6cecbf71988_Out_0_Float, _Property_ada5ad4374e6404b99a7002bc10d3adc_Out_0_Float, _Property_0004c9291f8e42fe8eee9107eedff443_Out_0_Float, _Property_a414e75c5dd44d6e865f068c60b1fb9e_Out_0_Float, _Property_22435519b2234c6d92c6b467fa17b40b_Out_0_Float, _Property_86dea8649f5a434aaec53d309a8be1e7_Out_0_Float, _Property_86c74d436dfa46c2aca1a0c10df4f551_Out_0_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3);
            half _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float;
            Unity_Add_half(half(1), _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector11_2_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float);
            Bindings_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float _DistanceCutoff_574befd6840749648d19978a8b7288cf;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float;
            float _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            SG_DistanceCutoff_6c605407cd6fa244f8ff68955ae4b09f_float(_Property_40ee40a928d947c29e1ec0025331ef99_Out_0_Float, _Property_e7f24f278a184d48a5a9309e6c50f05b_Out_0_Float, _Property_3a7e846478af4588abee730e138b7600_Out_0_Float, _Add_dba0dc31fc5345aaa7f7aadd57cd2143_Out_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outdither_3_Float, _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float);
            float _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean;
            Unity_Comparison_Less_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, float(1), _Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean);
            float _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float;
            Unity_OneMinus_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outmovement_1_Float, _OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float);
            float _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float;
            Unity_Power_float(_OneMinus_589f556f9ef14d52891b23df211bb6ce_Out_1_Float, float(0.75), _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float);
            float _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float;
            Unity_Multiply_float_float(_Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector1_1_Float, _Power_58f7c464ac8f4417a2f03c73d9ed4556_Out_2_Float, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float);
            float3 _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpacePosition, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3);
            float3 _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_f3616753e04743468b894301c6da8b4e_Out_2_Boolean, _RotateAboutAxis_f6f6a2bf20ec4da69c2676a2619ad7d7_Out_3_Vector3, IN.ObjectSpacePosition, _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3);
            half3 _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3 = half3(half(0), half(1), half(0));
            half _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float = _FadeBias;
            float _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            Unity_Power_float(_DistanceCutoff_574befd6840749648d19978a8b7288cf_outfade_2_Float, _Property_b2c35431f5e64da1b04067b0f591bad4_Out_0_Float, _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float);
            float3 _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            Unity_Lerp_float3(IN.ObjectSpaceNormal, _Vector3_876da79cb1bd496ba3d3a0058a514dec_Out_0_Vector3, (_Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float.xxx), _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3);
            float3 _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            Unity_Rotate_About_Axis_Radians_float(IN.ObjectSpaceTangent, _Wind_9575c284b6ad41e1a0814b08fbc61484_OutVector3_3_Vector3, _Multiply_3d88860f9647465f8ee2436a4dc17fdc_Out_2_Float, _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3);
            description.Position = _Branch_9d2881055e464e80bff63660ea41c8da_Out_3_Vector3;
            description.Normal = _Lerp_6589a3bbc8774d89be5d65a635b8f345_Out_3_Vector3;
            description.Tangent = _RotateAboutAxis_e6a8e7d7ce2f4ff3886597629d3b60f1_Out_3_Vector3;
            description.TerrainColorMatch = (_Lerp_51c40274ad2b4da3a9ddfc9aba9cf8f5_Out_3_Vector4.xyz);
            description.BiasedFade = _Power_f7e446a8f4b14768aebb1fd2bbba566a_Out_2_Float;
            description.Falloff = _DistanceCutoff_574befd6840749648d19978a8b7288cf_outfalloff_4_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            half Alpha;
            half AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_E1B0D043);
            half4 _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.tex, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.samplerstate, _Property_ebe8113d0fdb45e5ae4d50ab8278f9a8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_R_4_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.r;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_G_5_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.g;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_B_6_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.b;
            half _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float = _SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.a;
            half3 _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            Unity_Lerp_half3((_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_RGBA_0_Vector4.xyz), IN.TerrainColorMatch, (half3(IN.BiasedFade.xxx)), _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3);
            half _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float;
            Unity_OneMinus_half(IN.Falloff, _OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float);
            half _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float;
            Unity_Preview_half(_SampleTexture2D_e850feac85534e0e8af4834cbbb36b9b_A_7_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float);
            half _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            Unity_Multiply_half_half(_OneMinus_bc1c59553a0d49a8b3c1440af6d56983_Out_1_Float, _Preview_5a18074d42f44ceab38031076ebc548b_Out_1_Float, _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float);
            half _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float = Vector1_a5b8b09028ce49a39f4d090894c89e22;
            surface.BaseColor = _Lerp_52d649b2ebf24def9872029728fdbb7b_Out_3_Vector3;
            surface.Alpha = _Multiply_58a6d5312cd24489a63a3bb352f1554e_Out_2_Float;
            surface.AlphaClipThreshold = _Property_8692df6bcd9a416aad9f3a2dd8a2a1d0_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv1 =                                        input.uv1;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.TerrainColorMatch = input.TerrainColorMatch;
        output.BiasedFade = input.BiasedFade;
        output.Falloff = input.Falloff;
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}