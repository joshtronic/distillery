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

skill_with_desc() { # root name description
  mkdir -p "$1/skills/$2"
  cat > "$1/skills/$2/SKILL.md" <<EOF
---
name: $2
description: $3
consumers: generic
source: test
extracted: 2026-08-10
---

Body content.
EOF
}

skill_with_verify() { # root name verify_cmd
  mkdir -p "$1/skills/$2"
  cat > "$1/skills/$2/SKILL.md" <<EOF
---
name: $2
description: a valid test skill
consumers: generic
source: test
extracted: 2026-08-10
verify: $3
---

Body content.
EOF
}

readme_with_markers() { # root
  cat > "$1/README.md" <<'EOF'
# test repo

## The shelf

<!-- shelf:start -->
<!-- shelf:end -->
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

echo "== still index: renders frontmatter verbatim, including em dash and colon descriptions =="
R=$(sandbox); readme_with_markers "$R"
skill_with_desc "$R" alpha "uses an em dash — right here"
skill_with_desc "$R" beta "uses a colon: right here"
"$R/bin/still" index >/dev/null 2>&1 && ok || bad "index failed on a valid tree"
grep -qF -- '- **alpha** — uses an em dash — right here' "$R/README.md" && ok || bad "em dash description not rendered verbatim"
grep -qF -- '- **beta** — uses a colon: right here' "$R/README.md" && ok || bad "colon description not rendered verbatim"
rm -rf "$R"

echo "== still index --check: exits 0 when current, nonzero when the listing has drifted =="
R=$(sandbox); readme_with_markers "$R"; good_skill "$R" alpha; good_skill "$R" beta
"$R/bin/still" index >/dev/null 2>&1
"$R/bin/still" index --check >/dev/null 2>&1 && ok || bad "--check failed on a current listing"
# a skill added since the listing was last generated
good_skill "$R" gamma
"$R/bin/still" index --check >/dev/null 2>&1 && bad "--check passed with an added skill" || ok
rm -rf "$R/skills/gamma"
"$R/bin/still" index --check >/dev/null 2>&1 && ok || bad "--check failed after the added skill was reverted"
# a skill removed since the listing was last generated
rm -rf "$R/skills/beta"
"$R/bin/still" index --check >/dev/null 2>&1 && bad "--check passed with a removed skill" || ok
good_skill "$R" beta
"$R/bin/still" index >/dev/null 2>&1
# a skill's description edited since the listing was last generated
sed -i 's/^description:.*/description: a changed test skill/' "$R/skills/alpha/SKILL.md"
"$R/bin/still" index --check >/dev/null 2>&1 && bad "--check passed with a changed description" || ok
rm -rf "$R"

echo "== still index: a missing or unpaired marker pair is a hard failure =="
R=$(sandbox); good_skill "$R" alpha
"$R/bin/still" index >/dev/null 2>&1 && bad "index succeeded with no README.md" || ok
"$R/bin/still" index --check >/dev/null 2>&1 && bad "--check succeeded with no README.md" || ok
printf '# t\n\n<!-- shelf:start -->\n' > "$R/README.md"
"$R/bin/still" index >/dev/null 2>&1 && bad "index succeeded with an unpaired start marker" || ok
printf '# t\n\n<!-- shelf:end -->\n' > "$R/README.md"
"$R/bin/still" index >/dev/null 2>&1 && bad "index succeeded with an unpaired end marker" || ok
printf '# t\n\n<!-- shelf:end -->\n<!-- shelf:start -->\n' > "$R/README.md"
"$R/bin/still" index >/dev/null 2>&1 && bad "index succeeded with markers out of order" || ok
printf '# t\n\n<!-- shelf:start -->\n<!-- shelf:start -->\n<!-- shelf:end -->\n' > "$R/README.md"
"$R/bin/still" index >/dev/null 2>&1 && bad "index succeeded with duplicate start markers" || ok
rm -rf "$R"

echo "== still build: writes dist/index.md listing every validated skill =="
R=$(sandbox); good_skill "$R" alpha; good_skill "$R" beta
"$R/bin/still" build >/dev/null 2>&1 && ok || bad "build failed on a valid tree"
[ -f "$R/dist/index.md" ] && ok || bad "build did not write dist/index.md"
grep -qF -- '[alpha](skills/alpha/SKILL.md) — a valid test skill' "$R/dist/index.md" && ok || bad "dist/index.md missing the alpha entry"
grep -qF -- '[beta](skills/beta/SKILL.md) — a valid test skill' "$R/dist/index.md" && ok || bad "dist/index.md missing the beta entry"
rm -rf "$R"

echo "== still verify: a passing verify: command reports VERIFIED =="
R=$(sandbox); skill_with_verify "$R" alpha "true"
"$R/bin/still" verify >/dev/null 2>&1 && ok || bad "a passing verify: command failed the run"
out=$("$R/bin/still" verify 2>&1 || true)
grep -q "alpha: VERIFIED" <<<"$out" && ok || bad "a passing verify: command did not report VERIFIED"
rm -rf "$R"

echo "== still verify: a failing verify: command reports FAILED and the run exits 1 =="
R=$(sandbox); skill_with_verify "$R" beta "false"
"$R/bin/still" verify >/dev/null 2>&1 && bad "a failing verify: command did not fail the run" || ok
out=$("$R/bin/still" verify 2>&1 || true)
grep -q "beta: FAILED" <<<"$out" && ok || bad "a failing verify: command did not report FAILED"
rm -rf "$R"

echo "== still verify: no verify: reports UNVERIFIED and does not fail the run =="
R=$(sandbox); good_skill "$R" gamma
"$R/bin/still" verify >/dev/null 2>&1 && ok || bad "a missing verify: key failed the run (should be UNVERIFIED, not fatal)"
out=$("$R/bin/still" verify 2>&1 || true)
grep -q "gamma: UNVERIFIED" <<<"$out" && ok || bad "a missing verify: key did not report UNVERIFIED"
rm -rf "$R"

echo "== still verify: summary line reports verified/unverified/failed counts =="
R=$(sandbox); skill_with_verify "$R" alpha "true"; skill_with_verify "$R" beta "false"; good_skill "$R" gamma
out=$("$R/bin/still" verify 2>&1 || true)
grep -q "1 verified, 1 unverified, 1 failed" <<<"$out" && ok || bad "summary line missing or wrong counts"
rm -rf "$R"

echo "== a verify: key does not break still validate (optional key, not unknown key) =="
R=$(sandbox); skill_with_verify "$R" alpha "true"
"$R/bin/still" validate >/dev/null 2>&1 && ok || bad "a verify: key was rejected as an unknown frontmatter key"
rm -rf "$R"

echo "== still verify negative test: sever the verify execution and the failing skill wrongly reports VERIFIED =="
R=$(sandbox); skill_with_verify "$R" failer "false"
sed -i 's/bash -c "\$cmd"/true/' "$R/bin/still"
"$R/bin/still" verify >/dev/null 2>&1 && ok || bad "severing verify execution wrongly failed the run"
out=$("$R/bin/still" verify 2>&1 || true)
grep -q "failer: VERIFIED" <<<"$out" && ok || bad "severing verify execution did not wrongly pass the failing skill -- the gate isn't what's catching it"
rm -rf "$R"

echo "== the real tree validates =="
"$STILL" validate >/dev/null 2>&1 && ok || bad "the repo's own skills tree does not validate"

echo "== the real tree's verify run exits 0 (no verify: commands adopted yet -- honestly all UNVERIFIED) =="
"$STILL" verify >/dev/null 2>&1 && ok || bad "the repo's own skills tree fails still verify"

echo "== the real tree's shelf listing is current =="
"$STILL" index --check >/dev/null 2>&1 && ok || bad "the repo's own README shelf listing is stale -- run 'bin/still index'"

echo "test-still: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
