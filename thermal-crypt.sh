#!/bin/bash

OUTPUT_DIR=""
INPUT_DIR=""
MODE=""

# Function to display usage
usage() {
    echo "Usage: $0 [-o|--output <output_directory>] [-i|--input <input_directory>] [-D|-E]"
    echo "  -o, --output   Specify the output directory"
    echo "  -i, --input    Specify the input directory containing configs"
    echo "  -D             Decrypt mode"
    echo "  -E             Encrypt mode"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -i|--input)
            INPUT_DIR="$2"
            shift 2
            ;;
        -D)
            MODE="decrypt"
            shift
            ;;
        -E)
            MODE="encrypt"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$OUTPUT_DIR" || -z "$INPUT_DIR" || -z "$MODE" ]]; then
    echo "Error: Missing required arguments."
    usage
    exit 1
fi

THERMAL_CRYPT_BIN="mi-thermal-crypt/mi-thermal-crypt"
THERMAL_CONF_LIST=(
    thermal-4k.conf
    thermal-arvr.conf
    thermal-camera.conf
    thermal-class0.conf
    thermal-extreme.conf
    thermal-high.conf
    thermal-nolimits.conf
    thermal-normal.conf
    thermal-per-camera.conf
    thermal-per-class0.conf
    thermal-per-normal.conf
    thermal-phone.conf
    thermal-tgame.conf
    thermal-youtube.conf
    thermal-map.conf
)

if [[ ! -f "$THERMAL_CRYPT_BIN" ]]; then
    echo "Error: Thermal crypt binary not found. Please run `git submodule update --init`"
    exit 1
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory does not exist."
    exit 1
fi
if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

if [[ "$MODE" == "decrypt" ]]; then
    echo "Decrypting files from $INPUT_DIR to $OUTPUT_DIR..."

    for conf in "${THERMAL_CONF_LIST[@]}"; do
        if [[ ! -f "$INPUT_DIR/$conf" ]]; then
            echo "Warning: $INPUT_DIR/$conf does not exist, skipping."
            continue
        fi
        "$THERMAL_CRYPT_BIN" -i $INPUT_DIR/$conf -o "$OUTPUT_DIR/$conf"
    done
elif [[ "$MODE" == "encrypt" ]]; then
    echo "Encrypting files from $INPUT_DIR to $OUTPUT_DIR..."

    for conf in "$INPUT_DIR"/thermal-*.conf; do
        "$THERMAL_CRYPT_BIN" -e -i $conf -o "$OUTPUT_DIR/$(basename "$conf")"
    done
else
    echo "Error: Invalid mode specified."
    usage
fi
