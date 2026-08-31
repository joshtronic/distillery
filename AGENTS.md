# distillery

The context brain: source-of-truth for the context files, directives, and
skills that drive the igor harness and the operator's local harnesses. For
the harnesses that consume it (and the humans who curate it) -- not an end-user
product. Content is organized as `skills/<name>/SKILL.md` bundles, validated
and assembled by `bin/still`. No release is cut yet -- consumers currently
read commits directly off `origin/master`.

## KPIs

(none yet)

## DOs and DON'Ts

- DO run every content change through `bin/still validate` -- nothing ships
  unvalidated; the deterministic gate IS the product's quality bar.
- DO keep extracted skills verbatim-faithful to their source at extraction
  time -- improvements are their own commits, never smuggled into a move.
- DON'T assume a release exists to pin -- none has been cut yet; consumers
  currently read `origin/master` directly.

## Caveats

- The `still` format contract (frontmatter keys, consumer vocabulary) is
  documented in `bin/still`'s header and enforced by `bin/test-still.sh` --
  extend both together.

## Metadata

```yaml
type: infra
test: make test
landed-kind: context-cache
```
