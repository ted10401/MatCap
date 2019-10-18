Shader "Matcap/AlbedoNormal"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
		_BumpMap ("Normal", 2D) = "bump" {}
		_BumpValue ("Normal Value", Range(0,10)) = 1
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
				float3 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_normal : TEXCOORD1;
				float3	TtoV0 : TEXCOORD2;
				float3	TtoV1 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float _BumpValue;
			sampler2D _Matcap;
			float4 _Matcap_ST;
			float _MatcapPower;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_normal = TRANSFORM_TEX(v.texcoord, _Matcap);

				TANGENT_SPACE_ROTATION;
				o.TtoV0 = normalize(mul(rotation, UNITY_MATRIX_IT_MV[0].xyz));
				o.TtoV1 = normalize(mul(rotation, UNITY_MATRIX_IT_MV[1].xyz));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 normal = UnpackNormal(tex2D(_BumpMap, i.uv_normal));
				normal.xy *= _BumpValue;
				normal.z = sqrt(1.0- saturate(dot(normal.xy, normal.xy)));
				normal = normalize(normal);
					
				float2 uv_matcap;
				uv_matcap.x = dot(i.TtoV0, normal);
				uv_matcap.y = dot(i.TtoV1, normal);

				fixed4 matcapCol = tex2D(_Matcap, uv_matcap);
				matcapCol *= _MatcapPower;

                fixed4 col = tex2D(_MainTex, i.uv);
				col *= matcapCol;

                return col;
            }
            ENDCG
        }
    }
}
