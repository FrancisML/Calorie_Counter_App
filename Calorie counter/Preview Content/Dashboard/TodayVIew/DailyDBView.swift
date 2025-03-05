//
//  DailyDBView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/12/25.
//

import SwiftUI
import CoreData

struct DailyDBView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date
    @Binding var diaryEntries: [DiaryEntry]
    var highestStreak: Int32
    var calorieGoal: CGFloat
    var useMetric: Bool
    @Binding var weighIns: [WeighIn]
    @State private var isWaterPickerPresented: Bool = false
    @State private var waterGoal: CGFloat = 0
    @State private var selectedUnit: String = "fl oz"
    @State private var isWeighInExpanded: Bool = false
    
    @State private var simulatedCurrentDate: Date = {
        if let savedDate = UserDefaults.standard.object(forKey: "simulatedCurrentDate") as? Date {
            return Calendar.current.startOfDay(for: savedDate)
        }
        return Calendar.current.startOfDay(for: Date())
    }()
    @State private var simulateDayTrigger: Bool = false

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

    private var isCurrentDay: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: simulatedCurrentDate)
    }

    private var canGoBack: Bool {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first, let startDate = userProfile.startDate {
                let startOfStartDate = Calendar.current.startOfDay(for: startDate)
                let startOfSelectedDate = Calendar.current.startOfDay(for: selectedDate)
                print("DEBUG: canGoBack - startDate: \(startOfStartDate), selectedDate: \(startOfSelectedDate), result: \(startOfSelectedDate > startOfStartDate)")
                return startOfSelectedDate > startOfStartDate
            } else {
                print("DEBUG: No UserProfile or startDate found")
                return false
            }
        } catch {
            print("❌ Error fetching startDate: \(error.localizedDescription)")
            return false
        }
    }

    private var canGoForward: Bool {
        let startOfSimulatedCurrent = Calendar.current.startOfDay(for: simulatedCurrentDate)
        let startOfSelectedDate = Calendar.current.startOfDay(for: selectedDate)
        print("DEBUG: canGoForward - simulatedCurrent: \(startOfSimulatedCurrent), selectedDate: \(startOfSelectedDate), result: \(startOfSelectedDate < startOfSimulatedCurrent)")
        return startOfSelectedDate < startOfSimulatedCurrent
    }

    private func saveOrUpdateDailyRecord() {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: selectedDate) as NSDate)
        fetchRequest.fetchLimit = 1
        
        let dailyRecord: DailyRecord
        do {
            if let existingRecord = try viewContext.fetch(fetchRequest).first {
                dailyRecord = existingRecord
                print("DEBUG: Updating existing DailyRecord for \(formattedDate(selectedDate))")
            } else {
                dailyRecord = DailyRecord(context: viewContext)
                dailyRecord.date = Calendar.current.startOfDay(for: selectedDate)
                print("DEBUG: Created new DailyRecord for \(formattedDate(selectedDate))")
            }
        } catch {
            print("❌ Error fetching DailyRecord: \(error.localizedDescription)")
            return
        }

        dailyRecord.calorieIntake = totalCalories
        dailyRecord.waterIntake = Double(totalDailyWater)
        dailyRecord.waterUnit = selectedUnit
        dailyRecord.passFail = totalCalories <= Double(calorieGoal)
        dailyRecord.waterGoal = Double(waterGoal)
        dailyRecord.calorieGoal = Double(calorieGoal)

        let avgWeightString = averageWeight()
        if let avgWeight = Double(avgWeightString) {
            dailyRecord.weighIn = avgWeight
        } else {
            dailyRecord.weighIn = 0.0
            print("DEBUG: Failed to convert averageWeight '\(avgWeightString)' to Double")
        }

        for entry in diaryEntries {
            let entryFetch: NSFetchRequest<CoreDiaryEntry> = CoreDiaryEntry.fetchRequest()
            entryFetch.predicate = NSPredicate(format: "entryDescription == %@ AND time == %@ AND dailyRecord == %@", entry.description, entry.time, dailyRecord)
            entryFetch.fetchLimit = 1
            
            if let existingEntry = try? viewContext.fetch(entryFetch).first {
                existingEntry.detail = entry.detail
                existingEntry.calories = Int32(entry.calories)
                existingEntry.fats = entry.fats
                existingEntry.carbs = entry.carbs
                existingEntry.protein = entry.protein
                print("DEBUG: Updated entry - Description: \(entry.description), Calories: \(entry.calories)")
            } else {
                let diaryEntity = CoreDiaryEntry(context: viewContext)
                diaryEntity.time = entry.time
                diaryEntity.iconName = entry.iconName
                diaryEntity.entryDescription = entry.description
                diaryEntity.detail = entry.detail
                diaryEntity.calories = Int32(entry.calories)
                diaryEntity.type = entry.type
                diaryEntity.imageName = entry.imageName
                diaryEntity.imageData = entry.imageData
                diaryEntity.fats = entry.fats
                diaryEntity.carbs = entry.carbs
                diaryEntity.protein = entry.protein
                diaryEntity.dailyRecord = dailyRecord
                dailyRecord.addToDiaryEntries(diaryEntity)
                print("DEBUG: Saving entry - Description: \(entry.description), Calories: \(entry.calories)")
            }
        }

        if isCurrentDay {
            let currentStreak = Int32(calculateStreak())
            let userFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userFetch.fetchLimit = 1
            do {
                if let userProfile = try viewContext.fetch(userFetch).first {
                    if currentStreak > userProfile.highStreak {
                        userProfile.highStreak = currentStreak
                        print("DEBUG: Updated highStreak to \(currentStreak)")
                    }
                }
            } catch {
                print("❌ Error updating highStreak: \(error.localizedDescription)")
            }
        }

        do {
            try viewContext.save()
            print("✅ Saved/Updated DailyRecord for \(formattedDate(selectedDate)) with \(diaryEntries.count) entries")
        } catch {
            print("❌ Error saving DailyRecord: \(error.localizedDescription)")
        }
    }

    private func loadDailyRecord(for date: Date) {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: date) as NSDate)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["diaryEntries"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let records = try viewContext.fetch(fetchRequest)
            if let record = records.first(where: { (($0.diaryEntries as? Set<CoreDiaryEntry>)?.count ?? 0) > 0 }) ?? records.first {
                let loadedEntries = (record.diaryEntries as? Set<CoreDiaryEntry>)?.map { entity in
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
                diaryEntries = loadedEntries
                waterGoal = CGFloat(record.waterGoal)
                if Calendar.current.isDate(date, inSameDayAs: simulatedCurrentDate) {
                    let userFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
                    userFetch.fetchLimit = 1
                    if let userProfile = try viewContext.fetch(userFetch).first {
                        if weighIns.isEmpty && userProfile.currentWeight > 0 {
                            weighIns = [WeighIn(time: formattedCurrentTime(), weight: "\(userProfile.currentWeight)")]
                        }
                        waterGoal = CGFloat(userProfile.waterGoal)
                    }
                } else {
                    weighIns = []
                }
                print("DEBUG: Loaded data for \(formattedDate(date)) - Entries: \(diaryEntries.count), Calorie Goal: \(record.calorieGoal)")
                let rawCount = (record.diaryEntries as? Set<CoreDiaryEntry>)?.count ?? 0
                print("DEBUG: Raw Core Data diaryEntries count: \(rawCount)")
                if rawCount > 0 {
                    (record.diaryEntries as? Set<CoreDiaryEntry>)?.forEach { entry in
                        print("DEBUG: Loaded CoreDiaryEntry - Description: \(entry.entryDescription ?? "nil"), Calories: \(entry.calories)")
                    }
                }
                if records.count > 1 {
                    print("WARNING: Multiple DailyRecords found for \(formattedDate(date)): \(records.count)")
                }
            } else {
                resetDailyData()
                if isCurrentDay {
                    saveOrUpdateDailyRecord()
                }
                print("DEBUG: No record found for \(formattedDate(date)), resetting")
            }
        } catch {
            print("❌ Error loading DailyRecord: \(error.localizedDescription)")
            resetDailyData()
        }
    }

    private func resetDailyData() {
        weighIns = []
        diaryEntries = []
        if Calendar.current.isDate(selectedDate, inSameDayAs: simulatedCurrentDate) {
            let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            fetchRequest.fetchLimit = 1
            do {
                if let userProfile = try viewContext.fetch(fetchRequest).first {
                    waterGoal = CGFloat(userProfile.waterGoal)
                }
            } catch {
                print("❌ Error fetching UserProfile: \(error.localizedDescription)")
            }
        } else {
            waterGoal = 0
        }
    }

    private func simulateDayPassing() {
        saveOrUpdateDailyRecord()
        simulatedCurrentDate = Calendar.current.date(byAdding: .day, value: 1, to: simulatedCurrentDate) ?? simulatedCurrentDate
        UserDefaults.standard.set(simulatedCurrentDate, forKey: "simulatedCurrentDate")
        selectedDate = simulatedCurrentDate
        resetDailyData()
        simulateDayTrigger.toggle()
        print("DEBUG: Simulated day - New current: \(formattedDate(simulatedCurrentDate))")
    }

    private func dayTitle() -> String {
        let today = Calendar.current.startOfDay(for: simulatedCurrentDate)
        if Calendar.current.isDate(selectedDate, inSameDayAs: today) {
            return "Today"
        } else if Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: today)!) {
            return "Yesterday"
        } else {
            let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            do {
                let records = try viewContext.fetch(fetchRequest)
                if let index = records.firstIndex(where: { Calendar.current.isDate($0.date ?? Date.distantFuture, inSameDayAs: selectedDate) }) {
                    return "Day \(index + 1)"
                }
            } catch {
                print("❌ Error fetching records for dayTitle: \(error.localizedDescription)")
            }
            return "Day X"
        }
    }

    private func streakOrPassFail() -> (String, Color) {
        if isCurrentDay {
            let streak = calculateStreak()
            return ("Streak: \(streak)", Styles.primaryText)
        } else {
            let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: selectedDate) as NSDate)
            fetchRequest.fetchLimit = 1
            do {
                if let record = try viewContext.fetch(fetchRequest).first {
                    return record.passFail ? ("UNDER", .green) : ("OVER", .red)
                }
            } catch {
                print("❌ Error fetching passFail: \(error.localizedDescription)")
            }
            return ("OVER", .red)
        }
    }

    private func calculateStreak() -> Int {
        let today = Calendar.current.startOfDay(for: simulatedCurrentDate)
        var streak = 0
        var currentDate = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        
        while true {
            let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date == %@", currentDate as NSDate)
            fetchRequest.fetchLimit = 1
            do {
                if let record = try viewContext.fetch(fetchRequest).first {
                    if record.passFail {
                        streak += 1
                        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
                    } else {
                        break
                    }
                } else {
                    break
                }
            } catch {
                print("❌ Error calculating streak: \(error.localizedDescription)")
                break
            }
        }
        return streak
    }

    private func averageWeight() -> String {
        guard !weighIns.isEmpty else { return isCurrentDay ? "0" : "none" }
        let totalWeight = weighIns.compactMap { Double($0.weight) }.reduce(0, +)
        return String(format: "%.1f", totalWeight / Double(weighIns.count))
    }

    // MARK: - Refactored Body Components

    private func headerView() -> some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                loadDailyRecord(for: selectedDate)
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(canGoBack ? Styles.primaryText : Styles.secondaryText.opacity(0.5))
            }
            .disabled(!canGoBack)
            
            Spacer()
            
            VStack {
                Text(dayTitle())
                    .font(.headline)
                    .foregroundColor(Styles.secondaryText)
                Text(formattedDate(selectedDate))
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
            }
            
            Spacer()
            
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                loadDailyRecord(for: selectedDate)
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(canGoForward ? Styles.primaryText : Styles.secondaryText.opacity(0.5))
            }
            .disabled(!canGoForward)
            
            Spacer()
            
            HStack {
                if isCurrentDay {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                }
                let (text, color) = streakOrPassFail()
                Text(text)
                    .font(.headline)
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Styles.secondaryBackground)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
        .zIndex(1)
    }

    private func mainContentView() -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 10) {
                Image("bolt")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 40)
                    .padding(.trailing, 5)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Calories")
                            .font(.headline)
                            .foregroundColor(totalCalories > Double(calorieGoal) ? .red : Styles.primaryText)
                        Spacer()
                        Text("\(Int(totalCalories))/\(Int(calorieGoal))")
                            .font(.subheadline)
                            .foregroundColor(totalCalories > Double(calorieGoal) ? .red : Styles.secondaryText)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Styles.primaryText.opacity(0.2))
                                .frame(height: 20)
                            
                            HStack(spacing: 0) {
                                if totalCalories > 0 {
                                    let progressWidth = min(CGFloat(totalCalories / Double(calorieGoal)) * geometry.size.width, geometry.size.width)
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
            .disabled(!isCurrentDay)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 10) {
                    Image("CalW")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                        .padding(.trailing, 5)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Daily Weigh-In:")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                            
                            Spacer()
                            
                            if isCurrentDay {
                                if weighIns.count == 1, let latestWeighIn = weighIns.last {
                                    Text("\(latestWeighIn.weight) \(useMetric ? "kg" : "lbs")")
                                        .font(.subheadline)
                                        .foregroundColor(Styles.secondaryText)
                                } else if weighIns.count > 1 {
                                    Button(action: { withAnimation { isWeighInExpanded.toggle() } }) {
                                        HStack {
                                            Text("\(averageWeight()) \(useMetric ? "kg" : "lbs")")
                                                .font(.subheadline)
                                                .foregroundColor(Styles.secondaryText)
                                            Image(systemName: "chevron.down")
                                                .rotationEffect(.degrees(isWeighInExpanded ? 180 : 0))
                                                .foregroundColor(Styles.secondaryText)
                                        }
                                    }
                                } else {
                                    Text("0 \(useMetric ? "kg" : "lbs")")
                                        .font(.subheadline)
                                        .foregroundColor(Styles.secondaryText)
                                }
                            } else {
                                Text("\(averageWeight()) \(useMetric ? "kg" : "lbs")")
                                    .font(.subheadline)
                                    .foregroundColor(Styles.secondaryText)
                            }
                        }
                    }
                }
                
                if isCurrentDay && isWeighInExpanded && weighIns.count > 1 {
                    VStack(spacing: 0) {
                        ForEach(Array(weighIns.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                Text(entry.time)
                                    .font(.subheadline)
                                    .foregroundColor(Styles.secondaryText)
                                    .frame(width: 80, alignment: .leading)
                                
                                Text("\(entry.weight) \(useMetric ? "kg" : "lbs")")
                                    .font(.subheadline)
                                    .foregroundColor(Styles.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Button(action: { deleteWeighIn(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding()
                            .background(index % 2 == 0 ? Styles.secondaryBackground : Styles.tertiaryBackground)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .disabled(!isCurrentDay)
        }
        .padding(15)
        .background(Styles.secondaryBackground)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
    }

    private func simulationButtonView() -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    simulateDayPassing()
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.top, 10)
                .padding(.trailing, 20)
            }
            Spacer()
        }
        .zIndex(2)
    }

    private func overlayView() -> some View {
        Group {
            if isCurrentDay && isWaterPickerPresented {
                WaterGoalPicker(
                    useMetric: useMetric,
                    selectedGoal: $waterGoal,
                    isWaterPickerPresented: $isWaterPickerPresented,
                    selectedUnit: $selectedUnit
                )
                .background(Color.clear)
                .zIndex(10)
            } else {
                EmptyView()
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView()
                mainContentView()
                DiaryView(diaryEntries: $diaryEntries)
                    .disabled(!isCurrentDay)
            }
            simulationButtonView()
        }
        .overlay(overlayView())
        .animation(nil, value: isWaterPickerPresented)
        .onAppear {
            if let savedDate = UserDefaults.standard.object(forKey: "simulatedCurrentDate") as? Date {
                simulatedCurrentDate = Calendar.current.startOfDay(for: savedDate)
            }
            selectedDate = simulatedCurrentDate
            loadDailyRecord(for: selectedDate)
            if isCurrentDay {
                saveOrUpdateDailyRecord()
            }
        }
        .onChange(of: selectedDate) { newDate in
            loadDailyRecord(for: newDate)
        }
        .onChange(of: diaryEntries) { _ in
            if isCurrentDay {
                saveOrUpdateDailyRecord()
            }
        }
        .onChange(of: weighIns) { _ in
            if isCurrentDay {
                saveOrUpdateDailyRecord()
                // Update UserProfile.currentWeight with averageWeight
                let avgWeightString = averageWeight()
                if let avgWeight = Double(avgWeightString), !weighIns.isEmpty {
                    let userFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
                    userFetch.fetchLimit = 1
                    do {
                        if let userProfile = try viewContext.fetch(userFetch).first {
                            userProfile.currentWeight = avgWeight
                            try viewContext.save()
                            print("DEBUG: Updated UserProfile.currentWeight to \(avgWeight)")
                        }
                    } catch {
                        print("❌ Error updating currentWeight: \(error.localizedDescription)")
                    }
                }
            }
        }
        .onChange(of: totalDailyWater) { _ in
            if isCurrentDay {
                saveOrUpdateDailyRecord()
            }
        }
        .id(simulateDayTrigger)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func deleteWeighIn(at index: Int) {
        withAnimation {
            if index >= 0 && index < weighIns.count {
                weighIns.remove(at: index)
            }
        }
    }

    private func formattedCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }

    private func debugDumpCoreData() {
        let dailyFetch: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        let diaryFetch: NSFetchRequest<CoreDiaryEntry> = CoreDiaryEntry.fetchRequest()
        do {
            let dailyRecords = try viewContext.fetch(dailyFetch)
            print("DEBUG: Total DailyRecords: \(dailyRecords.count)")
            dailyRecords.forEach { record in
                let entryCount = (record.diaryEntries as? Set<CoreDiaryEntry>)?.count ?? 0
                print("DailyRecord - Date: \(record.date ?? Date()), Entries: \(entryCount), Calorie Goal: \(record.calorieGoal)")
            }
            let diaryEntries = try viewContext.fetch(diaryFetch)
            print("DEBUG: Total CoreDiaryEntries: \(diaryEntries.count)")
            diaryEntries.forEach { entry in
                print("CoreDiaryEntry - Description: \(entry.entryDescription ?? "nil"), DailyRecord: \(entry.dailyRecord?.date ?? Date())")
            }
        } catch {
            print("❌ Error dumping Core Data: \(error)")
        }
    }
}
