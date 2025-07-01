//
//  NLog.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

public func NLog(
    _ message: String,
    _ level: NexusLogLevel = .info,
    attributes: [String: String]? = nil,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    // 1) Determine a human-readable thread name (main, named queue, or numeric ID)
    let threadName: String = {
        if Thread.isMainThread {
            return "main"
        } else if let name = Thread.current.name, !name.isEmpty {
            return name
        } else {
            var tid: UInt64 = 0
            pthread_threadid_np(nil, &tid)
            return "thread-\(tid)"
        }
    }()

    Task {
        await NexusLogger.shared.log(
            message,
            level,
            attributes: attributes,
            file: file,
            line: line,
            thread: threadName,
            function: function
        )
    }
}
