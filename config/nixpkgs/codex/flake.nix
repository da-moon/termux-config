{
  description = "OpenAI Codex CLI - AI coding assistant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "0.72.0";

        # Architecture-specific configuration
        archConfig = {
          "aarch64-linux" = {
            arch = "aarch64";
            sha256 = "sha256-HKGdAFhkgZLzkObeybYk49XDIBflWkwI1oqVrbWelHU=";
          };
          "x86_64-linux" = {
            arch = "x86_64";
            sha256 = "sha256-Qi4D9aXMGjuHc0qlfp1CUBwzRHld9L4t3fmf8f/95xw=";
          };
        };

        # Get config for current system, fallback to x86_64 if unknown
        currentArch = archConfig.${system} or archConfig."x86_64-linux";

        codex = pkgs.stdenv.mkDerivation rec {
          pname = "codex";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${currentArch.arch}-unknown-linux-musl.tar.gz";
            sha256 = currentArch.sha256;
          };

          sourceRoot = ".";

          # No build needed - precompiled binary
          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            runHook preInstall
            install -m755 -D codex-${currentArch.arch}-unknown-linux-musl $out/bin/codex
            runHook postInstall
          '';

          # Don't try to patch static musl binary
          dontStrip = true;
          dontPatchELF = true;

          meta = with pkgs.lib; {
            description = "OpenAI Codex CLI - AI coding assistant for terminal";
            longDescription = ''
              Codex is a lightweight coding agent that runs in your terminal.
              It can read and modify files, execute commands, search the web,
              and help you with various coding tasks through natural language.
            '';
            homepage = "https://github.com/openai/codex";
            platforms = [ "aarch64-linux" "x86_64-linux" ];
            maintainers = [ ];
          };
        };

      in
      {
        packages = {
          default = codex;
          codex = codex;
        };

        apps = {
          default = {
            type = "app";
            program = "${codex}/bin/codex";
          };
          codex = {
            type = "app";
            program = "${codex}/bin/codex";
          };
        };
      }
    );
}
