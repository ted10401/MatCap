Shader "Custom/KnightMatCapSpecularReflection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		[Header(Specular)]
		_SpecularTex ("Specular Texture", 2D) = "white" {}
		_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularPower ("Specular Power", Float) = 0.5

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
				fixed3 normalDirection : TEXCOORD2;
				fixed3 viewDirection : TEXCOORD3;
			};

			sampler2D _MainTex;
			fixed4 _MainTex_ST;

			sampler2D _SpecularTex;
			fixed4 _SpecularColor;
			fixed _SpecularPower;

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

                o.normalDirection = worldNormalDir;
				o.viewDirection = _WorldSpaceCameraPos - worldPos;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainCol = tex2D(_MainTex, i.uv.xy);

				fixed4 specCol = tex2D(_SpecularTex, i.uv.xy);
				fixed3 normalDirection = normalize(i.normalDirection);
				fixed3 viewDirection = normalize(i.viewDirection);
                fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				fixed specular = step(0.0, dot(normalDirection, _WorldSpaceLightPos0)) * pow(max(0.0, dot( reflect(-lightDirection, normalDirection), viewDirection)), _SpecularPower);
				fixed3 specularColor = specCol * _SpecularColor * specular;

				fixed4 matcapCol = tex2D(_MatCapTex, i.uv.zw);
				fixed4 reflectionCol = texCUBE(_Cubemap, i.reflectionDir) * _ReflectionColor * _ReflectionPower;

				fixed4 finalCol = mainCol;
				finalCol.rgb += specularColor;
				finalCol += specCol * matcapCol * _MatCapPower;
				finalCol += specCol * reflectionCol;

				return finalCol;
			}
			ENDCG
		}
	}
}
