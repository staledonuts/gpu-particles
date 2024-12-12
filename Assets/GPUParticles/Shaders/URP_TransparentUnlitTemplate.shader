// Example Shader for Universal RP
// Written by @Cyanilux
// https://www.cyanilux.com/tutorials/urp-shader-code

Shader "GPUParticles/Unlit - Transparent" 
{
	Properties 
	{
		_MainTex ("Example Texture", 2D) = "white" {}
		_Color ("Example Colour", Color) = (0, 0.66, 0.73, 0.5)
		_SizeMul("Size Multiplier", Float) = 1
	}
	SubShader 
	{
		Tags 
		{
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Transparent"
			"Queue"="Transparent"
		}

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "./ParticleStruct.hlsl"
		CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _Color;
			float _SizeMul;
		CBUFFER_END
		ENDHLSL

		Pass 
		{
			Name "Unlit"
			//Tags { "LightMode"="SRPDefaultUnlit" } // (is default anyway)

			Blend SrcAlpha OneMinusSrcAlpha
			Blend One One

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct fragdata 
			{
				float4 positionCS 	: SV_POSITION;
				float2 uv		    : TEXCOORD0;
				float4 color		: COLOR;
			};

			// Textures, Samplers & Global Properties
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			// Vertex Shader
			fragdata vert(uint id : SV_VertexID, uint inst : SV_InstanceID) 
			{
				fragdata OUT;

				float3 q = quad[id];
				OUT.positionCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, float4(particles[inst].position, 1.0f)) + float4(q, 0.0f) * _SizeMul * particles[inst].size);
				OUT.uv = q + 0.5f;
				OUT.color = particles[inst].alive * particles[inst].color;
				return OUT;
			}

			// Fragment Shader
			half4 frag(fragdata IN) : SV_Target 
			{
				half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
				clip(col.a - 0.001);
				return col * _Color * IN.color;
			}
			ENDHLSL
		}
	}
}