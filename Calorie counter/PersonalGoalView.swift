//
//  PersonalGoalsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

struct PersonalGoalsView: View {
    @State private var selectedGoal: Double = 0  // Tracks the selected value
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Personal Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Tell us your goal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }

            VStack(spacing: 20) {
                // **Replace placeholder with the picker**
                HorizontalWheelPicker(selectedValue: $selectedGoal)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.customGray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding(.horizontal, 0)
    }
}
