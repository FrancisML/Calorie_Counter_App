//
//  TodayView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/9/25.
//

import SwiftUI
import CoreData

struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var userName: String = "User"
    @State private var profilePicture: UIImage? = nil
    @State private var goalMessage: String = "No Goal Set"
    @State private var highestStreak: Int32 = 1 // Default streak
    @State private var currentDate: String = formattedCurrentDate() // Displays today's date
    @State private var useMetric: Bool = false // ✅ Now it exists
    @State private var diaryEntries: [DiaryEntry] = [
        DiaryEntry(time: "8:00 AM", icon: "carrot.fill", description: "Breakfast", calories: 250, type: "Food"),
        DiaryEntry(time: "10:00 AM", icon: "bicycle", description: "Cycling", calories: 300, type: "Workout"),
        DiaryEntry(time: "12:30 PM", icon: "carrot.fill", description: "Lunch", calories: 500, type: "Food")
    ]
    
    // Progress values (replace 100 with actual goals)
    @State private var calorieProgress: CGFloat = 0
    @State private var calorieGoal: CGFloat = 100
    @State private var waterProgress: CGFloat = 0
    @State private var waterGoal: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // USER PROFILE SECTION
            HStack(spacing: 15) {
                // Profile Picture
                if let image = profilePicture {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Styles.primaryText, lineWidth: 2))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Styles.secondaryText)
                }

                // USER DETAILS
                VStack(alignment: .leading, spacing: 5) {
                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)

                    HStack {
                        Text(goalMessage)
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)

                        Text("Progress 0%")
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                    }

                    Text("Highest Streak: \(highestStreak)")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                }

                Spacer()
            }
            .padding(.horizontal)
            

            // NAVIGATION BAR BELOW PROFILE
            HStack {
                // Previous Button "<"
                Button(action: {
                    // Functionality for moving to previous day (to be implemented)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }

                Spacer()

                // CENTERED DATE & SUBHEADING
                VStack {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(Styles.secondaryText)
                    Text(currentDate)
                        .font(.subheadline)
                        .foregroundColor(Styles.primaryText)
                }

                Spacer()

                // Next Button ">"
                Button(action: {
                    // Functionality for moving to next day (to be implemented)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }

                Spacer()

                // Streak Display
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange) // Flame icon color
                    Text("Streak: \(highestStreak)")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Styles.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // PROGRESS BARS SECTION
            VStack(spacing: 15) {
                // Calories Progress Bar
                HStack(spacing: 10) {
                    // Bolt Image (Matches Label + Progress Bar Height)
                    Image("bolt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40) // ✅ Adjusted height to match
                        .padding(.trailing, 5)

                    VStack(alignment: .leading) {
                        // Label HStack
                        HStack {
                            Text("Calories")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)

                            Spacer()

                            Text("\(Int(calorieProgress))/\(Int(calorieGoal))")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }

                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Styles.primaryText.opacity(0.2))
                                    .frame(height: 20) // ✅ Doubled height

                                Rectangle()
                                    .fill(Styles.primaryText)
                                    .frame(width: (calorieProgress / calorieGoal) * geometry.size.width, height: 20)
                                    .animation(.easeInOut(duration: 0.3), value: calorieProgress)
                            }
                        }
                        .frame(height: 20)
                    }
                }

                // WATER PROGRESS BAR
                HStack(spacing: 10) {
                    // Drop Image (Matches Label + Progress Bar Height)
                    Image("drop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40) // ✅ Adjusted height to match
                        .padding(.trailing, 5)

                    VStack(alignment: .leading) {
                        // Label HStack
                        HStack {
                            Text("Water")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)

                            Spacer()

                            Text("\(Int(waterProgress))/\(Int(waterGoal))")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }

                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Styles.primaryText.opacity(0.2))
                                    .frame(height: 20) // ✅ Doubled height

                                Rectangle()
                                    .fill(Styles.primaryText)
                                    .frame(width: (waterProgress / waterGoal) * geometry.size.width, height: 20)
                                    .animation(.easeInOut(duration: 0.3), value: waterProgress)
                            }
                        }
                        .frame(height: 20)
                    }
                }
                // DAILY WEIGH-IN SECTION
                // DAILY WEIGH-IN SECTION
                HStack(spacing: 10) {
                    // Weight Image (Same height as label)
                    Image("scale")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40) // ✅ Adjusted height to match
                        .padding(.trailing, 5)

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Daily Weigh-In:")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)

                            Spacer()

                            Text("0 \(useMetric ? "kg" : "lbs")") // ✅ Now `useMetric` works!
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }
                    }
                }
                // DAILY DIARY SECTION
                VStack(alignment: .leading, spacing: 10) {
                    Text("Diary")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)
                        .padding(.horizontal)

                    VStack {
                        // Placeholder Entries
                        ForEach(diaryEntries, id: \.id) { entry in
                            HStack {
                                // Time
                                Text(entry.time)
                                    .font(.subheadline)
                                    .foregroundColor(Styles.secondaryText)
                                    .frame(width: 70, alignment: .leading) // Adjust width for alignment
                                
                                // Icon
                                Image(systemName: entry.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(entry.type == "Food" ? .green : .red) // Different colors for Food/Workout
                                
                                // Description
                                Text(entry.description)
                                    .font(.subheadline)
                                    .foregroundColor(Styles.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Calories (Green for Food, Red for Workout)
                                Text("\(entry.type == "Food" ? "+" : "-")\(entry.calories)")
                                    .font(.subheadline)
                                    .foregroundColor(entry.type == "Food" ? .green : .red)
                                    .frame(width: 60, alignment: .trailing) // Align to the right
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                    .background(Styles.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }




            }
            .padding()
            .background(Styles.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 75) // ✅ Moves everything down
        .background(Styles.primaryBackground)
        .ignoresSafeArea()
        .onAppear {
            fetchUserData()
        }
    }

    // PROGRESS BAR COMPONENT
    


    // FETCH USER DATA FROM CORE DATA
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
                self.highestStreak = 1 // Default, should be replaced with real streak tracking

                self.useMetric = userProfile.useMetric // ✅ Now `useMetric` is fetched!
            }
        } catch {
            print("⚠️ ERROR: Failed to fetch user profile: \(error.localizedDescription)")
        }
    }

    // FORMAT CURRENT DATE
    private static func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }

    // GENERATE GOAL MESSAGE LOGIC
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

    // FORMAT GOAL DATE
    private func formattedGoalDate(_ date: Date?) -> String {
        guard let date = date else { return "Not Provided" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
struct DiaryEntry {
    let id = UUID()
    let time: String
    let icon: String
    let description: String
    let calories: Int
    let type: String // "Food" or "Workout"
}



