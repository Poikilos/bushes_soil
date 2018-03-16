#!/bin/sh
echo
echo
my_name="bushes_soil"
USR_SHARE_MINETEST=/usr/share/games/minetest
try_path=/usr/share/minetest
if [ -d "$try_path" ]; then
  USR_SHARE_MINETEST=$try_path
fi

try_path=/usr/local/share/minetest
if [ -d "$try_path" ]; then
  USR_SHARE_MINETEST=$try_path
  echo "Detected local path from a manually compiled copy (this script will only work for packaged versions if $try_path does not exist)..."
fi

MT_GAMES_DIR=$USR_SHARE_MINETEST/games
MT_MYGAME_NAME=ENLIVEN
if [ ! -z "$1" ]; then
  MT_MYGAME_NAME="$1"
fi
MT_MYGAME_DIR="$MT_GAMES_DIR/$MT_MYGAME_NAME"
MT_MYGAME_MODS_PATH="$MT_MYGAME_DIR/mods"

if [ ! -d "$MT_MYGAME_MODS_PATH" ]; then
  echo "$MT_MYGAME_NAME subgame could not be found in $MT_GAMES_DIR so skipping install (add game name as 1st param to avoid this error)"
  exit 1
fi
echo
echo
this_name=${PWD##*/}
if [ "$this_name" != "$my_name" ]; then
  echo "ERROR: Nothing done since you must be in the $my_name directory for this to work."
  exit 2
fi
echo "Using $MT_MYGAME_MODS_PATH..."

if [ -d "$MT_MYGAME_MODS_PATH/$my_name" ]; then
  echo "Removing old $MT_MYGAME_MODS_PATH/$my_name..."
  sudo rm -Rf $MT_MYGAME_MODS_PATH/$my_name
fi
if [ -d "$MT_MYGAME_MODS_PATH/$my_name" ]; then
  echo "ERROR: Nothing done since failed to remove old $MT_MYGAME_MODS_PATH/$my_name"
  exit 3
fi
#NOTE: if . is used, files will go to mods path without creating folder
sudo cp -R ../$my_name "$MT_MYGAME_MODS_PATH/"
if [ -d "$MT_MYGAME_MODS_PATH/$my_name" ]; then
  echo "OK (copied to $MT_MYGAME_MODS_PATH/$my_name)"
else
  echo "FAIL (could not create $MT_MYGAME_MODS_PATH/$my_name)"
fi
