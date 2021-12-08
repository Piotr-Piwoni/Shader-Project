Shader "Custom/Eye"
{
    Properties
    {
        [Header (Main)]
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [Header (Iris)]
        _Radius ("Iris Radius", Range(0,1)) = 0.4
        _IrisScaleX("Iris Scale X", Range(0,2)) = 1
		_IrisScaleY("Iris Scale Y", Range(0,2)) = 1
		[HDR]
		_IrisColor ("Iris Color", Color) = (0,0,1,0)
		[HDR]
		_IrisColorOut("Iris Out Color", Color) = (0,1,0,0)
		[Header (Pupil)]
		_RadiusPupil ("Pupil Radius", Range(0,1)) = 0.4
        _PupilScaleX("Pupil Scale X", Range(0,2)) = 1
		_PupilScaleY("Pupil Scale Y", Range(0,2)) = 1
		[HDR]
		_PupilColor ("Pupil Color", Color) = (0,1,1,0)
		[HDR]
		_PupilColorOut("Pupil Out Color", Color) = (1,0,1,1)
		[Header(Iris Edge)]
		_EdgeWidth("Iris Edge Width", Range(0,2)) = 0.1
		[HDR]
		_IrisEdgeColor("Iris Edge Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.5

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 objPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color, _PupilColor, _PupilColorOut, _IrisColor, _IrisColorOut, _IrisEdgeColor;
        float _Radius, _RadiusPupil;
        float _IrisScaleX, _PupilScaleX, _EdgeWidth;
        float _IrisScaleY, _PupilScaleY;
        
        void vert(inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.objPos = v.vertex;
            //o.lightDir = WorldSpaceLightDir(v.vertex); // get the worldspace lighting direction
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float dis = distance(0, float3(IN.objPos.x * _IrisScaleX, IN.objPos.y * _IrisScaleY, IN.objPos.z - 0.5));
            float disPup = distance(0, float3(IN.objPos.x * _PupilScaleX, IN.objPos.y * _PupilScaleY, IN.objPos.z - 0.5));
            
            float irisRadius = 1 - saturate(dis / _Radius);
            float pupilRadius = 1 - saturate(disPup / _RadiusPupil);
            float irisEdge = 1 - saturate(dis / _Radius - _EdgeWidth);
            
            float irisCircle = saturate(irisRadius * 20);
            float pupilCircle = saturate(pupilRadius * 20);
            float irisEdgeCircle = saturate(irisEdge * 20);
            
            irisEdgeCircle -= irisCircle;
            irisCircle -= pupilCircle;
            
            float4 pupilLerp = lerp(_PupilColorOut, _PupilColor, pupilRadius);
            float4 pupilColored = pupilCircle * pupilLerp;
            
            float4 irisLerp = lerp(_IrisColorOut, _IrisColor, irisRadius);
            float4 irisColored = irisCircle * irisLerp;
            
            float4 irisEdgeColored = irisEdgeCircle * _IrisEdgeColor;
            
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb + irisCircle + pupilColored + irisColored + irisEdgeColored;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
