{
  description = "Goose - AI agent for software development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-linux"; # For Android
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildGoModule rec {
        pname = "goose-cli";
        version = "1.13.2";

        src = pkgs.fetchFromGitHub {
          owner = "block";
          repo = "goose";
          rev = "v${version}";
          sha256 = ""; # Will be provided after first build attempt
        };

        vendorHash = ""; # Will be provided after first build attempt

        # Build from the cli subdirectory
        sourceRoot = "${src.name}/cli";

        ldflags = [
          "-s"
          "-w"
          "-X main.version=${version}"
        ];

        meta = with pkgs.lib; {
          description = "Open-source AI agent for software development";
          homepage = "https://github.com/block/goose";
          license = licenses.asl20;
          platforms = platforms.linux;
          mainProgram = "goose";
        };
      };
    };
}
