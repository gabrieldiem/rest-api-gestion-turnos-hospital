#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: Por favor especifica el nombre de la migración."
  exit 1
fi

TARGET_DIR="./db/migrations"

if [ -n "$2" ]; then
  TARGET_DIR="$2"
fi

mkdir -p "$TARGET_DIR"

NAME_FILE=$(date +%Y%m%d%H%M%S)_"$1".rb
TARGET_FILE="$TARGET_DIR/$NAME_FILE"

echo "Creando archivo de migracion: $TARGET_FILE"
touch "$TARGET_FILE"
