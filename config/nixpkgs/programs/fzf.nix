{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;

    # Enable bash integration (Ctrl+R, Ctrl+T, Alt+C)
    enableBashIntegration = true;

    # Default command for Ctrl+T (find files)
    defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git";

    # Default options
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--color=fg:#d0d0d0,bg:#121212,hl:#5f87af"
      "--color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff"
      "--color=info:#afaf87,prompt:#d7005f,pointer:#af5fff"
      "--color=marker:#87ff00,spinner:#af5fff,header:#87afaf"
    ];

    # Command for Alt+C (change directory)
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d --hidden --exclude .git";

    # Options for Alt+C
    changeDirWidgetOptions = [
      "--preview '${pkgs.eza}/bin/eza --tree --color=always {} | head -200'"
    ];

    # Options for Ctrl+T
    fileWidgetOptions = [
      "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {}'"
    ];
  };
}

# vim: ft=nix
