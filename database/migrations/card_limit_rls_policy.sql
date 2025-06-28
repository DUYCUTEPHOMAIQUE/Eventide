-- Card Creation Limit RLS Policy
-- Enforce max 5 cards for free users

-- Function to check if user can create more cards
CREATE OR REPLACE FUNCTION can_create_card(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_limits JSONB;
    max_cards INTEGER;
    current_card_count INTEGER;
BEGIN
    -- Get user limits
    SELECT get_user_limits(p_user_id) INTO user_limits;
    
    -- Get max cards limit
    max_cards := (user_limits->>'max_cards')::INTEGER;
    
    -- If unlimited (-1), allow creation
    IF max_cards = -1 THEN
        RETURN TRUE;
    END IF;
    
    -- Count current cards for user
    SELECT COUNT(*) INTO current_card_count
    FROM cards 
    WHERE owner_id = p_user_id;
    
    -- Return true if under limit
    RETURN current_card_count < max_cards;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing insert policy if exists
DROP POLICY IF EXISTS "cards_insert_with_limit" ON cards;

-- Create new RLS policy for card insertion with limits
CREATE POLICY "cards_insert_with_limit" ON cards
    FOR INSERT TO authenticated 
    WITH CHECK (
        auth.uid() = owner_id 
        AND can_create_card(auth.uid())
    );

-- Function to get user's card usage summary
CREATE OR REPLACE FUNCTION get_card_usage_summary(p_user_id UUID)
RETURNS TABLE(
    current_cards INTEGER,
    max_cards INTEGER,
    can_create_more BOOLEAN,
    percentage_used NUMERIC
) AS $$
DECLARE
    user_limits JSONB;
    card_count INTEGER;
    limit_count INTEGER;
BEGIN
    -- Get user limits
    SELECT get_user_limits(p_user_id) INTO user_limits;
    limit_count := (user_limits->>'max_cards')::INTEGER;
    
    -- Count current cards
    SELECT COUNT(*) INTO card_count FROM cards WHERE owner_id = p_user_id;
    
    RETURN QUERY SELECT 
        card_count,
        limit_count,
        CASE 
            WHEN limit_count = -1 THEN TRUE 
            ELSE card_count < limit_count 
        END,
        CASE 
            WHEN limit_count = -1 THEN 0 
            ELSE ROUND((card_count::NUMERIC / limit_count::NUMERIC) * 100, 1) 
        END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 