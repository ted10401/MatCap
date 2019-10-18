Shader "Matcap/MatcapOnly"
{
    Properties
    {
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv_matcap : TEXCOORD0;
            };

			sampler2D _Matcap;
			float _MatcapPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				float3 viewNormal = mul(UNITY_MATRIX_IT_MV, v.normal);
				//viewNormal = viewNormal * 0.5 + 0.5;
				o.uv_matcap = viewNormal.xy;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 matcapCol = tex2D(_Matcap, i.uv_matcap * 0.5 + 0.5);
				matcapCol *= _MatcapPower;

                return matcapCol;
            }
            ENDCG
        }
    }
}
