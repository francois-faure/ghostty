#!/usr/bin/env bash
# Run the development build of Ghostty on a non-NixOS system.
#
# The build is linked against Nix's libraries, so the system's Mesa drivers
# can't be loaded into it. Point it at the Mesa from the same Nix package set
# the build uses instead.
set -euo pipefail

cd "$(dirname "$0")"
nix_cmd=(nix --extra-experimental-features 'nix-command flakes')

mesa=$("${nix_cmd[@]}" build --no-link --print-out-paths --inputs-from . nixpkgs#mesa)

export __EGL_VENDOR_LIBRARY_FILENAMES="$mesa/share/glvnd/egl_vendor.d/50_mesa.json"
export LIBGL_DRIVERS_PATH="$mesa/lib/dri"
export GBM_BACKENDS_PATH="$mesa/lib/gbm"

# Run the binary directly rather than inside `nix develop`: the binary already
# finds its libraries through its runpath, while the dev shell's
# LD_LIBRARY_PATH would leak into every program started from the terminal.
exec ./zig-out/bin/ghostty "$@"
