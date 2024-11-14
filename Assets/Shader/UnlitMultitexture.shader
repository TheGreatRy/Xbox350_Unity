Shader "Xbox350/Unlit_Multitexture"
{
    Properties
    {
        _MainTex1 ("Texture", 2D) = "white" {}
        _Scroll1("Scroll", Vector) = (0,0,0)
        _MainTex2 ("Texture", 2D) = "white" {}
        _Scroll2("Scroll", Vector) = (0,0,0)
        _Tint ("Tint", Color) = (1,1,1,1)
        _Intensity("Intensity", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex1;
            sampler2D _MainTex2;
            float4 _MainTex1_ST;
            float4 _MainTex2_ST;

            fixed4 _Tint;
            float _Intensity;
            float4 _Scroll1;
            float4 _Scroll2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex1);

                o.uv.x = o.uv.x + (_Time.y * _Scroll1.x);
                o.uv.y = o.uv.y + (_Time.y * _Scroll1.y);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex2);

                o.uv.x = o.uv.x + (_Time.y * _Scroll2.x);
                o.uv.y = o.uv.y + (_Time.y * _Scroll2.y);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 c1 = tex2D(_MainTex1, i.uv);
                fixed4 c2 = tex2D(_MainTex2, i.uv);
                // apply fog
                fixed4 color = lerp(c1,c2,0.5)
                
                UNITY_APPLY_FOG(i.fogCoord, col);

                return color;
            }
            ENDCG
        }
    }
}
