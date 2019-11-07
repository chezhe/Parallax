
precision mediump float;
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

void main()
{
    vec2 uv = textureCoordinate - 0.5;
    uv *= 0.7 - mod(uv.x+uv.y,uv.x*0.5)*1.5;
    gl_FragColor = texture2D(inputImageTexture,uv+0.5);
}
