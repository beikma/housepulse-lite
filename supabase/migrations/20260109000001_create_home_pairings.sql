-- Create home_pairings table
-- Stores pairing status between users and homes with hashed MCP API key reference

CREATE TABLE IF NOT EXISTS home_pairings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  home_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  key_hash TEXT NOT NULL,
  paired_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(home_id, user_id)
);

-- Enable Row Level Security
ALTER TABLE home_pairings ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view their own pairings
CREATE POLICY "Users can view own pairings"
  ON home_pairings
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own pairings
CREATE POLICY "Users can insert own pairings"
  ON home_pairings
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own pairings
CREATE POLICY "Users can update own pairings"
  ON home_pairings
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Index for faster lookups
CREATE INDEX idx_home_pairings_user_id ON home_pairings(user_id);
CREATE INDEX idx_home_pairings_home_id ON home_pairings(home_id);
