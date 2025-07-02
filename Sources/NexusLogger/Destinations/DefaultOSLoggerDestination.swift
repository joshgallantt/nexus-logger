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

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category: String = "NexusLogger"
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    private func osLogType(for level: NexusLogLevel) -> OSLogType {
        switch level {
        case .debug:    return .debug
        case .info:     return .info
        case .success:  return .default
        case .warning:  return .error
        case .error:    return .error
        case .fault:    return .fault
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
        // 0) Normalize the message
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let nonEmpty = trimmed.isEmpty ? "<no message>" : trimmed

        // 1) Sanitize fields
        let msgField     = sanitizeString(nonEmpty)
        let timeField    = sanitizeString(time)
        let bundleField  = sanitizeString(bundleName)
        let versionField = sanitizeString(appVersion)
        let fileLine     = "\(sanitizeString(fileName)):\(lineNumber)"
        let threadField  = sanitizeString(threadName)
        let funcField    = sanitizeString(functionName)

        // 2) Build sections
        let sections = [
            "\(level.emoji)\(level.name)",
            timeField,
            bundleField,
            versionField,
            fileLine,
            threadField,
            funcField,
            "\"\(msgField)\""
        ]
        
        let sectionsDelimitted = sections.joined(separator: "|")

        // 3) Append attributes if present
        let attrPart: String
        if let pairs = attributes, !pairs.isEmpty {
            let kvs = pairs
                .map { key, val in "\(sanitizeString(key))=\(sanitizeString(val))" }
                .joined(separator: ",")
            attrPart = "|\(kvs)"
        } else {
            attrPart = ""
        }

        // 4) Emit to os.Logger
        let output = sectionsDelimitted + attrPart
        logger.log(level: osLogType(for: level), "\(output)")
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
