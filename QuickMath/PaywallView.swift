import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    private let benefits: [String] = [
        "Unlimited lifetime gratitude wall with search",
        "Fresh themed prompt packs added monthly",
        "On-this-day resurfacing and daily reminder"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                ScrollView {
                    VStack(spacing: 28) {
                        // Icon area
                        ZStack {
                            Circle()
                                .fill(Color.qmCard)
                                .frame(width: 88, height: 88)
                            Image(systemName: "hand.raised.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 42, height: 42)
                                .foregroundStyle(Color.qmAccent)
                        }
                        .padding(.top, 8)

                        // Title + subtitle
                        VStack(spacing: 8) {
                            Text("Gratile Pro")
                                .font(.title.weight(.bold))
                            Text("$0.99 / month. Auto-renews until you cancel.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        // Benefits
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(benefits, id: \.self) { benefit in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.qmAccent)
                                        .font(.body)
                                    Text(benefit)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .qmCard()
                        .padding(.horizontal)

                        // Unlock button
                        Button {
                            Task { await store.purchase() }
                            Haptics.tap()
                        } label: {
                            if store.purchaseInFlight {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Unlock Gratile Pro — \(store.displayPrice)/mo")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .prominentButton()
                        .padding(.horizontal)
                        .disabled(store.purchaseInFlight)

                        // Restore
                        Button("Restore Purchase") {
                            Task { await store.restore() }
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.qmAccent)

                        // Manage subscription
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            Link("Manage Subscription", destination: url)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Disclosure
                        VStack(spacing: 8) {
                            Text("Gratile Pro is a $0.99/month auto-renewable subscription. Your subscription will automatically renew at the same price unless you cancel at least 24 hours before the end of the current period. You can manage or cancel your subscription at any time in your App Store account settings.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 16) {
                                if let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                    Link("Terms of Service", destination: termsURL)
                                        .font(.caption2)
                                        .foregroundStyle(Color.qmAccent)
                                }
                                if let privacyURL = URL(string: "https://shimondeitel.github.io/gratile-site/privacy.html") {
                                    Link("Privacy Policy", destination: privacyURL)
                                        .font(.caption2)
                                        .foregroundStyle(Color.qmAccent)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: store.isPro) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }
}
