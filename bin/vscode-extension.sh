#!/usr/bin/env bash

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -e    Export vscode extensions"
  echo "  -i    Install vscode extensions"
  exit
}

export_extensions() {
  code --list-extensions | sort | uniq -i > src/vscode/extensions.list
}

import_extensions() {
  while IFS='' read -r LINE || [ -n "${LINE}" ]; do
    code --install-extension "${LINE}"
  done < src/vscode/extensions.list
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
