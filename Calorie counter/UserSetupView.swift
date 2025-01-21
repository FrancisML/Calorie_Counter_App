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
    @State private var birthDate: Date = Date()
    @State private var profilePicture: UIImage? = nil
    @State private var showDatePicker: Bool = false

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
                           TextField("Enter your name", text: $name)
                               .textFieldStyle(RoundedBorderTextFieldStyle())

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
                           Button(action: { showDatePicker = true }) {
                               HStack {
                                   Text(birthDateFormatted)
                                       .foregroundColor(.primary)

                                   Spacer()

                                   Text("Set Birthday")
                                       .foregroundColor(.blue)
                               }
                               .padding()
                               .background(Color.gray.opacity(0.2))
                               .cornerRadius(10)
                           }

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
                       .padding(.horizontal, 40) // Add horizontal padding to push inputs toward the center


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
                    DatePicker("Select Your Birthday", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()

                    HStack {
                        Button("Cancel") {
                            showDatePicker = false
                        }
                        .frame(maxWidth: .infinity)

                        Button("Save") {
                            showDatePicker = false
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
                .presentationDetents([.fraction(0.4)])
            }
        }
    }

    // Computed property to check if all required fields are filled
    private var canProceed: Bool {
        !name.isEmpty && !gender.isEmpty
    }

    // Computed property to format the birth date
    private var birthDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
}
