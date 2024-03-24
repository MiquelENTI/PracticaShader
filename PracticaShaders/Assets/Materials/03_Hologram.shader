Shader"ENTI/03_Hologram"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Power ("Power", float) = 1.0

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", float) = 5
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", float) = 5

        _Scale("Scale", float) = 1.0
        _LinesDisplacement("Displacement", float) = 1.0
        _LinesTex("Displacement Texture", 2D) = "WHITE" {}
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };
            


            struct v2f
            {
                float4 vertex : SV_POSITION;
                half3 normal : NORMAL;
                half3 viewDirection : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float4 dispTex : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _LinesTex;
            float4 _LinesTex_ST;

            float _Power;
            float _Scale;
            float _Displacement;


            v2f vert(appdata v)
            {    
    
                v2f o;


                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
        
                //o.viewDirection = normalize(mul((float3x3) unity_CameraToWorld, float3(0, 0, 1)));
                o.viewDirection = normalize(WorldSpaceViewDir(v.vertex));





                v.vertex *= _Scale;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                half4 displacetex = tex2Dlod(_LinesTex, float4(worldPos.x, worldPos.y * _Time.x, 0, 0));

                v.vertex.xyz += _Displacement * v.normal * displacetex;

                o.dispTex = displacetex;


    
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col;
                //col.xyz = i.viewDirection;
                float fresnel = dot(i.normal, i.viewDirection);
                fresnel = saturate(1 - fresnel);
                fresnel = pow(fresnel, _Power);
    
                fixed4 fresnelColor = fresnel * _Color;
                col = fresnelColor;

                col += i.dispTex;
    
                return col;
            }
            ENDCG
        }
    }
}

