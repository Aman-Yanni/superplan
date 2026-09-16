#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$ROOT/install.sh"
PACK="$ROOT/scripts/pack-check.sh"

fails=0
fixtures=()

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

run_cmd "$INSTALL"
if [[ "$run_code" -eq 2 && "$run_err" == *"not implemented"* ]]; then
	ok "install.sh no-args exits 2"
else
	not_ok "install.sh no-args (code=$run_code err=$run_err)"
fi

run_cmd "$INSTALL" all
if [[ "$run_code" -eq 2 && "$run_err" == *"not implemented"* ]]; then
	ok "install.sh all exits 2"
else
	not_ok "install.sh all (code=$run_code err=$run_err)"
fi

fake_home="$(newtmp)"
HOME="$fake_home" run_cmd "$INSTALL" --help
HOME="$fake_home" run_cmd "$INSTALL" all
if [[ ! -e "$fake_home/.claude" && ! -e "$fake_home/.cursor" ]]; then
	ok "install.sh does not create agent dirs under fake HOME"
else
	not_ok "install.sh wrote under fake HOME"
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

if [[ "$fails" -ne 0 ]]; then
	printf '%s test(s) failed\n' "$fails" >&2
	exit 1
fi
