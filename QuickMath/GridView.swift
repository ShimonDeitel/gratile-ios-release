import SwiftUI

/// The primary entry screen — write today's gratitude entry.
struct GridView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var saved = false
    @FocusState private var focused: Bool

    private var isEditing: Bool { appModel.todayEntry != nil }
    private var charLimit: Int { 280 }

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                ScrollView {
                    VStack(spacing: 24) {
                        // Prompt
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Prompt")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            Text(appModel.todayPrompt)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .qmCard()

                        // Text editor
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Your gratitude")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                Spacer()
                                Text("\(text.count)/\(charLimit)")
                                    .font(.caption)
                                    .foregroundStyle(text.count > charLimit ? Color.qmWrong : .secondary)
                            }

                            TextEditor(text: $text)
                                .focused($focused)
                                .font(.body)
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .onChange(of: text) { _, newVal in
                                    if newVal.count > charLimit {
                                        text = String(newVal.prefix(charLimit))
                                    }
                                }
                        }
                        .qmCard()

                        // Save button
                        if saved {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.qmCorrect)
                                Text("Saved")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.qmCorrect)
                            }
                            .padding(.vertical, 13)
                            .frame(maxWidth: .infinity)
                        } else {
                            Button {
                                saveEntry()
                            } label: {
                                Text(isEditing ? "Update Entry" : "Save Entry")
                                    .frame(maxWidth: .infinity)
                            }
                            .prominentButton()
                            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Today" : "Today's Gratitude")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                if let entry = appModel.todayEntry {
                    text = entry.text
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    focused = true
                }
            }
        }
    }

    private func saveEntry() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Haptics.success()
        appModel.saveEntry(text: trimmed, promptUsed: appModel.todayPrompt)
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}
