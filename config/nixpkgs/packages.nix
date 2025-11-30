{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages =
    let
      system = pkgs.stdenv.hostPlatform.system;

      # For portability: Set these environment variables to point to your setup
      # GIT_REPO_ROOT: The root of your git repository (default for nix-on-droid shown below)
      # CONFIG_SUBDIR: Subdirectory path from repo root to nixpkgs config
      gitRepoEnv = builtins.getEnv "GIT_REPO_ROOT";
      configSubdirEnv = builtins.getEnv "CONFIG_SUBDIR";

      gitRepoRoot =
        if gitRepoEnv != "" then gitRepoEnv else "/storage/emulated/0/sync/github/termux-config";
      configSubdir =
        if configSubdirEnv != "" then configSubdirEnv else "config/nixpkgs";

      # Import custom flakes from subdirectories in the git repo using ?dir= parameter
      claudeCodeFlake = builtins.getFlake "git+file://${gitRepoRoot}?dir=${configSubdir}/claude-code";
      gooseCliFlake = builtins.getFlake "git+file://${gitRepoRoot}?dir=${configSubdir}/goose-cli";
      fzfTabCompletionFlake =
        builtins.getFlake "git+file://${gitRepoRoot}?dir=${configSubdir}/fzf-tab-completion";
    in
    with pkgs;
    [
      # Custom packages from local flakes
      claudeCodeFlake.packages.${system}.default
      gooseCliFlake.packages.${system}.default
      fzfTabCompletionFlake.packages.${system}.default

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
      gh # github cli
    ];
}
