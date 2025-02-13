//
//  DiaryView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/12/25.
//

//
//  DiaryView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/10/25.
//

import SwiftUI

struct DiaryView: View {
    var diaryEntries: [DiaryEntry]

    var body: some View {
        VStack(spacing: 0) {
            // 🔹 DIARY LABEL BAR
            HStack {
                Text("Diary")
                    .font(.title2)
                    .foregroundColor(Styles.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Styles.secondaryBackground)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -3)
            .zIndex(1)

            // 🔹 DIARY ENTRIES LIST
            ScrollView {
                VStack(spacing: 0) {
                    if diaryEntries.isEmpty {
                        Text("No Entries Yet")
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ForEach(Array(diaryEntries.enumerated()), id: \.element.id) { index, entry in
                            DiaryEntryRow(entry: entry)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 15)
                                .background(index.isMultiple(of: 2) ? Styles.tertiaryBackground : Styles.secondaryBackground)
                        }
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
        }
    }
}

