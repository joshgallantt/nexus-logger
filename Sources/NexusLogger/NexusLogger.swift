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
    
    private let bundleInfo: BundleInfo
    
    private let isoFormatter: ISO8601DateFormatter
    private lazy var dispatcher: NexusLogDispatcher = NexusLogDispatcher(destinations: { [weak self] in self?.destinations ?? [] })

    public init() {
        bundleInfo = BundleInfo()
        isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    public func addDestination(_ destination: NexusLogDestination) {
        destinations.append(destination)
    }

    public func log(
        _ message: String,
        _ level: NexusLogLevel = .info,
        attributes: [String: String]? = nil,
        file: String = #file,
        line: Int = #line,
        thread: String,
        function: String = #function
    ) async {
        let now = isoFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent

        let entry = NexusLog(
            level: level,
            time: now,
            bundleName: bundleInfo.name,
            appVersion: bundleInfo.version,
            fileName: fileName,
            functionName: function,
            lineNumber: String(line),
            threadName: thread,
            message: message,
            attributes: attributes
        )

        await dispatcher.enqueue(entry)
    }
}

public actor NexusLogDispatcher {
    private var queue: [NexusLog] = []
    private let destinations: () -> [NexusLogDestination]
    private var processingTask: Task<Void, Never>? = nil
    private let maxQueueSize = 1000
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public init(destinations: @escaping () -> [NexusLogDestination]) {
        self.destinations = destinations
    }

    package func enqueue(_ msg: NexusLog) {
        if queue.count >= maxQueueSize {
            queue.removeFirst()
            queue.insert(createMemoryExceededLog(), at: 0)
        }

        queue.append(msg)
        processQueueIfNeeded()
    }

    private func processQueueIfNeeded() {
        guard processingTask == nil else { return }

        processingTask = Task {
            defer { processingTask = nil }
            await processQueue()
        }
    }

    private func processQueue() async {
        while let msg = queue.first {
            queue.removeFirst()

            await withTaskGroup(of: Void.self) { group in
                for destination in destinations() {
                    group.addTask {
                        await destination.log(
                            level: msg.level,
                            time: msg.time,
                            bundleName: msg.bundleName,
                            appVersion: msg.appVersion,
                            fileName: msg.fileName,
                            lineNumber: msg.lineNumber,
                            threadName: msg.threadName,
                            functionName: msg.functionName,
                            message: msg.message,
                            attributes: msg.attributes
                        )
                    }
                }
            }
        }
    }

    private func createMemoryExceededLog(
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> NexusLog {

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

        return NexusLog(
            level: .fault,
            time: isoFormatter.string(from: Date()),
            bundleName: BundleInfo().name,
            appVersion: BundleInfo().version,
            fileName: (file as NSString).lastPathComponent,
            functionName: function,
            lineNumber: String(line),
            threadName: threadName,
            message: "NexusLogger buffer exceeded \(maxQueueSize)! Oldest log was dropped.",
            attributes: nil
        )
    }
}
