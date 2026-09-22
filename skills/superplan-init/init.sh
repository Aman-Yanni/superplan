#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  init.sh --hub NAME_OR_PATH [--workspace PATH] [--create-workspace] [--repo PATH ...]
  init.sh --discover PATH
  init.sh -h, --help

  With no --hub, uses cwd (or an ancestor) when it contains superplan.yml.

  --hub NAME_OR_PATH   hub directory, or a folder name under --workspace / cwd
  --workspace PATH     optional parent for a bare --hub name
  --create-workspace   create --workspace if missing
  --repo PATH          bound product repo (repeatable); must exist
  --discover PATH      list git dirs (PATH and its immediate children); no writes
EOF
}

find_hub_up() {
	local d
	d="$(cd "${1:-.}" && pwd)" || return 1
	while [[ -n "$d" ]]; do
		if [[ -f "$d/superplan.yml" ]]; then
			printf '%s' "$d"
			return 0
		fi
		if [[ "$d" == / ]]; then
			return 1
		fi
		d="$(dirname "$d")"
	done
	return 1
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

json_quote() {
	local s=$1
	s=${s//\\/\\\\}
	s=${s//\"/\\\"}
	printf '"%s"' "$s"
}

copy_if_missing() {
	local src=$1 dest=$2
	if [[ ! -e "$dest" ]]; then
		mkdir -p "$(dirname "$dest")"
		cp "$src" "$dest"
	fi
}

context_sources() {
	local r=$1
	local bits=""
	if [[ -f "$r/CLAUDE.md" ]]; then
		bits="\`CLAUDE.md\`"
	fi
	if [[ -f "$r/AGENTS.md" ]]; then
		if [[ -n "$bits" ]]; then
			bits="$bits; \`AGENTS.md\`"
		else
			bits="\`AGENTS.md\`"
		fi
	fi
	if [[ -z "$bits" ]]; then
		printf 'none established'
	else
		printf '%s' "$bits"
	fi
}

write_hub_files() {
	local pack_root tpl hub_name table routing gates name r out
	pack_root="$(cd "$(dirname "$0")/../.." && pwd)"
	tpl="$pack_root/templates/hub"
	if [[ ! -d "$tpl" ]]; then
		echo "init: missing templates at $tpl" >&2
		exit 1
	fi
	hub_name="$(basename "$hub")"
	mkdir -p "$hub/rules" "$hub/phases" "$hub/templates" "$hub/.claude"
	copy_if_missing "$tpl/rules/cross-repo.md" "$hub/rules/cross-repo.md"
	copy_if_missing "$tpl/templates/task.md" "$hub/templates/task.md"
	copy_if_missing "$tpl/templates/rule-spoke.md" "$hub/templates/rule-spoke.md"
	copy_if_missing "$tpl/CURSOR.md" "$hub/CURSOR.md"
	table=""
	routing=""
	gates=""
	if [[ "${#resolved_repos[@]}" -eq 0 ]]; then
		table='| — | — | none established | none established |'
		gates='none established'
	else
		for r in "${resolved_repos[@]}"; do
			name="$(basename "$r")"
			table+="| ${name} | \`${r}\` | $(context_sources "$r") | none established |"
			table+=$'\n'
			routing+="| \`${name}\` | \`rules/${name}.md\` |"
			routing+=$'\n'
			gates+="**${name}** — none established"
			gates+=$'\n\n'
			copy_if_missing "$tpl/rules/repo.md" "$hub/rules/${name}.md"
		done
	fi
	out="$(cat "$tpl/CLAUDE.md")"
	out="${out//@@HUB_NAME@@/$hub_name}"
	out="${out//@@REPOS_TABLE@@/$table}"
	out="${out//@@ROUTING_ROWS@@/$routing}"
	out="${out//@@VERIFY_GATES@@/$gates}"
	printf '%s' "$out" >"$hub/CLAUDE.md"
	out="$(cat "$tpl/AGENTS.md")"
	out="${out//@@HUB_NAME@@/$hub_name}"
	printf '%s' "$out" >"$hub/AGENTS.md"
	if [[ ! -e "$hub/phases/INDEX.md" ]]; then
		out="$(cat "$tpl/phases/INDEX.md")"
		out="${out//@@HUB_NAME@@/$hub_name}"
		printf '%s' "$out" >"$hub/phases/INDEX.md"
	fi
	{
		printf '{\n  "permissions": {\n    "additionalDirectories": ['
		local first=1
		for r in "${resolved_repos[@]+"${resolved_repos[@]}"}"; do
			if [[ "$first" -eq 1 ]]; then
				first=0
				printf '\n      '
			else
				printf ',\n      '
			fi
			json_quote "$r"
		done
		if [[ "$first" -eq 0 ]]; then
			printf '\n    '
		fi
		printf ']\n  }\n}\n'
	} >"$hub/.claude/settings.json"
}

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

hub=""
if [[ -z "$hub_arg" ]]; then
	if hub="$(find_hub_up .)"; then
		:
	else
		echo "init: --hub is required (cwd has no superplan.yml)" >&2
		exit 2
	fi
fi

if [[ -n "$hub_arg" ]]; then
	if [[ -n "$workspace" ]]; then
		if [[ ! -d "$workspace" ]]; then
			if [[ "$create_ws" -eq 1 ]]; then
				mkdir -p "$workspace"
			else
				echo "init: workspace does not exist (pass --create-workspace): $workspace" >&2
				exit 1
			fi
		fi
		workspace="$(cd "$workspace" && pwd)"
	fi
	if [[ "$hub_arg" == /* || "$hub_arg" == */* ]]; then
		mkdir -p "$hub_arg"
		hub="$(cd "$hub_arg" && pwd)"
	elif [[ -n "$workspace" ]]; then
		hub="$workspace/$hub_arg"
		mkdir -p "$hub"
		hub="$(cd "$hub" && pwd)"
	else
		mkdir -p "$hub_arg"
		hub="$(cd "$hub_arg" && pwd)"
	fi
fi

resolved_repos=()
for r in "${repos[@]+"${repos[@]}"}"; do
	if [[ ! -d "$r" ]]; then
		echo "init: --repo is not a directory: $r" >&2
		exit 1
	fi
	resolved_repos+=("$(cd "$r" && pwd)")
done

write_superplan_yml=1
if [[ -f "$hub/superplan.yml" && ${#repos[@]} -eq 0 ]]; then
	write_superplan_yml=0
fi
if [[ "$write_superplan_yml" -eq 1 ]]; then
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
else
	resolved_repos=()
	while IFS= read -r line; do
		case "$line" in
		'  - "'*)
			line="${line#  - \"}"
			line="${line%\"}"
			resolved_repos+=("$line")
			;;
		esac
	done <"$hub/superplan.yml"
fi

write_hub_files

if [[ -n "$workspace" ]]; then
	printf 'init: workspace %s\n' "$workspace"
fi
printf 'init: hub %s\n' "$hub"
printf 'init: wrote %s/superplan.yml\n' "$hub"
