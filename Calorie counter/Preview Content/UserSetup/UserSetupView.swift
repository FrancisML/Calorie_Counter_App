//
//  UserSetupView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/21/25.
//

import SwiftUI

struct UserSetupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentStep: Int = 1
    @State private var showWelcomeSequence: Bool = false
    
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
    @State private var isWeightTargetDateGoalSelected: Bool = true
    @State private var isCustomCalorieGoalSelected: Bool = false
    @State private var temporaryBirthDate: Date = Date()
    
    // Personal Stats Variables
    @State private var weight: String = ""
    @State private var heightFeet: Int = 0
    @State private var heightCm: Int = 0
    @State private var heightInches: Int = 0
    @State private var useMetric: Bool = false
    @State private var activityLevel: Int = 0
    @State private var temporaryDate: Date? = nil
    @FocusState private var isKeyboardActive: Bool
    
    // New Variables from PersonalGoalsView
    @State private var customCals: String = ""
    @State private var goalWeight: String = ""
    @State private var goalDate: Date? = nil
    @State private var weekGoal: Double = 0.0
    
    @State private var isDarkMode: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - Validation for Personal Details
    private var isPersonalDetailsComplete: Bool {
        return !name.isEmpty && !gender.isEmpty && birthDate != nil
    }
    
    private var isPersonalStatsComplete: Bool {
        return !weight.isEmpty && hasEnteredHeight
    }
    
    private var hasEnteredHeight: Bool {
        if useMetric {
            return heightCm > 0
        } else {
            return heightFeet > 0 || heightInches > 0
        }
    }
    
    private var isNextButtonEnabled: Bool {
        switch currentStep {
        case 1:
            return isPersonalDetailsComplete
        case 2:
            return isPersonalStatsComplete
        default:
            return true
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // HEADER
                HStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                    Text("Calorie Counter")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                    
                    Spacer()
                }
                .padding()
                
                // ZStack for Swipe Transition
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
                    .offset(x: currentStep == 1 ? 0 : -geometry.size.width)
                    
                    PersonalStatsView(
                        weight: $weight,
                        heightFeet: $heightFeet,
                        heightInches: $heightInches,
                        heightCm: $heightCm,
                        useMetric: $useMetric,
                        goalWeight: $goalWeight,
                        activityLevel: $activityLevel,
                        weekGoal: $weekGoal
                    )
                    .offset(x: currentStep == 2 ? 0 : (currentStep > 2 ? -geometry.size.width : geometry.size.width))
                    
                    PersonalGoalsView(
                        useMetric: $useMetric,
                        goalWeight: $goalWeight,
                        goalDate: $goalDate,
                        customCals: $customCals,
                        weekGoal: $weekGoal,
                        isWeightTargetDateGoalSelected: $isWeightTargetDateGoalSelected,
                        isCustomCalorieGoalSelected: $isCustomCalorieGoalSelected
                    )
                    .offset(x: currentStep == 3 ? 0 : (currentStep < 3 ? geometry.size.width : -geometry.size.width))
                    
                    UserOverviewView(
                        name: name,
                        profilePicture: profilePicture,
                        gender: gender.isEmpty ? "" : gender, // Safely unwrap
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
                
                // BACK, DARK MODE TOGGLE, AND NEXT BUTTONS
                HStack {
                    if currentStep > 1 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                if currentStep > 1 {
                                    currentStep -= 1
                                }
                            }
                        }) {
                            Text("< Back")
                                .font(.title2)
                                .foregroundColor(Styles.primaryText)
                                .padding()
                                .frame(width: 120, height: 50)
                                .background(Styles.secondaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Styles.primaryText, lineWidth: 1)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        themeManager.isDarkMode.toggle()
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
                        if isNextButtonEnabled {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                if currentStep < 4 {
                                    currentStep += 1
                                } else {
                                    saveUserProfile()
                                    showWelcomeSequence = true
                                }
                            }
                        }
                    }) {
                        Text(currentStep < 4 ? "Next >" : "Finish")
                            .font(.title2)
                            .foregroundColor(isNextButtonEnabled ? Styles.primaryText : Styles.secondaryBackground)
                            .padding()
                            .frame(width: 120, height: 50)
                            .background(isNextButtonEnabled ? Styles.secondaryBackground : Color.gray.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(isNextButtonEnabled ? Styles.primaryText : Styles.secondaryBackground, lineWidth: 1)
                            )
                    }
                    .disabled(!isNextButtonEnabled)
                    .fullScreenCover(isPresented: $showWelcomeSequence) {
                        WelcomeSequenceView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Styles.primaryBackground)
            .focused($isKeyboardActive)
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
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
                            
                            CustomDatePicker(selectedDate: $temporaryBirthDate, minimumDate: nil)
                                .frame(height: 200)
                                .clipped()
                            
                            HStack {
                                Button("Cancel") {
                                    showDatePicker = false
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Styles.primaryText)
                                
                                Button("Save") {
                                    birthDate = temporaryBirthDate
                                    hasPickedDate = true
                                    showDatePicker = false
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 0).fill(Styles.secondaryBackground))
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        )
    }
    
    private func saveUserProfile() {
        let userProfile = UserProfile(context: viewContext)
        
        userProfile.name = name
        userProfile.gender = gender
        userProfile.birthdate = birthDate
        userProfile.profilePicture = profilePicture?.pngData()
        userProfile.startWeight = Double(weight) ?? 0.0
        userProfile.currentWeight = Double(weight) ?? 0.0
        userProfile.goalWeight = Double(goalWeight) ?? 0.0
        userProfile.targetDate = goalDate
        userProfile.weekGoal = weekGoal
        userProfile.customCals = Int32(customCals) ?? 0
        userProfile.useMetric = useMetric
        
        userProfile.heightCm = Int32(heightCm)
        userProfile.heightFt = Int32(heightFeet)
        userProfile.heightIn = Int32(heightInches)
        
        if let birthDate = userProfile.birthdate {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
            userProfile.age = Int32(ageComponents.year ?? 0)
        } else {
            userProfile.age = 0
        }
        
        userProfile.activityInt = Int32(activityLevel)
        
        userProfile.userBMR = calculateBMR(
            weight: userProfile.currentWeight,
            heightCm: userProfile.heightCm,
            heightFt: userProfile.heightFt,
            heightIn: userProfile.heightIn,
            age: userProfile.age,
            gender: userProfile.gender ?? "",
            activityInt: userProfile.activityInt,
            useMetric: userProfile.useMetric
        )
        
        let calorieFactor: Double = useMetric ? 7000.0 : 3500.0
        userProfile.dailyCalorieDif = Int32((calorieFactor * weekGoal) / 7)
        
        if userProfile.goalWeight > 0 {
            userProfile.weightDifference = abs(userProfile.currentWeight - userProfile.goalWeight)
        } else {
            userProfile.weightDifference = 0.0
        }
        
        if isWeightTargetDateGoalSelected {
            if weekGoal != 0 && (goalWeight.isEmpty || goalWeight == "0") {
                userProfile.goalId = 1
            } else if !goalWeight.isEmpty && goalDate == nil {
                userProfile.goalId = 2
            } else if !goalWeight.isEmpty && goalDate != nil {
                userProfile.goalId = 3
            } else if weekGoal == 0 {
                userProfile.goalId = 4
            }
        } else if isCustomCalorieGoalSelected && !customCals.isEmpty && customCals != "0" {
            userProfile.goalId = 5
        }
        
        userProfile.lastSavedDate = Date()
        
        // Set static goal text
        userProfile.goalText = generateGoalText(
            currentWeight: userProfile.currentWeight,
            goalWeight: userProfile.goalWeight,
            weekGoal: userProfile.weekGoal,
            goalDate: userProfile.targetDate,
            customCals: userProfile.customCals,
            useMetric: userProfile.useMetric
        )
        
        print("---- SAVING TO CORE DATA ----")
        print("Week Goal: \(weekGoal)")
        print("User BMR: \(userProfile.userBMR)")
        print("Goal ID: \(userProfile.goalId)")
        print("Use Metric: \(useMetric)")
        print("Daily Calorie Difference: \(userProfile.dailyCalorieDif)")
        print("Weight Difference: \(userProfile.weightDifference)")
        print("Goal Text: \(userProfile.goalText)")
        print("-----------------------------")
        
        do {
            try viewContext.save()
            print("✅ User Profile Saved Successfully!")
        } catch {
            print("❌ ERROR: Failed to save user profile: \(error.localizedDescription)")
        }
    }

    // Helper function to generate static goal text
    private func generateGoalText(currentWeight: Double, goalWeight: Double, weekGoal: Double, goalDate: Date?, customCals: Int32, useMetric: Bool) -> String {
        if customCals > 0 {
            return "Keep daily calories to \(customCals)"
        }
        
        let weightDifference = abs(goalWeight - currentWeight)
        let formattedDifference = useMetric ? "\(String(format: "%.1f", weightDifference)) kg" : "\(String(format: "%.1f", weightDifference)) lbs"
        
        if weekGoal == 0 {
            return "Maintain Current Weight"
        } else if goalWeight > 0 && goalDate == nil {
            let action = weekGoal < 0 ? "Lose" : "Gain"
            let formattedGoal = useMetric ? "\(abs(weekGoal)) kg" : "\(abs(weekGoal)) lbs"
            return "\(action) \(formattedDifference) by \(action.lowercased())ing \(formattedGoal) per week"
        } else if goalWeight > 0 && goalDate != nil {
            let action = weekGoal < 0 ? "Lose" : "Gain"
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let formattedDate = formatter.string(from: goalDate!)
            return "\(action) \(formattedDifference) by \(formattedDate)"
        } else {
            let action = weekGoal < 0 ? "Lose" : "Gain"
            let formattedGoal = useMetric ? "\(abs(weekGoal)) kg" : "\(abs(weekGoal)) lbs"
            return "\(action) \(formattedGoal) per week"
        }
    }
    
    private func calculateBMR(weight: Double, heightCm: Int32, heightFt: Int32, heightIn: Int32, age: Int32, gender: String, activityInt: Int32, useMetric: Bool) -> Int32 {
        var bmr: Double = 0.0
        
        let weightKg = useMetric ? weight : weight * 0.453592
        let heightCmDouble: Double
        if useMetric {
            heightCmDouble = Double(heightCm)
        } else {
            heightCmDouble = Double(heightFt * 12 + heightIn) * 2.54
        }
        
        if gender.lowercased() == "male" {
            bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCmDouble) - (5.677 * Double(age))
        } else {
            bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCmDouble) - (4.330 * Double(age))
        }
        
        let activityMultipliers: [Double] = [1.2, 1.375, 1.55, 1.725, 1.9]
        let activityIndex = min(max(Int(activityInt), 0), activityMultipliers.count - 1)
        bmr *= activityMultipliers[activityIndex]
        
        return Int32(bmr.rounded())
    }
}

struct UserSetupView_Previews: PreviewProvider {
    static var previews: some View {
        UserSetupView()
            .environmentObject(ThemeManager())
    }
}
