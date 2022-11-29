Shader "Custom/dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _MetallicMap("Metallic", 2D) = "white" { }
        [Normal]  _BumpMap("Normal Map", 2D) = "bump" { }
        _DissolveTexture("Dissolve Texture", 2D) = "white" {}
        _Amount("Amount", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300
        Cull Off
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard addshadow
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        sampler2D _MainTex;
        sampler2D _DissolveTexture;
        half _Amount; // half a float
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
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half dissolve_value = tex2D(_DissolveTexture, IN.uv_MainTex).r;
            clip(dissolve_value - _Amount);
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            //Add normal from map
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            //Add metallic from map
            fixed4 metal = tex2D(_MetallicMap, IN.uv_MetallicMap);
            o.Metallic = metal.r;
            //Smoothness from slider
            o.Smoothness = _Glossiness;
           o.Emission = fixed3(1, 0, 0.3928) * step( dissolve_value - _Amount, 0.05f);
            o.Alpha = c.a;// (0 > dissolve_value - _Amount);
        }
        ENDCG
    }
    Fallback "Transparent/VertexLit"
}