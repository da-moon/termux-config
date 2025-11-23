{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages =
    let
      # Import the claude-code flake
      claudeCodeFlake = builtins.getFlake "/data/data/com.termux.nix/files/home/.config/nixpkgs/claude-code";
    in
    with pkgs;
    [
      # Claude Code from local flake
      claudeCodeFlake.packages.${pkgs.system}.default

      # Development tools
      sd # Modern sed alternative
      delta # Git diff syntax highlighter
      nixfmt-rfc-style # Nix code formatter (RFC 166)

      # Runtime environments and package managers
      nodejs # Node.js JavaScript runtime
      deno # Secure JavaScript/TypeScript runtime
      bun # Fast JavaScript runtime and toolkit
      uv # Fast Python package installer and resolver

      # Editor
      # helix - now managed via programs.helix in programs/helix.nix

      # Search tools
      ripgrep # Fast recursive search (rg)
      fd # Fast file finder

      # File viewers and utilities
      bat # Better cat with syntax highlighting
      eza # Modern ls replacement
      trash-cli # Safe file deletion (freedesktop trash)

      # Terminal multiplexer
      zellij # Terminal workspace (manual start)

      # utilities
      fzf # fuzzy finder
      eternal-terminal # Mosh alternative
    ];
}
