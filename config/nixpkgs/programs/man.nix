{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.man = {
    enable = true;
    generateCaches = false; # Disable cache generation for performance
  };

  # Set home-manager path priority higher than system
  home.sessionVariables = {
    NIX_PATH_PRIORITY = "10"; # Lower number = higher priority
  };
}
