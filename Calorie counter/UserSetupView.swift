//  UserSetupView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/21/25.
//

import SwiftUI

struct UserSetupView: View {
    @State private var currentStep: Int = 1

    // Personal Details Variables
    @State private var name: String = ""
    @State private var gender: String = ""
    @State private var birthDate: Date? = nil
    @State private var profilePicture: UIImage? = nil
    @State private var showDatePicker: Bool = false
    @State private var hasPickedDate: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @State private var showActionSheet: Bool = false

    // Personal Stats Variables
    @State private var weight: String = ""
    @State private var heightFeet: Int = 0
    @State private var heightCm: Int = 0
    @State private var heightInches: Int = 0
    @State private var useMetric: Bool = false
    @State private var activityLevel: Int = 0
    @State private var temporaryDate: Date? = nil  // TEMPORARY DATE FOR PICKER
    @FocusState private var isKeyboardActive: Bool // Added to track keyboard focus

    // New Variables from PersonalGoalsView
    @State private var customCals: String = ""
    @State private var goalWeight: String = ""
    @State private var goalDate: Date? = nil
    @State private var weekGoal: Double = 0.0
    
    @State private var isDarkMode: Bool = false
    @EnvironmentObject var themeManager: ThemeManager

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
                        .foregroundColor(Styles.primaryText)  // Apply primary text color
                    
                    Spacer()
                }
                .padding()

                // ZStack for Swipe Transition (Views Below Header)
                ZStack {
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
                     // Apply secondary background
                    .offset(x: currentStep == 1 ? 0 : -geometry.size.width)
                    
                    PersonalStatsView(
                        weight: $weight,
                        heightFeet: $heightFeet,
                        heightInches: $heightInches,
                        heightCm: $heightCm,
                        useMetric: $useMetric,
                        goalWeight: $goalWeight,
                        activityLevel: $activityLevel
                    )
                    
                    .offset(x: currentStep == 2 ? 0 : (currentStep > 2 ? -geometry.size.width : geometry.size.width))

                    PersonalGoalsView(
                        useMetric: $useMetric,
                        goalWeight: $goalWeight,
                        goalDate: $goalDate,
                        customCals: $customCals,
                        weekGoal: $weekGoal
                    )
                    
                    .offset(x: currentStep == 3 ? 0 : (currentStep < 3 ? geometry.size.width : -geometry.size.width))

                    UserOverviewView(
                        name: name,
                        profilePicture: profilePicture,
                        gender: gender,
                        birthDate: birthDate,
                        weight: weight,
                        heightFeet: heightFeet,
                        heightInches: heightInches,
                        heightCm: heightCm,
                        useMetric: useMetric,
                        activityLevel: activityLevel,
                        customCals: customCals,
                        goalWeight: goalWeight,
                        goalDate: goalDate,
                        weekGoal: weekGoal
                    )
                    
                    .offset(x: currentStep == 4 ? 0 : geometry.size.width)
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                .animation(.easeInOut(duration: 0.4), value: currentStep)

                Spacer()

                // BACK AND NEXT BUTTONS
                // BACK AND NEXT BUTTONS WITH TOGGLE IN MIDDLE
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

                    // Dark/Light Mode Toggle Button
                    Button(action: {
                        themeManager.isDarkMode.toggle()  // Toggle dark mode
                    }) {
                        Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            if currentStep < 4 {
                                currentStep += 1
                            }
                        }
                    }) {
                        Text(currentStep < 4 ? "Next >" : "Finish")
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
            .background(Styles.primaryBackground) // Apply primary background to the whole view
            .focused($isKeyboardActive) // Ensures focus tracking
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isKeyboardActive = false
                        hideKeyboard()
                    }
                    .foregroundColor(Styles.accent) // Accent color for toolbar button
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
                                .foregroundColor(Styles.primaryText)

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
                                .foregroundColor(Styles.warning)

                                Button("Save") {
                                    if let selectedDate = temporaryDate {
                                        birthDate = selectedDate
                                        hasPickedDate = true
                                    }
                                    showDatePicker = false
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Styles.success)
                            }
                            .padding(.horizontal)
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Styles.secondaryBackground))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Styles.primaryText, lineWidth: 2))
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                    }
                }
            }
        )
    }
}









