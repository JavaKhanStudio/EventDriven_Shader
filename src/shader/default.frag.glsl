uniform float uClick;        // Click event
uniform float uDblClick;     // Double click event
uniform float uMouseDown;    // Mouse button down
uniform float uMouseUp;      // Mouse button up
uniform vec2 uMousePos;      // Mouse position (0.0 to 1.0 range)
uniform float uMouseEnter;   // Mouse enters
uniform float uMouseLeave;   // Mouse leaves
uniform float uKeyDown;      // Key pressed
uniform float uKeyUp;        // Key released
uniform float uScroll;       // Scroll amount (0.0 to 1.0)

uniform float uTime;
uniform vec2 uMouse;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    vec3 color = vec3(0.1); // Base dark color

    // Compute aspect-corrected coordinates
    vec2 aspect = vec2(uResolution.x / uResolution.y, 1.0);

    // Apply aspect correction before distance calculation
    vec2 uv = (vUv - uMouse) * aspect;
    float mouseDist = length(uv);

    // Create smooth circular glow
    float mouseGlow = smoothstep(0.06, 0.001, mouseDist);

    color += vec3(0.6, 0.2, 0.8) * mouseGlow * 0.9;

    // MOUSE CLICK - Red ring (border only)
    if (uClick > 0.0) {
        vec2 aspect = vec2(uResolution.x / uResolution.y, 1.0);
        vec2 uv = (vUv - uMouse) * aspect;

        float mouseDist = length(uv);

        // Define inner and outer radius for the ring
        float outer = 0.15;
        float inner = 0.13;

        // Create a thin ring using difference of smoothsteps
        float ring = smoothstep(outer, outer - 0.005, mouseDist)
        - smoothstep(inner, inner - 0.005, mouseDist);

        // Add red glow depending on click intensity
        color += vec3(1.0, 0.0, 0.0) * ring * uClick;
    }


    // DOUBLE CLICK - Orange expanding ring
    if (uDblClick > 0.0) {
        float ring = abs(sin((mouseDist - uDblClick * 2.0) * 200.0)) * smoothstep(0.1, 0.0, mouseDist);
        color += vec3(1.0, 0.5, 0.0) * ring * uDblClick;
    }

    // MOUSE DOWN - Blue corners light up
    if (uMouseDown > 0.0) {
        float cornerGlow = smoothstep(0.1, 0.0, mouseDist);
        color += vec3(0.0, 0.1, 1.0) * cornerGlow * uMouseDown;
    }

    // MOUSE UP - Star-shaped white pulse
    if (uMouseUp > 0.0) {
        vec2 aspect = vec2(uResolution.x / uResolution.y, 1.0);
        vec2 uv = (vUv - uMouse) * aspect;

        // Polar coordinates
        float r = length(uv);
        float a = atan(uv.y, uv.x);

        // Create star pattern using cosine modulation
        // The 5.0 defines how many points your star has
        float starShape = abs(cos(a * 5.0)) * 0.3 + 0.7;

        // The inner part glows stronger, outer part fades
        float starMask = smoothstep(starShape * 0.1, 0.0, r);

        // Animate pulse if desired (e.g. based on uMouseUp)
        color += vec3(1.0) * starMask * uMouseUp;
    }

    // MOUSE ENTER - Green fade from edges
    if (uMouseEnter > 0.0) {
        float edgeDist = min(min(vUv.x, 1.0 - vUv.x), min(vUv.y, 1.0 - vUv.y));
        float edgeGlow = smoothstep(0.3, 0.0, edgeDist);
        color += vec3(0.0, 1.0, 0.3) * edgeGlow * uMouseEnter;
    }

    // MOUSE LEAVE - Red edges
    if (uMouseLeave > 0.0) {
        float edgeDist = min(min(vUv.x, 1.0 - vUv.x), min(vUv.y, 1.0 - vUv.y));
        float edgeGlow = smoothstep(0.2, 0.0, edgeDist);
        color += vec3(1.0, 0.0, 0.0) * edgeGlow * uMouseLeave * 0.5;
    }

    // KEY DOWN - Vertical bars from top
    if (uKeyDown > 0.0) {
        float bars = step(0.5, sin(vUv.x * 10.0) + 20.);
        float topDown = smoothstep(1.0, 0.0, vUv.y);
        color += vec3(0.0, 1.0, 0.5) * bars * topDown * uKeyDown;
    }

    // KEY UP - Vertical bars from bottom
    if (uKeyUp > 0.0) {
        float bars = step(0.2, sin(vUv.x * 100.0));
        float bottomUp = smoothstep(0.0, 1.0, vUv.y) * smoothstep(0.3, 0.5, vUv.y);
        color += vec3(1.5, 0.3, 0.3) * bars * bottomUp * uKeyUp;
    }

    // SCROLL - Horizontal wave
    if (uScroll > 0.0) {
        float wave = sin(vUv.y * 10.0 + uScroll * 20.0) * 0.5 + 0.5;
        color += vec3(1.0, 0.8, 0.0) * wave * uScroll * 0.7;
    }

    gl_FragColor = vec4(color, 1.0);
}