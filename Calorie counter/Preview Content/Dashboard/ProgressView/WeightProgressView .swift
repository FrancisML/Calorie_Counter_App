//
//  WeightProgressView .swift
//  Calorie counter
//
//  Created by frank lasalvia on 3/8/25.
//


// WeightProgressView.swift
import SwiftUI
import Charts

struct WeightProgressView: View {
    @Binding var userProfile: UserProfile?
    @Binding var dailyRecords: [DailyRecord]
    
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
    
    private var progressPercentage: String {
        String(format: "%.0f%%", weightProgress * 100)
    }
    
    private var weightUnit: String {
        userProfile?.useMetric ?? false ? "kg" : "lb"
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 10) {
                Spacer().frame(height: 20)
                HStack {
                    Text(goalMessage)
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                    Spacer()
                    Text(progressPercentage)
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                }
                .padding(.horizontal, 15)
                
                // Custom Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Styles.primaryText.opacity(0.2))
                            .frame(height: 20)
                        
                        Rectangle()
                            .fill(Styles.primaryText)
                            .frame(
                                width: min(CGFloat(weightProgress) * geometry.size.width, geometry.size.width),
                                height: 20
                            )
                            .animation(.easeInOut(duration: 0.3), value: weightProgress)
                    }
                }
                .frame(height: 20)
                .padding(.horizontal, 15)
                
                HStack {
                    Text("\(String(format: "%.1f", userProfile?.startWeight ?? 0.0)) \(weightUnit)")
                        .font(.caption)
                        .foregroundColor(Styles.primaryText)
                    Spacer()
                    Text("\(String(format: "%.1f", userProfile?.goalWeight ?? 0.0)) \(weightUnit)")
                        .font(.caption)
                        .foregroundColor(Styles.primaryText)
                }
                .padding(.horizontal, 15)
                .padding(.top, 4)
                
                // Divider between progress bar and graph
                Divider()
                    .frame(height: 1)
                    .background(Styles.primaryText.opacity(0.2))
                    .padding(.horizontal, 15)
                
                weightGraph
            }
            .padding(.top, 40)
            .background(Styles.primaryBackground) // Changed from tertiaryBackground to primaryBackground
            .cornerRadius(8)
            
            HStack {
                Text("Weight")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(weightDifference.value > 0 ? "+" : "")\(String(format: "%.1f", weightDifference.value)) \(weightUnit)")
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
        
        let allWeights = weightData.map { $0.weight } + [startWeight, currentWeight, goalWeight].filter { $0 > 0 }
        let minWeight = allWeights.min() ?? 0.0
        let maxWeight = allWeights.max() ?? 0.0
        let adjustedMinWeight = minWeight - 5
        let adjustedMaxWeight = maxWeight + 5
        
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
        .chartYScale(domain: adjustedMinWeight...adjustedMaxWeight)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .clipped()
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
        return DateFormatter.mediumDate.string(from: date)
    }
}

struct WeightProgressView_Previews: PreviewProvider {
    static var previews: some View {
        WeightProgressView(userProfile: .constant(nil), dailyRecords: .constant([]))
    }
}
