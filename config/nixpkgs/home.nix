{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Import modular configurations
  imports = [
    ./programs/bash.nix
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/zoxide.nix
    ./programs/man.nix
    ./programs/atuin.nix
    ./programs/fzf.nix
    ./programs/environment.nix
    ./packages.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.05";
}
