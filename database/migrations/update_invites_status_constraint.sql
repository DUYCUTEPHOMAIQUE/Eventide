-- Update invites table status constraint to allow going, notgoing, maybe
-- Drop the old constraint
ALTER TABLE public.invites DROP CONSTRAINT IF EXISTS invites_status_check;

-- Add new constraint with updated values
ALTER TABLE public.invites ADD CONSTRAINT invites_status_check 
CHECK (status IN ('pending', 'going', 'notgoing', 'maybe', 'cancelled'));

-- Optional: Update existing data if needed
-- UPDATE public.invites SET status = 'going' WHERE status = 'accepted';
-- UPDATE public.invites SET status = 'notgoing' WHERE status = 'declined';
-- UPDATE public.invites SET status = 'maybe' WHERE status = 'undecided'; 