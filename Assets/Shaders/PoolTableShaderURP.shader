Shader "Custom/Pool Table Shader URP"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _MetallicMap ("Metallic", 2D) = "white" { }
        [Normal]  _BumpMap ("Normal Map", 2D) = "bump" { }
        _Cutoff("Alpha cutoff", Range(0,1)) = 0.9
    }
        SubShader
    {
        Tags {
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "Queue" = "Transparent"
            "RenderType" = "TransparentCutOut"
        }
        LOD 300
        Cull off

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }


            HLSLPROGRAM
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma shader_feature _ALPHATEST_ON

            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float3 tbn[3] : TEXCOORD3; 
            };
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            struct Input
            {
                float2 uv_MainTex;
                float2 uv_BumpMap;
                float2 uv_MetallicMap;
            };
            half _Glossiness;
            sampler2D _MetallicMap;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            half _Cutoff;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BumpMap);
                float3 normal = TransformObjectToWorldNormal(v.normal);
                float3 tangent = TransformObjectToWorldNormal(v.tangent.xyz);
                float3 bitangent = cross(tangent, normal);
                o.tbn[0] = tangent;
                o.tbn[1] = bitangent;
                o.tbn[2] = normal;
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.normal = normal;
                return o;
            }

            

            float3 Lambert(float3 lightColor, float3 lightDir, float3 normal)
            {
                float NdotL = saturate(dot(normal, lightDir));
                return lightColor * NdotL;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                half3 tangentNormal = UnpackNormal(tex2D (_BumpMap, i.uv)) * 2 - 1;
                half3 surfaceNormal = i.tbn[2];
                half3 worldNormal = float3(i.tbn[0] * tangentNormal.r + i.tbn[1] * tangentNormal.g + i.tbn[2] * tangentNormal.b);
                float4 color = tex2D(_MainTex, i.uv);
                float3 lightPos = _MainLightPosition.xyz;
                float3 lightCol = Lambert(_MainLightColor * unity_LightData.z, lightPos, worldNormal);

                uint lightsCount = GetAdditionalLightsCount();
                for (uint j = 0; j < lightsCount; j++)
                {
                    Light light = GetAdditionalLight(j, i.worldPos);
                    lightCol += Lambert(light.color * (light.distanceAttenuation * light.shadowAttenuation), light.direction, worldNormal);
                }
                half alpha = color.a * _Color.a;
                AlphaDiscard(alpha, _Cutoff);
                

                return color;
            }
            ENDHLSL
        }
    }
}