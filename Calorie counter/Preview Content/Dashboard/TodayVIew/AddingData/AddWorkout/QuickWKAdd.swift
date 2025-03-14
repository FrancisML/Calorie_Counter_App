import SwiftUI
import CoreData

struct QuickWKAddView: View {
    @Binding var diaryEntries: [DiaryEntry]
    var closeAction: () -> Void
    @Environment(\.managedObjectContext) private var viewContext

    @State private var workoutImageName: String = "DefaultWorkout"
    @State private var workoutName: String = "" // Variable name remains the same for consistency
    @State private var duration: String = ""
    @State private var calories: String = ""

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12 == 0 ? 12 : Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false

    @State private var showImagePickerPopup: Bool = false

    @FetchRequest(
        entity: ActivityModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityModel.name, ascending: true)]
    ) private var activities: FetchedResults<ActivityModel>

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                Image(workoutImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 3)
                    .onTapGesture {
                        showImagePickerPopup = true
                    }

                // Activity Name (changed from Workout Name)
                HStack(alignment: .center, spacing: 10) {
                    Text("Activity Name") // Updated label
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)
                    Spacer()
                    TextField("", text: $workoutName)
                        .frame(width: 100, height: 24)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 0)
                        .background(Styles.tertiaryBackground)
                        .cornerRadius(5)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Styles.primaryText)
                        .onTapGesture {
                            workoutName = ""
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20) // Increased padding to add space above the image

            Divider()

            // Duration
            HStack(alignment: .center, spacing: 10) {
                Text("Duration")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
                TextField("", text: $duration)
                    .frame(width: 50, height: 24)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 0)
                    .background(Styles.tertiaryBackground)
                    .cornerRadius(5)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Styles.primaryText)
                    .onTapGesture {
                        duration = ""
                    }
                Text("min")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
            }
            .padding(.horizontal)

            Divider()

            // Calories Burned
            HStack(alignment: .center, spacing: 10) {
                Text("Calories Burned")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
                TextField("", text: $calories)
                    .frame(width: 50, height: 24)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 0)
                    .background(Styles.tertiaryBackground)
                    .cornerRadius(5)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Styles.primaryText)
                    .onTapGesture {
                        calories = ""
                    }
                Text("cal")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
            }
            .padding(.horizontal)

            Divider()

            // Time
            HStack(alignment: .center, spacing: 10) {
                Text("Time")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
                Button(action: { showTimePicker = true }) {
                    Text(formattedTime)
                        .foregroundColor(Styles.primaryText)
                        .frame(width: 100, height: 24)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 0)
                        .background(Styles.tertiaryBackground)
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal)

            Spacer()

            bottomNavBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .onAppear {
            setCurrentTime()
        }
        .overlay(
            Group {
                if showTimePicker {
                    TimePicker(
                        selectedHour: $selectedHour,
                        selectedMinute: $selectedMinute,
                        selectedPeriod: $selectedPeriod,
                        isPresented: $showTimePicker
                    )
                }
                if showImagePickerPopup {
                    imagePickerPopup()
                }
            }
        )
    }

    private func setCurrentTime() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        selectedHour = currentHour % 12 == 0 ? 12 : currentHour % 12
        selectedMinute = Calendar.current.component(.minute, from: Date())
        selectedPeriod = currentHour >= 12 ? "PM" : "AM"
    }

    private var formattedTime: String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)"
    }

    private func imagePickerPopup() -> some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showImagePickerPopup = false
                    }
                
                VStack(spacing: 25) {
                    Text("Choose Workout Image")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)
                        .padding(.bottom, 5)
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                            ForEach(activities.filter { !$0.isCustom }, id: \.id) { activity in
                                Image(activity.imageName ?? "DefaultWorkout")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding(8)
                                    .background(Styles.primaryBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                                    .onTapGesture {
                                        workoutImageName = activity.imageName ?? "DefaultWorkout"
                                        showImagePickerPopup = false
                                    }
                                    .accessibilityLabel("Select \(activity.name ?? "unknown") image")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                    
                    Button("Cancel") {
                        showImagePickerPopup = false
                    }
                    .foregroundColor(.red)
                    .padding()
                }
                .padding()
                .background(Styles.primaryBackground)
                .shadow(radius: 5)
                .frame(maxWidth: 350)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }

    private func saveWorkoutToDiary() {
        let trimmedName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDuration = duration.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCalories = calories.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedDuration.isEmpty, !trimmedCalories.isEmpty else {
            print("⚠️ Missing required fields")
            return
        }

        let durationValue = Double(trimmedDuration) ?? 0
        let caloriesValue = Int(trimmedCalories) ?? 0

        let workoutEntry = WorkoutEntry(context: viewContext)
        workoutEntry.name = trimmedName
        workoutEntry.duration = durationValue
        workoutEntry.caloriesBurned = Double(caloriesValue)
        workoutEntry.time = formattedTime
        workoutEntry.imageName = workoutImageName

        let diaryEntry = CoreDiaryEntry(context: viewContext)
        diaryEntry.type = "Workout"
        diaryEntry.detail = trimmedName
        diaryEntry.entryDescription = formatDuration(trimmedDuration)
        diaryEntry.calories = Int32(caloriesValue)
        diaryEntry.time = formattedTime
        diaryEntry.iconName = workoutImageName

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
            print("✅ Workout saved to Core Data (both workoutEntries and diaryEntries)")

            let newDiaryEntry = DiaryEntry(
                time: formattedTime,
                iconName: workoutImageName,
                description: trimmedName,
                detail: formatDuration(trimmedDuration),
                calories: caloriesValue,
                type: "Workout",
                imageName: workoutImageName,
                imageData: nil,
                fats: 0,
                carbs: 0,
                protein: 0
            )
            diaryEntries.append(newDiaryEntry)
            print("✅ Added workout to diaryEntries array")
        } catch {
            print("❌ Error saving workout to Core Data: \(error.localizedDescription)")
            return
        }

        closeAction()
    }

    private func formatDuration(_ duration: String) -> String {
        if let minutes = Int(duration), minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes == 0 ? "\(hours) hr" : "\(hours) hr \(remainingMinutes) min"
        }
        return "\(duration) min"
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
                    saveWorkoutToDiary()
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .offset(y: -36)
        }
        .frame(height: 96)
    }
}

struct QuickWKAddView_Previews: PreviewProvider {
    static var previews: some View {
        QuickWKAddView(diaryEntries: .constant([]), closeAction: {})
            .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
}
