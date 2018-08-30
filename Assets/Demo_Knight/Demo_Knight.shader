Shader "Demo/Knight"
{
	Properties
	{
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormaMap ("Normal Map", 2D) = "bump" {}
        _NormalPower ("Normal Power", Float) = 1
        _SpecularTex ("Specular Texture", 2D) = "white" {}
        _DiffuseMatCapTex ("Diffuse MatCap Texture", 2D) = "white" {}
        _DiffuseMatCapPower ("Diffuse MatCap Power", Float) = 1
        _SpecularMatCapTex ("Specular MatCap Texture", 2D) = "white" {}
        _SpecularMatCapPower ("Specular MatCap Power", Float) = 1
        _RimMatCapTex ("Rim MatCap Texture", 2D) = "white" {}
        _RimMatCapPower ("Rim MatCap Power", Float) = 1
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
                fixed4 tangent : TANGENT;
			};

			struct v2f
			{
				fixed4 uv : TEXCOORD0;
				fixed4 vertex : SV_POSITION;
                fixed3 lightDir : TEXCOORD1;
                fixed3 viewDir : TEXCOORD2;
			};

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
   
            sampler2D _NormaMap;
            fixed _NormalPower;

            sampler2D _SpecularTex;

            sampler2D _DiffuseMatCapTex;
            fixed _DiffuseMatCapPower;
            sampler2D _SpecularMatCapTex;
            fixed _SpecularMatCapPower;
            sampler2D _RimMatCapTex;
            fixed _RimMatCapPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

                fixed3 viewNormal = mul(UNITY_MATRIX_IT_MV, v.normal);
                viewNormal = viewNormal * 0.5 + 0.5;
                o.uv.zw = viewNormal.xy;

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                fixed3 normalBias = UnpackNormal(tex2D(_NormaMap, i.uv.xy));

                fixed4 mainCol = tex2D(_MainTex, i.uv.xy);
                fixed4 specCol = tex2D(_SpecularTex, i.uv.xy);
                fixed4 diffuseMatCapCol = tex2D(_DiffuseMatCapTex, i.uv.zw + normalBias * _NormalPower);
                fixed4 specularMatCapCol = tex2D(_SpecularMatCapTex, i.uv.zw + normalBias * _NormalPower);
                fixed4 rimMatCapCol = tex2D(_RimMatCapTex, i.uv.zw);

                fixed4 finalCol = mainCol;
                finalCol += diffuseMatCapCol * _DiffuseMatCapPower;
                finalCol += specCol * specularMatCapCol * _SpecularMatCapPower;
                finalCol += rimMatCapCol * _RimMatCapPower;
                return finalCol;
			}
			ENDCG
		}
	}
}
