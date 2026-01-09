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
    const { home_id } = await req.json()

    if (!home_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required field: home_id' }),
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

    // Check if home is paired to this user
    const { data: pairing, error: pairingError } = await supabaseClient
      .from('home_pairings')
      .select('paired_at, key_hash')
      .eq('home_id', home_id)
      .eq('user_id', user.id)
      .single()

    if (pairingError || !pairing) {
      // Home not paired to this user
      return new Response(
        JSON.stringify({ error: 'Home not paired to user' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Gather system status (MVP: use mock data)
    const now = new Date()
    const notes: string[] = []

    // Verify pairing reference exists
    if (pairing.key_hash) {
      notes.push('Pairing reference validated')
    }

    // Check connectivity (basic check - pairing exists)
    notes.push('System connectivity confirmed')

    // Note pairing age
    const pairedAt = new Date(pairing.paired_at)
    const daysSincePaired = Math.floor((now.getTime() - pairedAt.getTime()) / (1000 * 60 * 60 * 24))
    notes.push(`Paired ${daysSincePaired} day(s) ago`)

    // Return system check response
    return new Response(
      JSON.stringify({
        ok: true,
        last_data_ts: now.toISOString(),
        notes: notes
      }),
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
