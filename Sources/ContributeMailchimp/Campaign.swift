//
//  Campaign.swift
//  ContributeMailchimp
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

extension Newsletter.Source {
  /// The metadata extracted from a Mailchimp campaign that identifies a
  /// newsletter issue.
  public struct Campaign: Sendable {
    /// The URL-safe slug used for the issue's file name.
    public let slug: String
    /// The issue number assigned while selecting campaigns.
    public let issueNo: Int
    /// The Mailchimp campaign identifier.
    public let campaignID: String
    /// The public campaign-archive URL for the issue.
    public let longArchiveURL: URL
    /// The image to feature for the issue, if the campaign has one.
    public let featuredImageURL: URL?
    /// The campaign's internal title.
    public let title: String
    /// The subject line the campaign was sent with.
    public let subjectLine: String
    /// The campaign's preview text, if set.
    public let previewText: String?
    /// The date and time the campaign was sent.
    public let sendTime: Date

    /// Creates campaign metadata for a newsletter issue.
    ///
    /// - Parameters:
    ///   - slug: The URL-safe slug used for the issue's file name.
    ///   - issueNo: The issue number assigned while selecting campaigns.
    ///   - campaignID: The Mailchimp campaign identifier.
    ///   - longArchiveURL: The public campaign-archive URL for the issue.
    ///   - featuredImageURL: The image to feature for the issue, if any.
    ///   - title: The campaign's internal title.
    ///   - subjectLine: The subject line the campaign was sent with.
    ///   - previewText: The campaign's preview text, if set.
    ///   - sendTime: The date and time the campaign was sent.
    public init(
      slug: String,
      issueNo: Int,
      campaignID: String,
      longArchiveURL: URL,
      featuredImageURL: URL? = nil,
      title: String,
      subjectLine: String,
      previewText: String? = nil,
      sendTime: Date
    ) {
      self.slug = slug
      self.issueNo = issueNo
      self.campaignID = campaignID
      self.longArchiveURL = longArchiveURL
      self.featuredImageURL = featuredImageURL
      self.title = title
      self.subjectLine = subjectLine
      self.previewText = previewText
      self.sendTime = sendTime
    }
  }
}
