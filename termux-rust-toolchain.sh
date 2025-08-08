#!/usr/bin/env bash
set -efuo pipefail

CARGO_BIN="${HOME}/.cargo/bin"

pkg install -y curl build-essential pkg-config libllvm clang cmake git ca-certificates gnupg jq tar gzip
pkg install -y rust rust-analyzer rust-docs

export PATH="${PATH}:${CARGO_BIN}" ;
mkdir -p "${CARGO_BIN}" ;
# Setup Cargo global configuration
echo "Setting up Cargo configuration..."
# Check if config.toml already exists
if [ -f "$HOME/.cargo/config.toml" ]; then
    echo "Cargo config already exists at ~/.cargo/config.toml, skipping..."
else
    # Create the config file
    cat > "$HOME/.cargo/config.toml" << 'EOF'
[build]
jobs = 4

[term]
color = 'auto'

[net]
retry = 2
git-fetch-with-cli = true

[env]
CC = "clang"
CXX = "clang++"
AR = "llvm-ar"

[alias]
b = "build"
c = "check"
t = "test"
r = "run"
rr = "run --release"
br = "build --release"
EOF

    # Check if file was created successfully
    if [ -f "$HOME/.cargo/config.toml" ]; then
        echo "Created Cargo config at ~/.cargo/config.toml"
    else
        echo "Warning: Failed to create Cargo config file"
    fi
fi

# Ensure Cargo bin is in PATH if not already there
if ! echo "$PATH" | grep -q "$HOME/.cargo/bin"; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added Cargo bin to PATH in .bashrc"
fi

# Install cargo-binstall
if ! command -v cargo-binstall &>/dev/null; then
  # Get latest release
curl -sL "https://api.github.com/repos/cargo-bins/cargo-binstall/releases/latest" \
  | jq -r ".assets[] | select(.name | contains(\"$(uname -m)\") and contains(\"linux-musl\") and endswith(\".tgz\") and (contains(\".sig\") | not) and (contains(\".full\") | not)) | .browser_download_url" \
    | xargs curl -sL \
      | tar -xzOf - cargo-binstall \
      | tee "${CARGO_BIN}/cargo-binstall" >/dev/null \
  && chmod +x ${CARGO_BIN}/cargo-binstall \
  && cargo binstall --help \
    || {
    echo "Failed to download cargo-binstall"
    exit 1
  }
fi

# Install cargo tools
TOOLS=(cargo-cyclonedx cargo-watch cargo-audit cargo-outdated cargo-watch cargo-expand cargo-tree cargo-release cargo-make cargo-tarpaulin cargo-llvm-cov)
for tool in "${TOOLS[@]}"; do
  cargo install --list | grep -q "^$tool " || cargo binstall "$tool" --quiet --no-confirm
done

echo "Setup complete. Run 'source ~/.cargo/env' to use Rust in current shell."
