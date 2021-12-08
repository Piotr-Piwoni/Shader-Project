Shader "Unlit/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimColor ("Rim Color", Color) = (0,.5,0,0)
    	_TintColor("Tint Color", Color) = (0,0.5,1,1)
	    _GlitchTime("Glitches Over Time", Range(0.01,3.0)) = 1.0
    	_WorldScale("Line Amount", Range(1,200)) = 20

    }
	
	Category
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Sphere" }
		Blend SrcAlpha OneMinusSrcAlpha 
		ColorMask RGB
		Cull Back 
    SubShader
    {
		Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
			fixed4 _TintColor;
			fixed4 _RimColor;

            struct appdata_t
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
            	float2 texcoord : TEXCOORD0;
				float3 wpos : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
            };
            
            float4 _MainTex_ST;
            float _GlitchTime;
            float _OptTime = 0;
            float _WorldScale;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

            	_OptTime = _OptTime == 0 ? sin(_Time.w * _GlitchTime) : _OptTime;
            	float glitchTime = step(0.99, _OptTime);
            	float glitchPos = v.vertex.y + _SinTime.y;
				float glitchPosClamped = step(0, glitchPos) * step(glitchPos, 0.2);
            	o.vertex.xz += glitchPosClamped * 0.1 * glitchTime * _SinTime.y;
            	
            	o.color = v.color;
            	o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
            	
            	o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
            	o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
            	
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            	float4 text = tex2D(_MainTex, i.texcoord) * _TintColor;
            	
            	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);
            	half rim = 1 - saturate(dot(viewDirection, i.normalDir));
            	
            	float fraclines = frac((i.wpos.y * _WorldScale) + _Time.y);
				float scanlines = step(fraclines, 0.5);

				float bigfracline = frac((i.wpos.y ) - _Time.x * 4);
            	
                fixed4 col = text + (bigfracline * 0.4 * _TintColor) + (rim * _RimColor);
            	col.a = 0.8 * (scanlines + rim + bigfracline);
            	
                return col;
            }
            ENDCG
        }
    }
	}

}
