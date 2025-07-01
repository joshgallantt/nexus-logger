//
//  NexusLog.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

public struct NexusLog: Sendable {
    let level: NexusLogLevel
    let time: String
    let bundleName: String
    let appVersion: String
    let fileName: String
    let functionName: String
    let lineNumber: String
    let message: String
    let attributes: [String: String]?
}
