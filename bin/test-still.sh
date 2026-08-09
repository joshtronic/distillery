#!/usr/bin/env bash
# bin/test-still.sh -- unit tests for bin/still, doctrine-style: every
# validation rule is exercised by deliberately breaking it (a validator that
# has never failed has never been tested).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
STILL="$HERE/still"
PASS=0; FAIL=0

ok()   { PASS=$((PASS+1)); }
bad()  { FAIL=$((FAIL+1)); echo "FAIL: $*" >&2; }

# sandbox <name> -- create a throwaway distillery root and echo its path.
sandbox() {
  local d; d=$(mktemp -d)
  mkdir -p "$d/skills" "$d/bin"
  cp "$STILL" "$d/bin/still"
  echo "$d"
}

good_skill() { # root name
  mkdir -p "$1/skills/$2"
  cat > "$1/skills/$2/SKILL.md" <<EOF
---
name: $2
description: a valid test skill
consumers: generic
source: test
extracted: 2026-08-10
---

Body content.
EOF
}

echo "== happy path: valid skill passes, builds a manifest =="
R=$(sandbox); good_skill "$R" alpha; good_skill "$R" beta
"$R/bin/still" validate >/dev/null 2>&1 && ok || bad "valid skills rejected"
"$R/bin/still" build >/dev/null 2>&1 && ok || bad "build failed on valid skills"
[ "$(jq '.skills | length' "$R/dist/manifest.json")" = "2" ] && ok || bad "manifest skill count wrong"
jq -e '.skills[] | select(.name=="alpha") | .sha256 | length == 64' "$R/dist/manifest.json" >/dev/null && ok || bad "manifest missing sha256"
rm -rf "$R"

echo "== each rule, deliberately broken =="
# missing SKILL.md
R=$(sandbox); mkdir -p "$R/skills/empty"
"$R/bin/still" validate >/dev/null 2>&1 && bad "missing SKILL.md accepted" || ok
rm -rf "$R"
# no frontmatter
R=$(sandbox); mkdir -p "$R/skills/nofm"; echo "just prose" > "$R/skills/nofm/SKILL.md"
"$R/bin/still" validate >/dev/null 2>&1 && bad "missing frontmatter accepted" || ok
rm -rf "$R"
# name != directory
R=$(sandbox); good_skill "$R" gamma
sed -i 's/^name: gamma/name: delta/' "$R/skills/gamma/SKILL.md"
"$R/bin/still" validate >/dev/null 2>&1 && bad "name/dir mismatch accepted" || ok
rm -rf "$R"
# unknown consumer
R=$(sandbox); good_skill "$R" gamma
sed -i 's/^consumers: generic/consumers: marsrover/' "$R/skills/gamma/SKILL.md"
"$R/bin/still" validate >/dev/null 2>&1 && bad "unknown consumer accepted" || ok
rm -rf "$R"
# unknown frontmatter key
R=$(sandbox); good_skill "$R" gamma
sed -i '/^source:/a version: 3' "$R/skills/gamma/SKILL.md"
"$R/bin/still" validate >/dev/null 2>&1 && bad "unknown frontmatter key accepted" || ok
rm -rf "$R"
# empty description
R=$(sandbox); good_skill "$R" gamma
sed -i 's/^description:.*/description:/' "$R/skills/gamma/SKILL.md"
"$R/bin/still" validate >/dev/null 2>&1 && bad "empty description accepted" || ok
rm -rf "$R"
# empty body
R=$(sandbox); good_skill "$R" gamma
awk '/^---$/{c++} c<2 || /^---$/' "$R/skills/gamma/SKILL.md" > "$R/skills/gamma/SKILL.md.tmp" \
  && mv "$R/skills/gamma/SKILL.md.tmp" "$R/skills/gamma/SKILL.md"
"$R/bin/still" validate >/dev/null 2>&1 && bad "empty body accepted" || ok
rm -rf "$R"
# build refuses to ship an invalid tree
R=$(sandbox); good_skill "$R" gamma; mkdir -p "$R/skills/broken"
"$R/bin/still" build >/dev/null 2>&1 && bad "build shipped an invalid tree" || ok
[ ! -f "$R/dist/manifest.json" ] && ok || bad "build wrote a manifest despite invalid tree"
rm -rf "$R"

echo "== the real tree validates =="
"$STILL" validate >/dev/null 2>&1 && ok || bad "the repo's own skills tree does not validate"

echo "test-still: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
