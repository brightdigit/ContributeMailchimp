//
//  NewsletterMarkdownExtractorTests.swift
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

/// Covers ``Newsletter/MarkdownExtractor``.
@Suite internal struct NewsletterMarkdownExtractorTests {
  /// The extractor returns the Markdown that was rendered when the source was
  /// built, and never re-runs the injected HTML-to-Markdown conversion.
  @Test internal func returnsTheAlreadyRenderedMarkdownWithoutReconverting() throws {
    let campaign = try NewsletterFixtures.campaign()
    let source = NewsletterFixtures.source(
      campaign: campaign,
      html: "<p>Raw archive HTML</p>",
      markdown: "# Issue 42\n\nAlready converted.\n"
    )

    let markdown = try Newsletter.MarkdownExtractor().markdown(from: source) { _ in
      Issue.record("The HTML-to-Markdown converter must not be invoked.")
      return "converted again"
    }

    #expect(markdown == "# Issue 42\n\nAlready converted.\n")
  }

  /// An empty body is passed through untouched rather than substituted.
  @Test internal func passesAnEmptyBodyThrough() throws {
    let campaign = try NewsletterFixtures.campaign()
    let source = NewsletterFixtures.source(
      campaign: campaign,
      html: "<p>Not empty</p>",
      markdown: ""
    )

    let markdown = try Newsletter.MarkdownExtractor().markdown(from: source) { $0 }

    #expect(markdown.isEmpty)
  }

  /// A converter that throws never reaches the extractor, so extraction succeeds.
  @Test internal func aThrowingConverterIsNeverCalled() throws {
    let campaign = try NewsletterFixtures.campaign()
    let source = NewsletterFixtures.source(campaign: campaign, markdown: "Body\n")

    let markdown = try Newsletter.MarkdownExtractor().markdown(from: source) { _ in
      throw CocoaError(.featureUnsupported)
    }

    #expect(markdown == "Body\n")
  }
}
