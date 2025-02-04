//
//  PersonalGoalsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

struct PersonalGoalsView: View {
    @Binding var useMetric: Bool               // Passed from PersonalStatsView
    @Binding var goalWeight: String            // Bind to UserSetupView
    @Binding var goalDate: Date?               // Bind to UserSetupView
    @Binding var customCals: String            // Bind to UserSetupView
    @Binding var weekGoal: Double              // Bind to UserSetupView, renamed from selectedGoal

    @State private var temporaryGoalDate: Date = Date() // Temporary date for picker
    @State private var showDatePicker: Bool = false     // Controls date picker visibility
    @State private var hasPickedDate: Bool = false      // Tracks if a date was picked

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
                        resetCalorieGoal()
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

                // Weight Goal Section
                VStack(alignment: .leading, spacing: 10) {
                    HorizontalWheelPicker(
                        selectedValue: $weekGoal,
                        useMetric: $useMetric,
                        isCalorieGoalSelected: Binding(
                            get: { selectedGoalType == .calorieGoal },
                            set: { _ in }
                        )
                    )
                    .disabled(selectedGoalType != .weightGoal)
                    .padding(.leading, 40)

                    VStack(alignment: .leading, spacing: 10) {
                        if weekGoal != 0 {
                            VStack(alignment: .leading, spacing: 10) {
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
                                .background(Color.customGray)
                                .disabled(selectedGoalType != .weightGoal)
                                .padding(.leading, 40)
                            }
                            .background(Color.customGray)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

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
                                .frame(maxWidth: .infinity)
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .clipped()
                        }
                    }
                    .clipped()
                    .animation(.easeOut(duration: 0.5), value: weekGoal)
                    .animation(.easeOut(duration: 0.5), value: goalWeight)
                }

                Divider()

                // Custom Calorie Goal Radio Button
                HStack {
                    Button(action: {
                        selectedGoalType = .calorieGoal
                        resetWeightAndDateInputs()
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

                if selectedGoalType == .calorieGoal {
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
                        .padding(.leading, 40)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeOut(duration: 0.5), value: selectedGoalType)
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
                    in: minSelectableDate...,
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

    private var formattedGoalDate: String {
        guard let goalDate = goalDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: goalDate)
    }

    private var minSelectableDate: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }

    private func resetCalorieGoal() {
        customCals = ""
    }

    private func resetWeightAndDateInputs() {
        weekGoal = 0
        goalWeight = ""
        goalDate = nil
        hasPickedDate = false
    }
}

