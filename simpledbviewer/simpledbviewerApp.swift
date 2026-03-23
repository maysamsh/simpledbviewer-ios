//
//  simpledbviewerApp.swift
//  simpledbviewer
//

import SwiftUI

@main
struct simpledbviewerApp: App {
    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            let coordinator = container.makeCredentialsCoordinator()
            TabView {
                HomeView(
                    viewModel: container.makeHomeViewModel(coordinator: coordinator),
                    coordinator: coordinator)
                    .tabItem {
                        Label("Database", systemImage: "cylinder.split.1x2")
                    }

                SettingsView(viewModel: container.makeSettingsViewModel())
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .task { container.performStartup() }
            .preferredColorScheme(ProcessInfo.processInfo.arguments.contains("-FASTLANE_SNAPSHOT") ? .light : nil)
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

struct NeedSetupView: View {
    let launchSetup: () -> Void

    var body: some View {
        VStack {
            Text("You need to add your AWS secret and key first")

            Button {
                launchSetup()
            } label: {
                Text("Go to setup")
            }
        }
    }
}
