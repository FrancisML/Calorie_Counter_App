//
//  ActivityStatsView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/20/25.
//

//
//  ActivityStatsView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/20/25.
//

//
//  ActivityStatsView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/20/25.
//

import SwiftUI
import CoreData

struct ActivityStatsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var activityName: String
    var activityImage: String
    var closeAction: () -> Void
    @Binding var diaryEntries: [DiaryEntry]

    @State private var duration: String = "20" // ✅ Default to 20 mins
    @State private var userWeight: Double = 70.0 // ✅ Default to 70kg, fetched later
    @State private var isFavorite: Bool = false
    @State private var useMetric: Bool = false // ✅ Tracks if user weight is in kg or lbs

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false

    // ✅ MET Intensity Selection
    @State private var selectedIntensity: IntensityLevel = .moderate

    enum IntensityLevel: String {
        case easy = "Easy"
        case moderate = "Moderate"
        case hard = "Hard"
        case veryHard = "Very Hard"

        var color: Color {
            switch self {
            case .easy: return .green.opacity(0.6)
            case .moderate: return .yellow.opacity(0.6)
            case .hard: return .orange.opacity(0.7)
            case .veryHard: return .red.opacity(0.7)
            }
        }

        var metMultiplier: Double {
            switch self {
            case .easy: return 0.75
            case .moderate: return 1.0
            case .hard: return 1.25
            case .veryHard: return 1.5
            }
        }

        var description: String {
            switch self {
            case .easy: return "A relaxed activity pace."
            case .moderate: return "A steady effort level."
            case .hard: return "An intense and challenging pace."
            case .veryHard: return "Extremely strenuous effort."
            }
        }
    }

    // ✅ COMPUTED PROPERTY: CALCULATE CALORIES BURNED
    private var caloriesBurned: Int {
        let metValue = fetchMETValue(for: activityName) // ✅ Get MET from activity
        let weightInKg = useMetric ? userWeight : userWeight * 0.453592 // ✅ Convert if needed
        let durationHours = (Double(duration) ?? 0) / 60.0 // ✅ Convert minutes to hours
        let multiplier = selectedIntensity.metMultiplier // ✅ Intensity multiplier

        let calories = metValue * weightInKg * durationHours * multiplier
        return max(0, Int(calories)) // ✅ Ensure no negative values
    }

    var body: some View {
        VStack(spacing: 20) {
            // ✅ TOP HSTACK: IMAGE + ACTIVITY NAME + FAVORITE BUTTON
            HStack(spacing: 15) {
                Image(activityImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 3)

                VStack(alignment: .leading, spacing: 5) {
                    Text(activityName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)

                    Button(action: toggleFavorite) {
                        HStack {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)

                            Text("Favorite")
                                .foregroundColor(Styles.primaryText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Styles.tertiaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Divider()

            // ✅ INTENSITY SELECTION BAR
            VStack {
                HStack(spacing: 0) {
                    ForEach([IntensityLevel.easy, .moderate, .hard, .veryHard], id: \.self) { level in
                        Button(action: {
                            selectedIntensity = level
                        }) {
                            Text(level.rawValue)
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedIntensity == level ? level.color : Styles.tertiaryBackground)
                                .foregroundColor(selectedIntensity == level ? .white : Styles.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .frame(width: 1)
                                .foregroundColor(.gray.opacity(0.3)),
                            alignment: .trailing
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)

                // ✅ INTENSITY DESCRIPTION
                Text(selectedIntensity.description)
                    .font(.footnote)
                    .foregroundColor(Styles.primaryText.opacity(0.8))
                    .padding(.top, 5)
            }
            .padding(.horizontal)

            Divider()

            // ✅ CALORIES BURNED DISPLAY
            HStack {
                Text("Calories Burned")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                Spacer()

                Text("\(caloriesBurned)")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
            }
            .padding(.horizontal)

            Divider()

            // ✅ DURATION INPUT
            HStack {
                Text("Duration")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                Spacer()

                TextField("", text: $duration)
                    .frame(width: 50)
                    .padding(5)
                    .background(Styles.tertiaryBackground)
                    .cornerRadius(5)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)

                Text("min")
                    .foregroundColor(Styles.primaryText)
            }
            .padding(.horizontal)

            Divider()

            // ✅ BASED ON YOUR WEIGHT TEXT
            Text("Based on your weight of \(Int(userWeight)) \(useMetric ? "kg" : "lbs")")
                .font(.footnote)
                .foregroundColor(Styles.primaryText.opacity(0.8))
                .padding(.top, 5)

            Spacer()
            bottomNavBar()
        }
        .frame(maxWidth: .infinity)
        .background(Styles.secondaryBackground)
        .onAppear {
            fetchUserWeight()
        }
    }
    

    // ✅ FETCH USER WEIGHT & UNIT
    private func fetchUserWeight() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()

        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                userWeight = Double(userProfile.currentWeight)
                useMetric = userProfile.useMetric // ✅ Determine if weight is in kg or lbs
            }
        } catch {
            print("⚠️ ERROR: Failed to fetch user weight: \(error.localizedDescription)")
        }
    }

    // ✅ FETCH MET VALUE FOR ACTIVITY
    private func fetchMETValue(for activity: String) -> Double {
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activity)

        do {
            let activities = try viewContext.fetch(fetchRequest)
            return activities.first?.metValue ?? 1.0 // ✅ Default to 1 MET if not found
        } catch {
            print("⚠️ ERROR: Failed to fetch MET value: \(error.localizedDescription)")
            return 1.0
        }
    }


    // ✅ FORMATTED TIME
    private var formattedTime: String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)"
    }

    // ✅ BOTTOM NAVIGATION BAR (Directly Closes WorkoutView)
    private func bottomNavBar() -> some View {
        ZStack {
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack {
                // 🔴 X Button (Closes WorkoutView Directly)
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: "xmark")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    closeAction()
                }

                Spacer().frame(width: 100)

                // ➕ "+" Button (Saves & Closes WorkoutView)
                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(Styles.secondaryBackground)
                }
                .onTapGesture {
                    saveActivityToDiary()
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .offset(y: -36)
        }
        .frame(height: 96)
    }
    private func toggleFavorite() {
        isFavorite.toggle() // ✅ Toggle the state locally

        // ✅ Fetch and update Core Data
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activityName)

        do {
            if let activity = try viewContext.fetch(fetchRequest).first {
                activity.isFavorite = isFavorite // ✅ Update Core Data property
                
                try viewContext.save() // ✅ Save immediately
                print("✅ Favorite status updated for \(activityName): \(isFavorite)")
            }
        } catch {
            print("❌ ERROR: Failed to update favorite status: \(error.localizedDescription)")
        }
    }


    // ✅ SAVE ACTIVITY TO DIARY
    private func saveActivityToDiary() {
        guard let durationValue = Int(duration), durationValue > 0 else {
            print("⚠️ ERROR: Invalid duration entered")
            return
        }

        let caloriesValue = caloriesBurned // ✅ Uses computed property

        guard caloriesValue > 0 else {
            print("⚠️ ERROR: Calories burned calculation failed")
            return
        }

        let durationText = "\(durationValue) min"

        let newEntry = DiaryEntry(
            time: formattedTime,
            iconName: activityImage,
            description: activityName,
            detail: durationText,
            calories: -caloriesValue, // ✅ Calories are always negative for workouts
            type: "Workout",
            imageName: activityImage,
            imageData: nil
        )

        DispatchQueue.main.async {
            diaryEntries.append(newEntry)
        }

        // ✅ Update `lastUsed` for this activity in Core Data
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activityName)

        do {
            if let activity = try viewContext.fetch(fetchRequest).first {
                activity.lastUsed = Date() // ✅ Updates last used timestamp

                try viewContext.save()
                print("✅ Activity saved & lastUsed updated: \(activityName)")
            }
        } catch {
            print("❌ ERROR: Failed to update lastUsed date: \(error.localizedDescription)")
        }

        closeAction() // ✅ Closes view after saving
    }


    // ✅ TIME PICKER OVERLAY
    private var timePickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Select Time")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                timePicker
                    .padding(.horizontal)

                HStack {
                    Button("Cancel") {
                        showTimePicker = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Styles.primaryText)

                    Button("Save") {
                        showTimePicker = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .padding(20)
            .background(Styles.secondaryBackground)
            .shadow(radius: 10)
        }
    }

    // ✅ TIME PICKER
    private var timePicker: some View {
        HStack {
            Picker("Hour", selection: $selectedHour) {
                ForEach(1...12, id: \.self) { hour in
                    Text("\(hour)").tag(hour)
                        .foregroundColor(Styles.primaryText)
                }
            }

            Picker("Minutes", selection: $selectedMinute) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(String(format: "%02d", minute))").tag(minute)
                        .foregroundColor(Styles.primaryText)
                }
            }

            Picker("AM/PM", selection: $selectedPeriod) {
                Text("AM").tag("AM").foregroundColor(Styles.primaryText)
                Text("PM").tag("PM").foregroundColor(Styles.primaryText)
            }
        }
    }
}
