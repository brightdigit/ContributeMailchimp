//
//  NewsletterFixtures.swift
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

/// Shared inputs for the ContributeMailchimp suites.
internal enum NewsletterFixtures {
  /// The archive URL of the sample campaign.
  internal static let archiveURLString = "https://us1.campaign-archive.com/?u=abc&id=def"
  /// The social-card image URL of the sample campaign.
  internal static let imageURLString = "https://mcusercontent.com/abc/images/header.png"
  /// The send time of the sample campaign (2026-01-01 00:00:00 UTC).
  internal static let sendTime = Date(timeIntervalSince1970: 1_767_225_600)

  /// Parses a URL string, failing the calling test if it is not a valid URL.
  ///
  /// - Parameter string: The URL string to parse.
  /// - Returns: The parsed URL.
  /// - Throws: An expectation failure if `string` is not a valid URL.
  internal static func url(_ string: String) throws -> URL {
    try #require(URL(string: string))
  }

  /// Builds sample campaign metadata, overriding only the fields a test cares about.
  ///
  /// - Parameters:
  ///   - slug: The URL-safe slug used for the issue's file name.
  ///   - issueNo: The issue number assigned while selecting campaigns.
  ///   - campaignID: The Mailchimp campaign identifier.
  ///   - featuredImageURL: The image to feature for the issue, if any.
  ///   - title: The campaign's internal title.
  ///   - subjectLine: The subject line the campaign was sent with.
  ///   - previewText: The campaign's preview text, if set.
  ///   - sendTime: The date and time the campaign was sent.
  /// - Returns: The campaign metadata.
  /// - Throws: An expectation failure if a fixture URL cannot be parsed.
  internal static func campaign(
    slug: String = "whats-new-in-swift-6-4",
    issueNo: Int = 42,
    campaignID: String = "1a2b3c4d5e",
    featuredImageURL: URL? = nil,
    title: String = "Empower Apps Newsletter",
    subjectLine: String = "What is new in Swift 6.4",
    previewText: String? = "A short preview line.",
    sendTime: Date = NewsletterFixtures.sendTime
  ) throws -> Newsletter.Source.Campaign {
    Newsletter.Source.Campaign(
      slug: slug,
      issueNo: issueNo,
      campaignID: campaignID,
      longArchiveURL: try Self.url(Self.archiveURLString),
      featuredImageURL: featuredImageURL,
      title: title,
      subjectLine: subjectLine,
      previewText: previewText,
      sendTime: sendTime
    )
  }

  /// Builds a fully-resolved newsletter issue from sample campaign metadata.
  ///
  /// - Parameters:
  ///   - campaign: The campaign metadata to wrap.
  ///   - html: The campaign's archive HTML.
  ///   - markdown: The issue body, already converted to Markdown.
  /// - Returns: The newsletter source.
  internal static func source(
    campaign: Newsletter.Source.Campaign,
    html: String = "<p>Hello, newsletter.</p>",
    markdown: String = "Hello, newsletter.\n"
  ) -> Newsletter.Source {
    Newsletter.Source(campaign: campaign, html: html, markdown: markdown)
  }

  /// Renders the `yyyy-MM-dd HH:mm` string that YAML front matter should carry
  /// for the given date, computed independently of `Contribute.YAML`.
  ///
  /// - Parameter date: The date to render.
  /// - Returns: The expected front-matter date string.
  /// - Throws: An expectation failure if the date components are unavailable.
  internal static func expectedDateString(for date: Date) throws -> String {
    let parts = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: date
    )
    let date = [
      Self.pad(try #require(parts.year), width: 4),
      Self.pad(try #require(parts.month), width: 2),
      Self.pad(try #require(parts.day), width: 2),
    ]
    .joined(separator: "-")
    let time = [
      Self.pad(try #require(parts.hour), width: 2),
      Self.pad(try #require(parts.minute), width: 2),
    ]
    .joined(separator: ":")
    return "\(date) \(time)"
  }

  /// Left-pads a number with zeros to the requested width.
  ///
  /// - Parameters:
  ///   - value: The number to pad.
  ///   - width: The desired minimum width.
  /// - Returns: The zero-padded number.
  private static func pad(_ value: Int, width: Int) -> String {
    let text = String(value)
    guard text.count < width else {
      return text
    }
    return String(repeating: "0", count: width - text.count) + text
  }
}
