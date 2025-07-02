//
//  NexusLogLevel.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

/// Represents the severity of a log message..
/// Ordered from least to most critical: `.debug` < `.info` < `.success` < `.warning` < `.error` < `.fault`.
public enum NexusLogLevel: Int, Sendable, Comparable, CaseIterable {

    /// Detailed debug info used during development.
    /// Example: view lifecycle events, API request payloads.
    case debug = 0

    /// Informational messages about normal app behavior.
    /// Example: screen navigation, configuration updates, user interaction.
    case info

    /// Key positive events that may be useful for analytics or QA.
    /// Example: login success, purchase completed.
    case success

    /// Recoverable issues or unusual conditions.
    /// Example: missing optional field, entering degraded mode.
    case warning

    /// Expected but unrecoverable errors that require developer attention.
    /// Example: decoding failure, file not found, unauthorized response.
    case error

    /// Entered a expected and critical state that should never occur.
    case fault

    /// Emoji for quick visual identification in logs.
    public var emoji: String {
        switch self {
        case .debug:     return "🟪"
        case .info:      return "🟦"
        case .success:   return "🟩"
        case .warning:   return "🟨"
        case .error:     return "🟥"
        case .fault:     return "⬛️"
        }
    }

    /// Uppercase string name for use in log formatting.
    public var name: String {
        switch self {
        case .debug:     return "DEBUG"
        case .info:      return "INFO"
        case .success:   return "SUCCESS"
        case .warning:   return "WARNING"
        case .error:     return "ERROR"
        case .fault:     return "FAULT"
        }
    }

    /// Compares severity between two log levels.
    public static func < (lhs: NexusLogLevel, rhs: NexusLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
