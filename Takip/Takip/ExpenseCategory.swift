import SwiftUI

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case other = "Other"
    
    var id: String { rawValue }
    
    var titleTR: String {
        switch self {
        case .food: return "Yemek"
        case .transport: return "Ulaşım"
        case .shopping: return "Alışveriş"
        case .entertainment: return "Eğlence"
        case .other: return "Diğer"
        }
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "bus"
        case .shopping: return "bag"
        case .entertainment: return "sparkles"
        case .other: return "ellipsis"
        }
    }
    
    var tint: Color {
        switch self {
        case .food: return .blue
        case .transport: return .green
        case .shopping: return .orange
        case .entertainment: return .purple
        case .other: return .gray
        }
    }
    
    static func fromCoreData(_ raw: String?) -> ExpenseCategory {
        guard let raw else { return .other }
        return ExpenseCategory(rawValue: raw) ?? .other
    }
}

