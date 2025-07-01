//
//  NLog.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//


public func NLog(
    _ message: String,
    _ level: NexusLogLevel = .info,
    attributes: [String: String]? = nil,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    
    let log = NexusLog(level: .critical, time: "", bundleName: "", appVersion: "", fileName: "", functionName: "", lineNumber: "", message: "", attributes: nil)
    Task {
        await NexusLogger.shared.log(
            message,
            level,
            attributes: attributes,
            file: file,
            function: function,
            line: line
        )
    }
}
