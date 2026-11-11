#!/usr/bin/env bash
# Shrink new photos before committing them (keeps the git repo small).
#
#   scripts/optimize_photos.sh            # processes assets/photography/
#
# Every image larger than 3000 px or 6 MB is re-saved as a high-quality JPEG (long edge 3000 px,
# all metadata incl. GPS removed). The untouched original is moved to assets/photography/_originals/,
# which git ignores, so nothing is lost. The website build makes its own smaller copies anyway.
set -euo pipefail
cd "$(dirname "$0")/../assets/photography"
mkdir -p _originals
M=$(command -v magick || command -v convert)
shopt -s nullglob nocaseglob
for f in *.jpg *.jpeg *.png *.tif *.tiff *.heic *.webp; do
  size=$(wc -c <"$f")
  dims=$("$M" identify -format '%w %h' "$f[0]" 2>/dev/null || echo "0 0")
  read -r w h <<<"$dims"
  if (( size > 6000000 || w > 3000 || h > 3000 )); then
    out="${f%.*}.jpg"
    echo "→ $f  (${w}x${h}, $((size / 1000000)) MB)"
    mv "$f" "_originals/$f"
    "$M" "_originals/$f[0]" -auto-orient -colorspace sRGB -depth 8 -resize '3000x3000>' -strip -quality 90 "$out"
  fi
done
echo "Done."
