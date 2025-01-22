//
//  UserSetupView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/21/25.
//

import SwiftUI

struct UserSetupView: View {
    @State private var name: String = ""
    @State private var gender: String = ""
    @State private var birthDate: Date? = nil
    @State private var profilePicture: UIImage? = nil
    @State private var showDatePicker: Bool = false
    @State private var temporaryDate: Date? = nil


    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header with Logo and App Name
                HStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)

                    Text("Calorie Counter")
                        .font(.title)
                        .fontWeight(.bold)

                    Spacer()
                }
                .padding()

                // Title and Subtitle
                VStack(spacing: 10) {
                    Text("Personal Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Please enter your information as accurately as possible")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300) // Limit width for wrapping
                }
                .frame(maxWidth: .infinity) // Makes the VStack take full width
                .multilineTextAlignment(.center) // Centers the text within the VStack
                .padding(.horizontal)

                // Input Fields
                VStack(spacing: 20) {
                    // Name Input
                    FloatingTextField(placeholder: " First Name ", text: $name)

                    // Gender Selection
                    HStack(spacing: 20) {
                        Button(action: { gender = "Man" }) {
                            Text("Man")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(gender == "Man" ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: { gender = "Woman" }) {
                            Text("Woman")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(gender == "Woman" ? Color.pink : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    // Birth Date Selection
                    FloatingInputWithAction(
                        placeholder: "Birthday",
                        displayedText: birthDateFormatted,
                        action: { showDatePicker = true }
                    )

                    // Profile Picture Section
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Add Profile Picture")
                                .font(.headline)

                            Text("Optional")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if let image = profilePicture {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)

                                Image("Empty man PP")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)

                                Button(action: { /* Add action to pick image */ }) {
                                    Text("Add")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(5)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .offset(y: 40)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20) // Add padding for centering
                .padding(.vertical, 20)   // Add vertical padding
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1)) // Light gray background
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2) // Lighter gray border
                )
                .padding(.horizontal, 40) // Outer padding for layout

                Spacer()

                // Next Button
                Button(action: { /* Proceed to next screen */ }) {
                    Text("Next")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(canProceed ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!canProceed)
                .padding(.horizontal)
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    // DatePicker UI
                    DatePicker(
                        "Select Your Birthday",
                        selection: Binding(
                            get: { temporaryDate ?? Date() }, // Show current date if no temporary date
                            set: { temporaryDate = $0 } // Update the temporary date
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()

                    // Save and Cancel Buttons
                    HStack {
                        Button("Cancel") {
                            showDatePicker = false // Dismiss the picker without saving
                        }
                        .frame(maxWidth: .infinity)

                        Button("Save") {
                            if let selectedDate = temporaryDate {
                                birthDate = selectedDate // Save the selected date
                            }
                            showDatePicker = false // Dismiss the picker
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
            }


           
        }
    }

    // Computed property to check if all required fields are filled
    private var canProceed: Bool {
        !name.isEmpty && !gender.isEmpty
    }

    // Computed property to format the birth date
    private var birthDateFormatted: String {
        guard let birthDate = birthDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
}


struct FloatingTextField: View {
    var placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 2)

            if isFocused || !text.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(Color(.systemBackground))
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: isFocused || !text.isEmpty)
            }

            HStack {
                TextField(isFocused || !text.isEmpty ? "" : placeholder, text: $text)
                    .focused($isFocused)
                    .font(.system(size: 18))
                    .foregroundColor(!text.isEmpty ? .yellow : .primary)
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

struct FloatingInputWithAction: View {
    var placeholder: String
    var displayedText: String
    var action: () -> Void
    @State private var isFocused: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 2)

            if isFocused || !displayedText.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(Color(.systemBackground))
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: isFocused || !displayedText.isEmpty)
            }

            Button(action: {
                isFocused = true
                action()
            }) {
                HStack {
                    Text(displayedText.isEmpty ? placeholder : displayedText)
                        .foregroundColor(displayedText.isEmpty ? .gray : .primary)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)

                    if !displayedText.isEmpty {
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










