Shader "Unlit/VatShader"
{
    Properties
    {
        _MainTex ("MainTexture", 2D) = "white" {}
        _AnimVertexTex ("AnimTexture", 2D) = "black" {}
        _TempAnimVertexTex ("TempAnimVertexTex", 2D) = "black" {}
        _Color("Color", Color) = (1,1,1,1)
        _AnimationSpeed("AnimationSpeed", float) = 25
        _Transition("Transition", Range(0,1)) = 0
    
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "UnityCG.cginc"

            struct appdata
            {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                uint vertexId : SV_VertexID;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

           
            
            sampler2D _MainTex;
                            sampler2D _AnimVertexTex;
                            sampler2D _TempAnimVertexTex;
                            float4 _MainTex_ST;
                            float4 _AnimVertexTex_TexelSize;
                            float4 _Color;
                            float _AnimationSpeed;
                            float _Transition;

            

            float mapCurrentVertexToTextureCords(int VertexId, float invTextureWidth)
            {
                float normalizedVertexId = VertexId * invTextureWidth;
                float halfTexelCoord = 0.5 * invTextureWidth;
                return  normalizedVertexId + halfTexelCoord;
            }

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                float vertCoords= mapCurrentVertexToTextureCords(v.vertexId, _AnimVertexTex_TexelSize.x);
                float animCoords = frac(_Time.y *_AnimationSpeed* _AnimVertexTex_TexelSize.y);
                float4 texCoords = float4(vertCoords, animCoords, 0,0);
                float4 animVertexTex = tex2Dlod(_AnimVertexTex, texCoords);
                float4 animTempVertexTex = tex2Dlod(_TempAnimVertexTex, texCoords);
                
                float4 position = (0 == animVertexTex) ? v.vertex:animVertexTex;
                position = (0 == animTempVertexTex) ? position :lerp(animVertexTex,animTempVertexTex,_Transition);

                // if (any(animTempVertexTex))
                // {
                //     position = lerp(animVertexTex,animTempVertexTex,_Transition);
                // }
                
                v2f o;
                o.vertex = UnityObjectToClipPos(position);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                float4 col = tex * _Color;
               
                return col;
            }

            
            ENDCG
        }
    }
}
