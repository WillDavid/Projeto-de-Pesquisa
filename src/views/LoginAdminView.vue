<script>
export default {
    name: 'LoginAdminView',
    data() {
        return {
            email: '',
            password: '',
            loading: false,
            error: ''
        };
    },
    methods: {
        async login() {
            if (!this.email || !this.password) {
                this.error = 'Preencha todos os campos';
                return;
            }

            this.loading = true;
            this.error = '';

            try {
                if (this.email === 'admin@sistema.com' && this.password === 'admin123') {
                    localStorage.setItem('adminLogado', 'true');
                    this.$router.push('/admin');
                } else {
                    this.error = 'Credenciais inválidas';
                }
            } catch (e) {
                this.error = 'Erro ao fazer login';
            } finally {
                this.loading = false;
            }
        },
        goBack() {
            this.$router.push('/');
        }
    }
};
</script>

<template>
    <div class="login-container">
        <div class="login-card">
            <button class="back-btn" @click="goBack">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="19" y1="12" x2="5" y2="12"></line>
                    <polyline points="12 19 5 12 12 5"></polyline>
                </svg>
                Voltar
            </button>

            <div class="login-header">
                <h1 class="login-title">Área Administrativa</h1>
                <p class="login-subtitle">Autenticação de acesso restrito</p>
            </div>

            <form @submit.prevent="login" class="login-form">
                <div class="form-group">
                    <label for="email">Endereço de e-mail</label>
                    <input
                        id="email"
                        v-model="email"
                        type="email"
                        placeholder="admin@sistema.com"
                        class="form-input"
                    />
                </div>

                <div class="form-group">
                    <label for="password">Senha</label>
                    <input
                        id="password"
                        v-model="password"
                        type="password"
                        placeholder="••••••••"
                        class="form-input"
                    />
                </div>

                <p v-if="error" class="error-message">{{ error }}</p>

                <button type="submit" class="login-btn" :disabled="loading">
                    {{ loading ? 'Autenticando...' : 'Entrar' }}
                </button>
            </form>

            <div class="login-hint">
                <p>Credenciais de teste: admin@sistema.com / admin123</p>
            </div>
        </div>
    </div>
</template>

<style scoped>
.login-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #f8f9fa;
    padding: 20px;
}

.login-card {
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 40px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
    width: 100%;
    max-width: 380px;
    position: relative;
}

.back-btn {
    position: absolute;
    top: 16px;
    left: 16px;
    display: flex;
    align-items: center;
    gap: 6px;
    background: none;
    border: none;
    color: #666;
    font-size: 13px;
    cursor: pointer;
    padding: 6px;
    font-family: inherit;
}

.back-btn:hover {
    color: #333;
}

.login-header {
    text-align: center;
    margin-bottom: 32px;
}

.login-title {
    font-family: 'Georgia', 'Times New Roman', serif;
    font-size: 22px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 8px 0;
}

.login-subtitle {
    font-size: 13px;
    color: #666;
    margin: 0;
}

.login-form {
    display: flex;
    flex-direction: column;
    gap: 18px;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.form-group label {
    font-size: 13px;
    font-weight: 500;
    color: #333;
}

.form-input {
    padding: 10px 14px;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 14px;
    font-family: inherit;
    transition: border-color 0.2s;
    background: #fafafa;
}

.form-input:focus {
    outline: none;
    border-color: #333;
    background: #fff;
}

.error-message {
    color: #b00020;
    font-size: 13px;
    text-align: center;
    margin: 0;
}

.login-btn {
    padding: 12px;
    background: #333;
    color: #ffffff;
    border: none;
    border-radius: 3px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    font-family: inherit;
    margin-top: 8px;
}

.login-btn:hover:not(:disabled) {
    background: #1a1a1a;
}

.login-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.login-hint {
    margin-top: 24px;
    padding-top: 16px;
    border-top: 1px solid #eee;
    text-align: center;
}

.login-hint p {
    font-size: 11px;
    color: #888;
    margin: 0;
}
</style>