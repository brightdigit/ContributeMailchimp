# Release Notes

## Unreleased

First release of ContributeMailchimp as a standalone package (brightdigit/ContributeMailchimp #1,
head `brightdigit-com-260717`). The module was split out of the brightdigit.com monorepo and
pushed to this repository via `git subrepo push`.

### Library

- Initial `ContributeMailchimp` library product: the `Newsletter` `ContentType` and its
  `Newsletter.Source`, `Newsletter.Source.Campaign`, `Newsletter.FrontMatter`,
  `Newsletter.FrontMatterTranslator`, and `Newsletter.MarkdownExtractor` types, which bridge
  Mailchimp campaigns into the `Contribute` Markdown-import pipeline.
- `Newsletter.sources(from:listID:selectingWith:processedWith:)` lists a Mailchimp list's sent
  campaigns, lets the caller select and number the issues to import, then fetches and converts
  each campaign's archive HTML concurrently. A campaign whose archive content is permanently
  unavailable (cached 503, brightdigit.com issue #108) is logged to stderr and skipped rather
  than aborting the whole import.
- The whole public API is annotated `@available(*, deprecated)` — it exists to keep the
  brightdigit.com newsletter import building and is scheduled for removal.
- Adopted the Spinetail 1.0.0 rename `MailchimpCampaign` → `Campaign`.
- Package dependencies (`Contribute`, `Spinetail`) resolve from their GitHub repositories
  instead of the monorepo's relative `path:` entries, so the package builds standalone.

### Tests

- `ContributeMailchimpTests` placeholder swift-testing suite so the package ships a test target.

### CI

- Adopted the shared BrightDigit workflow set: `ContributeMailchimp.yml` (Ubuntu, macOS, Apple
  platforms, Windows, Android) plus `check-unsafe-flags.yml`, `claude-code-review.yml`,
  `claude.yml`, `cleanup-caches.yml`, and `swift-source-compat.yml`, and the
  `.github/actions/setup-tools` composite action that caches the mise tool installs.
- `fail-fast: true` on all four build matrices.
- Ubuntu coverage now uses `sersoft-gmbh/swift-coverage-action@v5` instead of the SHA-pinned
  BrightDigit fork; dropped `fail-on-empty-output` and the Codecov `verbose` flag.
- `build-macos-platforms` adds a visionOS leg and drops the `ENABLE_WATCHOS` step gate.
- Added `.github/dependabot.yml` and `codecov.yml`; devcontainer image moved to
  `swiftlang/swift:nightly-6.4.x-noble`.
- `.spi.yml` documents the `ContributeMailchimp` target on Swift 6.4.

### Docs

- Added the `ContributeMailchimp.docc` catalog and a full README (badges, overview, installation,
  usage, requirements).
- `AGENTS.md` is now the canonical agent instruction file, with `CLAUDE.md` as a symlink to it;
  added `.claude/agent-notes.md` and the shared `.claude/skills/` set.
