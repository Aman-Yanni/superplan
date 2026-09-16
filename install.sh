#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PACK="$ROOT/skills"
MODE=symlink
want_claude=0
want_cursor=0
saw_agent=0

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

agent_dest() {
	case "$1" in
	claude) printf '%s/.claude/skills' "$HOME" ;;
	cursor) printf '%s/.cursor/skills' "$HOME" ;;
	*)
		echo "install: unknown agent $1" >&2
		exit 2
		;;
	esac
}

is_ours() {
	local dest="$1"
	local src="$2"
	if [[ -L "$dest" ]]; then
		[[ "$(readlink "$dest")" == "$src" ]]
		return
	fi
	if [[ -d "$dest" && -f "$dest/.superplan-install" ]]; then
		[[ "$(cat "$dest/.superplan-install")" == "$src" ]]
		return
	fi
	return 1
}

prompt_agents() {
	printf '%s\n' \
		"Select agents:" \
		"  1) claude   $HOME/.claude/skills" \
		"  2) cursor   $HOME/.cursor/skills" \
		"  3) all      both" \
		"Enter 1, 2, 3 or claude/cursor/all:"
	local ans=""
	if ! IFS= read -r ans; then
		echo "install: no agent selected" >&2
		exit 2
	fi
	case "$ans" in
	1 | claude)
		want_claude=1
		;;
	2 | cursor)
		want_cursor=1
		;;
	3 | all | both)
		want_claude=1
		want_cursor=1
		;;
	"")
		echo "install: no agent selected" >&2
		exit 2
		;;
	*)
		echo "install: unknown agent" >&2
		exit 2
		;;
	esac
	saw_agent=1
}

for arg in "$@"; do
	case "$arg" in
	-h | --help)
		usage
		exit 0
		;;
	esac
done

for arg in "$@"; do
	case "$arg" in
	--copy)
		MODE=copy
		;;
	claude)
		want_claude=1
		saw_agent=1
		;;
	cursor)
		want_cursor=1
		saw_agent=1
		;;
	all)
		want_claude=1
		want_cursor=1
		saw_agent=1
		;;
	*)
		usage >&2
		exit 2
		;;
	esac
done

if [[ "$saw_agent" -eq 0 ]]; then
	prompt_agents
fi

if [[ ! -d "$PACK" ]]; then
	echo "install: missing skills dir: $PACK" >&2
	exit 1
fi

shopt -s nullglob
names=()
for dir in "$PACK"/*/; do
	if [[ -f "${dir}SKILL.md" ]]; then
		names+=("$(basename "${dir%/}")")
	fi
done

if [[ "${#names[@]}" -eq 0 ]]; then
	echo "install: no skills in $PACK" >&2
	exit 1
fi

agents=()
if [[ "$want_claude" -eq 1 ]]; then
	agents+=("claude")
fi
if [[ "$want_cursor" -eq 1 ]]; then
	agents+=("cursor")
fi

preflight() {
	local agent dest_root name dest src
	for agent in "${agents[@]}"; do
		dest_root="$(agent_dest "$agent")"
		for name in "${names[@]}"; do
			src="$PACK/$name"
			dest="$dest_root/$name"
			if [[ -e "$dest" || -L "$dest" ]]; then
				if ! is_ours "$dest" "$src"; then
					echo "install: refusing to replace $dest (not a Superplan install)" >&2
					exit 1
				fi
			fi
		done
	done
}

apply() {
	local agent dest_root name dest src
	local verb="linked"
	if [[ "$MODE" == "copy" ]]; then
		verb="copied"
	fi
	for agent in "${agents[@]}"; do
		dest_root="$(agent_dest "$agent")"
		mkdir -p "$dest_root"
		printf 'Installing Superplan (%s) → %s\n' "$MODE" "$dest_root"
		for name in "${names[@]}"; do
			src="$PACK/$name"
			dest="$dest_root/$name"
			if [[ -e "$dest" || -L "$dest" ]]; then
				rm -rf -- "$dest"
			fi
			if [[ "$MODE" == "copy" ]]; then
				cp -R "$src" "$dest"
				printf '%s\n' "$src" >"$dest/.superplan-install"
			else
				ln -s "$src" "$dest"
			fi
			printf '  %s %s\n' "$verb" "$name"
		done
	done
}

preflight
apply
