{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import fzf-tab-completion from GitHub flakes repo
  system = pkgs.stdenv.hostPlatform.system;
  fzfTabCompletionFlake = builtins.getFlake "github:da-moon/flakes?dir=fzf-tab-completion";
  fzf-tab-completion = fzfTabCompletionFlake.packages.${system}.default;
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true; # Enable bash completion for fzf integration

    # Shell aliases
    shellAliases = {
      # Eza (modern ls) aliases
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      l = "eza -lah";

      # Bat (better cat) alias
      cat = "bat -pp"; # Plain output without decorations

      # Zoxide (smart cd) alias
      cd = "z";

      # Nix-on-droid switch with fresh flake fetch
      nod-switch = "nix-on-droid switch --option tarball-ttl 0";

      # Syncthing log viewer
      syncthing-log = "tail -f $LOGDIR/syncthing.log";

      # Use system bash-interactive to skip slow bashInteractive evaluation
      # --command bash would use the minimal nix bash (no readline/completion)
      nix-develop = "nix develop --command ${pkgs.bashInteractive}/bin/bash";
    };

    initExtra = ''
      # Load secrets from external file (not tracked in git)
      [ -f ~/.secrets.env ] && source ~/.secrets.env

      # Autostart syncthing if not already running
      if ! pgrep -x syncthing > /dev/null 2>&1; then
        mkdir -p "$LOGDIR"
        nohup syncthing serve --no-browser > "$LOGDIR/syncthing.log" 2>&1 &
        disown
      fi


      # fzf-tab-completion: Configure auto-completion behavior
      # Auto-complete common prefix before showing fzf (prevents UI flicker)
      export FZF_COMPLETION_AUTO_COMMON_PREFIX=true
      export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART=true

      # Source the bash completion script
      source "${fzf-tab-completion}/share/fzf-tab-completion/bash/fzf-bash-completion.sh"

      # Bind tab to use fzf completion
      bind -x '"\t": fzf_bash_completion'
    '';
  };
}
