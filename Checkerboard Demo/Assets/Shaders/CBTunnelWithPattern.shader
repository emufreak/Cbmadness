Shader "Custom/CBTunnelWithPattern"
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
            uniform float _Size3;
            uniform float _Factor;
            uniform float _ColorMiddle;

            fixed4 cblayer(fixed4 inputcolor, v2f i, float size) {
              fixed4 color = fixed4(0.95, 0.85, 0.77, 0);
              color = color - color * pow(0.99, size) - 0.10;
              float2 pos = floor((i.vertex - float2(160.0, 128.0) + (uint) size / 2) / (uint) size);
              float PatternMask = abs((pos.x + (pos.y % 2)) % 2.0);
              fixed4 col = color * PatternMask + inputcolor * ((PatternMask + 1) % 2);
              return col;
            }

            fixed4 cblayerinv(fixed4 inputcolor, v2f i, float size,fixed4 trgcol, fixed4 bgcol, fixed colint) {
              float2 pos = floor((i.vertex - float2(160.0, 128.0) + (uint) size / 2) / (uint) size);
              float PatternMask = abs((pos.x + (pos.y % 2)) % 2.0);
              fixed4 color = trgcol - trgcol * pow(0.99, size) - 0.10;
              fixed4 col = abs(bgcol - color);
              col = (col * colint + abs(bgcol - 1) * (1 - colint)) * PatternMask;
              col = col + inputcolor * ((PatternMask + 1) % 2);
              return col;            
            }

            fixed4 frag(v2f i) : SV_Target {
              fixed4 trgcol = fixed4(0.95, 0.85, 0.77, 0);
              fixed4 bgcolor = _ColorMiddle;
              fixed colint = 1 - pow(0.99, _Size2) - 0.10;
              fixed4 col2 = cblayerinv(bgcolor * colint + abs(bgcolor - 1) * (1 - colint), i, _Size, trgcol, bgcolor, colint);
              col2 = cblayerinv(col2, i, _Size * _Factor, trgcol, bgcolor, colint);
              col2 = cblayerinv(col2, i, _Size * pow(_Factor, 2), trgcol, bgcolor, colint);
              float2 pos = floor((i.vertex - float2(160.0, 128.0) + (uint) _Size2 / 2) / (uint) _Size2); //Calculate CB-GridPos
              float PatternMask = abs(pos.x) + abs(pos.y) == 0;

              bgcolor = abs(_ColorMiddle - 1);
              fixed4 col = cblayerinv(bgcolor, i, _Size, trgcol, bgcolor, 1);
              col = cblayerinv(col, i, _Size * _Factor, trgcol, bgcolor, 1); 
              col = cblayerinv(col, i, _Size * pow(_Factor, 2), trgcol, bgcolor,1);
              col = col2 * PatternMask + col * ((PatternMask + 1) % 2);
              return col;
            }
              ENDCG
        }
    }
}
