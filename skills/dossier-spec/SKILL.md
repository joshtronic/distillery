---
name: dossier-spec
description: The dossier's declared-shape vocabulary -- AGENTS.md structure, the Metadata key contract (url, automerge.require_human, automerge.maintenance, landed.kind), and the two invariants (explicit opt-in with fail-fast on partial declarations; no unattended edits to the dossier itself)
consumers: generic
source: docs/agents-md-spec.md + lib/automerge.sh, lib/landed.sh (igor)
extracted: 2026-08-18
---

# AGENTS.md dossier spec

Every fleet repo carries exactly one context file: `AGENTS.md`, at the
repo root. It is the project's dossier -- what the project is, what
winning looks like, and the decided policy around it -- plus a small
machine-readable block the harness parses. It replaces `CLAUDE.md`,
`agent.json`, and `CEO.md`; converted repos delete all three.

The format follows the [AGENTS.md standard](https://agents.md/): plain
markdown, prose for agents to read. This spec constrains it further so
the file is also parseable, checkable, and uniform across the fleet.
Validation enforces this spec; a repo whose dossier doesn't conform
fails validation and drops out of the work pool, loudly.

Beyond its own prose structure, the dossier is the harness's entire
vocabulary for a repo's *shape* -- the declared facts that drive merge
and post-merge verification behavior without the harness special-casing
a repo by name. Four keys make up that declared vocabulary: `url`,
`automerge.require_human`, `automerge.maintenance`, `landed.kind`. That
is the spec-level shape -- which of them the harness already reads, and
which are still hardcoded on its side, is the migration note near the
end. Every one lives in the `## Metadata` block below, under the same
two rules (see Declaration invariants): required-and-explicit on opt-in,
and never editable through an unattended merge.

## Design principles

- **Thin by intent.** The dossier holds only what is true about THIS
  project. Generic craft (how to be a good unattended worker, PR
  discipline, TDD) lives in the harness's `AGENTS.md` system-prompt
  contract, not per repo. Coding standards are the linters' job
  (`lint:` in Metadata), and idiom is the codebase's job -- agents
  match surrounding code. Per-repo prose earns its place only when it
  is about this repo.
- **Durable truth only.** No status, no roadmap, no "current
  priorities." That is what the issue tracker is for. A dossier that
  narrates state starts rotting the day it merges, and rot in a
  context file is worse than absence because agents trust it.
- **Written for amnesia.** The reader is an agent with no memory of
  any prior conversation. Every fact it needs to avoid a category
  error ("this is not a content site") must be in the file.

## Required structure

Sections appear in exactly this order. Headings are exact strings;
validation matches them literally.

1. **H1 + description** (required). The H1 is the project's canonical
   name: the `url` host for sites (`# porksicle.com`), the repo name
   otherwise (`# igor`). A site served from a subdomain uses that
   subdomain; the validation rule below is the definition. The
   paragraph(s) under it must answer two questions: what this project
   is, and who it is for.
2. **`## KPIs`** (required). Either an ordered list -- priority
   order, top entry matters most -- or the literal `(none yet)` as
   the section's entire content, which is honest and valid. An empty
   section is not. Each list entry names its measurement source (a
   GA4 event, a GSC metric, a spreadsheet) after a separator: `--`,
   an em/en dash, or a comma. A KPI with no measurement source is a
   vibe and does not go in the list.
3. **`## DOs and DON'Ts`** (optional). Decided policy, both
   directions, as two bulleted groups or one mixed list. Entries are
   rulings, ideally with a one-clause why: "DON'T build a real-money
   gambling funnel -- ruled out for AdSense/legal/audience." This is
   where a retired `CEO.md` mandate's guardrails and decision
   guidance land. Its value is preventing an amnesiac agent from
   re-litigating what was already decided.
4. **`## Caveats`** (optional). Landmines and gotchas: "the site is
   generated -- edit the generator, never run the build locally."
   Caveats are warnings; policy belongs in DOs and DON'Ts.
5. **`## Metadata`** (required, always LAST). Exactly one fenced code
   block containing flat YAML. Nothing may follow this section.

## The Metadata block

Validation enforces exactly one fenced code block in this section, so
the harness can simply take the first one after the literal heading
`## Metadata` and never encounter a second. Rules:

- Flat `key: value` scalars only. No nesting, no lists, no multiline
  values. The parser is grep/awk, not a YAML library; flatness is
  what keeps it that way. (The block is still valid YAML, so real
  tooling can consume it later without migration.)
- Keys come from the closed vocabulary below. Unknown keys fail
  validation -- extending the vocabulary is a PR to this spec.

| Key | Required | Meaning |
| --- | --- | --- |
| `type` | yes | One of the closed type list below |
| `url` | sites | Canonical live URL; enables auto-merge + deploy barrier (was `agent.json` `.smoke.url`); host must match the H1 |
| `automerge.require_human` | no | Pins the repo to the human-approval merge gate instead of the shadow-review APPROVE default (was `agent.json` `.automerge.require_human`); a url-less repo is already human-gated unconditionally regardless of this flag, so declare it there only as the prerequisite for `automerge.maintenance`, never as decoration |
| `automerge.maintenance` | no | Marks a `require_human` repo eligible for the maintenance-tier carve-out: an affirmative shadow APPROVE with no live human REQUEST_CHANGES may still merge a narrow, data-only diff without waiting on a human; meaningless without `automerge.require_human: true` alongside it (see Declaration invariants) |
| `landed.kind` | no | For a url-less repo, which host-state check verifies a merge actually landed: `igor` (self-pull HEAD check) or `distillery` (served-cache generation-marker check); mutually exclusive with `url` (see Declaration invariants) |
| `test` | see note | Command that runs the test suite |
| `lint` | no | Command that runs the linter(s) |
| `verify` | no | Command for end-to-end/visual verification (e.g. a Playwright script) |
| `feedback-csv` | no | Published CSV of user feedback for the triage pass (was `agent.json` `.feedback.csv`) |

Note on `test`: validation's existing test-signal rules apply
unchanged -- a repo needs a test signal (a `test:` command or a live
`url` acting as a smoke check) to validate for work.

`type` closed list: `arcade`, `game`, `content`, `tool`, `api`,
`personal`, `infra`. Of these, the **site types** -- the ones that
serve a live domain and therefore require `url` -- are `arcade`,
`game`, `content`, `api`, and `personal`; `tool` and `infra` are not
site types and take no `url`. The type drives harness behavior
(which digest treatment a site gets, what a measurement-gap check
expects), so a new value is a harness change, shipped together with
it.

`automerge.require_human` and `automerge.maintenance` are read by the
merge gate; `landed.kind` by the post-merge host-state watch. Together
with `url` they are the harness's entire declared vocabulary for a
repo's merge shape. `landed.kind`'s closed vocabulary is exactly
`igor` and `distillery` -- the two url-less repos the watch knows how
to verify because they ARE the harness and this brain; no other
url-less repo has a host-state check to attach to, declared or not.

## Declaration invariants

Two rules hold across every key in this vocabulary, not just the four
above -- a key added later inherits them too:

1. **Required-and-explicit on opt-in; no defaults, fail-fast on
   partial.** A repo gets none of a behavior's mechanism until it
   explicitly declares every key that behavior needs. There is no
   silent inference from absence, and there is no partial credit:
   `automerge.maintenance: true` without `automerge.require_human:
   true` alongside it is not "maintenance tier with the human gate
   implied" -- the maintenance carve-out exists only to loosen a
   `require_human` pin, so declaring the loosening without the pin is
   an incoherent declaration and validation fails it, loudly, rather
   than guessing what the author meant. The rule keys on the key being
   present at all, not on its value: `automerge.maintenance: false`
   without the pin fails the same way, because the carve-out it opts
   out of does not exist on that repo either. A repo that wants no
   maintenance tier omits the key. Likewise `landed.kind` on a
   repo that also declares `url` is a contradictory declaration -- the
   landed watch exists only for repos with no live URL to smoke-check
   instead -- and fails validation rather than one key silently
   winning over the other.
2. **Dossier files are never editable through any unattended merge
   path.** `AGENTS.md` (and, during the migration window, `agent.json`)
   sits on the shadow-only auto-merge path's risk-gate deny-list: a
   diff touching either can never merge via the no-human-in-the-loop
   path, full stop. A human-approved merge is not gated there (a human
   already saw the diff), so a human can still edit the dossier; what
   can never happen is a repo -- or an agent working in it -- extending
   its own privileges (setting `automerge.require_human: false` on
   itself, say) and having that PR ship unattended. The repo reads the
   privileges the dossier grants it; it never grants them to itself.

## Validation contract

`validate-repo` asserts, loudly and fail-fast, against the ROOT
dossier only (nested dossiers are exempt from structural checks --
see below):

- Required sections present, in spec order, exact heading strings.
- `## Metadata` is the last section and contains exactly one fenced
  block; the block parses as flat `key: value` lines.
- All keys are in the vocabulary; required keys present (`type`
  always; `url` for site types).
- For site types, the H1 equals the `url` host, with a leading
  `www.` stripped from the host before comparison.
- Each `## KPIs` entry carries a measurement source, or the section
  is exactly `(none yet)`.
- Nested `AGENTS.md` files contain no `## Metadata` section (the
  root dossier is the only machine-readable one).
- `automerge.maintenance` is present only alongside
  `automerge.require_human: true` (Declaration invariant 1).
- `landed.kind` is present only on a repo with no `url` key, and its
  value is one of the closed set the watch recognizes (`igor`,
  `distillery`) (Declaration invariant 1).

Those last two bullets are target state, not current behavior.
`automerge.maintenance` and `landed.kind` have no consumer yet (see
Authoring and migration), so no validator rejects a bad declaration of
either today; the checks land with the harness-side wiring that reads
the keys, in the same change. Don't read them as a validator you can
lean on right now.

**Un-adopted vs nonconforming -- the migration gate:** a repo that
has not adopted this spec validates under the legacy rules
(`CLAUDE.md` + `agent.json`) for the duration of the migration
window -- non-adoption is not failure while the fleet converts. The
gate keys on the `## Metadata` heading, not on the file existing: a
root `AGENTS.md` is the near-universal prose convention and predates
this spec, so a root file carrying no `## Metadata` is an ordinary
prose AGENTS.md and takes the legacy path, exactly as an absent one
does. A file that DECLARES itself a dossier by carrying `##
Metadata` is validated in full, and nonconformance is a hard
validation failure immediately: a broken dossier is worse than none,
because agents trust it. Once the fleet is converted the legacy path
is removed and non-adoption itself becomes the failure.

**When "once the fleet is converted" is true:** when no repo in
`VALIDATED_REPOS_JSON` still takes the legacy path -- every validated
repo has a root `AGENTS.md` carrying a `## Metadata` block. That is
mechanically checkable, so it does not depend on anyone remembering.
The PR that converts the LAST repo is the one that deletes the
fallback and flips non-adoption to a failure; a fallback still
standing after that PR is live debt and gets a ticket, not another
migration window.

## Nested dossiers

Per the AGENTS.md standard, nested files are allowed and the nearest
file wins. A monorepo-ish site (porksicle's per-game directories) may
give each subproject its own small `AGENTS.md` (lore, mechanics, that
game's verify script) under the root dossier's general one. Only the
ROOT dossier carries `## Metadata`; nested files are prose only.

## Authoring and migration

Dossiers are authored by the onboarding wizard (`bin/onboard.sh`,
planned): it scans the repo for what is inferable (stack, test
command, CI, live domain), interviews the operator for what is not
(type, KPIs, rulings), and emits a conforming file. Hand-authoring is
fine too; validation is the gate either way.

Migration order per repo: wizard emits `AGENTS.md`; content worth
keeping from `CLAUDE.md` moves into Caveats/Metadata; a retired
`CEO.md`'s guardrails move into DOs and DON'Ts ("fire the CEO, keep
his notes"); `CLAUDE.md`, `agent.json`, and `CEO.md` are deleted in
the same PR. During the migration window the harness helpers fall
back to `agent.json` for any repo that has not adopted the spec (see
the un-adopted-vs-nonconforming rule above); the fallback is removed on
the condition stated there -- with the last repo's conversion PR.

Acceptance test for a conversion: the amnesia test. A cold agent with
only the thin dossier takes a trivial ticket end-to-end. If it
fumbles, the dossier is missing something load-bearing -- find out
which section was too thin before converting the next repo.

`url` and `automerge.require_human` migrate the way every Metadata key
does: each already has a legacy `agent.json` home (`.smoke.url`,
`.automerge.require_human`) that the migration-window fallback reads
until a repo declares the dossier form. `automerge.maintenance` and
`landed.kind` have no such legacy home -- today they are hardcoded in
the harness itself (the maintenance carve-out to one specific repo;
`landed.kind` to a two-way name match), not read from any per-repo
config. This spec is that vocabulary's first declared form; wiring the
harness to read it instead of hardcoding it is consumer-side work
tracked separately, out of scope here.

## Example

````markdown
# porksicle.com

Penny arcade -- a collection of small browser games, played casually
in short sessions. For players; not a content site, and success is
people playing, not people reading.

## KPIs

1. Games played per week -- GA4 game_start (custom events, once wired)
2. Return visitors -- GA4 returning-user share

## DOs and DON'Ts

- DO keep ported games faithful to their originals -- parity over
  improvement.
- DON'T add content/SEO surfaces -- this is an arcade, ruled out
  2026-08.

## Caveats

- Each game directory carries its own AGENTS.md with lore and
  mechanics; read it before touching that game.

## Metadata

```yaml
type: arcade
url: https://porksicle.com
test: npm test
feedback-csv: https://docs.google.com/spreadsheets/d/e/.../pub?output=csv
```
````

A url-less repo declaring the merge-shape keys -- no `url`, so no
deploy barrier; `landed.kind` stands in with the host-state watch
instead. The pin is deliberately absent: a url-less repo is human-gated
unconditionally, so `automerge.require_human` here would declare
nothing. The only reason to write it would be as the prerequisite for
`automerge.maintenance`, which this repo does not take.

````markdown
# distillery

The context brain the harness reads its own vocabulary from. No live
domain -- consumers pin a released proof, not this working tree.

## KPIs

(none yet)

## Metadata

```yaml
type: infra
test: make test
landed.kind: distillery
```
````
