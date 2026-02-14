-- Sentra Parking Database Schema (Deprecated)
-- The mobile app now uses the shared schema in:
--   Web/admin_backend/supabase_schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Parking facilities table
CREATE TABLE IF NOT EXISTS public.parking_facilities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    price_per_hour DECIMAL(10,2) DEFAULT 0,
    currency TEXT DEFAULT 'LKR',
    image_url TEXT,
    total_slots INTEGER DEFAULT 0,
    available_slots INTEGER DEFAULT 0,
    reserved_slots INTEGER DEFAULT 0,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Parking slots table
CREATE TABLE IF NOT EXISTS public.parking_slots (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    facility_id UUID REFERENCES public.parking_facilities(id) ON DELETE CASCADE NOT NULL,
    slot_number TEXT NOT NULL,
    floor TEXT,
    section TEXT,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'disabled')),
    reserved_by UUID REFERENCES auth.users(id),
    reserved_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(facility_id, slot_number)
);

-- Reservations table
CREATE TABLE IF NOT EXISTS public.reservations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    slot_id UUID REFERENCES public.parking_slots(id) ON DELETE SET NULL,
    facility_id UUID REFERENCES public.parking_facilities(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    slot_number TEXT NOT NULL,
    facility_name TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    total_price DECIMAL(10,2),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recent facilities table (for user's recently viewed facilities)
CREATE TABLE IF NOT EXISTS public.recent_facilities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    facility_id UUID REFERENCES public.parking_facilities(id) ON DELETE CASCADE NOT NULL,
    visited_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, facility_id)
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recent_facilities ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow service role to insert profiles (for trigger)
CREATE POLICY "Service role can insert profiles" ON public.profiles
    FOR INSERT WITH CHECK (true);

-- Parking facilities policies (public read)
CREATE POLICY "Anyone can view parking facilities" ON public.parking_facilities
    FOR SELECT USING (true);

-- Parking slots policies (public read)
CREATE POLICY "Anyone can view parking slots" ON public.parking_slots
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can update slots" ON public.parking_slots
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Reservations policies
CREATE POLICY "Users can view own reservations" ON public.reservations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own reservations" ON public.reservations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reservations" ON public.reservations
    FOR UPDATE USING (auth.uid() = user_id);

-- Recent facilities policies
CREATE POLICY "Users can view own recent facilities" ON public.recent_facilities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own recent facilities" ON public.recent_facilities
    FOR ALL USING (auth.uid() = user_id);

-- Trigger to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert sample parking facilities
INSERT INTO public.parking_facilities (name, address, price_per_hour, currency, total_slots, available_slots, reserved_slots)
VALUES 
    ('Downtown parking', '123 Main Street, Downtown', 250, 'LKR', 20, 8, 2),
    ('Monte Carlo parking', '456 Casino Road, Monte Carlo', 300, 'LKR', 30, 15, 3);

-- Insert sample slots for Downtown parking
DO $$
DECLARE
    downtown_id UUID;
    slot_labels TEXT[] := ARRAY['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10',
                                 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10'];
    slot_label TEXT;
    slot_status TEXT;
    i INTEGER := 1;
BEGIN
    SELECT id INTO downtown_id FROM public.parking_facilities WHERE name = 'Downtown parking';
    
    FOREACH slot_label IN ARRAY slot_labels
    LOOP
        -- Randomly assign status (60% available, 30% occupied, 10% reserved)
        IF i <= 8 THEN
            slot_status := 'available';
        ELSIF i <= 18 THEN
            slot_status := 'occupied';
        ELSE
            slot_status := 'reserved';
        END IF;
        
        INSERT INTO public.parking_slots (facility_id, slot_number, status)
        VALUES (downtown_id, slot_label, slot_status);
        
        i := i + 1;
    END LOOP;
END $$;

-- Insert sample slots for Monte Carlo parking
DO $$
DECLARE
    monte_id UUID;
    slot_labels TEXT[] := ARRAY['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10',
                                 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10',
                                 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10'];
    slot_label TEXT;
    slot_status TEXT;
    i INTEGER := 1;
BEGIN
    SELECT id INTO monte_id FROM public.parking_facilities WHERE name = 'Monte Carlo parking';
    
    FOREACH slot_label IN ARRAY slot_labels
    LOOP
        IF i <= 15 THEN
            slot_status := 'available';
        ELSIF i <= 27 THEN
            slot_status := 'occupied';
        ELSE
            slot_status := 'reserved';
        END IF;
        
        INSERT INTO public.parking_slots (facility_id, slot_number, status)
        VALUES (monte_id, slot_label, slot_status);
        
        i := i + 1;
    END LOOP;
END $$;

-- ============================================================
-- NEW TABLES FOR MOBILE APP FEATURES
-- ============================================================

-- Vehicles table (FR-05: Vehicle Management)
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    license_plate TEXT NOT NULL,
    vehicle_name TEXT,
    vehicle_type TEXT,
    vehicle_color TEXT,
    vehicle_make TEXT,
    vehicle_model TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, license_plate)
);

-- Payment methods table (FR-08: Payment Integration)
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    type TEXT DEFAULT 'card' CHECK (type IN ('card', 'bank_account')),
    card_brand TEXT,
    last_four_digits TEXT NOT NULL,
    card_holder_name TEXT NOT NULL,
    expiry_month INTEGER,
    expiry_year INTEGER,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments table (FR-08: Payment Integration)
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'LKR',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    transaction_id TEXT,
    reservation_id UUID REFERENCES public.reservations(id) ON DELETE SET NULL,
    parking_session_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Parking sessions table (FR-06: Real-time Parking Status, FR-07: Parking History)
CREATE TABLE IF NOT EXISTS public.parking_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    facility_id UUID REFERENCES public.parking_facilities(id) ON DELETE SET NULL NOT NULL,
    slot_id UUID REFERENCES public.parking_slots(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE SET NULL,
    license_plate TEXT NOT NULL,
    entry_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    exit_time TIMESTAMPTZ,
    duration DECIMAL(10,2), -- in hours
    total_amount DECIMAL(10,2),
    currency TEXT DEFAULT 'LKR',
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    payment_id UUID REFERENCES public.payments(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key to payments for parking_session_id
ALTER TABLE public.payments 
ADD CONSTRAINT fk_parking_session 
FOREIGN KEY (parking_session_id) REFERENCES public.parking_sessions(id) ON DELETE SET NULL;

-- Parking receipts table (FR-07: Parking History & Receipts)
CREATE TABLE IF NOT EXISTS public.parking_receipts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    parking_session_id UUID REFERENCES public.parking_sessions(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    facility_name TEXT NOT NULL,
    facility_address TEXT,
    license_plate TEXT NOT NULL,
    slot_number TEXT,
    entry_time TIMESTAMPTZ NOT NULL,
    exit_time TIMESTAMPTZ NOT NULL,
    duration DECIMAL(10,2) NOT NULL, -- in hours
    rate_per_hour DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'LKR',
    payment_method TEXT,
    transaction_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security for new tables
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_receipts ENABLE ROW LEVEL SECURITY;

-- Vehicles policies
CREATE POLICY "Users can view own vehicles" ON public.vehicles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own vehicles" ON public.vehicles
    FOR ALL USING (auth.uid() = user_id);

-- Payment methods policies
CREATE POLICY "Users can view own payment methods" ON public.payment_methods
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own payment methods" ON public.payment_methods
    FOR ALL USING (auth.uid() = user_id);

-- Payments policies
CREATE POLICY "Users can view own payments" ON public.payments
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own payments" ON public.payments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own payments" ON public.payments
    FOR UPDATE USING (auth.uid() = user_id);

-- Parking sessions policies
CREATE POLICY "Users can view own parking sessions" ON public.parking_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create parking sessions" ON public.parking_sessions
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own parking sessions" ON public.parking_sessions
    FOR UPDATE USING (auth.uid() = user_id);

-- Parking receipts policies
CREATE POLICY "Users can view own receipts" ON public.parking_receipts
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create receipts" ON public.parking_receipts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');
