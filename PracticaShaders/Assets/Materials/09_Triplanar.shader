Shader"ENTI/09_Triplanar"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "black" {}
        _SecondaryTex("Secondary Tex", 2D) = "black" {}

        _Color ("Ambient Color", Color) = (1,1,1,1)

        _Sharpness("Sharpness", Range(1,64)) = 1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float3 worldPos : TEXCOORD0;
                float3 normal : NORMAL;
};

            fixed4 _Color;

            sampler2D _MainTex, _SecondaryTex;
            float4 _MainTex_ST, _SecondaryTex_ST;
float _Sharpness;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xyz;
                o.normal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
    
                float2 uv_front = TRANSFORM_TEX(i.worldPos.yz, _MainTex);
                float2 uv_top = TRANSFORM_TEX(i.worldPos.xz, _SecondaryTex);
                float2 uv_side = TRANSFORM_TEX(i.worldPos.xy, _MainTex);
    
    
                fixed4 col_front = tex2D(_MainTex, uv_front);
                fixed4 col_top = tex2D(_SecondaryTex, uv_top);
                fixed4 col_side = tex2D(_MainTex, uv_side);
    
                float3 weight = i.normal;
                weight = abs(weight);
    
                if(i.normal.y < 0.0)
                {
                    uv_top = TRANSFORM_TEX(i.worldPos.xz, _MainTex);
                    col_top = tex2D(_MainTex, uv_top);
                }

   
                weight = pow(weight, _Sharpness);
                weight = weight / (weight.x + weight.y + weight.z);
    
                col_front *= weight.x;
                col_top *= weight.y;
                col_side *= weight.z;
    
                fixed4 col = col_front + col_top + col_side;
    
                return col;
            }
            ENDCG
        }
    }
}


