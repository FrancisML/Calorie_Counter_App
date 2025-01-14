//
//  ChangeDateView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/10/25.
//

import SwiftUI

struct ChangeDateView: View {
    @Binding var targetDate: Date
    var onChange: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)
            
            Image("calender")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
            
            Text("Choose a new goal Date?")
                .font(.title)
            
            DatePicker("", selection: $targetDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
            
            Spacer()
            
            Button(action: {
                onChange() // Call the provided closure when "Change" is pressed
            }) {
                Text("Change")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

