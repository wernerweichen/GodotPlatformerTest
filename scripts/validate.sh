#!/usr/bin/env bash
# Validates all GDScript files: syntax (gdparse) + lint (gdlint) +
# Variant-inference check + GUT unit tests (when Godot available).
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

# --- 3. Variant-inference check ---
# Godot 4 treats "inferred from Variant" as a compile error.
# These patterns are the most common sources: functions that return Variant
# when called without an explicit cast or typed destination.
echo "[validate] Variant-inference check..."
VARIANT_ERRORS=0

# Functions whose return type is always Variant in Godot 4
VARIANT_FUNCS="get_node_or_null|get_first_node_in_group|find_child|find_node|get_meta"
# Polymorphic math builtins that resolve to Variant when arg types are ambiguous
POLY_MATH="sign\b|max\b|min\b|abs\b|clamp\b"

# Match: var <name> :=  <variant_func>(
PATTERN=":= *(${VARIANT_FUNCS}|${POLY_MATH})\("

while IFS= read -r -d '' file; do
    # Exclude lines already resolved via 'as Type' safe cast
    matches=$(grep -nP "$PATTERN" "$file" 2>/dev/null | grep -v " as " || true)
    if [ -n "$matches" ]; then
        echo "  VARIANT INFERENCE in $file:"
        echo "$matches" | sed 's/^/    /'
        VARIANT_ERRORS=$((VARIANT_ERRORS + 1))
    fi
done < <(printf '%s\0' "${GD_FILES[@]}")

if [ $VARIANT_ERRORS -gt 0 ]; then
    echo ""
    echo "[validate] FAILED: $VARIANT_ERRORS file(s) use ':=' with Variant-returning functions."
    echo "           Use an explicit type annotation or cast:"
    echo "             var x: float = sign(y)          -- explicit type"
    echo "             var x := signf(y)                -- typed variant (signf/signi)"
    echo "             var node := get_node_or_null('N') as Node2D  -- safe cast"
    echo "             var n: int = maxi(a, b)          -- typed int max"
    exit 1
fi
echo "[validate] Variant-inference OK."

# --- 4. GUT unit tests (requires Godot 4 binary) ---
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
    echo "           Install Godot 4 and add it to PATH to enable full runtime validation."
fi

echo "[validate] All checks passed."
