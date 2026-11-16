---
name: presentaciones-html
description: Crear presentaciones/webinars en HTML de alto impacto (un solo archivo, navegable con teclado, animaciones, iconos SVG, imágenes, modo presentador). Usar cuando el usuario pida slides, deck, presentación o webinar en HTML.
---

# Presentaciones HTML de alto impacto

Objetivo: un **único archivo `.html`** autocontenido en `presentaciones/<nombre>/index.html`, que se abre en cualquier navegador y se presenta a pantalla completa.

## Proceso
1. Pedir (o inferir) objetivo, audiencia, duración y CTA final. Armar el guion: 1 idea por slide, 10–25 slides para 45–60 min.
2. Definir un sistema visual antes de escribir: 1 tipografía display + 1 de texto (Google Fonts), 1 color de marca + 1 acento + neutros como variables CSS en `:root`. Fondo oscuro por defecto para webinars.
3. Construir con la plantilla de abajo. Cada slide es un `<section class="slide">`.
4. Verificar con Playwright: capturar cada slide a 1920×1080 en `scratchpad`, mirar las capturas, corregir desbordes y contraste.

## Reglas de diseño
- Títulos grandes (`clamp(48px, 6vw, 110px)`), máx. ~12 palabras por slide; el detalle va en notas del presentador (`<aside class="notes">`).
- Tipos de slide para variar ritmo: portada, gran frase, número gigante (KPI), comparativa antes/después en 2 columnas, lista con iconos (3–4 ítems), imagen a sangre completa con texto encima, timeline, cita, CTA.
- Iconos: SVG inline (Lucide vía `https://unpkg.com/lucide@0.460.0` o SVG pegado). Nunca emojis como iconos. Un solo estilo de icono por deck.
- Imágenes: `object-fit: cover`, overlay con gradiente para legibilidad del texto.
- Animaciones: entradas escalonadas por slide (fade + translateY, 400–700ms, `cubic-bezier(.2,.8,.2,1)`), contadores animados para números, dibujado de trazo SVG (`stroke-dashoffset`) para iconos. Respetar `prefers-reduced-motion`. Para animaciones complejas se puede usar GSAP desde `https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js`.
- Comparativas (p. ej. frames de video extraídos con la skill `video-frames`): grid 2 columnas con etiqueta "Antes / Después" o "A / B" y una conclusión de una línea abajo.

## Plantilla base
```html
<!doctype html><html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Título</title>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
<style>
:root{--bg:#0b0d12;--fg:#f4f5f7;--muted:#9aa3b2;--brand:#6c5ce7;--accent:#00d1b2}
*{box-sizing:border-box;margin:0}
html,body{height:100%;background:var(--bg);color:var(--fg);font-family:Inter,sans-serif;overflow:hidden}
h1,h2{font-family:'Space Grotesk',sans-serif;line-height:1.05;letter-spacing:-.02em}
.slide{position:absolute;inset:0;display:flex;flex-direction:column;justify-content:center;padding:6vw 8vw;opacity:0;pointer-events:none;transition:opacity .5s}
.slide.active{opacity:1;pointer-events:auto}
.slide .in{opacity:0;transform:translateY(24px)}
.slide.active .in{animation:up .7s cubic-bezier(.2,.8,.2,1) forwards;animation-delay:calc(var(--i,0)*120ms)}
@keyframes up{to{opacity:1;transform:none}}
.notes{display:none}
#bar{position:fixed;left:0;bottom:0;height:4px;background:var(--brand);transition:width .4s}
@media (prefers-reduced-motion:reduce){.slide .in{animation:none!important;opacity:1;transform:none}}
</style></head><body>
<section class="slide"><h1 class="in">Título</h1><p class="in" style="--i:1">Subtítulo</p><aside class="notes">Notas</aside></section>
<div id="bar"></div>
<script>
const s=[...document.querySelectorAll('.slide')];let i=+(location.hash.slice(1))||0;
function go(n){i=Math.max(0,Math.min(s.length-1,n));s.forEach((e,k)=>e.classList.toggle('active',k===i));
document.getElementById('bar').style.width=((i+1)/s.length*100)+'%';history.replaceState(null,'','#'+i);}
addEventListener('keydown',e=>{if(['ArrowRight',' ','PageDown'].includes(e.key))go(i+1);
if(['ArrowLeft','PageUp'].includes(e.key))go(i-1);if(e.key==='f')document.documentElement.requestFullscreen();
if(e.key==='n')alert(s[i].querySelector('.notes')?.innerText||'');});
addEventListener('click',e=>go(e.clientX>innerWidth/2?i+1:i-1));go(i);
</script></body></html>
```

## Captura para revisar
```bash
node -e "const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();const p=await b.newPage({viewport:{width:1920,height:1080}});await p.goto('file://'+process.argv[1]);const n=await p.$$eval('.slide',x=>x.length);for(let k=0;k<n;k++){await p.evaluate(k=>{location.hash=k;go(k)},k);await p.waitForTimeout(1200);await p.screenshot({path:process.argv[2]+'/slide-'+k+'.png'})}await b.close()})()" "$PWD/presentaciones/X/index.html" "$SCRATCH"
```
