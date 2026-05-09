<script>
import { useAuthStore } from '../stores/auth';
import { useQuestionnaireStore } from '../stores/questionnaire';
import FormCard from '../components/common/FormCard.vue';

export default {
    name: 'ParticipanteView',
    components: {
        FormCard
    },
    setup() {
        return {
            authStore: useAuthStore(),
            questionnaireStore: useQuestionnaireStore()
        };
    },
    computed: {
        formularios() {
            return this.questionnaireStore.getFormularios;
        }
    },
    async mounted() {
        this.authStore.checkSession();
        if (!this.authStore.isLoggedIn) {
            this.$router.push('/login-respondente');
            return;
        }

        await this.authStore.refreshStatus();
        await this.questionnaireStore.carregarStatusFormularios(this.authStore.senhaId);
    },
    methods: {
        async iniciarFormulario(form) {
            if (form.emBreve) return;
            if (form.concluido) return;

            await this.questionnaireStore.iniciarFormulario(form.id);
            this.$router.push(form.id === 'preferencias' ? '/preferencias' : '/formulario');
        },
        logout() {
            this.authStore.logout();
            this.$router.push('/');
        },
        getProgresso(form) {
            return form.progressoRespondente || 0;
        }
    }
};
</script>

<template>
    <div class="dashboard-container">
        <header class="dashboard-header">
            <div class="header-content">
                <div class="header-info">
                    <span class="header-label">Pesquisa Corporativa</span>
                    <h1 class="header-title">Participante</h1>
                </div>
                <div class="header-user">
                    <span class="senha-chip">Senha: {{ authStore.senhaCodigo }}</span>
                    <span class="setor-name">{{ authStore.setorNome }}</span>
                    <button class="logout-btn" @click="logout">Sair</button>
                </div>
            </div>
        </header>

        <main class="dashboard-main">
            <div class="intro-section">
                <h2 class="intro-title">Bem-vindo à Pesquisa</h2>
                <p class="intro-text">
                    Você possui <strong>2 formulários obrigatórios</strong> para responder.
                    Você pode responder em qualquer ordem. Cada formulário contém questões importantes para a avaliação dos processos organizacionais.
                </p>
            </div>

            <div class="forms-grid">
                <FormCard
                    v-for="form in formularios"
                    :key="form.id"
                    :titulo="form.titulo"
                    :descricao="form.descricao"
                    :concluido="form.concluido"
                    :emBreve="form.emBreve"
                    :progresso="getProgresso(form)"
                    @click="iniciarFormulario(form)"
                />
            </div>

            <div class="status-section">
                <div class="status-card">
                    <h3 class="status-title">Progresso Geral</h3>
                    <div class="status-info">
                        <span class="status-label">Formulários respondidos:</span>
                        <span class="status-value">
                            {{ formularios.filter(f => f.concluido).length }} / {{ formularios.length }}
                        </span>
                    </div>
                </div>
            </div>
        </main>
    </div>
</template>

<style scoped>
.dashboard-container {
    min-height: 100vh;
    background: #f8f9fa;
}

.dashboard-header {
    background: #ffffff;
    border-bottom: 1px solid #e0e0e0;
    padding: 24px 32px;
}

.header-content {
    max-width: 800px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.header-label {
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: #666;
    display: block;
    margin-bottom: 4px;
}

.header-title {
    font-family: 'Georgia', serif;
    font-size: 24px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0;
}

.header-user {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 8px;
}

.senha-chip {
    font-family: 'Courier New', monospace;
    font-size: 12px;
    color: #2c5282;
    background: #e8f0fe;
    padding: 4px 8px;
    border-radius: 3px;
}

.setor-name {
    font-size: 13px;
    color: #666;
}

.logout-btn {
    padding: 6px 14px;
    background: #ffffff;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 12px;
    color: #555;
    cursor: pointer;
    font-family: inherit;
    transition: all 0.2s;
}

.logout-btn:hover {
    background: #f5f5f5;
}

.dashboard-main {
    max-width: 800px;
    margin: 0 auto;
    padding: 32px;
}

.intro-section {
    text-align: center;
    margin-bottom: 32px;
    padding: 24px;
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
}

.intro-title {
    font-family: 'Georgia', serif;
    font-size: 20px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 12px 0;
}

.intro-text {
    font-size: 14px;
    color: #555;
    margin: 0;
    line-height: 1.6;
}

.intro-text strong {
    color: #2c5282;
}

.forms-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
    margin-bottom: 32px;
}

.status-section {
    margin-top: 24px;
}

.status-card {
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 20px 24px;
}

.status-title {
    font-size: 14px;
    font-weight: 600;
    color: #333;
    margin: 0 0 12px 0;
}

.status-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.status-label {
    font-size: 13px;
    color: #666;
}

.status-value {
    font-size: 14px;
    font-weight: 600;
    color: #2c5282;
}

@media (max-width: 640px) {
    .dashboard-header {
        padding: 20px;
    }

    .header-content {
        flex-direction: column;
        gap: 16px;
    }

    .header-user {
        width: 100%;
        align-items: flex-start;
    }

    .dashboard-main {
        padding: 20px;
    }

    .forms-grid {
        grid-template-columns: 1fr;
    }
}
</style>
