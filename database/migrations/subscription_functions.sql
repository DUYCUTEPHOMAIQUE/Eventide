-- Function to get user's current subscription with plan details
CREATE OR REPLACE FUNCTION get_user_subscription(p_user_id UUID)
RETURNS TABLE(
    subscription_id UUID,
    plan_name TEXT,
    status TEXT,
    started_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    features JSONB,
    limits JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        us.id,
        sp.name,
        us.status,
        us.started_at,
        us.expires_at,
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

-- Function to check if user has access to a feature
CREATE OR REPLACE FUNCTION check_feature_access(
    p_user_id UUID,
    p_feature_name TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    user_features JSONB;
BEGIN
    -- Get user's subscription features
    SELECT sp.features INTO user_features
    FROM user_subscriptions us
    JOIN subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id 
    AND us.status = 'active'
    AND (us.expires_at IS NULL OR us.expires_at > NOW());
    
    -- If no subscription found, auto-assign free plan
    IF user_features IS NULL THEN
        PERFORM assign_free_plan(p_user_id);
        
        -- Get free plan features
        SELECT sp.features INTO user_features
        FROM subscription_plans sp
        WHERE sp.name = 'Free';
    END IF;
    
    -- Check if feature exists and is enabled
    RETURN COALESCE((user_features->p_feature_name)::BOOLEAN, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's usage limits
CREATE OR REPLACE FUNCTION get_user_limits(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    user_limits JSONB;
BEGIN
    SELECT sp.limits INTO user_limits
    FROM user_subscriptions us
    JOIN subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id 
    AND us.status = 'active'
    AND (us.expires_at IS NULL OR us.expires_at > NOW());
    
    -- If no subscription, return free plan limits
    IF user_limits IS NULL THEN
        SELECT sp.limits INTO user_limits
        FROM subscription_plans sp
        WHERE sp.name = 'Free';
    END IF;
    
    RETURN COALESCE(user_limits, '{}'::JSONB);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to track feature usage
CREATE OR REPLACE FUNCTION track_feature_usage(
    p_user_id UUID,
    p_feature_name TEXT,
    p_increment INTEGER DEFAULT 1
) RETURNS INTEGER AS $$
DECLARE
    current_usage INTEGER := 0;
    period_start DATE;
    period_end DATE;
BEGIN
    -- Calculate current month period
    period_start := DATE_TRUNC('month', CURRENT_DATE);
    period_end := (period_start + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
    
    -- Insert or update usage record
    INSERT INTO user_usage (user_id, feature_name, usage_count, period_start, period_end)
    VALUES (p_user_id, p_feature_name, p_increment, period_start, period_end)
    ON CONFLICT (user_id, feature_name, period_start)
    DO UPDATE SET 
        usage_count = user_usage.usage_count + p_increment,
        updated_at = NOW()
    RETURNING usage_count INTO current_usage;
    
    RETURN current_usage;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user can use a feature (considering limits)
CREATE OR REPLACE FUNCTION can_use_feature(
    p_user_id UUID,
    p_feature_name TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    has_access BOOLEAN;
    user_limits JSONB;
    current_usage INTEGER := 0;
    limit_value INTEGER;
    period_start DATE;
BEGIN
    -- First check if user has access to the feature
    SELECT check_feature_access(p_user_id, p_feature_name) INTO has_access;
    
    IF NOT has_access THEN
        RETURN false;
    END IF;
    
    -- Get user limits
    SELECT get_user_limits(p_user_id) INTO user_limits;
    
    -- Get limit for this feature (monthly)
    limit_value := (user_limits->(p_feature_name || '_per_month'))::INTEGER;
    
    -- If limit is -1 (unlimited) or not set, allow usage
    IF limit_value IS NULL OR limit_value = -1 THEN
        RETURN true;
    END IF;
    
    -- Check current usage this month
    period_start := DATE_TRUNC('month', CURRENT_DATE);
    
    SELECT COALESCE(usage_count, 0) INTO current_usage
    FROM user_usage
    WHERE user_id = p_user_id 
    AND feature_name = p_feature_name
    AND period_start = period_start;
    
    -- Return true if under limit
    RETURN current_usage < limit_value;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to auto-assign free plan to new users
CREATE OR REPLACE FUNCTION assign_free_plan(p_user_id UUID)
RETURNS UUID AS $$
DECLARE
    free_plan_id UUID;
    subscription_id UUID;
BEGIN
    -- Get free plan ID
    SELECT id INTO free_plan_id FROM subscription_plans WHERE name = 'Free';
    
    -- Insert subscription if doesn't exist
    INSERT INTO user_subscriptions (user_id, plan_id, status, expires_at)
    VALUES (p_user_id, free_plan_id, 'active', NULL)
    ON CONFLICT (user_id, status) DO NOTHING
    RETURNING id INTO subscription_id;
    
    RETURN subscription_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function for auto-assigning free plan
CREATE OR REPLACE FUNCTION auto_assign_free_plan()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM assign_free_plan(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users
DROP TRIGGER IF EXISTS auto_assign_free_plan_trigger ON auth.users;
CREATE TRIGGER auto_assign_free_plan_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION auto_assign_free_plan(); 