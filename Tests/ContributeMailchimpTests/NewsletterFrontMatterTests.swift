//
//  NewsletterFrontMatterTests.swift
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

/// Covers ``Newsletter/FrontMatterTranslator``.
@Suite internal struct NewsletterFrontMatterTests {
  /// Every source field is mapped onto the front matter, including the crossover
  /// where the campaign title becomes `newsletterTitle` and the subject line
  /// becomes the item `title`.
  @Test internal func translatorMapsEverySourceField() throws {
    let imageURL = try NewsletterFixtures.url(NewsletterFixtures.imageURLString)
    let campaign = try NewsletterFixtures.campaign(featuredImageURL: imageURL)
    let source = NewsletterFixtures.source(campaign: campaign)

    let frontMatter = Newsletter.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.issueNo == 42)
    #expect(frontMatter.campaignID == "1a2b3c4d5e")
    #expect(frontMatter.featuredImage == imageURL)
    #expect(frontMatter.longArchiveURL.absoluteString == NewsletterFixtures.archiveURLString)
    #expect(frontMatter.newsletterTitle == "Empower Apps Newsletter")
    #expect(frontMatter.title == "What is new in Swift 6.4")
    #expect(frontMatter.description == "A short preview line.")
  }

  /// The send time is written in the `yyyy-MM-dd HH:mm` shape Publish expects.
  @Test internal func sendTimeIsFormattedForYAML() throws {
    let campaign = try NewsletterFixtures.campaign()
    let source = NewsletterFixtures.source(campaign: campaign)

    let frontMatter = Newsletter.FrontMatterTranslator().frontMatter(from: source)
    let expected = try NewsletterFixtures.expectedDateString(for: NewsletterFixtures.sendTime)

    #expect(frontMatter.date == expected)
    #expect(frontMatter.date.count == 16)
  }

  /// A campaign without an image or preview text produces nil optionals rather
  /// than empty strings.
  @Test internal func absentOptionalsStayNil() throws {
    let campaign = try NewsletterFixtures.campaign(
      featuredImageURL: nil,
      previewText: nil
    )
    let source = NewsletterFixtures.source(campaign: campaign)

    let frontMatter = Newsletter.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.featuredImage == nil)
    #expect(frontMatter.description == nil)
  }

  /// The description carries the *normalized* preview text, not the raw one.
  @Test internal func descriptionUsesTheNormalizedPreviewText() throws {
    let campaign = try NewsletterFixtures.campaign(
      previewText: " \"Swift\u{2019}s new concurrency\" "
    )
    let source = NewsletterFixtures.source(campaign: campaign)

    let frontMatter = Newsletter.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.description == "Swift's new concurrency")
  }
}
