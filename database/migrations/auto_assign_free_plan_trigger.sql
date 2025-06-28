-- Auto-assign Free plan trigger for new users
-- This trigger will run when a new user is created in auth.users

-- First, ensure we have the assign_free_plan function
CREATE OR REPLACE FUNCTION assign_free_plan(p_user_id UUID)
RETURNS UUID AS $$
DECLARE
    free_plan_id UUID;
    subscription_id UUID;
BEGIN
    -- Get free plan ID
    SELECT id INTO free_plan_id FROM subscription_plans WHERE name = 'Free';
    
    IF free_plan_id IS NULL THEN
        RAISE EXCEPTION 'Free plan not found in subscription_plans table';
    END IF;
    
    -- Insert subscription if doesn't exist
    INSERT INTO user_subscriptions (user_id, plan_id, status, started_at, expires_at)
    VALUES (p_user_id, free_plan_id, 'active', NOW(), NULL)
    ON CONFLICT (user_id, status) DO NOTHING
    RETURNING id INTO subscription_id;
    
    -- Log the assignment
    RAISE NOTICE 'Free plan assigned to user: %', p_user_id;
    
    RETURN subscription_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function for auto-assigning free plan
CREATE OR REPLACE FUNCTION auto_assign_free_plan_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Assign free plan to the new user
    PERFORM assign_free_plan(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS auto_assign_free_plan_on_signup ON auth.users;

-- Create trigger on auth.users table
CREATE TRIGGER auto_assign_free_plan_on_signup
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION auto_assign_free_plan_trigger();

-- Alternative: Trigger on profiles table (if you have one)
-- Uncomment if you want to trigger on profile creation instead

/*
-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS auto_assign_free_plan_on_profile ON profiles;

-- Create trigger on profiles table (if you have profiles table)
CREATE TRIGGER auto_assign_free_plan_on_profile
    AFTER INSERT ON profiles
    FOR EACH ROW 
    EXECUTE FUNCTION auto_assign_free_plan_trigger();
*/

-- Test the trigger by checking if it's created
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers 
WHERE trigger_name LIKE '%free_plan%';

-- Show current subscription functions
SELECT 
    routine_name,
    routine_type,
    security_type
FROM information_schema.routines 
WHERE routine_name LIKE '%free_plan%' OR routine_name LIKE '%subscription%'; 