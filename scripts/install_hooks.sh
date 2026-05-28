#!/usr/bin/env bash
# Installs git hooks for this project.
# Run once after cloning: bash scripts/install_hooks.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

install_hook() {
    local hook="$1"
    local target="$HOOKS_DIR/$hook"
    cat > "$target" <<HOOK
#!/usr/bin/env bash
REPO_ROOT="\$(git rev-parse --show-toplevel)"
exec "\$REPO_ROOT/scripts/validate.sh"
HOOK
    chmod +x "$target"
    echo "Installed $hook hook."
}

install_hook pre-commit
install_hook pre-push

echo "Done. Run 'bash scripts/validate.sh' at any time to run checks manually."
