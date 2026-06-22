import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage("quickmath.theme") private var themeRaw = AppTheme.system.rawValue
    @State private var showPaywall = false
    @State private var showDeleteConfirm = false

    private var currentTheme: Binding<AppTheme> {
        Binding(
            get: { AppTheme(rawValue: themeRaw) ?? .system },
            set: { themeRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                List {
                    // Pro section
                    Section("Subscription") {
                        if store.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Color.qmAccent)
                                Text("Gratile Pro — Active")
                                    .font(.body.weight(.medium))
                            }
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                Link(destination: url) {
                                    HStack {
                                        Text("Manage Subscription")
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.open.fill")
                                        .foregroundStyle(Color.qmAccent)
                                    Text("Unlock Gratile Pro")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(Color.qmAccent)
                                }
                            }
                            Button("Restore Purchase") {
                                Task { await store.restore() }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }

                    // Appearance
                    Section("Appearance") {
                        Picker("Theme", selection: currentTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.label).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }

                    // Legal
                    Section("Legal") {
                        if let url = URL(string: "https://shimondeitel.github.io/gratile-site/privacy.html") {
                            Link(destination: url) {
                                HStack {
                                    Text("Privacy Policy")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            Link(destination: url) {
                                HStack {
                                    Text("Terms of Service")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }

                    // Data
                    Section("Data") {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Text("Delete All Entries")
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(store)
            }
            .confirmationDialog(
                "Delete All Entries?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    appModel.deleteAllData()
                    Haptics.warning()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your gratitude entries. This cannot be undone.")
            }
        }
    }
}
