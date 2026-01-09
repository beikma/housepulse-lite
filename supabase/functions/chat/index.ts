import { createClient } from 'npm:supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

// Free-tier message limit per user per day (MVP placeholder)
const FREE_TIER_DAILY_LIMIT = 50

interface Message {
  role: string
  content: string
}

interface ToolEvent {
  tool: string
  status: string
}

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
    const { home_id, locale, messages } = await req.json()

    if (!home_id || !messages || !Array.isArray(messages)) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: home_id, messages' }),
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
      .select('id')
      .eq('home_id', home_id)
      .eq('user_id', user.id)
      .single()

    if (pairingError || !pairing) {
      return new Response(
        JSON.stringify({ error: 'Home not paired to user' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check rate limiting (MVP: simple daily counter)
    const today = new Date().toISOString().split('T')[0]
    const { data: usageData, error: usageError } = await supabaseClient
      .from('chat_usage')
      .select('message_count')
      .eq('user_id', user.id)
      .eq('date', today)
      .single()

    let currentCount = 0
    if (!usageError && usageData) {
      currentCount = usageData.message_count || 0
    }

    // Enforce free-tier limit
    if (currentCount >= FREE_TIER_DAILY_LIMIT) {
      return new Response(
        JSON.stringify({ error: 'Free-tier message limit exceeded' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update usage counter
    await supabaseClient
      .from('chat_usage')
      .upsert({
        user_id: user.id,
        date: today,
        message_count: currentCount + 1,
      }, {
        onConflict: 'user_id,date'
      })

    // Process messages through tool routing (MVP stub)
    const toolEvents: ToolEvent[] = []
    let reply = ''

    // Extract user's latest message
    const userMessage = messages.filter((m: Message) => m.role === 'user').pop()
    const userContent = userMessage?.content || ''

    // Simple tool routing stub - detect if tools should be called
    if (userContent.toLowerCase().includes('temperature') ||
        userContent.toLowerCase().includes('sensor') ||
        userContent.toLowerCase().includes('data')) {
      // Simulate tool execution
      toolEvents.push({
        tool: 'mcp_get_sensor_data',
        status: 'success'
      })

      reply = locale?.startsWith('de')
        ? 'Ich habe die Sensordaten für Ihr Zuhause abgerufen. Die aktuelle Temperatur beträgt 21°C.'
        : 'I retrieved the sensor data for your home. The current temperature is 21°C.'
    } else {
      // Generic response
      reply = locale?.startsWith('de')
        ? 'Verstanden. Wie kann ich Ihnen weiter helfen?'
        : 'Understood. How can I help you further?'
    }

    // Return chat response
    return new Response(
      JSON.stringify({
        reply,
        ...(toolEvents.length > 0 && { tool_events: toolEvents })
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
