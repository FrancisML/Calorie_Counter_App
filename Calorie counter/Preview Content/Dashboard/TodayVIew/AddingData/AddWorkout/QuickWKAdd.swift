//
//  QuickWKAdd.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/18/25.
//

import SwiftUI

struct QuickWKAddView: View {
    @State private var workoutImage: UIImage? = UIImage(named: "DefaultWorkout") // ✅ Default image
    @State private var workoutName: String = ""
    @State private var duration: String = ""
    @State private var calories: String = ""

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false // ✅ Toggles picker visibility

    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // ✅ Top Row: Image + Name Input
            HStack(spacing: 20) {
                // ✅ Picture Input (Top Left)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(workoutImage != UIImage(named: "DefaultWorkout") ? Color.green : Styles.primaryText, lineWidth: 3)
                        .frame(width: 100, height: 100)

                    Image(uiImage: workoutImage ?? UIImage(named: "DefaultWorkout")!) // ✅ Always displays valid image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    // ✅ Overlay for "Add" Button
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Button(action: {
                        showActionSheet = true
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 100)
                    }
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("Select Image"),
                            buttons: [
                                .default(Text("Take a Photo")) {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        imagePickerSourceType = .camera
                                        showImagePicker = true
                                    }
                                },
                                .default(Text("Choose from Library")) {
                                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                                        imagePickerSourceType = .photoLibrary
                                        showImagePicker = true
                                    }
                                },
                                .destructive(Text("Remove Image")) {
                                    workoutImage = UIImage(named: "DefaultWorkout") // ✅ Reset to default
                                },
                                .cancel()
                            ]
                        )
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $workoutImage, sourceType: imagePickerSourceType)
                    }
                }

                // ✅ Name Input (Right Side)
                FloatingTextField(placeholder: " Workout Name ", text: $workoutName)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // ✅ Other Inputs (Below Image & Name)
            VStack(spacing: 15) {
                FloatingTextField(placeholder: " Duration (mins) ", text: $duration)
                    .keyboardType(.numberPad)

                // ✅ Calories Input (Only Accepts Integers)
                FloatingTextField(placeholder: " Calories Burned ", text: $calories)
                    .keyboardType(.numberPad)
                    .onReceive(calories.publisher.collect()) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let trimmed = String(filtered.prefix(4)) // ✅ Limit to 4 digits (9999 max)
                        if calories != trimmed { calories = trimmed }
                    }

                // ✅ Time Input with Picker
                FloatingInputWithAction(
                    placeholder: " Time ",
                    displayedText: formattedTime,
                    action: { showTimePicker = true },
                    hasPickedValue: .constant(true)
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
        .onAppear {
            setCurrentTime() // ✅ Sets the time when the view appears
        }
        .overlay(
            Group {
                if showTimePicker {
                    timePickerOverlay
                }
            }
        )
    }

    // ✅ Automatically sets the current time
    private func setCurrentTime() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        selectedHour = currentHour % 12 == 0 ? 12 : currentHour % 12
        selectedMinute = Calendar.current.component(.minute, from: Date())
        selectedPeriod = currentHour >= 12 ? "PM" : "AM"
    }

    // ✅ Time Formatting for Display
    private var formattedTime: String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)"
    }

    // ✅ Time Picker Overlay
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

    // ✅ Time Picker (3 Columns: Hours, Minutes, AM/PM)
    private var timePicker: some View {
        HStack {
            Picker("Hour", selection: $selectedHour) {
                ForEach(1...12, id: \.self) { hour in
                    Text("\(hour)").tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("Minutes", selection: $selectedMinute) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(String(format: "%02d", minute))").tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("AM/PM", selection: $selectedPeriod) {
                Text("AM").tag("AM")
                Text("PM").tag("PM")
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()
        }
    }
}

