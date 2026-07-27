//
//  NewsletterContentTests.swift
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

import Contribute
import Foundation
import Testing

@testable import ContributeMailchimp

/// Covers the Markdown document ``Newsletter`` produces through Contribute's
/// generic YAML content builder.
@Suite internal struct NewsletterContentTests {
  /// Splits a rendered document into its front-matter lines and its body.
  ///
  /// - Parameter text: The rendered document.
  /// - Returns: The front-matter lines and the Markdown body.
  /// - Throws: An expectation failure if the delimiters are missing.
  private static func split(_ text: String) throws -> (frontMatter: [String], body: String) {
    let lines = text.components(separatedBy: "\n")
    #expect(lines.first == "---")
    let rest = Array(lines.dropFirst())
    let closingIndex = try #require(rest.firstIndex(of: "---"))
    return (
      frontMatter: Array(rest[..<closingIndex]),
      body: rest[(closingIndex + 1)...].joined(separator: "\n")
    )
  }

  /// The document is YAML front matter between `---` fences, followed by the
  /// issue's Markdown body.
  @Test internal func documentIsFrontMatterThenBody() throws {
    let campaign = try NewsletterFixtures.campaign()
    let source = NewsletterFixtures.source(
      campaign: campaign,
      markdown: "# Issue 42\n\nHello, newsletter.\n"
    )

    let text = try Newsletter.contentBuilder().content(from: source) { $0 }
    let parts = try Self.split(text)

    #expect(parts.frontMatter.contains("issueNo: 42"))
    #expect(parts.frontMatter.contains("campaignID: 1a2b3c4d5e"))
    #expect(parts.frontMatter.contains("newsletterTitle: Empower Apps Newsletter"))
    #expect(parts.body == "# Issue 42\n\nHello, newsletter.\n")
  }

  /// Keys for absent optionals are omitted from the YAML rather than emitted as
  /// `null`, so Publish never sees an empty `featuredImage` or `description`.
  @Test internal func absentOptionalKeysAreOmitted() throws {
    let campaign = try NewsletterFixtures.campaign(
      featuredImageURL: nil,
      previewText: nil
    )
    let source = NewsletterFixtures.source(campaign: campaign)

    let text = try Newsletter.contentBuilder().content(from: source) { $0 }
    let parts = try Self.split(text)

    #expect(!parts.frontMatter.contains { $0.hasPrefix("featuredImage:") })
    #expect(!parts.frontMatter.contains { $0.hasPrefix("description:") })
  }

  /// Present optionals are emitted, image URL included.
  @Test internal func presentOptionalKeysAreEmitted() throws {
    let imageURL = try NewsletterFixtures.url(NewsletterFixtures.imageURLString)
    let campaign = try NewsletterFixtures.campaign(featuredImageURL: imageURL)
    let source = NewsletterFixtures.source(campaign: campaign)

    let text = try Newsletter.contentBuilder().content(from: source) { $0 }
    let parts = try Self.split(text)

    #expect(parts.frontMatter.contains("featuredImage: \(NewsletterFixtures.imageURLString)"))
    #expect(parts.frontMatter.contains("description: A short preview line."))
  }
}
