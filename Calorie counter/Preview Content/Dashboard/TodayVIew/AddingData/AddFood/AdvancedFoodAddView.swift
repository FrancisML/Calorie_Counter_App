//
//  AdvancedAddView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//

import SwiftUI
import AVFoundation

struct AdvancedFoodAddView: View {
    @Binding var diaryEntries: [DiaryEntry]
    var closeAction: () -> Void
    var initialBarcode: String? // New parameter for barcode from search

    @State private var foodImage: UIImage? = UIImage(named: "DefaultFood")
    @State private var foodName: String = ""
    @State private var servingSizeAmount: String = ""
    @State private var servingSizeUnit: String = "g"
    @State private var servingConsumedAmount: String = ""
    @State private var calories: Double = 0
    @State private var fats: Double = 0
    @State private var carbohydrates: Double = 0
    @State private var protein: Double = 0
    @State private var selectedCategory: String = "Uncategorized"
    @State private var isMacroSectionExpanded: Bool = false
    @State private var isMicroSectionExpanded: Bool = false
    @State private var isIngredientsExpanded: Bool = false
    @State private var ingredientsText: String = ""
    @State private var isFromScanner: Bool = false

    // Base API data (per serving size unit)
    @State private var baseCalories: Double = 0
    @State private var baseFats: Double = 0
    @State private var baseCarbs: Double = 0
    @State private var baseProtein: Double = 0

    // Micronutrients (amounts in mg or µg, DV in %)
    @State private var vitaminA: Double = 0
    @State private var vitaminA_DV: Double = 0
    @State private var vitaminC: Double = 0
    @State private var vitaminC_DV: Double = 0
    @State private var vitaminD: Double = 0
    @State private var vitaminD_DV: Double = 0
    @State private var calcium: Double = 0
    @State private var calcium_DV: Double = 0
    @State private var iron: Double = 0
    @State private var iron_DV: Double = 0
    @State private var sodium: Double = 0
    @State private var sodium_DV: Double = 0

    // Base API data for micronutrients (per 100g)
    @State private var baseVitaminA: Double = 0
    @State private var baseVitaminC: Double = 0
    @State private var baseVitaminD: Double = 0
    @State private var baseCalcium: Double = 0
    @State private var baseIron: Double = 0
    @State private var baseSodium: Double = 0

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false

    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet: Bool = false
    @State private var showBarcodeScanner: Bool = false

    // Focus states for each TextField
    @FocusState private var isNameFocused: Bool
    @FocusState private var isServingSizeFocused: Bool
    @FocusState private var isServingConsumedFocused: Bool
    @FocusState private var isCaloriesFocused: Bool
    @FocusState private var isFatsFocused: Bool
    @FocusState private var isCarbsFocused: Bool
    @FocusState private var isProteinFocused: Bool
    @FocusState private var isVitaminAFocused: Bool
    @FocusState private var isVitaminCFocused: Bool
    @FocusState private var isVitaminDFocused: Bool
    @FocusState private var isCalciumFocused: Bool
    @FocusState private var isIronFocused: Bool
    @FocusState private var isSodiumFocused: Bool
    @FocusState private var isVitaminA_DVFocused: Bool
    @FocusState private var isVitaminC_DVFocused: Bool
    @FocusState private var isVitaminD_DVFocused: Bool
    @FocusState private var isCalcium_DVFocused: Bool
    @FocusState private var isIron_DVFocused: Bool
    @FocusState private var isSodium_DVFocused: Bool

    private let categories = ["Uncategorized", "Breakfast", "Lunch", "Dinner", "Snack", "Dessert"]
    private let servingUnits = ["piece", "g", "oz"]

    // Daily Value References (approximate, based on FDA/USDA for adults)
    private let dvVitaminA: Double = 900 // µg
    private let dvVitaminC: Double = 90 // mg
    private let dvVitaminD: Double = 20 // µg
    private let dvCalcium: Double = 1300 // mg
    private let dvIron: Double = 18 // mg
    private let dvSodium: Double = 2300 // mg

    init(diaryEntries: Binding<[DiaryEntry]>, closeAction: @escaping () -> Void, initialBarcode: String? = nil) {
        self._diaryEntries = diaryEntries
        self.closeAction = closeAction
        self.initialBarcode = initialBarcode
    }

    var body: some View {
        VStack(spacing: 20) {
            // Top Section: Image + Name and Time
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(foodImage != UIImage(named: "DefaultFood") ? Color.green : Styles.primaryText, lineWidth: 3)
                        .frame(width: 100, height: 100)

                    Image(uiImage: foodImage ?? UIImage(named: "DefaultFood")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button(action: {
                        showActionSheet = true
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                    }
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("Select Image"),
                            buttons: [
                                .default(Text("Take a Photo")) {
                                    imagePickerSourceType = .camera
                                    showImagePicker = true
                                },
                                .default(Text("Choose from Library")) {
                                    imagePickerSourceType = .photoLibrary
                                    showImagePicker = true
                                },
                                .destructive(Text("Remove Image")) {
                                    foodImage = UIImage(named: "DefaultFood")
                                },
                                .cancel()
                            ]
                        )
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $foodImage, sourceType: imagePickerSourceType)
                    }
                }

                VStack(spacing: 10) {
                    if isFromScanner {
                        HStack {
                            Text("Name")
                                .foregroundColor(Styles.primaryText)
                            Spacer()
                            Text(foodName.isEmpty ? "Food Name" : foodName)
                                .foregroundColor(Styles.primaryText)
                        }
                    } else {
                        HStack {
                            Text("Name")
                                .foregroundColor(Styles.primaryText)
                            Spacer()
                            TextField("Food Name", text: $foodName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(Styles.primaryText)
                                .padding(4)
                                .frame(width: 100)
                                .border(Styles.primaryText, width: 1)
                                .focused($isNameFocused)
                                .submitLabel(.done)
                                .onTapGesture {
                                    isNameFocused = true
                                }
                        }
                    }

                    HStack {
                        Text("Time")
                            .foregroundColor(Styles.primaryText)
                        Spacer()
                        Text(formattedTime)
                            .foregroundColor(Styles.primaryText)
                            .padding(4)
                            .frame(width: 100, alignment: .trailing)
                            .border(Styles.primaryText, width: 1)
                            .onTapGesture {
                                showTimePicker = true
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Scrollable Data Section
            ScrollView {
                VStack(spacing: 0) {
                    // Serving Size
                    HStack(spacing: 0) {
                        Text("Serving Size")
                            .foregroundColor(Styles.primaryText)
                        Spacer()
                        if isFromScanner {
                            Text(servingSizeAmount)
                                .foregroundColor(Styles.primaryText)
                        } else {
                            TextField("Amount", text: $servingSizeAmount)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(Styles.primaryText)
                                .keyboardType(.decimalPad)
                                .padding(4)
                                .frame(width: 100)
                                .border(Styles.primaryText, width: 1)
                                .focused($isServingSizeFocused)
                                .submitLabel(.done)
                                .onTapGesture {
                                    isServingSizeFocused = true
                                }
                        }
                        Picker("Unit", selection: $servingSizeUnit) {
                            ForEach(servingUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(Styles.primaryText)
                        .frame(width: 100)
                        .padding(4)
                        .background(Styles.primaryBackground.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onChange(of: servingSizeUnit) { _ in if isFromScanner { recalculateNutrition() } }
                    }
                    .padding(.vertical, 10)

                    Divider()
                        .background(Styles.primaryText.opacity(0.5))

                    // Serving Consumed
                    HStack(spacing: 0) {
                        Text("Serving Consumed")
                            .foregroundColor(Styles.primaryText)
                        Spacer()
                        TextField("Amount", text: $servingConsumedAmount)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Styles.primaryText)
                            .keyboardType(.decimalPad)
                            .padding(4)
                            .frame(width: 100)
                            .border(Styles.primaryText, width: 1)
                            .focused($isServingConsumedFocused)
                            .submitLabel(.done)
                            .onTapGesture {
                                isServingConsumedFocused = true
                            }
                        Text(servingSizeUnit)
                            .foregroundColor(Styles.primaryText)
                            .padding(.leading, 4)
                    }
                    .padding(.vertical, 10)

                    Divider()
                        .background(Styles.primaryText.opacity(0.5))

                    // Calories per Serving
                    if isFromScanner {
                        HStack {
                            Text("Calories per Serving")
                                .foregroundColor(Styles.primaryText)
                            Spacer()
                            Text(String(format: "%.0f", calories))
                                .foregroundColor(Styles.primaryText)
                                .frame(width: 100, alignment: .trailing)
                        }
                        .padding(.vertical, 10)
                    } else {
                        HStack(spacing: 0) {
                            Text("Calories per Serving")
                                .foregroundColor(Styles.primaryText)
                            Spacer()
                            TextField("Calories", text: Binding(
                                get: { String(format: "%.0f", calories) },
                                set: { calories = Double($0) ?? 0 }
                            ))
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Styles.primaryText)
                            .keyboardType(.numberPad)
                            .padding(4)
                            .frame(width: 100)
                            .border(Styles.primaryText, width: 1)
                            .focused($isCaloriesFocused)
                            .submitLabel(.done)
                            .onTapGesture {
                                isCaloriesFocused = true
                            }
                        }
                        .padding(.vertical, 10)
                    }

                    Divider()
                        .background(Styles.primaryText.opacity(0.5))

                    // Macronutrients
                    DisclosureGroup(
                        isExpanded: $isMacroSectionExpanded,
                        content: {
                            VStack(spacing: 0) {
                                if isFromScanner {
                                    HStack {
                                        Text("Fats")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f g", fats))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 100, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Fats")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Fats", text: Binding(
                                            get: { String(format: "%.1f", fats) },
                                            set: { fats = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isFatsFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isFatsFocused = true
                                        }
                                        Text("g")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }

                                Divider()
                                    .background(Styles.primaryText.opacity(0.5))

                                if isFromScanner {
                                    HStack {
                                        Text("Carbohydrates")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f g", carbohydrates))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 100, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Carbohydrates")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Carbs", text: Binding(
                                            get: { String(format: "%.1f", carbohydrates) },
                                            set: { carbohydrates = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isCarbsFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isCarbsFocused = true
                                        }
                                        Text("g")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }

                                Divider()
                                    .background(Styles.primaryText.opacity(0.5))

                                if isFromScanner {
                                    HStack {
                                        Text("Protein")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f g", protein))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 100, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Protein")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Protein", text: Binding(
                                            get: { String(format: "%.1f", protein) },
                                            set: { protein = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isProteinFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isProteinFocused = true
                                        }
                                        Text("g")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                            .padding(.top, 10)
                        },
                        label: {
                            Text("Macronutrients")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                        }
                    )
                    .padding(.vertical, 10)

                    Divider()
                        .background(Styles.primaryText.opacity(0.5))

                    // Micronutrients
                    DisclosureGroup(
                        isExpanded: $isMicroSectionExpanded,
                        content: {
                            VStack(spacing: 0) {
                                // Vitamin A
                                if isFromScanner {
                                    HStack {
                                        Text("Vitamin A")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f µg (%.0f%% DV)", vitaminA, vitaminA_DV))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 150, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Vitamin A")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Amount", text: Binding(
                                            get: { String(format: "%.1f", vitaminA) },
                                            set: { vitaminA = Double($0) ?? 0; updateDV(&vitaminA_DV, vitaminA, dvVitaminA) }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isVitaminAFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isVitaminAFocused = true
                                        }
                                        Text("µg")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                        TextField("% DV", text: Binding(
                                            get: { String(format: "%.0f", vitaminA_DV) },
                                            set: { vitaminA_DV = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 60)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isVitaminA_DVFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isVitaminA_DVFocused = true
                                        }
                                        Text("%")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }

                                Divider()
                                    .background(Styles.primaryText.opacity(0.5))

                                // Vitamin C
                                if isFromScanner {
                                    HStack {
                                        Text("Vitamin C")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f mg (%.0f%% DV)", vitaminC, vitaminC_DV))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 150, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Vitamin C")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Amount", text: Binding(
                                            get: { String(format: "%.1f", vitaminC) },
                                            set: { vitaminC = Double($0) ?? 0; updateDV(&vitaminC_DV, vitaminC, dvVitaminC) }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isVitaminCFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isVitaminCFocused = true
                                        }
                                        Text("mg")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                        TextField("% DV", text: Binding(
                                            get: { String(format: "%.0f", vitaminC_DV) },
                                            set: { vitaminC_DV = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 60)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isVitaminC_DVFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isVitaminC_DVFocused = true
                                        }
                                        Text("%")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }

                                Divider()
                                    .background(Styles.primaryText.opacity(0.5))

                                // Vitamin D
                                if isFromScanner {
                                    HStack {
                                        Text("Vitamin D")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f µg (%.0f%% DV)", vitaminD, vitaminD_DV))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 150, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Vitamin D")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Amount", text: Binding(
                                            get: { String(format: "%.1f", vitaminD) },
                                            set: { vitaminD = Double($0) ?? 0; updateDV(&vitaminD_DV, vitaminD, dvVitaminD) }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isVitaminDFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isVitaminDFocused = true
                                        }
                                        Text("µg")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                        TextField("% DV", text: Binding(
                                            get: { String(format: "%.0f", vitaminD_DV) },
                                            set: { vitaminD_DV = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 60)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isVitaminD_DVFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isVitaminD_DVFocused = true
                                        }
                                        Text("%")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }

                                Divider()
                                    .background(Styles.primaryText.opacity(0.5))

                                // Calcium
                                if isFromScanner {
                                    HStack {
                                        Text("Calcium")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f mg (%.0f%% DV)", calcium, calcium_DV))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 150, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Calcium")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Amount", text: Binding(
                                            get: { String(format: "%.1f", calcium) },
                                            set: { calcium = Double($0) ?? 0; updateDV(&calcium_DV, calcium, dvCalcium) }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isCalciumFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isCalciumFocused = true
                                        }
                                        Text("mg")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                        TextField("% DV", text: Binding(
                                            get: { String(format: "%.0f", calcium_DV) },
                                            set: { calcium_DV = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 60)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isCalcium_DVFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isCalcium_DVFocused = true
                                        }
                                        Text("%")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }

                                Divider()
                                    .background(Styles.primaryText.opacity(0.5))

                                // Iron
                                if isFromScanner {
                                    HStack {
                                        Text("Iron")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f mg (%.0f%% DV)", iron, iron_DV))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 150, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Iron")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Amount", text: Binding(
                                            get: { String(format: "%.1f", iron) },
                                            set: { iron = Double($0) ?? 0; updateDV(&iron_DV, iron, dvIron) }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isIronFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isIronFocused = true
                                        }
                                        Text("mg")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                        TextField("% DV", text: Binding(
                                            get: { String(format: "%.0f", iron_DV) },
                                            set: { iron_DV = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 60)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isIron_DVFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isIron_DVFocused = true
                                        }
                                        Text("%")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }

                                Divider()
                                    .background(Styles.primaryText.opacity(0.5))

                                // Sodium
                                if isFromScanner {
                                    HStack {
                                        Text("Sodium")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f mg (%.0f%% DV)", sodium, sodium_DV))
                                            .foregroundColor(Styles.primaryText)
                                            .frame(width: 150, alignment: .trailing)
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Sodium")
                                            .foregroundColor(Styles.primaryText)
                                        Spacer()
                                        TextField("Amount", text: Binding(
                                            get: { String(format: "%.1f", sodium) },
                                            set: { sodium = Double($0) ?? 0; updateDV(&sodium_DV, sodium, dvSodium) }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 100)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isSodiumFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isSodiumFocused = true
                                        }
                                        Text("mg")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                        TextField("% DV", text: Binding(
                                            get: { String(format: "%.0f", sodium_DV) },
                                            set: { sodium_DV = Double($0) ?? 0 }
                                        ))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(Styles.primaryText)
                                        .keyboardType(.decimalPad)
                                        .padding(4)
                                        .frame(width: 60)
                                        .border(Styles.primaryText, width: 1)
                                        .focused($isSodium_DVFocused)
                                        .submitLabel(.done)
                                        .onTapGesture {
                                            isSodium_DVFocused = true
                                        }
                                        Text("%")
                                            .foregroundColor(Styles.primaryText)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                            .padding(.top, 10)
                        },
                        label: {
                            Text("Micronutrients")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                        }
                    )
                    .padding(.vertical, 10)

                    Divider()
                        .background(Styles.primaryText.opacity(0.5))

                    // Ingredient List
                    DisclosureGroup(
                        isExpanded: $isIngredientsExpanded,
                        content: {
                            TextField("Enter ingredients...", text: $ingredientsText, axis: .vertical)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(Styles.primaryText)
                                .padding()
                                .background(Styles.primaryBackground.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 10)
                                .disabled(isFromScanner)
                        },
                        label: {
                            Text("Ingredient List")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                        }
                    )
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
            }

            // Save Custom Food Button (Manual only)
            if !isFromScanner {
                Button(action: {
                    saveFoodToDiary()
                }) {
                    Text("Save Custom Food")
                        .font(.headline)
                        .foregroundColor(Styles.secondaryBackground)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Styles.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
            }

            bottomNavBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showTimePicker) {
            VStack {
                timePicker
                Button("Done") { showTimePicker = false }
            }
        }
        .sheet(isPresented: $showBarcodeScanner) {
            BarcodeScannerView { barcode in
                fetchFoodData(barcode: barcode)
                showBarcodeScanner = false
            }
        }
        .onAppear {
            if let barcode = initialBarcode {
                fetchFoodData(barcode: barcode)
            }
        }
    }

    // MARK: - Barcode Scanner View
    struct BarcodeScannerView: UIViewControllerRepresentable {
        var onScan: (String) -> Void

        func makeUIViewController(context: Context) -> ScannerViewController {
            let scanner = ScannerViewController()
            scanner.delegate = context.coordinator
            return scanner
        }

        func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
            var parent: BarcodeScannerView

            init(_ parent: BarcodeScannerView) {
                self.parent = parent
            }

            func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                   let barcode = metadataObject.stringValue {
                    parent.onScan(barcode)
                }
            }
        }
    }

    class ScannerViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var delegate: AVCaptureMetadataOutputObjectsDelegate?

        override func viewDidLoad() {
            super.viewDidLoad()
            setupScanner()
        }

        private func setupScanner() {
            captureSession = AVCaptureSession()
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .code128]
            }

            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            captureSession.startRunning()
        }
    }

    // MARK: - Open Food Facts API Call
    private func fetchFoodData(barcode: String) {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let product = json["product"] as? [String: Any] {
                    DispatchQueue.main.async {
                        self.foodName = (product["product_name"] as? String) ?? ""
                        if let nutriments = product["nutriments"] as? [String: Any] {
                            self.baseCalories = nutriments["energy-kcal_100g"] as? Double ?? 0
                            self.baseFats = nutriments["fat_100g"] as? Double ?? 0
                            self.baseCarbs = nutriments["carbohydrates_100g"] as? Double ?? 0
                            self.baseProtein = nutriments["proteins_100g"] as? Double ?? 0
                            self.calories = self.baseCalories
                            self.fats = self.baseFats
                            self.carbohydrates = self.baseCarbs
                            self.protein = self.baseProtein

                            // Micronutrients (per 100g)
                            self.baseVitaminA = (nutriments["vitamin-a_100g"] as? Double ?? 0) * 1_000_000 // Convert g to µg
                            self.baseVitaminC = (nutriments["vitamin-c_100g"] as? Double ?? 0) * 1000 // Convert g to mg
                            self.baseVitaminD = (nutriments["vitamin-d_100g"] as? Double ?? 0) * 1_000_000 // Convert g to µg
                            self.baseCalcium = (nutriments["calcium_100g"] as? Double ?? 0) * 1000 // Convert g to mg
                            self.baseIron = (nutriments["iron_100g"] as? Double ?? 0) * 1000 // Convert g to mg
                            self.baseSodium = (nutriments["sodium_100g"] as? Double ?? 0) * 1000 // Convert g to mg

                            // Initial values
                            self.vitaminA = self.baseVitaminA
                            self.vitaminC = self.baseVitaminC
                            self.vitaminD = self.baseVitaminD
                            self.calcium = self.baseCalcium
                            self.iron = self.baseIron
                            self.sodium = self.baseSodium

                            // Calculate initial % DV
                            self.vitaminA_DV = (self.vitaminA / dvVitaminA) * 100
                            self.vitaminC_DV = (self.vitaminC / dvVitaminC) * 100
                            self.vitaminD_DV = (self.vitaminD / dvVitaminD) * 100
                            self.calcium_DV = (self.calcium / dvCalcium) * 100
                            self.iron_DV = (self.iron / dvIron) * 100
                            self.sodium_DV = (self.sodium / dvSodium) * 100
                        }
                        self.servingSizeAmount = "100"
                        self.servingSizeUnit = "g"
                        self.servingConsumedAmount = "100"
                        if let categories = product["categories"] as? String {
                            let matchedCategory = categories.split(separator: ",").first { cat in
                                self.categories.contains(cat.trimmingCharacters(in: .whitespaces))
                            }?.trimmingCharacters(in: .whitespaces)
                            self.selectedCategory = matchedCategory ?? "Uncategorized"
                        }
                        if let ingredients = product["ingredients_text"] as? String {
                            self.ingredientsText = ingredients
                        } else if let ingredientsEn = product["ingredients_text_en"] as? String {
                            self.ingredientsText = ingredientsEn
                        }
                        if let imageUrlString = product["image_front_url"] as? String {
                            self.loadImage(from: imageUrlString)
                        }
                        self.isFromScanner = true
                        self.recalculateNutrition()
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }

    // MARK: - Load Image from URL
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self.foodImage = image
            }
        }.resume()
    }

    // MARK: - Recalculate Nutrition
    private func recalculateNutrition() {
        guard let sizeAmount = Double(servingSizeAmount),
              let consumedAmount = Double(servingConsumedAmount),
              sizeAmount > 0, consumedAmount > 0 else {
            if isFromScanner {
                calories = 0
                fats = 0
                carbohydrates = 0
                protein = 0
                vitaminA = 0
                vitaminC = 0
                vitaminD = 0
                calcium = 0
                iron = 0
                sodium = 0
                vitaminA_DV = 0
                vitaminC_DV = 0
                vitaminD_DV = 0
                calcium_DV = 0
                iron_DV = 0
                sodium_DV = 0
            }
            return
        }

        if isFromScanner {
            var gramsPerServing: Double
            switch servingSizeUnit {
            case "g":
                gramsPerServing = sizeAmount
            case "oz":
                gramsPerServing = sizeAmount * 28.3495
            case "piece":
                gramsPerServing = sizeAmount * 100 // Placeholder
            default:
                gramsPerServing = sizeAmount
            }

            let baseFactor = gramsPerServing / 100.0
            let caloriesPerServing = baseCalories * baseFactor
            let fatsPerServing = baseFats * baseFactor
            let carbsPerServing = baseCarbs * baseFactor
            let proteinPerServing = baseProtein * baseFactor
            let vitaminAPerServing = baseVitaminA * baseFactor
            let vitaminCPerServing = baseVitaminC * baseFactor
            let vitaminDPerServing = baseVitaminD * baseFactor
            let calciumPerServing = baseCalcium * baseFactor
            let ironPerServing = baseIron * baseFactor
            let sodiumPerServing = baseSodium * baseFactor

            let consumedGrams: Double
            switch servingSizeUnit {
            case "g":
                consumedGrams = consumedAmount
            case "oz":
                consumedGrams = consumedAmount * 28.3495
            case "piece":
                consumedGrams = consumedAmount * 100 // Placeholder
            default:
                consumedGrams = consumedAmount
            }

            let consumedFactor = consumedGrams / gramsPerServing
            calories = caloriesPerServing * consumedFactor
            fats = fatsPerServing * consumedFactor
            carbohydrates = carbsPerServing * consumedFactor
            protein = proteinPerServing * consumedFactor
            vitaminA = vitaminAPerServing * consumedFactor
            vitaminC = vitaminCPerServing * consumedFactor
            vitaminD = vitaminDPerServing * consumedFactor
            calcium = calciumPerServing * consumedFactor
            iron = ironPerServing * consumedFactor
            sodium = sodiumPerServing * consumedFactor

            // Update % DV based on recalculated values
            vitaminA_DV = (vitaminA / dvVitaminA) * 100
            vitaminC_DV = (vitaminC / dvVitaminC) * 100
            vitaminD_DV = (vitaminD / dvVitaminD) * 100
            calcium_DV = (calcium / dvCalcium) * 100
            iron_DV = (iron / dvIron) * 100
            sodium_DV = (sodium / dvSodium) * 100
        }
    }

    // Helper to update % DV when amount changes
    private func updateDV(_ dv: inout Double, _ amount: Double, _ reference: Double) {
        dv = (amount / reference) * 100
    }

    // MARK: - Save Food Entry
    private func saveFoodToDiary() {
        guard !foodName.isEmpty, !servingSizeAmount.isEmpty, !servingConsumedAmount.isEmpty, calories > 0 else {
            print("⚠️ Missing required fields")
            return
        }
        
        let newEntry = DiaryEntry(
            time: formattedTime,
            iconName: foodImage != UIImage(named: "DefaultFood") ? "CustomFood" : "DefaultFood",
            description: foodName,
            detail: "\(servingConsumedAmount) \(servingSizeUnit)",
            calories: Int(calories),
            type: "Food",
            imageName: "DefaultFood",
            imageData: foodImage?.jpegData(compressionQuality: 0.8),
            fats: fats,
            carbs: carbohydrates,
            protein: protein
        )
        
        DispatchQueue.main.async {
            diaryEntries.append(newEntry)
        }
        print("✅ Food Saved: \(newEntry)")
        closeAction()
    }

    // MARK: - Helpers
    private var formattedTime: String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)"
    }

    private var timePicker: some View {
        HStack {
            Picker("Hour", selection: $selectedHour) {
                ForEach(1...12, id: \.self) { hour in
                    Text("\(hour)").tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("Minutes", selection: $selectedMinute) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(String(format: "%02d", minute))").tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("AM/PM", selection: $selectedPeriod) {
                Text("AM").tag("AM")
                Text("PM").tag("PM")
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()
        }
    }

    private func bottomNavBar() -> some View {
        ZStack {
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack(spacing: 0) {
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

                Spacer()

                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image("BarCode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .onTapGesture {
                    showBarcodeScanner = true
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(Styles.secondaryBackground)
                }
                .onTapGesture {
                    if isFromScanner {
                        saveFoodToDiary()
                    }
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .offset(y: -36)
        }
        .frame(height: 96)
    }
}
