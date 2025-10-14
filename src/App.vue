<template>
  <ShaderBackground
      :autoplay="true"
      :interactive="true"
      :dpr="'auto'"
      :zIndex="-1"
      ref="bg"
      @ready="onShaderReady"
  />

  <div id="theCube">I am a Cube</div>

</template>

<script setup>
import { ref, onUnmounted } from 'vue'
import ShaderBackground from './components/ShaderBackground.vue'

const bg = ref(null)
const timeout = 500 ;

function onPointerMove(e) {
  if (!bg.value.getMaterial()) return

  const rect = bg.value.root.getBoundingClientRect()
  const x = (e.clientX - rect.left) / rect.width
  const y = 1.0 - (e.clientY - rect.top) / rect.height

  bg.value.getMaterial().uniforms.uMouse.value.set(x, y)
}

function onShaderReady() {
  console.log('Shader is ready!', bg.value.getMaterial())
  const mat = bg.value.getMaterial()
  const uniforms = mat.uniforms
  let theCube = document.getElementById("theCube")

  // --- POINTER MOVE (already handled)
  window.addEventListener('pointermove', onPointerMove, { passive: true })

  theCube.addEventListener('click', () => {
    theCube.style.backgroundColor = "yellow" ;
  })

  theCube.addEventListener('pointerenter', () => {
    theCube.style.backgroundColor = "red" ;
  })

  theCube.addEventListener('pointerleave', () => {
    theCube.style.backgroundColor = "blue" ;
  })

  // --- DOUBLE CLICK
  window.addEventListener('dblclick', () => {
    uniforms.uDblClick.value = 1.0
    setTimeout(() => (uniforms.uDblClick.value = 0.0), timeout)
  })

  // --- MOUSE DOWN / UP
  window.addEventListener('pointerdown', () => (uniforms.uMouseDown.value = 1.0))
  window.addEventListener('pointerup', () => {
    uniforms.uMouseDown.value = 0.0
    uniforms.uMouseUp.value = 0.5
    setTimeout(() => (uniforms.uMouseUp.value = 0.0), timeout)
  })

  // --- KEY DOWN / UP
  window.addEventListener('keydown', () => (uniforms.uKeyDown.value = 1.0))
  window.addEventListener('keyup', () => {
    uniforms.uKeyDown.value = 0.0
    uniforms.uKeyUp.value = 1.0
    setTimeout(() => (uniforms.uKeyUp.value = 0.0), timeout)
  })

  // --- SCROLL
  window.addEventListener('scroll', () => {
    const scrollMax = document.body.scrollHeight - window.innerHeight
    const scrollPos = window.scrollY / scrollMax
    uniforms.uScroll.value = scrollPos
  })
}


onUnmounted(() => {
  window.removeEventListener('pointermove', onPointerMove)
})
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
  height: 200vh;
  display: flex;
  justify-content: center;
}

#theCube {
  position: absolute;
  text-align: center;
  width: 100px;
  height: 100vh;
  background-color: #0079ff;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
