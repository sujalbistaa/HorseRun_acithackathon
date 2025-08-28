// Supabase Configuration
// Make sure to load config.js before this file
const SUPABASE_URL = window.CONFIG?.SUPABASE?.URL || 'YOUR_SUPABASE_PROJECT_URL';
const SUPABASE_ANON_KEY = window.CONFIG?.SUPABASE?.ANON_KEY || 'YOUR_SUPABASE_ANON_KEY';

// Initialize Supabase
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Authentication Functions
const auth = {
    // Sign up user
    async signUp(email, password, userData = {}) {
        try {
            const { data, error } = await supabase.auth.signUp({
                email,
                password,
                options: {
                    data: userData
                }
            });

            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            return { success: false, error: error.message };
        }
    },

    // Sign in user
    async signIn(email, password) {
        try {
            const { data, error } = await supabase.auth.signInWithPassword({
                email,
                password
            });

            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            return { success: false, error: error.message };
        }
    },

    // Sign in with Google OAuth
    async signInWithGoogle(redirectTo = null) {
        try {
            // Use the callback handler for better OAuth flow management
            const baseUrl = 'http://127.0.0.1:3000/HorseRun_acithackathon';
            const callbackUrl = `${baseUrl}/auth-callback.html`;

            const { data, error } = await supabase.auth.signInWithOAuth({
                provider: 'google',
                options: {
                    redirectTo: redirectTo || callbackUrl,
                    queryParams: {
                        access_type: 'offline',
                        prompt: 'consent'
                    }
                }
            });

            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            return { success: false, error: error.message };
        }
    },

    // Sign up with Google OAuth (same as sign in for OAuth)
    async signUpWithGoogle(redirectTo = null) {
        return this.signInWithGoogle(redirectTo);
    },

    // Get current user
    getCurrentUser() {
        return supabase.auth.getUser();
    },

    // Listen to auth state changes
    onAuthStateChange(callback) {
        return supabase.auth.onAuthStateChange(callback);
    },

    // Reset password
    async resetPassword(email) {
        try {
            const { error } = await supabase.auth.resetPasswordForEmail(email, {
                redirectTo: `${window.location.origin}/reset-password.html`
            });
            if (error) throw error;
            return { success: true };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }
};

// Utility functions
const utils = {
    showMessage(message, type = 'info') {
        // Create message element
        const messageEl = document.createElement('div');
        messageEl.className = `auth-message ${type}`;
        messageEl.textContent = message;

        // Style the message
        messageEl.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 8px;
            color: white;
            font-weight: 500;
            z-index: 1000;
            animation: slideIn 0.3s ease-out;
        `;

        // Set background color based on type
        const colors = {
            success: '#4CAF50',
            error: '#f44336',
            warning: '#ff9800',
            info: '#2196F3'
        };
        messageEl.style.backgroundColor = colors[type] || colors.info;

        // Add to body
        document.body.appendChild(messageEl);

        // Remove after 5 seconds
        setTimeout(() => {
            messageEl.style.animation = 'slideOut 0.3s ease-in';
            setTimeout(() => messageEl.remove(), 300);
        }, 5000);
    },

    setLoading(button, loading = true) {
        if (loading) {
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-circle-notch fa-spin"></i> Processing...';
        } else {
            button.disabled = false;
            button.innerHTML = button.dataset.originalText || 'Submit';
        }
    }
};

// Add CSS animations for messages
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);

// Export for use in other files
window.AuthUtils = { auth, utils };
