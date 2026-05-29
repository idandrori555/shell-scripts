#!/usr/bin/env bash

set -e

TEMPLATES_DIR="$HOME/.boil"

show_help() {
  echo "Usage:"
  echo "  boil <template-name>       # Copy template to current directory"
  echo "  boil --ls                  # List all templates"
  echo "  boil --help                # Show this help message"
  echo "  boil --new <target_folder> # Add new template from folder/file"
}

list_templates() {
  if [ -d "$TEMPLATES_DIR" ]; then
    echo "Available templates in $TEMPLATES_DIR:"
    ls -A1 "$TEMPLATES_DIR"
  else
    echo "No templates directory found at $TEMPLATES_DIR"
  fi
}

copy_to_boil() {
  local SRC="$1"
  local DEST="$2"

  if [ -d "$SRC" ]; then
    cp -r "$SRC" "$DEST"
  else
    cp "$SRC" "$DEST"
  fi
}

# Ensure templates directory exists
mkdir -p "$TEMPLATES_DIR"

# Check arguments
if [ $# -lt 1 ]; then
  show_help
  exit 1
fi

case "$1" in
  --help)
    show_help
    exit 0
    ;;
  --ls)
    list_templates
    exit 0
    ;;
  --new)
    if [ $# -lt 2 ]; then
      echo "❌ Usage: boil --new <target_folder>"
      exit 1
    fi

    TARGET="$2"
    if [ ! -e "$TARGET" ]; then
      echo "❌ Folder/file '$TARGET' does not exist."
      exit 1
    fi

    BASENAME=$(basename "$TARGET")
    DEST="$TEMPLATES_DIR/$BASENAME"

    if [ -e "$DEST" ]; then
      echo "❌ Template '$BASENAME' already exists in $TEMPLATES_DIR"
      exit 1
    fi

    copy_to_boil "$TARGET" "$DEST"
    echo "✅ Added new template '$BASENAME' to $TEMPLATES_DIR"
    exit 0
    ;;
  *)
    TEMPLATE_NAME="$1"
    SRC="$TEMPLATES_DIR/$TEMPLATE_NAME"
    DEST="$(pwd)"

    if [ ! -e "$SRC" ]; then
      echo "❌ Template '$TEMPLATE_NAME' not found in $TEMPLATES_DIR"
      exit 1
    fi

    if [ -d "$SRC" ]; then
      cp -rn "$SRC/." "$DEST/"
    else
      cp -n "$SRC" "$DEST/"
    fi

    echo "✅ Boiled '$TEMPLATE_NAME' into '$DEST'"
    ;;
esac
