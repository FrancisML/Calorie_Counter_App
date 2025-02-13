//
//  WeighIn.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//

import SwiftUI

struct WeighInView: View {
    var closeAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let safeAreaTopInset = geometry.safeAreaInsets.top // ✅ Get the top safe area size
            
            VStack(spacing: 0) {
                // ✅ Title Bar (Now Adjusts for Notch)
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 80)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 4)

                    Text("Weigh In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, safeAreaTopInset) // ✅ Pushes title bar below notch

                Spacer().frame(height: 20) // 🔥 Additional spacing if needed

                // ✅ Placeholder Content (Replace with actual UI)
                VStack {
                    Text("Weigh-in Content Goes Here")
                        .font(.title)
                        .foregroundColor(Styles.primaryText)
                        .padding()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ✅ Bottom Navigation Bar
                ZStack {
                    // Background Bar (Same as Dashboard)
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 96)
                        .shadow(radius: 5)

                    HStack {
                        // Red X Button (Closes View)
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "xmark")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            closeAction()
                        }

                        Spacer().frame(width: 100) // 🔥 Adjusted spacing

                        // "+" Button (Same Size & Position as Dashboard, But No Functionality)
                        ZStack {
                            Circle()
                                .fill(Styles.primaryText)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(Styles.secondaryBackground)
                        }
                    }
                    .padding(.horizontal, 30) // 🔥 Reduced padding from 40 → 30
                    .frame(maxWidth: .infinity)
                    .offset(y: -36) // Matches dashboard "+" button's position
                }
                .frame(height: 96)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground) // ✅ Sets the entire background color
            .edgesIgnoringSafeArea(.all)
        }
    }
}
