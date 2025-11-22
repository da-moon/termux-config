#!/data/data/com.termux/files/usr/bin/env bash
set -efuo pipefail

pkg update && pkg upgrade -y
pkg install ca-certificates openssl-tool openssl curl -y
# Set SSL cert path
export SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem
echo 'export SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem' >> ~/.bashrc


if [ ! -r "~/.zshrc" ] ;
  curl -fsSL https://git.io/termux | bash -s -- --zsh --python --neovim ;
fi
# NOTE: nerdfonts
curl -fsSL https://raw.githubusercontent.com/arnavgr/termux-nf/main/install.sh | bash

pkg install -y atuin zellij nushell ripgrep sd fd fzf bat eza git-delta difftastic ;

# https://gist.github.com/CodeIter/ccdcc840e432288ef1e01cc15d66c048
