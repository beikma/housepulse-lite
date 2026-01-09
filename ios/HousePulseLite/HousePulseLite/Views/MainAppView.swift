import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Success header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text("Welcome to HousePulse!")
                        .font(.title)
                        .fontWeight(.bold)

                    if let home = onboardingViewModel.selectedHome {
                        Text("Connected to \(home.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                // System status
                if let systemCheck = onboardingViewModel.systemCheckResponse {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("System Status")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            StatusRow(
                                icon: "checkmark.circle.fill",
                                text: "System OK",
                                color: .green
                            )

                            StatusRow(
                                icon: "clock.fill",
                                text: "Last updated: \(formatDate(systemCheck.lastDataTs))",
                                color: .blue
                            )

                            ForEach(systemCheck.notes, id: \.self) { note in
                                StatusRow(
                                    icon: "info.circle.fill",
                                    text: note,
                                    color: .blue
                                )
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()

                // Placeholder for future features
                VStack(spacing: 16) {
                    Text("Main app features coming soon!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Chat, sensor monitoring, and more will be available here.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()

                // Sign out button
                Button(action: {
                    authViewModel.signOut()
                    onboardingViewModel.reset()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else {
            return isoString
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

struct StatusRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
        }
    }
}
