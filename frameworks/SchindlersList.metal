//
//  SchindlersList.metal
//  GPUImage_iOS
//
//  Created by 王亮 on 2019/11/12.
//  Copyright © 2019 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
//#include "OperationShaderTypes.h"
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

fragment half4 schindlersListFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    float gray;
    gray = color.r*0.3 + color.g*0.59 + color.b*0.11;
    
    if (color.r > (color.g + color.b) || (color.g * 2 < color.r && color.b * 2 < color.r)) {
        
    } else {
        color.r = gray;
    }
    color.g = gray;
    color.b = gray;
    
    return half4(color);
}
