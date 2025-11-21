#!/data/data/com.termux/files/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  npm-shebang-fix.sh

Description:
  Fix shebangs in npm global packages and binaries for Termux compatibility.
  This script recursively fixes shebangs in:
  - npm global packages (node_modules)
  - npm bin directory
  - npx cache

  Uses the current npm prefix from `npm config get prefix`.

Examples:
  ./npm-shebang-fix.sh

Notes:
  - Requires termux-fix-shebang to be installed
  - Safe to run multiple times
  - Suppresses errors for missing directories

EOF
}

if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then
  usage
  exit 0
fi

# Check if termux-fix-shebang is available
if ! command -v termux-fix-shebang >/dev/null 2>&1; then
  echo "Error: termux-fix-shebang not found. Please install it first."
  exit 1
fi

# Phase 0: Fix npm itself if needed
echo "Phase 0: Ensuring npm has correct shebang..."
if command -v npm >/dev/null 2>&1; then
  npm_path="$(command -v npm)"
  termux-fix-shebang "$npm_path" 2>/dev/null || true
  echo " Fixed npm at: $npm_path"
else
  echo "Error: npm not found in PATH"
  exit 1
fi
echo ""

PREFIX="$(npm config get prefix)"

if [ ! -d "$PREFIX" ]; then
  echo "Error: PREFIX directory does not exist: $PREFIX"
  exit 1
fi

echo "Using npm prefix: $PREFIX"
echo ""

# Phase 1: Fix global packages
echo "Phase 1: Fixing shebangs in npm global packages..."
if [ -d "$PREFIX/lib/node_modules" ]; then
  count=$(find "$PREFIX/lib/node_modules" -type f -executable 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    find "$PREFIX/lib/node_modules" -type f -executable -exec termux-fix-shebang {} + 2>/dev/null
    echo " Fixed $count executable files in node_modules"
  else
    echo " No executable files found"
  fi
else
  echo " Directory not found: $PREFIX/lib/node_modules"
fi

# Phase 2: Fix bin directory
echo ""
echo "Phase 2: Fixing shebangs in $PREFIX/bin..."
if [ -d "$PREFIX/bin" ]; then
  count=$(find "$PREFIX/bin" -type f -executable 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    find "$PREFIX/bin" -type f -executable -exec termux-fix-shebang {} + 2>/dev/null
    echo " Fixed $count executable files in bin"
  else
    echo " No executable files found"
  fi
else
  echo " Directory not found: $PREFIX/bin"
fi

# Phase 3: Fix npx cache
echo ""
echo "Phase 3: Fixing shebangs in npx cache..."
npx_cache="$HOME/.npm/_npx"
if [ -d "$npx_cache" ]; then
  count=$(find "$npx_cache" -type f -name "*.js" -path "*/bin/*" 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    find "$npx_cache" -type f -name "*.js" -path "*/bin/*" -exec termux-fix-shebang {} + 2>/dev/null
    echo " Fixed $count JS files in npx cache"
  else
    echo " No JS files found in npx cache"
  fi
else
  echo " npx cache not found: $npx_cache"
fi

echo ""
echo "Done."
