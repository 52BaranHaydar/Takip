import SwiftUI

struct SettingsView: View {
    @AppStorage("settings.theme") private var themeRaw: String = "system" // system | light | dark
    @AppStorage("settings.notifications") private var notificationsEnabled: Bool = true
    @AppStorage("settings.currency") private var currencyCode: String = "TRY"
    
    @State private var isDeleteConfirmPresented = false
    @State private var isBackupInfoPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "circle.lefthalf.filled")
                            .foregroundStyle(.blue)
                        Text("Uygulama Teması")
                        Spacer()
                    }
                    
                    Picker("Tema", selection: $themeRaw) {
                        Text("Açık").tag("light")
                        Text("Koyu").tag("dark")
                        Text("Sistem").tag("system")
                    }
                    .pickerStyle(.segmented)
                    
                } header: {
                    Text("Görünüm")
                }
                
                Section("Genel") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Bildirimler", systemImage: "bell.badge")
                    }
                    
                    NavigationLink {
                        CurrencyPickerView(selection: $currencyCode)
                    } label: {
                        Label {
                            HStack {
                                Text("Para Birimi")
                                Spacer()
                                Text(displayCurrency)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "turkishlirasign.circle")
                        }
                    }
                    
                    LabeledContent {
                        Text("Türkiye")
                            .foregroundStyle(.secondary)
                    } label: {
                        Label("Bölge", systemImage: "globe.europe.africa")
                    }
                }
                
                Section("Veri") {
                    Button {
                        isBackupInfoPresented = true
                    } label: {
                        Label("Veri Yedekleme", systemImage: "icloud.and.arrow.up")
                    }
                    .foregroundStyle(.primary)
                    .alert("Veri Yedekleme", isPresented: $isBackupInfoPresented) {
                        Button("Tamam", role: .cancel) {}
                    } message: {
                        Text("İstersen iCloud/Files ile dışa aktarma ve içe aktarma ekleyebilirim. Şu an sadece arayüz hazır.")
                    }
                    
                    Button(role: .destructive) {
                        isDeleteConfirmPresented = true
                    } label: {
                        Label("Veri Silme", systemImage: "trash")
                    }
                    .alert("Tüm veriler silinsin mi?", isPresented: $isDeleteConfirmPresented) {
                        Button("İptal", role: .cancel) {}
                        Button("Sil", role: .destructive) {
                            // İstersen burada Core Data store reset ekleyebilirim.
                        }
                    } message: {
                        Text("Bu işlem geri alınamaz.")
                    }
                }
                
                Section("Bilgi") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("Hakkımızda", systemImage: "info.circle")
                    }
                    
                    NavigationLink {
                        ContactView()
                    } label: {
                        Label("Bize Ulaşın", systemImage: "envelope")
                    }
                }
                
                Section {
                    Button(role: .destructive) {} label: {
                        Text("Çıkış Yap")
                    }
                }
            }
            .navigationTitle("Ayarlar")
        }
        .preferredColorScheme(preferredColorScheme)
    }
    
    private var preferredColorScheme: ColorScheme? {
        switch themeRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    private var displayCurrency: String {
        switch currencyCode {
        case "TRY": return "₺ TRY"
        case "USD": return "$ USD"
        case "EUR": return "€ EUR"
        default: return currencyCode
        }
    }
}

#Preview {
    SettingsView()
}

private struct CurrencyPickerView: View {
    @Binding var selection: String
    
    var body: some View {
        List {
            Section {
                currencyRow(code: "TRY", title: "Türk Lirası", symbol: "₺")
                currencyRow(code: "USD", title: "Amerikan Doları", symbol: "$")
                currencyRow(code: "EUR", title: "Euro", symbol: "€")
            } header: {
                Text("Para Birimi")
            }
        }
        .navigationTitle("Para Birimi")
    }
    
    private func currencyRow(code: String, title: String, symbol: String) -> some View {
        Button {
            selection = code
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text("\(symbol) \(code)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if selection == code {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

private struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(Color.accentColor)
            Text("Takip")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Giderlerini hızlıca kaydet, aylık özetini gör.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Hakkımızda")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ContactView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("E-posta", value: "support@takip.app")
                LabeledContent("Web", value: "takip.app")
            } header: {
                Text("İletişim")
            } footer: {
                Text("Bu alanları istersen gerçek linklerle açılacak hale getirebilirim.")
            }
        }
        .navigationTitle("Bize Ulaşın")
        .navigationBarTitleDisplayMode(.inline)
    }
}

