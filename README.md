![ContributeMailchimp Logo](Sources/ContributeMailchimp/ContributeMailchimp.docc/Resources/ContributeMailchimpLogo.png)

# ContributeMailchimp


[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeMailchimp%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/ContributeMailchimp)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeMailchimp%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/ContributeMailchimp)
[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/ContributeMailchimp/documentation)
[![License](https://img.shields.io/github/license/brightdigit/ContributeMailchimp)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/ContributeMailchimp/ContributeMailchimp.yml?label=actions&logo=github&branch=main)](https://github.com/brightdigit/ContributeMailchimp/actions)
[![Maintainability](https://qlty.sh/gh/brightdigit/projects/ContributeMailchimp/maintainability.svg)](https://qlty.sh/gh/brightdigit/projects/ContributeMailchimp)
[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/ContributeMailchimp)](https://codecov.io/gh/brightdigit/ContributeMailchimp)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/ContributeMailchimp)](https://www.codefactor.io/repository/github/brightdigit/ContributeMailchimp)

Create content for your site from Mailchimp newsletters.

---

## What is ContributeMailchimp?

Your newsletter archive is already a body of writing — it just lives inside Mailchimp instead of
on your site. **ContributeMailchimp turns sent Mailchimp campaigns into Markdown files with YAML
front matter**, ready to drop into a static site generator's content folder.

It is the Mailchimp adapter for [Contribute](https://github.com/brightdigit/Contribute), the
source-model-to-Markdown pipeline behind `brightdigit.com`. Contribute is deliberately
source-agnostic: it defines the *shape* of an import — a `ContentType` binding a source model to a
front-matter translator and a Markdown extractor — but it never talks to an API. This package
fills in the Mailchimp-specific half:

- it **fetches** campaigns and their archive HTML with
  [Spinetail](https://github.com/brightdigit/Spinetail), the BrightDigit Mailchimp API client, and
- it **models** a newsletter issue as the trio Contribute expects — `Newsletter` (the
  `ContentType`), `Newsletter.Source`, `Newsletter.FrontMatterTranslator`, and
  `Newsletter.MarkdownExtractor` — so Contribute's generic `write(...)` does the rest.

`brightdigit.com` uses it to import its newsletter archive alongside its podcast episodes and
videos.

> **Deprecated.** Every symbol in this module is annotated
> `@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")`. The
> package exists to keep the `brightdigit.com` newsletter import building while that content
> pipeline is reworked. For new work, model your own `ContentType` against `Contribute` and
> `Spinetail` directly.

## Installation

Add ContributeMailchimp to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/ContributeMailchimp.git", from: "1.0.0-alpha.1")
]
```

Then add it to a target:

```swift
.target(
  name: "MySite",
  dependencies: [.product(name: "ContributeMailchimp", package: "ContributeMailchimp")]
)
```

## Usage

### 1. Fetch the campaigns

`Newsletter.sources(from:listID:selectingWith:processedWith:)` lists a Mailchimp list's sent
campaigns and hands the **whole** list to your `select` closure. Filtering and issue numbering
happen there, where global ordering is available. Each campaign you return is then fetched and
converted concurrently.

```swift
import Contribute
import ContributeMailchimp
import Foundation
import Spinetail

let client = try MailchimpClient(apiKey: apiKey)
let htmlToMarkdown = SwiftSoupMarkdownGenerator().markdown(fromHTML:)

let newsletters = try await Newsletter.sources(
  from: client,
  listID: listID,
  selectingWith: { campaigns in
    // `campaigns` is [Spinetail.Campaign] — every sent campaign on the list.
    campaigns.enumerated().compactMap { index, campaign in
      guard
        let campaignID = campaign.id,
        let title = campaign.title,
        let sendTime = campaign.sendTime,
        let archiveURL = campaign.longArchiveURL.flatMap(URL.init(string:))
      else { return nil }

      return Newsletter.Source.Campaign(
        slug: title.slugify(),
        issueNo: index + 1,
        campaignID: campaignID,
        longArchiveURL: archiveURL,
        featuredImageURL: campaign.socialCardImageURL.flatMap(URL.init(string:)),
        title: title,
        subjectLine: campaign.subjectLine ?? title,
        previewText: campaign.previewText,
        sendTime: sendTime
      )
    }
  },
  processedWith: htmlToMarkdown
)
.sorted { $0.issueNo < $1.issueNo }
```

### 2. Write the Markdown

Hand the sources to Contribute's generic writer — the call site is identical to any other
Contribute source:

```swift
try Newsletter.write(
  from: newsletters,
  atContentPathURL: URL(fileURLWithPath: "Content/newsletters"),
  fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
  using: htmlToMarkdown,
  options: MarkdownContentBuilderOptions(
    shouldOverwriteExisting: false,
    includeMissingPrevious: false
  )
)
```

Each file is YAML front matter followed by the newsletter body:

```markdown
---
issueNo: 42
campaignID: 1a2b3c4d5e
featuredImage: https://mcusercontent.com/…/header.png
longArchiveURL: https://us1.campaign-archive.com/?u=…&id=…
newsletterTitle: Empower Apps Newsletter
title: What's new in Swift 6.4
date: 2026-06-29T12:00:00Z
description: A short preview line.
---

The newsletter body, converted from the campaign's archive HTML.
```

### Resilience

Mailchimp's storage layer occasionally serves a permanently cached `503` for a single campaign's
archive content. `Newsletter.sources(...)` logs that campaign to standard error and skips it
rather than aborting, so one bad campaign never costs you the whole archive.

## Requirements

- Swift 6.4
- macOS 15+, iOS 16+, tvOS 16+, watchOS 9+
- Ubuntu 24.04 (Noble) and other Swift 6.4 Linux distributions; Windows and Android are covered
  in CI

## License

[MIT](LICENSE) © BrightDigit
