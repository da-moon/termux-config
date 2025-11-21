{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.starship = {
    enable = true;
    settings = {
      # Add a newline before the prompt
      add_newline = true;

      # Configure the prompt format
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$character"
      ];

      # Character configuration
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      # Directory configuration
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      # Git branch configuration
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      # Git status configuration
      git_status = {
        style = "bold yellow";
        conflicted = " ";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "$\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      # Nix shell indicator
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
      };

      # Username display
      username = {
        style_user = "bold yellow";
        style_root = "bold red";
        format = "[$user]($style) ";
        show_always = false;
      };

      # Hostname display
      hostname = {
        ssh_only = false;
        format = "on [$hostname](bold blue) ";
        disabled = true;
      };
    };
  };
}
