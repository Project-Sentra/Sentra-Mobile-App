// IMPORTANT:
// Use the Supabase *Anon public key* from Dashboard → Settings → API.
// It usually looks like a JWT starting with "eyJ...".
// If you use an `sb_publishable_...` key here, Edge Functions with "Verify JWT"
// may fail with 401 "Invalid JWT".

const supabaseUrl = 'https://pnopbaulalcwaucrynim.supabase.co';
const supabaseKey =
	'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBub3BiYXVsYWxjd2F1Y3J5bmltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0NjQ4MzEsImV4cCI6MjA4NjA0MDgzMX0.pGbC8SRw0WRQM9o9Z3kWSliZ34wuCxJ7HCdPzflUVlo';
