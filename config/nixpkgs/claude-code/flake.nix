{
  description = "Claude Code - AI coding assistant for Android/Termux via nix-on-droid";

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
        nodejs = pkgs.nodejs_20;
        version = "2.0.69";

        # Main Claude Code package - manual extraction approach for ARM64 Android compatibility
        claude-code = pkgs.stdenv.mkDerivation rec {
          pname = "claude-code";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
            sha256 = "sha256-bJKc0kkcgZu/kmnp/vmgg/r6+dtBH4IuT2a8tRKbLzM=";
          };

          nativeBuildInputs = with pkgs; [
            makeWrapper
            nodejs
          ];

          buildInputs = with pkgs; [
            nodejs
            ripgrep # System ripgrep for search functionality
          ];

          # Skip npm build phase entirely to avoid native module issues
          dontBuild = true;
          dontConfigure = true;

          unpackPhase = ''
            runHook preUnpack

            # Extract the npm tarball
            tar -xzf $src
            cd package

            runHook postUnpack
          '';

          patchPhase = ''
            runHook prePatch

            # Remove incompatible x64 native binaries that cause crashes on ARM64
            # These vendor binaries are compiled for x64 architectures and won't work on Android

            echo "Removing incompatible vendor binaries for ARM64 compatibility..."

            # Remove ripgrep native binaries (we'll use system ripgrep instead)
            if [ -d "vendor/ripgrep" ]; then
              echo "  - Removing vendor/ripgrep x64 binaries"
              rm -rf vendor/ripgrep/*/rg 2>/dev/null || true
              rm -rf vendor/ripgrep/*/*.node 2>/dev/null || true
              rm -rf vendor/ripgrep 2>/dev/null || true
            fi

            # Remove sharp native modules if present (image processing library)
            # These lack ARM64 Android support and cause memory corruption
            if [ -d "node_modules/sharp" ]; then
              echo "  - Removing sharp native binaries"
              rm -rf node_modules/sharp 2>/dev/null || true
            fi

            # Remove any .node native addon files that might be x64-only
            find . -name "*.node" -type f 2>/dev/null | while read -r nodefile; do
              echo "  - Removing native addon: $nodefile"
              rm -f "$nodefile" 2>/dev/null || true
            done

            echo "Binary cleanup complete"

            runHook postPatch
          '';

          installPhase = ''
                        runHook preInstall
                        
                        # Create output directory structure
                        mkdir -p $out/lib/claude-code
                        mkdir -p $out/bin
                        
                        # Copy all package files (except removed native binaries)
                        echo "Installing Claude Code files..."
                        cp -r . $out/lib/claude-code/
                        
                        # Create main wrapper script with proper environment setup
                        echo "Creating wrapper script..."
                        makeWrapper ${nodejs}/bin/node $out/bin/claude \
                          --add-flags "$out/lib/claude-code/cli.js" \
                          --set NODE_PATH "$out/lib/claude-code:$out/lib/claude-code/node_modules" \
                          --set NODE_ENV "production" \
                          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ripgrep ]} \
                          --set USE_BUILTIN_RIPGREP "0" \
                          --set DISABLE_AUTO_UPDATE "1"
                        
                        # Alternative direct execution script (backup method)
                        cat > $out/bin/claude-direct << EOF
            #!/usr/bin/env bash
            export NODE_PATH="$out/lib/claude-code:$out/lib/claude-code/node_modules"
            export NODE_ENV="production"
            export USE_BUILTIN_RIPGREP="0"
            export PATH="${pkgs.ripgrep}/bin:\$PATH"
            cd $out/lib/claude-code
            exec ${nodejs}/bin/node cli.js "\$@"
            EOF
                        chmod +x $out/bin/claude-direct
                        
                        # Make the main script executable
                        chmod +x $out/lib/claude-code/cli.js 2>/dev/null || true
                        
                        echo "Installation complete"
                        
                        runHook postInstall
          '';

          # Critical settings for Android/ARM compatibility
          dontStrip = true; # Don't strip binaries (they're JavaScript anyway)
          dontPatchELF = true; # Don't try to patch ELF binaries (causes issues on Android)
          dontPatchShebangs = false; # Do patch shebangs for proper shell script execution

          meta = with pkgs.lib; {
            description = "Claude Code - AI coding assistant CLI for terminal";
            longDescription = ''
              Claude Code is an agentic coding tool that lives in your terminal,
              understands your codebase, and helps you code faster by executing
              routine tasks, explaining complex code, and handling git workflows
              through natural language commands.

              This build is optimized for nix-on-droid/Android ARM64 by removing
              incompatible x64 native binaries and using system tools instead.
            '';
            homepage = "https://github.com/anthropics/claude-code";
            platforms = platforms.unix;
            maintainers = [ ];
          };
        };

      in
      {
        # Main package outputs
        packages = {
          default = claude-code;
          claude-code = claude-code;
        };

        # Development shell with all necessary tools
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            ripgrep
            git
          ];

          shellHook = ''
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  Claude Code Development Shell (nix-on-droid)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Environment:"
            echo "  Node.js:  $(node --version)"
            echo "  npm:      $(npm --version)"
            echo "  ripgrep:  $(rg --version | head -n1)"
            echo "  git:      $(git --version)"
            echo ""
            echo "Commands:"
            echo "  nix build              # Build Claude Code package"
            echo "  nix build .#claude-code # Same as above"
            echo "  ./result/bin/claude    # Run after building"
            echo ""
            echo "Note: This build is optimized for Android ARM64"
            echo "      Image processing features may be limited"
            echo ""
            echo "Set up API key before using:"
            echo "  export ANTHROPIC_API_KEY='your-key-here'"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };

        # Apps for easy running
        apps = {
          default = {
            type = "app";
            program = "${claude-code}/bin/claude";
          };
          claude = {
            type = "app";
            program = "${claude-code}/bin/claude";
          };
          claude-direct = {
            type = "app";
            program = "${claude-code}/bin/claude-direct";
          };
        };
      }
    );
}
# NOTE: Minimal way to install it
# nix registry add personal/claude-code github:da-moon/termux-config?dir=config/nixpkgs/claude-code
# nix profile install personal/claude-code#claude-cod

