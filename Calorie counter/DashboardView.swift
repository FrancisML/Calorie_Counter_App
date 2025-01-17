//
//  DashboardView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @AppStorage("appState") private var appState: String = "dashboard"
    @State private var profilePicture: UIImage? = nil
    @State private var name: String = ""
    @State private var currentWeight: Int = 0
    @State private var goalWeight: Int = 0
    @State private var goalDate: Date = Date()
    @State private var userProfile: UserProfile?
    
    // State properties for bindings
    @State private var dayNumber: Int = 1
    @State private var dailyLimit: Int = 2000 // Default value or fetched from profile
    @State private var calorieIntake: Int = 0
    @State private var ledger: [(type: String, name: String, calories: Int)] = []
    
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
                
                // Daily Progress View
                if let profile = userProfile {
                    DailyProgressView(
                        userProfile: profile,
                        dayNumber: $dayNumber,
                        dailyLimit: $dailyLimit,
                        calorieIntake: $calorieIntake,
                        ledger: $ledger
                    )
                    .padding(.horizontal)
                } else {
                    ProgressView("Loading user profile...")
                        .padding()
                }
                
                Spacer()
                
                // Simulate Day Button
                Button(action: {
                    if let profile = userProfile {
                        // Call saveDailyProgressAndReset directly on bindings
                        DailyProgressView(
                            userProfile: profile,
                            dayNumber: $dayNumber,
                            dailyLimit: $dailyLimit,
                            calorieIntake: $calorieIntake,
                            ledger: $ledger
                        ).saveDailyProgressAndReset()
                    }
                    loadUserData() // Reload dashboard to reflect updated weight
                    if let profile = userProfile {
                           print("UserProfile Weight After Reload: \(profile.weight)")
                       }
                }) {
                    Text("Simulate Day")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Reset Button
                Button(action: {
                    clearUserData()
                    
                    appState = "setup"
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
                loadUserData()
            }
        }
    }
    
    // MARK: - Load User Data
    private func loadUserData() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            if let profile = try PersistenceController.shared.context.fetch(fetchRequest).first {
                userProfile = profile
                name = profile.name ?? "John Doe"
                currentWeight = Int(profile.weight)
                goalWeight = Int(profile.goalWeight)
                goalDate = profile.targetDate ?? Date()
                dailyLimit = Int(profile.dailyLimit)
                dayNumber = Int(profile.tempDayNumber) // Load the persisted day number

                if let profileImageData = profile.profilePicture {
                    profilePicture = UIImage(data: profileImageData)
                }
            }
        } catch {
            print("Failed to load user profile: \(error)")
        }
    }
    
    // MARK: - Clear User Data
    private func clearUserData() {
        let fetchUserProfileRequest: NSFetchRequest<NSFetchRequestResult> = UserProfile.fetchRequest()
        let fetchDailyProgressRequest: NSFetchRequest<NSFetchRequestResult> = DailyProgress.fetchRequest()
        
        let deleteUserProfileRequest = NSBatchDeleteRequest(fetchRequest: fetchUserProfileRequest)
        let deleteDailyProgressRequest = NSBatchDeleteRequest(fetchRequest: fetchDailyProgressRequest)
        
        do {
            // Delete all UserProfile entities
            try PersistenceController.shared.context.execute(deleteUserProfileRequest)
            
            // Delete all DailyProgress entities
            try PersistenceController.shared.context.execute(deleteDailyProgressRequest)
            
            // Save the context to apply changes
            try PersistenceController.shared.context.save()
            print("User data and daily progress cleared successfully.")
        } catch {
            print("Failed to clear user data or daily progress: \(error)")
        }
    }
}

