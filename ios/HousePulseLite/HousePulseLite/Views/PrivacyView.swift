import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Datenschutz & Daten")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Privacy & Data")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("Ein Projekt von Exafion")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 8)

                    Divider()

                    // German Version
                    PrivacySectionView(
                        title: "Unser Engagement für den Datenschutz",
                        content: "HousePulse Lite wurde mit Datenschutz als Kernprinzip entwickelt. Wir verfolgen keine Benutzer, schalten keine Werbung und verkaufen keine Daten an Dritte.",
                        icon: "hand.raised.fill",
                        color: .blue
                    )

                    PrivacySectionView(
                        title: "Welche Daten wir verarbeiten",
                        content: """
                        • Authentifizierungsdaten (Supabase Auth)
                        • Heim-ID zur Identifizierung Ihres Hauses
                        • Chat-Nachrichten (temporär für aktive Sitzungen)
                        • Tägliche Nutzungszähler (50 Nachrichten/Tag)
                        """,
                        icon: "doc.text.fill",
                        color: .green
                    )

                    PrivacySectionView(
                        title: "MCP-API-Schlüssel",
                        content: """
                        • iOS: Sicher im iOS Keychain gespeichert
                        • Server: Niemals im Klartext gespeichert
                        • Gehashed mit SHA-256 vor der Speicherung
                        • Niemals in API-Antworten zurückgegeben
                        """,
                        icon: "key.fill",
                        color: .orange
                    )

                    PrivacySectionView(
                        title: "Keine Verfolgung",
                        content: """
                        • Keine Analyse-Dienste (z.B. Google Analytics)
                        • Keine Werbenetzwerke
                        • Keine Datenmakler
                        • Server-Logs enthalten keine Geheimnisse
                        """,
                        icon: "eye.slash.fill",
                        color: .purple
                    )

                    Divider()

                    // English Version
                    Text("English Version")
                        .font(.headline)
                        .padding(.top, 8)

                    PrivacySectionView(
                        title: "Our Commitment to Privacy",
                        content: "HousePulse Lite is designed with privacy as a core principle. We do not track users, serve advertisements, or sell data to third parties.",
                        icon: "hand.raised.fill",
                        color: .blue
                    )

                    PrivacySectionView(
                        title: "What Data We Process",
                        content: """
                        • Authentication data (Supabase Auth)
                        • Home ID to identify your home
                        • Chat messages (temporary for active sessions)
                        • Daily usage counters (50 messages/day)
                        """,
                        icon: "doc.text.fill",
                        color: .green
                    )

                    PrivacySectionView(
                        title: "MCP API Key Storage",
                        content: """
                        • iOS: Securely stored in iOS Keychain
                        • Server: Never stored in plaintext
                        • Hashed with SHA-256 before storage
                        • Never returned in API responses
                        """,
                        icon: "key.fill",
                        color: .orange
                    )

                    PrivacySectionView(
                        title: "No Tracking",
                        content: """
                        • No analytics services (e.g., Google Analytics)
                        • No advertising networks
                        • No data brokers
                        • Server logs contain no secrets
                        """,
                        icon: "eye.slash.fill",
                        color: .purple
                    )

                    Divider()

                    // Contact & Links
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weitere Informationen / More Information")
                            .font(.headline)

                        Link(destination: URL(string: "https://github.com/beikma/housepulse-lite")!) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                Text("GitHub Repository")
                            }
                            .foregroundColor(.blue)
                        }

                        Text("Kontakt / Contact: [E-Mail wird hinzugefügt / Email to be added]")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Footer
                    VStack(spacing: 4) {
                        Text("Projekt von Exafion")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Project by Exafion")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Stand / Last Updated: Januar 2026")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Privacy Section View

struct PrivacySectionView: View {
    let title: String
    let content: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Text(title)
                    .font(.headline)
            }

            Text(content)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
