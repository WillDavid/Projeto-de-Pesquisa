import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://sewrvsaaajnbglzzblkc.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNld3J2c2FhYWpuYmdsenpibGtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzMjc5NTQsImV4cCI6MjA5MzkwMzk1NH0.YqyHUACCCSVsyCxnNbbXe-_I8kgdagRTgf2zbMTimeY';

export const supabase = createClient(supabaseUrl, supabaseKey);

export const generatePassword = () => {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let password = '';
    for (let i = 0; i < 8; i++) {
        password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
};

export const isValidPassword = (password) => {
    if (password.length !== 8) return false;
    const hasLetter = /[A-Z]/i.test(password);
    const hasNumber = /[0-9]/.test(password);
    return hasLetter && hasNumber;
};