//
//  ProgressView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/9/25.
//

import SwiftUI
import CoreData
import PhotosUI
import Charts

struct ProgressView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var userProfile: UserProfile?
    @State private var progressPictures: [ProgressPicture] = []
    @State private var dailyRecords: [DailyRecord] = []
    @State private var bodyMeasurements: [BodyMeasurement] = []
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var isExpanded = false
    @State private var showBodyMeasurementView = false
    
    // Progress Picture Computed Properties
    private var startPicture: UIImage? {
        if let startData = userProfile?.startPicture, let image = UIImage(data: startData) {
            return image
        }
        return userProfile?.gender == "Male" ? UIImage(named: "Empty man PP") : UIImage(named: "Empty woman PP")
    }
    
    private var latestPicture: UIImage? {
        if let latest = progressPictures.last, let imageData = latest.imageData, let image = UIImage(data: imageData) {
            return image
        }
        return progressPictures.isEmpty ? (userProfile?.gender == "Male" ? UIImage(named: "Empty man PP") : UIImage(named: "Empty woman PP")) : startPicture
    }
    
    private var startDateOverlay: String {
        userProfile?.startDate != nil ? DateFormatter.mediumDate.string(from: userProfile!.startDate!) : "N/A"
    }
    
    private var startWeightOverlay: String {
        userProfile?.startWeight ?? 0 > 0 ? "\(userProfile!.startWeight) \(userProfile!.useMetric ? "kg" : "lbs")" : "N/A"
    }
    
    private var latestDateOverlay: String {
        progressPictures.last?.date != nil ? DateFormatter.mediumDate.string(from: progressPictures.last!.date!) : "N/A"
    }
    
    private var latestWeightOverlay: String {
        progressPictures.last?.weight ?? 0 > 0 ? "\(progressPictures.last!.weight) \(userProfile?.useMetric ?? false ? "kg" : "lbs")" : "N/A"
    }
    
    // Weight Section Computed Properties
    private var goalMessage: String {
        guard let userProfile = userProfile else { return "No Goal Set" }
        return generateGoalMessage(userProfile: userProfile)
    }
    
    private var weightData: [(date: Date, weight: Double)] {
        var data = [(date: userProfile?.startDate ?? Date(), weight: userProfile?.startWeight ?? 0.0)]
        data.append(contentsOf: dailyRecords.compactMap { record in
            guard let date = record.date else { return nil }
            let weight = record.weighIn > 0 ? record.weighIn : (userProfile?.currentWeight ?? 0.0)
            return (date: date, weight: weight)
        }.sorted { $0.date < $1.date })
        return data
    }
    
    private var weightProgress: Float {
        guard let userProfile = userProfile, userProfile.startWeight > 0, userProfile.goalWeight > 0 else { return 0.0 }
        let start = Float(userProfile.startWeight)
        let current = Float(userProfile.currentWeight)
        let goal = Float(userProfile.goalWeight)
        if goal == start { return 1.0 }
        let totalChange = abs(goal - start)
        let currentChange = abs(current - start)
        return min(max(currentChange / totalChange, 0.0), 1.0)
    }
    
    private var weightDifference: (value: Double, color: Color) {
        guard let userProfile = userProfile, userProfile.startWeight > 0, userProfile.currentWeight > 0 else {
            return (0.0, .gray)
        }
        let difference = userProfile.currentWeight - userProfile.startWeight
        let isLoseGoal = userProfile.weekGoal < 0 || userProfile.goalWeight < userProfile.startWeight
        let color: Color = difference == 0 ? .gray : (isLoseGoal ? (difference > 0 ? .red : .green) : (difference > 0 ? .green : .red))
        return (difference, color)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) { // Sections touch with no spacing
                headerView
                progressPictureSection
                weightSection
                bodyMeasurementSection
                exerciseOverviewSection
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea(edges: .top)
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { newPhoto in saveProgressPicture(from: newPhoto) }
        .onAppear {
            fetchUserProfile()
            fetchDailyRecords()
            fetchBodyMeasurements()
        }
        .sheet(isPresented: $showBodyMeasurementView) {
            BodyMeasurementView(userProfile: userProfile)
                .environment(\.managedObjectContext, viewContext)
                .onDisappear { fetchBodyMeasurements() }
        }
    }
    
    private var headerView: some View {
        VStack {
            Spacer().frame(height: 50)
            Text("Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Styles.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private var progressPictureSection: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image(uiImage: startPicture ?? UIImage(named: "Empty man PP")!)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipped()
                        .overlay(
                            VStack {
                                Spacer()
                                Text(startDateOverlay)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.black.opacity(0.6))
                                Text(startWeightOverlay)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.black.opacity(0.6))
                            }
                            .padding(.bottom, 10),
                            alignment: .bottom
                        )
                    Image(uiImage: latestPicture ?? UIImage(named: "Empty man PP")!)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipped()
                        .overlay(
                            VStack {
                                Spacer()
                                Text(latestDateOverlay)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.black.opacity(0.6))
                                Text(latestWeightOverlay)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.black.opacity(0.6))
                            }
                            .padding(.bottom, 10),
                            alignment: .bottom
                        )
                }
                .frame(height: 200)
                .clipped()
                .onTapGesture {
                    if progressPictures.count > 2 {
                        withAnimation { isExpanded.toggle() }
                    }
                }
                
                if isExpanded && progressPictures.count > 2 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            if let startImage = startPicture {
                                ProgressPictureItem(
                                    image: startImage,
                                    date: userProfile?.startDate ?? Date(),
                                    weight: userProfile?.startWeight ?? 0.0,
                                    useMetric: userProfile?.useMetric ?? false
                                )
                            }
                            ForEach(progressPictures, id: \.self) { picture in
                                if let imageData = picture.imageData, let image = UIImage(data: imageData) {
                                    ProgressPictureItem(
                                        image: image,
                                        date: picture.date ?? Date(),
                                        weight: picture.weight,
                                        useMetric: userProfile?.useMetric ?? false
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .background(Styles.secondaryBackground)
                    .cornerRadius(8)
                }
            }
            .padding(.top, 40)
            
            HStack {
                Text("Progress Pics")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
                Button(action: { isPhotoPickerPresented = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .background(Styles.secondaryBackground)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
            .zIndex(1)
        }
    }
    
    private var weightSection: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 15) {
                Spacer().frame(height: 20)
                HStack {
                    Text("Goal: \(goalMessage)")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                SwiftUI.ProgressView(value: weightProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 12)
                    .padding(.horizontal, 15)
                
                HStack {
                    Text("\(String(format: "%.1f", userProfile?.startWeight ?? 0.0))")
                        .font(.caption)
                        .foregroundColor(Styles.primaryText)
                    Spacer()
                    Text("\(String(format: "%.1f", userProfile?.goalWeight ?? 0.0))")
                        .font(.caption)
                        .foregroundColor(Styles.primaryText)
                }
                .padding(.horizontal, 15)
                
                weightGraph
            }
            .padding(.top, 40)
            .background(Styles.tertiaryBackground)
            .cornerRadius(8)
            
            HStack {
                Text("Weight")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(weightDifference.value > 0 ? "+" : "")\(String(format: "%.1f", weightDifference.value)) \(userProfile?.useMetric ?? false ? "kg" : "lbs")")
                    .font(.subheadline)
                    .foregroundColor(weightDifference.color)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .background(Styles.secondaryBackground)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
            .zIndex(1)
        }
    }
    
    private var weightGraph: some View {
        let hasData = !weightData.isEmpty
        let currentWeight = userProfile?.currentWeight ?? 0.0
        let startWeight = userProfile?.startWeight ?? 0.0
        let goalWeight = userProfile?.goalWeight ?? 0.0
        
        let minWeight = min(currentWeight, goalWeight) - 5
        let maxWeight = max(currentWeight, goalWeight) + 5
        
        let today = Date()
        let futureDates = (0...5).map { Calendar.current.date(byAdding: .day, value: $0, to: today)! }
        
        var displayData: [(date: Date, weight: Double)]
        if hasData && weightData.count >= 5 {
            displayData = weightData
        } else {
            displayData = weightData
            let remainingCount = 5 - weightData.count
            if remainingCount > 0 {
                let futureData = futureDates.prefix(remainingCount).map { ($0, currentWeight) }
                displayData.append(contentsOf: futureData)
            }
        }
        
        let minDate = displayData.map { $0.date }.min() ?? today
        let maxDate = displayData.map { $0.date }.max() ?? futureDates.last!
        
        return Chart {
            ForEach(displayData, id: \.date) { data in
                LineMark(
                    x: .value("Date", data.date),
                    y: .value("Weight", data.weight)
                )
                .foregroundStyle(hasData ? .blue : .gray)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            
            RuleMark(y: .value("Goal", goalWeight))
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .top) {
                    VStack {
                        Spacer().frame(height: 10)
                        Text("Goal: \(String(format: "%.1f", goalWeight))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            
            RuleMark(y: .value("Current", currentWeight))
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .top) {
                    Text("Current: \(String(format: "%.1f", currentWeight))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine()
                    .foregroundStyle(Styles.primaryText)
                AxisTick()
                    .foregroundStyle(Styles.primaryText)
                AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    .foregroundStyle(Styles.primaryText)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Styles.primaryText)
                AxisTick()
                    .foregroundStyle(Styles.primaryText)
                AxisValueLabel()
                    .foregroundStyle(Styles.primaryText)
            }
        }
        .chartXScale(domain: minDate...maxDate)
        .chartYScale(domain: minWeight...maxWeight)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    private var bodyMeasurementSection: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 15) {
                let hasMultipleEntries = bodyMeasurements.count > 1
                let latestMeasurement = bodyMeasurements.last
                let earliestMeasurement = bodyMeasurements.first
                let allZero = latestMeasurement.map { $0.chest == 0 && $0.waist == 0 && $0.hips == 0 && $0.leftArm == 0 && $0.rightArm == 0 && $0.leftThigh == 0 && $0.rightThigh == 0 } ?? true
                
                HStack(spacing: 15) {
                    Spacer()
                    Image("BMDefault")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 263)
                    VStack(alignment: .leading, spacing: 8) {
                        MeasurementRow(label: "Chest", value: latestMeasurement?.chest ?? 0, difference: calculateDifference(earliest: earliestMeasurement?.chest, latest: latestMeasurement?.chest), showDifference: hasMultipleEntries, useMetric: userProfile?.useMetric ?? false)
                        MeasurementRow(label: "Waist", value: latestMeasurement?.waist ?? 0, difference: calculateDifference(earliest: earliestMeasurement?.waist, latest: latestMeasurement?.waist), showDifference: hasMultipleEntries, useMetric: userProfile?.useMetric ?? false)
                        MeasurementRow(label: "Hips", value: latestMeasurement?.hips ?? 0, difference: calculateDifference(earliest: earliestMeasurement?.hips, latest: latestMeasurement?.hips), showDifference: hasMultipleEntries, useMetric: userProfile?.useMetric ?? false)
                        MeasurementRow(label: "Arms (L)", value: latestMeasurement?.leftArm ?? 0, difference: calculateDifference(earliest: earliestMeasurement?.leftArm, latest: latestMeasurement?.leftArm), showDifference: hasMultipleEntries, useMetric: userProfile?.useMetric ?? false)
                        MeasurementRow(label: "Arms (R)", value: latestMeasurement?.rightArm ?? 0, difference: calculateDifference(earliest: earliestMeasurement?.rightArm, latest: latestMeasurement?.rightArm), showDifference: hasMultipleEntries, useMetric: userProfile?.useMetric ?? false)
                        MeasurementRow(label: "Thighs (L)", value: latestMeasurement?.leftThigh ?? 0, difference: calculateDifference(earliest: earliestMeasurement?.leftThigh, latest: latestMeasurement?.leftThigh), showDifference: hasMultipleEntries, useMetric: userProfile?.useMetric ?? false)
                        MeasurementRow(label: "Thighs (R)", value: latestMeasurement?.rightThigh ?? 0, difference: calculateDifference(earliest: earliestMeasurement?.rightThigh, latest: latestMeasurement?.rightThigh), showDifference: hasMultipleEntries, useMetric: userProfile?.useMetric ?? false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Styles.tertiaryBackground)
                .cornerRadius(8)
                .onTapGesture { showBodyMeasurementView = true }
                
                if allZero {
                    Text("Enter your measurements")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                        .padding(.bottom, 5)
                }
            }
            .padding(.top, 40)
            
            HStack {
                Text("Body Measurements")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
                Button(action: { showBodyMeasurementView = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .background(Styles.secondaryBackground)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
            .zIndex(1)
        }
    }
    
    private var exerciseOverviewSection: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    Spacer()
                    Image("Running")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 263)
                    VStack(alignment: .leading, spacing: 8) {
                        ExerciseRow(label: "Highest Streak", value: highestStreak)
                        ExerciseRow(label: "Current Streak", value: currentStreak)
                        ExerciseRow(label: "Days Worked Out", value: daysWorkedOutPercentage, isPercentage: true)
                        ExerciseRow(label: "Total Exercise Time", value: totalExerciseTime, isTime: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Styles.tertiaryBackground)
                .cornerRadius(8)
                
                // Moved inside the main content VStack
                if totalExerciseTime == 0 {
                    Text("No workouts recorded yet")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                        .padding(.bottom, 5)
                }
                Spacer()
                Spacer()
            }
            .padding(.top, 40)
            .background(Styles.secondaryBackground) // Applied to the entire VStack
            .cornerRadius(8)
            
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
    }
    
    struct MeasurementRow: View {
        let label: String
        let value: Double
        let difference: Double?
        let showDifference: Bool
        let useMetric: Bool
        
        var body: some View {
            HStack(spacing: 10) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
                    .frame(width: 80, alignment: .leading)
                Text(String(format: "%.1f%@", value, useMetric ? "cm" : "in"))
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
                if showDifference, let diff = difference {
                    Text(diff > 0 ? "+\(String(format: "%.1f", diff))" : String(format: "%.1f", diff))
                        .font(.subheadline)
                        .foregroundColor(diff > 0 ? .red : .green)
                }
            }
        }
    }
    
    struct ExerciseRow: View {
        let label: String
        let value: Any
        var isPercentage: Bool = false
        var isTime: Bool = false
        
        var formattedValue: String {
            if isTime {
                let hours = (value as? Int ?? 0) / 60
                let minutes = (value as? Int ?? 0) % 60
                return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
            } else if isPercentage {
                return String(format: "%.1f%%", value as? Double ?? 0.0)
            } else {
                return String(value as? Int ?? 0)
            }
        }
        
        var body: some View {
            HStack(spacing: 10) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
                    .frame(width: 120, alignment: .leading)
                Text(formattedValue)
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
            }
        }
    }
    
    private func fetchBodyMeasurements() {
        guard let userProfile = userProfile else {
            print("❌ No user profile for fetching measurements")
            return
        }
        print("DEBUG: Fetching for user: \(userProfile.name ?? "unknown"), ID: \(userProfile.objectID.uriRepresentation())")
        let fetchRequest: NSFetchRequest<BodyMeasurement> = BodyMeasurement.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userProfile == %@", userProfile)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let measurements = try viewContext.fetch(fetchRequest)
            print("DEBUG: Fetched \(measurements.count) body measurements")
            for (index, measurement) in measurements.enumerated() {
                print("DEBUG: Measurement \(index) - Chest: \(measurement.chest), Date: \(measurement.date?.description ?? "nil"), ObjectID: \(measurement.objectID.uriRepresentation())")
            }
            self.bodyMeasurements = measurements
        } catch {
            print("❌ Fetch error: \(error.localizedDescription)")
            self.bodyMeasurements = []
        }
    }
    
    private func calculateDifference(earliest: Double?, latest: Double?) -> Double? {
        guard let earliest = earliest, let latest = latest else { return nil }
        return latest - earliest
    }
    
    private func fetchUserProfile() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            userProfile = try viewContext.fetch(fetchRequest).first
            print("DEBUG: Fetched UserProfile - Name: \(userProfile?.name ?? "nil"), ID: \(userProfile?.objectID.uriRepresentation().description ?? "nil")")
        } catch {
            print("❌ Error fetching user profile: \(error.localizedDescription)")
            userProfile = nil
        }
    }
    
    private func fetchProgressPictures() {
        guard let userProfile = userProfile else { return }
        let fetchRequest: NSFetchRequest<ProgressPicture> = ProgressPicture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userProfile == %@", userProfile)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            progressPictures = try viewContext.fetch(fetchRequest)
        } catch {
            print("❌ Error fetching progress pictures: \(error.localizedDescription)")
            progressPictures = []
        }
    }
    
    private func fetchDailyRecords() {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            dailyRecords = try viewContext.fetch(fetchRequest)
        } catch {
            print("❌ Error fetching daily records: \(error.localizedDescription)")
            dailyRecords = []
        }
    }
    
    private func saveProgressPicture(from photoItem: PhotosPickerItem?) {
        guard let photoItem = photoItem, let userProfile = userProfile else { return }
        Task {
            do {
                if let data = try await photoItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let currentDate = Date()
                    let currentWeight = userProfile.currentWeight
                    if progressPictures.isEmpty && userProfile.startPicture == nil {
                        userProfile.startPicture = data
                        userProfile.startDate = currentDate
                        userProfile.startWeight = currentWeight
                        print("DEBUG: Set first picture as startPicture")
                    } else {
                        let newPicture = ProgressPicture(context: viewContext)
                        newPicture.imageData = data
                        newPicture.date = currentDate
                        newPicture.weight = currentWeight
                        newPicture.userProfile = userProfile
                        progressPictures.append(newPicture)
                        print("DEBUG: Added new progress picture")
                    }
                    try viewContext.save()
                    fetchProgressPictures()
                }
            } catch {
                print("❌ Error saving progress picture: \(error.localizedDescription)")
            }
        }
    }
    
    private func generateGoalMessage(userProfile: UserProfile) -> String {
        let weightDifference = abs(userProfile.goalWeight - userProfile.currentWeight)
        let formattedDifference = userProfile.useMetric ? "\(weightDifference) kg" : "\(weightDifference) lbs"
        if userProfile.weekGoal == 0 {
            return "Maintain Current Weight"
        } else if userProfile.goalWeight == 0 {
            let action = userProfile.weekGoal < 0 ? "Lose" : "Gain"
            return "\(action) \(abs(userProfile.weekGoal)) per week"
        } else if userProfile.goalWeight > 0 && userProfile.targetDate == nil {
            let action = userProfile.weekGoal < 0 ? "Lose" : "Gain"
            return "\(action) \(formattedDifference) by \(action.lowercased())ing \(abs(userProfile.weekGoal)) per week"
        } else if userProfile.goalWeight > 0 && userProfile.targetDate != nil {
            let action = userProfile.weekGoal < 0 ? "Lose" : "Gain"
            return "\(action) \(formattedDifference) by \(formattedGoalDate(userProfile.targetDate))"
        } else {
            return "No Goal Set"
        }
    }
    
    private func formattedGoalDate(_ date: Date?) -> String {
        guard let date = date else { return "Not Provided" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Exercise Calculations
    private var highestStreak: Int {
        guard !dailyRecords.isEmpty, let startDate = userProfile?.startDate else { return 0 }
        var maxStreak = 0
        var currentStreak = 0
        
        let sortedRecords = dailyRecords.sorted { $0.date ?? Date() < $1.date ?? Date() }
        for record in sortedRecords {
            if hasWorkout(record) {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        return maxStreak
    }
    
    private var currentStreak: Int {
        guard !dailyRecords.isEmpty, let startDate = userProfile?.startDate else { return 0 }
        var streak = 0
        let today = Calendar.current.startOfDay(for: Date())
        let sortedRecords = dailyRecords.sorted { $0.date ?? Date() < $1.date ?? Date() }.reversed()
        
        for record in sortedRecords {
            guard let recordDate = record.date else { continue }
            if Calendar.current.isDate(recordDate, inSameDayAs: today) || recordDate < today {
                if hasWorkout(record) {
                    streak += 1
                } else {
                    break
                }
            }
        }
        return streak
    }
    
    private var daysWorkedOutPercentage: Double {
        guard !dailyRecords.isEmpty, let startDate = userProfile?.startDate else { return 0.0 }
        let workoutDays = dailyRecords.filter { hasWorkout($0) }.count
        let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
        return totalDays > 0 ? (Double(workoutDays) / Double(totalDays)) * 100 : 0.0
    }
    
    private var totalExerciseTime: Int {
        guard !dailyRecords.isEmpty else { return 0 }
        return dailyRecords.reduce(0) { total, record in
            let workoutEntries = (record.diaryEntries as? Set<CoreDiaryEntry>)?.filter { $0.type == "Workout" } ?? []
            return total + workoutEntries.reduce(0) { $0 + extractDuration($1.detail ?? "") }
        }
    }
    
    private func hasWorkout(_ record: DailyRecord) -> Bool {
        let workoutEntries = (record.diaryEntries as? Set<CoreDiaryEntry>)?.filter { $0.type == "Workout" }
        return !(workoutEntries?.isEmpty ?? true)
    }
    
    private func extractDuration(_ detail: String) -> Int {
        let components = detail.lowercased().split(separator: " ")
        var totalMinutes = 0
        
        for i in stride(from: 0, to: components.count - 1, by: 2) {
            if let value = Int(components[i]) {
                let unit = String(components[i + 1])
                if unit.hasPrefix("hr") || unit.hasPrefix("hour") {
                    totalMinutes += value * 60
                } else if unit.hasPrefix("min") {
                    totalMinutes += value
                }
            }
        }
        return totalMinutes
    }
}

struct ProgressPictureItem: View {
    let image: UIImage
    let date: Date
    let weight: Double
    let useMetric: Bool
    
    private var formattedDate: String { DateFormatter.mediumDate.string(from: date) }
    private var formattedWeight: String { weight > 0 ? "\(weight) \(useMetric ? "kg" : "lbs")" : "N/A" }
    
    var body: some View {
        VStack(spacing: 5) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(Styles.primaryText)
            Text(formattedWeight)
                .font(.caption)
                .foregroundColor(Styles.primaryText)
        }
    }
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View { ProgressView() }
}
