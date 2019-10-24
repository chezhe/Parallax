// https://www.shadertoy.com/view/3sBXDh

precision mediump float;
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

void main() {
    vec2 uv = textureCoordinate;
    if (uv.x < 0.65){
        int diameter = 12;
        float radius = float(diameter)/2.;
        vec2 pixel = vec2(1.0 / 1280.,1./720.); //pixel size on video
        // Sample the neighbor pixels
        vec3 sum = vec3(0);
        for (int y = -diameter/2;y < diameter/2+1;++y) {
            for (int x = -diameter/2; x < diameter/2+1;++x) {
                //if sample is within radius
                if ( float(x*x+y*y) < radius*radius)
                    sum += texture2D(inputImageTexture, uv + vec2(float(x-diameter/2)*pixel.x,float(y-diameter/2)*pixel.y) ).rgb;
            }
        }

        sum /= 3.1459*radius*radius;



        gl_FragColor = vec4(sum,1);
    } else {
        gl_FragColor = texture2D(inputImageTexture,uv);
    }
}
