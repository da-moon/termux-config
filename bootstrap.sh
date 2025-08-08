#!/usr/bin/env bash
set -efuo pipefail

if [ ! -r "~/.zshrc" ] ;
  curl -fsSL https://git.io/termux | bash -s -- --zsh --python --neovim ;
fi
# NOTE: nerdfonts
curl -fsSL https://raw.githubusercontent.com/arnavgr/termux-nf/main/install.sh | bash

pkg install -y \
  git-delta \
  difftastic ;
