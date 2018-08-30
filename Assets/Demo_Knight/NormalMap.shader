Shader "Demo/NormalMap"
{
	Properties
	{
        _Bump ("Bump", 2D) = "bump" {}
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
                fixed4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
                fixed3 lightDir : TEXCOORD1;
                fixed3 viewDir : TEXCOORD2;
			};
   
            sampler2D _Bump;
            sampler2D _MatCapTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv;

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
                fixed3 norm = UnpackNormal(tex2D(_Bump, i.uv.xy));
                norm = norm * 0.5 + 0.5;

                fixed4 matcapCol = tex2D(_MatCapTex, i.uv.zw + norm);
                return matcapCol;
			}
			ENDCG
		}
	}
}
