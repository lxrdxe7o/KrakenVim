#!/usr/bin/env bash
# img2ascii.sh - Convert images to Lua ASCII headers for Neovim Alpha dashboard
# Compatible with alpha-ascii.nvim settings

set -euo pipefail

# Configuration (matching alpha-ascii defaults)
DEFAULT_WIDTH=48
DEFAULT_HEIGHT=24
DITHER="ordered4"
FORMAT="utf8"

# Paths
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
HEADERS_DIR="$NVIM_CONFIG/ascii/headers/custom"
CACHE_DIR="$NVIM_CONFIG/ascii/cache"

usage() {
	cat << EOF
Usage: $(basename "$0") IMAGE OUTPUT_NAME [WIDTH] [HEIGHT]

Convert an image to ASCII art and generate a Lua header file.

Arguments:
    IMAGE       - Input image file (PNG, JPG, GIF, WebP)
    OUTPUT_NAME - Output filename (without .lua extension)
    WIDTH       - Character width (default: $DEFAULT_WIDTH)
    HEIGHT      - Line height (default: $DEFAULT_HEIGHT)

Examples:
    $(basename "$0") logo.png my_logo
    $(basename "$0") cat.jpg cool_cat 60 30
    $(basename "$0") avatar.png profile 40 20

Generated file: $HEADERS_DIR/OUTPUT_NAME.lua
Category: custom/

Note: Requires img2txt from libcaca-utils package
      Install: sudo pacman -S libcaca (Arch)
               sudo apt install caca-utils (Debian/Ubuntu)
EOF
	exit 1
}

# Check dependencies
check_deps() {
	if ! command -v img2txt &> /dev/null; then
		echo "Error: img2txt not found. Install libcaca-utils:"
		echo "  Arch: sudo pacman -S libcaca"
		echo "  Ubuntu/Debian: sudo apt install caca-utils"
		exit 1
	fi
}

# Parse arguments
parse_args() {
	[[ $# -lt 2 ]] && usage

	INPUT_IMAGE="$1"
	OUTPUT_NAME="$2"
	WIDTH="${3:-$DEFAULT_WIDTH}"
	HEIGHT="${4:-$DEFAULT_HEIGHT}"

	# Validate input
	[[ ! -f "$INPUT_IMAGE" ]] && { echo "Error: Image not found: $INPUT_IMAGE"; exit 1; }
	[[ ! "$WIDTH" =~ ^[0-9]+$ ]] && { echo "Error: Width must be a number"; exit 1; }
	[[ ! "$HEIGHT" =~ ^[0-9]+$ ]] && { echo "Error: Height must be a number"; exit 1; }

	OUTPUT_FILE="$HEADERS_DIR/${OUTPUT_NAME}.lua"
}

# Convert image to ASCII with ANSI colors
convert_image() {
	echo "Converting: $INPUT_IMAGE"
	echo "Dimensions: ${WIDTH}x${HEIGHT}"
	echo "Output: $OUTPUT_FILE"

	mkdir -p "$HEADERS_DIR"
	mkdir -p "$CACHE_DIR"

	# Generate ASCII with img2txt
	local temp_ascii="$CACHE_DIR/${OUTPUT_NAME}.txt"

	img2txt \
		--width="$WIDTH" \
		--height="$HEIGHT" \
		--format="$FORMAT" \
		--dither="$DITHER" \
		"$INPUT_IMAGE" > "$temp_ascii"

	# Convert to Lua format
	generate_lua_header "$temp_ascii"

	rm -f "$temp_ascii"
	echo "✓ Generated: $OUTPUT_FILE"
	echo "✓ Category: custom/$OUTPUT_NAME"
	echo ""
	echo "Reload Neovim to see the new header!"
	echo "Use <leader>an to cycle to it."
}

# Generate Lua header file
generate_lua_header() {
	local ascii_file="$1"
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	local img_basename=$(basename "$INPUT_IMAGE")

	cat > "$OUTPUT_FILE" << EOF
-- Generated from: $img_basename
-- Dimensions: ${WIDTH}x${HEIGHT}
-- Generated: $timestamp
-- Category: custom

local header = {
EOF

	# Read ASCII and format as Lua table
	while IFS= read -r line; do
		# Escape special characters for Lua
		line="${line//\\/\\\\}"  # Escape backslashes
		line="${line//\"/\\\"}"  # Escape quotes
		printf '\t"%s",\n' "$line" >> "$OUTPUT_FILE"
	done < "$ascii_file"

	cat >> "$OUTPUT_FILE" << 'EOF'
}

return { header = header }
EOF
}

# Main execution
main() {
	check_deps
	parse_args "$@"
	convert_image
}

main "$@"
