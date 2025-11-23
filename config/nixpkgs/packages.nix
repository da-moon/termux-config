{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages =
    let
      # Import the claude-code flake using absolute real path to avoid symlink issues
      # Note: sync/ is a symlink to /storage/emulated/0/sync/
      realConfigDir = "/storage/emulated/0/sync/github/termux-config/config/nixpkgs";
      claudeCodeFlake = builtins.getFlake "${realConfigDir}/claude-code";
    in
    with pkgs;
    [
      # Claude Code from local flake
      claudeCodeFlake.packages.${pkgs.stdenv.hostPlatform.system}.default

      # ps wrapper to suppress Android boot time errors
      (pkgs.writeShellScriptBin "ps" ''
        ${pkgs.procps}/bin/ps "$@" 2> >(${pkgs.gnugrep}/bin/grep -v "Unable to get system boot time" >&2)
      '')

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
