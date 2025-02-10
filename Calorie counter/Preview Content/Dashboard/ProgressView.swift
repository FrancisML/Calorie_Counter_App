//
//  ProgressView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/9/25.
//

import SwiftUI

struct ProgressView: View {
    var body: some View {
        VStack {
            Text("Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Styles.primaryText)
                .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea()
    }
}

