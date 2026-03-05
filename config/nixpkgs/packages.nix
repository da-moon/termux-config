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

      # Import custom flakes from GitHub
      claudeCodeFlake = builtins.getFlake "github:da-moon/flakes?dir=claude-code";
      kimiCliFlake = builtins.getFlake "github:da-moon/flakes?dir=kimi-cli";

      # geminiCliFlake = builtins.getFlake "github:da-moon/flakes?dir=gemini-cli";
      # gooseCliFlake = builtins.getFlake "github:da-moon/flakes?dir=goose-cli";

      fzfTabCompletionFlake = builtins.getFlake "github:da-moon/flakes?dir=fzf-tab-completion";
      beadsFlake = builtins.getFlake "github:da-moon/flakes?dir=beads";

      # MCP Servers - imported from programs
      mcpServers = import ./programs/mcp-servers.nix { inherit system; };
    in
    with pkgs;
    [
      # Custom packages from local flakes
      claudeCodeFlake.packages.${system}.default
      kimiCliFlake.packages.${system}.default
      # geminiCliFlake.packages.${system}.default
      # gooseCliFlake.packages.${system}.default
      fzfTabCompletionFlake.packages.${system}.default
      beadsFlake.packages.${system}.default
    ]
    ++ mcpServers
    ++ [

      # ps wrapper to suppress Android boot time errors
      (pkgs.writeShellScriptBin "ps" ''
        ${pkgs.procps}/bin/ps "$@" 2> >(${pkgs.gnugrep}/bin/grep -v "Unable to get system boot time" >&2)
      '')

      # stty wrapper to suppress Android PTY permission errors in devshells
      (pkgs.writeShellScriptBin "stty" ''
        ${pkgs.coreutils}/bin/stty "$@" 2> >(${pkgs.gnugrep}/bin/grep -v "Permission denied" >&2)
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
      python3 # Python interpreter

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
