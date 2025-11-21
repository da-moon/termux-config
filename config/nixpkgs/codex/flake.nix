{
  description = "OpenAI Codex CLI tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";  # For Android
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation rec {
        pname = "codex";
        version = "0.57.0";

        src = pkgs.fetchurl {
        
                # "https://github.com/openai/codex/releases/download/rust-v0.57.0/codex-x86_64-unknown-linux-musl.tar.gz"
          url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${pkgs.stdenv.hostPlatform.uname.processor}-unknown-linux-musl.tar.gz";
            sha256 = "sha256-mHZg694PXNwIPVLSGKiUg3+rSYukK4DSLvciTH4BIpY=";
        };

        sourceRoot = ".";

        installPhase = ''
          runHook preInstall
          install -m755 -D codex-${pkgs.stdenv.hostPlatform.uname.processor}-unknown-linux-musl $out/bin/codex
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "OpenAI Codex CLI tool";
          homepage = "https://github.com/openai/codex";
          platforms = platforms.linux;
        };
      };
    };
}
