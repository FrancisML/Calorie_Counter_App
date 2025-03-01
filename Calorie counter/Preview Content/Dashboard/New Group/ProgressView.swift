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
        let progress = currentChange / totalChange
        return min(max(progress, 0.0), 1.0)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                progressPictureSection
                weightSection
                bodyMeasurementSection
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea(edges: .top)
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { newPhoto in
            saveProgressPicture(from: newPhoto)
        }
        .onAppear {
            fetchUserProfile()
            fetchDailyRecords()
        }
        .sheet(isPresented: $showBodyMeasurementView) {
            BodyMeasurementView(userProfile: userProfile)
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: 50)
            Text("Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Styles.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private var progressPictureSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Progress Pics")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
                Button(action: {
                    isPhotoPickerPresented = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .zIndex(1)
            
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
                    withAnimation {
                        isExpanded.toggle()
                    }
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
        .background(Styles.tertiaryBackground)
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var weightSection: some View {
        VStack(spacing: 15) {
            Text("Weight")
                .font(.headline)
                .foregroundColor(Styles.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Goal: \(goalMessage)")
                .font(.subheadline)
                .foregroundColor(Styles.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            weightGraph
            
            weightProgressBar
        }
        .padding()
        .background(Styles.tertiaryBackground)
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var weightGraph: some View {
        Group {
            if !weightData.isEmpty {
                Chart {
                    ForEach(weightData, id: \.date) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Weight", data.weight)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            } else {
                Text("No weight data available")
                    .foregroundColor(Styles.secondaryText)
                    .frame(height: 200)
            }
        }
    }
    
    private var weightProgressBar: some View {
        Group {
            if userProfile?.startWeight ?? 0.0 > 0 && userProfile?.goalWeight ?? 0.0 > 0 {
                SwiftUI.ProgressView(value: weightProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .overlay(
                        Text("Progress to Goal: \(Int(weightProgress * 100))%")
                            .font(.subheadline)
                            .foregroundColor(Styles.primaryText),
                        alignment: .top
                    )
            } else {
                Text("Set a start and goal weight to track progress")
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
            }
        }
    }
    
    private var bodyMeasurementSection: some View {
        VStack(spacing: 15) {
            Text("Body Measurements")
                .font(.headline)
                .foregroundColor(Styles.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                Image("Running")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Chest")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                    Text("Waist")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                    Text("Hips")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                    Text("Arms (L/R)")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                    Text("Thighs (L/R)")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                }
            }
            .padding()
            .background(Styles.tertiaryBackground)
            .cornerRadius(8)
            .onTapGesture {
                showBodyMeasurementView = true
            }
        }
        .padding(.horizontal)
    }
    
    // Fetch Functions
    private func fetchUserProfile() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            userProfile = try viewContext.fetch(fetchRequest).first
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
    
    // Save Progress Picture
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
    
    // Goal Message Logic
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
}

struct ProgressPictureItem: View {
    let image: UIImage
    let date: Date
    let weight: Double
    let useMetric: Bool
    
    private var formattedDate: String {
        DateFormatter.mediumDate.string(from: date)
    }
    
    private var formattedWeight: String {
        weight > 0 ? "\(weight) \(useMetric ? "kg" : "lbs")" : "N/A"
    }
    
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
    static var previews: some View {
        ProgressView()
    }
}
