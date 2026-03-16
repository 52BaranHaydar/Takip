import Foundation

enum Formatters {
    static let currencyTR: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "tr_TR")
        f.currencySymbol = "₺"
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()
    
    static let dayMonthYear: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()
}

