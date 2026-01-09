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
