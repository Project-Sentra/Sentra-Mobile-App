// IMPORTANT:
// Use the Supabase *Anon public key* from Dashboard → Settings → API.
// It usually looks like a JWT starting with "eyJ...".
// If you use an `sb_publishable_...` key here, Edge Functions with "Verify JWT"
// may fail with 401 "Invalid JWT".

const supabaseUrl = 'https://ezntvcormqnwtkppjlkj.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV6bnR2Y29ybXFud3RrcHBqbGtqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA5NjUzNTcsImV4cCI6MjEwNjU0MTM1N30.SBA3q45FE-TsDqonKGFCLgiY9y2ETDXIn8fM3WqGQ3Q';
