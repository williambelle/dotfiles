#!/usr/bin/env bash

#
# Symlink all the dotfiles.
#
# Heavily inspired from paulirish's work
# See https://github.com/paulirish/dotfiles/blob/master/symlink-setup.sh
#

# Print output in light red
print_error() {
  printf "\e[0;91m  [✖] $1 $2\e[0m\n"
}

# Print output in light green
print_success() {
  printf "\e[0;92m  [✔] $1\e[0m\n"
}

# Print output in light blue
print_info() {
  printf "\n\e[0;94m$1\e[0m\n\n"
}

# Print output in light yellow
print_question() {
  printf "\e[0;93m  [?] $1\e[0m"
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  [ "$3" == "true" ] && [ $1 -ne 0 ] \
    && exit
}

get_os() {
  local os=""
  local kernelName=""

  kernelName="$(uname -s)"

  if [ "$kernelName" == "Darwin" ]; then
    os="macos"
  elif [ "$kernelName" == "Linux" ] && \
       [ -e "/etc/os-release" ]; then
         os="$(. /etc/os-release; printf "%s" "$ID")"
  else
    os="$kernelName"
  fi

  printf "%s" "$os"
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -n 1
  printf "\n"
}

answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] \
    && return 0 \
    || return 1
}

execute() {
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}

create_symlinks() {
  local os="$(get_os)"

  declare -a FILES_TO_SYMLINK=(
    "src/git/gitconfig" "$HOME/.gitconfig"
    "src/shell/zshrc" "$HOME/.zshrc"
    "src/shell/search" "$HOME/.search"
    "src/shell/exports" "$HOME/.exports"
    "src/shell/functions" "$HOME/.functions"
    "src/shell/aliases/aliases" "$HOME/.aliases"
    "src/shell/powerlevel10k" "$HOME/.powerlevel10k"
    "src/colorls/dark_colors.yaml" "$HOME/.config/colorls/dark_colors.yaml"
  )

  if [ "$os" == "macos" ]; then
    local iterm2Config="com.googlecode.iterm2.plist"
    FILES_TO_SYMLINK+=(
      "src/shell/aliases/macos_aliases" "$HOME/.aliases_os"
      "src/iterm2/$iterm2Config" "$HOME/.config/iterm2/$iterm2Config"
    )
  else
    FILES_TO_SYMLINK+=(
      "src/shell/aliases/ubuntu_aliases" "$HOME/.aliases_os"
      "src/terminator/config" "$HOME/.config/terminator/config"
      "src/mplayer/config" "$HOME/.config/mplayer/config"
      "src/mplayer/input.conf" "$HOME/.config/mplayer/input.conf"
      "src/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
    )
  fi

  local i=""
  local sourceFile=""
  local targetFile=""

  local len=${#FILES_TO_SYMLINK[*]}
  for (( i=0 ; i<${len}; i++ )); do

    sourceFile="$(pwd)/${FILES_TO_SYMLINK[$i]}"
    ((i=i+1))
    targetFile="${FILES_TO_SYMLINK[$i]}"

    if [ -e "$targetFile" ]; then
      if [ "$(readlink "$targetFile")" != "$sourceFile" ]; then

        ask_for_confirmation \
          "'$targetFile' already exists, do you want to overwrite it?"

        if answer_is_yes; then
          rm -rf "$targetFile"
          execute \
            "ln -fs $sourceFile $targetFile" \
            "$targetFile → $sourceFile"
        else
          print_error "$targetFile → $sourceFile"
        fi

      else
        print_success "$targetFile → $sourceFile"
      fi
    else
      mkdir -p "$(dirname $targetFile)"
      execute \
        "ln -fs $sourceFile $targetFile" \
        "$targetFile → $sourceFile"
    fi
  done
}

main() {
  print_info "Create symbolic links"
  create_symlinks
  printf "\n"
}

main
