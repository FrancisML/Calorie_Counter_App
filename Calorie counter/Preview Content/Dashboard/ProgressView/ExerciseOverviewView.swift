import SwiftUI
import CoreData

struct ExerciseOverviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: DailyRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyRecord.date, ascending: true)]
    ) private var dailyRecords: FetchedResults<DailyRecord>
    
    @FetchRequest(
        fetchRequest: {
            let request = NSFetchRequest<UserProfile>(entityName: "UserProfile")
            request.sortDescriptors = []
            request.fetchLimit = 1
            return request
        }()
    ) private var userProfiles: FetchedResults<UserProfile>
    
    private var simulatedCurrentDate: Date {
        if let savedDate = UserDefaults.standard.object(forKey: "simulatedCurrentDate") as? Date {
            return Calendar.current.startOfDay(for: savedDate)
        }
        return Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    ZStack {
                        Image(favoriteActivity().imageName ?? "Running")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                    }
                    .frame(width: 100)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Text("Highest Activity Streak")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                                .frame(width: 150, alignment: .leading)
                            Text("\(highestActivityStreak()) days")
                                .font(.subheadline)
                                .foregroundColor(Styles.primaryText)
                                .frame(width: 80, alignment: .leading)
                        }
                        HStack(spacing: 10) {
                            Text("Current Streak")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                                .frame(width: 150, alignment: .leading)
                            Text("\(currentStreak()) days")
                                .font(.subheadline)
                                .foregroundColor(Styles.primaryText)
                                .frame(width: 80, alignment: .leading)
                        }
                        HStack(spacing: 10) {
                            Text("Days Worked Out")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                                .frame(width: 150, alignment: .leading)
                            Text(daysWorkedOut())
                                .font(.subheadline)
                                .foregroundColor(Styles.primaryText)
                                .frame(width: 80, alignment: .leading)
                        }
                        HStack(spacing: 10) {
                            Text("Total Exercise Time")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                                .frame(width: 150, alignment: .leading)
                            Text(totalExerciseTime())
                                .font(.subheadline)
                                .foregroundColor(Styles.primaryText)
                                .frame(width: 80, alignment: .leading)
                        }
                        HStack(spacing: 10) {
                            Text("Total Calories Burned")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                                .frame(width: 150, alignment: .leading)
                            Text("\(Int(totalCaloriesBurned()))")
                                .font(.subheadline)
                                .foregroundColor(Styles.primaryText)
                                .frame(width: 80, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 80)
                .padding(.bottom, 30)
                
                Divider()
                
                HStack(spacing: 10) {
                    VStack {
                        Image(favoriteActivity().imageName ?? "Running")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        Text(favoriteActivity().name ?? "Running")
                            .font(.caption)
                            .foregroundColor(Styles.primaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 90, height: 120)
                    .background(Styles.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Favorite Activity")
                            .font(.headline)
                            .foregroundColor(Styles.primaryText)
                        HStack(spacing: 10) {
                            Text("Percentage of Activity")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                            Text(String(format: "%.1f%%", favoriteActivityPercentage()))
                                .font(.subheadline)
                                .foregroundColor(Styles.primaryText)
                        }
                        HStack(spacing: 10) {
                            Text("Total Time Spent")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                            Text(totalFavoriteActivityTime())
                                .font(.subheadline)
                                .foregroundColor(Styles.primaryText)
                        }
                    }
                }
                .padding()
                
                Text("No workouts recorded yet")
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
                    .padding(.bottom, 5)
                    .opacity(dailyRecords.isEmpty ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                Text("Exercise Overview")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .background(Styles.secondaryBackground)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
            .zIndex(1)
        }
        .onAppear {
            printDailyRecordsDebugInfo()
        }
    }
    
    private func currentStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.date(byAdding: .day, value: -1, to: simulatedCurrentDate)! // Start from yesterday
        
        while true {
            if let record = dailyRecords.first(where: { Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: currentDate) }),
               let diaryEntries = record.diaryEntries as? Set<CoreDiaryEntry>,
               diaryEntries.contains(where: { $0.type == "Workout" }) {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    private func highestActivityStreak() -> Int {
        guard !dailyRecords.isEmpty else { return 0 }
        
        var maxStreak = 0
        var currentStreakCount = 0
        let sortedRecords = dailyRecords.sorted { $0.date ?? Date.distantFuture < $1.date ?? Date.distantFuture }
        var previousDate: Date? = nil
        
        for record in sortedRecords {
            guard let recordDate = record.date else { continue }
            let hasWorkout = (record.diaryEntries as? Set<CoreDiaryEntry>)?.contains(where: { $0.type == "Workout" }) == true
            
            if let prev = previousDate {
                let daysDifference = Calendar.current.dateComponents([.day], from: prev, to: recordDate).day ?? 0
                if daysDifference == 1 && hasWorkout {
                    currentStreakCount += 1
                } else if daysDifference > 1 || !hasWorkout {
                    currentStreakCount = hasWorkout ? 1 : 0
                }
            } else if hasWorkout {
                currentStreakCount = 1
            }
            
            maxStreak = max(maxStreak, currentStreakCount)
            previousDate = recordDate
        }
        
        return maxStreak
    }
    
    private func daysWorkedOut() -> String {
        guard let startDate = userProfiles.first?.startDate else {
            print("❌ No startDate found in UserProfile")
            return "0/0"
        }
        
        let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: simulatedCurrentDate).day ?? 0
        var workoutDays = 0
        
        for record in dailyRecords {
            guard let diaryEntries = record.diaryEntries as? Set<CoreDiaryEntry> else {
                print("⚠️ No diaryEntries for record on \(record.date?.description ?? "unknown date")")
                continue
            }
            if diaryEntries.contains(where: { $0.type == "Workout" }) {
                workoutDays += 1
                print("✅ Found workout on \(record.date?.description ?? "unknown date")")
            }
        }
        
        print("📊 Total workout days: \(workoutDays), Total days: \(totalDays)")
        return "\(workoutDays)/\(totalDays)"
    }
    
    private func totalExerciseTime() -> String {
        let totalMinutes = dailyRecords.compactMap { $0.workoutEntries as? Set<WorkoutEntry> }
            .flatMap { $0 }
            .reduce(0) { $0 + $1.duration }
        return formatTime(totalMinutes)
    }
    
    private func totalCaloriesBurned() -> Double {
        return dailyRecords.compactMap { $0.workoutEntries as? Set<WorkoutEntry> }
            .flatMap { $0 }
            .reduce(0) { $0 + $1.caloriesBurned }
    }
    
    private func favoriteActivity() -> (name: String?, imageName: String?) {
        let workoutDurations = dailyRecords.compactMap { $0.workoutEntries as? Set<WorkoutEntry> }
            .flatMap { $0 }
            .reduce(into: [String: Double]()) { result, entry in
                if let name = entry.name {
                    result[name, default: 0] += entry.duration
                }
            }
        
        if let (name, _) = workoutDurations.max(by: { $0.value < $1.value }) {
            let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.fetchLimit = 1
            do {
                if let activity = try viewContext.fetch(fetchRequest).first {
                    return (name, activity.imageName)
                }
            } catch {
                print("❌ Error fetching activity: \(error)")
            }
            return (name, "Running")
        }
        return ("Running", "Running")
    }
    
    private func favoriteActivityPercentage() -> Double {
        let totalMinutes = dailyRecords.compactMap { $0.workoutEntries as? Set<WorkoutEntry> }
            .flatMap { $0 }
            .reduce(0) { $0 + $1.duration }
        guard totalMinutes > 0 else { return 0 }
        
        let favoriteName = favoriteActivity().name
        let favoriteMinutes = dailyRecords.compactMap { $0.workoutEntries as? Set<WorkoutEntry> }
            .flatMap { $0 }
            .filter { $0.name == favoriteName }
            .reduce(0) { $0 + $1.duration }
        
        return (favoriteMinutes / totalMinutes) * 100
    }
    
    private func totalFavoriteActivityTime() -> String {
        let favoriteName = favoriteActivity().name
        let totalMinutes = dailyRecords.compactMap { $0.workoutEntries as? Set<WorkoutEntry> }
            .flatMap { $0 }
            .filter { $0.name == favoriteName }
            .reduce(0) { $0 + $1.duration }
        return formatTime(totalMinutes)
    }
    
    private func formatTime(_ minutes: Double) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            return String(format: "%.1f hrs", hours)
        }
        return String(format: "%.0f min", minutes)
    }
    
    private func printDailyRecordsDebugInfo() {
        print("🔍 Debug Info - Daily Records Count: \(dailyRecords.count)")
        for record in dailyRecords {
            let date = record.date?.description ?? "No date"
            let diaryEntries = (record.diaryEntries as? Set<CoreDiaryEntry>)?.map { "\($0.type ?? "No type") - \($0.detail ?? "No detail") (\($0.entryDescription ?? "No desc"))" } ?? ["No diary entries"]
            let workoutEntries = (record.workoutEntries as? Set<WorkoutEntry>)?.map { "\($0.name ?? "No name") - \(Int($0.duration)) min" } ?? ["No workout entries"]
            print("Record Date: \(date), Diary Entries: \(diaryEntries), Workout Entries: \(workoutEntries)")
        }
    }
}

struct ExerciseOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseOverviewView()
            .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
}
