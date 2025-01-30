//
//  UserSetupView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/21/25.
//

import SwiftUI

struct UserSetupView: View {
    @State private var currentStep: Int = 1

    @State private var name: String = ""
    @State private var gender: String = ""
    @State private var birthDate: Date? = nil
    @State private var profilePicture: UIImage? = nil
    @State private var showDatePicker: Bool = false
    @State private var hasPickedDate: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @State private var showActionSheet: Bool = false
    @State private var weight: String = ""
    @State private var heightFeet: Int = 0
    @State private var heightCm: Int = 0
    @State private var heightInches: Int = 0
    @State private var useMetric: Bool = false
    @State private var goalWeight: String = ""
    @State private var activityLevel: Int = 0
    @State private var temporaryDate: Date? = nil  // TEMPORARY DATE FOR PICKER
    @FocusState private var isKeyboardActive: Bool // Added to track keyboard focus

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // HEADER (Always at the Top)
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

                // ZStack for Swipe Transition (Views Below Header)
                ZStack {
                    if currentStep == 1 {
                        PersonalDetailsView(
                            name: $name,
                            gender: $gender,
                            birthDate: $birthDate,
                            profilePicture: $profilePicture,
                            showDatePicker: $showDatePicker,
                            hasPickedDate: $hasPickedDate,
                            showImagePicker: $showImagePicker,
                            imagePickerSourceType: $imagePickerSourceType,
                            showActionSheet: $showActionSheet
                        )
                        .transition(.move(edge: .leading)) // Swiping Left Transition
                    }
                    
                    if currentStep == 2 {
                        PersonalStatsView(
                            weight: $weight,
                            heightFeet: $heightFeet,
                            heightInches: $heightInches, 
                            heightCm: $heightCm,
                            useMetric: $useMetric,
                            goalWeight: $goalWeight,
                            activityLevel: $activityLevel,
                            onBack: { withAnimation(.easeInOut(duration: 0.4)) { currentStep -= 1 } },
                            onNext: { withAnimation(.easeInOut(duration: 0.4)) { currentStep += 1 } }
                        )
                        .transition(.move(edge: .trailing)) // Swiping Right Transition
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.7)

                Spacer()

                // BACK AND NEXT BUTTONS
                HStack {
                    if currentStep > 1 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                currentStep -= 1
                            }
                        }) {
                            Text("< Back")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                    }

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep += 1
                        }
                    }) {
                        Text("Next >")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .focused($isKeyboardActive) // Ensures focus tracking
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isKeyboardActive = false
                        hideKeyboard()
                    }
                }
            }
        }
        // DATE PICKER OVERLAY (Works Like Before)
        .overlay(
            Group {
                if showDatePicker {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

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
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.customGray))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                    }
                }
            }
        )
    }
}









