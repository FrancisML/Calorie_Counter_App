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
    @State private var dailyWeighIn: Int = 0
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
                GeometryReader { geometry in
                    let barWidth = geometry.size.width // Measure container's width

                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 40)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .fill(isOverLimit ? Color.red : Color.green)
                        .frame(width: min(CGFloat(progress) * barWidth, barWidth), height: 40) // Cap width
                        .cornerRadius(10)
                }
                .frame(height: 40) // Fixed height for the progress bar
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
                            print("Daily Weigh-In Set To: \(dailyWeighIn)")
                            
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
                    if ledger.isEmpty {
                        // Placeholder for when the ledger is empty
                        Text("Add a meal or activity")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        // Render ledger items when not empty
                        ForEach(ledger.indices, id: \.self) { index in
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
                }
                .frame(maxWidth: .infinity, minHeight: CGFloat(5 * 40)) // Extend horizontally and simulate height of 5 items
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .frame(maxHeight: 200) // Ensures consistent height




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
            // Weight Input Field
            if showWeightInput {
                VStack {
                    TextField("Enter Weight (lbs)", text: $inputWeight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding(.vertical)

                    Button(action: {
                        print("Input Weight: \(inputWeight)") // Debugging: Log the raw input

                        if let weight = Int(inputWeight), weight > 0 {
                            dailyWeighIn = weight
                            print("Daily Weigh-In Set To: \(dailyWeighIn)") // Debugging: Confirm State Update
                            showWeightInput = false
                            inputWeight = ""
                        } else {
                            print("Invalid weight entered or conversion failed.") // Debugging: Log invalid input
                        }
                    })
                    {
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
        // Update the local daily weigh-in variable
        dailyWeighIn = weight

        // Debugging: Print the updated weight
        print("Updated local weigh-in for Day \(dayNumber): \(dailyWeighIn)")
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
        newProgress.dayNumber = Int32(dayNumber)
        newProgress.date = currentDate
        newProgress.calorieIntake = Int32(calorieIntake)
        newProgress.dailyLimit = Int32(dailyLimit)
        newProgress.passOrFail = calorieIntake <= dailyLimit ? "Pass" : "Fail"

        // Calculate TDEE
        let multiplier: Double
        switch userProfile.activityLevel {
        case "Sedentary": multiplier = 1.2
        case "Lightly Active": multiplier = 1.375
        case "Moderately Active": multiplier = 1.55
        case "Very Active": multiplier = 1.725
        case "Extra Active": multiplier = 1.9
        default: multiplier = 1.2
        }
        let tdee = Int(Double(userProfile.userBMR) * multiplier)

        // Calculate dailyCalorieDeficit
        let dailyCalDeficit = tdee - calorieIntake
        newProgress.dailyCalDeficit = Int32(dailyCalDeficit)

        // Use `dailyWeighIn` for weight or fallback to `userProfile.weight`
        if dailyWeighIn > 0 {
            print("DailyWeighIN > 0")
            newProgress.dailyWeight = Int32(dailyWeighIn)
            userProfile.weight = Int32(dailyWeighIn) // Update UserProfile weight
        } else {
            newProgress.dailyWeight = userProfile.weight // Default to UserProfile weight
        }

        userProfile.addToDailyProgress(newProgress)

        // Save ledger entries
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

            print("""
            Saving Daily Progress:
            Day Number: \(newProgress.dayNumber)
            Date: \(newProgress.date ?? Date())
            Calorie Intake: \(newProgress.calorieIntake)
            Daily Limit: \(newProgress.dailyLimit)
            Pass/Fail: \(newProgress.passOrFail ?? "Unknown")
            Daily Weight: \(newProgress.dailyWeight)
            Daily Calorie Deficit: \(newProgress.dailyCalDeficit)
            User Profile Weight: \(userProfile.weight)
            """)

            // Save changes to Core Data
            try context.save()
            print("Daily progress and weight saved successfully!")

            // Reset for the next day
            ledger.removeAll()
            calorieIntake = 0
            inputWeight = ""
            dailyWeighIn = 0 // Reset `dailyWeighIn`
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

