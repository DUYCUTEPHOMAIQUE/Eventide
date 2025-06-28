-- Premium Templates System
-- Create templates table with subscription tiers

CREATE TABLE card_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL, -- 'birthday', 'wedding', 'business', 'party', etc.
    tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'premium', 'pro')),
    preview_image_url TEXT,
    background_gradient JSONB, -- {"colors": ["#FF6B6B", "#4ECDC4"], "direction": "to bottom right"}
    background_pattern TEXT, -- 'dots', 'waves', 'geometric', 'minimal', etc.
    font_family TEXT DEFAULT 'SF Pro Rounded',
    color_scheme JSONB, -- {"primary": "#FF6B6B", "secondary": "#4ECDC4", "text": "#2C3E50"}
    layout_style TEXT DEFAULT 'classic', -- 'classic', 'modern', 'minimalist', 'elegant'
    template_data JSONB, -- Full template configuration
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE card_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Everyone can read templates, but tier access is handled in app
CREATE POLICY "templates_read_all" ON card_templates
    FOR SELECT TO authenticated USING (is_active = true);

-- Insert default templates
INSERT INTO card_templates (name, description, category, tier, preview_image_url, background_gradient, color_scheme, layout_style, sort_order) VALUES
-- Free Templates
('Classic Birthday', 'Simple and elegant birthday invitation', 'birthday', 'free', null, 
 '{"colors": ["#FFB74D", "#FF8A65"], "direction": "to bottom right"}',
 '{"primary": "#FFB74D", "secondary": "#FF8A65", "text": "#2C3E50", "accent": "#FFFFFF"}',
 'classic', 1),

('Simple Party', 'Clean party invitation template', 'party', 'free', null,
 '{"colors": ["#64B5F6", "#42A5F5"], "direction": "to right"}',
 '{"primary": "#64B5F6", "secondary": "#42A5F5", "text": "#1A237E", "accent": "#FFFFFF"}',
 'minimalist', 2),

('Business Meeting', 'Professional meeting invitation', 'business', 'free', null,
 '{"colors": ["#78909C", "#546E7A"], "direction": "to bottom"}',
 '{"primary": "#78909C", "secondary": "#546E7A", "text": "#263238", "accent": "#FFFFFF"}',
 'modern', 3),

-- Premium Templates
('Luxury Wedding', 'Elegant wedding invitation with gold accents', 'wedding', 'premium', null,
 '{"colors": ["#D4AF37", "#F5F5DC", "#FFFFFF"], "direction": "radial"}',
 '{"primary": "#D4AF37", "secondary": "#F5F5DC", "text": "#2C2C2C", "accent": "#FFFFFF"}',
 'elegant', 4),

('Modern Corporate', 'Sleek corporate event template', 'business', 'premium', null,
 '{"colors": ["#1A237E", "#3949AB", "#5C6BC0"], "direction": "to bottom right"}',
 '{"primary": "#1A237E", "secondary": "#3949AB", "text": "#FFFFFF", "accent": "#FFD700"}',
 'modern', 5),

('Festive Celebration', 'Vibrant party template with animations', 'party', 'premium', null,
 '{"colors": ["#E91E63", "#FF5722", "#FF9800"], "direction": "45deg"}',
 '{"primary": "#E91E63", "secondary": "#FF5722", "text": "#FFFFFF", "accent": "#FFD700"}',
 'modern', 6),

('Baby Shower Bliss', 'Soft and sweet baby shower design', 'baby_shower', 'premium', null,
 '{"colors": ["#F8BBD9", "#E1BEE7", "#C5CAE9"], "direction": "to bottom"}',
 '{"primary": "#F8BBD9", "secondary": "#E1BEE7", "text": "#4A148C", "accent": "#FFFFFF"}',
 'elegant', 7),

('Executive Summit', 'High-end business conference template', 'business', 'premium', null,
 '{"colors": ["#000000", "#212121", "#424242"], "direction": "to right"}',
 '{"primary": "#000000", "secondary": "#212121", "text": "#FFFFFF", "accent": "#FFD700"}',
 'elegant', 8);

-- Function to get templates by user subscription
CREATE OR REPLACE FUNCTION get_available_templates(p_user_id UUID)
RETURNS TABLE(
    template_id UUID,
    name TEXT,
    description TEXT,
    category TEXT,
    tier TEXT,
    preview_image_url TEXT,
    background_gradient JSONB,
    color_scheme JSONB,
    layout_style TEXT,
    is_locked BOOLEAN
) AS $$
DECLARE
    user_subscription_tier TEXT := 'free';
BEGIN
    -- Get user's subscription tier
    SELECT COALESCE(sp.name, 'free') INTO user_subscription_tier
    FROM user_subscriptions us
    JOIN subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id 
    AND us.status = 'active'
    AND (us.expires_at IS NULL OR us.expires_at > NOW());
    
    -- Return templates with lock status
    RETURN QUERY
    SELECT 
        ct.id,
        ct.name,
        ct.description,
        ct.category,
        ct.tier,
        ct.preview_image_url,
        ct.background_gradient,
        ct.color_scheme,
        ct.layout_style,
        CASE 
            WHEN ct.tier = 'free' THEN false
            WHEN ct.tier = 'premium' AND user_subscription_tier IN ('premium', 'pro') THEN false
            WHEN ct.tier = 'pro' AND user_subscription_tier = 'pro' THEN false
            ELSE true
        END as is_locked
    FROM card_templates ct
    WHERE ct.is_active = true
    ORDER BY ct.sort_order, ct.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user can use a specific template
CREATE OR REPLACE FUNCTION can_use_template(p_user_id UUID, p_template_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    template_tier TEXT;
    user_subscription_tier TEXT := 'free';
BEGIN
    -- Get template tier
    SELECT tier INTO template_tier FROM card_templates WHERE id = p_template_id;
    
    IF template_tier IS NULL THEN
        RETURN false;
    END IF;
    
    -- Free templates are always available
    IF template_tier = 'free' THEN
        RETURN true;
    END IF;
    
    -- Get user's subscription tier
    SELECT COALESCE(sp.name, 'free') INTO user_subscription_tier
    FROM user_subscriptions us
    JOIN subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id 
    AND us.status = 'active'
    AND (us.expires_at IS NULL OR us.expires_at > NOW());
    
    -- Check access based on tiers
    RETURN (
        (template_tier = 'premium' AND user_subscription_tier IN ('premium', 'pro')) OR
        (template_tier = 'pro' AND user_subscription_tier = 'pro')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create indexes for performance
CREATE INDEX idx_card_templates_category ON card_templates(category);
CREATE INDEX idx_card_templates_tier ON card_templates(tier);
CREATE INDEX idx_card_templates_active_sort ON card_templates(is_active, sort_order);
