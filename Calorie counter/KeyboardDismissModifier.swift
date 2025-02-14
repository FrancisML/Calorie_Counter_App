//
//  KeyboardDismissModifier.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//

import SwiftUI

struct KeyboardDismissModifier: ViewModifier {
    @FocusState private var isKeyboardActive: Bool

    func body(content: Content) -> some View {
        content
            .focused($isKeyboardActive)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isKeyboardActive = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .foregroundColor(Styles.accent) // ✅ Matches your app's accent color
                }
            }
            .ignoresSafeArea(.keyboard)
    }
}

// ✅ Custom Extension to Apply Modifier Easily
extension View {
    func withKeyboardDismiss() -> some View {
        self.modifier(KeyboardDismissModifier())
    }
}
