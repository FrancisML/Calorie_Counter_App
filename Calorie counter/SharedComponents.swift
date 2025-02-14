//
//  SharedComponents.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI
import UIKit
import Foundation

extension Color {
    static let customGray = Color(red: 0.2, green: 0.2, blue: 0.2) // RGB for #666666
}

// MARK: - Floating Text Field
struct FloatingTextField: View {
    var placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @EnvironmentObject var themeManager: ThemeManager  // Ensures reactivity on theme change

    private var borderColor: Color {
        if !text.isEmpty || isFocused {
            return Color.blue
        } else {
            return Styles.primaryText
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(borderColor, lineWidth: 1)

            if isFocused || !text.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(Styles.primaryText)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Styles.secondaryBackground)
                    )
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: isFocused || !text.isEmpty)
            }

            HStack {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Styles.secondaryText)  // Updates with theme change
                            .padding(.horizontal, 10)
                            
                    }

                    TextField("", text: $text)
                        .focused($isFocused)
                        .font(.system(size: 18))
                        .foregroundColor(Styles.primaryText)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                }

                if !text.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.green)
                        .padding(.trailing, 8)
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 0)
    }
}


     


// MARK: - Floating Input With Action

struct FloatingInputWithAction: View {
    var placeholder: String
    var displayedText: String
    var action: () -> Void
    @Binding var hasPickedValue: Bool
    @State private var isFocused: Bool = false

    private var borderColor: Color {
        hasPickedValue ? Color.blue : Styles.primaryText
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(borderColor, lineWidth: 1)

            // Placeholder ONLY appears if a value has been selected
            if hasPickedValue {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(Styles.primaryText)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Styles.secondaryBackground)
                    )
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: hasPickedValue)
            }

            Button(action: {
                action()
            }) {
                HStack {
                    Text(displayedText.isEmpty ? placeholder : displayedText)
                        .foregroundColor(Styles.secondaryText)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)

                    if hasPickedValue {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.green)
                            .padding(.trailing, 8)
                    }
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 0)
    }
}

// MARK: - Height Picker
struct HeightPicker: View {
    @Binding var heightFeet: Int
    @Binding var heightCm: Int
    @Binding var heightInches: Int
    @Binding var useMetric: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Height")
                .font(.headline)

            if useMetric {
                Picker("Height (cm)", selection: $heightCm) {
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

            Toggle("Use Metric (cm)", isOn: $useMetric)
        }
    }
}
// MARK: - Activity Level View
import SwiftUI

struct CustomActivitySlider: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var activityLevel: Int

    private let activityNames = ["None", "Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extra Active"]
    private let activityDescriptions = [
        "No physical activity at all.",
        "Little to no exercise. Mostly sitting throughout the day.",
        "Light exercise or sports 1-3 days per week.",
        "Moderate exercise or sports 3-5 days per week.",
        "Hard exercise or sports 6-7 days per week.",
        "Very intense exercise, physical job, or training twice per day."
    ]

    private let stepCount = 5  // Number of stops (0 to 5)
    private let trackOffset: CGFloat = 30  //  Move the track & tick marks down

    @State private var dragOffset: CGFloat = 0
    @State private var liveActivityLevel: Int  //  Live updates while dragging

    private let trackWidth: CGFloat = UIScreen.main.bounds.width * 0.75  //  Keep within parent
    private let thumbSize: CGFloat = 55  //  Thumb (slider image) size

    init(activityLevel: Binding<Int>) {
        _activityLevel = activityLevel
        _liveActivityLevel = State(initialValue: activityLevel.wrappedValue)  //  Sync initial value
    }

    var body: some View {
        VStack(spacing: 15) {
            Text("Activity Level")
                .font(.headline)
                .foregroundColor(Styles.primaryText)
                .padding(.bottom, 10)

           

            // **Custom Slider with Tick Marks**
            ZStack(alignment: .leading) {
                // **Track (Moves Down)**
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: trackWidth, height: 10)
                    .foregroundColor(Styles.primaryText.opacity(0.5))
                    .offset(y: trackOffset)  // Move track down

                // **Tick Marks (Moves Down with Track)**
                HStack(spacing: (trackWidth - thumbSize) / CGFloat(stepCount)) {
                    ForEach(0...stepCount, id: \.self) { index in
                        Rectangle()
                            .frame(width: 3, height: 20) //  Tick Mark Size
                            .foregroundColor(Styles.secondaryBackground)
                    }
                }
                .frame(width: trackWidth, height: 20)
                .offset(y: trackOffset)  // Move tick marks down to match the track

                // **Draggable Image (Acts as the Thumb)**
                Image(themeManager.isDarkMode ? "SliderIcon" : "SliderIconDark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newOffset = min(
                                    max(gesture.translation.width + stepPosition(activityLevel), 0),
                                    trackWidth - thumbSize
                                )
                                dragOffset = newOffset
                                liveActivityLevel = closestStep(for: dragOffset)
                            }
                            .onEnded { _ in
                                let newLevel = closestStep(for: dragOffset)
                                activityLevel = newLevel
                                liveActivityLevel = newLevel
                                dragOffset = stepPosition(newLevel)
                            }
                    )

            }
            .frame(width: trackWidth, height: 80)  // Increased height for spacing
            // **Activity Image (Updates LIVE)**
         

            // **Activity Name (Updates LIVE)**
            Text(activityNames[liveActivityLevel])
                .font(.subheadline)
                .foregroundColor(Styles.secondaryText)
                .font(.title2)
                .fontWeight(.bold)

            // **Activity Description (Updates LIVE)**
            Text(activityDescriptions[liveActivityLevel])
                .font(.subheadline)
                .foregroundColor(Styles.secondaryText)
                .padding(.horizontal, 20)
        }
        .onAppear {
            dragOffset = stepPosition(activityLevel)
            liveActivityLevel = activityLevel  // Sync initial state
        }
    }

    // 🔹 **Returns the position of a step**
    private func stepPosition(_ step: Int) -> CGFloat {
        let stepSpacing = (trackWidth - thumbSize) / CGFloat(stepCount)
        return stepSpacing * CGFloat(step)
    }

    // 🔹 **Finds the closest step based on position**
    private func closestStep(for offset: CGFloat) -> Int {
        let stepSpacing = (trackWidth - thumbSize) / CGFloat(stepCount)
        return Int(round(offset / stepSpacing))
    }
}



// MARK: - Utility Function to Present Alerts
func presentAlert(alert: UIAlertController) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first,
       let rootViewController = window.rootViewController {
        rootViewController.present(alert, animated: true)
    }
}


// MARK: - Horizontal Wheel Picker

struct HorizontalWheelPicker: View {
    @Binding var selectedValue: Double
    @Binding var useMetric: Bool
    @Binding var isCalorieGoalSelected: Bool  // Tracks goal type selection

    // Imperial (lbs) and Metric (kg) Value Arrays
    private let imperialValues: [Double] = [-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2]
    private let metricValues: [Double] = [-1, -0.75, -0.50, -0.25, 0, 0.25, 0.50, 0.75, 1]
    private var values: [Double] { useMetric ? metricValues : imperialValues }

    private let totalTicks = 41  // 9 major ticks + 32 small ones (4 per section)

    private let indicatorWidth: CGFloat = 3
    private let tickHeightTall: CGFloat = 30
    private let tickHeightSmall: CGFloat = 12
    private let tickSpacing: CGFloat = 5

    @State private var dragOffset: CGFloat = 0
    @State private var liveValue: Double = 0
    @State private var initialOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 10) {
            // Updated selection message style
            Text(selectionMessage(for: liveValue))
                .font(.headline)  // Slightly smaller than title2
                .foregroundColor(isCalorieGoalSelected ? .gray : Styles.primaryText)  // Dynamic text color

            GeometryReader { geometry in
                ZStack {
                    // Change indicator image based on goal type
                    Image(isCalorieGoalSelected ? "grayscaleIndicator" : "scaleIndicator")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: tickHeightTall + 10)
                        .offset(y: -7)
                        .zIndex(1)

                    // Moving Scale (Tick Marks)
                    HStack(spacing: tickSpacing) {
                        ForEach(0..<totalTicks, id: \.self) { index in
                            let isMajorTick = index % 5 == 0
                            let tickColor: Color = isCalorieGoalSelected
                                ? .gray
                                : (isMajorTick ? Styles.primaryText : Styles.primaryBackground)  // Updated tick colors
                            let labelColor: Color = isCalorieGoalSelected
                                ? .gray
                                : Styles.primaryText  // Updated label color
                            let tickHeight = isMajorTick ? tickHeightTall : tickHeightSmall

                            VStack(spacing: 2) {
                                Rectangle()
                                    .fill(tickColor)
                                    .frame(width: 2, height: tickHeight)
                                    .frame(maxHeight: tickHeightTall, alignment: .bottom)

                                if isMajorTick {
                                    let labelIndex = index / 5
                                    if values.indices.contains(labelIndex) {
                                        let labelValue = values[labelIndex]
                                        let formattedValue = formatValue(labelValue)
                                        Text(formattedValue)
                                            .font(.caption2)
                                            .foregroundColor(labelColor)
                                            .fixedSize()
                                    }
                                } else {
                                    Spacer().frame(height: 14)
                                }
                            }
                            .frame(width: tickSpacing)
                        }
                    }
                    .frame(width: geometry.size.width, height: tickHeightTall + 20)
                    .offset(x: dragOffset)
                }
                .frame(width: geometry.size.width, height: tickHeightTall + 40)
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let maxDragOffset = 340
                            let newOffset = min(max(Int(gesture.translation.width + initialOffset), -maxDragOffset), maxDragOffset)
                            dragOffset = CGFloat(newOffset)
                            liveValue = -closestValue(for: dragOffset)
                        }
                        .onEnded { _ in
                            let newValue = -closestValue(for: dragOffset)
                            selectedValue = newValue
                            dragOffset = stepPosition(-newValue)
                            initialOffset = dragOffset
                        }
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: tickHeightTall)
            .padding(.bottom, 40)
        }
        .onAppear {
            dragOffset = stepPosition(selectedValue)
            liveValue = selectedValue
        }
    }

    // Get the exact x-offset for each step to align with major ticks
    private func stepPosition(_ value: Double) -> CGFloat {
        let majorTickSpacing = tickSpacing * 5 * 2
        if let index = values.firstIndex(of: value) {
            let centeredIndex = index - (values.count / 2)
            return CGFloat(centeredIndex) * majorTickSpacing
        }
        return 0
    }

    // Ensures snapping goes to the closest valid tick
    private func closestValue(for offset: CGFloat) -> Double {
        let majorTickSpacing = tickSpacing * 5 * 2
        let indexOffset = Int(round(offset / majorTickSpacing)) + (values.count / 2)
        return values[max(0, min(indexOffset, values.count - 1))]
    }

    // Selection message for displaying weight changes
    private func selectionMessage(for value: Double) -> String {
        if value < 0 {
            return useMetric
                ? "Lose \(String(format: "%.2f", abs(value))) kg per week"
                : "Lose \(String(format: "%.1f", abs(value))) lbs per week"
        } else if value == 0 {
            return "Maintain current weight"
        } else {
            return useMetric
                ? "Gain \(String(format: "%.2f", value)) kg per week"
                : "Gain \(String(format: "%.1f", value)) lbs per week"
        }
    }

    // Format labels for metric and imperial values
    private func formatValue(_ value: Double) -> String {
        if useMetric {
            return value > 0
                ? "+\(String(format: "%.2f", value))"
                : String(format: "%.2f", value)
        } else {
            return value > 0
                ? "+\(String(format: "%.1f", value))"
                : String(format: "%.1f", value)
        }
    }
}

// SharedComponents.swift

import SwiftUI
import Combine

// Your existing shared components here...
// MARK: - DatePicker


struct CustomDatePicker: UIViewRepresentable {
    @Binding var selectedDate: Date
    var minimumDate: Date?

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.minimumDate = minimumDate

        // ✅ Remove the gray background by setting a clear background color
        datePicker.backgroundColor = .clear

        // ✅ Set text color to match theme
        datePicker.setValue(UIColor(Styles.primaryText), forKeyPath: "textColor")

        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selectedDate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CustomDatePicker

        init(_ parent: CustomDatePicker) {
            self.parent = parent
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selectedDate = sender.date
        }
    }
}


// MARK: - ThemeManager (Temporary)
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false {
        didSet {
            Styles.isDarkMode = isDarkMode // Update the Styles struct globally
        }
    }
}


// Preview Struct
// MARK: -BMR



func calculateBMR(weight: Int32, heightCm: Int32, heightFt: Int32, heightIn: Int32, age: Int32, gender: String?, activityInt: Int32, useMetric: Bool) -> Int32 {
    // Convert height to cm if using imperial
    let finalHeightCm: Double = useMetric ? Double(heightCm) : (Double(heightFt) * 30.48 + Double(heightIn) * 2.54)

    // Convert weight to kg if using imperial
    let finalWeightKg: Double = useMetric ? Double(weight) : Double(weight) * 0.453592

    // Validate inputs before calculating
    guard finalHeightCm > 0, finalWeightKg > 0, age > 0, let gender = gender else {
        print("Error: Invalid values for BMR calculation")
        return 0
    }

    // BMR Formula (Mifflin-St Jeor Equation)
    var bmr: Double
    if gender.lowercased() == "man" {
        bmr = (10 * finalWeightKg) + (6.25 * finalHeightCm) - (5 * Double(age)) + 5
    } else {
        bmr = (10 * finalWeightKg) + (6.25 * finalHeightCm) - (5 * Double(age)) - 161
    }

    // Apply Activity Level Multiplier
    let activityMultipliers: [Double] = [1, 1.2, 1.375, 1.55, 1.725, 1.9]
    let activityMultiplier = activityMultipliers[Int(activityInt)]

    let finalBMR = bmr * activityMultiplier

    print("Calculated BMR: \(finalBMR)")
    return Int32(finalBMR)
}
// MARK: -WaterPicker

struct WaterGoalPicker: View {
    var useMetric: Bool
    @Binding var selectedGoal: CGFloat
    @Binding var isWaterPickerPresented: Bool
    @Binding var selectedUnit: String  // ✅ Bind to DiaryEntriesView

    @State private var selectedValue: Double = 0
    
    private let imperialValues = Array(stride(from: 0, through: 128, by: 8)).map { Double($0) }
    private let gallonValues = [0.0, 0.25, 0.5, 0.75, 1.0]
    private let metricValues = [0, 1, 2, 3, 4].map { Double($0) }
    private let milliliterValues = Array(stride(from: 0, through: 4000, by: 250)).map { Double($0) }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Select Water Goal")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                HStack {
                    Picker("Amount", selection: $selectedValue) {
                        ForEach(currentValues(), id: \.self) { value in
                            Text(value == floor(value) ? "\(Int(value))" : String(format: "%.2f", value))
                                .foregroundColor(Styles.primaryText)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.4)
                    .clipped()

                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(currentUnits(), id: \.self) { unit in
                            Text(unit)
                                .foregroundColor(Styles.primaryText)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.4)
                    .clipped()
                    .onChange(of: selectedUnit) { _ in
                        selectedValue = 0
                    }
                }

                HStack {
                    Button("Cancel") {
                        isWaterPickerPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Styles.primaryText)

                    Button("Save") {
                        DispatchQueue.main.async {
                            selectedGoal = CGFloat(selectedValue) // ✅ Force UI update
                        }
                        isWaterPickerPresented = false
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
        .onAppear {
            selectedValue = Double(selectedGoal)
        }
    }

    private func currentValues() -> [Double] {
        switch selectedUnit {
        case "Gallons": return gallonValues
        case "Liters": return metricValues
        case "Milliliters": return milliliterValues
        default: return imperialValues
        }
    }

    private func currentUnits() -> [String] {
        return useMetric ? ["Liters", "Milliliters"] : ["fl oz", "Gallons"]
    }
    
}
