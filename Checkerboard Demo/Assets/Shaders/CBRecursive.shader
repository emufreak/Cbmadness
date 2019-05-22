Shader "Custom/CBRecursiveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            uniform float _Size;


            fixed4 cblayer(fixed4 inputcolor, v2f i, float size, float isize) {
              fixed4 color = fixed4(0.95, 0.85, 0.77, 0);
              color = color - color * pow(0.99, size) -0.05;
              float2 pos = floor((i.vertex - float2(160.0, 128.0) + isize/2) / isize);
              float PatternMask = abs((pos.x + (pos.y % 2)) % 2.0);   
              fixed4 col = color * PatternMask + inputcolor * ((PatternMask + 1) % 2);
              return col;
            }

            fixed4 frag (v2f i) : SV_Target {
               int isize = (int) _Size;
               fixed4 col = cblayer(fixed4(0, 0, 0, 0), i, _Size, isize);
               col = cblayer(col, i, _Size * 3, isize * 3);
               col = cblayer(col, i, _Size * 9, isize * 9);
               col = cblayer(col, i, _Size * 27, isize * 27);
               return col;
            }

            ENDCG
        }
    }
}
  