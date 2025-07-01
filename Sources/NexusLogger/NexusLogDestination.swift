//
//  LogDestination.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

/// Protocol for a Nexus Log Destination (e.g., system log, remote service).
public protocol NexusLogDestination: Sendable {
    /// Recieves the Log from Nexus Log, form and fire to your destination.
    ///
    /// - Parameters:
    ///   - level:        Severity (developer-provided)
    ///   - time:         Timestamp of the log
    ///   - bundleName:   Application Name
    ///   - appVersion:   Application version
    ///   - fileName:     Source file name
    ///   - lineNumber:   Line number
    ///   - threadName:   Originating Thread
    ///   - functionName: Function name
    ///   - message:      Log message (developer-provided)
    ///   - attributes:   Custom event fields (developer-provided)
    func log(
        level: NexusLogLevel,
        time: String,
        bundleName: String,
        appVersion: String,
        fileName: String,
        lineNumber: String,
        threadName: String,
        functionName: String,
        message: String,
        attributes: [String: String]?
    ) async
}
