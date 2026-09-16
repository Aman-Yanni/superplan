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

frontmatter_name() {
	awk '
		BEGIN { n = 0 }
		/^---[[:space:]]*$/ {
			n++
			if (n == 2) exit
			next
		}
		n == 1 && $1 == "name:" {
			val = $2
			for (i = 3; i <= NF; i++) val = val " " $i
			gsub(/^["'\'']|["'\'']$/, "", val)
			print val
			exit
		}
	' "$1"
}

shopt -s nullglob
count=0
missing=0

for dir in "$SKILLS_DIR"/*/; do
	count=$((count + 1))
	skill_md="${dir}SKILL.md"
	base="$(basename "${dir%/}")"
	if [[ ! -f "$skill_md" ]]; then
		echo "pack-check: missing SKILL.md in $dir" >&2
		missing=$((missing + 1))
		continue
	fi
	got="$(frontmatter_name "$skill_md")"
	if [[ -z "$got" ]]; then
		echo "pack-check: missing name: in frontmatter of $skill_md" >&2
		missing=$((missing + 1))
		continue
	fi
	if [[ "$got" != "$base" ]]; then
		echo "pack-check: name '$got' != folder '$base'" >&2
		missing=$((missing + 1))
	fi
done

echo "pack-check: ${count} skill(s)"

if [[ "$missing" -ne 0 ]]; then
	exit 1
fi
