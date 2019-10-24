// GIGATRON FRANCE ... some digit code based from Vox shader :Follow the white rabbit 
// so thx to him ; and Amiga Rulez !!
// https://www.shadertoy.com/view/XtyGWm

precision highp float;
uniform float u_time;
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

#define PI 3.14159265359
#define GR 1.21803398875
#define MAX_DIM (max(textureCoordinate.x, textureCoordinate.y))

#define MATRIX_W (MAX_DIM/8.0)
#define MATRIX_H (MAX_DIM/20.0)

float sampleDigit(const in float fDigit, const in vec2 vUV)
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
    
    vec2 vPixel = floor(vUV * vec2(4.0, 5.0));
    float fIndex = vPixel.x + (vPixel.y * 4.);
    
    return mod(floor(fDigitBinary / pow(2.0, fIndex)), 2.0);
}



void main()
{
    vec2 uv = textureCoordinate.xy;
    float w=texture2D(inputImageTexture,uv).r*4.5; // get first value !
    vec3 tx=texture2D(inputImageTexture,uv).rgb*2.5;
    float tt= u_time*1.2;
    
    vec2 my = fract(uv*vec2(MATRIX_W,MATRIX_H));
    vec2 bh = floor(uv*vec2(MATRIX_W,MATRIX_H));
    float ss=0.0;
    
    // permutation is based on wave sample w index !
    (tx.r<0.2) ?  ss=clamp(w,0.0,0.0) :  ss=clamp(w,0.0,1.0) ;
    
    float number = (mod(ss*tt*PI*cos(bh.x+bh.y*MATRIX_W), ss));
    float digit = sampleDigit(number, GR*my);
    
    vec3 col = vec3(1);
    col *= mix(vec3(0.),vec3(tx),digit);// or tx ;

    gl_FragColor = vec4(vec3(col), 1.0);
}
