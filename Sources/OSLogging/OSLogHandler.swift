import Foundation
import Logging
import os

public struct OSLogHandler: Logging.LogHandler {

  private let logger: os.Logger
  public var metadata: Logging.Logger.Metadata = [:]
  public var logLevel: Logging.Logger.Level = .info

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
