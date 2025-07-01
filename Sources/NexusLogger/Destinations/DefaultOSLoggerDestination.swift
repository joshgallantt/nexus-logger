//
//  DefaultOSLoggerDestination.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation
import os

/// A logger destination that routes logs to Apple's Unified Logging system (os.Logger),
/// with emoji and machine-friendly, delimiter-separated output.
public final class DefaultOSLoggerDestination: NexusLogDestination {
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
        case .critical: return .fault
        }
    }

    /// 🟢SUCCESS|2025-06-19T20:26:45.757Z|com.my.bundle|v1.0|Main.swift:31|init()|"Logger initialized"|key=value,...
    public func log(
        level: NexusLogLevel,
        time: String,
        bundleName: String,
        appVersion: String,
        fileName: String,
        functionName: String,
        lineNumber: String,
        message: String,
        attributes: [String: String]? = nil
    ) async {
        let emoji       = level.emoji
        let levelText   = level.name
        let isoTime     = time
        let bundle      = bundleName
        let version     = appVersion
        let fileLine    = "\(fileName):\(lineNumber)"
        let function    = functionName
        let quotedMsg   = "\"\(message)\""
        let attrString  = attributes?
            .map { "\($0)=\($1)" }
            .joined(separator: ",")
            ?? ""

        // Compose fields: LEVEL|TIME|BUNDLE|VERSION|FILE:LINE|FUNCTION|"MESSAGE"|[ATTRS]
        let formatted = [
            "\(emoji)\(levelText)",
            isoTime,
            bundle,
            "v\(version)",
            fileLine,
            function,
            quotedMsg
        ].joined(separator: "|")
        let output = attrString.isEmpty
            ? formatted
            : formatted + "|" + attrString

        logger.log(level: osLogType(for: level), "\(output)")
    }
}
