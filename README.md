# HousePulse Lite

Chat-first iOS application for smart building operations.

## Scope (MVP)
- Native iOS app (SwiftUI, iOS 16+)
- AI chat as primary interface
- Read-only monitoring
- MCP-based backend services via Supabase Edge Functions
- No direct DB access from client
- Focus on:
  - Predictive maintenance
  - Energy optimization (tariffs, weather)
  - ESCO compliance (e.g. Tmin 20°C from 08:00–17:00)

## Architecture
- iOS App → Supabase Auth
- iOS App → Supabase Edge Functions (BFF)
- No direct Postgres access from iOS
- MCP API key stored only in iOS Keychain
- One-time pairing flow

## Status
- Sprint 0: Backend contracts + Chat-only app

## Documentation
- **[API Documentation](docs/API.md)** - Complete API reference for all edge functions
- **[Privacy Policy](docs/PRIVACY.md)** - Privacy and data handling (EN + DE)
- **[iOS App README](ios/README.md)** - iOS app setup and architecture

## Project by Exafion
