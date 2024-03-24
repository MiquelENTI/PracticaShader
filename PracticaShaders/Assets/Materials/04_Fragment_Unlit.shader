Shader"ENTI/04_Fragment_Unlit"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1,1,1,1)
        _Color2 ("Color 2", Color) = (1,1,1,1)
        _Blend ("_Blend Value", Range(0,1)) = 1.0
        _Tex1("Texture 1", 2D) = "WHITE" {}
        _Tex2("Texture 2", 2D) = "WHITE" {}
        _Tex3("Texture 3", 2D) = "WHITE" {}
        _BlendTex("Blend Tex", 2D) = "WHITE" {}
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
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
            };
            


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

fixed4 _Color1, _Color2;
float _Blend;
sampler2D _Tex1, _Tex2, _Tex3, _BlendTex;
float4 _Tex1_ST, _Tex2_ST, _Tex3_ST, _BlendTex_ST;


            v2f vert(appdata v)
            {    
    
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
    
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col;
    
                //1. Blending
                col = _Color1 + _Color2 * _Blend;
    
                //2. Interpolation
                col = _Color1 * (1 - _Blend) + _Color2 * _Blend;
                col = lerp(_Color1, _Color2, _Blend);
    
                //3 Textures
                //calculate uv coordinates
                float2 first_uv = TRANSFORM_TEX(i.uv, _Tex1);
                float2 second_uv = TRANSFORM_TEX(i.uv, _Tex2);
                float2 third_uv = TRANSFORM_TEX(i.uv, _Tex3);
                //read colors from texture
                fixed4 first_color = tex2D(_Tex1, first_uv);
                fixed4 second_color = tex2D(_Tex2, second_uv);
                fixed4 third_color = tex2D(_Tex3, third_uv);
                //interpolate
    
                float2 blend_uv = TRANSFORM_TEX(i.uv, _BlendTex);
                fixed4 blend_color = tex2D(_BlendTex, blend_uv);
    
                //col = lerp(first_color, second_color, _Blend);
                col = _Color1;
                col = lerp(col, first_color, blend_color.r);
                col = lerp(col, second_color, blend_color.g);
                col = lerp(col, third_color, blend_color.b);
    
            //Sin
            float sin_value = sin(_Time.y);
            sin_value = saturate(sin_value); //Clamps the value = (0,1)
            sin_value = frac(sin_value); //returns fractional (decimal) = (0.0,0.9)
            col = lerp(col, first_color, sin_value);
    
                return col;
            }
            ENDCG
        }
    }
}

