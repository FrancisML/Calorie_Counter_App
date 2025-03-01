//
//  PastView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/9/25.
//

import SwiftUI
import Charts
import CoreData

struct PastView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // State to hold past records
    @State private var pastRecords: [DailyRecord] = []
    @State private var userProfile: UserProfile?
    
    // Computed properties for graph data
    private var calorieData: [(date: Date, intake: Double, goal: Double)] {
        pastRecords.compactMap { record in
            guard let date = record.date else { return nil }
            let intake = record.calorieIntake
            // Use dailyCalorieGoal from UserProfile as a fallback; ideally, this would be stored per day
            let goal = Double(userProfile?.dailyCalorieGoal ?? 2000) // Default to 2000 if no profile
            return (date: date, intake: intake, goal: goal)
        }.sorted { $0.date < $1.date } // Sort by date
    }
    
    private var passPercentage: Double {
        guard !pastRecords.isEmpty else { return 0.0 }
        let passCount = pastRecords.filter { $0.passFail }.count
        return (Double(passCount) / Double(pastRecords.count)) * 100
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Push the title down to avoid the notch
                Spacer()
                    .frame(height: 50) // Adjust this value based on your device's notch height
                
                Text("Past Records")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Styles.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Line Graph for Calories Over Time
                if !calorieData.isEmpty {
                    Chart {
                        // Line for Calorie Intake
                        ForEach(calorieData, id: \.date) { data in
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("Calories", data.intake)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        
                        // Line for Calorie Goal
                        ForEach(calorieData, id: \.date) { data in
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("Goal", data.goal)
                            )
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5])) // Dashed line for goal
                        }
                    }
                    .frame(height: 250)
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
                    .padding(.horizontal)
                } else {
                    Text("No past data available")
                        .foregroundColor(Styles.secondaryText)
                        .frame(height: 250)
                }
                
                // Pass Percentage
                Text("Pass Percentage: \(String(format: "%.1f", passPercentage))%")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                
                // List of Past Days
                VStack(spacing: 10) {
                    ForEach(pastRecords.indices, id: \.self) { index in
                        let record = pastRecords[index]
                        PastDayRow(record: record, userProfile: userProfile)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            fetchPastRecords()
            fetchUserProfile()
        }
    }
    
    private func fetchPastRecords() {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            pastRecords = try viewContext.fetch(fetchRequest)
        } catch {
            print("❌ Error fetching past records: \(error.localizedDescription)")
            pastRecords = []
        }
    }
    
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
}

// Subview for each past day row
struct PastDayRow: View {
    let record: DailyRecord
    let userProfile: UserProfile?
    
    private var dayTitle: String {
        guard let date = record.date, let startDate = userProfile?.startDate else { return "Day X" }
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: date).day! + 1
        return "Day \(daysSinceStart)"
    }
    
    private var formattedDate: String {
        guard let date = record.date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var calorieGoal: Int32 {
        userProfile?.dailyCalorieGoal ?? 2000 // Default fallback
    }
    
    private var weighIn: String {
        // Ideally, weigh-ins would be stored per day in DailyRecord; using UserProfile's currentWeight as a placeholder
        guard let date = record.date, let userProfile = userProfile else { return "N/A" }
        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
        return isToday && userProfile.currentWeight > 0 ? "\(userProfile.currentWeight) \(userProfile.useMetric ? "kg" : "lbs")" : "N/A"
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Day and Date
            VStack(alignment: .leading, spacing: 5) {
                Text(dayTitle)
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
            }
            .frame(width: 100, alignment: .leading)
            
            // Details
            VStack(alignment: .leading, spacing: 5) {
                Text("Calories: \(Int(record.calorieIntake))/\(calorieGoal)")
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
                Text("Water: \(String(format: "%.1f", record.waterIntake)) \(record.waterUnit ?? "fl oz")")
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
                Text("Weigh-In: \(weighIn)")
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
            }
            
            Spacer()
            
            // Pass/Fail Indicator
            Text(record.passFail ? "PASS" : "FAIL")
                .font(.headline)
                .foregroundColor(record.passFail ? .green : .red)
                .frame(width: 60, alignment: .trailing)
        }
        .padding()
        .background(
            record.passFail ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        )
        .cornerRadius(8)
    }
}

struct PastView_Previews: PreviewProvider {
    static var previews: some View {
        PastView()
    }
}
