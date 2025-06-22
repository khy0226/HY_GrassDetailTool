Shader "HY_Shader/HY_GrassVertexTest"
{
    Properties
    {
        [HDR]_BaseColor("Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BaseMap("Base Map", 2D) = "white" {}
        _Cutoff("Cutoff", Range(0, 1)) = 0.5

        // Occlusion
        [Space(20)]
        _OcclusionMin("OcclusionMin", Range(0, 1)) = 0
        _OcclusionMax("OcclusionMax", Range(0, 1)) = 1
        _OcclusionColor("OcclusionColor", Color) = (0.5, 0.5, 0.5, 1)

        // Subsurface
        [Space(20)]
        [ToggleUI]_SubsurfaceOnOff("SubsurfaceOnOff", Float) = 0
        [HDR]_SubsurfaceColor("SubsurfaceColor", Color) = (1, 1, 1, 1)
        _SubsurfaceIntensity("SubsurfaceIntensity", Range(0, 1)) = 0.5
        _SubsurfaceScattering("SubsurfaceScattering", Range(0, 16)) = 8
        _SubsurfaceAngle("SubsurfaceAngle", Range(1, 16)) = 1
                
        // Noise Mask (for Color Variation)
        [Space(20)]
        [ToggleUI]_NoiseColorOnOff("Noise Color", Float) = 0
        _NoiseColor1("NoiseColor1", Color) = (1, 1, 1, 1)
        _NoiseColor2("NoiseColor2", Color) = (1, 1, 1, 1)
        _NoiseMaskMin("NoiseMaskMin", Range(0, 1)) = 0
        _NoiseMaskMax("NoiseMaskMax", Range(0, 1)) = 1
        _NoiseMaskScale("NoiseMaskScale", Range(0, 1)) = 1
        
        [Space(20)]
        [NoScaleOffset]_NoiseTex("Noise Texture", 2D) = "white" {}

        // Wind
        [Space(20)]
        [ToggleUI]_WindOnOff("WindOn/Off", Float) = 0
        _MotionBending("MotionBending", Range(0, 2)) = 1
        _MotionSpeed("MotionSpeed", Range(0, 20)) = 5
        _MotionScale("MotionScale", Range(0, 10)) = 3
        _MotionVariation("MotionVariation", Range(0, 10)) = 1

        [Space(20)]
        [ToggleUI]_WideGrass("Wide Grass", Float) = 0

        // Fade Out
        [Space(20)]
        [ToggleUI]_FadeOutOnOff("FadeOutOn/Off", Float) = 0
        _FadeStart("FadeStart", Float) = 60
        _FadeEnd("FadeEnd", Float) = 100

    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
            "DisableBatching"="False"
        }
        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            Cull Off
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile_fog
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor; 
                float _Cutoff;
                float _OcclusionMin, _OcclusionMax; 
                float4 _OcclusionColor;
                float _SubsurfaceOnOff, _SubsurfaceIntensity, _SubsurfaceScattering, _SubsurfaceAngle; 
                float4 _SubsurfaceColor;
                float _WindOnOff, _WideGrass, _MotionBending, _MotionSpeed, _MotionScale, _MotionVariation;
                float _FadeOutOnOff, _FadeStart, _FadeEnd;
                float4 _NoiseColor1, _NoiseColor2; 
                float _NoiseColorOnOff, _NoiseMaskMin, _NoiseMaskMax, _NoiseMaskScale;
            CBUFFER_END
            
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseTex);  SAMPLER(sampler_linear_repeat);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0; 
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };
            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;
                float3 normalWS     : TEXCOORD2;
                float3 vertexLight  : TEXCOORD3;
                float  height       : TEXCOORD4;
                #ifdef _FOG
                    half fogCoord    : TEXCOORD5;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            #include "GrassAnimation.hlsl"

            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 worldPos = TransformObjectToWorld(v.positionOS.xyz);
                float3 animatedPosOS = AnimateVertex(v.positionOS.xyz, worldPos);

                o.positionWS = TransformObjectToWorld(animatedPosOS);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionCS = TransformWorldToHClip(o.positionWS);

                half3 bakedGI = SampleSH(o.normalWS);
                half3 indirectDiffuse = bakedGI;
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(o.positionWS));
                half NdotL = saturate(dot(o.normalWS, mainLight.direction));
                half3 directDiffuse = mainLight.color * NdotL * mainLight.shadowAttenuation;

                #if defined(_ADDITIONAL_LIGHTS) || defined(_ADDITIONAL_LIGHTS_VERTEX)
                {
                    uint lightCount = GetAdditionalLightsCount();

                    #if USE_FORWARD_PLUS
                    for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
                    {
                        FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

                        Light light = GetAdditionalPerObjectLight(lightIndex, o.positionWS);
                        light.shadowAttenuation = AdditionalLightRealtimeShadow(lightIndex, o.positionWS, light.direction);
        
                        float NdotL = saturate(dot(o.normalWS, light.direction));
                        directDiffuse += light.color * NdotL * light.distanceAttenuation * light.shadowAttenuation;
                    }
                    #endif

                    #if USE_FORWARD_PLUS
                    #define LIGHT_LOOP_BEGIN_Custom(lightCount) { \
                        uint lightIndex; \
                        ClusterIterator _urp_internal_clusterIterator = ClusterInit(v.uv, o.positionWS, 0); \
                        [loop] while (ClusterNext(_urp_internal_clusterIterator, lightIndex)) { \
                            lightIndex += URP_FP_DIRECTIONAL_LIGHTS_COUNT; \
                            FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
                        #define LIGHT_LOOP_END } }
                    #elif !_USE_WEBGL1_LIGHTS
                        #define LIGHT_LOOP_BEGIN_Custom(lightCount) \
                        for (uint lightIndex = 0u; lightIndex < lightCount; ++lightIndex) {

                        #define LIGHT_LOOP_END }
                    #else
                        #define LIGHT_LOOP_BEGIN_Custom(lightCount) \
                        for (int lightIndex = 0; lightIndex < _WEBGL1_MAX_LIGHTS; ++lightIndex) { \
                            if (lightIndex >= (int)lightCount) break;

                        #define LIGHT_LOOP_END }
                    #endif

                    LIGHT_LOOP_BEGIN_Custom(lightCount)
                        Light light = GetAdditionalPerObjectLight(lightIndex, o.positionWS);
                        light.shadowAttenuation = AdditionalLightRealtimeShadow(lightIndex, o.positionWS, light.direction);
        
                        float NdotL = saturate(dot(o.normalWS, light.direction));
                        directDiffuse += light.color * NdotL * light.distanceAttenuation * light.shadowAttenuation;
                    LIGHT_LOOP_END
                }
                #endif
                o.vertexLight = directDiffuse + indirectDiffuse;
                
                o.uv = v.uv;
                o.height = v.positionOS.y;
                #ifdef _FOG
                    o.fogCoord = ComputeFogFactor(o.positionCS.z);
                #endif
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half4 color = baseMap * _BaseColor;

                clip(baseMap.a * _BaseColor.a - _Cutoff);
                
                half occlusionFactor = saturate((i.height - _OcclusionMin) / (_OcclusionMax - _OcclusionMin + 0.0001)); 
                color.rgb *= lerp(_OcclusionColor.rgb, 1, occlusionFactor);
                
                if (_NoiseColorOnOff)
                {
                float2 noiseUV = i.positionWS.xz * _NoiseMaskScale * 0.1;
                half noiseVal = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_linear_repeat, noiseUV, 0).b;
                noiseVal = saturate((noiseVal - _NoiseMaskMin) / (_NoiseMaskMax - _NoiseMaskMin + 0.0001));
                half3 noiseColor = lerp(_NoiseColor1.rgb, _NoiseColor2.rgb, noiseVal);
                color.rgb *= noiseColor;
                } 
                
                half3 baseOccNoise = color.rgb;

                color.rgb *= i.vertexLight;

                if (_SubsurfaceOnOff) 
                {
                    Light mainLight = GetMainLight(TransformWorldToShadowCoord(i.positionWS));
                    half3 viewDir = GetWorldSpaceNormalizeViewDir(i.positionWS);
                    half sssDot = saturate(dot(-mainLight.direction, viewDir)); 
                    half sssFactor = pow(sssDot, _SubsurfaceAngle) * _SubsurfaceScattering;
                    half3 sssBaseOcc = _SubsurfaceColor.rgb  * baseOccNoise * _SubsurfaceIntensity;
                    half3 sssColor = sssFactor * sssBaseOcc;
                    color.rgb += sssColor;
                }                

                #ifdef _FOG
                    color.rgb = MixFog(color.rgb, i.fogCoord);
                #endif
                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert; 
            #pragma fragment frag;
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor; 
                float _Cutoff;
                float _OcclusionMin, _OcclusionMax; 
                float4 _OcclusionColor;
                float _SubsurfaceOnOff, _SubsurfaceIntensity, _SubsurfaceScattering, _SubsurfaceAngle; 
                float4 _SubsurfaceColor;
                float _WindOnOff, _WideGrass, _MotionBending, _MotionSpeed, _MotionScale, _MotionVariation;
                float _FadeOutOnOff, _FadeStart, _FadeEnd;
                float4 _NoiseColor1, _NoiseColor2; 
                float _NoiseColorOnOff, _NoiseMaskMin, _NoiseMaskMax, _NoiseMaskScale;
            CBUFFER_END

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseTex);  
            SAMPLER(sampler_linear_repeat);
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0; 
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };
            
            #include "GrassAnimation.hlsl"

            Varyings vert(Attributes v) 
            {
                Varyings o; 
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                float3 worldPos = TransformObjectToWorld(v.positionOS.xyz);
                float3 animatedPosOS = AnimateVertex(v.positionOS.xyz, worldPos);
                float3 animatedWorldPos = TransformObjectToWorld(animatedPosOS);

                o.positionCS = TransformWorldToHClip(animatedWorldPos);
                o.uv = v.uv; 
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET 
            {
                UNITY_SETUP_INSTANCE_ID(i);
                half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv).a;
                clip(alpha - _Cutoff); 
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert; 
            #pragma fragment frag;
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor; 
                float _Cutoff;
                float _OcclusionMin, _OcclusionMax; 
                float4 _OcclusionColor;
                float _SubsurfaceOnOff, _SubsurfaceIntensity, _SubsurfaceScattering, _SubsurfaceAngle; 
                float4 _SubsurfaceColor;
                float _WindOnOff, _WideGrass, _MotionBending, _MotionSpeed, _MotionScale, _MotionVariation;
                float _FadeOutOnOff, _FadeStart, _FadeEnd;
                float4 _NoiseColor1, _NoiseColor2; 
                float _NoiseColorOnOff, _NoiseMaskMin, _NoiseMaskMax, _NoiseMaskScale;
            CBUFFER_END

            TEXTURE2D(_BaseMap); 
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseTex);  
            SAMPLER(sampler_linear_repeat);

            struct Attributes 
            { 
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings 
            { 
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            #include "GrassAnimation.hlsl" 
            
            Varyings vert(Attributes v) 
            {
                Varyings o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                float3 worldPos = TransformObjectToWorld(v.positionOS.xyz);
                float3 animatedPosOS = AnimateVertex(v.positionOS.xyz, worldPos);
                float3 animatedWorldPos = TransformObjectToWorld(animatedPosOS);

                o.positionCS = TransformWorldToHClip(animatedWorldPos);
                o.uv = v.uv; 
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(i);
                half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv).a;
                clip(alpha - _Cutoff); 
                return 0;
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }

            ZWrite On
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert; 
            #pragma fragment frag;
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor; 
                float _Cutoff;
                float _OcclusionMin, _OcclusionMax; 
                float4 _OcclusionColor;
                float _SubsurfaceOnOff, _SubsurfaceIntensity, _SubsurfaceScattering, _SubsurfaceAngle; 
                float4 _SubsurfaceColor;
                float _WindOnOff, _WideGrass, _MotionBending, _MotionSpeed, _MotionScale, _MotionVariation;
                float _FadeOutOnOff, _FadeStart, _FadeEnd;
                float4 _NoiseColor1, _NoiseColor2; 
                float _NoiseColorOnOff, _NoiseMaskMin, _NoiseMaskMax, _NoiseMaskScale;
            CBUFFER_END

            TEXTURE2D(_BaseMap); 
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseTex); 
            SAMPLER(sampler_linear_repeat);

            struct Attributes
            { 
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };
            struct Varyings 
            { 
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            #include "GrassAnimation.hlsl"
            
            Varyings vert(Attributes v)
            {
                Varyings o;
                UNITY_SETUP_INSTANCE_ID(v); 
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                float3 worldPos = TransformObjectToWorld(v.positionOS.xyz);
                float3 animatedPosOS = AnimateVertex(v.positionOS.xyz, worldPos);
                float3 animatedWorldPos = TransformObjectToWorld(animatedPosOS);

                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionCS = TransformWorldToHClip(animatedWorldPos);
                o.uv = v.uv;
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(i);
                half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv).a;
                clip(alpha - _Cutoff);
                return float4(normalize(i.normalWS) * 0.5 + 0.5, 0); 
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}