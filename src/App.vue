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
let uniforms ;

function onPointerMove(e) {
  if (!bg.value.getMaterial()) return

  const rect = bg.value.root.getBoundingClientRect()
  const x = (e.clientX - rect.left) / rect.width
  const y = 1.0 - (e.clientY - rect.top) / rect.height

  uniforms.uMouse.value.set(x, y)
}

function onShaderReady() {
  console.log('Shader is ready!', bg.value.getMaterial())
  const mat = bg.value.getMaterial()
  uniforms = mat.uniforms ;

  window.addEventListener('pointermove', onPointerMove, { passive: true })
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