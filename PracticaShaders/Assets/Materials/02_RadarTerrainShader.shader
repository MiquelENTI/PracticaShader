Shader"ENTI/02_RadarTerrainShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "WHITE" {}
        _Heatmap("Heatmap", 2D) = "white" {}
        _MaxHeight("Max Height", float) = 1.0

        _Position("Radar Position", vector) = (0.0, 0.0, 0.0)
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
                float2 uv : TEXCOORD0;
            };
            


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Heatmap; 
            float4 _Heatmap_ST;
            float _MaxHeight;
            float _Position;


            v2f vert(appdata v)
            {    
    
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float2 mapVector = tex2Dlod(_MainTex, float4(o.uv, 0, 0)).rg;
    
    
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
    
                float2 local_tex_Height = tex2Dlod(_MainTex, float4(v.uv, 0, 0));
                float l_Height = local_tex_Height.y * _MaxHeight;
                o.uv = float2(v.uv.x, local_tex_Height.y);
    
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
    
                o.vertex.y += l_Height;
    
                o.vertex = mul(UNITY_MATRIX_VP, o.vertex);   
                
    
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                fixed4 col = fixed4(tex2D(_Heatmap, i.uv).rgb,1.0);
            
                

                float3 pos = _Position;


                if (distance(_Position, i.worldPos) < 1.32)
                {
                    col = _Color;
                }
                
                /*if (distance((5, 5, 5), i.worldPos) < 1.32)
                {
                    col = _Color;
                }*/

                /*Este distance de aquí arriba debería funcionar,
                no se porque solo cuenta la z para hacer el distance
                y le da igual que cambie las demás coordenadas.
                El punto se muestra pero solo en el 0,0*/
                




                return col;
            }
            ENDCG
        }
    }
}

