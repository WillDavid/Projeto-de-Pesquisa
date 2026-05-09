<script>
export default {
    name: 'HomeView',
    methods: {
        goToLoginAdmin() {
            this.$router.push('/login-admin');
        },
        goToLoginRespondente() {
            this.$router.push('/login-respondente');
        }
    }
};
</script>

<template>
    <div class="home-container">
        <div class="home-content">
            <div class="university-badge">
                <span class="institution">Pesquisa Acadêmica</span>
            </div>

            <h1 class="home-title">Sistema de Coleta de Dados</h1>
            <p class="home-subtitle">
                Pesquisa de Satisfação e Avaliação de Serviços
            </p>

            <div class="divider"></div>

            <p class="home-description">
                Selecione o tipo de acesso para continuar
            </p>

            <div class="home-buttons">
                <button class="home-btn admin-btn" @click="goToLoginAdmin">
                    <span class="btn-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                        </svg>
                    </span>
                    Acesso Administrador
                </button>

                <button class="home-btn respondent-btn" @click="goToLoginRespondente">
                    <span class="btn-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                            <polyline points="14 2 14 8 20 8"></polyline>
                            <line x1="16" y1="13" x2="8" y2="13"></line>
                            <line x1="16" y1="17" x2="8" y2="17"></line>
                        </svg>
                    </span>
                    Acesso Respondente
                </button>
            </div>
        </div>

        <footer class="home-footer">
            <p>Desenvolvido por Dinardi Solucoes em Software</p>
        </footer>
    </div>
</template>

<style scoped>
.home-container {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: #f8f9fa;
    padding: 20px;
}

.home-content {
    text-align: center;
    padding: 48px 56px;
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    max-width: 520px;
    width: 100%;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.university-badge {
    margin-bottom: 16px;
}

.institution {
    display: inline-block;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: #666;
    padding: 4px 12px;
    border: 1px solid #ddd;
    background: #fafafa;
}

.home-title {
    font-family: 'Georgia', 'Times New Roman', serif;
    font-size: 28px;
    font-weight: 700;
    color: #1a1a1a;
    margin: 0 0 8px 0;
    line-height: 1.3;
}

.home-subtitle {
    font-size: 14px;
    color: #555;
    margin: 0;
    font-weight: 400;
}

.divider {
    width: 60px;
    height: 2px;
    background: #333;
    margin: 24px auto;
}

.home-description {
    font-size: 13px;
    color: #666;
    margin: 0 0 28px 0;
}

.home-buttons {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.home-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    padding: 14px 24px;
    font-size: 14px;
    font-weight: 500;
    border: 1px solid;
    border-radius: 3px;
    cursor: pointer;
    transition: all 0.2s ease;
    font-family: inherit;
}

.btn-icon {
    display: flex;
    align-items: center;
}

.admin-btn {
    background: #ffffff;
    border-color: #333;
    color: #333;
}

.admin-btn:hover {
    background: #333;
    color: #ffffff;
}

.respondent-btn {
    background: #ffffff;
    border-color: #2c5282;
    color: #2c5282;
}

.respondent-btn:hover {
    background: #2c5282;
    color: #ffffff;
}

.home-footer {
    margin-top: 32px;
}

.home-footer p {
    font-size: 11px;
    color: #888;
    margin: 0;
    letter-spacing: 0.5px;
}
</style>