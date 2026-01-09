# Supabase Edge Functions

## pair_home

**Endpoint:** `POST /functions/v1/pair_home`

**Purpose:** Initial home pairing function that securely validates and stores MCP API credentials.

**Authentication:** Required (JWT in Authorization header)

**Request Body:**
```json
{
  "home_id": "uuid-string",
  "mcp_api_key": "string"
}
```

**Success Response:**
```json
{
  "paired": true
}
```

**Error Responses:**
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User lacks access to home (future implementation)
- `422 Unprocessable Entity` - Invalid input (missing fields, invalid UUID, invalid MCP key)
- `500 Internal Server Error` - Server configuration or unexpected errors

**Security:**
- MCP API keys are hashed using SHA-256 before storage
- API keys are never stored in plaintext
- API keys are never returned in responses
- Row Level Security (RLS) ensures users can only access their own pairings

**Database:**
Requires `home_pairings` table (see migrations).

## system_check

**Endpoint:** `POST /functions/v1/system_check`

**Purpose:** Lightweight health verification for paired homes that confirms proper pairing and validates backend data access functionality.

**Authentication:** Required (JWT in Authorization header)

**Request Body:**
```json
{
  "home_id": "uuid-string"
}
```

**Success Response:**
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

**Error Responses:**
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User lacks access to home
- `422 Unprocessable Entity` - Home not paired to user or invalid input
- `500 Internal Server Error` - Server configuration or unexpected errors

**Security:**
- Verifies home belongs to authenticated user
- Never discloses credentials or API keys
- Row Level Security (RLS) ensures proper access control

**Database:**
Requires `home_pairings` table (see migrations).
