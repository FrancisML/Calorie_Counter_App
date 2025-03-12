// ProgressView.swift
// Calorie counter
// Created by frank lasalvia on 2/9/25.


// ProgressView.swift
// Calorie counter
// Created by frank lasalvia on 2/9/25.

import SwiftUI
import CoreData
import PhotosUI
import Charts

struct ProgressView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var userProfile: UserProfile?
    @State private var dailyRecords: [DailyRecord] = []
    @State private var bodyMeasurements: [BodyMeasurement] = []
    @State private var showBodyMeasurementView = false
    @State private var showDeleteConfirmation = false
    @State private var pictureToDelete: ProgressPicture? = nil
    @State private var showDeleteOptions = false
    
    // Simulated Date Logic
    private var simulatedCurrentDate: Date {
        if let savedDate = UserDefaults.standard.object(forKey: "simulatedCurrentDate") as? Date {
            return Calendar.current.startOfDay(for: savedDate)
        }
        return Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerView
                    ProgressPictureView(
                        userProfile: $userProfile,
                        showDeleteOptions: $showDeleteOptions,
                        onDeletePicture: { picture in
                            pictureToDelete = picture
                            showDeleteConfirmation = true
                        }
                    )
                    .environment(\.managedObjectContext, viewContext)
                    WeightProgressView(userProfile: $userProfile, dailyRecords: $dailyRecords)
                    BodyMeasurementView(
                        userProfile: $userProfile,
                        bodyMeasurements: $bodyMeasurements,
                        showBodyMeasurementView: $showBodyMeasurementView
                    )
                    ExerciseOverviewView(
                        
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.primaryBackground)
            .ignoresSafeArea(edges: .top)
            .onAppear {
                fetchUserProfile()
                fetchDailyRecords()
                fetchBodyMeasurements()
            }
            .sheet(isPresented: $showBodyMeasurementView) {
                MeasurementInputView(userProfile: userProfile)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onChange(of: showBodyMeasurementView) { newValue in
                if !newValue { // Sheet dismissed
                    fetchBodyMeasurements()
                }
            }
            
            // Delete Confirmation Overlay
            if showDeleteConfirmation {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showDeleteConfirmation = false
                        showDeleteOptions = false
                    }
                
                VStack {
                    Text("Confirm Deletion")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)
                        .padding(.top)
                    Text("Are you sure you want to delete this? This action cannot be undone.")
                        .font(.subheadline)
                        .foregroundColor(Styles.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                    if let picture = pictureToDelete, let imageData = picture.imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipped()
                            .overlay(
                                HStack {
                                    Spacer()
                                    Text("\(DateFormatter.mediumDate.string(from: picture.date ?? Date())) \(picture.weight > 0 ? "\(picture.weight) \(userProfile?.useMetric ?? false ? "kg" : "lbs")" : "")")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.black.opacity(0.6))
                                }
                                .padding(.bottom, 10)
                                .frame(maxWidth: .infinity, alignment: .trailing),
                                alignment: .bottom
                            )
                            .padding(.bottom, 20)
                    }
                    HStack(spacing: 40) {
                        Button("Delete", role: .destructive) {
                            deletePicture()
                            showDeleteConfirmation = false
                            showDeleteOptions = false
                        }
                        Button("Cancel") {
                            showDeleteConfirmation = false
                            showDeleteOptions = false
                        }
                    }
                    .padding(.bottom)
                }
                .padding()
                .background(Styles.secondaryBackground)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: 300)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showDeleteConfirmation)
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
    
    private func fetchUserProfile() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            if let profile = try viewContext.fetch(fetchRequest).first {
                userProfile = profile
                print("✅ ProgressView fetched user profile: \(profile.name ?? "Unknown")")
            } else {
                print("⚠️ No UserProfile found in Core Data for ProgressView")
                let newProfile = UserProfile(context: viewContext)
                newProfile.name = "Default User"
                newProfile.gender = "Male"
                newProfile.currentWeight = 0.0
                newProfile.startWeight = 0.0
                newProfile.goalWeight = 0.0
                newProfile.useMetric = false
                newProfile.highestActivityStreak = 1 // Initialize to 1 as per your requirement
                newProfile.startDate = Calendar.current.startOfDay(for: Date()) // Set start date for streak calculations
                newProfile.dailyCalorieGoal = 2000 // Reasonable default calorie goal
                newProfile.waterGoal = 8 // Default water goal (e.g., 8 cups or 2L, depending on unit)
                newProfile.waterUnit = newProfile.useMetric ? "L" : "cups" // Consistent water unit
                try viewContext.save()
                userProfile = newProfile
                print("✅ Created default user profile: \(newProfile.name ?? "Unknown") with highestActivityStreak: \(newProfile.highestActivityStreak)")
            }
        } catch {
            print("❌ Error fetching user profile: \(error.localizedDescription)")
            userProfile = nil
        }
    }
    private func fetchDailyRecords() {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            dailyRecords = try viewContext.fetch(fetchRequest)
            print("✅ Fetched \(dailyRecords.count) daily records")
        } catch {
            print("❌ Error fetching daily records: \(error.localizedDescription)")
            dailyRecords = []
        }
    }
    
    private func fetchBodyMeasurements() {
        guard let userProfile = userProfile else {
            print("❌ No user profile for fetching measurements")
            return
        }
        let fetchRequest: NSFetchRequest<BodyMeasurement> = BodyMeasurement.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userProfile == %@", userProfile)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            bodyMeasurements = try viewContext.fetch(fetchRequest)
            print("✅ Fetched \(bodyMeasurements.count) body measurements")
        } catch {
            print("❌ Fetch error: \(error.localizedDescription)")
            bodyMeasurements = []
        }
    }
    
    private func deletePicture() {
        guard let picture = pictureToDelete else { return }
        viewContext.delete(picture)
        do {
            try viewContext.save()
            pictureToDelete = nil
            fetchUserProfile()
            print("✅ Deleted progress picture and refreshed user profile")
        } catch {
            print("❌ Error deleting progress picture: \(error.localizedDescription)")
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
}
