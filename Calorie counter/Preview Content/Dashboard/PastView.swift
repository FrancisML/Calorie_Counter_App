//
//  PastView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/9/25.
//

import SwiftUI

struct PastView: View {
    var body: some View {
        VStack {
            Text("Past Records")
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

