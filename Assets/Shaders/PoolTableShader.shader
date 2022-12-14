Shader "Custom/PoolTableShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _MetallicMap ("Metallic", 2D) = "white" { }
        [Normal]  _BumpMap ("Normal Map", 2D) = "bump" { }
        _Cutoff("Alpha cutoff", Range(0,1)) = 0.5
        
    }
    SubShader
    {
        Tags {"RenderQueue"="Transparent" "RenderType"="TransparentCutout" }
        LOD 300
        Cull off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow alphatest:_Cutoff

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
        

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {

            // Albedo comes from a texture tinted by color
            half4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap));
            fixed4 metal = tex2D (_MetallicMap, IN.uv_MetallicMap); 
            o.Metallic = metal.r;
            o.Smoothness = _Glossiness;

            
        }
        ENDCG
    }
    //FallBack "Diffuse"
}
