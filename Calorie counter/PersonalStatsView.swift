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
    @Binding var useMetric: Bool
    @Binding var goalWeight: String
    @Binding var activityLevel: Int
    @State private var hasPickedHeight: Bool = false  // ✅ Track if height was picked
    @State private var showHeightPicker: Bool = false // ✅ Controls Height Picker Visibility
    var onBack: () -> Void
    var onNext: () -> Void

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

            // ✅ Styled Box for Inputs
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Toggle(isOn: Binding(
                        get: { useMetric },
                        set: { newValue in
                            useMetric = newValue
                            heightFeet = 0  // Reset height
                            heightInches = 0
                            hasPickedHeight = false  // Mark as not picked
                        }
                    )) {
                        Text("Metric")
                    }
                }
                .padding(.trailing, 10) // Keep aligned to the right



                FloatingTextField(placeholder: useMetric ? " Weight (kg) " : " Weight (lbs) ", text: $weight)
                    .keyboardType(.numberPad)

                //  Height Input (Tap to Open Picker)
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
        //  Overlay for Height Picker
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
                                    hasPickedHeight = true  // ✅ Mark height as picked
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

    //  Format Height Display
    private var formattedHeight: String {
        if hasPickedHeight {
            return useMetric ? "\(heightFeet) cm" : "\(heightFeet) ft \(heightInches) in"
        }
        return ""  //  Return empty if height has not been picked
    }


    //  Hidden Height Picker
    private var heightPicker: some View {
        VStack {
            if useMetric {
                Picker("Height (cm)", selection: $heightFeet) {
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
