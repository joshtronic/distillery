# Distillery

The context brain for a fleet of unattended coding agents. This repo is the
source of truth for the context files, directives, and skills that drive
[igor](https://git.sherver.org/joshtronic/igor) (the harness) and the
operator's local harnesses -- extracted out of the harness so the same brain
can pour into more than one glass. Context is treated as first-class,
versioned, validated artifacts that agents consume, rather than prose that
rots inside whatever repo it started in.

## Mirrors

**Canonical repo: <https://git.sherver.org/joshtronic/distillery>**

Mirrored for _your_ convenience:

- <https://github.com/joshtronic/distillery>

_I don't monitor these services or accept pull/merge requests on them._

## How it works

- **`skills/<name>/SKILL.md`** -- one distillable unit: YAML frontmatter
  (name, description, consumers, source, extracted) followed by the content.
  Extra files ride in `skills/<name>/files/`.
- **`bin/still`** -- the assembler. `still validate` enforces the format
  contract deterministically; `still verify` runs each skill's optional
  `verify:` command as a semantic gate on top of that -- VERIFIED, FAILED,
  or honestly UNVERIFIED when a skill has no check yet; `still build`
  refuses to ship anything unvalidated and writes `dist/manifest.json`;
  `still list` shows the shelf.
- **`dist/manifest.json`** -- a committed, generated artifact (the rest of
  `dist/` stays gitignored). A consumer verifies each poured skill's
  `sha256` against this file read at a ref, so it must exist on that ref --
  regenerating it from the checkout being verified would prove nothing.
  Regenerate it with `bin/still build` whenever a skill changes, and commit
  the result; `bin/still build --check` fails CI if the committed copy has
  drifted from the tree.
- **Proofs** -- versioned releases consumers pin. Consumers never read the
  working tree; between proofs the tree is a draft.

## The shelf

Generated from each skill's `description` frontmatter by `bin/still index`;
`still index --check` fails CI if this block drifts from the tree. Run
`bin/still list` for the same listing from your terminal.

<!-- shelf:start -->
- **ai-writing-tells** — Catalog of AI writing tells to avoid in any prose surface
- **coding-standards** — Use when writing or reviewing any code change. The coding-output contract -- minimal touch, the two-variety comment rule, TDD with red-tested validation, honest verification claims.
- **design** — Use when doing visual or UX work on a site -- new UI, redesigns, reskins, or design review. Distinctive-per-subject direction with content preservation and verification-by-screenshot.
- **doctrine** — The operator's hard-won engineering doctrine for agentic systems -- amnesia, deterministic gates, mechanism over prose, red-tested validation, pre-mortems, evidence over claims, guard severance
- **dossier-spec** — The dossier's declared-shape vocabulary -- AGENTS.md structure, the Metadata key contract (url, automerge.require_human, automerge.maintenance, landed.kind), and the two invariants (explicit opt-in with fail-fast on partial declarations; no unattended edits to the dossier itself)
- **feedback-directive** — Player-feedback triage directive: DROP/FILE decision contract over untrusted CSV rows
- **now-directive** — Weekly /now page refresh directive
- **product-research** — Use when delegated a product goal for a site or tool -- researching whether and how to pursue it, and producing specced, verifiable tickets. Replaces the retired autonomous-CEO pattern with demand-driven product work.
- **review-directive** — The shadow code reviewer's directive: verdict contract, review dimensions, diff-appropriateness, comment-bloat findings
- **site-work-directive** — Weekly website work-pass directive
- **sports-digest-directive** — Daily sports digest directive: curation by significance, taught-concepts curriculum
- **ticket-skeleton** — The fixed skeleton every task spec (issue / ticket) is written against -- goal, out-of-scope, verification, done-means; the amnesiac worker reads nothing else
- **voice** — Igor's shared voice anchor for all writing surfaces
- **worker-contract** — The unattended worker's operating contract: outcomes (PR/report/block), PR_BODY discipline, TDD, security self-review, scope rules
- **worker-permissions** — The unattended worker's tool permission profile (Claude Code settings) -- broad dev capability, denied network git / secrets / harness internals
<!-- shelf:end -->

## Consuming

Pin a proof, read `dist/manifest.json`, take the skills whose `consumers`
list matches your surface (`igor-surface` for harness prompt fragments,
`generic` for anything). Wiring igor to consume proofs instead of its own
copies is tracked on igor's side.

## Testing

```sh
make test
```

Runs `bin/test-still.sh`, which exercises every validation rule by
deliberately breaking it -- a validator that has never failed has never been
tested -- and finishes by validating the real tree.

## License

GPL v3 -- see [LICENSE](LICENSE).
