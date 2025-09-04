#!/bin/bash

BASE_DIR="/usr/src/paperless/media/documents/originals"

set -e

find $BASE_DIR -type f -name "*.*" -not -name "*.tsr" | while read file; do
  echo "[+] $file"
  export DOCUMENT_SOURCE_PATH=$file
  ./timestamp_document.sh
  sleep 0.5  # give the server some rest between our (many) requests
done
