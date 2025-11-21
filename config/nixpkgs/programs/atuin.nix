{ config, pkgs, ... }:

{
  programs.atuin = {
    enable = true;

    # Enable bash integration
    enableBashIntegration = true;

    # Configuration settings
    settings = {
      # Search behavior
      search_mode = "fuzzy";  # Flexible fuzzy search
      filter_mode = "global"; # Search across all sessions
      style = "compact";      # Compact display style

      # UI preferences
      show_preview = true;
      max_preview_height = 4;
      show_help = true;

      # History settings
      inline_height = 20;     # Number of results to show

      # Sync settings (disabled by default - enable if you want cloud sync)
      auto_sync = false;
      # sync_frequency = "5m";
      # sync_address = "https://api.atuin.sh";

      # Key bindings - use Ctrl+R for search (default)
      # Uncomment to disable up-arrow binding:
      # keymap_mode = "vim-normal";
    };

    # Optional: disable up-arrow or ctrl-r if desired
    # flags = [ "--disable-up-arrow" ];
  };
}

# vim: ft=nix
