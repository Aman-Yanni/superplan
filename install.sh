#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PACK="$ROOT/skills"
MODE=symlink
want_claude=0
want_cursor=0
want_opencode=0
saw_agent=0

if [[ -t 1 ]]; then
	BOLD=$'\033[1m'
	DIM=$'\033[2m'
	RED=$'\033[31m'
	GRN=$'\033[32m'
	YEL=$'\033[33m'
	MAG=$'\033[35m'
	CYN=$'\033[36m'
	WHT=$'\033[37m'
	RST=$'\033[0m'
else
	BOLD=""
	DIM=""
	RED=""
	GRN=""
	YEL=""
	MAG=""
	CYN=""
	WHT=""
	RST=""
fi

die() {
	printf '%s\n' "${RED}${BOLD}✖${RST}   ${1}" >&2
	exit 1
}

usage() {
	cat <<EOF
${BOLD}Usage${RST}
  ${CYN}./install.sh${RST}              interactive agent select
  ${CYN}./install.sh${RST} ${YEL}claude${RST}       \$HOME/.claude/skills
  ${CYN}./install.sh${RST} ${YEL}cursor${RST}       \$HOME/.cursor/skills
  ${CYN}./install.sh${RST} ${YEL}opencode${RST}     \$HOME/.config/opencode/skills
  ${CYN}./install.sh${RST} ${YEL}all${RST}          Claude, Cursor, and OpenCode
  ${CYN}./install.sh${RST} ${YEL}--copy${RST}       copy instead of symlink
  ${CYN}./install.sh${RST} ${YEL}-h, --help${RST}

${BOLD}What it does${RST}
  Symlinks this repo's ${DIM}skills/<name>${RST} into Claude Code, Cursor, and/or
  OpenCode (DeepSeek and other OpenCode models) so ${MAG}/grill-me${RST} works
  in every workspace.

${BOLD}Then${RST}
  Restart the agent, open a planning hub, run ${MAG}/superplan-init${RST} if needed.
EOF
}

banner() {
	printf '\n'
	printf '%s\n' "${MAG}${BOLD}"
	cat <<'EOF'
 ____                              _
/ ___| _   _ _ __   ___ _ __ _ __ | | __ _ _ __
\___ \| | | | '_ \ / _ \ '__| '_ \| |/ _` | '_ \
 ___) | |_| | |_) |  __/ |  | |_) | | (_| | | | |
|____/ \__,_| .__/ \___|_|  | .__/|_|\__,_|_| |_|
            |_|             |_|
EOF
	printf '%s\n' "${RST}"
	printf '  %s\n' "${DIM}global skill pack  ·  Claude Code  ·  Cursor  ·  OpenCode  ·  data-only hubs${RST}"
	printf '\n'
}

agent_dest() {
	case "$1" in
	claude) printf '%s/.claude/skills' "$HOME" ;;
	cursor) printf '%s/.cursor/skills' "$HOME" ;;
	opencode) printf '%s/.config/opencode/skills' "$HOME" ;;
	*)
		die "unknown agent $1"
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
	printf '%s\n' "  ${BOLD}${WHT}Select agents${RST}"
	printf '\n'
	printf '%s\n' "  ${BOLD}1)${RST}  Claude Code    ${DIM}${HOME}/.claude/skills${RST}"
	printf '%s\n' "  ${BOLD}2)${RST}  Cursor         ${DIM}${HOME}/.cursor/skills${RST}"
	printf '%s\n' "  ${BOLD}3)${RST}  OpenCode       ${DIM}${HOME}/.config/opencode/skills${RST}  ${DIM}(DeepSeek)${RST}"
	printf '%s\n' "  ${BOLD}4)${RST}  All"
	printf '\n'
	printf '%s' "  ${CYN}›${RST}   Enter ${BOLD}1${RST}–${BOLD}4${RST} or claude/cursor/opencode/all: "
	local ans=""
	if ! IFS= read -r ans; then
		echo "install: no agent selected" >&2
		exit 2
	fi
	printf '\n'
	case "$ans" in
	1 | claude)
		want_claude=1
		;;
	2 | cursor)
		want_cursor=1
		;;
	3 | opencode | deepseek)
		want_opencode=1
		;;
	4 | all)
		want_claude=1
		want_cursor=1
		want_opencode=1
		;;
	both)
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

banner

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
	opencode | deepseek)
		want_opencode=1
		saw_agent=1
		;;
	all)
		want_claude=1
		want_cursor=1
		want_opencode=1
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
	die "missing skills dir: $PACK"
fi

shopt -s nullglob
names=()
for dir in "$PACK"/*/; do
	if [[ -f "${dir}SKILL.md" ]]; then
		names+=("$(basename "${dir%/}")")
	fi
done

if [[ "${#names[@]}" -eq 0 ]]; then
	die "no skills in $PACK"
fi

agents=()
if [[ "$want_claude" -eq 1 ]]; then
	agents+=("claude")
fi
if [[ "$want_cursor" -eq 1 ]]; then
	agents+=("cursor")
fi
if [[ "$want_opencode" -eq 1 ]]; then
	agents+=("opencode")
fi

printf '%s\n' "  ${BOLD}${WHT}📦  Pack${RST}    ${DIM}${PACK}${RST}"
printf '%s\n' "  ${BOLD}${WHT}🔗  Mode${RST}    ${WHT}${MODE}${RST}"
printf '%s\n' "  ${DIM}══════════════════════════════════════════════════════════${RST}"
printf '\n'

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
	local total="${#agents[@]}"
	local step=0
	local emoji
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
		step=$((step + 1))
		if [[ "$agent" == "claude" ]]; then
			emoji="🟠"
		elif [[ "$agent" == "cursor" ]]; then
			emoji="⬛"
		else
			emoji="🔷"
		fi
		printf '%s\n' "${GRN}${BOLD}✓${RST}   ${DIM}${step}/${total}${RST}  ${emoji}  ${BOLD}${agent}${RST}  ${DIM}· ${verb} ${#names[@]} skills${RST}"
	done
}

preflight
apply

printf '\n'
printf '%s\n' "  ${GRN}${BOLD}══════════════════════════════════════════════════════════${RST}"
printf '  %s  %s\n' "${GRN}${BOLD}✦${RST}" "${BOLD}${WHT}Superplan landed — skills are global${RST}"
printf '%s\n' "  ${GRN}${BOLD}══════════════════════════════════════════════════════════${RST}"
printf '\n'
printf '%s\n' "  ${BOLD}${WHT}🚀  Next steps${RST}"
printf '\n'
printf '%s\n' "  ${BOLD}${WHT}1️⃣${RST}   Restart Cursor, Claude Code, and OpenCode"
printf '    %s\n\n' "${DIM}Personal skills load at session start. OpenCode DeepSeek agents use ~/.config/opencode/skills.${RST}"
printf '%s\n' "  ${BOLD}${WHT}2️⃣${RST}   Open a planning hub (or run ${MAG}/superplan-init${RST})"
printf '    %s\n\n' "${DIM}Hubs are data-only. Skills stay in each agent's global skills dir.${RST}"
printf '%s\n' "  ${BOLD}${WHT}3️⃣${RST}   Type ${MAG}/grill-me${RST}"
printf '    %s\n\n' "${DIM}Edits in this git repo are live while the install is a symlink.${RST}"
