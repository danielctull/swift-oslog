import Foundation
import Logging
import os

/// `LogHandler` implementation that sends logs to Apple's
/// [os log](https://developer.apple.com/documentation/os) system.
///
/// > Note:
/// > There are seven levels in swift-log, and five in os log. These are
/// > converted in the following way:
/// >
/// > swift-log | os log
/// > ----------|--------
/// > trace     | debug
/// > debug     | debug
/// > info      | info
/// > notice    | default
/// > warning   | default
/// > error     | error
/// > critical  | fault
public struct OSLogHandler: Logging.LogHandler {

  private let logger: os.Logger
  public var metadata: Logging.Logger.Metadata = [:]
  public var logLevel: Logging.Logger.Level = .info

  /// Creates a log handler.
  ///
  /// Typically, you will want to create this in the builder of
  /// `LoggingSystem.bootstrap` early in your application lifecycle.
  ///
  /// Use the label provided in the builder as the category:
  ///
  /// ```swift
  /// LoggingSystem.bootstrap { label in
  ///   OSLogHandler(subsystem: "your.subsystem.name", category: label)
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - subsystem: String that identifies the subsystem that emits
  ///                signposts. Typically, you use the same value as your app’s
  ///                bundle ID.
  ///   - category: String that the system uses to categorize emitted signposts.
  ///               This should typically be the label provided by the swift log
  ///               logging system.
  public init(subsystem: String, category: String) {
    logger = os.Logger(subsystem: subsystem, category: category)
  }

  public subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
    get { metadata[key] }
    set { metadata[key] = newValue }
  }

  public func log(
    level: Logging.Logger.Level,
    message: Logging.Logger.Message,
    metadata: Logging.Logger.Metadata?,
    source: String,
    file: String,
    function: String,
    line: UInt
  ) {
    var message = message.description

    let metadata = self.metadata.merging(metadata ?? [:]) { _, rhs in rhs }
    if let formattedMetadata = metadata.formatted {
      message += " " + formattedMetadata
    }

    logger.log(
      level: OSLogType(level),
      "\(message, privacy: .public)"
    )
  }
}

extension Logging.Logger.Metadata {

  fileprivate var formatted: String? {
    guard !isEmpty else { return nil }
    return sorted { $0.key < $1.key }
      .map { "[\($0)=\($1)]" }
      .joined(separator: " ")
  }
}

extension OSLogType {

  fileprivate init(_ level: Logging.Logger.Level) {
    self = switch level {
    case .trace:    .debug
    case .debug:    .debug
    case .info:     .info
    case .notice:   .default
    case .warning:  .default
    case .error:    .error
    case .critical: .fault
    }
  }
}
