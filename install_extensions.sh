#!/bin/bash

# This script installs Cursor extensions listed in the extensions.list file.

DOTFILES_DIR="$HOME/repos/dotfiles"
EXTENSIONS_LIST_FILE="${1:-extensions.list}"

echo "Processing $EXTENSIONS_LIST_FILE..."
EXTENSIONS_PATH="$DOTFILES_DIR/$EXTENSIONS_LIST_FILE"

if [ -f "$EXTENSIONS_PATH" ]; then
  echo "Found extensions list. Checking for installed extensions..."
  while IFS= read -r extension_id || [ -n "$extension_id" ]; do
    extension_id=$(echo "$extension_id" | xargs) # Trim whitespace
    if [ -n "$extension_id" ]; then
      if cursor --list-extensions | grep -q "^$extension_id$"; then
        echo "✅ $extension_id is already installed. Skipping."
      else
        echo "🚀 Installing $extension_id..."
        cursor --install-extension "$extension_id"
        # Optional: Add a check for successful installation here
      fi
    fi
  done < "$EXTENSIONS_PATH"
else
  echo "Error: $EXTENSIONS_LIST_FILE not found at $EXTENSIONS_PATH."
  echo "Skipping extension installation. Please create the file if you wish to install extensions automatically."
fi

echo "Extension installation complete."
