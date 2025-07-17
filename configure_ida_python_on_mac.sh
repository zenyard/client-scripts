#!/usr/bin/env bash
set -euo pipefail

# Which Python executable to use (default: python3.10)
PY_BIN="${PYTHON_VERSION:-python3.10}"

# Verify the executable is in PATH
command -v "$PY_BIN" >/dev/null 2>&1 || {
  echo "Error: \"$PY_BIN\" not found in \$PATH" >&2
  exit 1
}

# Resolve the corresponding CPython framework library
PYTHON_LIB="$(
  "$PY_BIN" - <<'PY'
import sysconfig, pathlib
libdir = pathlib.Path(sysconfig.get_config_var("LIBDIR"))
print(libdir.parent / "Python")
PY
)"

[[ -f "$PYTHON_LIB" ]] || { echo "Cannot find Python library: $PYTHON_LIB" >&2; exit 1; }

find /Applications -maxdepth 1 -type d \( -name "IDA *.app" -o -name "IDA*.app" \) |
while read -r ida; do
  echo "Re-pointing ${ida##*/} → $PYTHON_LIB"
  "$ida/Contents/MacOS/idapyswitch" --force-path "$PYTHON_LIB"
done
