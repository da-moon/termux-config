{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import fzf-tab-completion from local flake in git repository
  # Uses environment variables for portability (see packages.nix for details)
  system = pkgs.stdenv.hostPlatform.system;

  gitRepoEnv = builtins.getEnv "GIT_REPO_ROOT";
  configSubdirEnv = builtins.getEnv "CONFIG_SUBDIR";

  gitRepoRoot =
    if gitRepoEnv != "" then gitRepoEnv else "/storage/emulated/0/sync/github/termux-config";
  configSubdir = if configSubdirEnv != "" then configSubdirEnv else "config/nixpkgs";

  fzfTabCompletionFlake =
    builtins.getFlake "git+file://${gitRepoRoot}?dir=${configSubdir}/fzf-tab-completion";
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

    };

    initExtra = ''
      # Load secrets from external file (not tracked in git)
      [ -f ~/.secrets.env ] && source ~/.secrets.env

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
