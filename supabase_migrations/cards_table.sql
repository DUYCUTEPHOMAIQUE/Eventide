-- Create cards table for storing invitation cards
CREATE TABLE IF NOT EXISTS cards (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(500),
    event_date_time TIMESTAMP WITH TIME ZONE,
    background_image_url TEXT DEFAULT 'default',
    memory_images JSONB DEFAULT '[]',
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    image_user_url TEXT DEFAULT '',
    selected_template VARCHAR(100) DEFAULT '',
    color_scheme VARCHAR(50) DEFAULT '',
    custom_settings JSONB DEFAULT '{}',
    is_published BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    rsvp_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_cards_owner_id ON cards(owner_id);
CREATE INDEX IF NOT EXISTS idx_cards_created_at ON cards(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_cards_event_date_time ON cards(event_date_time);
CREATE INDEX IF NOT EXISTS idx_cards_is_published ON cards(is_published);

-- Create storage bucket for card images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('card-images', 'card-images', true)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS (Row Level Security)
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;

-- RLS Policies for cards table
CREATE POLICY "Users can view their own cards" ON cards
    FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert their own cards" ON cards
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own cards" ON cards
    FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own cards" ON cards
    FOR DELETE USING (auth.uid() = owner_id);

-- Public can view published cards
CREATE POLICY "Anyone can view published cards" ON cards
    FOR SELECT USING (is_published = true);

-- Storage policies for card-images bucket
CREATE POLICY "Users can upload their own images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'card-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their own images" ON storage.objects
    FOR SELECT USING (bucket_id = 'card-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own images" ON storage.objects
    FOR UPDATE USING (bucket_id = 'card-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own images" ON storage.objects
    FOR DELETE USING (bucket_id = 'card-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Public can view images of published cards
CREATE POLICY "Anyone can view published card images" ON storage.objects
    FOR SELECT USING (bucket_id = 'card-images');

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_cards_updated_at 
    BEFORE UPDATE ON cards 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to increment view count
CREATE OR REPLACE FUNCTION increment_card_view_count(card_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE cards 
    SET view_count = view_count + 1 
    WHERE id = card_id;
END;
$$ LANGUAGE plpgsql;

-- Create templates table for predefined card templates
CREATE TABLE IF NOT EXISTS card_templates (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    color_scheme JSONB DEFAULT '[]',
    layout_settings JSONB DEFAULT '{}',
    is_premium BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Insert default templates
INSERT INTO card_templates (id, name, category, description, color_scheme, layout_settings) VALUES
('modern_minimal', 'Modern Minimal', 'Business', 'Clean and professional design for business events', '["#374151", "#F3F4F6"]', '{"style": "minimal", "layout": "clean"}'),
('birthday_fun', 'Birthday Fun', 'Personal', 'Colorful and playful design for birthday celebrations', '["#EC4899", "#F59E0B"]', '{"style": "playful", "layout": "colorful"}'),
('wedding_elegant', 'Wedding Elegant', 'Wedding', 'Elegant and romantic design for wedding invitations', '["#6366F1", "#F9FAFB"]', '{"style": "elegant", "layout": "romantic"}'),
('corporate_professional', 'Corporate Professional', 'Business', 'Professional design for corporate events', '["#3B82F6", "#374151"]', '{"style": "professional", "layout": "corporate"}'),
('party_vibrant', 'Party Vibrant', 'Personal', 'Vibrant and energetic design for parties', '["#10B981", "#6366F1"]', '{"style": "vibrant", "layout": "energetic"}'),
('graduation_classic', 'Graduation Classic', 'Academic', 'Classic design for graduation ceremonies', '["#1F2937", "#F59E0B"]', '{"style": "classic", "layout": "academic"}')
ON CONFLICT (id) DO NOTHING;

-- Grant permissions
GRANT SELECT ON card_templates TO authenticated;
GRANT SELECT ON card_templates TO anon; 