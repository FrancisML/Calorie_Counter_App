
//
//  BodyMeasurementView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/26/25.
//

import SwiftUI
import CoreData

struct BodyMeasurementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let userProfile: UserProfile?
    
    @State private var chest: Double = 0.0 // Now in inches
    @State private var waist: Double = 0.0
    @State private var hips: Double = 0.0
    @State private var leftArm: Double = 0.0
    @State private var rightArm: Double = 0.0
    @State private var leftThigh: Double = 0.0
    @State private var rightThigh: Double = 0.0
    
    @State private var selectedInput: String? = nil
    
    @FocusState private var focusedField: String? // Tracks which field is focused
    
    private let imageMaxWidth: CGFloat = UIScreen.main.bounds.width * 0.4
    private let inputHeight: CGFloat = 44
    private let inputSpacing: CGFloat = 10
    private let numberOfInputs: CGFloat = 7
    
    private var inputsTotalHeight: CGFloat {
        (numberOfInputs * inputHeight) + ((numberOfInputs - 1) * inputSpacing) // 368pt
    }
    
    // Bind the picker to the selected measurement
    private var selectedMeasurement: Binding<Double> {
        switch selectedInput {
        case "chest": return $chest
        case "waist": return $waist
        case "hips": return $hips
        case "leftArm": return $leftArm
        case "rightArm": return $rightArm
        case "leftThigh": return $leftThigh
        case "rightThigh": return $rightThigh
        default: return .constant(0.0) // Default to 0 when no input is selected
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 20) {
                    Text("Body Measurements")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 20) {
                            Image(currentImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: imageMaxWidth, maxHeight: inputsTotalHeight)
                                .onAppear {
                                    print("DEBUG: Initial image - \(currentImage), MaxWidth: \(imageMaxWidth), Height: \(inputsTotalHeight)")
                                }
                                .onChange(of: selectedInput) { newValue in
                                    print("DEBUG: Image changed to - \(currentImage), MaxWidth: \(imageMaxWidth), Height: \(inputsTotalHeight)")
                                }
                            
                            VStack(alignment: .leading, spacing: inputSpacing) {
                                MeasurementInput(label: "Chest", value: $chest, useMetric: userProfile?.useMetric ?? false, isFocused: selectedInput == "chest")
                                    .focused($focusedField, equals: "chest")
                                    .onTapGesture {
                                        selectedInput = "chest"
                                        focusedField = "chest"
                                        print("DEBUG: Chest selected, focusedField: \(String(describing: focusedField))")
                                    }
                                MeasurementInput(label: "Waist", value: $waist, useMetric: userProfile?.useMetric ?? false, isFocused: selectedInput == "waist")
                                    .focused($focusedField, equals: "waist")
                                    .onTapGesture {
                                        selectedInput = "waist"
                                        focusedField = "waist"
                                        print("DEBUG: Waist selected, focusedField: \(String(describing: focusedField))")
                                    }
                                MeasurementInput(label: "Hips", value: $hips, useMetric: userProfile?.useMetric ?? false, isFocused: selectedInput == "hips")
                                    .focused($focusedField, equals: "hips")
                                    .onTapGesture {
                                        selectedInput = "hips"
                                        focusedField = "hips"
                                        print("DEBUG: Hips selected, focusedField: \(String(describing: focusedField))")
                                    }
                                MeasurementInput(label: "Left Arm", value: $leftArm, useMetric: userProfile?.useMetric ?? false, isFocused: selectedInput == "leftArm")
                                    .focused($focusedField, equals: "leftArm")
                                    .onTapGesture {
                                        selectedInput = "leftArm"
                                        focusedField = "leftArm"
                                        print("DEBUG: Left Arm selected, focusedField: \(String(describing: focusedField))")
                                    }
                                MeasurementInput(label: "Right Arm", value: $rightArm, useMetric: userProfile?.useMetric ?? false, isFocused: selectedInput == "rightArm")
                                    .focused($focusedField, equals: "rightArm")
                                    .onTapGesture {
                                        selectedInput = "rightArm"
                                        focusedField = "rightArm"
                                        print("DEBUG: Right Arm selected, focusedField: \(String(describing: focusedField))")
                                    }
                                MeasurementInput(label: "Left Thigh", value: $leftThigh, useMetric: userProfile?.useMetric ?? false, isFocused: selectedInput == "leftThigh")
                                    .focused($focusedField, equals: "leftThigh")
                                    .onTapGesture {
                                        selectedInput = "leftThigh"
                                        focusedField = "leftThigh"
                                        print("DEBUG: Left Thigh selected, focusedField: \(String(describing: focusedField))")
                                    }
                                MeasurementInput(label: "Right Thigh", value: $rightThigh, useMetric: userProfile?.useMetric ?? false, isFocused: selectedInput == "rightThigh")
                                    .focused($focusedField, equals: "rightThigh")
                                    .onTapGesture {
                                        selectedInput = "rightThigh"
                                        focusedField = "rightThigh"
                                        print("DEBUG: Right Thigh selected, focusedField: \(String(describing: focusedField))")
                                    }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .withKeyboardDismiss()
                        }
                        .padding(.horizontal)
                        .frame(height: inputsTotalHeight) // Lock input space to 368pt
                        
                        Text(currentDescription)
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                        
                        Spacer() // Push picker to center
                        HorizontalTapeMeasurePicker(selectedValue: selectedMeasurement, useMetric: userProfile?.useMetric ?? false)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .opacity(selectedInput == nil ? 0.5 : 1.0)
                            .disabled(selectedInput == nil)
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0) // Added drop shadow
                        Spacer() // Balance with bottom spacer
                    }
                    
                    Button(action: {
                        saveMeasurements()
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.title2)
                            .foregroundColor(Styles.primaryText)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Styles.secondaryBackground)
                    }
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
                    .padding(.bottom, 20)
                }
                .background(Styles.primaryBackground)
            }
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Styles.primaryText)
                Text("Back")
                    .foregroundColor(Styles.primaryText)
            })
            .ignoresSafeArea(.keyboard)
            .onChange(of: focusedField) { newValue in
                print("DEBUG: focusedField changed to: \(String(describing: newValue))")
                if newValue == nil {
                    selectedInput = nil
                    print("DEBUG: No field focused, selectedInput reset to: \(String(describing: selectedInput))")
                }
            }
        }
    }
    
    private var currentImage: String {
        switch selectedInput {
        case "chest": return "BMChest"
        case "waist": return "BMWaist"
        case "hips": return "BMHips"
        case "leftArm": return "BMLArm"
        case "rightArm": return "BMRArm"
        case "leftThigh": return "BMLThigh"
        case "rightThigh": return "BMRThigh"
        default: return "BMDefault"
        }
    }
    
    private var currentDescription: String {
        switch selectedInput {
        case "chest": return "Measure around the fullest part of your chest, under the armpits, keeping the tape parallel to the ground."
        case "waist": return "Measure around your natural waistline, just above the hips, keeping the tape snug but not tight."
        case "hips": return "Measure around the widest part of your hips and buttocks, keeping the tape level."
        case "leftArm": return "Measure around the fullest part of your left upper arm, typically midway between shoulder and elbow."
        case "rightArm": return "Measure around the fullest part of your right upper arm, typically midway between shoulder and elbow."
        case "leftThigh": return "Measure around the fullest part of your left thigh, a few inches below the groin."
        case "rightThigh": return "Measure around the fullest part of your right thigh, a few inches below the groin."
        default: return "Select a measurement to see how to measure it correctly."
        }
    }
    
    private func saveMeasurements() {
        guard let userProfile = userProfile else {
            print("❌ No user profile available to save measurements")
            return
        }
        
        let measurement = BodyMeasurement(context: viewContext)
        measurement.chest = userProfile.useMetric ? chest * 2.54 : chest
        measurement.waist = userProfile.useMetric ? waist * 2.54 : waist
        measurement.hips = userProfile.useMetric ? hips * 2.54 : hips
        measurement.leftArm = userProfile.useMetric ? leftArm * 2.54 : leftArm
        measurement.rightArm = userProfile.useMetric ? rightArm * 2.54 : rightArm
        measurement.leftThigh = userProfile.useMetric ? leftThigh * 2.54 : leftThigh
        measurement.rightThigh = userProfile.useMetric ? rightThigh * 2.54 : rightThigh
        measurement.date = Date()
        measurement.userProfile = userProfile
        
        do {
            try viewContext.save()
            let unit = userProfile.useMetric ? "cm" : "in"
            print("✅ Body Measurements Saved: Chest: \(measurement.chest) \(unit), Waist: \(measurement.waist) \(unit), etc.")
        } catch {
            print("❌ Error saving body measurements: \(error.localizedDescription)")
        }
    }
}

// Updated MeasurementInput with Border and Shadow
struct MeasurementInput: View {
    let label: String
    @Binding var value: Double // In inches
    let useMetric: Bool
    let isFocused: Bool
    
    var body: some View {
        HStack {
            Text("\(label) (\(useMetric ? "cm" : "in"))")
                .font(.subheadline)
                .foregroundColor(Styles.secondaryText)
                .frame(width: 100, alignment: .leading)
            
            Text(String(format: "%.2f", useMetric ? value * 2.54 : value))
                .foregroundColor(Styles.primaryText)
                .padding(10)
                .frame(width: 95, height: 36)
                .background(isFocused ? Styles.tertiaryBackground : Styles.secondaryBackground)
                .overlay(
                    // Add border when focused
                    isFocused ? Rectangle().stroke(Styles.primaryText, lineWidth: 2) : nil
                )
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0) // Added drop shadow
        }
    }
}

struct BodyMeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        BodyMeasurementView(userProfile: nil)
    }
}
