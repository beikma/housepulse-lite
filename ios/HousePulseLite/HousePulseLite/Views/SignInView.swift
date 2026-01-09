import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showEmailSignIn = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                // App logo and title
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)

                    Text("HousePulse Lite")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Smart Home Assistant")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)

                Spacer()

                // Sign in options
                VStack(spacing: 16) {
                    // Apple Sign In
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.email]
                            request.nonce = authViewModel.generateNonce()
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                Task {
                                    await authViewModel.signInWithApple(authorization: authorization)
                                }
                            case .failure(let error):
                                authViewModel.errorMessage = error.localizedDescription
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)

                    // Email sign in toggle
                    Button(action: {
                        showEmailSignIn.toggle()
                    }) {
                        Text(showEmailSignIn ? "Hide Email Sign In" : "Sign in with Email")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }

                    // Email sign in form
                    if showEmailSignIn {
                        VStack(spacing: 12) {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            SecureField("Password", text: $password)
                                .textContentType(.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            Button(action: {
                                Task {
                                    await authViewModel.signInWithEmail(
                                        email: email,
                                        password: password
                                    )
                                }
                            }) {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal)

                // Error message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Loading indicator
                if authViewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .animation(.default, value: showEmailSignIn)
    }
}
