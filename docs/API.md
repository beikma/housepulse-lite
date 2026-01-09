# HousePulse Lite API Documentation

## Overview

HousePulse Lite provides a backend API for smart home assistant functionality via Supabase Edge Functions. All endpoints require authentication with a Supabase JWT token.

**Base URL**: `https://your-project.supabase.co/functions/v1`

## Authentication

All API requests require a valid Supabase JWT token in the `Authorization` header:

```
Authorization: Bearer <your-jwt-token>
```

Tokens are obtained through Supabase Auth (Apple Sign-In or email/password authentication).

## Security

- **MCP API keys are never returned** in any API response
- API keys are hashed (SHA-256) before server-side storage
- Row Level Security (RLS) ensures users can only access their own data
- All endpoints validate user authentication before processing

## Endpoints

### POST /pair_home

Pairs a home with the authenticated user by validating and storing an MCP API key reference.

**Authentication**: Required

**Request Body**:
```json
{
  "home_id": "550e8400-e29b-41d4-a716-446655440000",
  "mcp_api_key": "your-mcp-api-key-here"
}
```

**Parameters**:
- `home_id` (string, required): UUID of the home to pair
- `mcp_api_key` (string, required): MCP API key for the home (minimum 10 characters)

**Success Response** (200 OK):
```json
{
  "paired": true
}
```

**Error Responses**:

| Status Code | Description | Example Response |
|-------------|-------------|------------------|
| 401 Unauthorized | Missing or invalid authentication | `{"error": "Missing authorization"}` |
| 403 Forbidden | User lacks access to home | `{"error": "Forbidden"}` |
| 422 Unprocessable Entity | Invalid input (missing fields, invalid UUID, invalid MCP key) | `{"error": "Invalid home_id format"}` |
| 500 Internal Server Error | Server configuration or unexpected errors | `{"error": "Internal server error"}` |

**Notes**:
- MCP API key is hashed using SHA-256 before storage
- API key is never stored in plaintext
- API key is never returned in responses
- Pairing is bound to both user_id and home_id

---

### POST /system_check

Lightweight health verification for paired homes. Confirms proper pairing and validates backend data access.

**Authentication**: Required

**Request Body**:
```json
{
  "home_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Parameters**:
- `home_id` (string, required): UUID of the home to check

**Success Response** (200 OK):
```json
{
  "ok": true,
  "last_data_ts": "2026-01-09T12:34:56.789Z",
  "notes": [
    "Pairing reference validated",
    "System connectivity confirmed",
    "Paired 5 day(s) ago"
  ]
}
```

**Response Fields**:
- `ok` (boolean): System health status
- `last_data_ts` (string): ISO 8601 timestamp of last data update
- `notes` (array of strings): Human-readable system status messages

**Error Responses**:

| Status Code | Description | Example Response |
|-------------|-------------|------------------|
| 401 Unauthorized | Missing or invalid authentication | `{"error": "Invalid authentication"}` |
| 403 Forbidden | User lacks access to home | `{"error": "Forbidden"}` |
| 422 Unprocessable Entity | Home not paired to user or invalid input | `{"error": "Home not paired to user"}` |
| 500 Internal Server Error | Server configuration or unexpected errors | `{"error": "Internal server error"}` |

**Notes**:
- Requires home to be paired via `/pair_home` first
- Verifies home belongs to authenticated user
- Never discloses credentials or API keys

---

### POST /chat

AI chat interface with MCP-based backend tool routing for home automation assistance.

**Authentication**: Required

**Request Body**:
```json
{
  "home_id": "550e8400-e29b-41d4-a716-446655440000",
  "locale": "de-DE",
  "messages": [
    {
      "role": "user",
      "content": "What is the current temperature?"
    },
    {
      "role": "assistant",
      "content": "The current temperature is 21°C."
    },
    {
      "role": "user",
      "content": "Thank you"
    }
  ]
}
```

**Parameters**:
- `home_id` (string, required): UUID of the home
- `locale` (string, optional): User's locale preference (e.g., "de-DE", "en-US")
- `messages` (array, required): Conversation history
  - Each message must have:
    - `role` (string): Either "user" or "assistant"
    - `content` (string): Message text

**Success Response** (200 OK):
```json
{
  "reply": "Understood. How can I help you further?",
  "tool_events": [
    {
      "tool": "mcp_get_sensor_data",
      "status": "success"
    }
  ]
}
```

**Response Fields**:
- `reply` (string): Assistant's textual response
- `tool_events` (array, optional): Array of tool execution events
  - `tool` (string): Name of the tool executed
  - `status` (string): Execution status (e.g., "success", "failed")

**Error Responses**:

| Status Code | Description | Example Response |
|-------------|-------------|------------------|
| 401 Unauthorized | Missing or invalid authentication | `{"error": "Missing authorization"}` |
| 403 Forbidden | User lacks access to home | `{"error": "Forbidden"}` |
| 422 Unprocessable Entity | Home not paired to user or invalid input | `{"error": "Home not paired to user"}` |
| 429 Too Many Requests | Free-tier message limit exceeded (50 messages/day) | `{"error": "Free-tier message limit exceeded"}` |
| 500 Internal Server Error | Server configuration or unexpected errors | `{"error": "Internal server error"}` |

**Rate Limiting**:
- Free-tier: 50 messages per day per user
- Enforced server-side with automatic counter tracking
- Counter resets daily at midnight UTC

**Notes**:
- Requires home to be paired via `/pair_home` first
- Streaming is not supported in MVP
- Tool routing is based on message content
- Locale-aware responses (supports German and English)
- Never discloses credentials or API keys

---

## Error Handling

All endpoints follow consistent error response format:

```json
{
  "error": "Human-readable error message"
}
```

### Common HTTP Status Codes

- **200 OK**: Request successful
- **401 Unauthorized**: Missing or invalid authentication token
- **403 Forbidden**: User lacks permission to access resource
- **422 Unprocessable Entity**: Invalid input or business logic constraint violated
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Unexpected server error

### Best Practices

1. **Always include Authorization header** with valid JWT token
2. **Validate input client-side** before sending requests
3. **Handle rate limits gracefully** - display upgrade messaging for 429 errors
4. **Implement retry logic** for network errors (not for 4xx errors)
5. **Never log or display** sensitive data (API keys, tokens)

## Data Privacy

- MCP API keys are **never** returned in API responses
- API keys are **hashed** (SHA-256) before storage
- User data is protected by **Row Level Security** (RLS)
- No tracking or analytics on backend
- See [PRIVACY.md](PRIVACY.md) for full privacy policy

## Database Schema

### home_pairings

Stores pairing status between users and homes.

```sql
CREATE TABLE home_pairings (
  id UUID PRIMARY KEY,
  home_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  key_hash TEXT NOT NULL,  -- SHA-256 hash, never plaintext
  paired_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  UNIQUE(home_id, user_id)
);
```

### chat_usage

Tracks daily message counts for rate limiting.

```sql
CREATE TABLE chat_usage (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  date DATE NOT NULL,
  message_count INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  UNIQUE(user_id, date)
);
```

## Support

For issues or questions:
- GitHub Issues: https://github.com/beikma/housepulse-lite/issues
- Email: [Contact placeholder - to be added]

---

**Project by Exafion**
