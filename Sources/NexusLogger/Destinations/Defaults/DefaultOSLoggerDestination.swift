//
//  DefaultOSLoggerDestination.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation
import os

/// A logger destination that routes logs to Apple's Unified Logging system (os.Logger),
public struct DefaultOSLoggerDestination: NexusLogDestination {
    
    private let logger: Logger
    private let queue: DispatchQueue

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category:  String = "NexusLogger"
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.queue  = DispatchQueue(
            label: "\(subsystem).\(category)",
            qos: .utility
        )
    }

    private func osLogType(for level: NexusLogLevel) -> OSLogType {
        switch level {
        case .debug:   return .debug
        case .info:    return .info
        case .notice:  return .default
        case .warning: return .error
        case .error:   return .error
        case .fault:   return .fault
        }
    }

    public func log(
        level: NexusLogLevel,
        time: String,
        bundleName: String,
        appVersion: String,
        fileName: String,
        lineNumber: String,
        threadName: String,
        functionName: String,
        message: String,
        attributes: [String: String]? = nil
    ) async {
        // 1) Build the log string synchronously
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let nonEmpty = trimmed.isEmpty ? "<no message>" : trimmed

        let sections = [
            "\(level.emoji)\(level.name)",
            sanitizeString(time),
            sanitizeString(bundleName),
            sanitizeString(appVersion),
            "\(sanitizeString(fileName)):\(lineNumber)",
            sanitizeString(threadName),
            sanitizeString(functionName),
            "\"\(sanitizeString(nonEmpty))\""
        ]
        let base = sections.joined(separator: "|")

        let attrPart: String
        if let attrs = attributes, !attrs.isEmpty {
            let kvs = attrs
                .map { sanitizeString($0.key) + "=" + sanitizeString($0.value) }
                .joined(separator: ",")
            attrPart = "|\(kvs)"
        } else {
            attrPart = ""
        }

        let output = base + attrPart

        // 2) Enqueue the actual os.Logger call on our serial queue
        queue.async {
            self.logger.log(
                level: self.osLogType(for: level),
                "\(output)"
            )
        }
    }

    private func sanitizeString(_ input: String) -> String {
        input
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
            .replacingOccurrences(of: "|", with: "\\|")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "=", with: "\\=")
    }
}
