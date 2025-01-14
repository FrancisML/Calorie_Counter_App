//
//  PastDailyLedgerView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/13/25.
//

import SwiftUI

struct PastDailyLedgerView: View {
    let dailyProgress: DailyProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Day and Date Header
            Text("Day \(dailyProgress.dayNumber)")
                .font(.largeTitle)
                .bold()
            Text(dailyProgress.date?.formatted() ?? "Unknown Date")
                .font(.headline)
                .foregroundColor(.gray)

            Divider()

            // Summary Section
            Text("Summary")
                .font(.title2)
                .bold()

            HStack {
                Text("Calorie Intake:")
                Spacer()
                Text("\(dailyProgress.calorieIntake) / \(dailyProgress.dailyLimit) cal")
                    .foregroundColor(dailyProgress.calorieIntake <= dailyProgress.dailyLimit ? .green : .red)
            }

            HStack {
                Text("Status:")
                Spacer()
                Text(dailyProgress.passOrFail ?? "Unknown")
                    .foregroundColor(dailyProgress.passOrFail == "Pass" ? .green : .red)
                    .bold()
            }

            Divider()

            // Ledger Section
            Text("Ledger")
                .font(.title2)
                .bold()

            if let ledgerSet = dailyProgress.ledgerEntries {
                let ledgerEntries = Array(ledgerSet) as? [LedgerEntry] ?? []

                if ledgerEntries.isEmpty {
                    Text("No entries for this day.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(ledgerEntries, id: \ .self) { entry in
                                LedgerRow(entry: entry)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct LedgerRow: View {
    let entry: LedgerEntry

    var body: some View {
        HStack {
            Text(entry.type ?? "Unknown")
                .foregroundColor(entry.type == "Workout" ? .red : .green)
                .frame(width: 80, alignment: .leading)

            Text(entry.name ?? "Unnamed")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(entry.calories)")
                .foregroundColor(entry.type == "Workout" ? .red : .green)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 5)
    }
}



