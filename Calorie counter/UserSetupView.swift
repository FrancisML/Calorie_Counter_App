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
    @State private var showImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @State private var showActionSheet = false // To show the action sheet

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
                        .frame(maxWidth: 300)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(gender == "Man" ? Color.green : Color.clear, lineWidth: 3)
                                )
                        }

                        Button(action: { gender = "Woman" }) {
                            Text("Woman")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(gender == "Woman" ? Color.pink : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(gender == "Woman" ? Color.green : Color.clear, lineWidth: 3)
                                )
                        }
                    }



                    // Birth Date Selection
                    FloatingInputWithAction(
                        placeholder: " Birthday ",
                        displayedText: birthDateFormatted,
                        action: { showDatePicker = true },
                        hasPickedDate: $hasPickedDate
                    )

                    // Profile Picture Section
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
                            // Border Circle
                            Circle()
                                .stroke(profilePicture != nil ? Color.green : Color.gray, lineWidth: 3)
                                .frame(width: 100, height: 100)

                            // Background Circle
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)

                            // Profile Picture
                            if let image = profilePicture {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image("Empty man PP")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }

                            // Semi-Transparent Overlay
                            Circle()
                                .fill(Color.black.opacity(0.5)) // Semi-transparent grey overlay
                                .frame(width: 100, height: 100)

                            // Add Button with Larger Text
                            Button(action: {
                                showActionSheet = true // Show the action sheet
                            }) {
                                Text("Add")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(width: 100, height: 100)
                                    .background(Color.clear)
                            }
                            .actionSheet(isPresented: $showActionSheet) {
                                ActionSheet(
                                    title: Text("Select Profile Picture"),
                                    buttons: [
                                        .default(Text("Take a Photo")) {
                                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                                imagePickerSourceType = .camera
                                                showImagePicker = true // Open the image picker
                                            } else {
                                                
                                            }
                                        },
                                        .default(Text("Choose from Library")) {
                                            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                                                imagePickerSourceType = .photoLibrary
                                                showImagePicker = true // Open the image picker
                                            } else {
                                                
                                            }
                                        },
                                        .cancel()
                                    ]
                                )
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(selectedImage: $profilePicture, sourceType: imagePickerSourceType)
                            }

                        }
                    }

                }
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

                // Next Button
                HStack {
                    Spacer() // Push the button to the right

                    Button(action: { /* Proceed to next screen */ }) {
                        Text("Next")
                            .font(.title2) // Slightly larger text
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10) // Increased vertical padding to make the button 30% taller
                            .background(canProceed ? Color.blue : Color.gray)
                            .cornerRadius(25) // Slightly more rounded corners
                    }
                    .disabled(!canProceed)
                    .padding(.trailing, 20) // Add padding from the right edge
                    .padding(.bottom, 30) // Add padding from the bottom edge
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)


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
                                        temporaryDate = nil
                                        hasPickedDate = birthDate != nil
                                        showDatePicker = false
                                    }
                                    .frame(maxWidth: .infinity)

                                    Button("Save") {
                                        if let selectedDate = temporaryDate {
                                            birthDate = selectedDate
                                            hasPickedDate = true
                                        }
                                        showDatePicker = false
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.customGray)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                        }
                    }
                }
            )
        }
    }

    private var canProceed: Bool {
        !name.isEmpty && !gender.isEmpty && birthDate != nil
    }

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

struct FloatingInputWithAction: View {
    var placeholder: String
    var displayedText: String
    var action: () -> Void
    @Binding var hasPickedDate: Bool
    @State private var isFocused: Bool = false

    private var borderColor: Color {
        if hasPickedDate {
            return Color.blue
        } else {
            return Color.gray
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

func presentAlert(alert: UIAlertController) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first,
       let rootViewController = window.rootViewController {
        rootViewController.present(alert, animated: true)
    }
}













