//
//  AddFood.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//
import SwiftUI

struct AddFoodView: View {
    var closeAction: () -> Void
    @Binding var diaryEntries: [DiaryEntry]
    @State private var selectedTab: FoodTab = .quickAdd
    @State private var searchText: String = ""
    @State private var searchResults: [FoodItem] = []
    @State private var selectedFoodBarcode: String?
    
    enum FoodTab {
        case quickAdd, advancedAdd
    }
    
    struct FoodItem: Identifiable {
        let id = UUID()
        let name: String
        let barcode: String
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeAreaTopInset = geometry.safeAreaInsets.top
            
            VStack(spacing: 0) {
                // Title Bar
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 80)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 4)
                    Text("Add Food")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, safeAreaTopInset)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Styles.secondaryText)
                    TextField("Search food...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(Styles.primaryText)
                        .onChange(of: searchText) { newValue in
                            if newValue.isEmpty {
                                searchResults = []
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if searchText == newValue {
                                        searchFood(query: newValue)
                                    }
                                }
                            }
                        }
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(Styles.primaryBackground.opacity(0.3))
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, searchResults.isEmpty ? 16 : 0)
                
                // Search Results
                if !searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchResults.prefix(5)) { item in
                            Button(action: {
                                selectedFoodBarcode = item.barcode
                                searchResults = []
                                searchText = ""
                            }) {
                                Text(item.name)
                                    .foregroundColor(Styles.primaryText)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Styles.primaryBackground.opacity(0.1))
                            }
                        }
                    }
                    .background(Styles.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.opacity)
                }
                
                // Tabs
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(width: geometry.size.width, height: 50)
                        .shadow(radius: 2)
                    HStack(spacing: 0) {
                        tabButton(title: "Quick Add", selected: selectedTab == .quickAdd) {
                            selectedTab = .quickAdd
                        }
                        tabButton(title: "Advanced Add", selected: selectedTab == .advancedAdd) {
                            selectedTab = .advancedAdd
                        }
                    }
                    .frame(width: geometry.size.width, height: 50)
                }
                
                // Content Area
                if selectedFoodBarcode != nil {
                    AdvancedFoodAddView(
                        diaryEntries: $diaryEntries,
                        closeAction: closeAction,
                        initialBarcode: selectedFoodBarcode
                    )
                    .onDisappear {
                        selectedFoodBarcode = nil
                    }
                } else {
                    VStack {
                        if selectedTab == .quickAdd {
                            QuickFoodAddView(diaryEntries: $diaryEntries, closeAction: closeAction)
                        } else {
                            AdvancedFoodAddView(diaryEntries: $diaryEntries, closeAction: closeAction)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func tabButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(selected ? .orange : Styles.primaryText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(selected ? Color.clear : Styles.primaryBackground.opacity(0.3))
            .onTapGesture {
                withAnimation {
                    action()
                }
            }
    }
    
    private func searchFood(query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode query: \(query)")
            return
        }
        
        // Use V1 search endpoint for better full-text search support
        let urlString = "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(encodedQuery)&search_simple=1&action=process&json=1&page_size=5"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        print("Searching with URL: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Log raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response: \(jsonString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let products = json["products"] as? [[String: Any]] {
                    let results = products.compactMap { product -> FoodItem? in
                        guard let name = product["product_name"] as? String,
                              let barcode = product["code"] as? String,
                              !name.isEmpty, !barcode.isEmpty else {
                            return nil
                        }
                        return FoodItem(name: name, barcode: barcode)
                    }
                    
                    DispatchQueue.main.async {
                        withAnimation {
                            searchResults = results
                            print("Updated results: \(results.map { $0.name })")
                        }
                    }
                } else {
                    print("No valid products found in response")
                    DispatchQueue.main.async {
                        searchResults = []
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    searchResults = []
                }
            }
        }.resume()
    }
}
