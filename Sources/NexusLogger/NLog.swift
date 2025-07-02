//
//  NLog.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

/// Logs a message asynchronously through the shared `NexusLogger` instance.
/// 
/// - Parameter message:   The text of the log message.
/// - Parameter level:     The severity level of the log. Defaults to `.info`.
///     - `.debug`  : Detailed debug info (e.g., view lifecycle, API payloads)
///     - `.info`   : Informational messages (e.g., screen nav, config updates)
///     - `.success`: Positive outcomes (e.g., login success, sync finished)
///     - `.warning`: Recoverable but unusual conditions (e.g., network retry, missing optional field)
///     - `.error`  :  Expected but unrecoverable errors that require developer attention. (e.g., decoding failure)
///     - `.fault`  :  Unexpected and critical issues that should never occur.
/// - Parameter attributes: Optional key/value metadata to attach.
/// - Note: Fires off logging in a detached `Task`—does not block the caller.
public func NLog(
    _ message: String,
    _ level: NexusLogLevel = .info,
    attributes: [String: String]? = nil,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
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
