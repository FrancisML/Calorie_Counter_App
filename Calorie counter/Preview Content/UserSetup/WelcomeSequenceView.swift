import SwiftUI
import CoreData

struct WelcomeSequenceView: View {
    @State private var currentStep: Int = 0
    @State private var showText: Bool = false
    @Environment(\.dismiss) var dismiss  // Used to dismiss the view
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("appState") private var appState: String = "setup" // Store app state

    // Variables fetched from Core Data
    @State private var weekGoal: Double = 0.0
    @State private var userBMR: Int32 = 0
    @State private var dailyCalorieDif: Int32 = 0
    @State private var goalId: Int32 = 0
    @State private var useMetric: Bool = false
    @State private var weightDifference: Int32 = 0  // ✅ New variable
    @State private var goalDate: Date? = nil
    @State private var customCals: Int32 = 0  // ✅ Add customCals variable
    
    
    var body: some View {
        VStack {
            Spacer()

            if currentStep < messages.count {
                Text(messages[currentStep])
                    .font(.title)
                    .foregroundColor(Styles.primaryText)
                    .multilineTextAlignment(.center)  // Center-align the text
                    .padding(.horizontal, 40)  // Add margin on both sides
                    .opacity(showText ? 1 : 0)  // Controls fade-in/fade-out
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1), value: showText)
            }

            Spacer()

            if currentStep == messages.count - 1 {
                Button(action: {
                    appState = "dashboard" 
                    dismiss()  // Navigate away or present the main app
                }) {
                    Text("Start Counting")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)  // ✅ Change text color
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Styles.secondaryBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Styles.primaryText, lineWidth: 1)
                        )
                }
                .padding(.bottom, 40)  // ✅ Moves the button up
                .transition(.opacity)
                .animation(.easeInOut(duration: 1), value: showText)
            }

        }
        .onAppear {
            fetchUserProfile()
            setDailyCalorieGoal() // ✅ Set daily calorie goal only once
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea()
    }

    /// **Fetch user profile from Core Data and calculate necessary values**
    private func fetchUserProfile() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastSavedDate", ascending: false)]  // Ensure latest profile is fetched

        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                // ✅ Ensure Core Data object is refreshed
                viewContext.refresh(userProfile, mergeChanges: true)

                self.weekGoal = userProfile.weekGoal
                self.userBMR = userProfile.userBMR
                self.goalId = userProfile.goalId
                self.useMetric = userProfile.useMetric
                self.weightDifference = userProfile.weightDifference  // ✅ Fetch weight difference
                self.customCals = userProfile.customCals  // ✅ Fetch custom calorie goal

                let calorieFactor: Int32 = self.useMetric ? 7000 : 3500
                self.dailyCalorieDif = Int32((Double(calorieFactor) * self.weekGoal) / 7)
                userProfile.dailyCalorieDif = self.dailyCalorieDif

                try viewContext.save()  // Save updates

                print("---- FETCHED FROM CORE DATA ----")
                print("Week Goal: \(self.weekGoal)")
                print("User BMR: \(self.userBMR)")
                print("Goal ID: \(self.goalId)")
                print("Use Metric: \(self.useMetric)")
                print("Daily Calorie Difference: \(self.dailyCalorieDif)")
                print("Weight Difference: \(self.weightDifference)")
                print("Custom Calories: \(self.customCals)")  // ✅ Debugging
                print("-------------------------------")

                self.startMessageSequence()
            } else {
                print("⚠️ ERROR: No UserProfile found in CoreData")
            }
        } catch {
            print("⚠️ ERROR: Failed to fetch user profile: \(error.localizedDescription)")
        }
    }




    /// **Dynamically constructs the messages based on `goalId`**
    private var messages: [String] {
        guard (1...5).contains(goalId) else {
            return ["Goal scenario not handled yet."]
        }

        let goalType = weekGoal < 0 ? "lose" : "gain"
        let absWeekGoal = abs(weekGoal)
        let unit = useMetric ? "kg" : "lbs"
        _ = weekGoal < 0 ? "limit" : "reach"
        let progressWord = weekGoal < 0 ? "losing" : "gaining"

        var messageList: [String] = []

        if goalId == 1 {
            // Scenario 1: Lose/gain X per week
            let absCalorieDifference = abs(dailyCalorieDif)
            let adjustedCalories = weekGoal < 0 ? userBMR - absCalorieDifference : userBMR + absCalorieDifference

            messageList.append("Your goal is to \(goalType) \(absWeekGoal) \(unit) per week.")
            messageList.append("Based on your information, your BMR is \(userBMR).")

            let finalMessage = weekGoal < 0
                ? "To lose \(absWeekGoal) \(unit) a week, you need to limit your calorie intake to \(adjustedCalories) daily."
                : "To gain \(absWeekGoal) \(unit) a week, you need to reach an intake of \(adjustedCalories) calories daily."
            messageList.append(finalMessage)
          

        } else if goalId == 2 {
            // Scenario 2: Lose/gain a certain weight but no date
            let estimatedFinishDate = calculateFinishDate(weightDifference: Double(weightDifference), weekGoal: absWeekGoal)

            messageList.append("You want to \(goalType) \(weightDifference) \(unit) by \(progressWord) \(absWeekGoal) \(unit) per week.")
            messageList.append("Based on your information, your BMR is \(userBMR).")

            let absCalorieDifference = abs(dailyCalorieDif)
            let adjustedCalories = weekGoal < 0 ? userBMR - absCalorieDifference : userBMR + absCalorieDifference

            let finalMessage = weekGoal < 0
                ? "To lose \(absWeekGoal) \(unit) a week, you need to limit your calorie intake to \(adjustedCalories) daily."
                : "To gain \(absWeekGoal) \(unit) a week, you need to reach an intake of \(adjustedCalories) calories daily."
            messageList.append(finalMessage)

            messageList.append("By \(progressWord) \(absWeekGoal) \(unit) per week, you should \(goalType) \(weightDifference) \(unit) by \(estimatedFinishDate).")
            

        } else if goalId == 3 {
            // Scenario 3: Lose/gain a certain weight by a specific date
            let formattedDate = goalDate != nil ? formattedGoalDate : "Not Provided"
            let adjustedCaloriesByDate = calculateCaloriesByDate(weightDifference: Double(weightDifference), userBMR: userBMR, targetDate: goalDate)

            messageList.append("Your goal is to \(goalType) \(weightDifference) \(unit) by \(formattedDate).")
            messageList.append("Based on your information, your BMR is \(userBMR).")

            let finalMessage = weekGoal < 0
                ? "To lose \(absWeekGoal) \(unit) by \(formattedDate), you need to limit your calorie intake to \(adjustedCaloriesByDate) daily."
                : "To gain \(absWeekGoal) \(unit) by \(formattedDate), you need to reach an intake of \(adjustedCaloriesByDate) calories daily."
            messageList.append(finalMessage)
           

        } else if goalId == 4 {
            // Scenario 4: Maintain current weight
            messageList.append("Your goal is to Maintain your Current weight.")
            messageList.append("Based on your information, your BMR is \(userBMR).")
            messageList.append("In order to maintain your current weight, you need to keep your calorie intake at \(userBMR) calories daily.")

        } else if goalId == 5 {
            // Scenario 5: Custom Calorie Goal
            let calorieDifference = userBMR - customCals
            let calorieFactor = useMetric ? 7000 : 3500
            let calculatedWeight = abs(Double(calorieDifference * 7) / Double(calorieFactor))

            let weightChange = String(format: "%.1f", calculatedWeight)
            _ = calorieDifference < 0 ? "lose" : "gain"

            messageList.append("You want to keep your calorie intake to \(customCals) calories per day.")
            messageList.append("Based on your information, your BMR is \(userBMR).")
           
            let finalMessage = calorieDifference < 0
                ? "If you keep your calories to \(customCals) calories a day, you will gain \(weightChange) \(unit) per week."
                : "If you keep your calories to \(customCals) calories a day, you will lose \(weightChange) \(unit) per week."
            messageList.append(finalMessage)
           
        }

        return messageList
    }


    /// **Calculates the estimated finish date based on weight difference and weekly goal**
    /// **Calculates the estimated finish date based on weight difference and weekly goal**
    private func calculateFinishDate(weightDifference: Double, weekGoal: Double) -> String {
        guard weekGoal > 0 else { return "Unknown" } // Avoid division by zero

        let totalDaysNeeded = (weightDifference / weekGoal) * 7  // Convert weeks to days
        let calendar = Calendar.current

        if let estimatedDate = calendar.date(byAdding: .day, value: Int(ceil(totalDaysNeeded)), to: Date()) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: estimatedDate)
        }

        return "Unknown"
    }


    /// **Calculates the calorie intake needed to reach the goal weight by the target date**
    private func calculateCaloriesByDate(weightDifference: Double, userBMR: Int32, targetDate: Date?) -> Int32 {
        guard let targetDate = targetDate else { return userBMR }  // If no target date, return BMR

        let calorieFactor: Double = useMetric ? 7000 : 3500
        let daysUntilTarget = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0

        guard daysUntilTarget > 0 else { return userBMR } // Avoid division by zero

        let totalCalorieAdjustment = (weightDifference * calorieFactor) / Double(daysUntilTarget)
        let adjustedCalories = weekGoal < 0
            ? userBMR - Int32(totalCalorieAdjustment)  // Subtract when losing weight
            : userBMR + Int32(totalCalorieAdjustment)  // Add when gaining weight

        return adjustedCalories
    }


    /// **Handles the animation sequence for displaying messages**
    private func startMessageSequence() {
        for i in 0..<messages.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i * 3)) {
                withAnimation {
                    showText = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    currentStep = i
                    withAnimation {
                        showText = true
                    }
                }
            }
        }
    }

    /// **Formats Goal Date for Display**
    private var formattedGoalDate: String {
        guard let goalDate = goalDate else { return "Not Provided" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: goalDate)
    }
    private func updateDailyCalorieGoal(_ calories: Int32) {
        DispatchQueue.main.async {
            let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastSavedDate", ascending: false)]
            
            do {
                if let userProfile = try viewContext.fetch(fetchRequest).first {
                    userProfile.dailyCalorieGoal = calories
                    try viewContext.save()
                    
                    print("✅ DailyCalorieGoal Updated: \(calories)")
                }
            } catch {
                print("⚠️ ERROR: Failed to save dailyCalorieGoal to Core Data: \(error.localizedDescription)")
            }
        }
    }
    private func setDailyCalorieGoal() {
        var newCalorieGoal: Int32 = userBMR  // Default to BMR

        if goalId == 1 || goalId == 2 {
            let absCalorieDifference = abs(dailyCalorieDif)
            newCalorieGoal = weekGoal < 0 ? userBMR - absCalorieDifference : userBMR + absCalorieDifference
        } else if goalId == 3 {
            newCalorieGoal = calculateCaloriesByDate(weightDifference: Double(weightDifference), userBMR: userBMR, targetDate: goalDate)
        } else if goalId == 5 {
            newCalorieGoal = customCals
        }

        updateDailyCalorieGoal(newCalorieGoal)  // ✅ Now only updates once
    }

    
    
}

