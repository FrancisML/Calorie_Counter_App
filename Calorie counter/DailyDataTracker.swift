//
//  DailyDataTracker.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/16/25.
//

import SwiftUI
import Combine

class DailyDataTracker: ObservableObject {
    @Published var calorieIntake: Int = UserDefaults.standard.integer(forKey: "calorieIntake") {
        didSet {
            UserDefaults.standard.set(calorieIntake, forKey: "calorieIntake")
        }
    }
    @Published var dayNumber: Int = UserDefaults.standard.integer(forKey: "dayNumber") {
        didSet {
            UserDefaults.standard.set(dayNumber, forKey: "dayNumber")
        }
    }
    @Published var dailyLimit: Int = UserDefaults.standard.integer(forKey: "dailyLimit") {
        didSet {
            UserDefaults.standard.set(dailyLimit, forKey: "dailyLimit")
        }
    }

    func resetCalorieIntake() {
        calorieIntake = 0
    }

    func resetForNewDay() {
        calorieIntake = 0
        dayNumber += 1
    }
}




