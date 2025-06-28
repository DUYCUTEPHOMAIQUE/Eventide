-- Migration: Assign Free plan to all existing users who don't have subscription
-- This should be run after the subscription system is set up

-- First, get the Free plan ID and assign to existing users
DO $$
DECLARE
    free_plan_id UUID;
    affected_count INTEGER;
BEGIN
    -- Get Free plan ID
    SELECT id INTO free_plan_id FROM subscription_plans WHERE name = 'Free';
    
    IF free_plan_id IS NULL THEN
        RAISE EXCEPTION 'Free plan not found. Please run subscription system setup first.';
    END IF;
    
    -- Insert Free subscription for all existing users who don't have any subscription
    INSERT INTO user_subscriptions (user_id, plan_id, status, started_at, expires_at)
    SELECT 
        u.id,
        free_plan_id,
        'active',
        NOW(),
        NULL  -- Free plan never expires
    FROM auth.users u
    LEFT JOIN user_subscriptions us ON u.id = us.user_id AND us.status = 'active'
    WHERE us.user_id IS NULL  -- Only users without active subscription
    ON CONFLICT (user_id, status) DO NOTHING;
    
    -- Get count of affected users
    GET DIAGNOSTICS affected_count = ROW_COUNT;
    RAISE NOTICE 'Assigned Free plan to % existing users', affected_count;
END $$;

-- Verify the migration results
SELECT 
    COUNT(*) as total_users,
    COUNT(us.id) as users_with_subscription,
    COUNT(*) - COUNT(us.id) as users_without_subscription
FROM auth.users u
LEFT JOIN user_subscriptions us ON u.id = us.user_id AND us.status = 'active';

-- Show subscription plan distribution
SELECT 
    sp.name as plan_name,
    COUNT(us.id) as user_count,
    ROUND(COUNT(us.id) * 100.0 / NULLIF(SUM(COUNT(us.id)) OVER (), 0), 2) as percentage
FROM subscription_plans sp
LEFT JOIN user_subscriptions us ON sp.id = us.plan_id AND us.status = 'active'
GROUP BY sp.name, sp.price
ORDER BY sp.price;

-- Show sample of users with their subscriptions
SELECT 
    u.email,
    sp.name as subscription_plan,
    us.status,
    us.started_at,
    us.expires_at
FROM auth.users u
LEFT JOIN user_subscriptions us ON u.id = us.user_id AND us.status = 'active'
LEFT JOIN subscription_plans sp ON us.plan_id = sp.id
ORDER BY u.created_at DESC
LIMIT 10; 