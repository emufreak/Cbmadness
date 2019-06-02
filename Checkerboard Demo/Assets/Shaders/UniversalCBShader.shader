Shader "Custom/UniversalCBShader"
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
            uniform float _Size0;
            uniform float _Size1;
            uniform float _Size2;
            uniform float _Size3;
            uniform float _Size4;
            uniform float _Size5;
            uniform float _Size6;
            uniform float _Size7;
            uniform float _PosX0;
            uniform float _PosX1;
            uniform float _PosX2;
            uniform float _PosX3;
            uniform float _PosX4;
            uniform float _PosX5;
            uniform float _PosX6;
            uniform float _PosX7;
            uniform float _PosY0;
            uniform float _PosY1;
            uniform float _PosY2;
            uniform float _PosY3;
            uniform float _PosY4;
            uniform float _PosY5;
            uniform float _PosY6;
            uniform float _PosY7;
            uniform float _DetPosX0;
            uniform float _DetPosX1;
            uniform float _DetPosX2;
            uniform float _DetPosX3;
            uniform float _DetPosX4;
            uniform float _DetPosX5;
            uniform float _DetPosX6;
            uniform float _DetPosX7;
            uniform float _DetPosY0;
            uniform float _DetPosY1;
            uniform float _DetPosY2;
            uniform float _DetPosY3;
            uniform float _DetPosY4;
            uniform float _DetPosY5;
            uniform float _DetPosY6;
            uniform float _DetPosY7;
            uniform float _Color[512];
            uniform float _PatternData0[256];
            uniform float _PatternData1[256];
            uniform float _PatternData2[256];
            uniform float _PatternData3[256];
            uniform float _PatternData4[256];
            uniform float _PatternData5[256];
            uniform float _PatternData6[256];
            uniform float _PatternData7[256];
            uniform float _TotalLayers;

            uint cblayer( v2f i, int size, int posx
                                  , int posy, int detposx, int detposy,
                                                    float patdata[256]) {
                                                    
              uint xpos = posx + floor( (  detposx + i.vertex.x)/size);
              uint ypos = posy + floor( (  detposy + i.vertex.y)/size);
              uint selectedpattern = (uint) patdata[ xpos/16 + ypos*4];
              int xpospattern = 15 - ( xpos - 16*( xpos/16));
              uint Patternmask = (  selectedpattern & (uint) pow(2, xpospattern)) > 0;

              return Patternmask;
            }

            fixed4 frag(v2f i) : SV_Target{ 

              uint colind;
              if(_TotalLayers >= 1) 
                colind = cblayer(i, _Size0, _PosX0, 
                         _PosY0, _DetPosX0, _DetPosY0, _PatternData0);
              if(_TotalLayers >= 2)
                colind += cblayer(i, _Size1, _PosX1,
                         _PosY1, _DetPosX1, _DetPosY1, _PatternData1) * 2;
              if (_TotalLayers >= 3)
                colind += cblayer(i, _Size2, _PosX2,
                         _PosY2, _DetPosX2, _DetPosY2, _PatternData2) * 4;
              if (_TotalLayers >= 4)
                colind += cblayer(i, _Size3, _PosX3,
                         _PosY3, _DetPosX3, _DetPosY3, _PatternData3) * 8;
              if (_TotalLayers >= 5)
                colind += cblayer(i, _Size4, _PosX4,
                          _PosY4, _DetPosX4, _DetPosY4, _PatternData4) * 16;
              if (_TotalLayers >= 6)
                colind += cblayer(i, _Size5, _PosX5,
                          _PosY5, _DetPosX5, _DetPosY5, _PatternData5) * 32;
              if (_TotalLayers >= 7)
               colind += cblayer(i, _Size6, _PosX6,
                          _PosY6, _DetPosX6, _DetPosY6, _PatternData6) * 64;
              if (_TotalLayers >= 8)
                colind += cblayer(i, _Size7, _PosX7,
                          _PosY7, _DetPosX7, _DetPosY7, _PatternData7) * 128;

              //return fixed4(colind/128, 0,0,0);
              uint colvalhw =  _Color[  colind * 2];
              uint colvallw = _Color[colind * 2 + 1];
              fixed r = (fixed) ( (float) (colvalhw & 0xf00) /15 + (float) (colvallw & 0xf00) / 255) / 255;
              fixed g = (fixed) ( (float) (colvalhw & 0xf0) + (float) (colvallw & 0xf0) / 15) / 255;
              fixed b = (fixed)( (float) (colvalhw & 0xf) * 15 + (float) (colvallw & 0xf) ) / 255;
              return fixed4(  r, g, b, 0);

            }
            ENDCG
        }
    }
}
