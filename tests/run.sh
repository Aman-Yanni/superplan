#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$ROOT/install.sh"
PACK="$ROOT/scripts/pack-check.sh"
INIT="$ROOT/skills/superplan-init/init.sh"

fails=0
fixtures=()

REAL_HOME="$HOME"
real_claude="$(ls -A "$REAL_HOME/.claude/skills" 2>/dev/null || true)"
real_cursor="$(ls -A "$REAL_HOME/.cursor/skills" 2>/dev/null || true)"
real_superplan="$(ls -A "$REAL_HOME/.superplan" 2>/dev/null || true)"

PACK_NAMES="audit-rules bootstrap-turboplan dialectic-of-cognition grill-me setup-tasks superplan-init task-1-plan task-2-execute task-3-complete"

cleanup() {
	local d
	if ((${#fixtures[@]} > 0)); then
		for d in "${fixtures[@]}"; do
			rm -rf "$d"
		done
	fi
}
trap cleanup EXIT

newtmp() {
	local d
	d="$(mktemp -d)"
	fixtures+=("$d")
	printf '%s' "$d"
}

ok() {
	printf 'ok %s\n' "$1"
}

not_ok() {
	printf 'not ok %s\n' "$1"
	fails=$((fails + 1))
}

run_cmd() {
	# Sets globals: run_code, run_out, run_err
	local outf errf
	outf="$(newtmp)/out"
	errf="$(newtmp)/err"
	run_code=0
	"$1" "${@:2}" >"$outf" 2>"$errf" || run_code=$?
	run_out="$(cat "$outf")"
	run_err="$(cat "$errf")"
}

run_cmd_in() {
	# $1 = stdin string; remaining args = command
	local outf errf
	outf="$(newtmp)/out"
	errf="$(newtmp)/err"
	run_code=0
	printf '%s' "$1" | "$2" "${@:3}" >"$outf" 2>"$errf" || run_code=$?
	run_out="$(cat "$outf")"
	run_err="$(cat "$errf")"
}

assert_nine_links() {
	local dest_root="$1"
	local label="$2"
	local n src dest
	for n in $PACK_NAMES; do
		dest="$dest_root/$n"
		src="$ROOT/skills/$n"
		if [[ -L "$dest" && "$(readlink "$dest")" == "$src" && -f "$dest/SKILL.md" ]]; then
			continue
		fi
		not_ok "$label missing link $n"
		return
	done
	if [[ -e "$dest_root/.gitkeep" ]]; then
		not_ok "$label installed .gitkeep"
		return
	fi
	ok "$label 9 symlinks"
}

run_cmd "$INSTALL" --help
if [[ "$run_code" -eq 0 && "$run_out" == *Usage* ]]; then
	ok "install.sh --help"
else
	not_ok "install.sh --help (code=$run_code)"
fi

run_cmd "$INSTALL" -h
if [[ "$run_code" -eq 0 && "$run_out" == *Usage* ]]; then
	ok "install.sh -h"
else
	not_ok "install.sh -h (code=$run_code)"
fi

run_cmd_in "" "$INSTALL"
if [[ "$run_code" -ne 0 && "$run_err" == *"no agent selected"* ]]; then
	ok "install.sh no-args empty stdin"
else
	not_ok "install.sh no-args (code=$run_code err=$run_err)"
fi

run_cmd "$INSTALL" nope
if [[ "$run_code" -eq 2 ]]; then
	ok "install.sh unknown arg exits 2"
else
	not_ok "install.sh unknown arg (code=$run_code)"
fi

fake_all="$(newtmp)"
HOME="$fake_all" run_cmd "$INSTALL" all
if [[ "$run_code" -eq 0 && "$run_out" == *symlink* ]]; then
	ok "install.sh all exits 0"
else
	not_ok "install.sh all (code=$run_code out=$run_out err=$run_err)"
fi
assert_nine_links "$fake_all/.claude/skills" "all claude"
assert_nine_links "$fake_all/.cursor/skills" "all cursor"

HOME="$fake_all" run_cmd "$INSTALL" all
if [[ "$run_code" -eq 0 ]]; then
	ok "install.sh all idempotent"
else
	not_ok "install.sh all idempotent (code=$run_code err=$run_err)"
fi

fake_copy="$(newtmp)"
HOME="$fake_copy" run_cmd "$INSTALL" --copy cursor
if [[ "$run_code" -eq 0 && ("$run_out" == *copy* || "$run_out" == *copied*) ]]; then
	ok "install.sh --copy cursor exits 0"
else
	not_ok "install.sh --copy cursor (code=$run_code out=$run_out err=$run_err)"
fi
if [[ ! -e "$fake_copy/.claude" ]]; then
	ok "--copy cursor does not create claude dest"
else
	not_ok "--copy cursor created claude dest"
fi
if [[ -d "$fake_copy/.cursor/skills/grill-me" && ! -L "$fake_copy/.cursor/skills/grill-me" && -f "$fake_copy/.cursor/skills/grill-me/SKILL.md" && "$(cat "$fake_copy/.cursor/skills/grill-me/.superplan-install")" == "$ROOT/skills/grill-me" ]]; then
	ok "--copy cursor grill-me is a marked copy"
else
	not_ok "--copy cursor grill-me not a marked copy"
fi

fake_foreign="$(newtmp)"
mkdir -p "$fake_foreign/.claude/skills/grill-me"
printf 'nope\n' >"$fake_foreign/.claude/skills/grill-me/FOREIGN"
HOME="$fake_foreign" run_cmd "$INSTALL" claude
if [[ "$run_code" -eq 1 && "$run_err" == *refusing* ]]; then
	ok "install.sh refuses foreign dest"
else
	not_ok "install.sh foreign (code=$run_code err=$run_err)"
fi
if [[ -f "$fake_foreign/.claude/skills/grill-me/FOREIGN" && "$(ls -A "$fake_foreign/.claude/skills")" == "grill-me" ]]; then
	ok "foreign dest left intact, no siblings"
else
	not_ok "foreign dest mutated"
fi

fake_int="$(newtmp)"
HOME="$fake_int" run_cmd_in $'3\n' "$INSTALL"
if [[ "$run_code" -eq 0 ]]; then
	ok "install.sh interactive 3 exits 0"
else
	not_ok "install.sh interactive 3 (code=$run_code err=$run_err)"
fi
assert_nine_links "$fake_int/.claude/skills" "interactive claude"
assert_nine_links "$fake_int/.cursor/skills" "interactive cursor"

if [[ "$(ls -A "$REAL_HOME/.claude/skills" 2>/dev/null || true)" == "$real_claude" ]]; then
	ok "real ~/.claude/skills unchanged"
else
	not_ok "real ~/.claude/skills changed"
fi
if [[ "$(ls -A "$REAL_HOME/.cursor/skills" 2>/dev/null || true)" == "$real_cursor" ]]; then
	ok "real ~/.cursor/skills unchanged"
else
	not_ok "real ~/.cursor/skills changed"
fi

readme="$ROOT/README.md"
readme_ok=1
while IFS= read -r needle; do
	if ! grep -q -F -- "$needle" "$readme"; then
		not_ok "README missing $needle"
		readme_ok=0
	fi
done <<'EOF'
./install.sh
npx skills add
--list
-g
-a claude-code
-a cursor
~/.cursor/skills
Uninstall
EOF
if [[ "$readme_ok" -eq 1 ]]; then
	ok "README documents install.sh and npx skills add"
fi

run_cmd "$INIT" --help
if [[ "$run_code" -eq 0 && "$run_out" == *Usage* ]]; then
	ok "init.sh --help"
else
	not_ok "init.sh --help (code=$run_code)"
fi

fake_init_home="$(newtmp)"
ws="$(newtmp)/Claude Plans"
repo1="$(newtmp)/app"
mkdir -p "$repo1/.git"
HOME="$fake_init_home" run_cmd "$INIT" --workspace "$ws" --create-workspace --hub Dummy --repo "$repo1"
if [[ "$run_code" -eq 0 && -f "$fake_init_home/.superplan/config.yml" && -f "$ws/Dummy/superplan.yml" ]]; then
	ok "init.sh creates workspace hub and config"
else
	not_ok "init.sh create (code=$run_code err=$run_err)"
fi
if grep -q 'planning_workspace:' "$fake_init_home/.superplan/config.yml" && grep -q 'hub:' "$fake_init_home/.superplan/config.yml" && grep -q 'merge_prs: false' "$ws/Dummy/superplan.yml" && grep -q "$repo1" "$ws/Dummy/superplan.yml"; then
	ok "init.sh yaml has workspace, hub, merge_prs false, repo"
else
	not_ok "init.sh yaml contents"
fi
if [[ -f "$ws/Dummy/CLAUDE.md" && -f "$ws/Dummy/AGENTS.md" && -f "$ws/Dummy/phases/INDEX.md" && -f "$ws/Dummy/rules/cross-repo.md" && -f "$ws/Dummy/.claude/settings.json" ]]; then
	ok "init.sh writes data-only hub templates"
else
	not_ok "init.sh missing hub templates"
fi
if [[ ! -e "$ws/Dummy/.claude/skills" && ! -e "$ws/Dummy/.cursor/skills" ]] && grep -q 'Repo rules come first' "$ws/Dummy/CLAUDE.md" && grep -q "$repo1" "$ws/Dummy/.claude/settings.json"; then
	ok "init.sh hub has no skill copies and lists the repo"
else
	not_ok "init.sh hub skills or additionalDirectories"
fi
printf 'keep-me\n' >"$ws/Dummy/rules/keep.md"
HOME="$fake_init_home" run_cmd "$INIT" --hub Dummy --repo "$repo1"
if [[ -f "$ws/Dummy/rules/keep.md" ]] && grep -q 'keep-me' "$ws/Dummy/rules/keep.md"; then
	ok "init.sh refresh preserves user rules"
else
	not_ok "init.sh wiped user rules"
fi

repo2="$(newtmp)/other"
mkdir -p "$repo2/.git"
HOME="$fake_init_home" run_cmd "$INIT" --hub Dummy --repo "$repo2"
if [[ "$run_code" -eq 0 ]] && grep -q "$repo2" "$ws/Dummy/superplan.yml" && ! grep -q "$repo1" "$ws/Dummy/superplan.yml"; then
	ok "init.sh reuse hub replaces repos from saved workspace"
else
	not_ok "init.sh reuse (code=$run_code err=$run_err)"
fi

missing_ws="$(newtmp)/no-such-ws"
HOME="$(newtmp)" run_cmd "$INIT" --workspace "$missing_ws" --hub Dummy
if [[ "$run_code" -eq 1 && ! -d "$missing_ws" ]]; then
	ok "init.sh missing workspace without create fails"
else
	not_ok "init.sh missing workspace (code=$run_code)"
fi

disc="$(newtmp)"
mkdir -p "$disc/keep/.git" "$disc/also/.git" "$disc/skip/notgit"
run_cmd "$INIT" --discover "$disc"
if [[ "$run_code" -eq 0 && "$run_out" == *"keep"* && "$run_out" == *"also"* && "$run_out" != *"skip"* ]]; then
	ok "init.sh --discover lists git children"
else
	not_ok "init.sh --discover (code=$run_code out=$run_out err=$run_err)"
fi

empty_repos_home="$(newtmp)"
empty_ws="$(newtmp)/ws"
HOME="$empty_repos_home" run_cmd "$INIT" --workspace "$empty_ws" --create-workspace --hub Dummy
if [[ "$run_code" -eq 0 ]] && grep -q 'repos: \[\]' "$empty_ws/Dummy/superplan.yml"; then
	ok "init.sh zero repos writes repos: []"
else
	not_ok "init.sh zero repos (code=$run_code err=$run_err)"
fi

if [[ "$(ls -A "$REAL_HOME/.superplan" 2>/dev/null || true)" == "$real_superplan" ]]; then
	ok "real ~/.superplan unchanged"
else
	not_ok "real ~/.superplan changed"
fi

empty="$(newtmp)"
run_cmd "$PACK" "$empty"
if [[ "$run_code" -eq 0 ]]; then
	ok "pack-check empty dir"
else
	not_ok "pack-check empty dir (code=$run_code err=$run_err)"
fi

broken="$(newtmp)"
mkdir "$broken/foo"
run_cmd "$PACK" "$broken"
if [[ "$run_code" -ne 0 ]]; then
	ok "pack-check missing SKILL.md fails"
else
	not_ok "pack-check missing SKILL.md unexpectedly passed"
fi

good="$(newtmp)"
mkdir "$good/foo"
cat >"$good/foo/SKILL.md" <<'EOF'
---
name: foo
description: test fixture
---
# foo
EOF
run_cmd "$PACK" "$good"
if [[ "$run_code" -eq 0 ]]; then
	ok "pack-check with SKILL.md"
else
	not_ok "pack-check with SKILL.md (code=$run_code err=$run_err)"
fi

mismatch="$(newtmp)"
mkdir "$mismatch/foo"
cat >"$mismatch/foo/SKILL.md" <<'EOF'
---
name: bar
description: mismatch
---
# bar
EOF
run_cmd "$PACK" "$mismatch"
if [[ "$run_code" -ne 0 ]]; then
	ok "pack-check name mismatch fails"
else
	not_ok "pack-check name mismatch unexpectedly passed"
fi

noname="$(newtmp)"
mkdir "$noname/foo"
printf '# stub\n' >"$noname/foo/SKILL.md"
run_cmd "$PACK" "$noname"
if [[ "$run_code" -ne 0 ]]; then
	ok "pack-check missing name: fails"
else
	not_ok "pack-check missing name: unexpectedly passed"
fi

run_cmd "$PACK"
if [[ "$run_code" -eq 0 && "$run_out" == *"9 skill(s)"* ]]; then
	ok "pack-check repo skills/"
else
	not_ok "pack-check repo skills/ (code=$run_code out=$run_out err=$run_err)"
fi

got="$(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | paste -sd' ' -)"
exp_sorted="audit-rules bootstrap-turboplan dialectic-of-cognition grill-me setup-tasks superplan-init task-1-plan task-2-execute task-3-complete"
if [[ "$got" == "$exp_sorted" ]]; then
	ok "repo has exactly 9 pack skill dirs"
else
	not_ok "repo pack dirs mismatch (got=$got)"
fi

hubres="$ROOT/skills/grill-me/references/hub-resolution.md"
if [[ -f "$hubres" ]]; then
	hub_ok=1
	for s in audit-rules bootstrap-turboplan dialectic-of-cognition grill-me setup-tasks task-1-plan task-2-execute task-3-complete; do
		f="$ROOT/skills/$s/references/hub-resolution.md"
		if [[ ! -f "$f" ]] || ! cmp -s "$hubres" "$f"; then
			not_ok "hub-resolution missing or differs in $s"
			hub_ok=0
		fi
	done
	if [[ "$hub_ok" -eq 1 ]]; then
		ok "pack skills share hub-resolution.md"
	fi
else
	not_ok "grill-me hub-resolution.md missing"
fi

if [[ "$fails" -ne 0 ]]; then
	printf '%s test(s) failed\n' "$fails" >&2
	exit 1
fi
