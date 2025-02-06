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
    @Binding var weekGoal: Double
    
    @State private var hasPickedHeight: Bool
    @State private var showHeightPicker: Bool = false
    @State private var tempHeightCm: Int = 0  // Temporary variable for cm selection
    @EnvironmentObject var themeManager: ThemeManager
    
    init(weight: Binding<String>, heightFeet: Binding<Int>, heightInches: Binding<Int>, heightCm: Binding<Int>, useMetric: Binding<Bool>, goalWeight: Binding<String>, activityLevel: Binding<Int>, weekGoal: Binding<Double>) {
        _weight = weight
        _heightFeet = heightFeet
        _heightInches = heightInches
        _heightCm = heightCm
        _useMetric = useMetric
        _goalWeight = goalWeight
        _activityLevel = activityLevel
        _weekGoal = weekGoal  // ✅ Now properly initialized
        _hasPickedHeight = State(initialValue: heightCm.wrappedValue > 0 || heightFeet.wrappedValue > 0)
        _tempHeightCm = State(initialValue: heightCm.wrappedValue)
    }

    
    var body: some View {
        VStack(spacing: 20) {
            // Title and Subtitle
            VStack(spacing: 10) {
                Text("Personal Stats")
                    .font(.largeTitle)
                    .foregroundColor(Styles.primaryText)
                    .fontWeight(.bold)
                
                Text("Enter your stats")
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
                    // Metric Toggle
                    HStack {
                        Spacer()
                        Toggle(isOn: Binding(
                            get: { useMetric },
                            set: { newValue in
                                if newValue != useMetric {
                                    useMetric = newValue
                                    hasPickedHeight = false
                                    weight = ""  // Clear the weight input when toggling
                                    
                                    if newValue {
                                        // Convert feet + inches to cm when switching to metric
                                        heightCm = Int(Double((heightFeet * 12 + heightInches)) * 2.54)
                                        tempHeightCm = heightCm
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
                                .foregroundColor(Styles.primaryText)
                        }
                        .toggleStyle(SquareToggleStyle())
                    }
                    .padding(.trailing, 10)
                    
                    
                    // Weight Input
                    FloatingTextField(
                        placeholder: useMetric ? " Weight (kg) " : " Weight (lbs) ",
                        text: $weight
                    )
                    .keyboardType(.numberPad)
                    .onReceive(weight.publisher.collect()) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let trimmed = String(filtered.prefix(3))
                        if weight != trimmed { weight = trimmed }
                    }
                    
                    // Height Input
                    FloatingInputWithAction(
                        placeholder: useMetric ? " Height (cm) " : " Height (ft/in) ",
                        displayedText: formattedHeight,
                        action: { showHeightPicker = true },
                        hasPickedValue: $hasPickedHeight
                    )
                    
                    // Activity Level Slider
                    CustomActivitySlider(activityLevel: $activityLevel)
                }
                .padding(20)
            }
            .fixedSize(horizontal: false, vertical: true)
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
                                .foregroundColor(Styles.primaryText)
                            
                            heightPicker
                                .padding(.horizontal)
                            
                            HStack {
                                Button("Cancel") {
                                    showHeightPicker = false
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Styles.primaryText)
                                
                                Button("Save") {
                                    if useMetric {
                                        heightCm = tempHeightCm
                                    } else {
                                        heightCm = 0
                                    }
                                    hasPickedHeight = true
                                    showHeightPicker = false
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        }
                        .padding(20)
                        .background(Styles.secondaryBackground)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
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
                Picker("Height (cm)", selection: $tempHeightCm) {
                    ForEach(100...250, id: \.self) { cm in
                        Text("\(cm) cm")
                            .foregroundColor(Styles.secondaryText)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: UIScreen.main.bounds.width * 0.4) // Reduce width by 60%
                .clipped()
            } else {
                HStack {
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(3...7, id: \.self) { feet in
                            Text("\(feet) ft")
                                .foregroundColor(Styles.secondaryText)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.2) // Reduce width for feet
                    .clipped()
                    
                    Picker("Inches", selection: $heightInches) {
                        ForEach(0..<12, id: \.self) { inch in
                            Text("\(inch) in")
                                .foregroundColor(Styles.secondaryText)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.2) // Reduce width for inches
                    .clipped()
                }
            }
        }
    }

}


struct SquareToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            // Toggle container with dynamic background
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Rectangle()
                    .fill(configuration.isOn ? Color.blue : Styles.primaryText)
                    .frame(width: 50, height: 30)
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)

                // Square slider with primary background color
                Rectangle()
                    .fill(Styles.secondaryBackground)
                    .frame(width: 24, height: 24)
                    .padding(3)
                    .shadow(radius: 2)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}



