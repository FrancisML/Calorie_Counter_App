//
//  PastLedgerView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/13/25.
//

import SwiftUI
import CoreData

struct PastLedgerView: View {
    @FetchRequest(
        entity: DailyProgress.entity(),
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
    ) var dailyProgresses: FetchedResults<DailyProgress>
    
    @State private var selectedProgress: DailyProgress? = nil

    var body: some View {
        NavigationView {
            VStack {
                if dailyProgresses.isEmpty {
                    Text("No past records yet.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(dailyProgresses) { progress in
                            Button(action: {
                                selectedProgress = progress
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Day \(progress.dayNumber)")
                                            .font(.headline)
                                        Text(progress.date?.formatted() ?? "Unknown Date")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("\(progress.calorieIntake) / \(progress.dailyLimit) cal")
                                        .font(.subheadline)
                                    Text(progress.passOrFail ?? "Fail")
                                        .font(.subheadline)
                                        .foregroundColor(progress.passOrFail == "Pass" ? .green : .red)
                                        .bold()
                                }
                            }
                            .listRowBackground(progress.passOrFail == "Pass" ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Past Ledgers")
            .sheet(item: $selectedProgress) { progress in
                PastDailyLedgerView(dailyProgress: progress)
            }
        }
    }
}




