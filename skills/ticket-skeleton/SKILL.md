---
name: ticket-skeleton
description: The fixed skeleton every task spec (issue / ticket) is written against -- goal, out-of-scope, verification, done-means; the amnesiac worker reads nothing else
consumers: generic
source: operator doctrine (2026-08-10)
extracted: 2026-08-10
---

# Ticket skeleton

The worker that picks this ticket up has amnesia: it reads the issue body,
the repo's context file, and nothing else. Comments are not read. Prior
tickets are not read. Every actionable fact goes IN THE BODY, structured
like this:

```markdown
<One paragraph: what this is and why it exists. Link nothing load-bearing --
paste it. If a prior discussion decided something, restate the decision.>

## Deliverables

1. <Concrete artifact or change, one per numbered item. Exact paths, exact
   names, exact commands. "Add X to Y" beats "improve Y".>
2. <...>

## Out of scope

- <The adjacent work a reasonable agent might do but must not. Every scope
  surprise you've ever had was an out-of-scope section you didn't write.>

## Verification

- <How the worker proves it worked before exiting: the command to run, the
  output to expect, the fixture to test against. "Tests pass" only counts
  if you name which tests.>
- <What the human reviewer should check that automation can't.>

## Notes

- <Constraints, gotchas, sharp edges. The 3am-page pre-mortem's findings
  land here.>
```

Rules:

- **Deliverables are checkable.** If you can't verify an item shipped by
  looking at the diff, rewrite it until you can.
- **Out of scope is mandatory thinking, even when the section is short.**
  "Nothing else" is a valid entry; not considering the question is not.
- **Verification names its evidence.** A spec whose verification section is
  empty is not ready to file.
- **One ticket, one outcome.** If the deliverables list needs sub-headings,
  it's two tickets.
