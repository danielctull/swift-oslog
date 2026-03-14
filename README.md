# swift-oslog

An implementation of [swift-log](https://github.com/apple/swift-log)'s [`LogHandler`](https://github.com/apple/swift-log/blob/main/Sources/Logging/LogHandler.swift) that sends logs to Apple's [os log](https://developer.apple.com/documentation/os) system.

## Quick Guide

The following snippet shows how to add OSLogging to your Swift Package:

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "YourApp",
    dependencies: [
      .package(url: "https://github.com/danielctull/swift-oslog", from: "1.0.0")
    ],
    targets: [
      .target(
        name: "YourApp",
        dependencies: [
          .product(name: "OSLogging", package: "swift-oslog")
        ]
      )
    ]
)
```

Then return the log handler in the bootstrap:
  
  ```swift
  import Logging
  import OSLogging
  
  LoggingSystem.bootstrap { label in
    OSLogHandler(subsystem: "your.subsystem.name", category: label)
  }
  ```

Then start logging:

```swift
import Logging

// Create a logger
let logger = Logger(label: "Network")

// Log at different levels
logger.info("Request started")
logger.error("Something went wrong", metadata: ["error": "\(error)"])

// Add metadata for context
var requestLogger = logger
requestLogger[metadataKey: "request-id"] = "\(UUID())"
requestLogger.info("Processing request")
```

## See 

* [swift-log](https://github.com/apple/swift-log)
* [os log documentation](https://developer.apple.com/documentation/os)
