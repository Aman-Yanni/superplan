#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  init.sh --workspace PATH --hub NAME [--create-workspace] [--repo PATH ...]
  init.sh --discover PATH
  init.sh -h, --help

  --workspace PATH     planning workspace directory
  --create-workspace   create workspace if missing
  --hub NAME_OR_PATH   folder under workspace, or an absolute/relative path
  --repo PATH          bound product repo (repeatable); must exist
  --discover PATH      list git dirs (PATH and its immediate children); no writes
EOF
}

yaml_quote() {
	local s=$1
	s=${s//\\/\\\\}
	s=${s//\"/\\\"}
	printf '"%s"' "$s"
}

discover() {
	local root d
	if [[ ! -d "$1" ]]; then
		echo "init: discover path is not a directory: $1" >&2
		exit 1
	fi
	root="$(cd "$1" && pwd)"
	if [[ -d "$root/.git" ]]; then
		printf '%s\n' "$root"
	fi
	shopt -s nullglob
	for d in "$root"/*/; do
		if [[ -d "${d}.git" ]]; then
			(cd "$d" && pwd)
		fi
	done
}

CONFIG_DIR_REL=".superplan"
workspace=""
hub_arg=""
create_ws=0
do_discover=""
repos=()

for arg in "$@"; do
	case "$arg" in
	-h | --help)
		usage
		exit 0
		;;
	esac
done

while [[ $# -gt 0 ]]; do
	case "$1" in
	--workspace)
		workspace=${2:?init: --workspace needs a path}
		shift 2
		;;
	--hub)
		hub_arg=${2:?init: --hub needs a name or path}
		shift 2
		;;
	--repo)
		repos+=("${2:?init: --repo needs a path}")
		shift 2
		;;
	--create-workspace)
		create_ws=1
		shift
		;;
	--discover)
		do_discover=${2:?init: --discover needs a path}
		shift 2
		;;
	*)
		usage >&2
		exit 2
		;;
	esac
done

if [[ -n "$do_discover" ]]; then
	discover "$do_discover"
	exit 0
fi

config_file="$HOME/$CONFIG_DIR_REL/config.yml"

if [[ -z "$workspace" && -f "$config_file" ]]; then
	workspace="$(awk -F': *' '/^planning_workspace:/{gsub(/^[ \t"]+|[ \t"]+$/, "", $2); print $2; exit}' "$config_file")"
fi

if [[ -z "$workspace" ]]; then
	echo "init: --workspace is required (no saved planning_workspace)" >&2
	exit 2
fi

if [[ -z "$hub_arg" ]]; then
	echo "init: --hub is required" >&2
	exit 2
fi

if [[ ! -d "$workspace" ]]; then
	if [[ "$create_ws" -eq 1 ]]; then
		mkdir -p "$workspace"
	else
		echo "init: workspace does not exist (pass --create-workspace): $workspace" >&2
		exit 1
	fi
fi
workspace="$(cd "$workspace" && pwd)"

hub=""
if [[ "$hub_arg" == /* || "$hub_arg" == */* ]]; then
	if [[ ! -d "$hub_arg" ]]; then
		mkdir -p "$hub_arg"
	fi
	hub="$(cd "$hub_arg" && pwd)"
else
	hub="$workspace/$hub_arg"
	mkdir -p "$hub"
	hub="$(cd "$hub" && pwd)"
fi

resolved_repos=()
for r in "${repos[@]+"${repos[@]}"}"; do
	if [[ ! -d "$r" ]]; then
		echo "init: --repo is not a directory: $r" >&2
		exit 1
	fi
	resolved_repos+=("$(cd "$r" && pwd)")
done

mkdir -p "$HOME/$CONFIG_DIR_REL"
{
	printf 'planning_workspace: '
	yaml_quote "$workspace"
	printf '\n'
} >"$config_file"

{
	printf 'merge_prs: false\n'
	if [[ "${#resolved_repos[@]}" -eq 0 ]]; then
		printf 'repos: []\n'
	else
		printf 'repos:\n'
		for r in "${resolved_repos[@]}"; do
			printf '  - '
			yaml_quote "$r"
			printf '\n'
		done
	fi
} >"$hub/superplan.yml"

printf 'init: workspace %s\n' "$workspace"
printf 'init: hub %s\n' "$hub"
printf 'init: wrote %s\n' "$config_file"
printf 'init: wrote %s/superplan.yml\n' "$hub"
