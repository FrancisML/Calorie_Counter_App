//
//  PersonalGoalsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

struct PersonalGoalsView: View {
    @Binding var useMetric: Bool
    @Binding var goalWeight: String
    @Binding var goalDate: Date?
    @Binding var customCals: String
    @Binding var weekGoal: Double
    @Binding var isWeightTargetDateGoalSelected: Bool
       @Binding var isCustomCalorieGoalSelected: Bool


    @State private var temporaryGoalDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var hasPickedDate: Bool = false

    enum GoalType {
        case weightGoal, calorieGoal
    }
    @State private var selectedGoalType: GoalType = .weightGoal

    var body: some View {
        VStack(spacing: 20) {
            // Title and Subtitle
            VStack(spacing: 10) {
                Text("Personal Goals")
                    .font(.largeTitle)
                    .foregroundColor(Styles.primaryText)
                    .fontWeight(.bold)

                Text("Tell us your goal")
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            // Shadow applied to the container
            ZStack {
                Styles.secondaryBackground
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

                VStack(spacing: 20) {
                    // Weight Goal Radio Button
                    HStack {
                        Button(action: {
                            isWeightTargetDateGoalSelected = true
                            isCustomCalorieGoalSelected = false
                            selectedGoalType = .weightGoal  // ✅ Ensure the goal type is updated
                            resetCalorieGoal()
                        }) {
                            HStack {
                                Image(systemName: isWeightTargetDateGoalSelected ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.blue)
                                Text("Weight & Target Date Goal")
                                    .foregroundColor(Styles.primaryText)
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
                                    // Smaller Label with Padding
                                    Text("Do you have a goal weight?")
                                        .font(.subheadline)  // Smaller font size
                                        .foregroundColor(Styles.primaryText)
                                        .padding(.leading, 40)
                                        .padding(.bottom, 6)  // Padding below the label

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
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            if !goalWeight.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    // Smaller Label with Padding
                                    Text("Do you have a target date?")
                                        .font(.subheadline)  // Smaller font size
                                        .foregroundColor(Styles.primaryText)
                                        .padding(.leading, 40)
                                        .padding(.bottom, 6)  // Padding below the label

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
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .animation(.easeOut(duration: 0.5), value: weekGoal)
                        .animation(.easeOut(duration: 0.5), value: goalWeight)
                    }

                    Divider()

                    // Custom Calorie Goal Radio Button
                    HStack {
                        Button(action: {
                            isWeightTargetDateGoalSelected = false
                            isCustomCalorieGoalSelected = true
                            selectedGoalType = .calorieGoal  // ✅ Ensure the goal type is updated
                            resetWeightAndDateInputs()
                        }) {
                            HStack {
                                Image(systemName: isCustomCalorieGoalSelected ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.blue)
                                Text("Custom Calorie Goal")
                                    .foregroundColor(Styles.primaryText)
                                    .font(.headline)
                            }
                        }

                        Spacer()
                    }

                    if isCustomCalorieGoalSelected {
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
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(20)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 40)

            Spacer()
        }
        .overlay(
            Group {
                if showDatePicker {
                    ZStack {
                        Color.black.opacity(0.3) // Background dimming effect (optional)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text("Select Target Date")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)

                            //  Correct Date Picker Styled Like Birthdate Picker
                            CustomDatePicker(selectedDate: $temporaryGoalDate, minimumDate: minSelectableDate)
                                .frame(height: 200)
                                .clipped()

                            HStack {
                                Button("Cancel") {
                                    showDatePicker = false
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Styles.primaryText)

                                Button("Save") {
                                    goalDate = temporaryGoalDate
                                    hasPickedDate = true
                                    showDatePicker = false
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 0).fill(Styles.secondaryBackground))
                       
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // ✅ Centers Date Picker
                }
            }
        )


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
