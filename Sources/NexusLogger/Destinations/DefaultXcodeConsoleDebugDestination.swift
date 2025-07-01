//
//  XcodeConsoleDebugDestination.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

public final class DefaultXcodeConsoleDebugDestination: NexusLogDestination, @unchecked Sendable {

    public init() {}

    public func log(
        level: NexusLogLevel,
        time: String,
        bundleName: String,
        appVersion: String,
        fileName: String,
        functionName: String,
        lineNumber: String,
        message: String,
        attributes: [String: String]?
    ) async {
        // 1) Thread label
        let thread: String = {
            if Thread.isMainThread {
                return "main"
            } else if let name = Thread.current.name, !name.isEmpty {
                return name
            } else {
                return String(format: "%p", Thread.current)
            }
        }()

        // 2) Short file:line
        let fileOnly = (fileName as NSString).lastPathComponent
        let loc      = "\(fileOnly):\(lineNumber)"

        // 3) Attributes
        let attrStr: String
        if let attrs = attributes, !attrs.isEmpty {
            let joined = attrs.map { "\($0)=\($1)" }.joined(separator: ", ")
            attrStr = " { \(joined) }"
        } else {
            attrStr = ""
        }

        // 4) Build the plain text of the log
        let raw = """
        \(time) \(level.emoji)\(level.name) [\(thread)] \(loc) \(functionName) – \(message)\(attrStr)
        """

        // 5) Pick a background code inline
        let bg: String = {
            switch level {
            case .debug:    return "\u{001B}[45m"   // magenta
            case .info:     return "\u{001B}[44m"   // blue
            case .success:  return "\u{001B}[42m"   // green
            case .warning:  return "\u{001B}[43m"   // yellow
            case .error:     return "\u{001B}[41m"  // red
            case .critical: return "\u{001B}[101m"  // bright red
            }
        }()

        let reset = "\u{001B}[0m"

        // 6) Wrap the whole line and print
        let coloredLine = bg + raw + reset
        print(coloredLine)
    }
}
