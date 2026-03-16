import SwiftUI
import CoreData
import Charts

struct ReportsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.createdAt, ascending: false)],
        animation: .default
    )
    private var allExpenses: FetchedResults<Expense>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    chartCard
                    categoryCard
                }
                .padding()
            }
            .navigationTitle("Raporlar")
        }
    }
    
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Swift Charts")
                .font(.headline)
            
            if monthSeries.isEmpty {
                Text("Henüz veri yok.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart(monthSeries) { point in
                    BarMark(
                        x: .value("Ay", point.monthLabel),
                        y: .value("Tutar", point.total)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .annotation(position: .overlay, alignment: .top) {
                        if point == monthSeries.max(by: { $0.total < $1.total }) {
                            Text("Info:\n\(point.monthFullTR): \(Formatters.currencyTR.string(from: NSNumber(value: point.total)) ?? "")")
                                .font(.caption2)
                                .padding(6)
                                .background(.background, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(Color.secondary.opacity(0.18), lineWidth: 1)
                                )
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing)
                }
                .frame(height: 220)
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("List")
                .font(.headline)
            
            if currentMonthCategoryRows.isEmpty {
                Text("Bu ay kayıt yok.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(currentMonthCategoryRows) { row in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(row.category.tint.opacity(0.15))
                                    .frame(width: 34, height: 34)
                                Image(systemName: row.category.icon)
                                    .foregroundStyle(row.category.tint)
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.category.titleTR)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Bugün")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(Formatters.currencyTR.string(from: NSNumber(value: row.total)) ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if row.id != currentMonthCategoryRows.last?.id {
                            Divider().opacity(0.6)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var monthSeries: [MonthPoint] {
        let cal = Calendar.current
        let startThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
        let start = cal.date(byAdding: .month, value: -5, to: startThisMonth) ?? startThisMonth
        
        var totals: [Date: Double] = [:]
        for e in allExpenses {
            guard let d = e.createdAt else { continue }
            guard d >= start else { continue }
            let key = cal.date(from: cal.dateComponents([.year, .month], from: d)) ?? d
            let v = (e.amount as? NSDecimalNumber)?.doubleValue ?? 0
            totals[key, default: 0] += v
        }
        
        let keys = totals.keys.sorted()
        return keys.map { k in
            let comps = cal.dateComponents([.month, .year], from: k)
            let month = comps.month ?? 1
            let year = comps.year ?? 2000
            return MonthPoint(date: k, month: month, year: year, total: totals[k, default: 0])
        }
        .sorted(by: { $0.date < $1.date })
    }
    
    private var currentMonthCategoryRows: [CategoryRow] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
        let end = cal.date(byAdding: .month, value: 1, to: start) ?? Date()
        
        var totals: [ExpenseCategory: Double] = [:]
        for e in allExpenses {
            guard let d = e.createdAt, d >= start, d < end else { continue }
            let cat = ExpenseCategory.fromCoreData(e.category)
            let v = (e.amount as? NSDecimalNumber)?.doubleValue ?? 0
            totals[cat, default: 0] += v
        }
        
        return totals
            .map { CategoryRow(category: $0.key, total: $0.value) }
            .sorted(by: { $0.total > $1.total })
    }
}

#Preview {
    ReportsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

private struct MonthPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let month: Int
    let year: Int
    let total: Double
    
    var monthLabel: String {
        switch month {
        case 1: return "OCA"
        case 2: return "ŞUB"
        case 3: return "MAR"
        case 4: return "NİS"
        case 5: return "MAY"
        case 6: return "HAZ"
        case 7: return "TEM"
        case 8: return "AĞU"
        case 9: return "EYL"
        case 10: return "EKİ"
        case 11: return "KAS"
        default: return "ARA"
        }
    }
    
    var monthFullTR: String {
        let name: String
        switch month {
        case 1: name = "Ocak"
        case 2: name = "Şubat"
        case 3: name = "Mart"
        case 4: name = "Nisan"
        case 5: name = "Mayıs"
        case 6: name = "Haziran"
        case 7: name = "Temmuz"
        case 8: name = "Ağustos"
        case 9: name = "Eylül"
        case 10: name = "Ekim"
        case 11: name = "Kasım"
        default: name = "Aralık"
        }
        return "\(name) \(year)"
    }
}

private struct CategoryRow: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let total: Double
}

