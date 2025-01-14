//
//  DailyProgressView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import SwiftUI
import CoreData

struct DailyProgressView: View {
    // Core Data Context
    private let context = DailyProgressPersistenceController.shared.context

    // State Properties
    @State private var dailyLimit: Int = 0
    @State private var dayNumber: Int = 1
    @State private var calorieIntake: Int = 0
    @State private var currentDate: Date = Date()
    @State private var lastSavedDate: Date? = nil
    @State private var ledger: [(type: String, name: String, calories: Int)] = []
    @State private var showFoodInput = false
    @State private var showWorkoutInput = false
    @State private var inputName = ""
    @State private var inputCalories = ""

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
                Text("You need to burn \(overCalorieAmount) cal to reach your goal today")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                Text("\(dailyLimit - calorieIntake) cal remaining")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Buttons
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

            // Input Fields
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
                    ForEach(0..<max(ledger.count, 5), id: \ .self) { index in
                        if index < ledger.count {
                            let entry = ledger[index]
                            HStack {
                                Text(entry.type)
                                    .foregroundColor(entry.type == "Workout" ? .red : .green)
                                    .frame(width: 80, alignment: .leading)
                                Text(entry.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(entry.type == "Workout" ? .red : .green)
                                Text("\(entry.calories)")
                                    .foregroundColor(entry.type == "Workout" ? .red : .green)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .padding(.vertical, 5)
                        } else {
                            HStack {
                                Text("")
                                    .frame(width: 80, alignment: .leading)
                                Text("")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("")
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .onAppear {
            loadDailyProgress()
            loadUserData()
            checkAndResetForNewDay()
        }
    }

    // MARK: - Load Daily Progress
    private func loadDailyProgress() {
        let fetchRequest: NSFetchRequest<DailyProgress> = DailyProgress.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        if let latestProgress = try? DailyProgressPersistenceController.shared.context.fetch(fetchRequest).first {
            dayNumber = Int(latestProgress.dayNumber)
            dailyLimit = Int(latestProgress.dailyLimit)
            calorieIntake = Int(latestProgress.calorieIntake)
            currentDate = latestProgress.date ?? Date()
            lastSavedDate = latestProgress.date

            if let ledgerEntries = latestProgress.ledgerEntries?.allObjects as? [LedgerEntry] {
                ledger = ledgerEntries.map { entry in
                    (type: entry.type ?? "Unknown", name: entry.name ?? "Unnamed", calories: Int(entry.calories))
                }
            }
        }
    }

    // MARK: - Save and Reset for a New Day
    private func checkAndResetForNewDay() {
        let calendar = Calendar.current
        if let lastSavedDate = lastSavedDate,
           calendar.isDate(lastSavedDate, inSameDayAs: Date()) {
            return
        }

        saveDailyProgressAndReset()
    }
    
    private func loadUserData() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            if let userProfile = try PersistenceController.shared.context.fetch(fetchRequest).first {
                dailyLimit = Int(userProfile.dailyLimit)
            }
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }

    private func saveDailyProgressAndReset() {
        let context = DailyProgressPersistenceController.shared.context

        let dailyProgress = DailyProgress(context: context)
        dailyProgress.dayNumber = Int32(dayNumber)
        dailyProgress.date = currentDate
        dailyProgress.calorieIntake = Int32(calorieIntake)
        dailyProgress.dailyLimit = Int32(dailyLimit)
        dailyProgress.passOrFail = calorieIntake <= dailyLimit ? "Pass" : "Fail"

        for entry in ledger {
            let ledgerEntry = LedgerEntry(context: context)
            ledgerEntry.type = entry.type
            ledgerEntry.name = entry.name
            ledgerEntry.calories = Int32(entry.calories)
            ledgerEntry.dailyProgress = dailyProgress
        }

        do {
            try context.save()
            print("Daily progress saved successfully!")

            ledger.removeAll()
            calorieIntake = 0
            currentDate = Date()
            dayNumber += 1
            lastSavedDate = currentDate
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


