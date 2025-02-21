//
//  ActivityStatsView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/20/25.
//

import SwiftUI

struct ActivityStatsView: View {
    var activityName: String
    var activityImage: String
    var closeAction: () -> Void // ✅ Function to close the entire WorkoutView
    @Binding var diaryEntries: [DiaryEntry] // ✅ Binding to update diary

    @State private var duration: String = ""
    @State private var caloriesBurned: String = ""

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false // ✅ Toggles time picker visibility

    var body: some View {
        VStack(spacing: 20) {
            // ✅ ACTIVITY HEADER (Image + Name)
            VStack(spacing: 10) {
                Image(activityImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 3)

                Text(activityName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Styles.primaryText)
            }
            .padding(.top, 10)

            // ✅ INPUT FIELDS
            VStack(spacing: 15) {
                FloatingTextField(placeholder: " Duration (minutes) ", text: $duration)
                    .keyboardType(.numberPad)

                FloatingTextField(placeholder: " Calories Burned ", text: $caloriesBurned)
                    .keyboardType(.numberPad)
                    .onReceive(caloriesBurned.publisher.collect()) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let trimmed = String(filtered.prefix(4)) // ✅ Limit to 4 digits (9999 max)
                        if caloriesBurned != trimmed { caloriesBurned = trimmed }
                    }

                FloatingInputWithAction(
                    placeholder: " Time ",
                    displayedText: formattedTime,
                    action: { showTimePicker = true },
                    hasPickedValue: .constant(true)
                )
            }
            .padding(.horizontal)

            Spacer()

            // ✅ BOTTOM NAVIGATION BAR (Directly calls closeAction)
            bottomNavBar()
        }
        .frame(maxWidth: .infinity)
        .background(Styles.secondaryBackground)
        .overlay(
            Group {
                if showTimePicker {
                    timePickerOverlay
                }
            }
        )
    }

    // ✅ Save Workout & Close WorkoutView Instantly
    private func saveActivityToDiary() {
        guard !duration.isEmpty, !caloriesBurned.isEmpty else {
            print("⚠️ Missing required fields")
            return
        }

        let durationText = "\(duration) min"
        let caloriesValue = Int(caloriesBurned) ?? 0

        let newEntry = DiaryEntry(
            time: formattedTime,
            iconName: activityImage,
            description: activityName,
            detail: durationText,
            calories: -caloriesValue,
            type: "Workout",
            imageName: activityImage, // ✅ Uses image filename for pre-defined workouts
            imageData: nil // ✅ No user-selected image for ADVWorkoutAddView
        )

        DispatchQueue.main.async {
            diaryEntries.append(newEntry)
        }

        print("✅ Activity Saved: \(newEntry)")
        closeAction()
    }


    // ✅ FORMATTED TIME
    private var formattedTime: String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)"
    }

    // ✅ TIME PICKER OVERLAY
    private var timePickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Select Time")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                timePicker
                    .padding(.horizontal)

                HStack {
                    Button("Cancel") {
                        showTimePicker = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Styles.primaryText)

                    Button("Save") {
                        showTimePicker = false
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

    // ✅ TIME PICKER VIEW
    private var timePicker: some View {
        HStack {
            Picker("Hour", selection: $selectedHour) {
                ForEach(1...12, id: \.self) { hour in
                    Text("\(hour)").tag(hour)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("Minutes", selection: $selectedMinute) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(String(format: "%02d", minute))").tag(minute)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("AM/PM", selection: $selectedPeriod) {
                Text("AM").tag("AM")
                    .foregroundColor(Styles.primaryText)
                Text("PM").tag("PM")
                    .foregroundColor(Styles.primaryText)
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()
        }
    }

    // ✅ BOTTOM NAVIGATION BAR (Directly Closes WorkoutView)
    private func bottomNavBar() -> some View {
        ZStack {
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack {
                // 🔴 X Button (Closes WorkoutView Directly)
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: "xmark")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    closeAction() // ✅ Closes entire WorkoutView
                }

                Spacer().frame(width: 100) // ✅ Matches Quick Add Spacing

                // ➕ "+" Button (Saves & Closes WorkoutView)
                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(Styles.secondaryBackground)
                }
                .onTapGesture {
                    saveActivityToDiary() // ✅ Saves workout & closes WorkoutView
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .offset(y: -36)
        }
        .frame(height: 96)
    }
}

