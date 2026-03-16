import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAddPresented = false
    
    private var monthRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
        let end = cal.date(byAdding: .month, value: 1, to: start) ?? Date()
        return (start, end)
    }
    
    private var monthPredicate: NSPredicate {
        NSPredicate(format: "createdAt >= %@ AND createdAt < %@", monthRange.start as NSDate, monthRange.end as NSDate)
    }
    
    @FetchRequest private var monthExpenses: FetchedResults<Expense>
    
    init() {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
        let end = cal.date(byAdding: .month, value: 1, to: start) ?? Date()
        let predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", start as NSDate, end as NSDate)
        
        _monthExpenses = FetchRequest<Expense>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Expense.createdAt, ascending: false)],
            predicate: predicate,
            animation: .default
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    summaryCard
                    recentCard
                }
                .padding()
            }
            .navigationTitle("Bu Ayın Özeti")
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isAddPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor, in: Circle())
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 14)
                .accessibilityLabel("Harcama ekle")
            }
            .sheet(isPresented: $isAddPresented) {
                AddExpenseView()
            }
        }
    }
    
    private var totalMonth: Double {
        monthExpenses.reduce(0.0) { partial, e in
            partial + ((e.amount as? NSDecimalNumber)?.doubleValue ?? 0)
        }
    }
    
    private var donutSlices: [DonutSlice] {
        var totals: [ExpenseCategory: Double] = [:]
        for e in monthExpenses {
            let cat = ExpenseCategory.fromCoreData(e.category)
            let v = ((e.amount as? NSDecimalNumber)?.doubleValue ?? 0)
            totals[cat, default: 0] += v
        }
        
        return ExpenseCategory.allCases.map { cat in
            DonutSlice(
                value: totals[cat, default: 0],
                color: cat.tint,
                label: cat.titleTR
            )
        }.filter { $0.value > 0 }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Toplam Harcama:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Formatters.currencyTR.string(from: NSNumber(value: totalMonth)) ?? "₺0,00")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 14) {
                DonutChartView(slices: donutSlices, lineWidth: 22)
                    .frame(width: 140, height: 140)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(ExpenseCategory.allCases) { cat in
                        let value = donutSlices.first(where: { $0.label == cat.titleTR })?.value ?? 0
                        if value > 0 {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(cat.tint)
                                    .frame(width: 10, height: 10)
                                Text(cat.titleTR)
                                    .font(.subheadline)
                                Spacer()
                                Text(Formatters.currencyTR.string(from: NSNumber(value: value)) ?? "")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    if donutSlices.isEmpty {
                        Text("Bu ay henüz harcama yok.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
    
    private var recentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Harcamalar")
                .font(.headline)
            
            if monthExpenses.isEmpty {
                Text("Kayıt yok.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(monthExpenses.prefix(6))) { e in
                        RecentExpenseRow(expense: e)
                        if e != monthExpenses.prefix(6).last {
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
}

private struct RecentExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        let cat = ExpenseCategory.fromCoreData(expense.category)
        let title = (expense.note?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? cat.titleTR
        let amount = ((expense.amount as? NSDecimalNumber)?.doubleValue ?? 0)
        let date = expense.createdAt ?? Date()
        
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(cat.tint.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: cat.icon)
                    .foregroundStyle(cat.tint)
                    .font(.system(size: 15, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(Formatters.dayMonthYear.string(from: date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("-\(Formatters.currencyTR.string(from: NSNumber(value: amount)) ?? "₺0,00")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

