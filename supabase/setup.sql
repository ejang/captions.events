-- Complete database setup for Captions Events
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/_/sql

-- ============================================
-- 1. CREATE EVENTS TABLE
-- ============================================

-- Create events table for storing live caption events
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  creator_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on uid for fast lookups
CREATE INDEX IF NOT EXISTS idx_events_uid ON events(uid);

-- Create index on creator_id for user's events
CREATE INDEX IF NOT EXISTS idx_events_creator_id ON events(creator_id);

-- Enable Row Level Security
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all events
CREATE POLICY "Events are viewable by everyone"
  ON events FOR SELECT
  USING (true);

-- Policy: Users can insert their own events
CREATE POLICY "Users can create events"
  ON events FOR INSERT
  WITH CHECK (auth.uid() = creator_id);

-- Policy: Users can update their own events
CREATE POLICY "Users can update their own events"
  ON events FOR UPDATE
  USING (auth.uid() = creator_id);

-- Policy: Users can delete their own events
CREATE POLICY "Users can delete their own events"
  ON events FOR DELETE
  USING (auth.uid() = creator_id);


-- ============================================
-- 2. CREATE CAPTIONS TABLE
-- ============================================

-- Create captions table for storing live captions
CREATE TABLE IF NOT EXISTS captions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sequence_number INTEGER NOT NULL,
  is_final BOOLEAN DEFAULT false,
  language_code TEXT
);

-- Create index on event_id for fast lookups
CREATE INDEX IF NOT EXISTS idx_captions_event_id ON captions(event_id);

-- Create index on timestamp for ordering
CREATE INDEX IF NOT EXISTS idx_captions_timestamp ON captions(timestamp);

-- Create index on language_code for potential filtering/grouping
CREATE INDEX IF NOT EXISTS idx_captions_language_code ON captions(language_code);

-- Enable Row Level Security
ALTER TABLE captions ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view captions
CREATE POLICY "Captions are viewable by everyone"
  ON captions FOR SELECT
  USING (true);

-- Policy: Only event creators can insert captions
CREATE POLICY "Event creators can add captions"
  ON captions FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM events
      WHERE events.id = event_id
      AND events.creator_id = auth.uid()
    )
  );

-- Turn on realtime for the captions table
ALTER PUBLICATION supabase_realtime ADD TABLE captions;


-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Verify tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('events', 'captions');

-- Verify RLS policies
SELECT tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('events', 'captions');
