//
//  SharedComponents.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

extension Color {
    static let customGray = Color(red: 0.2, green: 0.2, blue: 0.2) // RGB for #666666
}

// MARK: - Floating Text Field
struct FloatingTextField: View {
    var placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    private var borderColor: Color {
        if !text.isEmpty {
            return Color.blue
        } else if isFocused {
            return Color.blue
        } else {
            return Color.gray
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 2)

            if isFocused || !text.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.customGray)
                    )
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: isFocused || !text.isEmpty)
            }

            HStack {
                TextField(isFocused || !text.isEmpty ? "" : placeholder, text: $text)
                    .focused($isFocused)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)

                if !text.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.green)
                        .padding(.trailing, 8)
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 0)
    }
}


// MARK: - Floating Input With Action
struct FloatingInputWithAction: View {
    var placeholder: String
    var displayedText: String
    var action: () -> Void
    @Binding var hasPickedValue: Bool
    @State private var isFocused: Bool = false

    private var borderColor: Color {
        hasPickedValue ? Color.blue : Color.gray
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 2)

            // ✅ Placeholder ONLY appears if a value has been selected
            if hasPickedValue {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.customGray)
                    )
                    .padding(.horizontal, 4)
                    .offset(x: 12, y: -29)
                    .animation(.easeInOut, value: hasPickedValue)
            }

            Button(action: {
                action()
            }) {
                HStack {
                    Text(displayedText.isEmpty ? placeholder : displayedText)
                        .foregroundColor(displayedText.isEmpty ? .gray : .primary)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 0)
    }
}






// MARK: - Height Picker
struct HeightPicker: View {
    @Binding var heightFeet: Int
    @Binding var heightInches: Int
    @Binding var useMetric: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Height")
                .font(.headline)

            if useMetric {
                Picker("Height (cm)", selection: $heightFeet) {
                    ForEach(100...250, id: \.self) { cm in
                        Text("\(cm) cm").tag(cm)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            } else {
                HStack {
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(3...7, id: \.self) { feet in
                            Text("\(feet) ft").tag(feet)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())

                    Picker("Inches", selection: $heightInches) {
                        ForEach(0..<12, id: \.self) { inch in
                            Text("\(inch) in").tag(inch)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }

            Toggle("Use Metric (cm)", isOn: $useMetric)
        }
    }
}

// MARK: - Utility Function to Present Alerts
func presentAlert(alert: UIAlertController) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first,
       let rootViewController = window.rootViewController {
        rootViewController.present(alert, animated: true)
    }
}
