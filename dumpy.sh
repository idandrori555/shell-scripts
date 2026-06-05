#!/bin/bash

TREE_ONLY=false
EXTENSIONS=()
EXCLUDE_FILES=()

# Parse flags and arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--tree)
            TREE_ONLY=true
            shift
            ;;
        -x|--exclude)
            EXCLUDE_FILES+=("$2")
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [-t|--tree] [-x|--exclude filename] ext1 ext2 ..." >&2
            exit 1
            ;;
        *)
            EXTENSIONS+=("$1")
            shift
            ;;
    esac
done

# --- Feature: Tree Only ---
if [ "$TREE_ONLY" = true ]; then
    if command -v tree &> /dev/null; then
        tree
    else
        # Fallback to find if tree is not installed (skips hidden files)
        find . -maxdepth 2 -not -path '*/.*'
    fi
    exit 0
fi

# Ensure extensions are provided if we are dumping file content
if [ ${#EXTENSIONS[@]} -eq 0 ]; then
    echo "Usage: $0 [-t|--tree] [-x|--exclude filename] ext1 ext2 ..." >&2
    exit 1
fi

# --- Feature: File Dump ---
# Avoid processing this script or common database files
EXCLUDE_ARGS=( -not -name "sqlite3.c" -not -name "sqlite3.h" -not -name "$(basename "$0")" )

for x_file in "${EXCLUDE_FILES[@]}"; do
    EXCLUDE_ARGS+=("-not" "-name" "$x_file")
done

NAME_ARGS=()
for ext in "${EXTENSIONS[@]}"; do
    [[ ${#NAME_ARGS[@]} -gt 0 ]] && NAME_ARGS+=("-o")
    NAME_ARGS+=("-name" "*.$ext")
done

# Dump everything straight to stdout
find . -maxdepth 2 -type f \( "${NAME_ARGS[@]}" \) "${EXCLUDE_ARGS[@]}" -print0 | while IFS= read -r -d '' file; do
    echo "FILE: $file"
    echo "================================================================================"
    cat "$file"
    echo -e "\n\n"
done
