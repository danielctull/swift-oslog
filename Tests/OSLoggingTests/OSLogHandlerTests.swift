import Foundation
import Logging
import OSLog
import OSLogging
import Testing

@Suite("OSLogHandler")
struct OSLogHandlerTests {

  @Test func `metadata: getter`() {
    let key = UUID().uuidString
    let value = Logging.Logger.MetadataValue(stringLiteral: UUID().uuidString)
    var handler = OSLogHandler(subsystem: UUID().uuidString, category: UUID().uuidString)
    handler.metadata = [key: value]
    #expect(handler[metadataKey: key] == value)
  }

  @Test func `metadata: setter`() {
    let key = UUID().uuidString
    let value = Logging.Logger.MetadataValue(stringLiteral: UUID().uuidString)
    var handler = OSLogHandler(subsystem: UUID().uuidString, category: UUID().uuidString)
    handler[metadataKey: key] = value
    #expect(handler.metadata[key] == value)
  }

  @Test(arguments: Array<
    (Logging.Logger.Level, OSLogEntryLog.Level)
  >([
    (.info,     .info),
    (.notice,   .notice),
    (.warning,  .notice),
    (.error,    .error),
    (.critical, .fault),
  ]))
  func `log: message`(
    level: Logging.Logger.Level,
    expected: OSLogEntryLog.Level
  ) throws {
    let label = UUID().uuidString
    let message = UUID().uuidString

    let store = try OSLogStore(scope: .currentProcessIdentifier)
    let entries = try store.entries { subsystem in

      let logger = Logger(label: label) {
        OSLogHandler(subsystem: subsystem, category: $0)
      }

      logger.log(level: level, "\(message)")
    }

    try #require(entries.count == 1)

    let entry = entries[0]
    #expect(entry.level == expected)
    #expect(entry.category == label)
    #expect(entry.composedMessage == message)
  }

  @Test(arguments: Array<
    (Logging.Logger.Level, OSLogEntryLog.Level)
  >([
    (.info,     .info),
    (.notice,   .notice),
    (.warning,  .notice),
    (.error,    .error),
    (.critical, .fault),
  ]))
  func `log: message + metadata`(
    level: Logging.Logger.Level,
    expected: OSLogEntryLog.Level
  ) throws {
    let label = UUID().uuidString
    let message = UUID().uuidString
    let key = UUID().uuidString
    let value = UUID().uuidString

    let store = try OSLogStore(scope: .currentProcessIdentifier)
    let entries = try store.entries { subsystem in

      let logger = Logger(label: label) {
        OSLogHandler(subsystem: subsystem, category: $0)
      }

      logger.log(level: level, "\(message)", metadata: [key: .init(stringLiteral: value)])
    }

    try #require(entries.count == 1)

    let entry = entries[0]
    #expect(entry.level == expected)
    #expect(entry.category == label)
    #expect(entry.composedMessage == "\(message) [\(key)=\(value)]")
  }

  @Test(arguments: Array<
    (Logging.Logger.Level, OSLogEntryLog.Level)
  >([
    (.info,     .info),
    (.notice,   .notice),
    (.warning,  .notice),
    (.error,    .error),
    (.critical, .fault),
  ]))
  func `log: message + metadata + logger metadata`(
    level: Logging.Logger.Level,
    expected: OSLogEntryLog.Level
  ) throws {
    let label = UUID().uuidString
    let message = UUID().uuidString

    let value1 = UUID().uuidString
    let override1 = UUID().uuidString
    let value2 = UUID().uuidString
    let value3 = UUID().uuidString

    let store = try OSLogStore(scope: .currentProcessIdentifier)
    let entries = try store.entries { subsystem in

      let logger = Logger(label: label) {
        var handler = OSLogHandler(subsystem: subsystem, category: $0)
        handler.metadata = [
          "key1": .init(stringLiteral: value1),
          "key2": .init(stringLiteral: value2),
        ]
        return handler
      }

      logger.log(level: level, "\(message)", metadata: [
        "key1": .init(stringLiteral: override1),
        "key3": .init(stringLiteral: value3),
      ])
    }

    try #require(entries.count == 1)

    let entry = entries[0]
    #expect(entry.level == expected)
    #expect(entry.category == label)
    #expect(entry.composedMessage == "\(message) [key1=\(override1)] [key2=\(value2)] [key3=\(value3)]")
  }
}

extension OSLogStore {

  fileprivate func entries(performing action: (String) -> Void) throws -> [OSLogEntryLog] {

    let subsystem = "com.terminalui.test.\(UUID().uuidString)"
    let position = position(date: .now)

    action(subsystem)

    return try getEntries(at: position)
      .compactMap { $0 as? OSLogEntryLog }
      .filter { $0.subsystem == subsystem }
  }
}
