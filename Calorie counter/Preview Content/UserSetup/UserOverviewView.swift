//  UserOverviewView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/4/25.
//

import SwiftUI
import CoreData

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

    // PersonalGoalsView variables (passed but not used for goal text)
    var customCals: String
    var goalWeight: String
    var goalDate: Date?
    var weekGoal: Double
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext
    private let activityNames = ["None", "Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extra Active"]

    var body: some View {
        VStack(spacing: 20) {
            // Title and Subtitle
            VStack(spacing: 10) {
                Text("Overview")
                    .font(.largeTitle)
                    .foregroundColor(Styles.primaryText)
                    .fontWeight(.bold)

                Text("Is all this information correct?")
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            // Styled Box with Profile Picture, Name, and Other Details
            ZStack {
                Styles.secondaryBackground
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

                VStack(alignment: .leading, spacing: 20) {
                    // Profile Picture and Name
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(profilePicture != nil ? Color.green : Styles.primaryText, lineWidth: 3)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .fill(Styles.primaryBackground.opacity(0.3))
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
                                .foregroundColor(Styles.secondaryText)
                            Text(name.isEmpty ? "Not Provided" : name)
                                .font(.title2)
                                .foregroundColor(Styles.primaryText)
                                .fontWeight(.bold)
                        }
                    }

                    Divider().background(Styles.primaryText)

                    // Additional Information
                    VStack(spacing: 10) {
                        overviewRow(label: "Gender", value: gender.isEmpty ? "Not Provided" : gender)
                        overviewRow(label: "Birthdate", value: formattedBirthDate)
                        overviewRow(label: "Weight", value: formattedWeight)
                        overviewRow(label: "Height", value: formattedHeight)
                        overviewRow(label: "Activity Level", value: activityNames[activityLevel])
                    }

                    Divider().background(Styles.primaryText)

                    // Goal Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Goal")
                            .font(.headline)
                            .foregroundColor(Styles.secondaryText)
                        
                        Text(fetchGoalText())
                            .font(.body)
                            .foregroundColor(Styles.primaryText)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(20)
            }
            .fixedSize(horizontal: false, vertical: true)
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
                .foregroundColor(Styles.primaryText)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(Styles.secondaryText)
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

    // MARK: - Fetch Static Goal Text
    private func fetchGoalText() -> String {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                return userProfile.goalText ?? "No Goal Set"
            }
        } catch {
            print("❌ Error fetching goal text: \(error.localizedDescription)")
        }
        return "No Goal Set" // Fallback if no profile exists
    }
}

// Preview (optional, for development)

