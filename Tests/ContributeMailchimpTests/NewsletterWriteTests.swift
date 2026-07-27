//
//  NewsletterWriteTests.swift
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

/// Covers writing newsletter issues to disk through Contribute's generic writer.
@Suite internal struct NewsletterWriteTests {
  /// Creates an empty scratch directory for one test.
  ///
  /// - Returns: The directory URL.
  /// - Throws: An error if the directory cannot be created.
  private static func makeScratchDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("ContributeMailchimpTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }

  /// Each issue becomes one `<issueNo>-<slug>.md` file whose contents match the
  /// document the content builder renders.
  @Test internal func writesOneMarkdownFilePerIssue() throws {
    let directory = try Self.makeScratchDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let source = NewsletterFixtures.source(campaign: try NewsletterFixtures.campaign())
    try Newsletter.write(
      from: [source],
      atContentPathURL: directory,
      fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
      using: { $0 }
    )

    let fileURL = directory.appendingPathComponent("42-whats-new-in-swift-6-4.md")
    let written = try String(contentsOf: fileURL, encoding: .utf8)
    let expected = try Newsletter.contentBuilder().content(from: source) { $0 }

    #expect(written == expected)
    #expect(written.hasSuffix("Hello, newsletter.\n"))
  }

  /// An issue that has already been written is left alone by default, so hand
  /// edits to an imported newsletter survive the next import.
  @Test internal func existingIssuesAreLeftAloneByDefault() throws {
    let directory = try Self.makeScratchDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let fileURL = directory.appendingPathComponent("42-whats-new-in-swift-6-4.md")
    try "hand edited".write(to: fileURL, atomically: true, encoding: .utf8)

    let source = NewsletterFixtures.source(campaign: try NewsletterFixtures.campaign())
    try Newsletter.write(
      from: [source],
      atContentPathURL: directory,
      fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
      using: { $0 }
    )

    #expect(try String(contentsOf: fileURL, encoding: .utf8) == "hand edited")
  }

  /// Passing `shouldOverwriteExisting` replaces the file on disk.
  @Test internal func existingIssuesAreReplacedWhenOverwritingIsRequested() throws {
    let directory = try Self.makeScratchDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let fileURL = directory.appendingPathComponent("42-whats-new-in-swift-6-4.md")
    try "hand edited".write(to: fileURL, atomically: true, encoding: .utf8)

    let source = NewsletterFixtures.source(campaign: try NewsletterFixtures.campaign())
    try Newsletter.write(
      from: [source],
      atContentPathURL: directory,
      fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
      using: { $0 },
      options: MarkdownContentBuilderOptions(
        shouldOverwriteExisting: true,
        includeMissingPrevious: false
      )
    )

    let written = try String(contentsOf: fileURL, encoding: .utf8)

    #expect(written != "hand edited")
    #expect(written.hasPrefix("---\n"))
    #expect(written.contains("issueNo: 42"))
  }
}
