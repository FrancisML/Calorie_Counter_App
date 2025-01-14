//
//  Calorie_counterApp.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/8/25.
//



import SwiftUI


@main
struct CalorieCounterApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView() // Always start with the SplashScreenView
        }
    }
}

struct SplashScreenView: View {
    @State private var isActive = false
    @AppStorage("appState") private var appState: String = "setup" // Tracks the app's current state

    var body: some View {
        VStack {
            if isActive {
                // Navigate dynamically based on appState
                if appState == "dashboard" {
                    DashboardView()
                } else if appState == "dashboardSetup" {
                    DashboardSetupView()
                } else {
                    UserSetupView()
                }
            } else {
                // Display the splash screen
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .onAppear {
                        // Simulate a delay for the splash screen
                        withAnimation(.easeOut(duration: 2)) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isActive = true
                            }
                        }
                    }
            }
        }
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var value: Int
    var width: CGFloat
    var height: CGFloat = 60
    var fontSize: CGFloat = 35
    var backgroundColor: Color = .gray
    var cornerRadius: CGFloat = 10
    var padding: CGFloat = 20

    var body: some View {
        TextField(placeholder, text: Binding(
            get: { value == 0 ? "" : String(value) },
            set: { newValue in
                if let intValue = Int(newValue), !newValue.isEmpty {
                    value = intValue
                } else {
                    value = 0
                }
            }
        ))
        .keyboardType(.numberPad)
        .textFieldStyle(PlainTextFieldStyle())
        .font(.system(size: fontSize))
        .multilineTextAlignment(.center)
        .padding(.horizontal, padding)
        .frame(width: width, height: height)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
    }
}

struct RoundedButtonStyle: ViewModifier {
    var backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .frame(minWidth: 120, minHeight: 50)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}




struct UserSetupView: View {
    @State private var currentStep = 0
    @State private var gender: String = ""
    @State private var heightFeet: Int = 0
    @State private var heightInches: Int = 0
    @State private var heightCm: Int = 0
    @State private var useMetric: Bool = false
    @State private var kgWeight: Int = 0
    @State private var lbWeight: Int = 0
    @State private var age: Int = 0
    @State private var goalKgWeight: Int = 0
    @State private var goalLbWeight: Int = 0
    @State private var targetDate: Date = Date()
    @State private var activityLevel: String = "Sedentary" // Default to the first option
    @FocusState private var isKeyboardFocused: Bool
    
    

    // MARK: - Computed Properties

    var goalMass: Double {
        let weight = useMetric ? Double(kgWeight) : Double(lbWeight) * 0.453592
        let goalWeight = useMetric ? Double(goalKgWeight) : Double(goalLbWeight) * 0.453592
        return weight - goalWeight
    }

    var goalCalories: Int {
        Int(goalMass * 7716)
    }

    var daysLeft: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day], from: currentDate, to: targetDate)
        return max(components.day ?? 1, 1) // Avoid division by zero
    }

    var calorieDeficit: Int {
        goalCalories / daysLeft
    }

    var userBMR: Int {
        let weightKg = useMetric ? Double(kgWeight) : Double(lbWeight) * 0.453592
        let heightCm = useMetric ? Double(heightCm) : Double(heightFeet) * 30.48 + Double(heightInches) * 2.54
        if gender == "Man" {
            return Int(10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5)
        } else {
            return Int(10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    // Gender Screen
                    VStack(spacing: 40) {
                        Spacer(minLength: 40)
                        Image("manorwoman")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Text("Are you a man or woman?")
                            .font(.title)
                        HStack(spacing: 20) {
                            Button(action: { gender = "Man" }) {
                                Text("Man")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(gender == "Man" ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: { gender = "Woman" }) {
                                Text("Woman")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(gender == "Woman" ? Color.pink : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .background(Color.black)
                    .tag(0)
                    
                    // Height Screen
                    VStack(spacing: 60) {
                        Spacer(minLength: 40)
                        Image("tape")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Text("How tall are you?")
                            .font(.title)
                        if useMetric {
                            CustomTextField(
                                placeholder: "cm",
                                value: $heightCm,
                                width: 150
                            )
                            .focused($isKeyboardFocused)
                        } else {
                            HStack(spacing: 40) {
                                CustomTextField(
                                    placeholder: "Feet",
                                    value: $heightFeet,
                                    width: 150
                                )
                                .focused($isKeyboardFocused)
                                CustomTextField(
                                    placeholder: "Inches",
                                    value: $heightInches,
                                    width: 150
                                )
                                .focused($isKeyboardFocused)
                            }
                        }
                        Button(action: { useMetric.toggle() }) {
                            Text(useMetric ? "Switch to Feet/Inches" : "Switch to Centimeters")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .background(Color.black)
                    .tag(1)
                    
                    // Age Screen
                    VStack(spacing: 60) {
                        Spacer(minLength: 40)
                        Image("age")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Text("How old are you?")
                            .font(.title)
                        CustomTextField(
                            placeholder: "Age",
                            value: $age,
                            width: 150
                        )
                        .focused($isKeyboardFocused)
                        Spacer()
                    }
                    .background(Color.black)
                    .tag(2)
                    
                    // Weight Screen
                    VStack(spacing: 60) {
                        Spacer(minLength: 40)
                        Image("scale")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Text("How much do you weigh?")
                            .font(.title)
                        if useMetric {
                            CustomTextField(
                                placeholder: "kgs",
                                value: $kgWeight,
                                width: 150
                            )
                            .focused($isKeyboardFocused)
                        } else {
                            CustomTextField(
                                placeholder: "lbs",
                                value: $lbWeight,
                                width: 150
                            )
                            .focused($isKeyboardFocused)
                        }
                        Button(action: { useMetric.toggle() }) {
                            Text(useMetric ? "Switch to Pounds (lbs)" : "Switch to Kilograms (kg)")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .background(Color.black)
                    .tag(3)
                    
                    // Goal Weight Screen
                    VStack(spacing: 60) {
                        Spacer(minLength: 40)
                        Image("target")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Text("What is your goal weight?")
                            .font(.title)
                        if useMetric {
                            CustomTextField(
                                placeholder: "kgs",
                                value: $goalKgWeight,
                                width: 150
                            )
                            .focused($isKeyboardFocused)
                        } else {
                            CustomTextField(
                                placeholder: "lbs",
                                value: $goalLbWeight,
                                width: 150
                            )
                            .focused($isKeyboardFocused)
                        }
                        Button(action: { useMetric.toggle() }) {
                            Text(useMetric ? "Switch to Pounds (lbs)" : "Switch to Kilograms (kg)")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .background(Color.black)
                    .tag(4)
                    VStack(spacing: 20) {
                                            Spacer(minLength: 40) // Adds top padding to the screen
                                            
                                            Image("calender")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 150)
                                            
                                            Text("When do you want to hit your goal weight?")
                                                .font(.title)
                                            
                                            DatePicker("Select a date", selection: $targetDate, displayedComponents: .date)
                                                .datePickerStyle(WheelDatePickerStyle())
                                                .labelsHidden()
                                            
                                            
                                            Spacer() // Pushes the buttons to the bottom
                                        }
                                        .tag(5)
                    
                    // Activity Level Screen
                    VStack(spacing: 20) {
                        Spacer(minLength: 40)
                        Image("bike")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Text("What is your activity level?")
                            .font(.title)
                        Picker("Activity Level", selection: $activityLevel) {
                            Text("Sedentary").tag("Sedentary")
                            Text("Lightly Active").tag("Lightly Active")
                            Text("Moderately Active").tag("Moderately Active")
                            Text("Very Active").tag("Very Active")
                            Text("Extra Active").tag("Extra Active")
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 150)
                        Spacer()
                    }
                    .background(Color.black)
                    .tag(6)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                isKeyboardFocused = false
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Navigation Buttons
                HStack(spacing: 50) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation { currentStep -= 1 }
                        }
                        .modifier(RoundedButtonStyle(backgroundColor: .gray))
                    }
                    if currentStep < 6 {
                        Button("Next") {
                            withAnimation { currentStep += 1 }
                        }
                        .modifier(RoundedButtonStyle(backgroundColor: .blue))
                    } else {
                        NavigationLink(
                            destination: SummaryView(
                                gender: gender,
                                height: useMetric ? "\(heightCm) cm" : "\(heightFeet)' \(heightInches)\"",
                                weight: useMetric ? kgWeight : lbWeight,
                                age: age,
                                goalWeight: useMetric ? goalKgWeight : goalLbWeight,
                                activityLevel: activityLevel,
                                targetDate: targetDate,
                                useMetric: useMetric,
                                goalMass: goalMass,
                                goalCalories: goalCalories,
                                daysLeft: daysLeft,
                                calorieDeficit: calorieDeficit,
                                userBMR: userBMR
                            )
                           
                        ) {
                            Text("Finish")
                                .modifier(RoundedButtonStyle(backgroundColor: .green))
                        }
                    }
                }
                .padding()
            }
        }
    }
}


            

