// Environment Configuration for Swasthya AI
// Replace these values with your actual Supabase project credentials

const CONFIG = {
    SUPABASE: {
        URL: 'https://qzkttpghxoynooqvjesm.supabase.co', // e.g., 'https://your-project-id.supabase.co'
        ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6a3R0cGdoeG95bm9vcXZqZXNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzOTkyODgsImV4cCI6MjA3MTk3NTI4OH0.Pk3oSi79PaPMQpWKsxL7iVBkXZi8xq4wp0wRQq-rKgQ' // Your project's anon/public key
    },
    APP: {
        NAME: 'Swasthya AI',
        VERSION: '1.0.0',
        ENVIRONMENT: 'development' // 'development' or 'production'
    }
};

// Export for use in other files
window.CONFIG = CONFIG;
