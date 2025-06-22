#ifndef GRASS_ANIMATION_INCLUDED
#define GRASS_ANIMATION_INCLUDED

float3 AnimateVertex(float3 positionOS, float3 worldPos)            
{
    float3 posOS = positionOS.xyz;

    // --------------------------------------------
    // [1] WideGrass 보정 (X,Z 중심점 계산)
    float3 wideGrassOffset = float3(posOS.x, 0, posOS.z);

    // WideGrass ON/OFF
    float3 wideGrass = (_WideGrass > 0.5) ? wideGrassOffset : float3(0, 0, 0);
    float3 basePivot = posOS - wideGrass;

    // --------------------------------------------
    // [2] Noise UV 계산
    float3 scaledWorldPos = worldPos * ((_MotionScale + 0.2) * 0.0075);

    float t = (_Time.y * _MotionSpeed + _MotionVariation) * 0.03;

    float4 motionParams = float4(0,0,0,0);
    float2 motionDirection = motionParams.xy * 2.0 - 1.0;

    float2 tFrac = -motionDirection * frac(t);
        
    float2 noiseUV = scaledWorldPos.xz + tFrac;

    // --------------------------------------------
    // [3] Noise 샘플 및 회전 벡터 생성
    float4 noiseSample = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_linear_repeat, noiseUV, 0);
    float2 noiseDir = noiseSample.rg * 2.0 - 1.0;

    // Matrix 역변환 및 축 계산
    float3 objectScale = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                         length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                         length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)));

    float4 noiseMatrix = mul(UNITY_MATRIX_I_M, float4(noiseDir.x, 0, noiseDir.y, 0));
    float3 noiseDirection = noiseMatrix.xyz * objectScale;

    // --------------------------------------------
    // [4] 바람 방향 보간
    float4 windMatrix = mul(UNITY_MATRIX_I_M, float4(motionDirection.x, 0, motionDirection.y, 0));
    float3 windDirection = windMatrix.xyz * objectScale;

    float windPower = 0.75;
    float powWind = pow(1.0 - windPower, 3.0);
    float strength = 1.0 - powWind;
    float blend = strength * 0.5;

    float2 windDir = lerp(noiseDirection.xz, windDirection.xz, blend);

    // --------------------------------------------
    // [5] 높이 기반 bending 보정
    float yHeight = posOS.y;
    float bendFactor = yHeight * 2.0 * _MotionBending;
    float power = bendFactor * windPower * windPower;

    float2 WindOffset = windDir * power;
    float3 finalWindOffset = float3(WindOffset.x, 0, WindOffset.y);


    // --------------------------------------------
    // [6] 회전 보간 처리
    float3 basePivotx00 = float3(basePivot.x, 0, 0);
    float3 basePivot0yz = float3(0, basePivot.y, basePivot.z);

    float cos1 = cos(finalWindOffset.z);
    float sin1 = sin(finalWindOffset.z);

    float3 rotate1 = basePivot0yz * cos1;
    float3 rotate2 = cross(float3(1, 0, 0), basePivot0yz) * sin1;
    float3 rotResult = rotate1 + rotate2;

    float3 final1 = basePivotx00 + rotResult;
    float3 flnal1x00 = float3(final1.x, 0, 0);
    float3 flnal10yz = float3(0, final1.y, final1.z);

    float cos2 = cos(-finalWindOffset.x);
    float sin2 = sin(-finalWindOffset.x);

    float3 rotate3 = flnal10yz * cos2;
    float3 rotate4 = cross(float3(0, 0, 1), flnal10yz) * sin2;
    float3 rotResult2 = rotate3 + rotate4;

    float3 windMotion = flnal1x00 + rotResult2;

    // --------------------------------------------
    // [7] Wind ON/OFF 브랜치
    float3 WindOnOff = (_WindOnOff > 0.5) ? windMotion : basePivot;
    float3 windFinal = wideGrass + WindOnOff;

    // --------------------------------------------
    // [8] FadeOut 처리
    if (_FadeOutOnOff > 0.5)
    {
        float dist = distance(GetCameraPositionWS(), worldPos);
        float fade = saturate((dist - _FadeEnd) / (_FadeStart - _FadeEnd + 0.0001));
        windFinal *= fade;
    }
    return windFinal;
}

#endif 