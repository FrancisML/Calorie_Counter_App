//
//  DailyProgressView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import SwiftUI
import CoreData

struct DailyProgressView: View {
    @ObservedObject var userProfile: UserProfile
    private let context = PersistenceController.shared.context

    // State Properties
    @Binding var dayNumber: Int
    @Binding var dailyLimit: Int
    @Binding var calorieIntake: Int
    @Binding var ledger: [(type: String, name: String, calories: Int)]

    @State private var showWeightInput = false
    @State private var inputWeight: String = ""
    @State private var lastSavedDate: Date? = nil
    @State private var showFoodInput = false
    @State private var showWorkoutInput = false
    @State private var inputName = ""
    @State private var inputCalories = ""
    private var currentDate: Date {
        guard let startDate = userProfile.startDate else { return Date() }
        return Calendar.current.date(byAdding: .day, value: dayNumber - 1, to: startDate) ?? Date()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top HStack: Day and Date
            HStack {
                Text("Day \(dayNumber) - \(formattedDate)")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Text("\(calorieIntake) / \(dailyLimit) cal")
                    .font(.subheadline)
                    .foregroundColor(isOverLimit ? .red : .green)
            }

            // Progress Bar
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                    .cornerRadius(10)

                Rectangle()
                    .fill(isOverLimit ? Color.red : Color.green)
                    .frame(width: UIScreen.main.bounds.width * progress, height: 20)
                    .cornerRadius(10)
            }

            // Remaining Calories or Over Limit Message
            if isOverLimit {
                Text("You need to burn \(overCalorieAmount) cal today")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                Text("\(dailyLimit - calorieIntake) cal remaining")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Buttons for Adding Food and Workout
            HStack {
                Button("Add Food") {
                    showFoodInput = true
                    showWorkoutInput = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Add Workout") {
                    showWorkoutInput = true
                    showFoodInput = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            // Input Fields for Food and Workout
            if showFoodInput || showWorkoutInput {
                VStack(spacing: 10) {
                    HStack {
                        TextField("Name", text: $inputName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Calories", text: $inputCalories)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }

                    Button("Add") {
                        if let calories = Int(inputCalories) {
                            let type = showFoodInput ? "Food" : "Workout"
                            let calorieValue = showFoodInput ? calories : -calories
                            ledger.append((type: type, name: inputName, calories: calorieValue))
                            calorieIntake += calorieValue
                            inputName = ""
                            inputCalories = ""
                            showFoodInput = false
                            showWorkoutInput = false
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.vertical)
            }

            // Ledger
            ScrollView {
                VStack {
                    ForEach(ledger.indices, id: \ .self) { index in
                        HStack {
                            Text(ledger[index].type)
                                .foregroundColor(ledger[index].type == "Workout" ? .red : .green)
                                .frame(width: 80, alignment: .leading)
                            Text(ledger[index].name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(ledger[index].type == "Workout" ? .red : .green)
                            Text("\(ledger[index].calories)")
                                .foregroundColor(ledger[index].type == "Workout" ? .red : .green)
                                .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .frame(maxHeight: 200)

            // Buttons for Weigh In and Progression
            HStack(spacing: 20) {
                // Weigh In Button
                Button(action: {
                    showWeightInput.toggle()
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

                // Progression Button
                NavigationLink(destination: PastLedgerView(userProfile: userProfile)) {
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

            // Weight Input Field
            if showWeightInput {
                VStack {
                    TextField("Enter Weight (lbs)", text: $inputWeight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding(.vertical)

                    Button(action: {
                        if let weight = Int(inputWeight), weight > 0 {
                            saveWeightToDailyProgress(weight: weight)
                            showWeightInput = false
                            inputWeight = ""
                        } else {
                            print("Invalid weight entered")
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save Weight")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .onAppear {
            loadDailyProgress()
        }
    }

    // MARK: - Save Weight to Daily Progress
    private func saveWeightToDailyProgress(weight: Int) {
        guard let dailyProgressSet = userProfile.dailyProgress as? Set<DailyProgress> else { return }

        // Find or create progress for the current day
        if let currentDayProgress = dailyProgressSet.first(where: { $0.dayNumber == Int32(dayNumber) }) {
            currentDayProgress.dailyWeight = Int32(weight)
        } else {
            let newProgress = DailyProgress(context: context)
            newProgress.dayNumber = Int32(dayNumber)
            newProgress.date = currentDate
            newProgress.dailyWeight = Int32(weight)
            userProfile.addToDailyProgress(newProgress)
        }

        // Update the UserProfile weight immediately
        userProfile.weight = Int32(weight)

        // Debugging: Print the weight being saved
        print("""
        Saving Weight:
        Entered Weight: \(weight)
        Current UserProfile Weight: \(userProfile.weight)
        """)

        // Save changes to Core Data
        do {
            try context.save()
            print("Weight saved successfully!")
        } catch {
            print("Failed to save weight: \(error)")
        }
    }


    // MARK: - Load Daily Progress
    private func loadDailyProgress() {
        guard let dailyProgressSet = userProfile.dailyProgress as? Set<DailyProgress> else { return }

        if let currentDayProgress = dailyProgressSet.first(where: { $0.dayNumber == Int32(dayNumber) }) {
            dailyLimit = Int(currentDayProgress.dailyLimit)
            calorieIntake = Int(currentDayProgress.calorieIntake)

            if let ledgerEntries = currentDayProgress.ledgerEntries?.allObjects as? [LedgerEntry] {
                ledger = ledgerEntries.map { entry in
                    (type: entry.type ?? "Unknown", name: entry.name ?? "Unnamed", calories: Int(entry.calories))
                }
            }
        } else {
            dailyLimit = Int(userProfile.dailyLimit)
            resetDailyData()
        }
    }

    private func resetDailyData() {
        ledger.removeAll()
        calorieIntake = 0
        dayNumber = Int(userProfile.tempDayNumber) > 0 ? Int(userProfile.tempDayNumber) : 1
        dailyLimit = Int(userProfile.dailyLimit)
        lastSavedDate = currentDate
        userProfile.lastSavedDate = lastSavedDate

        do {
            try context.save()
        } catch {
            print("Failed to reset daily data: \(error)")
        }
    }

    // MARK: - Save Daily Progress and Reset
    func saveDailyProgressAndReset() {
        // Create a new DailyProgress object for the current day
        let newProgress = DailyProgress(context: context)
        newProgress.dayNumber = Int32(dayNumber) // Use dayNumber for DailyProgress
        newProgress.date = currentDate
        newProgress.calorieIntake = Int32(calorieIntake)
        newProgress.dailyLimit = Int32(dailyLimit)
        newProgress.passOrFail = calorieIntake <= dailyLimit ? "Pass" : "Fail"

        // Set the weight for the day
        if let weight = Int(inputWeight), weight > 0 {
            newProgress.dailyWeight = Int32(weight)
            userProfile.weight = Int32(weight) // Update the UserProfile's weight
        } else {
            newProgress.dailyWeight = userProfile.weight // Use the existing weight from UserProfile
        }

        userProfile.addToDailyProgress(newProgress)

        for entry in ledger {
            let ledgerEntry = LedgerEntry(context: context)
            ledgerEntry.type = entry.type
            ledgerEntry.name = entry.name
            ledgerEntry.calories = Int32(entry.calories)
            ledgerEntry.dailyProgress = newProgress
        }

        do {
            // Increment and save the tempDayNumber in UserProfile
            dayNumber += 1
            userProfile.tempDayNumber = Int32(dayNumber)

            // Debugging: Print what is being saved
            print("""
            Saving Daily Progress:
            Day Number: \(newProgress.dayNumber)
            Date: \(newProgress.date ?? Date())
            Calorie Intake: \(newProgress.calorieIntake)
            Daily Limit: \(newProgress.dailyLimit)
            Pass/Fail: \(newProgress.passOrFail ?? "Unknown")
            Daily Weight: \(newProgress.dailyWeight)
            User Profile Weight: \(userProfile.weight)
            """)

            // Save changes to Core Data
            try context.save()
            print("Daily progress and weight saved successfully!")

            // Reset for the new day
            ledger.removeAll()
            calorieIntake = 0
            inputWeight = "" // Clear the weight input field
        } catch {
            print("Failed to save daily progress: \(error)")
        }
    }

    // MARK: - Computed Properties
    private var progress: CGFloat {
        guard dailyLimit > 0 else { return 0 }
        return min(CGFloat(calorieIntake) / CGFloat(dailyLimit), 1.0)
    }

    private var overCalorieAmount: Int {
        max(calorieIntake - dailyLimit, 0)
    }

    private var isOverLimit: Bool {
        calorieIntake > dailyLimit
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: currentDate)
    }
}

