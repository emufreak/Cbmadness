Shader "Custom/CBDefaultShader"
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
            uniform float _Size2;

            fixed4 cblayer(fixed4 inputcolor, v2f i, float size) { //Invertfunct
              fixed4 color = fixed4(0.95, 0.85, 0.77, 0);
              color = color - color * pow(0.99, size) - 0.05;
              float2 pos = floor((i.vertex - float2(160.0, 128.0) + (uint) size / 2) / (uint) size);
              float PatternMask = abs((pos.x + (pos.y % 2)) % 2.0);
              fixed4 col = color * PatternMask + inputcolor * ((PatternMask + 1) % 2);
              return col;
            }

            fixed4 frag(v2f i) : SV_Target{
               //int isize2 = (int)_Size2;
               fixed4 col = cblayer(fixed4(0, 0, 0, 0), i, _Size);
               col = cblayer(col, i, _Size * 1.5422); 
               col = cblayer(col, i, _Size * pow(1.5422, 2)); 
               col = cblayer(col, i, _Size * pow(1.5422, 3)); 
               col = cblayer(col, i, _Size * pow(1.5422, 4)); 
               col = cblayer(col, i, _Size * pow(1.5422, 5)); 
               col = cblayer(col, i, _Size * pow(1.5422, 6)); 
               col = cblayer(col, i, _Size * pow(1.5422, 7)); 
               return col;
            }
            ENDCG
        }
    }
}
