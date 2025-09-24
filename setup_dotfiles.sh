#!/bin/bash

# This script sets up a dotfiles project for Cursor's settings and keybindings.
# It handles cases where the files already exist in the dotfiles directory
# and are not yet symlinked from the Cursor configuration directory,
# or where the Cursor files don't exist and need a symlink created.

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

# Step 2: Handle settings.json
echo "Processing $SETTINGS_FILE..."
SOURCE_PATH="$CURSOR_CONFIG_DIR/$SETTINGS_FILE"
DEST_PATH="$DOTFILES_DIR/$SETTINGS_FILE"

if [ -f "$DEST_PATH" ]; then
  # Dotfiles version exists. Ensure Cursor file is a symlink.
  if [ -f "$SOURCE_PATH" ] && [ ! -L "$SOURCE_PATH" ]; then
    echo "Deleting original $SETTINGS_FILE and creating symlink..."
    rm -f "$SOURCE_PATH"
    ln -s "$DEST_PATH" "$SOURCE_PATH"
  elif [ ! -e "$SOURCE_PATH" ]; then
    # -e checks if the file exists at all (file or symlink)
    echo "Original $SETTINGS_FILE not found. Creating symlink to dotfiles version."
    ln -s "$DEST_PATH" "$SOURCE_PATH"
  else
    echo "No action needed for $SETTINGS_FILE. File is already symlinked or correctly in place."
  fi
elif [ -f "$SOURCE_PATH" ]; then
  # Dotfiles version does not exist, but Cursor file does.
  # Check if it's a regular file (not a symlink)
  if [ ! -L "$SOURCE_PATH" ]; then
    echo "Copying $SETTINGS_FILE from Cursor to dotfiles and creating symlink..."
    cp "$SOURCE_PATH" "$DEST_PATH"
    rm -f "$SOURCE_PATH"
    ln -s "$DEST_PATH" "$SOURCE_PATH"
  else
    echo "Error: The Cursor file $SETTINGS_FILE is a symlink, but the corresponding dotfiles version is missing. Cannot proceed."
  fi
else
  # Neither file exists.
  echo "Error: No $SETTINGS_FILE found in Cursor config directory or dotfiles directory. Cannot proceed."
fi

# Step 3: Handle keybindings.json
echo "Processing $KEYBINDINGS_FILE..."
SOURCE_PATH="$CURSOR_CONFIG_DIR/$KEYBINDINGS_FILE"
DEST_PATH="$DOTFILES_DIR/$KEYBINDINGS_FILE"

if [ -f "$DEST_PATH" ]; then
  # Dotfiles version exists. Ensure Cursor file is a symlink.
  if [ -f "$SOURCE_PATH" ] && [ ! -L "$SOURCE_PATH" ]; then
    echo "Deleting original $KEYBINDINGS_FILE and creating symlink..."
    rm -f "$SOURCE_PATH"
    ln -s "$DEST_PATH" "$SOURCE_PATH"
  elif [ ! -e "$SOURCE_PATH" ]; then
    # -e checks if the file exists at all (file or symlink)
    echo "Original $KEYBINDINGS_FILE not found. Creating symlink to dotfiles version."
    ln -s "$DEST_PATH" "$SOURCE_PATH"
  else
    echo "No action needed for $KEYBINDINGS_FILE. File is already symlinked or correctly in place."
  fi
elif [ -f "$SOURCE_PATH" ]; then
  # Dotfiles version does not exist, but Cursor file does.
  # Check if it's a regular file (not a symlink)
  if [ ! -L "$SOURCE_PATH" ]; then
    echo "Copying $KEYBINDINGS_FILE from Cursor to dotfiles and creating symlink..."
    cp "$SOURCE_PATH" "$DEST_PATH"
    rm -f "$SOURCE_PATH"
    ln -s "$DEST_PATH" "$SOURCE_PATH"
  else
    echo "Error: The Cursor file $KEYBINDINGS_FILE is a symlink, but the corresponding dotfiles version is missing. Cannot proceed."
  fi
else
  # Neither file exists.
  echo "Error: No $KEYBINDINGS_FILE found in Cursor config directory or dotfiles directory. Cannot proceed."
fi

echo "Setup complete."
