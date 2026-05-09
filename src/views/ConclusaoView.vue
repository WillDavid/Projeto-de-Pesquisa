<script>
import { useAuthStore } from '../stores/auth';
import { useQuestionnaireStore } from '../stores/questionnaire';

export default {
    name: 'ConclusaoView',
    setup() {
        return {
            authStore: useAuthStore(),
            questionnaireStore: useQuestionnaireStore()
        };
    },
    mounted() {
        this.authStore.checkSession();
        if (!this.authStore.isLoggedIn) {
            this.$router.push('/login-respondente');
        }
    },
    methods: {
        fazerLogout() {
            this.questionnaireStore.resetFormulario();
            this.authStore.logout();
            this.$router.push('/');
        }
    }
};
</script>

<template>
    <div class="conclusao-container">
        <div class="conclusao-card">
            <div class="success-icon">
                <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                    <polyline points="22 4 12 14.01 9 11.01"></polyline>
                </svg>
            </div>

            <h1 class="conclusao-title">Obrigado!</h1>
            <p class="conclusao-text">
                Suas respostas foram registradas com sucesso.
                Sua participação é fundamental para a melhoria dos processos organizacionais.
            </p>

            <div class="conclusao-info">
                <div class="info-item">
                    <span class="info-label">Setor:</span>
                    <span class="info-value">{{ authStore.setorNome }}</span>
                </div>
            </div>

            <button class="logout-btn" @click="fazerLogout">
                Encerrar Sessão
            </button>
        </div>

        <footer class="conclusao-footer">
            <p>Pesquisa Corporativa - Coleta de Dados</p>
        </footer>
    </div>
</template>

<style scoped>
.conclusao-container {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: #f8f9fa;
    padding: 20px;
}

.conclusao-card {
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 48px;
    text-align: center;
    max-width: 480px;
    width: 100%;
}

.success-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 80px;
    height: 80px;
    margin: 0 auto 24px;
    background: #e6f4ea;
    border-radius: 50%;
    color: #34a853;
}

.conclusao-title {
    font-family: 'Georgia', serif;
    font-size: 28px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 16px 0;
}

.conclusao-text {
    font-size: 15px;
    color: #555;
    margin: 0 0 32px 0;
    line-height: 1.6;
}

.conclusao-info {
    padding: 16px;
    background: #fafafa;
    border-radius: 4px;
    margin-bottom: 32px;
}

.info-item {
    display: flex;
    justify-content: center;
    gap: 8px;
}

.info-label {
    font-size: 14px;
    color: #666;
}

.info-value {
    font-size: 14px;
    font-weight: 600;
    color: #2c5282;
}

.logout-btn {
    padding: 12px 32px;
    background: #333;
    color: #ffffff;
    border: none;
    border-radius: 3px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    font-family: inherit;
}

.logout-btn:hover {
    background: #1a1a1a;
}

.conclusao-footer {
    margin-top: 32px;
}

.conclusao-footer p {
    font-size: 11px;
    color: #888;
    margin: 0;
    letter-spacing: 0.5px;
}
</style>