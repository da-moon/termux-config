{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim
    git
    wget
    jq
    procps
    killall
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    openssh
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set default SHELL environment variable
  environment.sessionVariables = {
    SHELL = "${pkgs.bash}/bin/bash";
  };

  # Set your time zone
  #time.timeZone = "Europe/Berlin";

  # Home-manager configuration (modular setup)
  # Configuration is organized in:
  # - home.nix (main file with imports)
  # - programs/*.nix (per-program configs)
  # - packages.nix (package list)
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Import the modular home.nix
    config = import ./home.nix;
  };
}

# vim: ft=nix
