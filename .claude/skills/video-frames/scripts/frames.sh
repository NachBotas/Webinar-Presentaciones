#!/usr/bin/env bash
# Uso: frames.sh <video> <dir_salida> [interval|scene|at|all] [valor]
set -euo pipefail
IN="$1"; OUT="$2"; MODE="${3:-interval}"; VAL="${4:-}"
mkdir -p "$OUT"
case "$MODE" in
  interval) ffmpeg -loglevel error -i "$IN" -vf "fps=1/${VAL:-5},scale=1280:-2" -frame_pts 1 "$OUT/f_%06d.jpg"
            n=0; for f in "$OUT"/f_*.jpg; do s=$((n*${VAL:-5})); mv "$f" "$OUT/t$(printf '%02d-%02d-%02d' $((s/3600)) $((s%3600/60)) $((s%60))).jpg"; n=$((n+1)); done ;;
  scene)    ffmpeg -loglevel error -i "$IN" -vf "select='gt(scene,${VAL:-0.3})',showinfo,scale=1280:-2" -vsync vfr "$OUT/scene_%04d.jpg" 2>&1 | grep -o 'pts_time:[0-9.]*' > "$OUT/scene_times.txt" || true ;;
  at)       IFS=',' read -ra TS <<< "$VAL"; for t in "${TS[@]}"; do ffmpeg -loglevel error -ss "$t" -i "$IN" -frames:v 1 -vf scale=1280:-2 "$OUT/t${t//:/-}.jpg"; done ;;
  all)      ffmpeg -loglevel error -t "${VAL:-2}" -i "$IN" -vf scale=1280:-2 "$OUT/frame_%05d.jpg" ;;
  *) echo "modo desconocido: $MODE"; exit 1 ;;
esac
ffmpeg -loglevel error -y -pattern_type glob -i "$OUT/*.jpg" -vf "scale=320:-2,tile=6x6" -frames:v 1 "$OUT/contact-sheet.jpg" || true
ls "$OUT" | wc -l | xargs echo "archivos generados en $OUT:"
