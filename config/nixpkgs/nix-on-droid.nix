{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.packages = with pkgs; [
    vim
    git
    wget
    jq
    procps
    killall
    diffutils
    findutils
    utillinux
    which
    ncurses
    tzdata
    hostname
    gnugrep
    gnupg
    gnused
    gawk
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    openssh
  ];
  environment.etcBackupExtension = ".bak";
  system.stateVersion = "24.05";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  environment.sessionVariables = {
    SHELL = "${pkgs.bash}/bin/bash";
    LOGDIR = "/data/data/com.termux.nix/files/usr/var/log";
    XDG_CONFIG_HOME = "/data/data/com.termux.nix/files/home/.config";
    XDG_CACHE_HOME = "/data/data/com.termux.nix/files/home/.cache";
    XDG_DATA_HOME = "/data/data/com.termux.nix/files/home/.local/share";
    XDG_STATE_HOME = "/data/data/com.termux.nix/files/home/.local/state";
    XDG_RUNTIME_DIR = "/data/data/com.termux.nix/files/usr/tmp";
    XDG_BIN_HOME = "/data/data/com.termux.nix/files/home/.local/bin";
  };
  time.timeZone = "America/New_York";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    config = import ./home.nix;
  };
}

# vim: ft=nix
