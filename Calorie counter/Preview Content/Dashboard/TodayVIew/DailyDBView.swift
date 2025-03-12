// DailyDBView.swift
// Calorie counter
//
// Created by frank lasalvia on 2/12/25.
//

import SwiftUI
import CoreData

struct DailyDBView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date
    @Binding var diaryEntries: [DiaryEntry]
    var highestStreak: Int32
    var calorieGoal: CGFloat // Legacy, replaced by DailyRecord.calorieGoal
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
                return startOfSelectedDate > startOfStartDate
            }
        } catch {
            print("❌ Error fetching startDate: \(error.localizedDescription)")
            return false
        }
        return false
    }

    private var canGoForward: Bool {
        let startOfSimulatedCurrent = Calendar.current.startOfDay(for: simulatedCurrentDate)
        let startOfSelectedDate = Calendar.current.startOfDay(for: selectedDate)
        return startOfSelectedDate < startOfSimulatedCurrent
    }

    private func saveOrUpdateDailyRecord() {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: selectedDate) as NSDate)
        fetchRequest.fetchLimit = 1
        
        let dailyRecord: DailyRecord
        var isNewRecord = false
        do {
            if let existingRecord = try viewContext.fetch(fetchRequest).first {
                dailyRecord = existingRecord
                print("DEBUG: Updating existing DailyRecord for \(formattedDate(selectedDate))")
            } else {
                dailyRecord = DailyRecord(context: viewContext)
                dailyRecord.date = Calendar.current.startOfDay(for: selectedDate)
                dailyRecord.weighIn = 0
                isNewRecord = true
                // Set waterGoal from previous day for new records
                if isCurrentDay, let previousWaterGoal = fetchPreviousDayWaterGoal() {
                    dailyRecord.waterGoal = Double(previousWaterGoal)
                    waterGoal = previousWaterGoal // Update state for UI
                    print("DEBUG: Set waterGoal to \(previousWaterGoal) from previous day for new record")
                }
                print("DEBUG: Created new DailyRecord for \(formattedDate(selectedDate)) with weighIn = 0")
            }
        } catch {
            print("❌ Error fetching DailyRecord: \(error.localizedDescription)")
            return
        }

        // Fetch UserProfile
        let userFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        userFetch.fetchLimit = 1
        guard let userProfile = try? viewContext.fetch(userFetch).first else {
            print("❌ Error: No UserProfile found")
            return
        }

        // Only calculate calorie goal for new records on the current day
        if isCurrentDay && isNewRecord {
            // Check if it's the user's birthday and update age
            if let birthdate = userProfile.birthdate {
                let calendar = Calendar.current
                let todayComponents = calendar.dateComponents([.month, .day], from: selectedDate)
                let birthComponents = calendar.dateComponents([.month, .day], from: birthdate)
                if todayComponents.month == birthComponents.month && todayComponents.day == birthComponents.day {
                    let ageComponents = calendar.dateComponents([.year], from: birthdate, to: selectedDate)
                    let newAge = Int32(ageComponents.year ?? 0)
                    if newAge != userProfile.age {
                        userProfile.age = newAge
                        print("DEBUG: Updated user age to \(newAge) on birthday")
                    }
                }
            }

            // Use previous day's weigh-in to set currentWeight for BMR calculation
            let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
            let prevFetch: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            prevFetch.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: previousDay) as NSDate)
            prevFetch.fetchLimit = 1
            if let prevRecord = try? viewContext.fetch(prevFetch).first, prevRecord.weighIn > 0 {
                if prevRecord.weighIn != userProfile.currentWeight {
                    userProfile.currentWeight = prevRecord.weighIn
                    print("DEBUG: Set UserProfile.currentWeight to \(prevRecord.weighIn) from previous day's weigh-in for new day")
                }
            }

            // Recalculate BMR with updated weight and age
            let newBMR = calculateBMR(
                weight: userProfile.currentWeight,
                heightCm: userProfile.heightCm,
                heightFt: userProfile.heightFt,
                heightIn: userProfile.heightIn,
                age: userProfile.age,
                gender: userProfile.gender ?? "",
                activityInt: userProfile.activityInt,
                useMetric: userProfile.useMetric
            )
            if newBMR != userProfile.userBMR {
                userProfile.userBMR = newBMR
                print("DEBUG: Recalculated BMR to \(newBMR) for new day")
            }

            // Update weightDifference based on currentWeight and goalWeight
            if userProfile.goalWeight > 0 {
                userProfile.weightDifference = abs(userProfile.currentWeight - userProfile.goalWeight)
                print("DEBUG: Updated weightDifference to \(userProfile.weightDifference) for new day")
            }

            // Set calorie goal for the new day
            updateDailyCalorieGoal(userProfile: userProfile)
            dailyRecord.calorieGoal = Double(userProfile.dailyCalorieGoal)
            print("DEBUG: Locked in DailyRecord.calorieGoal to \(dailyRecord.calorieGoal) for new day")
        }

        // Update weighIns for current day
        if isCurrentDay {
            // Clear existing weighIns to avoid duplicates
            if let existingWeighIns = dailyRecord.weighIns as? Set<WeighInEntry> {
                existingWeighIns.forEach { viewContext.delete($0) }
            }
            
            // Save new weighIns
            for weighIn in weighIns {
                let weighInEntry = WeighInEntry(context: viewContext)
                weighInEntry.time = weighIn.time
                weighInEntry.weight = Double(weighIn.weight) ?? 0.0
                weighInEntry.dailyRecord = dailyRecord
                dailyRecord.addToWeighIns(weighInEntry)
                print("DEBUG: Saved WeighInEntry - Time: \(weighIn.time), Weight: \(weighIn.weight)")
            }

            // Update average weighIn and currentWeight
            if !weighIns.isEmpty {
                let avgWeightString = averageWeight()
                if let avgWeight = Double(avgWeightString) {
                    dailyRecord.weighIn = avgWeight
                    userProfile.currentWeight = avgWeight // Update currentWeight, affects next day
                    print("DEBUG: Updated weighIn to \(avgWeight) and UserProfile.currentWeight to \(avgWeight) for current day (calorie goal unchanged)")
                }
            }
        }

        // Update other DailyRecord fields
        dailyRecord.calorieIntake = totalCalories
        dailyRecord.waterIntake = Double(totalDailyWater)
        dailyRecord.waterUnit = selectedUnit
        dailyRecord.waterGoal = Double(waterGoal) // Persist waterGoal
        dailyRecord.passFail = totalCalories <= dailyRecord.calorieGoal

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
            }
        }

        if isCurrentDay {
            let currentStreak = Int32(calculateStreak())
            if currentStreak > userProfile.highStreak {
                userProfile.highStreak = currentStreak
                print("DEBUG: Updated highStreak to \(currentStreak)")
            }
        }

        do {
            try viewContext.save()
            print("✅ Saved/Updated DailyRecord for \(formattedDate(selectedDate)) with waterGoal: \(dailyRecord.waterGoal)")
        } catch {
            print("❌ Error saving DailyRecord: \(error.localizedDescription)")
        }
    }

    private func loadDailyRecord(for date: Date) {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: date) as NSDate)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["diaryEntries", "weighIns"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let records = try viewContext.fetch(fetchRequest)
            if let record = records.first(where: { (($0.diaryEntries as? Set<CoreDiaryEntry>)?.count ?? 0) > 0 || (($0.weighIns as? Set<WeighInEntry>)?.count ?? 0) > 0 }) ?? records.first {
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
                
                // Load weighIns for current day only
                if isCurrentDay {
                    let loadedWeighIns = (record.weighIns as? Set<WeighInEntry>)?.map { entity in
                        WeighIn(time: entity.time ?? formattedCurrentTime(), weight: String(entity.weight))
                    } ?? []
                    weighIns = loadedWeighIns
                    print("DEBUG: Loaded \(loadedWeighIns.count) weighIns for current day")
                } else {
                    weighIns = []
                }
                
                waterGoal = CGFloat(record.waterGoal)
                selectedUnit = record.waterUnit ?? "fl oz"
                print("DEBUG: Loaded waterGoal: \(waterGoal) and unit: \(selectedUnit) for \(formattedDate(date))")
            } else {
                resetDailyData()
                if isCurrentDay {
                    if let previousWaterGoal = fetchPreviousDayWaterGoal() {
                        waterGoal = previousWaterGoal
                        print("DEBUG: No record found, set waterGoal to \(waterGoal) from previous day")
                    }
                    saveOrUpdateDailyRecord() // Save with previous day's waterGoal
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
        if isCurrentDay {
            if let previousWaterGoal = fetchPreviousDayWaterGoal() {
                waterGoal = previousWaterGoal
            } else {
                waterGoal = 0
            }
        } else {
            waterGoal = 0
        }
        print("DEBUG: Reset waterGoal to \(waterGoal) for \(formattedDate(selectedDate))")
    }

    private func simulateDayPassing() {
        saveOrUpdateDailyRecord()
        simulatedCurrentDate = Calendar.current.date(byAdding: .day, value: 1, to: simulatedCurrentDate) ?? simulatedCurrentDate
        UserDefaults.standard.set(simulatedCurrentDate, forKey: "simulatedCurrentDate")
        selectedDate = simulatedCurrentDate
        resetDailyData()
        saveOrUpdateDailyRecord()
        loadDailyRecord(for: selectedDate)
        updateActivityStreaks() // Add this
        simulateDayTrigger.toggle()
    }

    private func updateActivityStreaks() {
        let currentStreak = calculateActivityStreak()
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            if let userProfile = try viewContext.fetch(fetchRequest).first {
                if currentStreak > userProfile.highestActivityStreak {
                    userProfile.highestActivityStreak = Int32(currentStreak)
                    try viewContext.save()
                    print("✅ Updated highestActivityStreak to \(currentStreak)")
                }
            }
        } catch {
            print("❌ Error updating streaks: \(error)")
        }
    }

    private func calculateActivityStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: simulatedCurrentDate)
        
        while true {
            let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date == %@", currentDate as NSDate)
            fetchRequest.fetchLimit = 1
            do {
                if let record = try viewContext.fetch(fetchRequest).first,
                   let workouts = record.workoutEntries as? Set<WorkoutEntry>,
                   !workouts.isEmpty {
                    streak += 1
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    break
                }
            } catch {
                print("❌ Error calculating streak: \(error)")
                break
            }
        }
        return streak
    }

    // New helper to fetch previous day's water goal
    private func fetchPreviousDayWaterGoal() -> CGFloat? {
        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: previousDay) as NSDate)
        fetchRequest.fetchLimit = 1
        do {
            if let previousRecord = try viewContext.fetch(fetchRequest).first, previousRecord.waterGoal > 0 {
                return CGFloat(previousRecord.waterGoal)
            }
        } catch {
            print("❌ Error fetching previous day's water goal: \(error.localizedDescription)")
        }
        return nil
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
        if isCurrentDay {
            guard !weighIns.isEmpty else { return "0" }
            let totalWeight = weighIns.compactMap { Double($0.weight) }.reduce(0, +)
            return String(format: "%.1f", totalWeight / Double(weighIns.count))
        } else {
            let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: selectedDate) as NSDate)
            fetchRequest.fetchLimit = 1
            do {
                if let record = try viewContext.fetch(fetchRequest).first {
                    return record.weighIn > 0 ? String(format: "%.1f", record.weighIn) : "none"
                }
            } catch {
                print("❌ Error fetching weighIn: \(error.localizedDescription)")
            }
            return "none"
        }
    }

    // MARK: - Helper Functions

    private func calculateBMR(weight: Double, heightCm: Int32, heightFt: Int32, heightIn: Int32, age: Int32, gender: String, activityInt: Int32, useMetric: Bool) -> Int32 {
        var bmr: Double = 0.0
        
        let weightKg = useMetric ? weight : weight * 0.453592
        let heightCmDouble: Double
        if useMetric {
            heightCmDouble = Double(heightCm)
        } else {
            heightCmDouble = Double(heightFt * 12 + heightIn) * 2.54
        }
        
        if gender.lowercased() == "man" {
            bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCmDouble) - (5.677 * Double(age))
        } else if gender.lowercased() == "woman" {
            bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCmDouble) - (4.330 * Double(age))
        } else {
            bmr = (88.362 + (13.397 * weightKg) + (4.799 * heightCmDouble) - (5.677 * Double(age)) + 447.593 + (9.247 * weightKg) + (3.098 * heightCmDouble) - (4.330 * Double(age))) / 2
        }
        
        let activityMultipliers: [Double] = [1.2, 1.375, 1.55, 1.725, 1.9]
        let activityIndex = min(max(Int(activityInt), 0), activityMultipliers.count - 1)
        bmr *= activityMultipliers[activityIndex]
        
        return Int32(bmr.rounded())
    }

    private func updateDailyCalorieGoal(userProfile: UserProfile) {
        let calorieFactor: Double = useMetric ? 7000.0 : 3500.0
        userProfile.dailyCalorieDif = Int32((calorieFactor * userProfile.weekGoal) / 7)
        
        var newCalorieGoal: Int32 = userProfile.userBMR
        switch userProfile.goalId {
        case 1:
            let absCalorieDif = abs(userProfile.dailyCalorieDif)
            newCalorieGoal = userProfile.weekGoal < 0 ? userProfile.userBMR - absCalorieDif : userProfile.userBMR + absCalorieDif
            
        case 2:
            if userProfile.goalWeight > 0 {
                let absCalorieDif = abs(userProfile.dailyCalorieDif)
                newCalorieGoal = userProfile.weekGoal < 0 ? userProfile.userBMR - absCalorieDif : userProfile.userBMR + absCalorieDif
            } else {
                newCalorieGoal = userProfile.userBMR
            }
            
        case 3:
            if let targetDate = userProfile.targetDate, userProfile.goalWeight > 0 {
                let daysUntilTarget = Calendar.current.dateComponents([.day], from: selectedDate, to: targetDate).day ?? 0
                if daysUntilTarget > 0 {
                    let totalCalorieAdjustment = (userProfile.weightDifference * calorieFactor) / Double(daysUntilTarget)
                    newCalorieGoal = userProfile.weekGoal < 0 ? userProfile.userBMR - Int32(totalCalorieAdjustment) : userProfile.userBMR + Int32(totalCalorieAdjustment)
                } else {
                    newCalorieGoal = userProfile.userBMR
                }
            } else {
                newCalorieGoal = userProfile.userBMR
            }
            
        case 4:
            newCalorieGoal = userProfile.userBMR
            
        case 5:
            newCalorieGoal = userProfile.customCals
            
        default:
            newCalorieGoal = userProfile.userBMR
        }
        
        if newCalorieGoal != userProfile.dailyCalorieGoal {
            userProfile.dailyCalorieGoal = newCalorieGoal
            print("DEBUG: Updated UserProfile.dailyCalorieGoal to \(newCalorieGoal) for new day")
        }
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
                    .renderingMode(.template)
                    .foregroundColor(Styles.primaryText)
                    .scaledToFit()
                    .frame(width: 30, height: 40)
                    .padding(.trailing, 5)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Calories")
                            .font(.headline)
                            .foregroundColor(totalCalories > getCalorieGoalForSelectedDate() ? .red : Styles.primaryText)
                        Spacer()
                        Text("\(Int(totalCalories))/\(Int(getCalorieGoalForSelectedDate()))")
                            .font(.subheadline)
                            .foregroundColor(totalCalories > getCalorieGoalForSelectedDate() ? .red : Styles.secondaryText)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Styles.primaryText.opacity(0.2))
                                .frame(height: 20)
                            
                            HStack(spacing: 0) {
                                if totalCalories > 0 {
                                    let progressWidth = min(CGFloat(totalCalories / getCalorieGoalForSelectedDate()) * geometry.size.width, geometry.size.width)
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
                        .renderingMode(.template)
                        .foregroundColor(Styles.primaryText)
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                        .padding(.trailing, 5)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(isCurrentDay ? "Daily Weigh-In:" : "Daily Weight:")
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

    private func getCalorieGoalForSelectedDate() -> Double {
        let fetchRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", Calendar.current.startOfDay(for: selectedDate) as NSDate)
        fetchRequest.fetchLimit = 1
        do {
            if let record = try viewContext.fetch(fetchRequest).first {
                return record.calorieGoal
            }
        } catch {
            print("❌ Error fetching calorieGoal for \(formattedDate(selectedDate)): \(error.localizedDescription)")
        }
        if isCurrentDay {
            let userFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userFetch.fetchLimit = 1
            if let userProfile = try? viewContext.fetch(userFetch).first {
                return Double(userProfile.dailyCalorieGoal)
            }
        }
        return Double(calorieGoal)
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
        let weighInFetch: NSFetchRequest<WeighInEntry> = WeighInEntry.fetchRequest()
        do {
            let dailyRecords = try viewContext.fetch(dailyFetch)
            print("DEBUG: Total DailyRecords: \(dailyRecords.count)")
            dailyRecords.forEach { record in
                let entryCount = (record.diaryEntries as? Set<CoreDiaryEntry>)?.count ?? 0
                let weighInCount = (record.weighIns as? Set<WeighInEntry>)?.count ?? 0
                print("DailyRecord - Date: \(record.date ?? Date()), Entries: \(entryCount), WeighIns: \(weighInCount), Calorie Goal: \(record.calorieGoal), WeighIn: \(record.weighIn)")
            }
            let diaryEntries = try viewContext.fetch(diaryFetch)
            print("DEBUG: Total CoreDiaryEntries: \(diaryEntries.count)")
            diaryEntries.forEach { entry in
                print("CoreDiaryEntry - Description: \(entry.entryDescription ?? "nil"), DailyRecord: \(entry.dailyRecord?.date ?? Date())")
            }
            let weighIns = try viewContext.fetch(weighInFetch)
            print("DEBUG: Total WeighInEntries: \(weighIns.count)")
            weighIns.forEach { weighIn in
                print("WeighInEntry - Time: \(weighIn.time ?? "nil"), Weight: \(weighIn.weight), DailyRecord: \(weighIn.dailyRecord?.date ?? Date())")
            }
        } catch {
            print("❌ Error dumping Core Data: \(error)")
        }
    }
}

// Preview (optional, for development)

