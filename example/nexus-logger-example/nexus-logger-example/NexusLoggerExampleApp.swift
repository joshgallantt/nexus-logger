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
            await NexusLogger.shared.addDestination(DefaultXcodeConsoleDebugDestination())
            NLog("Logger initialized", .success)
        }
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
