
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

    @State private var duration: String = "20"
    @State private var userWeight: Double = 70.0
    @State private var isFavorite: Bool = false
    @State private var useMetric: Bool = false
    @State private var isCustom: Bool = false // New state to track if custom

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false

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

    private var caloriesBurned: Int {
        let metValue = fetchMETValue(for: activityName)
        let weightInKg = useMetric ? userWeight : userWeight * 0.453592
        let durationHours = (Double(duration) ?? 0) / 60.0
        let multiplier = selectedIntensity.metMultiplier
        let calories = metValue * weightInKg * durationHours * multiplier
        return max(0, Int(calories))
    }

    var body: some View {
        VStack(spacing: 20) {
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
                    
                    if isCustom {
                        Button(action: deleteCustomActivity) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Styles.tertiaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 2)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Divider()

            VStack {
                HStack(spacing: 0) {
                    ForEach([IntensityLevel.easy, .moderate, .hard, .veryHard], id: \.self) { level in
                        Button(action: { selectedIntensity = level }) {
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

                Text(selectedIntensity.description)
                    .font(.footnote)
                    .foregroundColor(Styles.primaryText.opacity(0.8))
                    .padding(.top, 5)
            }
            .padding(.horizontal)

            Divider()

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
            fetchFavoriteStatus()
            fetchCustomStatus() // New fetch for isCustom
        }
        .overlay(
            Group {
                if showTimePicker {
                    timePickerOverlay
                }
            }
        )
    }

    private func fetchUserWeight() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                userWeight = Double(userProfile.currentWeight)
                useMetric = userProfile.useMetric
            }
        } catch {
            print("⚠️ ERROR: Failed to fetch user weight: \(error.localizedDescription)")
        }
    }

    private func fetchMETValue(for activity: String) -> Double {
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activity)
        do {
            let activities = try viewContext.fetch(fetchRequest)
            return activities.first?.metValue ?? 1.0
        } catch {
            print("⚠️ ERROR: Failed to fetch MET value: \(error.localizedDescription)")
            return 1.0
        }
    }

    private func fetchFavoriteStatus() {
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activityName)
        do {
            if let activity = try viewContext.fetch(fetchRequest).first {
                isFavorite = activity.isFavorite
            }
        } catch {
            print("⚠️ ERROR: Failed to fetch favorite status: \(error.localizedDescription)")
        }
    }
    
    private func fetchCustomStatus() {
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activityName)
        do {
            if let activity = try viewContext.fetch(fetchRequest).first {
                isCustom = activity.isCustom
            }
        } catch {
            print("⚠️ ERROR: Failed to fetch custom status: \(error.localizedDescription)")
        }
    }

    private var formattedTime: String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)"
    }

    private func bottomNavBar() -> some View {
        ZStack {
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack {
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
        isFavorite.toggle()
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activityName)
        do {
            if let activity = try viewContext.fetch(fetchRequest).first {
                activity.isFavorite = isFavorite
                try viewContext.save()
                print("✅ Favorite status updated for \(activityName): \(isFavorite)")
            }
        } catch {
            print("❌ ERROR: Failed to update favorite status: \(error.localizedDescription)")
        }
    }

    private func deleteCustomActivity() {
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", activityName)
        do {
            if let activity = try viewContext.fetch(fetchRequest).first, activity.isCustom {
                viewContext.delete(activity)
                try viewContext.save()
                print("✅ Deleted custom activity: \(activityName)")
                closeAction() // Close view after deletion
            }
        } catch {
            print("❌ ERROR: Failed to delete custom activity: \(error.localizedDescription)")
        }
    }

    private func saveActivityToDiary() {
        guard let durationValue = Double(duration), durationValue > 0 else {
            print("⚠️ ERROR: Invalid duration entered")
            return
        }

        let caloriesValue = caloriesBurned
        guard caloriesValue > 0 else {
            print("⚠️ ERROR: Calories burned calculation failed")
            return
        }

        let workoutEntry = WorkoutEntry(context: viewContext)
        workoutEntry.name = activityName
        workoutEntry.duration = durationValue
        workoutEntry.caloriesBurned = Double(caloriesValue)
        workoutEntry.time = formattedTime
        workoutEntry.imageName = activityImage

        let diaryEntry = CoreDiaryEntry(context: viewContext)
        diaryEntry.type = "Workout"
        diaryEntry.detail = activityName
        diaryEntry.entryDescription = formatDuration(durationValue)
        diaryEntry.calories = Int32(caloriesValue)
        diaryEntry.time = formattedTime
        diaryEntry.iconName = activityImage

        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: Date()) as NSDate)
        fetchRequest.fetchLimit = 1

        do {
            if let dailyRecord = try viewContext.fetch(fetchRequest).first {
                dailyRecord.addToWorkoutEntries(workoutEntry)
                dailyRecord.addToDiaryEntries(diaryEntry)
            } else {
                let newDailyRecord = DailyRecord(context: viewContext)
                newDailyRecord.date = Calendar.current.startOfDay(for: Date())
                newDailyRecord.calorieGoal = 2000
                newDailyRecord.calorieIntake = 0
                newDailyRecord.waterGoal = 8
                newDailyRecord.waterIntake = 0
                newDailyRecord.waterUnit = "cups"
                newDailyRecord.passFail = false
                newDailyRecord.weighIn = 0
                newDailyRecord.addToWorkoutEntries(workoutEntry)
                newDailyRecord.addToDiaryEntries(diaryEntry)
            }
            try viewContext.save()

            let activityFetch: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
            activityFetch.predicate = NSPredicate(format: "name == %@", activityName)
            if let activity = try viewContext.fetch(activityFetch).first {
                activity.lastUsed = Date()
                try viewContext.save()
            }
            print("✅ Workout saved to Core Data successfully")

            let newDiaryEntry = DiaryEntry(
                time: formattedTime,
                iconName: activityImage,
                description: activityName,
                detail: formatDuration(durationValue),
                calories: caloriesValue,
                type: "Workout",
                imageName: activityImage,
                imageData: nil,
                fats: 0,
                carbs: 0,
                protein: 0
            )
            diaryEntries.append(newDiaryEntry)
            print("✅ Added workout to diaryEntries")
        } catch {
            print("❌ ERROR: Failed to save workout: \(error.localizedDescription)")
            return
        }

        closeAction()
    }

    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration)
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes == 0 ? "\(hours) hr" : "\(hours) hr \(remainingMinutes) min"
        }
        return "\(minutes) min"
    }

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
