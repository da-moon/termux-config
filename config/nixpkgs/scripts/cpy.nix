{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "cpy";

  runtimeInputs = with pkgs; [
    coreutils # for base64
  ];

  text = ''
    set -euo pipefail

    # Copy stdin to clipboard using OSC 52 escape sequence
    # This works in terminals that support OSC 52 (most modern terminals)
    printf "\033]52;c;%s\007" "$(base64 -w0)"
  '';

  meta = {
    description = "Copy stdin to clipboard using OSC 52 terminal escape sequence";
    longDescription = ''
      Reads from stdin and copies the content to the system clipboard
      using OSC 52 escape sequences. Works in terminals that support
      OSC 52, including most modern terminal emulators.

      Example usage:
        echo "hello" | cpy
        cat file.txt | cpy
    '';
  };
}

# vim: ft=nix
