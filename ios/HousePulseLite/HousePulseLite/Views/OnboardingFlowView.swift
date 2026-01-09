import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @State private var currentStep = 0

    var body: some View {
        NavigationView {
            VStack {
                // Progress indicator
                ProgressView(value: Double(currentStep), total: 2)
                    .padding()

                TabView(selection: $currentStep) {
                    // Step 1: Home Selection
                    HomeSelectionView(currentStep: $currentStep)
                        .tag(0)

                    // Step 2: MCP Key Entry and Pairing
                    MCPKeyEntryView(currentStep: $currentStep)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .disabled(onboardingViewModel.isLoading)
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Home Selection View
struct HomeSelectionView: View {
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @Binding var currentStep: Int

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "house.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Select Your Home")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Choose the home you want to pair with HousePulse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()

            // Home list
            List(onboardingViewModel.availableHomes) { home in
                Button(action: {
                    onboardingViewModel.selectedHome = home
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(home.name)
                                .font(.headline)
                            if let address = home.address {
                                Text(address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        if onboardingViewModel.selectedHome?.id == home.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }

            // Continue button
            Button(action: {
                withAnimation {
                    currentStep = 1
                }
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(onboardingViewModel.selectedHome != nil ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(onboardingViewModel.selectedHome == nil)
            .padding()
        }
    }
}

// MARK: - MCP Key Entry View
struct MCPKeyEntryView: View {
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var currentStep: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Enter MCP API Key")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("This key will be securely stored and used to connect your home")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                // Selected home info
                if let home = onboardingViewModel.selectedHome {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Home")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.blue)
                            Text(home.name)
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }

                // API Key input
                VStack(alignment: .leading, spacing: 8) {
                    Text("MCP API Key")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SecureField("Enter your MCP API key", text: $onboardingViewModel.mcpApiKey)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Text("Your API key will be encrypted and stored securely in the iOS Keychain")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Error message
                if let errorMessage = onboardingViewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // Success message
                if onboardingViewModel.isPaired,
                   let systemCheck = onboardingViewModel.systemCheckResponse {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title)
                            Text("Pairing Successful!")
                                .font(.headline)
                                .foregroundColor(.green)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("System Status")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(systemCheck.notes, id: \.self) { note in
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(note)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                }

                // Action buttons
                VStack(spacing: 12) {
                    if onboardingViewModel.isPaired {
                        // Success - button to continue to app (will be handled by RootView)
                        Text("Setup complete! Loading your home...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        // Pair Home button
                        Button(action: {
                            Task {
                                await onboardingViewModel.pairHome()
                            }
                        }) {
                            HStack {
                                if onboardingViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Pair Home")
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(onboardingViewModel.mcpApiKey.isEmpty || onboardingViewModel.isLoading)

                        // Back button
                        Button(action: {
                            withAnimation {
                                currentStep = 0
                            }
                        }) {
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                        .disabled(onboardingViewModel.isLoading)

                        // Retry button (if error)
                        if onboardingViewModel.errorMessage != nil {
                            Button(action: {
                                onboardingViewModel.retry()
                            }) {
                                Text("Retry")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()

                Spacer()
            }
        }
    }
}
