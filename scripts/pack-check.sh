#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="${1:-$ROOT/skills}"

if [[ ! -d "$SKILLS_DIR" ]]; then
	echo "pack-check: missing skills dir: $SKILLS_DIR" >&2
	exit 1
fi

if [[ -f "$ROOT/SKILL.md" ]]; then
	echo "pack-check: root SKILL.md hides the pack; keep skills under skills/<name>/" >&2
	exit 1
fi

shopt -s nullglob
count=0
missing=0

for dir in "$SKILLS_DIR"/*/; do
	count=$((count + 1))
	if [[ ! -f "${dir}SKILL.md" ]]; then
		echo "pack-check: missing SKILL.md in $dir" >&2
		missing=$((missing + 1))
	fi
done

echo "pack-check: ${count} skill(s)"

if [[ "$missing" -ne 0 ]]; then
	exit 1
fi
