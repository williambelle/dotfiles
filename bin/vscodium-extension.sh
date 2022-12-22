#!/usr/bin/env bash

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -e    Export VSCodium extensions"
  echo "  -i    Install VSCodium extensions"
  exit
}

export_extensions() {
  codium --list-extensions | sort | uniq -i > src/vscodium/extensions.list
}

import_extensions() {
  while IFS='' read -r LINE || [ -n "${LINE}" ]; do
    codium --install-extension "${LINE}"
  done < src/vscodium/extensions.list
}

no_args="true"
while getopts "ei" opt; do
  case "${opt}" in
    e)
      export_extensions
      ;;
    i)
      import_extensions
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
