{ config, lib, pkgs, ... }:

{
  # Custom utility scripts managed by Nix
  # Each script is defined in its own file in this directory
  home.packages = [
    # Clipboard utility - copy stdin to clipboard via OSC 52
    (import ./cpy.nix { inherit pkgs; })

    # Add more scripts here as you create them:
    # (import ./another-script.nix { inherit pkgs; })
  ];
}

# vim: ft=nix
