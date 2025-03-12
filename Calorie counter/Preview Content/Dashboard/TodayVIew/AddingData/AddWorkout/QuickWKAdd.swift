import SwiftUI
import CoreData

struct QuickWKAddView: View {
    @Binding var diaryEntries: [DiaryEntry]
    var closeAction: () -> Void
    @Environment(\.managedObjectContext) private var viewContext

    @State private var workoutImage: UIImage? = UIImage(named: "DefaultWorkout")
    @State private var workoutName: String = ""
    @State private var duration: String = ""
    @State private var calories: String = ""

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false

    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(workoutImage != UIImage(named: "DefaultWorkout") ? Color.green : Styles.primaryText, lineWidth: 3)
                        .frame(width: 100, height: 100)

                    Image(uiImage: workoutImage ?? UIImage(named: "DefaultWorkout")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Button(action: { showActionSheet = true }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 100)
                    }
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("Select Image"),
                            buttons: [
                                .default(Text("Take a Photo")) {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        imagePickerSourceType = .camera
                                        showImagePicker = true
                                    }
                                },
                                .default(Text("Choose from Library")) {
                                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                                        imagePickerSourceType = .photoLibrary
                                        showImagePicker = true
                                    }
                                },
                                .destructive(Text("Remove Image")) {
                                    workoutImage = UIImage(named: "DefaultWorkout")
                                },
                                .cancel()
                            ]
                        )
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $workoutImage, sourceType: imagePickerSourceType)
                    }
                }

                FloatingTextField(placeholder: " Workout Name ", text: $workoutName)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            VStack(spacing: 15) {
                FloatingTextField(placeholder: " Duration (mins) ", text: $duration)
                    .keyboardType(.numberPad)

                FloatingTextField(placeholder: " Calories Burned ", text: $calories)
                    .keyboardType(.numberPad)
                    .onReceive(calories.publisher.collect()) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let trimmed = String(filtered.prefix(4))
                        if calories != trimmed { calories = trimmed }
                    }

                FloatingInputWithAction(
                    placeholder: " Time ",
                    displayedText: formattedTime,
                    action: { showTimePicker = true },
                    hasPickedValue: .constant(true)
                )
            }
            .padding(.horizontal)

            Spacer()

            bottomNavBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
        .onAppear {
            setCurrentTime()
        }
        .overlay(
            Group {
                if showTimePicker {
                    timePickerOverlay
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
        workoutEntry.imageData = workoutImage?.jpegData(compressionQuality: 0.8)

        let diaryEntry = CoreDiaryEntry(context: viewContext)
        diaryEntry.type = "Workout"
        diaryEntry.detail = trimmedName // Activity name
        diaryEntry.entryDescription = formatDuration(trimmedDuration) // Duration string
        diaryEntry.calories = Int32(caloriesValue)
        diaryEntry.time = formattedTime
        diaryEntry.imageData = workoutImage?.jpegData(compressionQuality: 0.8)

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
                iconName: "DefaultWorkout",
                description: trimmedName,
                detail: formatDuration(trimmedDuration),
                calories: caloriesValue,
                type: "Workout",
                imageName: nil,
                imageData: workoutImage?.jpegData(compressionQuality: 0.8),
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

    private var timePickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Select Time")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                FloatingInputWithAction(
                    placeholder: " Time ",
                    displayedText: formattedTime,
                    action: { showTimePicker = true },
                    hasPickedValue: .constant(true)
                )
                .padding()

                Button("Close") {
                    showTimePicker = false
                }
                .padding()
                .foregroundColor(.blue)
            }
            .padding()
            .background(Styles.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 5)
        }
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
