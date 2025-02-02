//
//  PersonalGoalsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

struct PersonalGoalsView: View {
    @State private var selectedGoal: Double = 0        // Tracks the selected value
    @Binding var useMetric: Bool                       // Passed in from PersonalStatsView
    @State private var goalWeight: String = ""         // Goal weight input
    
    @State private var goalDate: Date? = nil           // Final saved date
    @State private var temporaryGoalDate: Date = Date() // Temporary date for picker
    @State private var showDatePicker: Bool = false    // Controls date picker visibility
    @State private var hasPickedDate: Bool = false     // Tracks if a date was picked
    
    @State private var customCals: String = ""         // Custom calorie goal input
    
    // Radio Button Selection State
    enum GoalType {
        case weightGoal, calorieGoal
    }
    @State private var selectedGoalType: GoalType = .weightGoal  // Default to weight goal selection
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                Text("Personal Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Tell us your goal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }

            VStack(spacing: 20) {
                // Weight Goal Radio Button
                HStack {
                    Button(action: {
                        selectedGoalType = .weightGoal
                        resetCalorieGoal()  // Reset calorie input when switching
                    }) {
                        HStack {
                            Image(systemName: selectedGoalType == .weightGoal ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                            Text("Weight & Target Date Goal")
                                .foregroundColor(.primary)
                                .font(.headline)
                        }
                    }
                    Spacer()
                }
                
                // Weight Goal Section (Always Visible, Disabled if Not Selected)
                HorizontalWheelPicker(selectedValue: $selectedGoal, useMetric: $useMetric)
                    .disabled(selectedGoalType != .weightGoal)
                    .padding(.leading, 40)
                                                    
                // Conditionally show these inputs if the slider is not on 0.0
                if selectedGoal != 0 {
                    VStack(alignment: .leading, spacing: 10) {
                        // Goal Weight Input
                        Text("Do you have a goal weight?")
                            .font(.headline)
                            .padding(.bottom, 5)
                            .padding(.leading, 40)

                        FloatingTextField(
                            placeholder: useMetric ? " Goal Weight (kg) " : " Goal Weight (lbs) ",
                            text: $goalWeight
                        )
                        .keyboardType(.numberPad)
                        .onReceive(goalWeight.publisher.collect()) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            let trimmed = String(filtered.prefix(3))
                            if goalWeight != trimmed { goalWeight = trimmed }
                        }
                        .disabled(selectedGoalType != .weightGoal)
                        .padding(.leading, 40)
                    }
                    .transition(.opacity)  // Smooth transition for Goal Weight input

                    // Show Target Date only if Goal Weight is entered
                    if !goalWeight.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Do you want to reach this weight by a certain date?")
                                .font(.headline)
                                .padding(.bottom, 5)
                                .padding(.leading, 40)

                            FloatingInputWithAction(
                                placeholder: " Target Date ",
                                displayedText: formattedGoalDate,
                                action: {
                                    temporaryGoalDate = goalDate ?? minSelectableDate
                                    showDatePicker = true
                                },
                                hasPickedValue: $hasPickedDate
                            )
                            .disabled(selectedGoalType != .weightGoal)
                            .padding(.leading, 40)
                        }
                        .transition(.opacity)  // Smooth transition for Target Date input
                    }
                }

                Divider()  // Divider between radio button selections
                
                // Custom Calorie Goal Radio Button
                HStack {
                    Button(action: {
                        selectedGoalType = .calorieGoal
                        resetWeightAndDateInputs()  // Reset weight and date inputs when switching
                    }) {
                        HStack {
                            Image(systemName: selectedGoalType == .calorieGoal ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                            Text("Custom Calorie Goal")
                                .foregroundColor(.primary)
                                .font(.headline)
                        }
                    }
                    Spacer()
                }
                
                // Custom Calorie Goal Input (Always Visible, Disabled if Not Selected)
                VStack(alignment: .leading, spacing: 10) {
                    FloatingTextField(
                        placeholder: " Enter Calorie Goal ",
                        text: $customCals
                    )
                    .keyboardType(.numberPad)
                    .onReceive(customCals.publisher.collect()) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let trimmed = String(filtered.prefix(5))
                        if customCals != trimmed { customCals = trimmed }
                    }
                    .disabled(selectedGoalType != .calorieGoal)
                    .padding(.leading, 40)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
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
        .sheet(isPresented: $showDatePicker) {
            VStack(spacing: 20) {
                Text("Select Target Date")
                    .font(.headline)
                    .padding()

                DatePicker(
                    "",
                    selection: $temporaryGoalDate,
                    in: minSelectableDate...,  // Restrict to dates starting from a week from today
                    displayedComponents: [.date]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding(.horizontal)

                HStack {
                    Button("Cancel") {
                        showDatePicker = false
                    }
                    .frame(maxWidth: .infinity)

                    Button("Save") {
                        goalDate = temporaryGoalDate
                        hasPickedDate = true
                        showDatePicker = false
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.customGray))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
            .frame(width: UIScreen.main.bounds.width * 0.9)
        }
    }
    
    // Date Formatter for Displaying the Selected Goal Date
    private var formattedGoalDate: String {
        guard let goalDate = goalDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: goalDate)
    }
    
    // Minimum Selectable Date (One Week from Today)
    private var minSelectableDate: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }
    
    // Reset Calorie Goal when switching to Weight Goal
    private func resetCalorieGoal() {
        customCals = ""
    }
    
    // Reset Weight and Date Inputs when switching to Calorie Goal
    private func resetWeightAndDateInputs() {
        selectedGoal = 0
        goalWeight = ""
        goalDate = nil
        hasPickedDate = false
    }
}

