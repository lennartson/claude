---
name: immersive-3d-frontend
description: Build immersive, 3D animated front-end experiences using Three.js, React Three Fiber, GSAP, and WebGL shaders. Activates when the user wants a 3D hero, particle systems, scroll-driven 3D scenes, interactive WebGL backgrounds, or any front-end with depth, motion, and spatial design.
origin: ECC
---

# Immersive 3D Frontend

Create production-grade, immersive 3D animated front-end experiences that run natively in the browser using Three.js, React Three Fiber (R3F), GSAP ScrollTrigger, and GLSL shaders.

## When to Activate
- User wants a 3D hero section, landing page, or full-page 3D experience
- Building interactive particle systems, WebGL backgrounds, or shader art
- Implementing scroll-driven 3D animations or camera fly-throughs
- Creating depth effects: parallax, fog, bloom, depth-of-field, refraction
- Porting a Figma/Spline/Blender concept to live browser 3D
- Adding spatial, physics-based, or fluid UI animations

## Non-Negotiables
1. **Performance first**: target 60 fps on mid-range devices; use instancing, LOD, and frustum culling.
2. **Progressive enhancement**: always supply a CSS/HTML fallback for browsers without WebGL.
3. **Responsive canvas**: canvas must fill its container and handle resize/devicePixelRatio correctly.
4. **Reduced-motion support**: detect `prefers-reduced-motion` and pause/simplify all animations.
5. **Lazy load 3D**: never block page render - load Three.js and assets asynchronously.
6. **Accessibility**: overlay semantic HTML on top of the canvas; 3D is decoration, not content.

## Stack Decision Guide

| Goal | Recommended Stack |
|---|---|
| Self-contained HTML demo | Three.js via CDN (ESM) + GSAP CDN |
| React/Next.js product | React Three Fiber + Drei + GSAP |
| Shader art / generative | Raw Three.js + custom GLSL |
| Physics interactions | R3F + `@react-three/rapier` |
| Scroll storytelling | Three.js or R3F + GSAP ScrollTrigger |
| Spline / Blender import | R3F + `@react-three/drei` `<useGLTF>` |

## Scene Architecture

### Scene Bootstrap (Vanilla Three.js)
```javascript
import * as THREE from 'https://esm.sh/three@0.163';
import { OrbitControls } from 'https://esm.sh/three@0.163/examples/jsm/controls/OrbitControls.js';

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.2;
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 100);
camera.position.set(0, 0, 5);

window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

const clock = new THREE.Clock();
function animate() {
  requestAnimationFrame(animate);
  const t = clock.getElapsedTime();
  renderer.render(scene, camera);
}
animate();
```

### React Three Fiber Bootstrap
```tsx
import { Canvas, useFrame } from '@react-three/fiber';
import { Environment, Float, OrbitControls } from '@react-three/drei';
import { Suspense, useRef } from 'react';
import * as THREE from 'three';

export default function Scene() {
  return (
    <Canvas
      camera={{ fov: 60, position: [0, 0, 5] }}
      dpr={[1, 2]}
      gl={{ antialias: true, toneMapping: 3 }}
    >
      <Suspense fallback={null}>
        <Environment preset="city" />
        <FloatingMesh />
        <OrbitControls enableZoom={false} />
      </Suspense>
    </Canvas>
  );
}

function FloatingMesh() {
  const ref = useRef<THREE.Mesh>(null);
  useFrame((state) => {
    if (!ref.current) return;
    ref.current.rotation.y = state.clock.elapsedTime * 0.4;
  });
  return (
    <Float speed={2} rotationIntensity={0.4} floatIntensity={0.8}>
      <mesh ref={ref}>
        <icosahedronGeometry args={[1, 1]} />
        <meshStandardMaterial color="#7c3aed" roughness={0.1} metalness={0.9} />
      </mesh>
    </Float>
  );
}
```

## Core 3D Techniques

### Particle Systems
```javascript
const COUNT = 5000;
const geometry = new THREE.BufferGeometry();
const positions = new Float32Array(COUNT * 3);
for (let i = 0; i < COUNT * 3; i++) {
  positions[i] = (Math.random() - 0.5) * 20;
}
geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
const material = new THREE.PointsMaterial({ size: 0.02, color: '#a78bfa' });
scene.add(new THREE.Points(geometry, material));
```

### Custom GLSL Shader Material
```javascript
const shaderMaterial = new THREE.ShaderMaterial({
  uniforms: {
    uTime:  { value: 0 },
    uColor: { value: new THREE.Color('#7c3aed') },
  },
  vertexShader: /* glsl */`
    uniform float uTime;
    varying vec2 vUv;
    void main() {
      vUv = uv;
      vec3 pos = position;
      pos.z += sin(pos.x * 3.0 + uTime) * 0.15;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    }
  `,
  fragmentShader: /* glsl */`
    uniform vec3 uColor;
    uniform float uTime;
    varying vec2 vUv;
    void main() {
      float alpha = smoothstep(0.0, 0.3, vUv.y) * smoothstep(1.0, 0.7, vUv.y);
      gl_FragColor = vec4(uColor, alpha);
    }
  `,
  transparent: true,
});
// In loop: shaderMaterial.uniforms.uTime.value = clock.getElapsedTime();
```

### Scroll-Driven Camera (GSAP ScrollTrigger)
```javascript
import gsap from 'https://esm.sh/gsap';
import ScrollTrigger from 'https://esm.sh/gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);

gsap.to(camera.position, {
  z: 2,
  y: 1.5,
  scrollTrigger: {
    trigger: '#hero',
    start: 'top top',
    end: 'bottom center',
    scrub: 1.5,
  },
});
```

### Post-Processing (R3F)
```tsx
import { EffectComposer, Bloom, ChromaticAberration, Vignette } from '@react-three/postprocessing';
import { BlendFunction } from 'postprocessing';

// Inside Canvas:
<EffectComposer>
  <Bloom luminanceThreshold={0.6} intensity={1.4} mipmapBlur />
  <ChromaticAberration offset={[0.002, 0.002]} blendFunction={BlendFunction.NORMAL} />
  <Vignette darkness={0.4} offset={0.3} />
</EffectComposer>
```

## Animation Patterns

### GSAP Timeline on Mesh Properties
```javascript
const tl = gsap.timeline({ repeat: -1, yoyo: true });
tl.to(mesh.rotation, { y: Math.PI * 2, duration: 6, ease: 'none' })
  .to(mesh.scale, { x: 1.3, y: 1.3, z: 1.3, duration: 2 }, '<');
```

### Mouse-Parallax Depth Effect
```javascript
let mouse = { x: 0, y: 0 };
window.addEventListener('mousemove', (e) => {
  mouse.x = (e.clientX / window.innerWidth  - 0.5) * 2;
  mouse.y = (e.clientY / window.innerHeight - 0.5) * 2;
});
// In loop:
camera.position.x += (mouse.x * 0.5 - camera.position.x) * 0.05;
camera.position.y += (-mouse.y * 0.3 - camera.position.y) * 0.05;
camera.lookAt(scene.position);
```

### Float + Breathe Loop (Vanilla)
```javascript
// In animation loop
mesh.position.y = Math.sin(t * 1.2) * 0.15;
mesh.rotation.x = Math.sin(t * 0.6) * 0.08;
mesh.rotation.z = Math.cos(t * 0.4) * 0.05;
```

## Performance Checklist
- [ ] Use `InstancedMesh` for repeated geometry (> 20 identical objects)
- [ ] Dispose geometries, materials, and textures when components unmount
- [ ] Cap `devicePixelRatio` at 2: `Math.min(window.devicePixelRatio, 2)`
- [ ] Use `MeshStandardMaterial` only where PBR is needed; prefer `MeshBasicMaterial` for flat/unlit objects
- [ ] Avoid per-frame DOM reads inside the animation loop
- [ ] Enable frustum culling (default true) - never set `frustumCulled = false` on large meshes
- [ ] Use compressed textures (.ktx2 with Basis) for large assets
- [ ] Profile with Chrome DevTools > Rendering > FPS meter before shipping

## Reduced-Motion & Accessibility
```javascript
const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

function animate() {
  requestAnimationFrame(animate);
  if (!prefersReduced) {
    mesh.rotation.y += 0.005;
  }
  renderer.render(scene, camera);
}
```
Always place a semantic `<h1>`, `<p>`, and CTA button in HTML above or overlaid on the canvas so screen readers and crawlers see real content.

## Workflow

### 1. Clarify Intent
Ask only what's needed:
- Is this a hero section, full-page experience, or a background effect?
- React project or standalone HTML?
- Any reference (Spline link, Dribbble, video)?

### 2. Choose Preset
Pick from `STYLE_PRESETS.md` based on mood: cosmic, minimal-glass, brutalist-geo, liquid-organic, or cyber-grid.

### 3. Scaffold
Output one of:
- `index.html` (self-contained, CDN-based)
- React component tree: `Scene.tsx`, `Mesh.tsx`, `Effects.tsx`, `useSceneAnimation.ts`

### 4. Validate
- Open in browser and confirm 60 fps in DevTools
- Test resize behavior
- Test with `prefers-reduced-motion: reduce` in DevTools emulation
- Confirm semantic HTML overlay is present and readable

### 5. Deliver
Summarize: preset used, key dependencies, perf tips, and how to swap colors/geometry.

## Related ECC Skills
- `frontend-patterns` - for React component structure wrapping 3D scenes
- `frontend-slides` - for 3D-enhanced presentation decks
- `e2e-testing` - automated visual regression on 3D outputs
