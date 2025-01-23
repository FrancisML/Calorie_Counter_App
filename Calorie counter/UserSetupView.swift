//
//  UserSetupView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/21/25.
//

import SwiftUI


extension Color {
    static let customGray = Color(red: 0.2, green: 0.2, blue: 0.2) // RGB for #666666
}

struct UserSetupView: View {
    @State private var name: String = ""
    @State private var gender: String = ""
    @State private var birthDate: Date? = nil
    @State private var profilePicture: UIImage? = nil
    @State private var showDatePicker: Bool = false
    @State private var temporaryDate: Date? = nil
    @State private var hasPickedDate: Bool = false
    
    


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
                        placeholder: " Birthday ",
                        displayedText: birthDateFormatted,
                        action: { showDatePicker = true },
                        hasPickedDate: $hasPickedDate // Pass the binding to hasPickedDate
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

                        ZStack {
                            // Background Circle
                            Circle()
                                .fill(Color.gray.opacity(0.3)) // Transparent gray base circle
                                .frame(width: 100, height: 100)

                            // Background Image (scaled to fit the circle)
                            if let image = profilePicture {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill() // Fills the circle completely
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle()) // Ensures it stays circular
                                    .overlay(
                                        Circle()
                                            .fill(Color.black.opacity(0.2)) // Slightly see-through gray overlay
                                    )
                            } else {
                                Image("Empty man PP")
                                    .resizable()
                                    .scaledToFill() // Fills the circle completely
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle()) // Ensures it stays circular
                                    .overlay(
                                        Circle()
                                            .fill(Color.black.opacity(0.2)) // Slightly see-through gray overlay
                                    )
                            }

                            // Add Button
                            Button(action: {
                                // Add action to pick image
                            }) {
                                Text("Add")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(10)
                                    .background(Color.clear) // Transparent background
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.blue, lineWidth: 1) // Blue border for the button
                                    )
                            }
                            .frame(width: 60, height: 30) // Square button size
                        }
                    }


                }
                .padding(.horizontal, 20) // Add padding for centering
                .padding(.vertical, 20)   // Add vertical padding
           
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.customGray) // Use the custom color
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white, lineWidth: 2) // Border color and width
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
            .overlay(
                Group {
                    if showDatePicker {
                        ZStack {
                            // Dim background
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()

                            // DatePicker Pop-Up
                            VStack(spacing: 20) {
                                Text("Select Your Birthday")
                                    .font(.headline)

                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { temporaryDate ?? birthDate ?? Date() },
                                        set: { temporaryDate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .padding(.horizontal)

                                // Save and Cancel Buttons
                                HStack {
                                    Button("Cancel") {
                                        temporaryDate = nil // Reset temporary date
                                        hasPickedDate = birthDate != nil // Retain the border color if there's an existing date
                                        showDatePicker = false // Close picker
                                    }
                                    .frame(maxWidth: .infinity)

                                    Button("Save") {
                                        if let selectedDate = temporaryDate {
                                            birthDate = selectedDate // Save the selected date
                                            hasPickedDate = true // Mark as date picked
                                        }
                                        showDatePicker = false // Close picker
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.customGray) // Match input style
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 2) // Match border style
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.9) // Match Vstack width
                        }
                    }
                }
            )







           
        }
    }

    // Computed property to check if all required fields are filled
    private var canProceed: Bool {
        !name.isEmpty && !gender.isEmpty && birthDate != nil
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

    // Computed property to determine border color
    private var borderColor: Color {
        if !text.isEmpty {
            return Color.blue // Blue when input is not empty
        } else if isFocused {
            return Color.blue // Blue when focused
        } else {
            return Color.gray // Default color
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Border
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 2) // Use the computed border color

            // Placeholder
            if isFocused || !text.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.customGray) // Use the custom color
                    )
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: isFocused || !text.isEmpty)
            }

            // TextField and Icon
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


struct FloatingInputWithAction: View {
    var placeholder: String
    var displayedText: String
    var action: () -> Void
    @Binding var hasPickedDate: Bool // Bind to parent's state
    @State private var isFocused: Bool = false

    private var borderColor: Color {
        if hasPickedDate {
            return Color.blue // Blue if a date is picked and saved
        } else {
            return Color.gray // Default border color
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 2)

            if isFocused || !displayedText.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.customGray)
                    )
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

                    if hasPickedDate {
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












