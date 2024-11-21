Shader "Xbox350/UnlitWarp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //The speed the object oscilates
        _Speed ("Speed", Range(0.1, 5.0)) = 1.0
        //How big the oscilation is
        _Size ("Size", Range(0.1, 5.0)) = 1.0

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
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _Size;
            
            //Random function that gets one value from a pair (Prof Maple)
            float random(float2 st) 
			{
				return frac(sin(dot(st.xy,
					float2(12.9898,78.233))) * 43758.5453123);
			}
 
            //Random function that gets two values from a pair (Prof Maple)
			float2 random2(float2 st)
			{
				st = float2(dot(st,float2(127.1,311.7)),
						   dot(st,float2(269.5,183.3)));
				return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
			}

            //Rotation about a pair and uses a float to determine the rate of the waves (https://www.shadertoy.com/view/MdtXRr)
            float2 rotate(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return p*(float2(c,s)*float2(-s,c));
            }

            v2f vert (appdata v)
            {
                v2f o;
                
                //Rotate about each pair of axes to get full oscilation, speed affectes rate and size affects how far the object oscilates
                v.vertex.xz = rotate(v.vertex.xz, _Time.y * _Speed) * _Size;
                v.vertex.xy= rotate(v.vertex.xy, _Time.y * _Speed) * _Size;
                v.vertex.yz = rotate(v.vertex.yz, _Time.y * _Speed) * _Size;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 color = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, color);
                return color;
            }
            ENDCG
        }
    }
}
