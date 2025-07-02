//
//  NexusLogger.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

public protocol NexusLoggerProtocol: Sendable {
    func log(
        _ message: String,
        _ level: NexusLogLevel,
        attributes: [String: String]?,
        file: String,
        line: Int,
        thread: String,
        function: String
    ) async
}

public actor NexusLogger: NexusLoggerProtocol {
    
    public static let shared = NexusLogger()
    
    package var destinations: [NexusLogDestination] = []
    
    private let bundleInfo = BundleInfo()
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    public init() {}
    
    public func addDestination(_ destination: NexusLogDestination) {
        destinations.append(destination)
    }
    
    public func log(
        _ message: String,
        _ level: NexusLogLevel = .info,
        attributes: [String : String]? = nil,
        file: String = #file,
        line: Int = #line,
        thread: String,
        function: String = #function
    ) async {
        let timestamp = isoFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        
        let entry = NexusLog(
            level:        level,
            time:         timestamp,
            bundleName:   bundleInfo.name,
            appVersion:   bundleInfo.version,
            fileName:     fileName,
            functionName: function,
            lineNumber:   String(line),
            threadName:   thread,
            message:      message,
            attributes:   attributes
        )
        
        for dest in destinations {
            await dest.log(
                level:        entry.level,
                time:         entry.time,
                bundleName:   entry.bundleName,
                appVersion:   entry.appVersion,
                fileName:     entry.fileName,
                lineNumber:   entry.lineNumber,
                threadName:   entry.threadName,
                functionName: entry.functionName,
                message:      entry.message,
                attributes:   entry.attributes
            )
        }
    }
}
