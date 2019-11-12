//
//  RedAlert.metal
//  GPUImage_iOS
//
//  Created by 王亮 on 2019/11/12.
//  Copyright © 2019 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

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
    float iTime;
} ThresholdUniform;

fragment half4 redAlertFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                            texture2d<half> inputTexture [[texture(0)]],
                            constant ThresholdUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    color.g *= abs(sin(uniform.iTime));
    color.b *= abs(sin(uniform.iTime));
    
    return color;
}
