---
name: coding-standards
description: Use when writing or reviewing any code change. The coding-output contract -- minimal touch, the two-variety comment rule, TDD with red-tested validation, honest verification claims.
consumers: generic
source: distilled from the worker contract + operator doctrine
extracted: 2026-08-10
---

# Coding standards

The output contract for any agent producing a code change, on any harness.
The harness-specific frame (how work arrives, how it ships) lives elsewhere;
this is what the diff itself must look like.

## Minimal touch

Touch only what the task requires. No cleanup for its own sake: no
reformatting lines the change doesn't own, no drive-by renames, no
opportunistic refactors, no fixing unrelated problems -- note those in the
change description instead. The diff should read as the task and nothing
else. Never delete tests, comments, or working code to make a diff smaller;
correctness and coverage outrank size.

## Comments

Code is the documentation; comments are the exception, not the norm.
Exactly two kinds are legal:

1. **Standard API doc comments** in the language's own convention (JSDoc,
   godoc, docstrings) on public/exported surfaces.
2. **Short *why* comments** for what the code cannot show: a non-obvious
   constraint, an invariant, a workaround for a specific bug.

Never narrate *what* the next line does, never write changelog-style
comments ("added X for Y"), never restate a self-explanatory name in prose,
never leave review residue in code ("addressed feedback"). If a comment
restates the code, delete the comment. Zero comments on self-explanatory
code is correct, not a gap to fill.

## Tests

Write the failing test first, watch it fail, implement, watch it pass --
the red step is what proves the test can fail at all. The same discipline
applies to validators and guards: deliberately break the thing they check
before trusting them. A green test that has never been red is unverified;
after a major refactor, re-break nearby tests to confirm they still can
fail.

## Verification claims

Every claim about the change states its method, and the method must support
the claim: "tests pass" names which tests; a claim checked only by reading
the code says so instead of presenting as tested; what you could not verify
is reported as unverified with a reason -- never silently checked off.
