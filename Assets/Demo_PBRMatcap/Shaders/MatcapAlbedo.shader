﻿Shader "Matcap/Albedo"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
		_Matcap ("Matcap", 2D) = "white" {}
		_MatcapPower ("Matcap Power", Float) = 1
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_matcap : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _Matcap;
			float _MatcapPower;

			float2 getMatcapUV(float3 viewNormal, float3 viewDir)
			{
				float3 viewCross = cross(viewDir, viewNormal);
				viewNormal = float3(-viewCross.y, viewCross.x, 0.0);
				viewNormal = viewNormal * 0.5 + 0.5;
				return viewNormal.xy;
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 viewNormal = normalize(mul(UNITY_MATRIX_MV, v.normal));
				float3 viewPos = UnityObjectToViewPos(v.vertex);
                float3 viewDir = normalize(viewPos);
				o.uv_matcap = getMatcapUV(viewNormal, viewDir);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 matcapCol = tex2D(_Matcap, i.uv_matcap);
				matcapCol *= _MatcapPower;

                fixed4 col = tex2D(_MainTex, i.uv);
				col *= matcapCol;

                return col;
            }
            ENDCG
        }
    }
}
