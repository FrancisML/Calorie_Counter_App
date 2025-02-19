//
//  AdvancedAddView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//

import SwiftUI

struct AdvancedFoodAddView: View {
    var body: some View {
        VStack {
            Text("Advanced Add Content Goes Here")
                .font(.title)
                .foregroundColor(.white)
                .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground.opacity(0.3))
    }
}
