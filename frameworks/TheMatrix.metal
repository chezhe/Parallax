//
//  TheMatrix.metal
//  GPUImage_iOS
//
//  Created by 王亮 on 2019/11/12.
//  Copyright © 2019 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#define PI 3.14159265359
#define GR 1.21803398875

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

struct TwoInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};

typedef struct
{
    float threshold;
} ThresholdUniform;

float ifmod(float x, float y)
{
    return x - y * floor(x / y);
};

float sampleDigit(float fDigit, float2 vUV)
{
    if(vUV.x < 0.0) return 0.0;
    if(vUV.y < 0.0) return 0.0;
    if(vUV.x >= 1.0) return 0.0;
    if(vUV.y >= 1.0) return 0.0;

    // In this version, each digit is made up of a 4x5 array of bits

    float fDigitBinary = 0.0;

    if(fDigit < 0.5) // 0
    {
        fDigitBinary = 7.0 + 5.0 * 16.0 + 5.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 1.5) // 1
    {
        fDigitBinary = 2.0 + 2.0 * 16.0 + 2.0 * 256.0 + 2.0 * 4096.0 + 2.0 * 65536.0;
    }
    else if(fDigit < 2.5) // 2
    {
        fDigitBinary = 7.0 + 1.0 * 16.0 + 7.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 3.5) // 3
    {
        fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 4.5) // 4
    {
        fDigitBinary = 4.0 + 7.0 * 16.0 + 5.0 * 256.0 + 1.0 * 4096.0 + 1.0 * 65536.0;
    }
    else if(fDigit < 5.5) // 5
    {
        fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 1.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 6.5) // 6
    {
        fDigitBinary = 7.0 + 5.0 * 16.0 + 7.0 * 256.0 + 1.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 7.5) // 7
    {
        fDigitBinary = 4.0 + 4.0 * 16.0 + 4.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 8.5) // 8
    {
        fDigitBinary = 7.0 + 5.0 * 16.0 + 7.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 9.5) // 9
    {
        fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
    }
    else if(fDigit < 10.5) // '.'
    {
        fDigitBinary = 2.0 + 0.0 * 16.0 + 0.0 * 256.0 + 0.0 * 4096.0 + 0.0 * 65536.0;
    }
    else if(fDigit < 11.5) // '-'
    {
        fDigitBinary = 0.0 + 0.0 * 16.0 + 7.0 * 256.0 + 0.0 * 4096.0 + 0.0 * 65536.0;
    }

    float2 vPixel = floor(vUV * float2(4.0, 5.0));
    float fIndex = vPixel.x + (vPixel.y * 4.);

    return ifmod(floor(fDigitBinary / pow(2.0, fIndex)), 2.0);
}

fragment half4 theMatrixFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant ThresholdUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    float2 uv = fragmentInput.textureCoordinate;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    float w = color.r * 4.5; // get first value !
    float3 tx = float3(color.rgb * 2.5);
    float tt = uniform.threshold; //, 1);

    float MATRIX_W = 40.0;
    float MATRIX_H = 100.0;

    float2 my = fract(uv * float2(MATRIX_W, MATRIX_H));
    float2 bh = floor(uv * float2(MATRIX_W, MATRIX_H));
    float ss = 0.0;

    // permutation is based on wave sample w index !
    if (tx.r<0.2) {
        ss = clamp(w,0.0,0.0);
    } else {
        ss = clamp(w,0.0,1.0) ;
    }

    float number = ifmod(ss * tt * PI * cos(bh.x + bh.y * MATRIX_W), ss);
    float digit = sampleDigit(number, GR*my);

    float3 col = float3(1);
    col *= mix(float3(0.),float3(tx), digit);// or tx ;

    return half4(half3(col), 1.0);
}

