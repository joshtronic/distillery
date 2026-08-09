---
name: design
description: Use when doing visual or UX work on a site -- new UI, redesigns, reskins, or design review. Distinctive-per-subject direction with content preservation and verification-by-screenshot.
consumers: generic
source: distilled from fleet design-refresh lessons
extracted: 2026-08-10
---

# Design

Rules for visual and UX work on real sites, learned the expensive way.

## Direction

- **Distinctive per subject, never templated.** The design should look like
  it was made for THIS site's subject and audience -- a penny arcade, a
  debt-help resource, and a benchmark site must not share a face. Generic
  gradient-hero-and-cards output is a failure even when it's clean.
- **The brand is load-bearing.** Existing brand elements (mascots, palettes,
  era aesthetics, voice) are constraints to work within, not debris to
  modernize away.

## Execution

- **A redesign carries ALL existing content and features forward.** Reskin
  means reskin: dropping sections, features, or copy because the new layout
  didn't have a slot for them is content loss, not design ("you've
  bastardized it" is real operator feedback from a redesign that dropped
  substance). Inventory the page before touching it; diff the inventory
  after.
- **Match the request's size.** A small visual change reuses existing
  styles and markup -- "image above text" is plain markup in the existing
  system, not a new CSS component. New abstractions need a new-abstraction
  reason.
- **Respect the content system.** Generated sites get template/generator
  edits, never hand-edited output; static-site conventions (existing CSS
  architecture, design tokens) are extended, not forked.

## Verification

- **See it before you ship it.** Render the real page and look at it --
  screenshot at desktop and mobile widths, and for interactive work, drive
  the actual interaction (a browser-automation pass) rather than inferring
  from code. "The CSS looks right" is not a verification method.
- **Check the unglamorous states:** empty content, long strings, missing
  images, dark backgrounds behind transparent assets -- the states the
  mockup never shows are where shipped design breaks.
