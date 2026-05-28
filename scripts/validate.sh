#!/usr/bin/env bash
# Validates all GDScript files: syntax (gdparse) + lint (gdlint).
# Optionally runs GUT unit tests if a Godot 4 binary is available.
# Exit code 0 = all checks passed.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GD_FILES=()
while IFS= read -r f; do
    GD_FILES+=("$f")
done < <(find . -name "*.gd" ! -path "./addons/*" ! -path "./tests/*" | sort)

if [ ${#GD_FILES[@]} -eq 0 ]; then
    echo "[validate] No GDScript files found — skipping."
    exit 0
fi

# --- 1. Syntax check (gdparse) ---
echo "[validate] Syntax check (gdparse) on ${#GD_FILES[@]} files..."
SYNTAX_ERRORS=0
for f in "${GD_FILES[@]}"; do
    if ! gdparse "$f" > /dev/null 2>&1; then
        echo "  SYNTAX ERROR: $f"
        gdparse "$f" 2>&1 | sed 's/^/    /'
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done
if [ $SYNTAX_ERRORS -gt 0 ]; then
    echo "[validate] FAILED: $SYNTAX_ERRORS file(s) have syntax errors."
    exit 1
fi
echo "[validate] Syntax OK."

# --- 2. Lint check (gdlint) ---
echo "[validate] Lint check (gdlint)..."
if command -v gdlint &>/dev/null; then
    if ! gdlint "${GD_FILES[@]}" 2>&1; then
        echo "[validate] FAILED: gdlint found problems. Fix them before committing."
        exit 1
    fi
    echo "[validate] Lint OK."
else
    echo "[validate] gdlint not found — skipping lint (install with: pip3 install gdtoolkit)."
fi

# --- 3. GUT unit tests (requires Godot 4 binary) ---
GODOT_BIN=""
for candidate in godot godot4 godot-4 Godot; do
    if command -v "$candidate" &>/dev/null; then
        GODOT_BIN="$candidate"
        break
    fi
done

if [ -n "$GODOT_BIN" ] && [ -d "addons/gut" ]; then
    echo "[validate] Running GUT test suite..."
    if ! "$GODOT_BIN" --headless -s addons/gut/gut_cmdln.gd \
            -gdir=res://tests/ -gexit -ginclude_subdirs 2>&1; then
        echo "[validate] FAILED: GUT tests did not pass."
        exit 1
    fi
    echo "[validate] GUT tests passed."
elif [ -n "$GODOT_BIN" ] && [ ! -d "addons/gut" ]; then
    echo "[validate] Godot found but GUT addon not installed — skipping GUT tests."
    echo "           Install GUT via AssetLib (search 'GUT') to enable automated testing."
else
    echo "[validate] Godot binary not found — skipping GUT tests."
    echo "           Install Godot 4 and add it to PATH to enable automated testing."
fi

echo "[validate] All checks passed."
