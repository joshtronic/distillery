---
name: doctrine
description: The operator's hard-won engineering doctrine for agentic systems -- amnesia, deterministic gates, mechanism over prose, red-tested validation, pre-mortems, evidence over claims, guard severance
consumers: generic
source: operator (lessons learned, 2026-08-10)
extracted: 2026-08-10
---

# Doctrine

Hard-won rules for building and operating agentic systems. Each earned its
place by something breaking. They bind every consumer of this brain -- a
harness surface, a working agent, or a human speccing work.

## Context

- **It's 50 First Dates: the consumer has amnesia.** Every reader wakes up
  with no memory of any prior conversation. Durable constraints live in the
  repo's context file (AGENTS.md); per-task context lives in the issue /
  ticket / task spec, written against a fixed skeleton (see the
  `ticket-skeleton` skill). Nothing load-bearing lives in chat history,
  comments, or anyone's head.
- **Context degrades. Sufficient does not mean durable -- demand both.** A
  context file that works today rots as the code moves. Prefer claims that
  are checkable (commands, paths, exact headings) and mechanisms that check
  them; date what can't be checked.

## Specification

- **Don't just define the task -- define what's OUT of scope and how to
  verify the result.** An agent with a goal and no boundary will find scope
  you didn't intend. An agent with no verification steps will declare
  success on vibes.
- **Before starting, poke holes: what could page you at 3am?** Run the
  pre-mortem while the design is cheap to change. Name the failure modes,
  then either design them away or accept them out loud.
- **In a single-threaded loop, ask what one task's failure starves.** Any
  scenario where one failing item wedges the whole cascade is a design bug,
  not an operational annoyance.

## Evidence

- **A claim is not evidence.** "It's fixed," "it's live," "tests pass" is a
  report; the passing run, the production probe, the diff is the evidence.
  Before advancing state on a report, go get the artifact it describes.
- **Measure the executing surface, not a proxy.** A version string, a merge
  event, a green badge stands in for the code that runs. Check the bytes
  that actually execute, not a stand-in for them.
- **Check the cure's state, not its existence.** A fix can exist as an
  inert artifact -- a draft PR, an unmerged branch, an undeployed commit --
  while the defect keeps reproducing. Confirm the fix is in force, not
  merely that it exists somewhere.
- **The signal is not the subject.** Before trusting a probe, ask: would it
  report the same result regardless of the subject's real state? If yes, it
  measures nothing -- fix the probe or stop citing it.

## Validation

- **Deterministic validation runs before any LLM sees the work.** Cheap
  scripted checks gate what reaches a model; the model spends judgment only
  on what survived. A line counter, a schema check, a grep -- each one is a
  model call that never has to happen and a failure class that can't slip
  through on charisma.
- **Enforce contracts with the mechanism, not the system prompt.** Document
  the rule, yes -- then check it in review, warn on it where the agent can
  recover, and reject at the gate where it can't. A rule that lives only in
  prose is a suggestion.
- **Red-test your validation before trusting it.** TDD applies to guards
  too: deliberately break the thing, watch the check fail, then fix it. A
  validator that has never failed has never been tested.
- **A green check is evidence only if it can go red -- and that applies to
  every gate a harness runs, not just this repo's own validator.** Sever
  the subject and confirm the gate refuses to pass: a CI check, a lint
  rule, an exclusion list. A gate that still passes when you remove the
  thing it asserts on is theater; an individually-justified exclusion is
  still an unguarded gap unless the sever-and-fail check runs on it too.
- **A green test is not necessarily a healthy test.** Major refactors
  restart scrutiny on the tests around them. At worst, re-break a test that
  hasn't failed in a while and confirm it still can.

## Operating

- **Observe the agent's OUTCOME, not the runner's exit code.** A script
  that exits 0 around an agent that produced nothing is a failure. Judge
  the work product.
- **Log every tick; surface annoyances and failures; track time since the
  last one.** "X days since an incident" is not a trophy -- it's the
  scheduling signal for the next deliberate re-break.
- **First failure could be a fluke. Second failure needs more than a monkey
  patch.** A recurrence is a pattern; patterns get root cause and a guard,
  not another bandage.
- **Post-mortem with rigor: which guard failed? If none existed, add one.**
  Every incident either found a hole in an existing guard or proved a
  missing guard. Leaving with neither answer means the incident will
  repeat.
- **Turn gut-check judgment calls into cheap structural rules.** When an
  in-the-moment call turns out right, don't let it evaporate -- encode it:
  a validation line, a checklist item, a skill entry like this one. The
  current task is the cheapest moment to make the lesson permanent.
