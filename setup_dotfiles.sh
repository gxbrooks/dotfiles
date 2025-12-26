#!/bin/bash

# This script sets up a dotfiles project for Cursor's settings and keybindings.
# It handles cases where the files already exist in the dotfiles directory
# and are not yet symlinked from the Cursor configuration directory,
# or where the Cursor files don't exist and need a symlink created.
#
# Usage:
#   ./setup_dotfiles.sh              # Standard mode (dotfiles version takes precedence)
#   ./setup_dotfiles.sh --merge      # Merge mode (combines both versions)
#   ./setup_dotfiles.sh -m           # Short form for merge mode

# Parse command line arguments
MERGE_MODE=false
if [[ "$1" == "--merge" ]] || [[ "$1" == "-m" ]]; then
  MERGE_MODE=true
  echo "Merge mode enabled - will combine repository and Cursor configurations"
fi

echo "Starting dotfiles setup for Cursor..."

# Define file paths for clarity
DOTFILES_DIR="$HOME/repos/dotfiles"
CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
SETTINGS_FILE="settings.json"
KEYBINDINGS_FILE="keybindings.json"

# Step 1: Create the dotfiles directory if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Creating directory: $DOTFILES_DIR"
  mkdir -p "$DOTFILES_DIR"
else
  echo "Directory already exists: $DOTFILES_DIR"
fi

# Function to merge two JSON files
# Merges cursor_file into dotfiles_file, with cursor_file values taking precedence
merge_json_files() {
  local cursor_file="$1"
  local dotfiles_file="$2"
  local merged_file="$3"
  
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required for merge mode. Install with: sudo apt install jq"
    return 1
  fi
  
  # Check if files are valid JSON
  if ! jq empty "$cursor_file" 2>/dev/null; then
    echo "Warning: $cursor_file is not valid JSON, skipping merge"
    return 1
  fi
  
  if ! jq empty "$dotfiles_file" 2>/dev/null; then
    echo "Warning: $dotfiles_file is not valid JSON, skipping merge"
    return 1
  fi
  
  # Merge: cursor_file values take precedence (your recent customizations override repo defaults)
  # jq '.[0] * .[1]' merges .[1] into .[0], with .[1] values winning conflicts
  # So we put dotfiles first, cursor second, so cursor values override dotfiles
  jq -s '.[0] * .[1]' "$dotfiles_file" "$cursor_file" > "$merged_file.tmp"
  
  if [ $? -eq 0 ]; then
    mv "$merged_file.tmp" "$merged_file"
    echo "  Merged configurations (Cursor values take precedence for conflicts)"
    return 0
  else
    echo "  Error: Failed to merge JSON files"
    rm -f "$merged_file.tmp"
    return 1
  fi
}

# Step 2: Handle settings.json
echo "Processing $SETTINGS_FILE..."
SETTINGS_SOURCE_PATH="$CURSOR_CONFIG_DIR/$SETTINGS_FILE"
SETTINGS_DEST_PATH="$DOTFILES_DIR/$SETTINGS_FILE"

if [ -f "$SETTINGS_DEST_PATH" ]; then
  # Dotfiles version exists. Ensure Cursor file is a symlink.
  if [ -f "$SETTINGS_SOURCE_PATH" ] && [ ! -L "$SETTINGS_SOURCE_PATH" ]; then
    if [ "$MERGE_MODE" = true ]; then
      echo "Merge mode: Merging $SETTINGS_FILE from Cursor and dotfiles..."
      if merge_json_files "$SETTINGS_SOURCE_PATH" "$SETTINGS_DEST_PATH" "$SETTINGS_DEST_PATH"; then
        echo "Creating symlink to merged dotfiles version..."
        rm -f "$SETTINGS_SOURCE_PATH"
        ln -s "$SETTINGS_DEST_PATH" "$SETTINGS_SOURCE_PATH"
      else
        echo "Merge failed, falling back to dotfiles version..."
        rm -f "$SETTINGS_SOURCE_PATH"
        ln -s "$SETTINGS_DEST_PATH" "$SETTINGS_SOURCE_PATH"
      fi
    else
      echo "Deleting original $SETTINGS_FILE and creating symlink..."
      rm -f "$SETTINGS_SOURCE_PATH"
      ln -s "$SETTINGS_DEST_PATH" "$SETTINGS_SOURCE_PATH"
    fi
  elif [ ! -e "$SETTINGS_SOURCE_PATH" ]; then
    # -e checks if the file exists at all (file or symlink)
    echo "Original $SETTINGS_FILE not found. Creating symlink to dotfiles version."
    ln -s "$SETTINGS_DEST_PATH" "$SETTINGS_SOURCE_PATH"
  else
    echo "No action needed for $SETTINGS_FILE. File is already symlinked or correctly in place."
  fi
elif [ -f "$SETTINGS_SOURCE_PATH" ]; then
  # Dotfiles version does not exist, but Cursor file does.
  # Check if it's a regular file (not a symlink)
  if [ ! -L "$SETTINGS_SOURCE_PATH" ]; then
    echo "Copying $SETTINGS_FILE from Cursor to dotfiles and creating symlink..."
    cp "$SETTINGS_SOURCE_PATH" "$SETTINGS_DEST_PATH"
    rm -f "$SETTINGS_SOURCE_PATH"
    ln -s "$SETTINGS_DEST_PATH" "$SETTINGS_SOURCE_PATH"
  else
    echo "Error: The Cursor file $SETTINGS_FILE is a symlink, but the corresponding dotfiles version is missing. Cannot proceed."
  fi
else
  # Neither file exists.
  echo "Error: No $SETTINGS_FILE found in Cursor config directory or dotfiles directory. Cannot proceed."
fi

# Step 3: Handle keybindings.json
echo "Processing $KEYBINDINGS_FILE..."
KEYBINDINGS_SOURCE_PATH="$CURSOR_CONFIG_DIR/$KEYBINDINGS_FILE"
KEYBINDINGS_DEST_PATH="$DOTFILES_DIR/$KEYBINDINGS_FILE"

if [ -f "$KEYBINDINGS_DEST_PATH" ]; then
  # Dotfiles version exists. Ensure Cursor file is a symlink.
  if [ -f "$KEYBINDINGS_SOURCE_PATH" ] && [ ! -L "$KEYBINDINGS_SOURCE_PATH" ]; then
    if [ "$MERGE_MODE" = true ]; then
      echo "Merge mode: Merging $KEYBINDINGS_FILE from Cursor and dotfiles..."
      # For keybindings, we want to merge arrays (append, not replace)
      # Keybindings are arrays of objects, so we need special handling
      if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required for merge mode. Install with: sudo apt install jq"
        echo "Falling back to dotfiles version..."
        rm -f "$KEYBINDINGS_SOURCE_PATH"
        ln -s "$KEYBINDINGS_DEST_PATH" "$KEYBINDINGS_SOURCE_PATH"
      elif merge_json_files "$KEYBINDINGS_SOURCE_PATH" "$KEYBINDINGS_DEST_PATH" "$KEYBINDINGS_DEST_PATH"; then
        echo "Creating symlink to merged dotfiles version..."
        rm -f "$KEYBINDINGS_SOURCE_PATH"
        ln -s "$KEYBINDINGS_DEST_PATH" "$KEYBINDINGS_SOURCE_PATH"
      else
        echo "Merge failed, falling back to dotfiles version..."
        rm -f "$KEYBINDINGS_SOURCE_PATH"
        ln -s "$KEYBINDINGS_DEST_PATH" "$KEYBINDINGS_SOURCE_PATH"
      fi
    else
      echo "Deleting original $KEYBINDINGS_FILE and creating symlink..."
      rm -f "$KEYBINDINGS_SOURCE_PATH"
      ln -s "$KEYBINDINGS_DEST_PATH" "$KEYBINDINGS_SOURCE_PATH"
    fi
  elif [ ! -e "$KEYBINDINGS_SOURCE_PATH" ]; then
    # -e checks if the file exists at all (file or symlink)
    echo "Original $KEYBINDINGS_FILE not found. Creating symlink to dotfiles version."
    ln -s "$KEYBINDINGS_DEST_PATH" "$KEYBINDINGS_SOURCE_PATH"
  else
    echo "No action needed for $KEYBINDINGS_FILE. File is already symlinked or correctly in place."
  fi
elif [ -f "$KEYBINDINGS_SOURCE_PATH" ]; then
  # Dotfiles version does not exist, but Cursor file does.
  # Check if it's a regular file (not a symlink)
  if [ ! -L "$KEYBINDINGS_SOURCE_PATH" ]; then
    echo "Copying $KEYBINDINGS_FILE from Cursor to dotfiles and creating symlink..."
    cp "$KEYBINDINGS_SOURCE_PATH" "$KEYBINDINGS_DEST_PATH"
    rm -f "$KEYBINDINGS_SOURCE_PATH"
    ln -s "$KEYBINDINGS_DEST_PATH" "$KEYBINDINGS_SOURCE_PATH"
  else
    echo "Error: The Cursor file $KEYBINDINGS_FILE is a symlink, but the corresponding dotfiles version is missing. Cannot proceed."
  fi
else
  # Neither file exists.
  echo "Error: No $KEYBINDINGS_FILE found in Cursor config directory or dotfiles directory. Cannot proceed."
fi

echo "Setup complete."
