<template>
  <ShaderBackground
      :autoplay="true"
      :interactive="true"
      :dpr="'auto'"
      :zIndex="-1"
      ref="bg"
      @ready="onShaderReady"
  />
</template>

<script setup>
import { ref, onUnmounted } from 'vue'
import ShaderBackground from './components/ShaderBackground.vue'

const bg = ref(null)

function onPointerMove(e) {
  if (!bg.value.getMaterial()) return

  const rect = bg.value.root.getBoundingClientRect()
  const x = (e.clientX - rect.left) / rect.width
  const y = 1.0 - (e.clientY - rect.top) / rect.height

  bg.value.getMaterial().uniforms.u_mouse.value.set(x, y)
}

function onShaderReady() {
  console.log('Shader is ready!', bg.value.getMaterial())
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
}
</style>
