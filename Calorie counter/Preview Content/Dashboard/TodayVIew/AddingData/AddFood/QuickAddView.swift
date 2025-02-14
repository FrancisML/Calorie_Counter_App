//
//  QuickAddView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//

import SwiftUI

struct QuickAddView: View {
    @State private var foodImage: UIImage? = UIImage(named: "DefaultFood") // ✅ Default image
    @State private var foodName: String = ""
    @State private var servingSize: String = ""
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
                        .stroke(foodImage != UIImage(named: "DefaultFood") ? Color.green : Styles.primaryText, lineWidth: 3)
                        .frame(width: 100, height: 100)

                    Image(uiImage: foodImage ?? UIImage(named: "DefaultFood")!) // ✅ Always displays valid image
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
                                    foodImage = UIImage(named: "DefaultFood") // ✅ Reset to default
                                },
                                .cancel()
                            ]
                        )
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $foodImage, sourceType: imagePickerSourceType)
                    }
                }

                // ✅ Name Input (Right Side)
                FloatingTextField(placeholder: " Food Name ", text: $foodName)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // ✅ Other Inputs (Below Image & Name)
            VStack(spacing: 15) {
                FloatingTextField(placeholder: " Serving Size ", text: $servingSize)

                // ✅ Calories Input (Only Accepts Integers)
                FloatingTextField(placeholder: " Calories ", text: $calories)
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

    // ✅ Time Picker (3 Columns: Hours, Minutes, AM/PM)
    private var timePicker: some View {
        HStack {
            // ✅ Hours Picker
            Picker("Hour", selection: $selectedHour) {
                ForEach(1...12, id: \.self) { hour in
                    Text("\(hour)")
                        .foregroundColor(Styles.primaryText) // ✅ Styled text
                        .tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            // ✅ Minutes Picker
            Picker("Minutes", selection: $selectedMinute) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(String(format: "%02d", minute))")
                        .foregroundColor(Styles.primaryText) // ✅ Styled text
                        .tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            // ✅ AM/PM Picker
            Picker("AM/PM", selection: $selectedPeriod) {
                Text("AM")
                    .foregroundColor(Styles.primaryText) // ✅ Styled text
                    .tag("AM")
                Text("PM")
                    .foregroundColor(Styles.primaryText) // ✅ Styled text
                    .tag("PM")
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()
        }
    }
}
