-- Debug subscription data structure
-- Run this to check what data is being returned

-- Check subscription plans structure
SELECT 'subscription_plans' as table_name, * FROM subscription_plans LIMIT 1;

-- Check user subscriptions structure  
SELECT 'user_subscriptions' as table_name, * FROM user_subscriptions LIMIT 1;

-- Test get_user_subscription function
-- Replace 'your-user-id' with actual user ID
SELECT 'get_user_subscription' as function_name, * 
FROM get_user_subscription('22f35be7-8cba-4e26-908e-9c8f0fdd9188');

-- Check what users exist
SELECT 'auth_users' as table_name, id, email FROM auth.users LIMIT 3;

-- Check if subscriptions are properly linked
SELECT 
    'subscription_check' as check_name,
    u.email,
    us.status,
    sp.name as plan_name,
    sp.features,
    sp.limits
FROM auth.users u
LEFT JOIN user_subscriptions us ON u.id = us.user_id AND us.status = 'active'
LEFT JOIN subscription_plans sp ON us.plan_id = sp.id
LIMIT 3;

-- Update get_user_subscription function to return proper field names
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