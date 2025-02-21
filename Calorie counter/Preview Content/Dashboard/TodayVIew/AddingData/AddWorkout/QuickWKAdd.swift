//
//  QuickWKAdd.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/18/25.
//


//
//  QuickWKAdd.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/18/25.
//

import SwiftUI

struct QuickWKAddView: View {
    @Binding var diaryEntries: [DiaryEntry] // ✅ Binding to update the diary
    var closeAction: () -> Void // ✅ Function to close the view

    @State private var workoutImage: UIImage? = UIImage(named: "DefaultWorkout") // ✅ Default image
    @State private var workoutName: String = ""
    @State private var duration: String = ""
    @State private var calories: String = ""

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false // ✅ Toggles time picker visibility

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

                    Image(uiImage: workoutImage ?? UIImage(named: "DefaultWorkout")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

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

                FloatingTextField(placeholder: " Calories Burned ", text: $calories)
                    .keyboardType(.numberPad)
                    .onReceive(calories.publisher.collect()) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let trimmed = String(filtered.prefix(4))
                        if calories != trimmed { calories = trimmed }
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

            // ✅ Bottom Navigation Bar
            bottomNavBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
        .onAppear {
            setCurrentTime()
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

    // ✅ Save Workout to Diary
    private func saveWorkoutToDiary() {
        let trimmedName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDuration = duration.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCalories = calories.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedDuration.isEmpty, !trimmedCalories.isEmpty else {
            print("⚠️ Missing required fields")
            return
        }

        let durationText = formatDuration(trimmedDuration)
        let caloriesValue = Int(trimmedCalories) ?? 0

        let newEntry = DiaryEntry(
            time: formattedTime,
            iconName: "CustomWorkout",
            description: trimmedName,
            detail: durationText,
            calories: -caloriesValue,
            type: "Workout",
            imageName: nil, // ✅ No filename since it's a user-selected image
            imageData: workoutImage?.jpegData(compressionQuality: 0.8) // ✅ Store user-selected image
        )

        DispatchQueue.main.async {
            diaryEntries.append(newEntry)
        }

        closeAction()
    }

    private func formatDuration(_ duration: String) -> String {
        if let minutes = Int(duration), minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes == 0 ? "\(hours) hr" : "\(hours) hr \(remainingMinutes) min"
        }
        return "\(duration) min"
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

                FloatingInputWithAction(
                    placeholder: " Time ",
                    displayedText: formattedTime,
                    action: { showTimePicker = true },
                    hasPickedValue: .constant(true)
                )
                .padding()

                Button("Close") {
                    showTimePicker = false
                }
                .padding()
                .foregroundColor(.blue)
            }
            .padding()
            .background(Styles.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 5)
        }
    }

    // ✅ Bottom Navigation Bar
    private func bottomNavBar() -> some View {
        ZStack {
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack {
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
                    closeAction()
                }

                Spacer().frame(width: 100)

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
                    saveWorkoutToDiary()
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .offset(y: -36)
        }
        .frame(height: 96)
    }
}
