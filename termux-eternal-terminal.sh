#!/data/data/com.termux/files/usr/bin/bash

# Sanity checks
[ ! -d /data/data/com.termux ] && echo "Not running on Termux" && exit 1
command -v pkg >/dev/null 2>&1 || {
  echo "pkg not found"
  exit 1
}

# Set PREFIX with default
: ${PREFIX:=/data/data/com.termux/files/usr}

# Install minimal dependencies for version check
pkg install -y curl jq >/dev/null 2>&1

# Get latest version from GitHub API
ET_VERSION=$(curl -s https://api.github.com/repos/MisterTea/EternalTerminal/releases/latest | jq -r '.tag_name' | sed 's/^et-v//')
: ${ET_VERSION:=6.2.11}

# Variables
BUILD_DIR=$(mktemp -d)
: ${MAKEFLAGS:=-j$(nproc)}

# Cleanup on exit
trap 'rm -rf "$BUILD_DIR"' EXIT

# Install dependencies
pkg update -y
pkg install -y cmake make clang openssl libsodium protobuf libcurl zlib

# Enter build directory
cd "$BUILD_DIR" || exit 1

# Download source
wget -q "https://github.com/MisterTea/EternalTerminal/archive/et-v${ET_VERSION}.tar.gz" || exit 1
tar -xzf "et-v${ET_VERSION}.tar.gz" || exit 1
cd "EternalTerminal-et-v${ET_VERSION}" || exit 1

# Create build directory
mkdir -p build
cd build || exit 1

# ARM optimization for Android
export VCPKG_FORCE_SYSTEM_BINARIES=1

# Configure
cmake .. \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DDISABLE_VCPKG=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TEST=OFF \
  -DDISABLE_CRASH_LOG=ON || exit 1

# Build client only
make -j$(nproc) et || exit 1

# Install client only
[ -f et ] || {
  echo "Build failed"
  exit 1
}
install -m 755 et "${PREFIX}/bin/et" || exit 1
# ln -sf "${PREFIX}/bin/et" "${PREFIX}/bin/htm"
# ln -sf "${PREFIX}/bin/et" "${PREFIX}/bin/htmd"

echo "EternalTerminal client v${ET_VERSION} installed to ${PREFIX}/bin/et"
