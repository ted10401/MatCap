Shader "Demo/MatCapRobot"
{
	Properties
	{
		_MatCapTex ("MatCap Texture", 2D) = "white" {}
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MatCapTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

                fixed3 viewNormal = mul(UNITY_MATRIX_IT_MV, v.normal);
                viewNormal = viewNormal * 0.5 + 0.5;
				o.uv = viewNormal.xy;            

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MatCapTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
