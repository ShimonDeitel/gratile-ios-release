import SwiftUI

/// Pro feature: unlimited gratitude wall with search, favorites, and on-this-day resurfacing.
struct InsightsView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var selectedEntry: GratEntry? = nil
    @State private var showDeleteConfirm = false
    @State private var entryToDelete: GratEntry? = nil

    private var filteredEntries: [GratEntry] {
        appModel.entries.filter { entry in
            let matchesFav = showFavoritesOnly ? entry.favorite : true
            let matchesSearch = searchText.isEmpty
                ? true
                : entry.text.localizedCaseInsensitiveContains(searchText)
                  || (entry.promptUsed?.localizedCaseInsensitiveContains(searchText) ?? false)
            return matchesFav && matchesSearch
        }
    }

    private var onThisDayEntries: [GratEntry] {
        let cal = Calendar.current
        let today = Date()
        return appModel.entries.filter { entry in
            let sameMonthDay = cal.component(.month, from: entry.date) == cal.component(.month, from: today)
                && cal.component(.day, from: entry.date) == cal.component(.day, from: today)
                && !cal.isDateInToday(entry.date)
            return sameMonthDay
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                List {
                    // Stats section
                    Section {
                        HStack(spacing: 12) {
                            MetricTile(value: "\(appModel.streak)", label: "Streak")
                            MetricTile(value: "\(appModel.entries.count)", label: "Total")
                            MetricTile(value: "\(appModel.entries.filter(\.favorite).count)", label: "Favorites")
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 4)
                    }

                    // On This Day
                    if !onThisDayEntries.isEmpty {
                        Section("On This Day") {
                            ForEach(onThisDayEntries) { entry in
                                entryRow(entry)
                            }
                        }
                    }

                    // All entries
                    Section {
                        if filteredEntries.isEmpty {
                            Text(searchText.isEmpty ? "No entries yet." : "No matching entries.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(filteredEntries) { entry in
                                entryRow(entry)
                            }
                            .onDelete { indexSet in
                                for i in indexSet {
                                    let entry = filteredEntries[i]
                                    appModel.deleteEntry(entry)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("All Entries")
                            Spacer()
                            Button {
                                showFavoritesOnly.toggle()
                                Haptics.tap()
                            } label: {
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .foregroundStyle(showFavoritesOnly ? Color.qmAccent : .secondary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, prompt: "Search entries")
            }
            .navigationTitle("Gratitude Wall")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func entryRow(_ entry: GratEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.text)
                        .font(.body)
                        .foregroundStyle(.primary)
                    if let prompt = entry.promptUsed {
                        Text(prompt)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    Text(entry.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                Button {
                    appModel.toggleFavorite(entry)
                    Haptics.tap()
                } label: {
                    Image(systemName: entry.favorite ? "heart.fill" : "heart")
                        .foregroundStyle(entry.favorite ? Color.qmAccent : Color.secondary)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}
