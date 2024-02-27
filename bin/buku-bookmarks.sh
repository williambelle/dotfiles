#!/usr/bin/env bash

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -e    Export buku bookmarks"
  echo "  -i    Import buku bookmarks"
  exit
}

export_bookmarks() {
  buku -e src/buku/bookmarks.md
}

import_bookmarks() {
  buku -i src/buku/bookmarks.md
}

no_args="true"
while getopts "ei" opt; do
  case "${opt}" in
    e)
      export_bookmarks
      ;;
    i)
      import_bookmarks
      ;;
    *)
      usage
      ;;
  esac
  no_args="false"
done

if [[ "$no_args" == "true" ]]; then
  usage
fi
