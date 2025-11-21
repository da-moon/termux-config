{ config, pkgs, ... }:

{
  # User-level environment variables for tool preferences
  home.sessionVariables = {
    # Editor preferences
    EDITOR = "hx";
    VISUAL = "hx";

    # Pager configuration
    PAGER = "bat -pp -l man";
    MANPAGER = "bat -pp -l man";
    LESS = "-R";
  };
}

# vim: ft=nix
