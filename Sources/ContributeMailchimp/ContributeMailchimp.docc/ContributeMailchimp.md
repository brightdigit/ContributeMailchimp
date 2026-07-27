# ``ContributeMailchimp``

Import Mailchimp campaigns into your static site as Markdown with YAML front matter.

## Overview

![Logo](ContributeMailchimpLogo.svg)

`ContributeMailchimp` is the Mailchimp adapter for
[Contribute](https://github.com/brightdigit/Contribute), the source-model-to-Markdown pipeline
behind `brightdigit.com`. Contribute is deliberately source-agnostic: it defines the shape of an
import (a `ContentType` binding a source model to a front-matter translator and a Markdown
extractor) but never talks to an API. This package fills in the Mailchimp half — it fetches
campaigns with [Spinetail](https://github.com/brightdigit/Spinetail), the BrightDigit Mailchimp
API client, and hands Contribute everything it needs to write one Markdown file per newsletter
issue.

The entry point is ``Newsletter``, a `ContentType` whose associated types are all declared here:

- ``Newsletter/Source`` is a fully-resolved newsletter issue — campaign metadata plus the archive
  HTML and the Markdown rendered from it.
- ``Newsletter/Source/Campaign`` is the metadata you select for import: slug, issue number,
  campaign id, archive URL, featured image, title, subject line, preview text, and send time.
- ``Newsletter/FrontMatterTranslator`` maps a source onto ``Newsletter/FrontMatter``, the YAML
  front matter written above the body.
- ``Newsletter/MarkdownExtractor`` returns the already-rendered Markdown body.

### Fetching campaigns

`Newsletter.sources(from:listID:selectingWith:processedWith:)` drives the fetch. It lists a
Mailchimp list's sent campaigns, passes the *whole* list to your `select` closure — filtering and
issue numbering happen there, where global ordering is available — then fetches each selected
campaign's archive HTML and converts it to Markdown concurrently.

```swift
import Contribute
import ContributeMailchimp
import Spinetail

let sources = try await Newsletter.sources(
  from: client,
  listID: listID,
  selectingWith: { campaigns in
    campaigns.enumerated().compactMap { index, campaign in
      Newsletter.Source.Campaign(/* … */)
    }
  },
  processedWith: SwiftSoupMarkdownGenerator().markdown(fromHTML:)
)
```

A campaign whose archive content is permanently unavailable — Mailchimp's storage layer can serve
a cached `503` — is logged to standard error and skipped, so one bad campaign never aborts the
whole import.

### Status

This module is in active use: `brightdigit.com` imports its newsletter archive through it. It is
supported and tested, not deprecated. Newer newsletter platforms are covered by their own
adapters (for example `ContributeButtondown`); this one remains the Mailchimp adapter.

## Topics

### Content type

- ``Newsletter``

### Source models

- ``Newsletter/Source``
- ``Newsletter/Source/Campaign``

### Front matter and body

- ``Newsletter/FrontMatter``
- ``Newsletter/FrontMatterTranslator``
- ``Newsletter/MarkdownExtractor``
