//
//  Source.swift
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

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
extension Newsletter {
  /// A fully-resolved newsletter issue: the campaign metadata together with its
  /// rendered HTML and Markdown.
  public struct Source: Sendable {
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
    /// The campaign's preview text, unquoted and unescaped, if set.
    public let previewText: String?
    /// The date and time the campaign was sent.
    public let sendTime: Date
    /// The campaign's archive HTML, as fetched from Mailchimp.
    public let html: String
    /// The issue body, converted from ``html`` to Markdown.
    public let markdown: String

    internal init(campaign: Campaign, html: String, markdown: String) {
      slug = campaign.slug
      issueNo = campaign.issueNo
      campaignID = campaign.campaignID
      longArchiveURL = campaign.longArchiveURL
      featuredImageURL = campaign.featuredImageURL
      title = campaign.title
      subjectLine = campaign.subjectLine
      previewText = campaign.previewText?.dequote().fixUnicodeEscape()
      sendTime = campaign.sendTime
      self.html = html
      self.markdown = markdown
    }
  }
}
