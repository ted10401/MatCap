Shader "Demo/Albedo + MatCap"
{
	Properties
	{
        _MainTex ("Main Texture", 2D) = "white" {}
		_MatCapTex ("MatCap Texture", 2D) = "white" {}
        _MatCapPower ("MatCap Power", Float) = 1
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
				fixed2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
			};

			struct v2f
			{
				fixed4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
			sampler2D _MatCapTex;
            fixed _MatCapPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

                fixed3 viewNormal = mul(UNITY_MATRIX_IT_MV, v.normal);
                viewNormal = viewNormal * 0.5 + 0.5;
				o.uv.zw = viewNormal.xy;            

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                fixed4 mainCol = tex2D(_MainTex, i.uv.xy);
				fixed4 matcapCol = tex2D(_MatCapTex, i.uv.zw);

                fixed4 finalCol = mainCol;
                finalCol *= matcapCol * _MatCapPower;

				return finalCol;
			}
			ENDCG
		}
	}
}
