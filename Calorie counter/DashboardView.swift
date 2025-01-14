//
//  DashboardView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @AppStorage("appState") private var appState: String = "dashboard" // Default to dashboard
    @State private var profilePicture: UIImage? = nil
    @State private var name: String = ""
    @State private var currentWeight: Int = 0
    @State private var goalWeight: Int = 0
    @State private var goalDate: Date = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile and Summary
                HStack(alignment: .top, spacing: 16) {
                    if let profilePicture {
                        Image(uiImage: profilePicture)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 120, height: 120)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    }

                    VStack(alignment: .leading) {
                        Text(name.isEmpty ? "No Name" : name)
                            .font(.system(size: 30, weight: .bold))
                        Text("Current Weight: \(currentWeight) lbs")
                            .font(.body)
                        Text("Goal Weight: \(goalWeight) lbs")
                            .font(.body)
                        Text("Goal Date: \(goalDate, style: .date)")
                            .font(.body)
                    }
                    Spacer()
                }
                .padding()

                // Import and Use `DailyProgressView`
                DailyProgressView()
                    .padding(.horizontal)

                // Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        // Action for "Weigh In" button
                        print("Weigh In tapped")
                    }) {
                        HStack {
                            Image(systemName: "scalemass")
                            Text("Weigh In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    NavigationLink(destination: PastLedgerView()) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("Progression")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Reset Button
                Button(action: {
                    clearUserData() // Clear all stored user data
                    appState = "setup" // Reset to start from the setup flow
                }) {
                    Text("Restart Setup")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .onAppear {
                loadUserData() // Fetch user data when view appears
            }
        }
    }

    // MARK: - Load User Data
    private func loadUserData() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            if let userProfile = try PersistenceController.shared.context.fetch(fetchRequest).first {
                name = userProfile.name ?? "John Doe"
                currentWeight = Int(userProfile.weight)
                goalWeight = Int(userProfile.goalWeight)
                goalDate = userProfile.targetDate ?? Date()
                if let profileImageData = userProfile.profilePicture {
                    profilePicture = UIImage(data: profileImageData)
                }
            }
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }

    // MARK: - Clear User Data
    private func clearUserData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserProfile.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try PersistenceController.shared.context.execute(deleteRequest)
            try PersistenceController.shared.context.save()
            print("User data cleared successfully.")
        } catch {
            print("Failed to clear user data: \(error)")
        }
    }
}

#Preview {
    DashboardView()
}

