-- Create subscription plans table
CREATE TABLE subscription_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    duration_months INTEGER NOT NULL,
    features JSONB NOT NULL DEFAULT '{}',
    limits JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user subscriptions table
CREATE TABLE user_subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, status) -- Chỉ có 1 subscription active per user
);

-- Create usage tracking table
CREATE TABLE user_usage (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    feature_name TEXT NOT NULL,
    usage_count INTEGER DEFAULT 0,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, feature_name, period_start)
);

-- Insert default plans
INSERT INTO subscription_plans (name, price, duration_months, features, limits) VALUES
('Free', 0.00, 12, 
 '{"ai_generation": true, "basic_templates": true, "event_creation": true}',
 '{"max_cards": 5, "ai_generations_per_month": 3, "max_invites_per_event": 20}'
),
('Premium', 9.99, 1,
 '{"ai_generation": true, "premium_templates": true, "unlimited_cards": true, "analytics": true}',
 '{"max_cards": -1, "ai_generations_per_month": -1, "max_invites_per_event": -1}'
);

-- Enable RLS
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_usage ENABLE ROW LEVEL SECURITY;

-- RLS Policies for subscription_plans (readable by all authenticated users)
CREATE POLICY "subscription_plans_read" ON subscription_plans
    FOR SELECT TO authenticated USING (true);

-- RLS Policies for user_subscriptions (users can only see their own)
CREATE POLICY "user_subscriptions_read" ON user_subscriptions
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "user_subscriptions_insert" ON user_subscriptions
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_subscriptions_update" ON user_subscriptions
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- RLS Policies for user_usage (users can only see their own)
CREATE POLICY "user_usage_read" ON user_usage
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "user_usage_insert" ON user_usage
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_usage_update" ON user_usage
    FOR UPDATE TO authenticated USING (auth.uid() = user_id); 