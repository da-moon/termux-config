# Utility script

This directory contains utility scripts and snippets to help with common Termux operations.

Ideally, you want to copy them under `/data/data/com.termux/files/usr/local/bin` or `/data/data/com.termux/files/home/.local/bin` ( if it is part of PATH) so that you can re-run them easily.

```bash
export XDG_BIN_HOME="/data/data/com.termux/files/home/.local/bin" ; 
find "$(pwd)/bin" -type f -name '*.sh' -exec sh -c '
  for f; do
    cp "$f" "$XDG_BIN_HOME/$(basename "${f%.sh}")" ;
    chmod +x "$XDG_BIN_HOME/$(basename "${f%.sh}")"
  done
' _ {} +
```

We are copying because `/storage/emulated/0` is Android shared storage using a FUSE filesystem. FUSE filesystems in Android do not support Unix execute permissions
