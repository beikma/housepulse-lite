# HousePulse Lite - iOS App

Native iOS application for HousePulse Lite smart home assistant.

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Architecture

### MVVM Pattern
- **Models**: Data structures for Home, User, API requests/responses
- **ViewModels**: Business logic for authentication and onboarding
- **Views**: SwiftUI user interface components
- **Services**: Keychain, Supabase client, API communication

### Key Components

#### Authentication
- **Apple Sign-In**: Primary authentication method using ASAuthorizationController
- **Email/Password**: Fallback authentication for testing
- **Supabase Auth**: Backend authentication service

#### Onboarding Flow
1. **Sign In**: User authenticates with Apple or email
2. **Home Selection**: User selects from mock home list
3. **MCP API Key**: User enters MCP API key for home pairing
4. **Keychain Storage**: API key stored securely in iOS Keychain
5. **Pair Home**: Calls `/functions/v1/pair_home` edge function
6. **System Check**: Calls `/functions/v1/system_check` to verify pairing
7. **Success**: User gains access to chat interface

#### Chat Interface
- **Messenger-style Bubbles**: User messages (blue, right-aligned) vs assistant messages (gray, left-aligned)
- **Quick Action Chips**: Four German-labeled quick actions:
  - „Status-Check" - System status inquiry
  - „Risiken / Wartung" - Risks and maintenance check
  - „Energie sparen" - Energy saving tips
  - „ESCO-Compliance prüfen" - ESCO compliance verification
- **Typing Indicator**: Animated dots while waiting for assistant response
- **Tool Events**: Display of backend tool executions (e.g., sensor data retrieval)
- **Rate Limiting**:
  - Client-side counter displays usage (UX only)
  - Server enforces 50 messages/day limit
  - Upgrade hint displayed when limit reached (HTTP 429)
- **Read-Only Badge**: Indicates current MVP limitations
- **Usage Counter**: Shows messages used today (e.g., "15/50 heute")
- **Privacy View**: Accessible via info button in toolbar
  - Displays privacy policy in German and English
  - Shows data processing information
  - Explains MCP API key security

#### Privacy & Data
- **In-App Privacy Screen**: Bilingual privacy policy accessible from chat toolbar
- **No Tracking**: No analytics, ads, or data selling
- **Secure Storage**: MCP API keys stored in iOS Keychain, hashed (SHA-256) server-side
- **Data Minimization**: Only essential data processed (auth, home_id, messages, usage counters)
- **Full Transparency**: See [docs/PRIVACY.md](../docs/PRIVACY.md) for complete policy

## Setup Instructions

### 1. Configure Supabase

Update `ios/HousePulseLite/HousePulseLite/Config/SupabaseConfig.swift`:

```swift
struct SupabaseConfig {
    static let url = "https://your-project.supabase.co"
    static let anonKey = "your-anon-key"
}
```

### 2. Enable Sign in with Apple

In Xcode:
1. Select the HousePulseLite target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "Sign in with Apple"

### 3. Configure Bundle Identifier

Update the bundle identifier to match your Apple Developer account:
1. Select the HousePulseLite target
2. Go to "Signing & Capabilities"
3. Update "Bundle Identifier" (e.g., `com.yourcompany.housepulse-lite`)

### 4. Run the App

1. Open `HousePulseLite.xcodeproj` in Xcode
2. Select a simulator or device
3. Click Run (⌘R)

## Project Structure

```
ios/HousePulseLite/HousePulseLite/
├── HousePulseLiteApp.swift       # App entry point
├── Config/
│   └── SupabaseConfig.swift      # Supabase configuration
├── Models/
│   ├── Home.swift                # Home data model
│   ├── User.swift                # User data model
│   ├── ChatMessage.swift         # Chat message & tool event models
│   └── APIModels.swift           # API request/response models
├── Services/
│   ├── KeychainService.swift     # Secure storage for API keys
│   └── SupabaseService.swift     # Supabase client & API calls
├── ViewModels/
│   ├── AuthViewModel.swift       # Authentication logic
│   ├── OnboardingViewModel.swift # Onboarding flow logic
│   └── ChatViewModel.swift       # Chat state & message handling
└── Views/
    ├── RootView.swift            # Root navigation
    ├── SignInView.swift          # Authentication screen
    ├── OnboardingFlowView.swift  # Onboarding wizard
    ├── ChatView.swift            # Main chat interface
    ├── MessageBubbleView.swift   # Message bubbles & typing indicator
    ├── PrivacyView.swift         # Privacy & data policy screen
    └── MainAppView.swift         # Legacy success screen
```

## Security Features

### Keychain Storage
MCP API keys are stored in iOS Keychain with:
- Service identifier: `com.housepulse.lite`
- Account key: `mcp_api_key_{homeId}`
- Accessibility: `kSecAttrAccessibleAfterFirstUnlock`

### Authentication
- JWT tokens managed by Supabase Auth
- Tokens included in `Authorization` header for all API calls
- No plaintext storage of credentials

## API Integration

### Edge Functions

All backend communication uses Supabase Edge Functions:

#### POST /functions/v1/pair_home
```json
Request:
{
  "home_id": "uuid",
  "mcp_api_key": "key"
}

Response:
{
  "paired": true
}
```

#### POST /functions/v1/system_check
```json
Request:
{
  "home_id": "uuid"
}

Response:
{
  "ok": true,
  "last_data_ts": "2026-01-09T12:34:56.789Z",
  "notes": ["Pairing reference validated", "..."]
}
```

#### POST /functions/v1/chat
```json
Request:
{
  "home_id": "uuid",
  "locale": "de-DE",
  "messages": [
    { "role": "user", "content": "What is the temperature?" },
    { "role": "assistant", "content": "The temperature is 21°C" }
  ]
}

Response:
{
  "reply": "I retrieved the sensor data. Current temperature is 21°C.",
  "tool_events": [
    { "tool": "mcp_get_sensor_data", "status": "success" }
  ]
}
```

**Note**: `tool_events` is optional and only included when tools are executed. Rate limit exceeded returns HTTP 429.

## Error Handling

The app handles the following error scenarios:
- **401 Unauthorized**: User not authenticated or invalid token
- **403 Forbidden**: User lacks access to home
- **422 Unprocessable Entity**: Invalid input or home not paired
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Backend error

Each error displays a user-friendly message with retry option.

## Development Notes

### Mock Data
- Home list uses mock data (`Home.mockHomes`)
- Replace with real API calls in production

### Future Enhancements
- Chat interface integration
- Sensor data visualization
- Push notifications
- Home management (add/remove homes)
- Settings and preferences

## Testing

### Test Accounts
Create test users in Supabase Dashboard:
1. Go to Authentication > Users
2. Add new user with email/password
3. Use credentials in email sign-in flow

### Test Flow
1. Launch app
2. Sign in with Apple or test email
3. Select "My Home" from mock list
4. Enter test MCP API key
5. Verify pairing succeeds
6. Check system status displays correctly

## Troubleshooting

### Sign in with Apple fails
- Ensure capability is enabled in Xcode
- Check bundle identifier matches Developer Portal
- Verify Apple ID is configured on device/simulator

### API calls fail
- Verify Supabase URL and anon key are correct
- Check network connectivity
- Review Supabase Edge Function logs
- Ensure authentication token is valid

### Keychain errors
- Reset simulator: Device > Erase All Content and Settings
- Check app has proper entitlements
- Verify service identifier matches

## License

MIT
