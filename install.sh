#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  ./install.sh              interactive agent select
  ./install.sh claude       ~/.claude/skills
  ./install.sh cursor       ~/.cursor/skills
  ./install.sh all          both
  ./install.sh --copy       copy instead of symlink
  ./install.sh -h, --help
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
	exit 0
fi

echo "install is not implemented yet" >&2
exit 2
