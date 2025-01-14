//
//  SummaryView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/9/25.
//

import SwiftUI

struct SummaryView: View {
    let gender: String
    let height: String
    let weight: Int
    let age: Int
    let goalWeight: Int
    let activityLevel: String
    let targetDate: Date
    let useMetric: Bool
    let goalMass: Double
    let goalCalories: Int
    let daysLeft: Int
    let calorieDeficit: Int
    let userBMR: Int

    @State private var navigateToGoalSummary = false
    @State private var navigateToUserSetup = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer(minLength: 20)
                Image("stats")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)

                Text("Look Good?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Gender: \(gender)")
                        .font(.title3)
                    Text("Height: \(height)")
                        .font(.title3)
                    Text("Weight: \(weight) \(useMetric ? "kg" : "lbs")")
                        .font(.title3)
                    Text("Age: \(age)")
                        .font(.title3)
                    Text("Goal Weight: \(goalWeight) \(useMetric ? "kg" : "lbs")")
                        .font(.title3)
                    Text("Activity Level: \(activityLevel)")
                        .font(.title3)
                    Text("Target Date: \(targetDate, style: .date)")
                        .font(.title3)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Spacer()

                HStack(spacing: 20) {
                    Button(action: {
                        navigateToUserSetup = true
                    }) {
                        Text("Re-enter")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        navigateToGoalSummary = true
                    }) {
                        Text("Confirm")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToUserSetup) {
                UserSetupView()
            }
            .navigationDestination(isPresented: $navigateToGoalSummary) {
                GoalSummaryView(
                    weight: weight,
                    goalWeight: goalWeight,
                    targetDate: targetDate,
                    age: age,
                    height: heightInCm,
                    heightFt: heightFt,
                    heightIn: heightIn,
                    heightCm: heightCm,
                    gender: gender,
                    activityLevel: activityLevel,
                    useMetric: useMetric,
                    goalMass: goalMass,
                    goalCalories: goalCalories,
                    daysLeft: daysLeft,
                    calorieDeficit: calorieDeficit,
                    dailyLimit: Int32(dailyLimit),
                    userBMR: userBMR
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Computed Properties
    var tdee: Int {
        let multiplier: Double
        switch activityLevel {
        case "Sedentary": multiplier = 1.2
        case "Lightly Active": multiplier = 1.375
        case "Moderately Active": multiplier = 1.55
        case "Very Active": multiplier = 1.725
        case "Extra Active": multiplier = 1.9
        default: multiplier = 1.2
        }
        return Int(Double(userBMR) * multiplier)
    }

    var dailyLimit: Int {
        tdee - calorieDeficit
    }

    // Helper to Convert Height to cm
    var heightInCm: Int {
        if useMetric {
            return Int(height.filter("0123456789".contains)) ?? 0
        } else {
            let parts = height.split(separator: "'").map { String($0) }
            guard parts.count == 2,
                  let feet = Int(parts[0].trimmingCharacters(in: .whitespaces)),
                  let inches = Int(parts[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")) else {
                return 0
            }
            return Int(Double(feet) * 30.48 + Double(inches) * 2.54)
        }
    }

    var heightFt: Int32? {
        if !useMetric {
            let parts = height.split(separator: "'").map { String($0) }
            guard let feet = Int(parts[0].trimmingCharacters(in: .whitespaces)) else {
                return nil
            }
            return Int32(feet)
        }
        return nil
    }

    var heightIn: Int32? {
        if !useMetric {
            let parts = height.split(separator: "'").map { String($0) }
            guard parts.count == 2,
                  let inches = Int(parts[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")) else {
                return nil
            }
            return Int32(inches)
        }
        return nil
    }

    var heightCm: Int32? {
        if useMetric {
            return Int32(heightInCm)
        }
        return nil
    }
}
