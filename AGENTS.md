# AGENTS.md

This is the canonical agent instruction file for this repository. `CLAUDE.md` is a symlink to it.

## Overview

ContributeMailchimp is a Swift library (SPM package, product `ContributeMailchimp`) that turns
Mailchimp campaigns into Markdown files with YAML front matter, using the
[`Contribute`](https://github.com/brightdigit/Contribute) pipeline. It is consumed as a library;
there is no executable target.

The package supplies the Mailchimp half of the trio `Contribute` expects: a `Newsletter`
`ContentType` bound to a `Newsletter.Source`, a `Newsletter.FrontMatterTranslator`, and a
`Newsletter.MarkdownExtractor`. Fetching is done with
[`Spinetail`](https://github.com/brightdigit/Spinetail) (the BrightDigit Mailchimp API client) —
`Newsletter.sources(from:listID:selectingWith:processedWith:)` lists a list's sent campaigns,
hands the whole list to a caller-supplied `select` closure (which filters and assigns issue
numbers, where global ordering is available), then fetches each selected campaign's archive HTML
concurrently and converts it to Markdown.

Notes that matter when editing:

- The public API is **not** deprecated. It used to carry a blanket
  `@available(*, deprecated, …)`, which was removed: brightdigit.com imports its newsletter
  archive through this package, so the API is in active use — and swift-testing refuses to apply
  `@Suite`/`@Test` to deprecated declarations, which made the module untestable. Do not
  reintroduce a blanket deprecation.
- A single campaign whose archive content is unavailable (a cached 503 at Mailchimp's storage
  layer — brightdigit.com issue #108) is logged to stderr and skipped, never fatal. Preserve
  that behaviour.
- Non-Apple platforms are supported; code is `#if canImport(FoundationNetworking)`-guarded.
  Preserve those guards.

## Commands

Builds with the **Swift 6.4 toolchain** (`.swift-version` → `6.4.x-snapshot`). Use the matching
snapshot / `Xcode-beta` toolchain locally.

- Build: `swift build`
- Build incl. tests: `swift build --build-tests`
- Run tests: `swift test` (swift-testing; `Tests/ContributeMailchimpTests`)

Swift 6 strict concurrency is mandatory. When a strict-concurrency error surfaces, fix it
properly (`Sendable`/`@Sendable`, actor isolation, restructured ownership) — never lower the
language mode or silence the diagnostic.

### Linting

Lint tooling is pinned via **mise** (`.mise.toml`). The entry point is `Scripts/lint.sh`, which
bootstraps tools with `mise install` then runs swift-format, SwiftLint, and a build check
(periphery + the license-header rewrite run locally only).

- Full lint + autofix (local): `Scripts/lint.sh`
- Format only: `FORMAT_ONLY=1 Scripts/lint.sh`
- CI/strict mode (no autofix, fails on warnings): `LINT_MODE=STRICT CI=1 Scripts/lint.sh`

`Scripts/lint.sh` invokes `Scripts/header.sh … -p "ContributeMailchimp"`. If you sync the script
from another BrightDigit package, keep that package name — copying verbatim rewrites the wrong
name into every source header.

SwiftLint config is strict and opinionated (`explicit_acl`, `force_unwrapping`, small
`file_length`) — keep files small and ACLs explicit.

## Dependencies

- [`Contribute`](https://github.com/brightdigit/Contribute) — the generic source → Markdown
  pipeline (`ContentType`, `FrontMatterTranslator`, `MarkdownExtractor`, YAML front matter).
- [`Spinetail`](https://github.com/brightdigit/Spinetail) — the Mailchimp API client
  (swift-openapi-generator based, async).

Both are resolved from their GitHub repositories; see `Package.swift` for the current pins.

## CI

A single primary workflow, `.github/workflows/ContributeMailchimp.yml` (a shared BrightDigit
template). It builds on Ubuntu (nightly-6.4 container), GitHub-hosted macOS + Apple platforms
(Xcode 27 / Swift 6.4), Windows, and Android. Matrix scope tiers up by ref: a small set always;
the full matrix + Windows on `main`, semver tags, dispatch, and PRs into `main`. Skip CI with
`ci skip` in the commit message.

**The workflow filename must exactly match the package name** — the README's Actions badge URL
embeds it.

Auxiliary workflows: `check-unsafe-flags.yml`, `claude-code-review.yml`, `claude.yml`,
`cleanup-caches.yml`, `swift-source-compat.yml`, plus the `.github/actions/setup-tools`
composite action that caches the mise tool installs.

## Memory & Corrections Convention

`.claude/agent-notes.md` is the canonical, versioned corrections log for this repository — an
append-only record of the maintainer's corrections and standing **always/never** directives.

- **Read `.claude/agent-notes.md` at the start of every work session, before doing any work.** It
  is the source of truth for *how* to work in this repo.
- **Whenever the maintainer makes a correction or gives an always/never instruction, append one
  line to `.claude/agent-notes.md` proactively (without being asked).** One line per directive,
  newest at the bottom. If a directive supersedes an earlier one, update or remove the stale line
  rather than leaving both.
