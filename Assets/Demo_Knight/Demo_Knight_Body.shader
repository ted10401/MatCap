Shader "Demo/Knight/Body"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _SpecularTex ("Specular Texture", 2D) = "white" {}
        _MatCapTex1 ("MatCap Texture 1", 2D) = "white" {}
        _MatCapPower1 ("MatCap Power 1", Float) = 1
        _MatCapTex2 ("MatCap Texture 2", 2D) = "white" {}
        _MatCapPower2 ("MatCap Power 2", Float) = 1
        _MatCapTex3 ("MatCap Texture 3", 2D) = "white" {}
        _MatCapPower3 ("MatCap Power 3", Float) = 1
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
				float2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

            sampler2D _SpecularTex;

            sampler2D _MatCapTex1;
            fixed _MatCapPower1;
            sampler2D _MatCapTex2;
            fixed _MatCapPower2;
            sampler2D _MatCapTex3;
            fixed _MatCapPower3;
			
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
                fixed4 specCol = tex2D(_SpecularTex, i.uv.xy);
                fixed4 matcapCol1 = tex2D(_MatCapTex1, i.uv.zw);
                fixed4 matcapCol2 = tex2D(_MatCapTex2, i.uv.zw);
                fixed4 matcapCol3 = tex2D(_MatCapTex3, i.uv.zw);

                fixed4 finalCol = mainCol + specCol;
                finalCol *= specCol * matcapCol1 * _MatCapPower1;
                finalCol *= specCol * matcapCol2 * _MatCapPower2;
                finalCol += specCol * matcapCol3 * _MatCapPower3;

				return finalCol;
			}
			ENDCG
		}
	}
}
