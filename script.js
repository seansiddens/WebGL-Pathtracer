function loadShaderSource(fileName) {
    var shaderSource;
    // Load shader code from source files
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", fileName, false);
    xhttp.onreadystatechange = function () {
        if (xhttp.readyState===4 && xhttp.status===200) {
            shaderSource = xhttp.responseText;
        }
    }
    xhttp.send();

    return shaderSource;
}

function createShader(gl, type, source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success) {
        return shader;
    }

    console.log(gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
}

function createProgram(gl, vertexShader, fragmentShader) {
    var program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    var success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success) {
        return program;
    }

    console.log(gl.getProgramInfoLog(program));
    gl.deleteProgram(program);
}

function main() {
    // Set width and height of html canvas
    var aspectRatio = 4 / 3;
    var height = 500;
    var width = height * aspectRatio;

    // Set width and height of canvas
    var canvas = document.getElementById("canvas");
    canvas.width = width;
    canvas.height = height;

    // Get a WebGL context from canvas
    var gl = canvas.getContext("webgl2");
    if (!gl) {
        console.log("No webgl!");
    }

    // Get shader source code from file
    var vertexShaderSource = loadShaderSource("vert.glsl");
    var fragmentShaderSource = loadShaderSource("frag.glsl");

    // Compile shaders from source
    var vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    var fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    // Create the shader program from compiled shaders
    var program = createProgram(gl, vertexShader, fragmentShader);

    // Look up where the vertex data needs to go
    var positionAttributeLocation = gl.getAttribLocation(program, "a_position");

    // Look up uniform locations
    var resolutionUniformLocation = gl.getUniformLocation(program, "u_resolution");

    // Create a buffer to store vertex positions in
    var positionBuffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Positions defined in pixel space
    var positions = [
        0, 0, 
        gl.canvas.width, 0, 
        0, gl.canvas.height, 
        0, gl.canvas.height,
        gl.canvas.width, 0, 
        gl.canvas.width, gl.canvas.height
    ];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

    // Create a vertex array object (attribute state)
    var vao = gl.createVertexArray(); 
    gl.bindVertexArray(vao); // Make it the current one we're working with
    gl.enableVertexAttribArray(positionAttributeLocation); // Turn it on
    // Tell the attribute how to get data out of positionBuffer
    var size = 2;
    var type = gl.FLOAT;
    var normalize = false;
    var stride = 0;
    var offset = 0;
    gl.vertexAttribPointer(positionAttributeLocation, size, type, normalize, stride, offset);

    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    // Clear the canvas
    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    // Tell it to use our shaders
    gl.useProgram(program);

    // Bind the attribute/buffer set we want
    gl.bindVertexArray(vao);

    // Pass uniforms to shader
    gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);

    var primitiveType = gl.TRIANGLES;
    var offset = 0;
    var count = 6;
    gl.drawArrays(primitiveType, offset, count);

}

main();
