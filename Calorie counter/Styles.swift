import SwiftUI

struct Styles {
    // Static flag for dark mode (default to false)
    static var isDarkMode: Bool = false
    
    // Primary Background
    static var primaryBackground: Color {
        isDarkMode
            ? Color(red: 0.129, green: 0.208, blue: 0.333)  // Dark Mode (#213555)
            : Color(red: 0.843, green: 0.827, blue: 0.749)  // Light Mode (#D7D3BF)
    }

    // Secondary Background
    static var secondaryBackground: Color {
        isDarkMode
            ? Color(red: 0.243, green: 0.345, blue: 0.475)  // Dark Mode (#3E5879)
            : Color(red: 0.925, green: 0.922, blue: 0.871)  // Light Mode (#ECEBDE)
    }
    
    static var tertiaryBackground: Color {
        isDarkMode
            ? Color(red: 0.192, green: 0.286, blue: 0.400)  // Dark Mode (#314965)
            : Color(red: 0.890, green: 0.882, blue: 0.835)  // Light Mode (#E3E1D5)
    }

    // Primary Text
    static var primaryText: Color {
        isDarkMode
            ? Color(red: 0.847, green: 0.769, blue: 0.714)  // Dark Mode (#D8C4B6)
            : Color(red: 0.408, green: 0.341, blue: 0.322)  // Light Mode (#685752)
    }

    // Secondary Text
    static var secondaryText: Color {
        isDarkMode
            ? Color(red: 0.961, green: 0.937, blue: 0.906)  // Dark Mode (#F5EFE7)
            : Color(red: 0.600, green: 0.486, blue: 0.439)  // Light Mode (#997C70)
    }

    // Accent Colors
    static var accent: Color {
        isDarkMode ? Color.blue : Color.purple
    }

    static var warning: Color {
        isDarkMode ? Color.orange : Color.red
    }

    static var success: Color {
        isDarkMode ? Color.green : Color.green.opacity(0.8)
    }

    // Button Styles
    static var primaryButton: Color {
        isDarkMode ? Color.blue : Color.green
    }

    static var secondaryButton: Color {
        isDarkMode ? Color.gray : Color.gray.opacity(0.5)
    }
}
