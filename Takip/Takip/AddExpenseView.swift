import SwiftUI
import CoreData

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var amountText: String = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Yeni Harcama Ekle")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                
                amountField
                
                Text("Kategori Seç")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                categoryStrip
                
                Group {
                    Text("Açıklama")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Örn. Öğle yemeği", text: $note)
                        .textFieldStyle(.roundedBorder)
                }
                
                Group {
                    Text("Tarih")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxHeight: 140)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                
                Button {
                    save()
                } label: {
                    Text("Harcama Ekle")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 6)
                
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("İptal")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var amountField: some View {
        HStack(spacing: 10) {
            Text("₺")
                .font(.title3)
                .foregroundStyle(.secondary)
            TextField("0,00", text: $amountText)
                .keyboardType(.decimalPad)
                .font(.title3)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExpenseCategory.allCases) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 34, height: 34)
                                .background(cat.tint.opacity(selectedCategory == cat ? 0.25 : 0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(selectedCategory == cat ? cat.tint : Color.clear, lineWidth: 2)
                                )
                                .foregroundStyle(cat.tint)
                            Text(cat.titleTR)
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.secondary.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(cat.titleTR)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private func save() {
        errorMessage = nil
        let cleaned = amountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
        
        guard let value = Decimal(string: cleaned), value > 0 else {
            errorMessage = "Lütfen geçerli bir tutar gir."
            return
        }
        
        let e = Expense(context: viewContext)
        e.id = UUID()
        e.createdAt = date
        e.category = selectedCategory.rawValue
        e.note = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note.trimmingCharacters(in: .whitespacesAndNewlines)
        e.amount = NSDecimalNumber(decimal: value)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Kayıt edilemedi. Tekrar dene."
        }
    }
}

#Preview {
    AddExpenseView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

