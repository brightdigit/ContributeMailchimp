//
//  NewsletterSourceTests.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import Testing

@testable import ContributeMailchimp

/// Covers how ``Newsletter/Source`` is built from campaign metadata.
@Suite internal struct NewsletterSourceTests {
  /// Every campaign field, plus the fetched HTML and Markdown, lands on the source.
  @Test internal func campaignMetadataIsCopiedOntoTheSource() throws {
    let imageURL = try NewsletterFixtures.url(NewsletterFixtures.imageURLString)
    let campaign = try NewsletterFixtures.campaign(featuredImageURL: imageURL)
    let source = NewsletterFixtures.source(
      campaign: campaign,
      html: "<p>Body</p>",
      markdown: "Body\n"
    )

    #expect(source.slug == "whats-new-in-swift-6-4")
    #expect(source.issueNo == 42)
    #expect(source.campaignID == "1a2b3c4d5e")
    #expect(source.longArchiveURL.absoluteString == NewsletterFixtures.archiveURLString)
    #expect(source.featuredImageURL == imageURL)
    #expect(source.title == "Empower Apps Newsletter")
    #expect(source.subjectLine == "What is new in Swift 6.4")
    #expect(source.sendTime == NewsletterFixtures.sendTime)
    #expect(source.html == "<p>Body</p>")
    #expect(source.markdown == "Body\n")
  }

  /// The preview text is trimmed, unquoted, and has curly apostrophes normalized;
  /// every other string is copied verbatim.
  @Test(
    arguments: [
      ("\"A quoted preview.\"", "A quoted preview."),
      ("'A quoted preview.'", "A quoted preview."),
      ("   Padded preview.   ", "Padded preview."),
      ("Swift\u{2019}s new concurrency", "Swift's new concurrency"),
      ("\"Swift\u{2019}s new concurrency\"", "Swift's new concurrency"),
      ("A \"quoted\" word inside.", "A \"quoted\" word inside."),
    ]
  )
  internal func previewTextIsNormalized(rawText: String, expected: String) throws {
    let campaign = try NewsletterFixtures.campaign(previewText: rawText)
    let source = NewsletterFixtures.source(campaign: campaign)

    #expect(source.previewText == expected)
  }

  /// A campaign without preview text produces a source without a description.
  @Test internal func missingPreviewTextStaysNil() throws {
    let campaign = try NewsletterFixtures.campaign(previewText: nil)
    let source = NewsletterFixtures.source(campaign: campaign)

    #expect(source.previewText == nil)
  }

  /// The optional campaign parameters default to `nil`.
  @Test internal func campaignOptionalsDefaultToNil() throws {
    let campaign = Newsletter.Source.Campaign(
      slug: "issue-1",
      issueNo: 1,
      campaignID: "abc123",
      longArchiveURL: try NewsletterFixtures.url(NewsletterFixtures.archiveURLString),
      title: "Issue 1",
      subjectLine: "Issue 1",
      sendTime: NewsletterFixtures.sendTime
    )

    #expect(campaign.featuredImageURL == nil)
    #expect(campaign.previewText == nil)
  }
}
