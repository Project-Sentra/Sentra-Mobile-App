-- Deprecated: Mobile app now uses shared schema in Web/admin_backend/supabase_schema.sql

-- ==============================================
-- VEHICLES TABLE (for user vehicle registration)
-- ==============================================
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    license_plate TEXT NOT NULL,
    vehicle_name TEXT,
    vehicle_type TEXT DEFAULT 'car',
    vehicle_color TEXT,
    vehicle_make TEXT,
    vehicle_model TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, license_plate)
);

-- Enable RLS on vehicles
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

-- Vehicles policies
CREATE POLICY "Users can view own vehicles" ON public.vehicles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vehicles" ON public.vehicles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vehicles" ON public.vehicles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own vehicles" ON public.vehicles
    FOR DELETE USING (auth.uid() = user_id);

-- ==============================================
-- PARKING LOCATIONS TABLE (multi-location support)
-- ==============================================
CREATE TABLE IF NOT EXISTS public.parking_locations (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    price_per_hour DECIMAL(10,2) DEFAULT 100,
    currency TEXT DEFAULT 'LKR',
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.parking_locations ENABLE ROW LEVEL SECURITY;

-- Anyone can view locations
CREATE POLICY "Anyone can view parking locations" ON public.parking_locations
    FOR SELECT USING (true);

-- ==============================================
-- UPDATE PARKING_SPOTS TABLE (add location reference)
-- ==============================================
-- First check if location_id column exists, if not add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'parking_spots' AND column_name = 'location_id'
    ) THEN
        ALTER TABLE public.parking_spots 
        ADD COLUMN location_id BIGINT REFERENCES public.parking_locations(id);
    END IF;
END $$;

-- ==============================================
-- RESERVATIONS TABLE (for pre-booking)
-- ==============================================
CREATE TABLE IF NOT EXISTS public.reservations (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    vehicle_id UUID REFERENCES public.vehicles(id),
    location_id BIGINT REFERENCES public.parking_locations(id),
    spot_id BIGINT,
    plate_number TEXT NOT NULL,
    spot_name TEXT,
    location_name TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'completed', 'cancelled')),
    booking_fee DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;

-- Reservation policies
CREATE POLICY "Users can view own reservations" ON public.reservations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own reservations" ON public.reservations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reservations" ON public.reservations
    FOR UPDATE USING (auth.uid() = user_id);

-- ==============================================
-- SAMPLE DATA
-- ==============================================
-- Insert sample parking locations
INSERT INTO public.parking_locations (name, address, price_per_hour, currency)
VALUES 
    ('Location A - Downtown', '123 Main Street, Colombo', 100, 'LKR'),
    ('Location B - Mall Parking', '456 Shopping Ave, Colombo', 150, 'LKR'),
    ('Location C - Airport', '789 Airport Road, Katunayake', 200, 'LKR')
ON CONFLICT DO NOTHING;

-- Link existing parking_spots to Location A (if they don't have a location)
UPDATE public.parking_spots 
SET location_id = (SELECT id FROM public.parking_locations WHERE name LIKE 'Location A%' LIMIT 1)
WHERE location_id IS NULL;

-- ==============================================
-- INDEXES FOR PERFORMANCE
-- ==============================================
CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON public.vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON public.vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_parking_spots_location_id ON public.parking_spots(location_id);
CREATE INDEX IF NOT EXISTS idx_reservations_user_id ON public.reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_reservations_plate_number ON public.reservations(plate_number);
CREATE INDEX IF NOT EXISTS idx_parking_sessions_plate_number ON public.parking_sessions(plate_number);
