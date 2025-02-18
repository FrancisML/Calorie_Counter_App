//
//  TodayView.swift
//  Calorie counter
//
//  Created by Frank LaSalvia on 2/9/25.
//

import SwiftUI
import CoreData

struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var userName: String = "User"
    @State private var profilePicture: UIImage? = nil
    @State private var goalMessage: String = "No Goal Set"
    @State private var highestStreak: Int32 = 1
    @State private var selectedDate: Date = Date()
    @State private var dailyCalorieGoal: Int = 2000
    @State private var isWaterPickerPresented: Bool = false // ✅ Controls picker visibility
    @State private var selectedUnit: String = "fl oz"
    
    @Binding var weighIns: [(time: String, weight: String)] // ✅ Accept weigh-ins as Binding



   



    @Binding var diaryEntries: [DiaryEntry]
     
    

    @State private var calorieProgress: CGFloat = 0
    @State private var calorieGoal: CGFloat = 100
    @State private var waterProgress: CGFloat = 0
    @State private var waterGoal: CGFloat = 100
    @State private var useMetric: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer().frame(height: 50)

            HStack(spacing: 15) {
                if let image = profilePicture {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Styles.primaryText, lineWidth: 2))
                        .padding(.leading, 20)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Styles.secondaryText)
                        .padding(.leading, 20)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)

                    Text(goalMessage)
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 15)

            DailyDBView(
                selectedDate: $selectedDate,
                diaryEntries: $diaryEntries,
                highestStreak: highestStreak,
                calorieGoal: CGFloat(dailyCalorieGoal),
                useMetric: useMetric,
                weighIns: $weighIns // ✅ Pass weighIns as a binding
            )

            



        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Styles.primaryBackground)
        .ignoresSafeArea()
        .onAppear {
            fetchUserData()
        }
    }

    private func fetchUserData() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastSavedDate", ascending: false)]

        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                self.userName = userProfile.name ?? "User"

                if let imageData = userProfile.profilePicture, let uiImage = UIImage(data: imageData) {
                    self.profilePicture = uiImage
                }

                self.goalMessage = generateGoalMessage(userProfile: userProfile)
                self.highestStreak = 1
                self.useMetric = userProfile.useMetric
                self.dailyCalorieGoal = Int(userProfile.dailyCalorieGoal) // ✅ Fetch dailyCalorieGoal
            }
        } catch {
            print("⚠️ ERROR: Failed to fetch user profile: \(error.localizedDescription)")
        }
    }


    private func generateGoalMessage(userProfile: UserProfile) -> String {
        let weightDifference = abs(userProfile.goalWeight - userProfile.currentWeight)
        let formattedDifference = userProfile.useMetric ? "\(weightDifference) kg" : "\(weightDifference) lbs"
        
        if userProfile.weekGoal == 0 {
            return "Maintain Current Weight"
        } else if userProfile.goalWeight == 0 {
            let action = userProfile.weekGoal < 0 ? "Lose" : "Gain"
            return "\(action) \(abs(userProfile.weekGoal)) per week"
        } else if userProfile.goalWeight > 0 && userProfile.targetDate == nil {
            let action = userProfile.weekGoal < 0 ? "Lose" : "Gain"
            return "\(action) \(formattedDifference) by \(action.lowercased())ing \(abs(userProfile.weekGoal)) per week"
        } else if userProfile.goalWeight > 0 && userProfile.targetDate != nil {
            let action = userProfile.weekGoal < 0 ? "Lose" : "Gain"
            return "\(action) \(formattedDifference) by \(formattedGoalDate(userProfile.targetDate))"
        } else {
            return "No Goal Set"
        }
    }

    private func formattedGoalDate(_ date: Date?) -> String {
        guard let date = date else { return "Not Provided" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    private static func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

