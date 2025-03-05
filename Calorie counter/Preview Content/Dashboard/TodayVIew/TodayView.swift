//
//  TodayView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/12/25.
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
    @State private var isWaterPickerPresented: Bool = false
    @State private var selectedUnit: String = "fl oz"
    @Binding var weighIns: [WeighIn]
    @Binding var diaryEntries: [DiaryEntry]
    private var useMetric: Bool = false

    init(weighIns: Binding<[WeighIn]>, diaryEntries: Binding<[DiaryEntry]>) {
        self._weighIns = weighIns
        self._diaryEntries = diaryEntries
    }

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

                    HStack(spacing: 5) {
                        Image(systemName: "target")
                            .foregroundColor(Styles.secondaryText)
                            .font(.subheadline)
                        Text(goalMessage)
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                        Text("Highest Streak: \(highestStreak)")
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "scalemass.fill")
                            .foregroundColor(Styles.secondaryText)
                            .font(.subheadline)
                        Text("Weight: \(formattedCurrentWeight())")
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                        Spacer()
                        if let (difference, weekGoal) = weightDifference() {
                            let differenceColor: Color = {
                                if weekGoal < 0 { // Lose weight
                                    return difference < 0 ? .green : .red
                                } else if weekGoal > 0 { // Gain weight
                                    return difference > 0 ? .green : .red
                                } else { // Maintain weight
                                    return .red
                                }
                            }()
                            HStack(spacing: 2) {
                                Image(systemName: difference > 0 ? "arrow.up" : difference < 0 ? "arrow.down" : "minus")
                                    .foregroundColor(differenceColor)
                                    .font(.subheadline)
                                Text("\(String(format: "%.1f", abs(difference)))")
                                    .font(.subheadline)
                                    .foregroundColor(differenceColor)
                            }
                        }
                    }
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
                weighIns: $weighIns
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
                self.highestStreak = userProfile.highStreak
                self.dailyCalorieGoal = Int(userProfile.dailyCalorieGoal)
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

    private func formattedCurrentWeight() -> String {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                return String(format: "%.1f %@", userProfile.currentWeight, useMetric ? "kg" : "lbs")
            }
        } catch {
            print("❌ Error fetching current weight: \(error.localizedDescription)")
        }
        return "N/A"
    }

    private func weightDifference() -> (difference: Double, weekGoal: Double)? {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                let difference = userProfile.currentWeight - userProfile.startWeight
                return (difference, userProfile.weekGoal)
            }
        } catch {
            print("❌ Error fetching weight difference: \(error.localizedDescription)")
        }
        return nil
    }

    private static func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}
