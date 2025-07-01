//
//  nexus_logger_exampleApp.swift
//  NexusLoggerExample
//
//  Created by Josh Gallant on 01/07/2025.
//

import SwiftUI
import NexusLogger

@main
struct NexusLoggerExampleApp: App {
    
    init() {
        Task {
            await NexusLogger.shared.addDestination(DefaultOSLoggerDestination())
            NLog("   ", .success)
            NLog("Logger|initialized", .success)
            NLog("Logger initialized", .debug)
            NLog("Logger initialized", .info)
            NLog("Logger initialized", .success)
            NLog("Logger initialized", .warning)
            NLog("Logger initialized", .error)
            NLog("Logger initialized", .fault)
        }
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
