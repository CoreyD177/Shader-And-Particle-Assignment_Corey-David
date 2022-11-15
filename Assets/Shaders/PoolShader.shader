Shader "Custom/PoolShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _MetallicMap ("Metallic", 2D) = "white" { }
        [Normal]  _BumpMap ("Normal Map", 2D) = "bump" { }
        _Wave1 ("Wave 1", Vector) = (0.5,0.5,0.15,1)
        _Wave2 ("Wave 2", Vector) = (0,0.5,0.25,1)
        _Wave3 ("Wave 3", Vector) = (0.5,0.5,0.15,1)
    }
    SubShader
    {
        Tags {"RenderQueue"="Transparent" "RenderType"="Fade" }
        LOD 300
        Cull off
        Zwrite off
        Blend One One

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows BlinnPhong vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_MetallicMap;
        };
        half _Glossiness;
        sampler2D _MetallicMap;
        sampler2D _BumpMap;
        fixed4 _Color;
        float4 _Wave1, _Wave2, _Wave3;
        

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float3 Waves(float4 wave, float3 pnt, inout float3 tangent, inout float3 binormal)
        {
            float steepness = wave.z;
            float waveLength = wave.w;
            float k = UNITY_TWO_PI / waveLength;
            float c = sqrt(9.8/k);
            float2 direction = normalize(wave.xy);
            float f = k * (dot(direction, pnt.xz) - c * _Time.y);
            float amplitude = steepness / k;
            tangent += float3( - direction.x * direction.x * (steepness * sin(f)), direction.x * (steepness * cos(f)),-direction.x * direction.y * (steepness * sin(f)));
            binormal += float3(-direction.x * direction.y * (steepness * sin(f)), direction.y * (steepness * cos(f)), 1-direction.y * direction.y * (steepness * sin(f)));
            return float3(direction.x * (amplitude * cos(f)), amplitude * sin(f), direction.y * (amplitude * cos(f)));
        }
        
        void vert (inout appdata_full vertexData)
        {
            float3 gridPoint = vertexData.vertex.xyz;
            float3 tangent = float3(1,0,0);
            float3 binormal = float3(0,0,1);
            float3 p = gridPoint;
            p += Waves(_Wave1, gridPoint, tangent, binormal);
            p += Waves(_Wave2, gridPoint, tangent, binormal);
            p += Waves(_Wave3, gridPoint, tangent, binormal);
            float3 normal = normalize(cross(binormal,tangent));
            vertexData.vertex.xyz = p;
            vertexData.normal = normal;
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap));
            fixed4 metal = tex2D (_MetallicMap, IN.uv_MetallicMap); 
            o.Metallic = metal.r;
            o.Smoothness = _Glossiness;

            
        }
        ENDCG
    }
    FallBack "Diffuse"
}
