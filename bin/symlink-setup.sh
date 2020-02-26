#!/usr/bin/env bash

#
# Symlink all the dotfiles to ~/
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
  declare -A FILES_TO_SYMLINK=(
    ["src/git/gitconfig"]="$HOME/.gitconfig"
    ["src/shell/zshrc"]="$HOME/.zshrc"
    ["src/shell/powerlevel9k"]="$HOME/.powerlevel9k"
    ["src/colorls/config"]="$HOME/.config/colorls/config"
    ["src/terminator/config"]="$HOME/.config/terminator/config"
  )

  local i=""
  local sourceFile=""
  local targetFile=""

  for key in "${!FILES_TO_SYMLINK[@]}"; do

    sourceFile="$(pwd)/$key"
    targetFile="${FILES_TO_SYMLINK[$key]}"

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
