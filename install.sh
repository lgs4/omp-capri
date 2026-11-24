#!/usr/bin/env bash
# Instala as customizações do Capri no oh-my-pi (omp).
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${OMP_HOME:-$HOME/.omp}/agent"
mkdir -p "$DEST/themes"
cp "$SRC/themes/capri-afterdark.json" "$DEST/themes/"
for f in config.yml models.yml PERSONALITY.md; do
  if [ -f "$DEST/$f" ]; then cp "$DEST/$f" "$DEST/$f.bak.$(date +%s)"; fi
  cp "$SRC/$f" "$DEST/$f"
done
echo "Pronto. Backups dos arquivos antigos ficaram em $DEST/*.bak.*"
