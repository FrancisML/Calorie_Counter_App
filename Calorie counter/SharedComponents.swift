//
//  SharedComponents.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

extension Color {
    static let customGray = Color(red: 0.2, green: 0.2, blue: 0.2) // RGB for #666666
}

// MARK: - Floating Text Field
struct FloatingTextField: View {
    var placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    private var borderColor: Color {
        if !text.isEmpty {
            return Color.blue
        } else if isFocused {
            return Color.blue
        } else {
            return Color.gray
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 2)

            if isFocused || !text.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.customGray)
                    )
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: isFocused || !text.isEmpty)
            }

            HStack {
                TextField(isFocused || !text.isEmpty ? "" : placeholder, text: $text)
                    .focused($isFocused)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)

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
        hasPickedValue ? Color.blue : Color.gray
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 2)

            // Placeholder ONLY appears if a value has been selected
            if hasPickedValue {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.customGray)
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
                        .foregroundColor(displayedText.isEmpty ? .gray : .primary)
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
                .padding(.bottom, 10)

           

            // **Custom Slider with Tick Marks**
            ZStack(alignment: .leading) {
                // **Track (Moves Down)**
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: trackWidth, height: 10)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .offset(y: trackOffset)  // Move track down

                // **Tick Marks (Moves Down with Track)**
                HStack(spacing: (trackWidth - thumbSize) / CGFloat(stepCount)) {
                    ForEach(0...stepCount, id: \.self) { index in
                        Rectangle()
                            .frame(width: 3, height: 20) //  Tick Mark Size
                            .foregroundColor(Color.customGray)
                    }
                }
                .frame(width: trackWidth, height: 20)
                .offset(y: trackOffset)  // Move tick marks down to match the track

                // **Draggable Image (Acts as the Thumb)**
                Image("SliderIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newOffset = min(
                                    max(gesture.translation.width + stepPosition(activityLevel), 0),  //  Left boundary
                                    trackWidth - thumbSize  //  Right boundary (fixed)
                                )
                                dragOffset = newOffset
                                liveActivityLevel = closestStep(for: dragOffset)  //  Live update
                            }
                            .onEnded { _ in
                                let newLevel = closestStep(for: dragOffset)
                                activityLevel = newLevel  //  Saves final selection
                                liveActivityLevel = newLevel  //  Ensures UI stays synced
                                dragOffset = stepPosition(newLevel)  // Snap to step position
                            }
                    )
            }
            .frame(width: trackWidth, height: 80)  // Increased height for spacing
            // **Activity Image (Updates LIVE)**
         

            // **Activity Name (Updates LIVE)**
            Text(activityNames[liveActivityLevel])
                .font(.subheadline)
                .font(.title2)
                .fontWeight(.bold)

            // **Activity Description (Updates LIVE)**
            Text(activityDescriptions[liveActivityLevel])
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
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

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
// MARK: - Horizontal whell picker

struct HorizontalWheelPicker: View {
    @Binding var selectedValue: Double
    @Binding var useMetric: Bool
    @Binding var isCalorieGoalSelected: Bool  // New binding to track goal type selection
  // Added to switch between imperial and metric

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
            Text(selectionMessage(for: liveValue))
                .font(.title2)
                .foregroundColor(isCalorieGoalSelected ? .gray : .white)  // Change text color based on goal type

            GeometryReader { geometry in
                ZStack {
                    // Change Indicator Image Based on Goal Type
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
                            let tickColor: Color = isCalorieGoalSelected ? .gray : (isMajorTick ? .yellow : .white)
                            let labelColor: Color = isCalorieGoalSelected ? .gray : .yellow
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
                                            .foregroundColor(labelColor)  // Update label color
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


    // Get the exact x-offset for each step to align with yellow ticks
    private func stepPosition(_ value: Double) -> CGFloat {
        let majorTickSpacing = tickSpacing * 5 * 2
        if let index = values.firstIndex(of: value) {
            let centeredIndex = index - (values.count / 2)
            return CGFloat(centeredIndex) * majorTickSpacing
        }
        return 0
    }

    // Ensures snapping goes to the closest valid yellow tick
    private func closestValue(for offset: CGFloat) -> Double {
        let majorTickSpacing = tickSpacing * 5 * 2
        let indexOffset = Int(round(offset / majorTickSpacing)) + (values.count / 2)
        return values[max(0, min(indexOffset, values.count - 1))]
    }

    // Selection Message for Displaying Changes
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

    // Format Labels for Metric and Imperial Values
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


// Preview Struct


