Shader "Custom/MatCapShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MatCapTex ("MatCap Texture", 2D) = "white" {}
		_MatCapPower ("MatCap Power", Float) = 2
		_Cubemap("Reflection Cubemap", Cube) = "" {}
		_ReflectionColor ("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectionPower ("Reflection Power", Float) = 0.5
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
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				fixed4 uv : TEXCOORD0;
				fixed4 vertex : SV_POSITION;
				fixed3 reflectionDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			fixed4 _MainTex_ST;

			sampler2D _MatCapTex;
			fixed _MatCapPower;

			samplerCUBE _Cubemap;
			fixed4 _ReflectionColor;
			fixed _ReflectionPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 viewNormalDir = mul(UNITY_MATRIX_IT_MV, v.normal);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = viewNormalDir.xy * 0.5 + 0.5;

				fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormalDir = mul(unity_ObjectToWorld, v.normal);
                o.reflectionDir = reflect(-UnityWorldSpaceViewDir(worldPos), worldNormalDir);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainCol = tex2D(_MainTex, i.uv.xy);
				fixed4 matcapCol = tex2D(_MatCapTex, i.uv.zw);
				fixed4 reflectionCol = texCUBE(_Cubemap, i.reflectionDir) * _ReflectionColor * _ReflectionPower;

				fixed4 finalCol = mainCol + reflectionCol;
				finalCol *= matcapCol * _MatCapPower;

				return finalCol;
			}
			ENDCG
		}
	}
}
