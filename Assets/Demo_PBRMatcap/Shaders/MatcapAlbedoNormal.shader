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
				float3 TtoV[3] : TEXCOORD2;
				float3 viewDir : TEXCOORD5;
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
				o.viewDir = UnityObjectToViewPos(v.vertex);

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				o.TtoV[0] = fixed3(worldTangent.x, worldBinormal.x, worldNormal.x);
				o.TtoV[1] = fixed3(worldTangent.y, worldBinormal.y, worldNormal.y);
				o.TtoV[2] = fixed3(worldTangent.z, worldBinormal.z, worldNormal.z);

                return o;
            }

			float2 getMatcapUV(float3 viewNormal, float3 viewDir)
			{
				float3 viewCross = cross(viewDir, viewNormal);
				viewNormal = float3(-viewCross.y, viewCross.x, 0.0);
				viewNormal = viewNormal * 0.5 + 0.5;
				return viewNormal.xy;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float3 normal = UnpackNormal(tex2D(_BumpMap, i.uv_normal));
				normal.xy *= _BumpValue;
				normal.z = sqrt(1.0- saturate(dot(normal.xy, normal.xy)));
				normal = normalize(normal);

				float3 worldNormal;
				worldNormal.x = dot(i.TtoV[0], normal);
				worldNormal.y = dot(i.TtoV[1], normal);
				worldNormal.z = dot(i.TtoV[2], normal);
				float3 viewNormal =  mul((float3x3)UNITY_MATRIX_V, worldNormal);
				viewNormal = normalize(viewNormal);

				float2 uv_matcap = getMatcapUV(viewNormal, normalize(i.viewDir));
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
