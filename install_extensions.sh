#!/bin/bash

# This script installs Cursor extensions listed in the extensions.txt file.
#
# Usage:
#   ./install_extensions.sh                    # Install extensions from repository list (extensions.txt)
#   ./install_extensions.sh extensions.txt     # Install from specified file
#   ./install_extensions.sh -m                 # Merge mode: union installed + repo, replace repo file, then install

DOTFILES_DIR="$HOME/repos/dotfiles"
MERGE_MODE=false

# Parse command line arguments
if [[ "$1" == "-m" ]] || [[ "$1" == "--merge" ]]; then
  MERGE_MODE=true
  EXTENSIONS_LIST_FILE="${2:-extensions.txt}"
else
  EXTENSIONS_LIST_FILE="${1:-extensions.txt}"
fi

# Step 1: If merge mode, get installed extensions and union with repo list
if [ "$MERGE_MODE" = true ]; then
  echo "Merge mode: Combining installed extensions with repository list..."
  
  REPO_EXTENSIONS_PATH="$DOTFILES_DIR/$EXTENSIONS_LIST_FILE"
  
  # Get currently installed extensions
  INSTALLED_EXTENSIONS=$(cursor --list-extensions 2>/dev/null)
  
  if [ -z "$INSTALLED_EXTENSIONS" ]; then
    echo "Warning: Could not get list of installed extensions. Proceeding with repo list only."
    INSTALLED_EXTENSIONS=""
  fi
  
  # Combine installed and repo extensions (union) and save to repository location
  TEMP_FILE="/tmp/cursor_extensions_merge_$$.tmp"
  
  if [ -f "$REPO_EXTENSIONS_PATH" ]; then
    echo "Merging with repository extensions from $REPO_EXTENSIONS_PATH..."
    # Combine both lists, sort, and remove duplicates, then write to temp file
    (echo "$INSTALLED_EXTENSIONS"; cat "$REPO_EXTENSIONS_PATH") | sort -u > "$TEMP_FILE"
    mv "$TEMP_FILE" "$REPO_EXTENSIONS_PATH"
    echo "Merged extensions list saved to repository: $REPO_EXTENSIONS_PATH"
  else
    echo "Repository extensions file not found. Creating it with installed extensions..."
    echo "$INSTALLED_EXTENSIONS" | sort > "$TEMP_FILE"
    mv "$TEMP_FILE" "$REPO_EXTENSIONS_PATH"
    echo "New extensions list created at: $REPO_EXTENSIONS_PATH"
  fi
  
  echo "Processing merged extensions list..."
  EXTENSIONS_PATH="$REPO_EXTENSIONS_PATH"
else
  echo "Processing $EXTENSIONS_LIST_FILE..."
  EXTENSIONS_PATH="$DOTFILES_DIR/$EXTENSIONS_LIST_FILE"
fi

# Step 2: Install extensions from the list
if [ -f "$EXTENSIONS_PATH" ]; then
  echo "Found extensions list. Checking for installed extensions..."
  while IFS= read -r extension_id || [ -n "$extension_id" ]; do
    extension_id=$(echo "$extension_id" | xargs) # Trim whitespace
    if [ -n "$extension_id" ]; then
      if cursor --list-extensions 2>/dev/null | grep -q "^$extension_id$"; then
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
