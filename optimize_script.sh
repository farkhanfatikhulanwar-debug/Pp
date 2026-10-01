#!/bin/bash

# Manual error mode
set -o nounset -o pipefail

# =========[ Auto Dependency Installer ]=========
install_dependencies() {
  echo "🔧 Installing dependencies: optipng, advancecomp, ffmpeg, zip, parallel"

  if command -v apt >/dev/null 2>&1; then
    sudo apt update -qq
    sudo apt install -y -qq optipng advancecomp ffmpeg zip parallel
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y optipng advancecomp ffmpeg zip parallel
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm optipng advancecomp ffmpeg zip parallel
  else
    echo "❌ Unsupported package manager. Please install optipng, advancecomp, ffmpeg, zip, and parallel manually."
    exit 1
  fi
}

# =========[ Dependency Check ]=========
for cmd in optipng advpng ffmpeg zip parallel; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    install_dependencies
    break
  fi
done
echo "✅ Dependencies are installed."

# =========[ Choose Optimization Level ]=========
echo "=============================="
echo "📦 Resource Pack Optimizer"
echo "=============================="
echo ""
echo "Choose optimization level:"
echo "  1) Level 1 - Balanced (PNG lossless + basic audio)"
echo "  2) Level 2 - Maximum Audio (PNG lossless + aggressive audio)"
echo ""
read -rp "Enter choice [1 or 2]: " LEVEL

if [[ "$LEVEL" != "1" && "$LEVEL" != "2" ]]; then
  echo "❌ Invalid choice. Exiting."
  exit 1
fi

if [[ "$LEVEL" == "1" ]]; then
  echo "✅ Selected: Level 1 (Balanced)"
  AUDIO_MODE="basic"
else
  echo "✅ Selected: Level 2 (Maximum Audio Compression)"
  echo "⚠️  WARNING: Audio will be normalized and silence removed."
  AUDIO_MODE="aggressive"
fi

# =========[ Ask for Directory ]=========
read -rp "📁 Enter the full path to your resource pack folder: " SRC_DIR
if [[ ! -d "$SRC_DIR" ]]; then
  echo "❌ Directory does not exist: $SRC_DIR"
  exit 1
fi

# =========[ Prepare Workspace ]=========
WORK_DIR="optimize_work"
UNPACK_DIR="$WORK_DIR/unpacked"
OUTPUT_ZIP="optimized-pack-level${LEVEL}.zip"

rm -rf "$WORK_DIR" "$OUTPUT_ZIP"
mkdir -p "$UNPACK_DIR"
cp -r "$SRC_DIR"/. "$UNPACK_DIR"/

# =========[ Remove Shader Folder ]=========
SHADER_DIR="$UNPACK_DIR/assets/minecraft/shaders"
if [[ -d "$SHADER_DIR" ]]; then
  rm -rf "$SHADER_DIR"
  echo "🗑️  Removed shader folder: assets/minecraft/shaders"
else
  echo "ℹ️  No shader folder found, skipping."
fi

# =========[ PNG Optimization ]=========
echo "=============================="
echo "🖼️  Optimizing PNG files..."
echo "=============================="

mapfile -t PNGS < <(find "$UNPACK_DIR" -type f -iname '*.png')
total_png=${#PNGS[@]}
echo "📦 Found $total_png PNG file(s)."

if [[ "$total_png" -eq 0 ]]; then
  echo "⚠️  No PNG files found!"
else
  # Get original size
  ORIGINAL_SIZE=$(du -sb "$UNPACK_DIR" | awk '{print $1}')

  # Pass 1: OptiPNG
  echo "🔄 Pass 1/2: OptiPNG optimization..."
  find "$UNPACK_DIR" -type f -iname '*.png' | \
    parallel -j+0 --bar 'optipng -o7 -fix {} >/dev/null 2>&1 || true'

  # Pass 2: AdvPNG
  echo "🔄 Pass 2/2: AdvPNG compression..."
  find "$UNPACK_DIR" -type f -iname '*.png' | \
    parallel -j+0 --bar 'advpng -z -4 {} >/dev/null 2>&1 || true'

  # Calculate savings
  NEW_SIZE=$(du -sb "$UNPACK_DIR" | awk '{print $1}')
  SAVED=$((ORIGINAL_SIZE - NEW_SIZE))
  PERCENT=$((SAVED * 100 / ORIGINAL_SIZE))

  echo "✅ PNG optimization complete (Lossless)"
  echo "💾 Saved: $(numfmt --to=iec $SAVED) ($PERCENT%)"
fi

# =========[ OGG Compression ]=========
echo "=============================="
echo "🔊 Compressing OGG files..."
echo "=============================="

mapfile -t OGGS < <(find "$UNPACK_DIR" -type f -iname '*.ogg')
total_ogg=${#OGGS[@]}
echo "📦 Found $total_ogg OGG file(s)."

if [[ "$total_ogg" -eq 0 ]]; then
  echo "⚠️  No OGG files found!"
else
  # Get original audio size
  ORIGINAL_SIZE=$(find "$UNPACK_DIR" -type f -iname '*.ogg' -exec du -cb {} + | tail -1 | awk '{print $1}')

  if [[ "$AUDIO_MODE" == "basic" ]]; then
    # Level 1: Basic compression
    echo "🔄 Mode: Basic compression (Level 1)"
    optimize_ogg() {
      local file="$1"
      ffmpeg -v error -y -i "$file" -c:a libvorbis -qscale:a 3 "${file}.tmp.ogg" 2>/dev/null
      if [[ -f "${file}.tmp.ogg" ]]; then
        mv -f "${file}.tmp.ogg" "$file"
      fi
    }
    export -f optimize_ogg

    find "$UNPACK_DIR" -type f -iname '*.ogg' | \
      parallel -j+0 --bar optimize_ogg {}
  else
    # Level 2: Aggressive compression
    echo "🔄 Mode: Aggressive compression (Level 2)"
    echo "   - Audio normalization (loudnorm)"
    echo "   - Silence removal"
    echo "   - Lower bitrate (qscale 2)"
    
    optimize_ogg_aggressive() {
      local file="$1"
      ffmpeg -v error -y -i "$file" \
        -af "loudnorm=I=-16:TP=-1.5:LRA=11,silenceremove=1:0:-50dB" \
        -c:a libvorbis -qscale:a 2 \
        -ar 44100 \
        "${file}.tmp.ogg" 2>/dev/null
      
      if [[ -f "${file}.tmp.ogg" ]]; then
        mv -f "${file}.tmp.ogg" "$file"
      fi
    }
    export -f optimize_ogg_aggressive

    find "$UNPACK_DIR" -type f -iname '*.ogg' | \
      parallel -j+0 --bar optimize_ogg_aggressive {}
  fi

  # Calculate audio savings
  NEW_SIZE=$(find "$UNPACK_DIR" -type f -iname '*.ogg' -exec du -cb {} + | tail -1 | awk '{print $1}')
  SAVED=$((ORIGINAL_SIZE - NEW_SIZE))
  PERCENT=$((SAVED * 100 / ORIGINAL_SIZE))

  echo "✅ OGG compression complete"
  echo "💾 Saved: $(numfmt --to=iec $SAVED) ($PERCENT%)"
fi

# =========[ Create ZIP ]=========
echo "=============================="
echo "📦 Creating $OUTPUT_ZIP"
echo "=============================="

(cd "$UNPACK_DIR" && zip -rq "../../$OUTPUT_ZIP" .) || {
  echo "❌ Failed to zip optimized pack."
  exit 1
}

# =========[ Cleanup ]=========
rm -rf "$WORK_DIR"

echo ""
echo "=============================="
echo "✅ All done!"
echo "=============================="
echo "📁 Output: $(realpath "$OUTPUT_ZIP")"
echo "🎯 Level: $LEVEL ($AUDIO_MODE audio)"
echo ""

if [[ "$LEVEL" == "2" ]]; then
  echo "⚠️  Level 2 used - test audio in-game to ensure sounds behave as expected."
fi
