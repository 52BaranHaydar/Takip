import SwiftUI

struct DonutSlice: Identifiable {
    let id = UUID()
    let value: Double
    let color: Color
    let label: String
}

struct DonutChartView: View {
    let slices: [DonutSlice]
    var lineWidth: CGFloat = 22
    
    private var total: Double {
        slices.reduce(0) { $0 + max(0, $1.value) }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if total <= 0 {
                    Circle()
                        .stroke(Color.secondary.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth))
                } else {
                    ForEach(Array(slices.enumerated()), id: \.offset) { idx, slice in
                        let start = startAngle(for: idx)
                        let end = endAngle(for: idx)
                        Circle()
                            .trim(from: start, to: end)
                            .stroke(slice.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                            .rotationEffect(.degrees(-90))
                    }
                }
                
                VStack(spacing: 4) {
                    Text("Toplam")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Formatters.currencyTR.string(from: NSNumber(value: total)) ?? "₺0,00")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Aylık harcama grafiği")
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func startAngle(for index: Int) -> CGFloat {
        guard total > 0 else { return 0 }
        let sum = slices.prefix(index).reduce(0) { $0 + max(0, $1.value) }
        return CGFloat(sum / total)
    }
    
    private func endAngle(for index: Int) -> CGFloat {
        guard total > 0 else { return 0 }
        let sum = slices.prefix(index + 1).reduce(0) { $0 + max(0, $1.value) }
        return CGFloat(sum / total)
    }
}

#Preview {
    let demoSlices = [
        DonutSlice(value: 1200, color: ExpenseCategory.food.tint, label: ExpenseCategory.food.titleTR),
        DonutSlice(value: 800, color: ExpenseCategory.transport.tint, label: ExpenseCategory.transport.titleTR),
        DonutSlice(value: 600, color: ExpenseCategory.shopping.tint, label: ExpenseCategory.shopping.titleTR),
        DonutSlice(value: 400, color: ExpenseCategory.entertainment.tint, label: ExpenseCategory.entertainment.titleTR),
        DonutSlice(value: 200, color: ExpenseCategory.other.tint, label: ExpenseCategory.other.titleTR)
    ]
    
    return DonutChartView(slices: demoSlices)
        .padding()
        .background(Color(.systemBackground))
}

