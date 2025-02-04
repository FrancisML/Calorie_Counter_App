//
//  UserOverviewView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/4/25.
//

import SwiftUI

struct UserOverviewView: View {
    var name: String
    var profilePicture: UIImage?
    var gender: String
    var birthDate: Date?
    var weight: String
    var heightFeet: Int
    var heightInches: Int
    var heightCm: Int
    var useMetric: Bool
    var activityLevel: Int

    // PersonalGoalsView variables
    var customCals: String
    var goalWeight: String
    var goalDate: Date?
    var weekGoal: Double

    private let activityNames = ["None", "Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extra Active"]

    var body: some View {
        VStack(spacing: 20) {
            // Title and Subtitle
            VStack(spacing: 10) {
                Text("Overview")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Is all this information correct?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            // Gray Box with Profile Picture, Name, and Other Details
            VStack(alignment: .leading, spacing: 20) {
                // Profile Picture and Name
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(profilePicture != nil ? Color.green : Color.gray, lineWidth: 3)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                        
                        if let image = profilePicture {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image("Empty man PP")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("First Name")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(name.isEmpty ? "Not Provided" : name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

                Divider()

                // VStack for Additional Information
                VStack(spacing: 10) {
                    overviewRow(label: "Gender", value: gender.isEmpty ? "Not Provided" : gender)
                    overviewRow(label: "Birthdate", value: formattedBirthDate)
                    overviewRow(label: "Weight", value: formattedWeight)
                    overviewRow(label: "Height", value: formattedHeight)
                    overviewRow(label: "Activity Level", value: activityNames[activityLevel])
                }

                Divider()

                // Goal Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Goal")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(goalMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.customGray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding(.horizontal, 0)
    }

    // MARK: - Helper Functions for Formatting

    private func overviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }

    private var formattedBirthDate: String {
        guard let birthDate = birthDate else { return "Not Provided" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }

    private var formattedWeight: String {
        if weight.isEmpty { return "Not Provided" }
        return useMetric ? "\(weight) kg" : "\(weight) lbs"
    }

    private var formattedHeight: String {
        if useMetric {
            return heightCm > 0 ? "\(heightCm) cm" : "Not Provided"
        } else {
            return (heightFeet > 0 || heightInches > 0) ? "\(heightFeet) ft \(heightInches) in" : "Not Provided"
        }
    }

    // MARK: - Goal Message Logic
    private var goalMessage: String {
            // 1. Custom Calorie Goal takes priority
            if !customCals.isEmpty {
                return "Keep daily calories to \(customCals)"
            }

            // Convert user weight and goal weight to Double for comparison
            let currentWeight = Double(weight) ?? 0
            let targetWeight = Double(goalWeight) ?? 0
            let weightDifference = abs(targetWeight - currentWeight)
            let formattedDifference = useMetric ? "\(String(format: "%.1f", weightDifference)) kg" : "\(String(format: "%.1f", weightDifference)) lbs"
            
            if weekGoal == 0 {
                // 2. Maintain Goal
                return "Maintain Current Weight"
            } else if goalWeight.isEmpty {
                // 3. Lose or Gain X per week (no goal weight)
                let action = weekGoal < 0 ? "Lose" : "Gain"
                let formattedGoal = useMetric ? "\(abs(weekGoal)) kg" : "\(abs(weekGoal)) lbs"
                return "\(action) \(formattedGoal) per week"
            } else if goalWeight.isEmpty == false && goalDate == nil {
                // 4. Goal weight entered, but no goal date
                let action = weekGoal < 0 ? "Lose" : "Gain"
                let formattedGoal = useMetric ? "\(abs(weekGoal)) kg" : "\(abs(weekGoal)) lbs"
                return "\(action) \(formattedDifference) by \(action.lowercased())ing \(formattedGoal) per week"
            } else if goalWeight.isEmpty == false && goalDate != nil {
                // 5. Goal weight and goal date entered
                let action = weekGoal < 0 ? "Lose" : "Gain"
                let formattedDate = formattedGoalDate
                return "\(action) \(formattedDifference) by \(formattedDate)"
            } else {
                return "No Goal Set"
            }
        }

        private var formattedGoalDate: String {
            guard let goalDate = goalDate else { return "Not Provided" }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: goalDate)
        }
    }
