import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if onboardingViewModel.isPaired {
                    MainAppView()
                        .environmentObject(onboardingViewModel)
                } else {
                    OnboardingFlowView()
                        .environmentObject(onboardingViewModel)
                }
            } else {
                SignInView()
            }
        }
    }
}
