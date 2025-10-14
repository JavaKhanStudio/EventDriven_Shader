<!-- ShaderBackground.vue -->
<template>
  <div
      ref="root"
      class="shader-bg"
      :class="{ ready: isReady }"
      :style="{
      zIndex: String(zIndex),
      '--fade-dur': fadeDuration + 'ms',
      '--fade-delay': fadeDelay + 'ms',
      background: placeholderImage
        ? `center / cover no-repeat url(${placeholderImage})`
        : placeholderColor
    }"
      aria-hidden="true"
  >
    <canvas ref="canvas" class="shader-canvas"/>
    <slot/>
  </div>
</template>

<script setup>
import {onMounted, onBeforeUnmount, ref, watch, nextTick} from 'vue'
import * as THREE from 'three'
import defaultVert from '@/shader/default.vert.glsl'
import defaultFrag from '@/shader/default.frag.glsl'


const props = defineProps({
  fragment: {type: String, default: ''},
  vertex: {type: String, default: ''},
  uniforms: {type: Object, default: () => ({})},
  autoplay: {type: Boolean, default: true},
  interactive: {type: Boolean, default: false},
  dpr: {type: [Number, String], default: 'auto'},
  powerPreference: {type: String, default: 'high-performance'},
  alpha: {type: Boolean, default: true},
  antialias: {type: Boolean, default: true},
  preserveDrawingBuffer: {type: Boolean, default: false},
  zIndex: {type: [Number, String], default: -1},

  // NEW: placeholder & fade controls
  placeholderColor: {type: String, default: '#0b0f19'},
  placeholderImage: {type: String, default: ''}, // e.g. imported URL or /assets/bg.jpg
  fadeDuration: {type: Number, default: 600},
  fadeDelay: {type: Number, default: 0},
})

const emit = defineEmits(['ready'])
const root = ref(null)
const canvas = ref(null)
const isReady = ref(false)

let renderer, scene, camera, mesh
let material
let rafId = null
let start = 0
let stopped = !props.autoplay
let disposed = false

function getDPR() {
  if (props.dpr === 'auto') return Math.min(window.devicePixelRatio || 1, 2)
  const n = Number(props.dpr)
  return isFinite(n) && n > 0 ? Math.min(n, 3) : 1
}

async function init() {
  const el = root.value
  const cv = canvas.value

  if (!el || !cv) {
    console.error("Can't find canvas element")
    return
  }

  console.log("Initializing canvas element") ;

  renderer = new THREE.WebGLRenderer({
    canvas: cv,
    powerPreference: props.powerPreference,
    alpha: props.alpha,
    antialias: props.antialias,
    preserveDrawingBuffer: props.preserveDrawingBuffer,
  })
  renderer.setPixelRatio(getDPR())
  renderer.setSize(el.clientWidth, el.clientHeight, false)
  renderer.setClearAlpha(0)

  scene = new THREE.Scene()
  camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1)

  const vert = defaultVert
  const frag = defaultFrag

  const geo = new THREE.PlaneGeometry(2, 2)
  const uniforms = THREE.UniformsUtils.merge([
    {
      u_time: {value: 0},
      u_resolution: {value: new THREE.Vector2(el.clientWidth, el.clientHeight)},
      u_mouse: {value: new THREE.Vector2(0, 0)},
    },
    props.uniforms,
  ])

  material = new THREE.ShaderMaterial({
    vertexShader: vert,
    fragmentShader: frag,
    uniforms,
    depthTest: false,
    depthWrite: false,
  })

  console.log(material) ;

  mesh = new THREE.Mesh(geo, material)
  scene.add(mesh)

  window.addEventListener('resize', onResize, {passive: true})
  document.addEventListener('visibilitychange', onVisibility, false)
  cv.addEventListener('webglcontextlost', onContextLost, false)
  cv.addEventListener('webglcontextrestored', onContextRestored, false)

  // render a first frame ASAP, then flip the ready flag to fade in
  start = performance.now()
  if (!stopped) {
    material.uniforms.u_time.value = 0.0001
    renderer.render(scene, camera)
    await nextTick()
    requestAnimationFrame(() => {
      isReady.value = true;
      emit('ready', { material, setUniform })
      animate()
    })
  }
}

function animate() {
  if (stopped || disposed || !material) return
  rafId = requestAnimationFrame(animate)
  const t = (performance.now() - start) / 1000
  material.uniforms.u_time.value = t
  renderer.render(scene, camera)
}

function onResize() {
  if (!renderer || !root.value) return
  const w = root.value.clientWidth
  const h = root.value.clientHeight
  renderer.setPixelRatio(getDPR())
  renderer.setSize(w, h, false)
  material?.uniforms?.u_resolution?.value.set(w, h)
}

function onVisibility() {
  if (document.hidden) pause(); else if (props.autoplay) resume()
}



function onContextLost(e) {
  e.preventDefault();
  pause()
}

function onContextRestored() {
  disposeGL(false);
  requestAnimationFrame(() => init())
}

function pause() {
  stopped = true
  if (rafId) {
    cancelAnimationFrame(rafId);
    rafId = null
  }
}

function resume() {
  if (!renderer || disposed || !stopped) return
  stopped = false
  start = performance.now()
  animate()
}

function disposeGL(removeListeners = true) {
  if (removeListeners) {
    window.removeEventListener('resize', onResize)
    document.removeEventListener('visibilitychange', onVisibility)
    canvas.value?.removeEventListener?.('webglcontextlost', onContextLost)
    canvas.value?.removeEventListener?.('webglcontextrestored', onContextRestored)
  }
  if (mesh) {
    mesh.geometry?.dispose?.()
    if (mesh.material?.uniforms) {
      Object.values(mesh.material.uniforms).forEach(u => {
        if (u?.value?.isTexture) u.value.dispose()
      })
    }
    mesh.material?.dispose?.()
    scene?.remove(mesh)
    mesh = null
  }
  renderer?.dispose?.()
  renderer = scene = camera = material = null
}

onMounted(() => {
  init();
  if (!props.autoplay) pause()
})
onBeforeUnmount(() => {
  disposed = true;
  pause();
  disposeGL(true)
})
watch(() => props.autoplay, (v) => v ? resume() : pause())

// 👇 Watch for changes in props.uniforms and update GPU uniforms
watch(
    () => props.uniforms,
    (newUniforms) => {
      if (!material || !material.uniforms) return

      console.log('🎨 Updating shader uniforms:', newUniforms)

      for (const [key, val] of Object.entries(newUniforms)) {
        if (!material.uniforms[key]) continue

        if (val?.value?.isVector3) {
          material.uniforms[key].value.copy(val.value)
        } else {
          material.uniforms[key].value = val.value
        }
      }
    },
    {deep: true}
)


// expose controls
function setUniform(name, value) {
  if (!material?.uniforms?.[name]) return
  const u = material.uniforms[name]
  if (u.value?.set && value?.x !== undefined) u.value.set(value.x, value.y ?? u.value.y, value.z ?? u.value.z)
  else u.value = value
}

function getMaterial() {
  return material;
}

defineExpose({
  root,
  getMaterial,
  setUniform
})

</script>

<style scoped>
.shader-bg {
  position: fixed;
  inset: 0;
  /* placeholder shows immediately (solid or image) */
  background: var(--placeholder, transparent);
  background: inherit; /* keep computed background from inline style */
  pointer-events: none;
  contain: strict;
}

/* canvas is hidden until first frame is ready */
.shader-canvas {
  width: 100%;
  height: 100%;
  display: block;
  opacity: 0;
  transition: opacity var(--fade-dur, 600ms) ease var(--fade-delay, 0ms);
}

/* when ready, fade in */
.ready .shader-canvas {
  opacity: 1;
}

/* accessibility: reduce motion -> no fade */
@media (prefers-reduced-motion: reduce) {
  .shader-canvas {
    transition: none;
  }
}
</style>
