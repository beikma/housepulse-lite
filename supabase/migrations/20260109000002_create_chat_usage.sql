-- Create chat_usage table
-- Tracks daily message counts per user for free-tier rate limiting

CREATE TABLE IF NOT EXISTS chat_usage (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  message_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, date)
);

-- Enable Row Level Security
ALTER TABLE chat_usage ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view their own usage
CREATE POLICY "Users can view own usage"
  ON chat_usage
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own usage
CREATE POLICY "Users can insert own usage"
  ON chat_usage
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own usage
CREATE POLICY "Users can update own usage"
  ON chat_usage
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Index for faster lookups
CREATE INDEX idx_chat_usage_user_date ON chat_usage(user_id, date);
