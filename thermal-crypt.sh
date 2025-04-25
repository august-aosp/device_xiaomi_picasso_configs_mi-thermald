#!/bin/bash

OUTPUT_DIR=""
INPUT_DIR=""
MODE=""
CLEAN_OUTPUT_DIR=false

# Function to display usage
usage() {
    echo "Usage: $0 [-o|--output <output_directory>] [-i|--input <input_directory>] [-D|-E]"
    echo "  -o, --output   Specify the output directory"
    echo "  -i, --input    Specify the input directory containing configs"
    echo "  -D             Decrypt mode"
    echo "  -E             Encrypt mode"
    echo "  -c, --clean   Clean output directory before processing"
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
        -c|--clean)
            CLEAN_OUTPUT_DIR=true
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
IGNORE_THERMAL_CONF_LIST=(
    thermal-engine.conf
    thermal-chg-only.conf
    thermald-devices.conf
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

if [[ "$CLEAN_OUTPUT_DIR" == true ]]; then
    echo "Cleaning output directory: $OUTPUT_DIR"
    rm -rf "$OUTPUT_DIR"/*
fi

if [[ "$MODE" == "decrypt" ]]; then
    echo "Decrypting files from $INPUT_DIR to $OUTPUT_DIR..."

    for conf in "$INPUT_DIR"/thermal-*.conf; do
        conf_name=$(basename "$conf")
        if [[ " ${IGNORE_THERMAL_CONF_LIST[@]} " =~ " $conf_name " ]]; then
            echo "Skipping $conf_name"
            continue
        fi
        "$THERMAL_CRYPT_BIN" -i $conf -o "$OUTPUT_DIR/$conf_name"
    done
elif [[ "$MODE" == "encrypt" ]]; then
    echo "Encrypting files from $INPUT_DIR to $OUTPUT_DIR..."

    for conf in "$INPUT_DIR"/thermal-*.conf; do
        conf_name=$(basename "$conf")
        if [[ " ${IGNORE_THERMAL_CONF_LIST[@]} " =~ " $conf_name " ]]; then
            echo "Skipping $conf_name"
            continue
        fi
        "$THERMAL_CRYPT_BIN" -e -i $conf -o "$OUTPUT_DIR/$conf_name"
    done
else
    echo "Error: Invalid mode specified."
    usage
fi
