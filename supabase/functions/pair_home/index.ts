import { createClient } from 'npm:supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Validate authentication
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client with user context
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader }
        }
      }
    )

    // Verify user authentication
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid authentication' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse and validate request body
    const { home_id, mcp_api_key } = await req.json()

    if (!home_id || !mcp_api_key) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: home_id, mcp_api_key' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate home_id format (UUID)
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    if (!uuidRegex.test(home_id)) {
      return new Response(
        JSON.stringify({ error: 'Invalid home_id format' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Stub: Validate MCP API key format (basic check for MVP)
    if (typeof mcp_api_key !== 'string' || mcp_api_key.length < 10) {
      return new Response(
        JSON.stringify({ error: 'Invalid MCP API key' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // TODO: Check user has access to home_id (RLS will handle this when homes table exists)
    // For MVP, we assume user can pair any home_id they provide

    // Hash the MCP API key (never store plaintext)
    const encoder = new TextEncoder()
    const data = encoder.encode(mcp_api_key)
    const hashBuffer = await crypto.subtle.digest('SHA-256', data)
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const keyHash = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')

    // Store the pairing with hashed key reference
    // Using a simple metadata table approach for MVP
    const { error: insertError } = await supabaseClient
      .from('home_pairings')
      .upsert({
        home_id,
        user_id: user.id,
        key_hash: keyHash,
        paired_at: new Date().toISOString(),
      }, {
        onConflict: 'home_id,user_id'
      })

    if (insertError) {
      // If table doesn't exist yet, that's a server configuration issue
      console.error('Database error:', insertError)
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Success response
    return new Response(
      JSON.stringify({ paired: true }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    // Catch-all error handler
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
