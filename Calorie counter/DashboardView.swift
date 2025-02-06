//
//  DashboardView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext  // Access Core Data
    @FetchRequest(
        entity: UserProfile.entity(),
        sortDescriptors: []
    ) private var userProfile: FetchedResults<UserProfile>

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Welcome Message
                Text("Welcome to Your Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Styles.primaryText)

                // Profile Summary Box
                ZStack {
                    Styles.secondaryBackground
                        .cornerRadius(10)
                        .shadow(radius: 5)

                    VStack(spacing: 10) {
                        if let user = userProfile.first {
                            Text("Hello, \(user.name ?? "User")!")
                                .font(.title)
                                .fontWeight(.semibold)

                            Text("Current Weight: \(user.currentWeight) \(user.useMetric ? "kg" : "lbs")")
                                .font(.headline)

                            Text("Goal Weight: \(user.goalWeight) \(user.useMetric ? "kg" : "lbs")")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)

                            if let targetDate = user.targetDate {
                                Text("Target Date: \(formattedDate(targetDate))")
                                    .font(.subheadline)
                                    .foregroundColor(Styles.secondaryText)
                            }
                        } else {
                            Text("No user data available.")
                                .font(.headline)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                // Refresh Button
                Button(action: {
                    reloadData()
                }) {
                    Text("Refresh Data")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
    }

    // Function to Format Date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Function to Reload Data (You Can Expand This Later)
    private func reloadData() {
        do {
            try viewContext.save()
        } catch {
            print("Error reloading data: \(error.localizedDescription)")
        }
    }
}

