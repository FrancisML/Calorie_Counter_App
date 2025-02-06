//
//  GoalSummaryView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/10/25.
//

//import SwiftUI
//import CoreData
//
//struct GoalSummaryView: View {
//    // Input Properties
//    let weight: Int
//        let goalWeight: Int
//        let targetDate: Date
//        let age: Int
//        let height: Int // Height in cm
//        let heightFt: Int32? // Add these optional properties
//        let heightIn: Int32?
//        let heightCm: Int32?
//        let gender: String
//        let activityLevel: Int
//        let useMetric: Bool
//        let goalMass: Double
//        let goalCalories: Int
//        let userBMR: Int
//
//        // State Properties
//        @State private var daysLeft: Int
//        @State private var calorieDeficit: Int
//        @State private var updatedTargetDate: Date
//        @State private var currentStep = 0
//        @State private var showDoctorWarning = false
//        @State private var warningAcknowledged = false
//        @State private var showChangeDate = false
//        @State private var navigateToDashboard = false
//    
//    @AppStorage("appState") private var appState: String = "setup"
//
//        // Initializer
//        init(
//            weight: Int,
//            goalWeight: Int,
//            targetDate: Date,
//            age: Int,
//            height: Int,
//            heightFt: Int32?, // Add these to the initializer
//            heightIn: Int32?,
//            heightCm: Int32?,
//            gender: String,
//            activityLevel: String,
//            useMetric: Bool,
//            goalMass: Double,
//            goalCalories: Int,
//            daysLeft: Int,
//            calorieDeficit: Int,
//            dailyLimit: Int32,
//            userBMR: Int
//        ) {
//            self.weight = weight
//            self.goalWeight = goalWeight
//            self.targetDate = targetDate
//            self.age = age
//            self.height = height
//            self.heightFt = heightFt // Initialize these
//            self.heightIn = heightIn
//            self.heightCm = heightCm
//            self.gender = gender
//            self.activityLevel = activityLevel
//            self.useMetric = useMetric
//            self.goalMass = goalMass
//            self.goalCalories = goalCalories
//            self.userBMR = userBMR
//            _daysLeft = State(initialValue: daysLeft)
//            _calorieDeficit = State(initialValue: calorieDeficit)
//            _updatedTargetDate = State(initialValue: targetDate)
//        }
//    
//
//    var body: some View {
//        VStack(spacing: 0) {
//            TabView(selection: $currentStep) {
//                // Screen 1: Goal Statement
//                VStack(spacing: 20) {
//                    Spacer()
//                    Image("trophy")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 150)
//                    Text("You want to lose \(displayGoalMass) by \(formattedDate).")
//                        .font(.title)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    Spacer()
//                }
//                .tag(0)
//
//                // Screen 2: Goal Calories
//                VStack(spacing: 20) {
//                    Spacer()
//                    Image("bolt")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 150)
//                    Text("\(displayGoalMass) equals \(goalCalories) calories!")
//                        .font(.title)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    Spacer()
//                }
//                .tag(1)
//
//                // Screen 3: Daily Calorie Deficit
//                VStack(spacing: 20) {
//                    Spacer()
//                    Image("calx")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 150)
//                    Text("To reach \(displayGoalMass) by \(formattedDate), you need a daily calorie deficit of \(calorieDeficit) calories.")
//                        .font(.title)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    Spacer()
//                }
//                .tag(2)
//
//                // Screen 4: BMR Explanation
//                VStack(spacing: 20) {
//                    Spacer()
//                    Image("BMR")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 150)
//                    Text("Let's Talk BMR")
//                        .font(.largeTitle)
//                        .padding()
//                    Text("Your Basal Metabolic Rate (BMR) represents the number of calories your body needs to maintain basic functions (like breathing, circulation, and cell production) every day.")
//                        .font(.title3)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    Spacer()
//                }
//                .tag(3)
//
//                // Screen 5: User's BMR
//                VStack(spacing: 20) {
//                    Spacer()
//                    Image("flame")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 150)
//                    Text("Your BMR is \(userBMR), but considering your activity level (\(activityLevel)), your Total Daily Energy Expenditure (TDEE) is \(tdee).")
//                        .font(.title)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    Spacer()
//                }
//                .tag(4)
//
//                // Screen 6: Save and Navigate
//                VStack(spacing: 20) {
//                    Spacer()
//                    Image("hungry")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 150)
//                    Text("To reach your goal, you need to limit your calorie intake to no more than \(dailyLimit) calories.")
//                        .font(.title)
//                        .multilineTextAlignment(.center)
//                        .padding()
//
//                    if dailyLimit < minimumCalories {
//                        if showDoctorWarning {
//                            // Display doctor warning and "Acknowledge" button
//                            Text("It would be wise to consult a doctor before attempting to eat at a high-calorie deficit.")
//                                .font(.headline)
//                                .foregroundColor(.red)
//                                .multilineTextAlignment(.center)
//                                .padding()
//                            
//                            Button("Acknowledge") {
//                                // Save user data and navigate to the dashboard
//                                saveUserData(
//                                    gender: gender,
//                                    heightFt: useMetric ? nil : Int32(height / 30),
//                                    heightIn: useMetric ? nil : Int32(height % 30),
//                                    heightCm: useMetric ? Int32(height) : nil,
//                                    weight: Int32(weight),
//                                    age: Int32(age),
//                                    goalWeight: Int32(goalWeight),
//                                    activityLevel: activityLevel,
//                                    targetDate: targetDate,
//                                    useMetric: useMetric,
//                                    goalMass: goalMass,
//                                    goalCalories: Int32(goalCalories),
//                                    daysLeft: Int32(daysLeft),
//                                    calorieDeficit: Int32(calorieDeficit),
//                                    userBMR: Int32(userBMR),
//                                    dailyLimit: Int32(dailyLimit),
//                                    
//                                    
//                                    context: PersistenceController.shared.context
//                                )
//                                appState = "dashboardSetup"
//                                navigateToDashboard = true
//                            }
//                            .frame(maxWidth: .infinity, minHeight: 50)
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                        } else {
//                            // Display the initial warning with "Change Date" and "Continue" buttons
//                            Text("Consuming less than \(minimumCalories) calories a day is dangerous to your health. Would you like to extend your time frame?")
//                                .font(.headline)
//                                .foregroundColor(.red)
//                                .multilineTextAlignment(.center)
//                                .padding()
//                            
//                            HStack(spacing: 20) {
//                                Button("Change Date") {
//                                    // Navigate to ChangeDateView
//                                    showChangeDate = true
//                                }
//                                .frame(maxWidth: .infinity, minHeight: 50)
//                                .background(Color.red)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//
//                                Button("Continue Anyway") {
//                                    // Display the doctor warning
//                                    showDoctorWarning = true
//                                }
//                                .frame(maxWidth: .infinity, minHeight: 50)
//                                .background(Color.orange)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                            }
//                            .padding(.horizontal)
//                        }
//                    } else {
//                        // If dailyLimit is safe, directly show "Start Counting" button
//                        Button("Start Counting") {
//                            // Save user data and navigate to the dashboard
//                            saveUserData(
//                                gender: gender,
//                                heightFt: useMetric ? nil : Int32(height / 30),
//                                heightIn: useMetric ? nil : Int32(height % 30),
//                                heightCm: useMetric ? Int32(height) : nil,
//                                weight: Int32(weight),
//                                age: Int32(age),
//                                goalWeight: Int32(goalWeight),
//                                activityLevel: activityLevel,
//                                targetDate: targetDate,
//                                useMetric: useMetric,
//                                goalMass: goalMass,
//                                goalCalories: Int32(goalCalories),
//                                daysLeft: Int32(daysLeft),
//                                calorieDeficit: Int32(calorieDeficit),
//                                userBMR: Int32(userBMR),
//                                dailyLimit: Int32(dailyLimit),
//                                
//                                context: PersistenceController.shared.context
//                            )
//                            appState = "dashboardSetup"
//                            navigateToDashboard = true
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 50)
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                    }
//
//                    Spacer()
//                }
//                .tag(5)
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//            .navigationBarBackButtonHidden(true)
//            .navigationDestination(isPresented: $navigateToDashboard) {
//                DashboardSetupView()
//            }
//            .sheet(isPresented: $showChangeDate, onDismiss: {
//                recalculateData()
//            }) {
//                ChangeDateView(targetDate: $updatedTargetDate) {
//                    recalculateData()
//                    showChangeDate = false
//                }
//            }
//        }
//    }
//
//    // MARK: - Computed Properties
//    var displayGoalMass: String {
//        useMetric ? "\(String(format: "%.2f", goalMass)) kg" : "\(String(format: "%.2f", goalMass / 0.453592)) lbs"
//    }
//
//    var tdee: Int {
//        let multiplier: Double
//        switch activityLevel {
//        case "Sedentary": multiplier = 1.2
//        case "Lightly Active": multiplier = 1.375
//        case "Moderately Active": multiplier = 1.55
//        case "Very Active": multiplier = 1.725
//        case "Extra Active": multiplier = 1.9
//        default: multiplier = 1.2
//        }
//        return Int(Double(userBMR) * multiplier)
//    }
//
//    var dailyLimit: Int {
//        tdee - calorieDeficit
//    }
//
//    var minimumCalories: Int {
//        gender == "Man" ? 1500 : 1200
//    }
//
//    var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: updatedTargetDate)
//    }
//
//    // MARK: - Functions
//    func recalculateData() {
//        let newDaysLeft = Calendar.current.dateComponents([.day], from: Date(), to: updatedTargetDate).day ?? 1
//        let newCalorieDeficit = goalCalories / max(newDaysLeft, 1)
//
//        daysLeft = newDaysLeft
//        calorieDeficit = newCalorieDeficit
//    }
//
//    func saveUserData(
//        gender: String,
//        heightFt: Int32?,
//        heightIn: Int32?,
//        heightCm: Int32?,
//        weight: Int32,
//        age: Int32,
//        goalWeight: Int32,
//        activityLevel: Int32,
//        targetDate: Date,
//        useMetric: Bool,
//        goalMass: Double,
//        goalCalories: Int32,
//        daysLeft: Int32,
//        calorieDeficit: Int32,
//        userBMR: Int32,
//        dailyLimit: Int32,
//        context: NSManagedObjectContext
//    ) {
//        let userProfile = UserProfile(context: context) // Updated to use `UserProfile`
//        userProfile.gender = gender
//        userProfile.heightFt = heightFt ?? 0
//        userProfile.heightIn = heightIn ?? 0
//        userProfile.heightCm = heightCm ?? 0
//        userProfile.currentWeight = weight
//        userProfile.age = age
//        userProfile.goalWeight = goalWeight
//        userProfile.activityLevel = activityLevel
//        userProfile.targetDate = targetDate
//        userProfile.useMetric = useMetric
//        userProfile.goalMass = goalMass
//        userProfile.goalCalories = goalCalories
//        userProfile.daysLeft = daysLeft
//        userProfile.dailyLimit = dailyLimit
//        userProfile.calorieDeficit = calorieDeficit
//        userProfile.userBMR = userBMR
//
//        do {
//            try context.save()
//            print("User profile saved successfully!")
//        } catch {
//            print("Failed to save user profile: \(error)")
//        }
//    }
//}
