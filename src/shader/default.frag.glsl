// Fragment Shader
// EVENT UNIFORMS - Set these from JavaScript (0.0 = off, 1.0 = on)
uniform float uClick;        // Click event
uniform float uDblClick;     // Double click event
uniform float uMouseDown;    // Mouse button down
uniform float uMouseUp;      // Mouse button up
uniform vec2 uMousePos;      // Mouse position (0.0 to 1.0 range)
uniform float uMouseEnter;   // Mouse enters
uniform float uMouseLeave;   // Mouse leaves
uniform float uDragStart;    // Drag starts
uniform float uDrag;         // Dragging
uniform float uDragEnd;      // Drag ends
uniform float uKeyDown;      // Key pressed
uniform float uKeyUp;        // Key released
uniform float uScroll;       // Scroll amount (0.0 to 1.0)

uniform float uTime;
varying vec2 vUv;

void main() {
    vec3 color = vec3(0.1); // Base dark color

    // CLICK - Red flash from center
    if (uClick > 0.0) {
        float dist = distance(vUv, vec2(0.5));
        float flash = smoothstep(0.6, 0.0, dist) * uClick;
        color += vec3(1.0, 0.0, 0.0) * flash;
    }

    // DOUBLE CLICK - Orange expanding ring
    if (uDblClick > 0.0) {
        float dist = distance(vUv, vec2(0.5));
        float ring = abs(sin((dist - uDblClick * 2.0) * 20.0)) * smoothstep(1.0, 0.0, dist);
        color += vec3(1.0, 0.5, 0.0) * ring * uDblClick;
    }

    // MOUSE DOWN - Blue corners light up
    if (uMouseDown > 0.0) {
        float corners = max(abs(vUv.x - 0.5), abs(vUv.y - 0.5));
        float cornerGlow = smoothstep(0.5, 0.3, corners);
        color += vec3(0.0, 0.5, 1.0) * cornerGlow * uMouseDown;
    }

    // MOUSE UP - White center pulse
    if (uMouseUp > 0.0) {
        float dist = distance(vUv, vec2(0.5));
        float pulse = smoothstep(0.3, 0.0, dist) * uMouseUp;
        color += vec3(1.0) * pulse;
    }

    // MOUSE POSITION - Yellow circle follows mouse
    if (length(uMousePos) > 0.0) {
        float mouseDist = distance(vUv, uMousePos);
        float mouseCircle = smoothstep(0.1, 0.0, mouseDist);
        color += vec3(1.0, 1.0, 0.0) * mouseCircle * 0.8;
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

    // DRAG START - Cyan spiral from center
    if (uDragStart > 0.0) {
        vec2 centered = vUv - 0.5;
        float angle = atan(centered.y, centered.x);
        float dist = length(centered);
        float spiral = sin(angle * 3.0 + dist * 10.0) * 0.5 + 0.5;
        color += vec3(0.0, 1.0, 1.0) * spiral * uDragStart * smoothstep(0.5, 0.0, dist);
    }

    // DRAGGING - Magenta trail effect
    if (uDrag > 0.0) {
        float lines = sin(vUv.x * 30.0 + uTime * 5.0) * 0.5 + 0.5;
        color += vec3(1.0, 0.0, 1.0) * lines * uDrag * 0.6;
    }

    // DRAG END - Purple burst
    if (uDragEnd > 0.0) {
        vec2 centered = vUv - 0.5;
        float angle = atan(centered.y, centered.x);
        float dist = length(centered);
        float burst = sin(angle * 8.0 - dist * 5.0 + uDragEnd * 3.0) * 0.5 + 0.5;
        color += vec3(0.5, 0.0, 1.0) * burst * uDragEnd;
    }

    // KEY DOWN - Vertical bars from top
    if (uKeyDown > 0.0) {
        float bars = step(0.5, sin(vUv.x * 15.0));
        float topDown = smoothstep(1.0, 0.0, vUv.y);
        color += vec3(0.0, 1.0, 0.5) * bars * topDown * uKeyDown;
    }

    // KEY UP - Vertical bars from bottom
    if (uKeyUp > 0.0) {
        float bars = step(0.5, sin(vUv.x * 15.0));
        float bottomUp = smoothstep(0.0, 1.0, vUv.y) * smoothstep(1.0, 0.5, vUv.y);
        color += vec3(0.5, 1.0, 0.0) * bars * bottomUp * uKeyUp;
    }

    // SCROLL - Horizontal wave
    if (uScroll > 0.0) {
        float wave = sin(vUv.y * 10.0 + uScroll * 20.0) * 0.5 + 0.5;
        color += vec3(1.0, 0.8, 0.0) * wave * uScroll * 0.7;
    }

    gl_FragColor = vec4(color, 1.0);
}