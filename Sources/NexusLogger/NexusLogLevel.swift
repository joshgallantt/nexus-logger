//
//  NexusLogLevel.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

public enum NexusLogLevel: Int, Sendable, Comparable, CaseIterable {
    case debug = 0  // Lowest severity
    case info
    case success
    case warning
    case error
    case critical   // Highest severity

    public var emoji: String {
        switch self {
        case .debug:     return "🟣"
        case .info:      return "🔵"
        case .success:   return "🟢"
        case .warning:   return "🟡"
        case .error:     return "🔴"
        case .critical:  return "⚫️"
        }
    }

    public var name: String {
        switch self {
        case .debug:     return "DEBUG"
        case .info:      return "INFO"
        case .success:   return "SUCCESS"
        case .warning:   return "WARNING"
        case .error:     return "ERROR"
        case .critical:  return "CRITICAL"
        }
    }

    public static func < (lhs: NexusLogLevel, rhs: NexusLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

