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
  contract deterministically; `still build` refuses to ship anything
  unvalidated and writes `dist/manifest.json`; `still list` shows the shelf.
- **Proofs** -- versioned releases consumers pin. Consumers never read the
  working tree; between proofs the tree is a draft.

## The shelf

Run `bin/still list`. Current stock: the unattended worker's operating
contract, the shadow reviewer's directive, per-surface directives (voice,
feedback triage, site work, sports digest, /now), the AI-writing-tells
catalog, the per-repo AGENTS.md dossier spec, the worker permission profile,
the operator's engineering doctrine, and the ticket skeleton every task spec
is written against.

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
