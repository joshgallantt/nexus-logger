//
//  NexusLogger.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

public protocol NexusLoggerProtocol: Actor, Sendable {
    nonisolated func log(
        _ message: String,
        _ level: NexusLogLevel,
        attributes: [String: String]?,
        file: String,
        line: Int,
        thread: String,
        function: String
    )

    func addDestination(_ destination: NexusLogDestination)
}

//public actor NexusLogger: NexusLoggerProtocol {
//
//    public static let shared = NexusLogger()
//
//    package var destinations: [NexusLogDestination] = []
//
//    private let bundleInfo = BundleInfo()
//
//    private let isoFormatter: ISO8601DateFormatter = {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return formatter
//    }()
//
//    private let logStream: AsyncStream<NexusLog>
//    private let logContinuation: AsyncStream<NexusLog>.Continuation
//
//    public init() {
//        (logStream, logContinuation) = AsyncStream<NexusLog>.makeStream()
//
//        Task {
//            for await logEntry in logStream {
//                await processLog(logEntry)
//            }
//        }
//    }
//
//    // isolated method for safely mutating the destinations array
//    public func addDestination(_ destination: NexusLogDestination) {
//        destinations.append(destination)
//    }
//
//    // enqueue logs from nonisolated context using continuation
//    public nonisolated func log(
//        _ message: String,
//        _ level: NexusLogLevel,
//        attributes: [String: String]?,
//        file: String,
//        line: Int,
//        thread: String,
//        function: String
//    ) {
//        let entry = NexusLog(
//            level: level,
//            time: ISO8601DateFormatter().string(from: Date()),
//            bundleName: BundleInfo().name,
//            appVersion: BundleInfo().version,
//            fileName: (file as NSString).lastPathComponent,
//            functionName: function,
//            lineNumber: String(line),
//            threadName: thread,
//            message: message,
//            attributes: attributes
//        )
//
//        logContinuation.yield(entry)
//    }
//
//    private func processLog(_ entry: NexusLog) async {
//        for dest in destinations {
//            await dest.log(
//                level: entry.level,
//                time: entry.time,
//                bundleName: entry.bundleName,
//                appVersion: entry.appVersion,
//                fileName: entry.fileName,
//                lineNumber: entry.lineNumber,
//                threadName: entry.threadName,
//                functionName: entry.functionName,
//                message: entry.message,
//                attributes: entry.attributes
//            )
//        }
//    }
//}

public actor NexusLogger {

    public static let shared = NexusLogger()

    private let logStream: AsyncStream<NexusLog>
    private let logContinuation: AsyncStream<NexusLog>.Continuation

    public init() {
        (logStream, logContinuation) = AsyncStream.makeStream()

        Task {
            for await logEntry in logStream {
                await processLog(logEntry)
            }
        }
    }

    public nonisolated func log(
        _ message: String,
        _ level: NexusLogLevel,
        attributes: [String: String]?,
        file: String,
        line: Int,
        thread: String,
        function: String
    ) {
        let entry = NexusLog(
            level: level,
            time: ISO8601DateFormatter().string(from: Date()),
            bundleName: BundleInfo().name,
            appVersion: BundleInfo().version,
            fileName: (file as NSString).lastPathComponent,
            functionName: function,
            lineNumber: String(line),
            threadName: thread,
            message: message,
            attributes: attributes
        )

        logContinuation.yield(entry)
    }

    private func processLog(_ entry: NexusLog) async {
        let destinations = DestinationStore.shared.destinations

        for dest in destinations {
            await dest.log(
                level: entry.level,
                time: entry.time,
                bundleName: entry.bundleName,
                appVersion: entry.appVersion,
                fileName: entry.fileName,
                lineNumber: entry.lineNumber,
                threadName: entry.threadName,
                functionName: entry.functionName,
                message: entry.message,
                attributes: entry.attributes
            )
        }
    }
}

public final class DestinationStore: @unchecked Sendable {
    public static let shared = DestinationStore()

    private var _destinations: [NexusLogDestination] = []
    private let queue = DispatchQueue(label: "com.nexuslogger.destinations.queue")

    private init() {}

    var destinations: [NexusLogDestination] {
        queue.sync { _destinations }
    }

    public func addDestination(_ destination: NexusLogDestination) {
        queue.sync {
            _destinations.append(destination)
        }
    }
}


