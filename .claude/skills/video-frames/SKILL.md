---
name: video-frames
description: Extraer frames (capturas cuadro a cuadro, por intervalo o por cambio de escena) de un video de YouTube, Google Drive o archivo local, para analizarlos visualmente y hacer comparativas. Usar cuando el usuario pase un link de video y quiera ver, analizar, comparar o sacar capturas.
---

# Frames de video para análisis y comparativas

## 1. Conseguir el video
- **YouTube / otros sitios**: `yt-dlp -f "bv*[height<=720]+ba/b[height<=720]" -o "$DIR/video.%(ext)s" "<URL>"` (instalar con `pip install yt-dlp` si falta). Si falla con `403 Forbidden` del proxy, el entorno cloud no permite youtube.com: hay que habilitar los hosts `www.youtube.com`, `youtube.com`, `*.googlevideo.com` en la red del entorno (o descargar el video y subirlo a Drive).
- **Google Drive**: usar el conector de Google Drive (`download_file_content` con el ID del archivo del link `drive.google.com/file/d/<ID>/...`) y guardar el archivo.
- **Local**: usar la ruta directamente.
Guardar todo en un directorio nuevo del scratchpad, nunca en el repo.

## 2. Extraer frames
Usar `scripts/frames.sh <video> <salida> <modo> [valor]`:
- `interval 5` → 1 frame cada 5 s (por defecto).
- `scene 0.3` → solo cuando cambia la escena (ideal para slides/cortes).
- `at 00:01:23,00:04:10` → timestamps exactos.
- `all 2` → todos los frames de los primeros N segundos (cuadro a cuadro real).
Además genera `contact-sheet.jpg` (mosaico) para una vista rápida.

## 3. Analizar
- Mirar primero `contact-sheet.jpg` con Read, después los frames individuales relevantes. El nombre de cada archivo lleva el timestamp.
- Para comparar dos videos: extraer con el mismo modo en ambos y armar una tabla/slide A vs B por timestamp; o `ffmpeg -i a.jpg -i b.jpg -filter_complex hstack lado-a-lado.jpg`.
- Si además se necesita lo que se dice, sacar subtítulos: `yt-dlp --write-auto-subs --sub-langs es,en --skip-download`.
- Las comparativas se pueden volcar directo a una slide con la skill `presentaciones-html`.
