//
//  PersonalStatsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

struct PersonalStatsView: View {
    @Binding var weight: String
    @Binding var heightFeet: Int
    @Binding var heightInches: Int
    @Binding var heightCm: Int
    @Binding var useMetric: Bool
    @Binding var goalWeight: String
    @Binding var activityLevel: Int
    @State private var hasPickedHeight: Bool
    @State private var showHeightPicker: Bool = false
    @State private var tempHeightCm: Int = 0  // Temporary variable for cm selection



    init(weight: Binding<String>, heightFeet: Binding<Int>, heightInches: Binding<Int>, heightCm: Binding<Int>, useMetric: Binding<Bool>, goalWeight: Binding<String>, activityLevel: Binding<Int>) {
        _weight = weight
        _heightFeet = heightFeet
        _heightInches = heightInches
        _heightCm = heightCm
        _useMetric = useMetric
        _goalWeight = goalWeight
        _activityLevel = activityLevel
       

        _hasPickedHeight = State(initialValue: heightCm.wrappedValue > 0 || heightFeet.wrappedValue > 0)
        _tempHeightCm = State(initialValue: heightCm.wrappedValue)  // Initialize temp value
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Personal Stats")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enter your stats")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Toggle(isOn: Binding(
                        get: { useMetric },
                        set: { newValue in
                            if newValue != useMetric {
                                useMetric = newValue
                                hasPickedHeight = false
                                if newValue {
                                    // Convert feet + inches to cm when switching to metric
                                    heightCm = Int(Double((heightFeet * 12 + heightInches)) * 2.54)
                                    tempHeightCm = heightCm  // Keep the converted value for selection
                                } else {
                                    // Convert cm to feet + inches when switching to imperial
                                    let totalInches = Int(Double(heightCm) / 2.54)
                                    heightFeet = totalInches / 12
                                    heightInches = totalInches % 12
                                }
                            }
                        }
                    )) {
                        Text("Metric")
                    }
                }
                .padding(.trailing, 10)

                FloatingTextField(
                    placeholder: useMetric ? " Weight (kg) " : " Weight (lbs) ",
                    text: $weight
                )
                .keyboardType(.numberPad)
                .onReceive(weight.publisher.collect()) { newValue in
                    let filtered = newValue.filter { $0.isNumber } // ✅ Keep only numbers
                    let trimmed = String(filtered.prefix(3)) // ✅ Convert to String and limit to 3 digits
                    if weight != trimmed { weight = trimmed } // ✅ Prevents infinite loop
                }


                FloatingInputWithAction(
                    placeholder: useMetric ? " Height (cm) " : " Height (ft/in) ",
                    displayedText: formattedHeight,
                    action: { showHeightPicker = true },
                    hasPickedValue: $hasPickedHeight
                )

                CustomActivitySlider(activityLevel: $activityLevel)
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
        .overlay(
            Group {
                if showHeightPicker {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text("Select Your Height")
                                .font(.headline)

                            heightPicker
                                .padding(.horizontal)

                            HStack {
                                Button("Cancel") {
                                    showHeightPicker = false
                                }
                                .frame(maxWidth: .infinity)

                                Button("Save") {
                                    if useMetric {
                                        heightCm = tempHeightCm  // ✅ Correctly assign from picker
                                    } else {
                                        heightCm = 0
                                    }
                                    hasPickedHeight = true
                                    showHeightPicker = false
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.customGray))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                    }
                }
            }
        )
    }

    private var formattedHeight: String {
        if hasPickedHeight {
            return useMetric ? "\(heightCm) cm" : "\(heightFeet) ft \(heightInches) in"
        }
        return ""
    }

    private var heightPicker: some View {
        VStack {
            if useMetric {
                Picker("Height (cm)", selection: $tempHeightCm) {  // ✅ Use temp value
                    ForEach(100...250, id: \.self) { cm in
                        Text("\(cm) cm").tag(cm)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            } else {
                HStack {
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(3...7, id: \.self) { feet in
                            Text("\(feet) ft").tag(feet)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())

                    Picker("Inches", selection: $heightInches) {
                        ForEach(0..<12, id: \.self) { inch in
                            Text("\(inch) in").tag(inch)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }
        }
    }
}

