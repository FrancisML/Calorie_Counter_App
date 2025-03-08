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
    
    @State private var pastRecords: [DailyRecord] = []
    @State private var userProfile: UserProfile?
    @State private var selectedRecord: DailyRecord?
    
    private var simulatedCurrentDate: Date {
        if let savedDate = UserDefaults.standard.object(forKey: "simulatedCurrentDate") as? Date {
            return Calendar.current.startOfDay(for: savedDate)
        }
        return Calendar.current.startOfDay(for: Date())
    }
    
    private struct CaloriePoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let category: String
    }
    
    private var chartData: [CaloriePoint] {
        var data: [CaloriePoint] = []
        let filteredRecords = pastRecords.filter { !Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: simulatedCurrentDate) }
        guard !filteredRecords.isEmpty else { return data }
        
        let sortedRecords = filteredRecords.sorted { $0.date ?? Date() < $1.date ?? Date() }
        guard let firstDate = sortedRecords.first?.date,
              let lastDate = sortedRecords.last?.date else { return data }
        
        for record in sortedRecords {
            if let date = record.date {
                data.append(CaloriePoint(date: date, value: record.calorieIntake, category: "Intake"))
                data.append(CaloriePoint(date: date, value: record.calorieGoal, category: "Goal"))
            }
        }
        
        return data
    }
    
    private var averageCalories: Double {
        let filteredRecords = pastRecords.filter { !Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: simulatedCurrentDate) }
        guard !filteredRecords.isEmpty else { return 0.0 }
        let total = filteredRecords.reduce(0) { $0 + $1.calorieIntake }
        return total / Double(filteredRecords.count)
    }
    
    private var passPercentage: Double {
        let filteredRecords = pastRecords.filter { !Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: simulatedCurrentDate) }
        guard !filteredRecords.isEmpty else { return 0.0 }
        let passCount = filteredRecords.filter { $0.passFail }.count
        return (Double(passCount) / Double(filteredRecords.count)) * 100
    }
    
    private var xAxisDates: [Date] {
        let filteredRecords = pastRecords.filter { !Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: simulatedCurrentDate) }
        guard !filteredRecords.isEmpty else { return [] }
        let sortedRecords = filteredRecords.sorted { $0.date ?? Date() < $1.date ?? Date() }
        guard let firstDate = sortedRecords.first?.date,
              let lastDate = sortedRecords.last?.date else { return [] }
        
        let totalDays = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        let maxLabels = 5
        let step = max(1, totalDays / (maxLabels - 1))
        
        var dates: [Date] = []
        for i in stride(from: 0, through: totalDays, by: step) {
            if let date = Calendar.current.date(byAdding: .day, value: i, to: firstDate) {
                dates.append(date)
            }
        }
        if !dates.contains(where: { Calendar.current.isDate($0, inSameDayAs: lastDate) }) {
            dates.append(lastDate)
        }
        return dates
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 50)
                
                Text("Past Records")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Styles.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if !pastRecords.filter({ !Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: simulatedCurrentDate) }).isEmpty {
                    VStack(spacing: 10) {
                        Text("Calories per Day")
                            .font(.headline)
                            .foregroundColor(Styles.primaryText)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Styles.secondaryBackground)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -2)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Chart {
                            ForEach(chartData) { point in
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Calories", point.value)
                                )
                                .foregroundStyle(by: .value("Category", point.category))
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            }
                            
                            RuleMark(
                                y: .value("Average", averageCalories)
                            )
                            .foregroundStyle(.purple)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        }
                        .chartForegroundStyleScale([
                            "Intake": Styles.primaryText,
                            "Goal": .orange
                        ])
                        .chartLineStyleScale([
                            "Intake": StrokeStyle(lineWidth: 2),
                            "Goal": StrokeStyle(lineWidth: 2, dash: [5, 5])
                        ])
                        .chartLegend(.hidden)
                        .chartXAxis {
                            AxisMarks(values: xAxisDates) { value in
                                AxisGridLine()
                                    .foregroundStyle(Styles.primaryText)
                                AxisTick()
                                    .foregroundStyle(Styles.primaryText)
                                AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                                    .foregroundStyle(Styles.primaryText)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading, values: .automatic) { value in
                                AxisGridLine()
                                    .foregroundStyle(Styles.primaryText)
                                AxisTick()
                                    .foregroundStyle(Styles.primaryText)
                                AxisValueLabel()
                                    .foregroundStyle(Styles.primaryText)
                            }
                        }
                        .frame(height: 250)
                        .padding(.horizontal)
                        .chartOverlay { proxy in
                            GeometryReader { geometry in
                                Rectangle().fill(.clear).contentShape(Rectangle())
                                    .overlay(alignment: .leading) {
                                        if let firstDate = pastRecords.filter({ !Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: simulatedCurrentDate) }).min(by: { $0.date ?? Date() < $1.date ?? Date() })?.date,
                                           let xPosition = proxy.position(forX: firstDate),
                                           let yPosition = proxy.position(forY: averageCalories) {
                                            Text("\(Int(averageCalories))")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                                .position(x: xPosition + 30, y: yPosition)
                                        }
                                    }
                            }
                        }
                        
                        HStack(spacing: 20) {
                            HStack {
                                Rectangle()
                                    .fill(Styles.primaryText)
                                    .frame(width: 20, height: 2)
                                Text("Intake")
                                    .font(.caption)
                                    .foregroundColor(Styles.secondaryText)
                            }
                            HStack {
                                Rectangle()
                                    .fill(.orange)
                                    .frame(width: 20, height: 2)
                                Text("Goal")
                                    .font(.caption)
                                    .foregroundColor(Styles.secondaryText)
                            }
                            HStack {
                                Rectangle()
                                    .fill(.purple)
                                    .frame(width: 20, height: 2)
                                Text("Average")
                                    .font(.caption)
                                    .foregroundColor(Styles.secondaryText)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 5)
                    }
                    
                    HStack {
                        Text("Past Overview")
                            .font(.headline)
                            .foregroundColor(Styles.primaryText)
                        Spacer()
                        Text("Pass Rate \(String(format: "%.1f", passPercentage))%")
                            .font(.headline)
                            .foregroundColor(Styles.primaryText)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(Styles.secondaryBackground)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -2)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    if let selectedRecord = selectedRecord {
                        PastDailyDBView(
                            record: selectedRecord,
                            userProfile: userProfile,
                            onBack: { withAnimation { self.selectedRecord = nil } }
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(Array(pastRecords.enumerated()).reversed().filter { !Calendar.current.isDate($0.element.date ?? Date.distantFuture, inSameDayAs: simulatedCurrentDate) }, id: \.element.objectID) { index, record in
                                PastDayRow(record: record, userProfile: userProfile, dayNumber: index + 1)
                                    .onTapGesture {
                                        withAnimation {
                                            selectedRecord = record
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text("No past data available")
                        .foregroundColor(Styles.secondaryText)
                        .frame(height: 250)
                }
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
            print("DEBUG: Fetched \(pastRecords.count) past records")
            pastRecords.forEach { record in
                print("Record - Date: \(record.date ?? Date()), Intake: \(record.calorieIntake), Goal: \(record.calorieGoal)")
            }
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

struct PastDailyDBView: View {
    let record: DailyRecord
    let userProfile: UserProfile?
    let onBack: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var weighIns: [WeighIn] = []
    @State private var waterGoal: CGFloat = 0
    @State private var selectedUnit: String = "fl oz"
    @State private var isWaterPickerPresented: Bool = false
    @State private var isWeighInExpanded: Bool = false
    
    private var selectedDate: Date { record.date ?? Date() }
    private var dayNumber: Int {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let records = try viewContext.fetch(fetchRequest)
            if let index = records.firstIndex(where: { Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: selectedDate) }) {
                return index + 1
            }
        } catch {
            print("❌ Error fetching records for dayNumber: \(error.localizedDescription)")
        }
        return 0
    }
    
    private var totalCalories: Double {
        let foodCalories = diaryEntries.filter { $0.type == "Food" }.reduce(0) { $0 + Double($1.calories) }
        let workoutCalories = diaryEntries.filter { $0.type == "Workout" }.reduce(0) { $0 + Double(abs($1.calories)) }
        return foodCalories - workoutCalories
    }
    
    private var quickAddCalories: Double {
        diaryEntries.filter { $0.type == "Food" && $0.fats == 0 && $0.carbs == 0 && $0.protein == 0 }
            .reduce(0) { $0 + Double($1.calories) }
    }
    
    private var fatCalories: Double {
        diaryEntries.filter { $0.type == "Food" && $0.fats > 0 }
            .reduce(0) { $0 + ($1.fats * 9) }
    }
    
    private var carbCalories: Double {
        diaryEntries.filter { $0.type == "Food" && $0.carbs > 0 }
            .reduce(0) { $0 + ($1.carbs * 4) }
    }
    
    private var proteinCalories: Double {
        diaryEntries.filter { $0.type == "Food" && $0.protein > 0 }
            .reduce(0) { $0 + ($1.protein * 4) }
    }
    
    private var totalDailyWater: CGFloat {
        var totalIntake: CGFloat = 0
        for entry in diaryEntries where entry.type == "Water" {
            let (amount, unit) = extractWaterAmountAndUnit(entry.detail)
            let convertedAmount = convertWaterUnit(amount: amount, from: unit, to: selectedUnit)
            totalIntake += convertedAmount
        }
        return totalIntake
    }
    
    private func extractWaterAmountAndUnit(_ detail: String) -> (CGFloat, String) {
        let fractionMap: [String: CGFloat] = ["1/4": 0.25, "1/2": 0.5, "3/4": 0.75, "1": 1.0]
        let components = detail.split(separator: " ")
        if components.count == 2 {
            let amountString = String(components[0])
            let unit = String(components[1])
            if let fractionValue = fractionMap[amountString] {
                return (fractionValue, unit)
            } else if let amount = Double(amountString) {
                return (CGFloat(amount), unit)
            }
        } else if detail.contains("fl oz") {
            let numberString = detail.replacingOccurrences(of: "fl oz", with: "").trimmingCharacters(in: .whitespaces)
            if let amount = Double(numberString) {
                return (CGFloat(amount), "fl oz")
            }
        }
        return (0, "ml")
    }
    
    private func convertWaterUnit(amount: CGFloat, from fromUnit: String, to toUnit: String) -> CGFloat {
        let mlPerFlOz: CGFloat = 29.5735
        let mlPerGallon: CGFloat = 3785.41
        let mlPerLiter: CGFloat = 1000
        
        var amountInMl: CGFloat
        switch fromUnit.lowercased() {
        case "milliliters", "ml": amountInMl = amount
        case "liters", "l": amountInMl = amount * mlPerLiter
        case "gallons", "gal": amountInMl = amount * mlPerGallon
        case "fl", "fl oz": amountInMl = amount * mlPerFlOz
        default: return amount
        }
        
        switch toUnit.lowercased() {
        case "milliliters", "ml": return amountInMl
        case "liters", "l": return amountInMl / mlPerLiter
        case "gallons", "gal": return amountInMl / mlPerGallon
        case "fl", "fl oz": return amountInMl / mlPerFlOz
        default: return amount
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func averageWeight() -> String {
        guard !weighIns.isEmpty else { return "none" }
        let totalWeight = weighIns.compactMap { Double($0.weight) }.reduce(0, +)
        return String(format: "%.1f", totalWeight / Double(weighIns.count))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Styles.primaryText)
                    }
                    Spacer()
                    VStack {
                        Text("Day \(dayNumber)")
                            .font(.headline)
                            .foregroundColor(Styles.secondaryText)
                        Text(formattedDate(selectedDate))
                            .font(.subheadline)
                            .foregroundColor(Styles.primaryText)
                    }
                    Spacer()
                    Text(totalCalories <= Double(record.calorieGoal) ? "UNDER" : "OVER")
                        .font(.headline)
                        .foregroundColor(totalCalories <= Double(record.calorieGoal) ? .green : .red)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Styles.secondaryBackground)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                .zIndex(1)
                
                VStack(spacing: 15) {
                    HStack(spacing: 10) {
                        Image("bolt")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Styles.primaryText)
                            .scaledToFit()
                            .frame(width: 30, height: 40)
                            .padding(.trailing, 5)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Calories")
                                    .font(.headline)
                                    .foregroundColor(totalCalories > Double(record.calorieGoal) ? .red : Styles.primaryText)
                                Spacer()
                                Text("\(Int(totalCalories))/\(Int(record.calorieGoal))")
                                    .font(.subheadline)
                                    .foregroundColor(totalCalories > Double(record.calorieGoal) ? .red : Styles.secondaryText)
                            }
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Styles.primaryText.opacity(0.2))
                                        .frame(height: 20)
                                    HStack(spacing: 0) {
                                        if totalCalories > 0 {
                                            let progressWidth = min(CGFloat(totalCalories / Double(record.calorieGoal)) * geometry.size.width, geometry.size.width)
                                            if quickAddCalories > 0 {
                                                Rectangle()
                                                    .fill(Styles.primaryText)
                                                    .frame(width: (quickAddCalories / totalCalories) * progressWidth)
                                            }
                                            if fatCalories > 0 {
                                                Rectangle()
                                                    .fill(Color.red)
                                                    .frame(width: (fatCalories / totalCalories) * progressWidth)
                                            }
                                            if carbCalories > 0 {
                                                Rectangle()
                                                    .fill(Color.yellow)
                                                    .frame(width: (carbCalories / totalCalories) * progressWidth)
                                            }
                                            if proteinCalories > 0 {
                                                Rectangle()
                                                    .fill(Color.green)
                                                    .frame(width: (proteinCalories / totalCalories) * progressWidth)
                                            }
                                        }
                                    }
                                    .frame(height: 20)
                                }
                            }
                            .frame(height: 20)
                        }
                    }
                    Divider()
                    WaterTrackerView(
                        diaryEntries: diaryEntries,
                        selectedUnit: $selectedUnit,
                        waterGoal: $waterGoal,
                        isWaterPickerPresented: $isWaterPickerPresented
                    )
                    .disabled(true)
                    Divider()
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 10) {
                            Image("CalW")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Styles.primaryText)
                                .scaledToFit()
                                .frame(width: 30, height: 40)
                                .padding(.trailing, 5)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Daily Weigh-In:")
                                        .font(.headline)
                                        .foregroundColor(Styles.primaryText)
                                    Spacer()
                                    if weighIns.count == 1, let latestWeighIn = weighIns.last {
                                        Text("\(latestWeighIn.weight) \(userProfile?.useMetric ?? false ? "kg" : "lbs")")
                                            .font(.subheadline)
                                            .foregroundColor(Styles.secondaryText)
                                    } else if weighIns.count > 1 {
                                        Button(action: { withAnimation { isWeighInExpanded.toggle() } }) {
                                            HStack {
                                                Text("\(averageWeight()) \(userProfile?.useMetric ?? false ? "kg" : "lbs")")
                                                    .font(.subheadline)
                                                    .foregroundColor(Styles.secondaryText)
                                                Image(systemName: "chevron.down")
                                                    .rotationEffect(.degrees(isWeighInExpanded ? 180 : 0))
                                                    .foregroundColor(Styles.secondaryText)
                                            }
                                        }
                                    } else {
                                        Text("\(averageWeight()) \(userProfile?.useMetric ?? false ? "kg" : "lbs")")
                                            .font(.subheadline)
                                            .foregroundColor(Styles.secondaryText)
                                    }
                                }
                            }
                        }
                        if isWeighInExpanded && weighIns.count > 1 {
                            VStack(spacing: 0) {
                                ForEach(Array(weighIns.enumerated()), id: \.element.id) { index, entry in
                                    HStack {
                                        Text(entry.time)
                                            .font(.subheadline)
                                            .foregroundColor(Styles.secondaryText)
                                            .frame(width: 80, alignment: .leading)
                                        Text("\(entry.weight) \(userProfile?.useMetric ?? false ? "kg" : "lbs")")
                                            .font(.subheadline)
                                            .foregroundColor(Styles.primaryText)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .padding()
                                    .background(index % 2 == 0 ? Styles.secondaryBackground : Styles.tertiaryBackground)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                    .disabled(true)
                }
                .padding(15)
                .background(Styles.secondaryBackground)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                
                DiaryView(diaryEntries: $diaryEntries)
                    .disabled(true)
            }
        }
        .onAppear {
            loadDailyRecord()
        }
    }
    
    private func loadDailyRecord() {
        diaryEntries = (record.diaryEntries as? Set<CoreDiaryEntry>)?.map { entity in
            DiaryEntry(
                time: entity.time ?? "",
                iconName: entity.iconName ?? "",
                description: entity.entryDescription ?? "",
                detail: entity.detail ?? "",
                calories: Int(entity.calories),
                type: entity.type ?? "",
                imageName: entity.imageName,
                imageData: entity.imageData,
                fats: entity.fats,
                carbs: entity.carbs,
                protein: entity.protein
            )
        } ?? []
        waterGoal = CGFloat(record.waterGoal)
        selectedUnit = record.waterUnit ?? "fl oz"
        if record.weighIn > 0 {
            weighIns = [WeighIn(time: formattedCurrentTime(), weight: String(format: "%.1f", record.weighIn))]
        }
        print("DEBUG: Loaded past day - Date: \(formattedDate(selectedDate)), Entries: \(diaryEntries.count)")
    }
    
    private func formattedCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}

struct PastDayRow: View {
    let record: DailyRecord
    let userProfile: UserProfile?
    let dayNumber: Int
    
    private var formattedDate: String {
        guard let date = record.date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var weighIn: String {
        return record.weighIn > 0 ? String(format: "%.1f %@", record.weighIn, userProfile?.useMetric ?? false ? "kg" : "lbs") : "N/A"
    }
    
    private var waterText: String {
        let intake = String(format: "%.1f", record.waterIntake)
        let goal = String(format: "%.1f", record.waterGoal)
        let unit = record.waterUnit ?? "fl oz"
        return record.waterGoal > 0 ? "\(intake)/\(goal) \(unit)" : "\(intake) \(unit)"
    }
    
    private var waterTextColor: Color {
        if record.waterGoal > 0 {
            return record.waterIntake >= record.waterGoal ? .green : .red
        }
        return Styles.primaryText
    }
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Day \(dayNumber)")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
            }
            .frame(width: 100, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Calories: \(Int(record.calorieIntake))/\(Int(record.calorieGoal))")
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
                Text("Water: \(waterText)")
                    .font(.subheadline)
                    .foregroundColor(waterTextColor)
                Text("Weigh-In: \(weighIn)")
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
            }
            
            Spacer()
            
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
