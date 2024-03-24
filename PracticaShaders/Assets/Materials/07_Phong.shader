Shader"ENTI/07_Phong"
{
    Properties
    {
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            fixed4 _Color, _SpecColor;
            float _Attenuation, _AmbientIntensity, _SpecPow, _SpecIntensity;

uniform float4 _LightColor0;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
    
                float3 viewDirection = normalize(WorldSpaceViewDir(v.vertex));
                //get normal direction
                float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
    
                //get light direction
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    
                //diffuse direction
                float3 diffuseReflection = dot(normalDirection, lightDirection);
                diffuseReflection = max(0.0, diffuseReflection) * _Attenuation;
    
                //specular reflection
                float3 x = reflect(-lightDirection, normalDirection);
                float3 specularReflection = dot(x, viewDirection);
                specularReflection = pow(max(0.0, specularReflection), _SpecPow) * _SpecIntensity;
                specularReflection *= diffuseReflection;
                specularReflection *= _SpecColor.rgb;
    
    
                float3 lightFinal = diffuseReflection * _LightColor0.rgb;
    
                //lightFinal += UNITY_LIGHTMODEL_AMBIENT.rgb;
                //lightFinal += _Color.rgb;
                lightFinal += (_Color.rgb * _AmbientIntensity);
                lightFinal += specularReflection;
    
                o.color = float4(lightFinal, 1.0);
    
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}


