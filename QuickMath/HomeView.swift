import SwiftUI

struct HomeView: View {
    var forceScreen: String? = nil

    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store

    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var showInsights = false
    @State private var showGrid = false

    var body: some View {
        ZStack {
            QMBackground()
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Gratile")
                                .font(.largeTitle.weight(.bold))
                            Text("One good thing a day")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .foregroundStyle(Color.qmAccent)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Streak + entry count metrics
                    HStack(spacing: 12) {
                        MetricTile(value: "\(appModel.streak)", label: "Day Streak")
                        MetricTile(value: "\(appModel.entries.count)", label: "Entries")
                    }
                    .padding(.horizontal)

                    // Today card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Today")
                                .font(.headline.weight(.semibold))
                            Spacer()
                            if appModel.todayEntry != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.qmCorrect)
                            }
                        }

                        if let entry = appModel.todayEntry {
                            Text(entry.text)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button("Edit") {
                                showGrid = true
                            }
                            .softButton()
                        } else {
                            Text(appModel.todayPrompt)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button("Write Today's Entry") {
                                showGrid = true
                            }
                            .prominentButton()
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .qmCard()
                    .padding(.horizontal)

                    // Recent entries (last 3 preview)
                    if !appModel.freeEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent")
                                    .font(.headline.weight(.semibold))
                                Spacer()
                            }

                            ForEach(Array(appModel.freeEntries.prefix(3))) { entry in
                                recentRow(entry)
                            }
                        }
                        .qmCard()
                        .padding(.horizontal)
                    }

                    // Pro tile
                    proTile
                        .padding(.horizontal)

                    Spacer(minLength: 32)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
                .environmentObject(appModel)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showInsights) {
            InsightsView()
                .environmentObject(appModel)
                .environmentObject(store)
        }
        .sheet(isPresented: $showGrid) {
            GridView()
                .environmentObject(appModel)
                .environmentObject(store)
        }
        .onAppear {
            if let screen = forceScreen {
                if screen == "paywall" { showPaywall = true }
                else if screen == "insights" { showInsights = true }
                else if screen == "grid" { showGrid = true }
            }
        }
    }

    @ViewBuilder
    private func recentRow(_ entry: GratEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                    .font(.subheadline)
                    .lineLimit(2)
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if entry.favorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.qmAccent)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    private var proTile: some View {
        Button {
            if store.isPro { showInsights = true } else { showPaywall = true }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: store.isPro ? "chart.bar.fill" : "lock.fill")
                    .font(.title2)
                    .foregroundStyle(Color.qmAccent)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.isPro ? "Your Gratitude Wall" : "Gratile Pro")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(store.isPro
                         ? "Unlimited history, search, on-this-day"
                         : "Unlimited wall · Prompts · On-this-day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .qmCard()
        }
        .buttonStyle(.plain)
    }
}
