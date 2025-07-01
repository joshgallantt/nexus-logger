//
//  NexusLogger.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

protocol NexusLoggerProtocol: Sendable {
    func log(
        _ message: String,
        _ level: NexusLogLevel,
        attributes: [String: String]?,
        file: String,
        function: String,
        line: Int
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
        function: String = #function,
        line: Int = #line
    ) {
        let now = isoFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent

        let msg = NexusLog(
            level: level,
            time: now,
            bundleName: bundleInfo.name,
            appVersion: bundleInfo.version,
            fileName: fileName,
            functionName: function,
            lineNumber: String(line),
            message: message,
            attributes: attributes
        )

        Task {
            await dispatcher.enqueue(msg)
        }
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
                            functionName: msg.functionName,
                            lineNumber: msg.lineNumber,
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
        let bundleInfo = BundleInfo()
        
        return NexusLog(
            level: .critical,
            time: isoFormatter.string(from: Date()),
            bundleName: bundleInfo.name,
            appVersion: bundleInfo.version,
            fileName: (file as NSString).lastPathComponent,
            functionName: function,
            lineNumber: String(line),
            message: "NexusLogger buffer exceeded \(maxQueueSize)! Oldest log was dropped.",
            attributes: nil
        )
    }
}
