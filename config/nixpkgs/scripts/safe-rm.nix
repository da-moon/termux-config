{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "safe-rm";

  runtimeInputs = with pkgs; [
    trash-cli
    coreutils
  ];

  text = ''
    # Check if any argument is on /storage/emulated (different volume)
    for arg in "$@"; do
      # Skip flags
      [[ "$arg" == -* ]] && continue

      # Cross-volume: use real rm
      if [[ "$arg" == /storage/emulated/* ]]; then
        exec rm "$@"
      fi
    done

    # Same volume: use trash
    exec trash-put "$@"
  '';

  meta = {
    description = "Smart rm wrapper that uses trash-put when possible, real rm for cross-volume files";
    longDescription = ''
      Automatically detects if files are on the same volume as the trash directory.
      - Same volume (e.g., home directory): uses trash-put for safe deletion
      - Different volume (e.g., /storage/emulated): uses real rm for permanent deletion

      This solves the Android limitation where trash-cli cannot move files
      across different filesystem volumes.

      Example usage:
        rm ~/file.txt                          # Uses trash (safe)
        rm /storage/emulated/0/Download/x.pdf  # Uses real rm (permanent)
    '';
  };
}

# vim: ft=nix
