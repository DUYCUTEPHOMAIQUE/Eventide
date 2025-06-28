-- Fix get_user_subscription function return type

-- Drop existing function first
DROP FUNCTION IF EXISTS get_user_subscription(UUID);

-- Recreate with proper return structure
CREATE OR REPLACE FUNCTION get_user_subscription(p_user_id UUID)
RETURNS TABLE(
    subscription_id UUID,
    plan_name TEXT,
    plan_id UUID,
    user_id UUID,
    status TEXT,
    started_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    features JSONB,
    limits JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        us.id as subscription_id,
        sp.name as plan_name,
        sp.id as plan_id,
        us.user_id,
        us.status,
        us.started_at,
        us.expires_at,
        us.created_at,
        us.updated_at,
        sp.features,
        sp.limits
    FROM user_subscriptions us
    JOIN subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id 
    AND us.status = 'active'
    AND (us.expires_at IS NULL OR us.expires_at > NOW())
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test the function
SELECT 'Testing function...' as status;
SELECT * FROM get_user_subscription((SELECT id FROM auth.users LIMIT 1));
