{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;

    # Basic configuration
    userName = "da-moon";
    userEmail = "contact@havi.dev"; 

    # Git aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    # Extra git configuration
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "hx"; # Use helix as default editor

      # Better diffs with delta (if available)
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";

      delta = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = false;
      };

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
