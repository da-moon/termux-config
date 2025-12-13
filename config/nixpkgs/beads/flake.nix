{
  description = "Beads - A lightweight memory system for AI coding agents";

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
        version = "0.29.0";

        # Architecture-specific configuration
        archConfig = {
          "aarch64-linux" = {
            arch = "arm64";
            sha256 = "sha256-QsAAUt1rZO0MVe64bMC9tDw0Vi7V0H2jM+v5l6qgAbc=";
          };
          "x86_64-linux" = {
            arch = "amd64";
            sha256 = "sha256-Z//ybUB4+1b1r1km0U+laCScQ8OfNFn89VAMCbn+3+o=";
          };
        };

        # Get config for current system, fallback to amd64 if unknown
        currentArch = archConfig.${system} or archConfig."x86_64-linux";

        beads = pkgs.stdenv.mkDerivation rec {
          pname = "beads";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://github.com/steveyegge/beads/releases/download/v${version}/beads_${version}_linux_${currentArch.arch}.tar.gz";
            sha256 = currentArch.sha256;
          };

          sourceRoot = ".";

          # Use autoPatchelfHook to fix dynamic linker path
          nativeBuildInputs = [ pkgs.autoPatchelfHook ];

          # No build needed - precompiled binary
          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            runHook preInstall
            install -m755 -D bd $out/bin/bd
            runHook postInstall
          '';

          # Don't strip but do patch ELF
          dontStrip = true;

          meta = with pkgs.lib; {
            description = "Beads - A lightweight memory system for AI coding agents";
            longDescription = ''
              Beads is a graph-based issue tracker designed as a memory system
              for AI coding agents. It enables agents to manage complex work
              across extended sessions and multiple machines with dependency
              tracking, ready work detection, and git-based distribution.
            '';
            homepage = "https://github.com/steveyegge/beads";
            platforms = [ "aarch64-linux" "x86_64-linux" ];
            maintainers = [ ];
          };
        };

      in
      {
        packages = {
          default = beads;
          beads = beads;
        };

        apps = {
          default = {
            type = "app";
            program = "${beads}/bin/bd";
          };
          bd = {
            type = "app";
            program = "${beads}/bin/bd";
          };
        };
      }
    );
}
