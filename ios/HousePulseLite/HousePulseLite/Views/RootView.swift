import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if onboardingViewModel.isPaired,
                   let selectedHome = onboardingViewModel.selectedHome {
                    ChatView(homeId: selectedHome.id.uuidString)
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
