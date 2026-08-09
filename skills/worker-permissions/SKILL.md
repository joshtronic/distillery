---
name: worker-permissions
description: The unattended worker's tool permission profile (Claude Code settings) -- broad dev capability, denied network git / secrets / harness internals
consumers: igor-surface
source: agent-settings.json
extracted: 2026-08-10
---

# Worker permission profile

`files/agent-settings.json` is the Claude Code permission profile the harness
hands every unattended worker. The design intent, so a consumer can evaluate
rather than cargo-cult it:

- **Allow**: read/edit/search tools, WebFetch/WebSearch, and Bash for every
  mainstream toolchain (git local-only, node/python/go/rust/make) plus text
  utilities and the four harness helpers (`agent-block.sh`, `agent-report.sh`,
  `agent-ask.sh`, `agent-enqueue.sh`) by bare name.
- **Deny**: network-side git (`push`/`remote` -- the harness owns the remote),
  sudo, destructive rm patterns, curl-pipe-to-shell, and reads of `~/.ssh`,
  `/etc/shadow`, and the harness install/config directories (secrets live
  there; the worker must never be able to exfiltrate its own credentials).

The deny-on-harness-directory rule is load-bearing: the worker runs AS the
bot user on the host, so filesystem discipline is the actual secret boundary,
not the process boundary.
