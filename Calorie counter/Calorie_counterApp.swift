//
//  Calorie_counterApp.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/8/25.
//



import SwiftUI


@main
struct CalorieCounterApp: App {
    
    let persistenceController = PersistenceController.shared // Ensure the Core Data stack is initialized here
    @StateObject private var tracker = DailyDataTracker() // Initialize DailyDataTracker
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, persistenceController.context)
                    .environmentObject(tracker) // Pass tracker to environment
            
        }
    }
}

struct SplashScreenView: View {
    @State private var isActive = false
    @AppStorage("appState") private var appState: String = "setup" // Tracks the app's current state

    var body: some View {
        VStack {
            if isActive {
                // Navigate dynamically based on appState
                if appState == "dashboard" {
                    DashboardView()
                } else if appState == "dashboardSetup" {
                    DashboardSetupView()
                } else {
                    UserSetupView()
                }
            } else {
                // Display the splash screen
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .onAppear {
                        // Simulate a delay for the splash screen
                        withAnimation(.easeOut(duration: 2)) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isActive = true
                            }
                        }
                    }
            }
        }
    }
}


