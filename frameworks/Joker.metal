//
//  Joker.metal
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

fragment half4 jokerFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    float2 uv = fragmentInput.textureCoordinate;
    if (uv.x < 0.65){
        int diameter = 12;
        float radius = float(diameter)/2.;
        float2 pixel = float2(1.0 / 1280.,1./720.); //pixel size on video
        // Sample the neighbor pixels
        half4 sum = half4(0);
        for (int y = -diameter/2;y < diameter/2+1;++y) {
            for (int x = -diameter/2; x < diameter/2+1;++x) {
                //if sample is within radius
                if ( float(x*x+y*y) < radius*radius)
                    sum += inputTexture.sample(quadSampler, uv + float2(float(x-diameter/2)*pixel.x, float(y-diameter/2)*pixel.y));
            }
        }

        sum /= 3.1459*radius*radius;

        return half4(sum);
    } else {
        return half4(color);
    }
}
