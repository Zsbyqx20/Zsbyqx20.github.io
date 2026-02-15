#!/bin/bash
# Convert SVG to multi-size ICO using ImageMagick
# Usage: ./svg2ico.sh input.svg output.ico

set -e  # Exit on error

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input.svg> <output.ico>"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"

if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found."
    exit 1
fi

# Define icon sizes (standard for ICO)
SIZES=(16 24 32 48 64 128 256)

# Create temporary directory
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Generate PNGs at each size
for size in "${SIZES[@]}"; do
    magick convert \
        -background transparent \
        -density 300 \
        -resize "${size}x${size}" \
        -extent "${size}x${size}" \
        -gravity center \
        "$INPUT" \
        "$TMPDIR/icon_${size}.png"
done

# Combine all PNGs into a single ICO file
magick convert "$TMPDIR/icon_*.png" "$OUTPUT"

echo "✅ Successfully converted '$INPUT' to '$OUTPUT' with sizes: ${SIZES[*]}"