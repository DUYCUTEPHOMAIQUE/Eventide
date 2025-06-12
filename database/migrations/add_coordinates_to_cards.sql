-- Migration: Add latitude and longitude to cards table
-- Run this in Supabase SQL Editor

-- Add latitude and longitude columns to cards table
ALTER TABLE cards 
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- Add index for geospatial queries (optional but recommended for performance)
CREATE INDEX IF NOT EXISTS cards_coordinates_idx ON cards (latitude, longitude);

-- Add a check constraint to ensure both lat/lng are provided together or both are null
-- This ensures data consistency
ALTER TABLE cards 
ADD CONSTRAINT check_coordinates_consistency 
CHECK (
  (latitude IS NULL AND longitude IS NULL) OR 
  (latitude IS NOT NULL AND longitude IS NOT NULL)
);

-- Add comment to document the new columns
COMMENT ON COLUMN cards.latitude IS 'GPS latitude coordinate in decimal degrees';
COMMENT ON COLUMN cards.longitude IS 'GPS longitude coordinate in decimal degrees';

-- Optional: Add a view for cards with location info
CREATE OR REPLACE VIEW cards_with_location AS
SELECT 
  *,
  CASE 
    WHEN latitude IS NOT NULL AND longitude IS NOT NULL 
    THEN TRUE 
    ELSE FALSE 
  END as has_coordinates,
  CASE 
    WHEN latitude IS NOT NULL AND longitude IS NOT NULL 
    THEN CONCAT(latitude::text, ', ', longitude::text)
    ELSE NULL 
  END as coordinates_string
FROM cards;

-- Grant permissions (adjust based on your RLS policies)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON cards_with_location TO authenticated; 