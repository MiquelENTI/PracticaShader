Shader"ENTI/08_CelShade"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white" {}

        [Space(10)]
        [Header(Diffuse)]
        _Attenuation("Attenuation", Range(0.001, 5)) = 1.0
        

        [Space(10)]
        [Header(Ambient)]
        _Color ("Ambient Color", Color) = (1,1,1,1)
        _AmbientIntensity("Ambient Intensity", Range(0.001, 5)) = 1.0

        [Space(10)]
        [Header(Specular)]
        _SpecColor("Specular Color", Color) = (1,1,1,1)
        _SpecPow("Specular Power", Range(0.001, 5)) = 1.0
        _SpecIntensity("Specular Intensity", Range(0.001, 5)) = 1.0

[Space(1)]
[Header(Celshade)]
_CelThreshold("Celshade Threshold", Range(0,1)) = 1.0
_ShadowColor("Shadow Color", Color) = (1,1,1,1)
_ShadowIntensity("Shadow Intensity", Range(0,1)) = 1.0

[Space(1)]
[Header(Outline)]
_OutlineWidth("Outline Width", Range(0,0.1)) = 0.05

    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 viewdir : TEXCOORD1;
                float4 color : COLOR;
            };

            fixed4 _Color, _SpecColor, _ShadowColor;
            float _Attenuation, _AmbientIntensity, _SpecPow, _SpecIntensity, _CelThreshold, _ShadowIntensity;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            uniform float4 _LightColor0;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex = UnityObjectToClipPos(v.vertex);
    
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.viewdir = normalize(WorldSpaceViewDir(v.vertex));
    
    
    
                
    
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
    
                            //get light direction
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    
                            //diffuse direction
                float3 diffuseReflection = dot(i.normal, lightDirection);
                diffuseReflection = max(0.0, diffuseReflection) * _Attenuation;
    
                //celshade
                fixed light = step(_CelThreshold, diffuseReflection);
                light = lerp(_ShadowIntensity, fixed(1), light);
                fixed3 lightCol = lerp(_ShadowColor.rgb, _LightColor0.rgb, light);
    
                            //specular reflection
                float3 x = reflect(-lightDirection, i.normal);
                float3 specularReflection = dot(x, i.viewdir);
                specularReflection = pow(max(0.0, specularReflection), _SpecPow) * _SpecIntensity;
    
                float3 halfDirection = normalize(lightDirection + i.viewdir);
                float specularAngle = max(0.0, dot(halfDirection, i.normal));
                specularReflection = pow(specularAngle, _SpecPow) * _SpecIntensity;
    
                specularReflection *= diffuseReflection;
                specularReflection *= _SpecColor.rgb;
    
    
                //float3 lightFinal = diffuseReflection * _LightColor0.rgb;
                float3 lightFinal = lightCol;
    
                            //lightFinal += UNITY_LIGHTMODEL_AMBIENT.rgb;
                            //lightFinal += _Color.rgb;
                lightFinal += (_Color.rgb * _AmbientIntensity);
                lightFinal += specularReflection;
    
                i.color = float4(lightFinal, 1.0);
    
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            float _OutlineWidth;

            v2f vert(appdata v)
            {
                v2f o;

                v.vertex.xyz += _OutlineWidth * v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _Color;
            }

            ENDCG
        }
    }
}


