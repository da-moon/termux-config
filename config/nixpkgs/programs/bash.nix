{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import fzf-tab-completion from local flake
  fzfTabCompletionFlake = builtins.getFlake "/data/data/com.termux.nix/files/home/.config/nixpkgs/fzf-tab-completion";
  fzf-tab-completion = fzfTabCompletionFlake.packages.${pkgs.system}.default;
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
      # Starship is already initialized by home-manager's programs.starship module
      # Zoxide is already initialized by home-manager's programs.zoxide module

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
