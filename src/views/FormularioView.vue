<script>
import { useAuthStore } from '../stores/auth';
import { useQuestionnaireStore } from '../stores/questionnaire';
import ProgressBar from '../components/common/ProgressBar.vue';
import QuestionRenderer from '../components/questionnaire/QuestionRenderer.vue';

export default {
    name: 'FormularioView',
    components: {
        ProgressBar,
        QuestionRenderer
    },
    setup() {
        return {
            authStore: useAuthStore(),
            questionnaireStore: useQuestionnaireStore()
        };
    },
    data() {
        return {
            loading: false,
            finalized: false,
            showingSuccess: false,
            savingMessage: 'Salvando respostas...'
        };
    },
    computed: {
        perguntaAtual() {
            return this.questionnaireStore.getPerguntaAtual;
        },
        progresso() {
            return this.questionnaireStore.getProgresso;
        },
        totalPerguntas() {
            return this.questionnaireStore.getTotalPerguntas;
        },
        perguntaIndex() {
            return this.questionnaireStore.perguntaAtualIndex;
        },
        respostaAtual() {
            if (!this.perguntaAtual) return null;
            const resp = this.questionnaireStore.respostas[this.perguntaAtual.id];
            return resp ? resp.valor : null;
        },
        podeAvancar() {
            return this.respostaAtual !== null;
        },
        formulario() {
            return this.questionnaireStore.getFormularioAtual;
        }
    },
    async mounted() {
        this.authStore.checkSession();
        if (!this.authStore.isLoggedIn) {
            this.$router.push('/login-respondente');
            return;
        }

        await this.authStore.refreshStatus();

        if (this.authStore.formularioOpcoesConcluido) {
            this.$router.push('/participante');
            return;
        }

        if (!this.questionnaireStore.formularioAtual) {
            this.questionnaireStore.iniciarFormulario('opcoes');
        }
    },
    methods: {
        atualizarResposta(valor) {
            if (this.loading || this.finalized) return;
            this.questionnaireStore.salvarResposta(this.perguntaAtual.id, valor);
        },
        proxima() {
            if (this.loading || this.finalized) return;

            if (this.questionnaireStore.proximaPergunta()) {
                return;
            }
            this.finalizar();
        },
        anterior() {
            if (this.loading || this.finalized) return;
            this.questionnaireStore.perguntaAnterior();
        },
        async finalizar() {
            if (this.loading || this.finalized) return;

            this.loading = true;
            this.finalized = true;
            this.savingMessage = 'Salvando respostas no banco de dados...';

            try {
                const result = await this.questionnaireStore.enviarFormulario(
                    this.authStore.senhaId,
                    this.authStore.setorId
                );

                if (result) {
                    this.authStore.setFormularioStatus('opcoes', true);
                    this.savingMessage = 'Verificando registro das respostas...';
                    await new Promise(r => setTimeout(r, 500));
                    this.showingSuccess = true;
                } else {
                    throw new Error('Falha ao enviar');
                }
            } catch (e) {
                console.error('Erro ao enviar:', e);
                alert(e?.message || 'Erro ao enviar respostas. Por favor, tente novamente.');
                this.loading = false;
                this.finalized = false;
                this.showingSuccess = false;
            }
        },
        goToDashboard() {
            this.showingSuccess = false;
            this.questionnaireStore.resetFormulario();
            this.questionnaireStore.carregarStatusFormularios(this.authStore.senhaId);
            this.$router.push('/participante');
        },
        sair() {
            this.questionnaireStore.resetFormulario();
            this.authStore.logout();
            this.$router.push('/');
        }
    }
};
</script>

<template>
    <div class="form-container">
        <header class="form-header">
            <div class="header-top">
                <span class="form-badge">Questionário</span>
                <button class="exit-btn" @click="sair" :disabled="loading">Sair</button>
            </div>
            <h1 class="form-title">{{ formulario?.titulo }}</h1>
            <p class="form-subtitle">Setor: {{ authStore.setorNome }}</p>
        </header>

        <div class="form-content">
            <ProgressBar
                :progresso="progresso"
                :label="`Pergunta ${perguntaIndex + 1} de ${totalPerguntas}`"
            />

            <QuestionRenderer
                v-if="perguntaAtual && !showingSuccess"
                :pergunta="perguntaAtual"
                :resposta="respostaAtual"
                @update="atualizarResposta"
            />

            <div v-if="!showingSuccess" class="form-navigation">
                <button
                    class="nav-btn prev"
                    @click="anterior"
                    :disabled="perguntaIndex === 0 || loading"
                >
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="19" y1="12" x2="5" y2="12"></line>
                        <polyline points="12 19 5 12 12 5"></polyline>
                    </svg>
                    <span class="btn-text">Anterior</span>
                </button>

                <button
                    class="nav-btn next"
                    @click="proxima"
                    :disabled="!podeAvancar || loading || finalized"
                >
                    <span v-if="loading" class="spinner-small"></span>
                    <span v-else class="btn-text">
                        {{ perguntaIndex === totalPerguntas - 1 ? 'Finalizar' : 'Próxima' }}
                    </span>
                    <svg v-if="!loading && perguntaIndex !== totalPerguntas - 1" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                        <polyline points="12 5 19 12 12 19"></polyline>
                    </svg>
                </button>
            </div>

            <div v-if="loading && !showingSuccess" class="saving-indicator">
                <span class="saving-spinner"></span>
                <span>{{ savingMessage }}</span>
            </div>

            <div v-if="showingSuccess" class="success-modal">
                <div class="success-content">
                    <div class="success-icon">
                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                            <polyline points="22 4 12 14.01 9 11.01"></polyline>
                        </svg>
                    </div>
                    <h2 class="success-title">Respostas Salvas!</h2>
                    <p class="success-text">
                        Suas respostas foram registradas com sucesso no banco de dados.
                    </p>
                    <button class="dashboard-btn" @click="goToDashboard">
                        Voltar ao Menu
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.form-container {
    min-height: 100vh;
    background: #f8f9fa;
    display: flex;
    flex-direction: column;
}

.form-header {
    background: #2c5282;
    padding: 20px;
}

.header-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
}

.form-badge {
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: rgba(255, 255, 255, 0.7);
    padding: 4px 10px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    background: rgba(255, 255, 255, 0.1);
}

.exit-btn {
    padding: 6px 14px;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 3px;
    font-size: 12px;
    color: rgba(255, 255, 255, 0.8);
    cursor: pointer;
    font-family: inherit;
    transition: all 0.2s;
}

.exit-btn:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.2);
    color: #ffffff;
}

.exit-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.form-title {
    font-family: 'Georgia', serif;
    font-size: 20px;
    font-weight: 600;
    color: #ffffff;
    margin: 0 0 6px 0;
}

.form-subtitle {
    font-size: 13px;
    color: rgba(255, 255, 255, 0.7);
    margin: 0;
}

.form-content {
    flex: 1;
    max-width: 700px;
    width: 100%;
    margin: 0 auto;
    padding: 20px;
}

.form-navigation {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 24px;
    padding-top: 20px;
    border-top: 1px solid #e0e0e0;
    gap: 12px;
}

.nav-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px 20px;
    border: 1px solid;
    border-radius: 3px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    font-family: inherit;
    flex: 1;
    max-width: 160px;
}

.nav-btn.prev {
    background: #ffffff;
    border-color: #ccc;
    color: #555;
}

.nav-btn.prev:hover:not(:disabled) {
    background: #f5f5f5;
}

.nav-btn.prev:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}

.nav-btn.next {
    background: #2c5282;
    border-color: #2c5282;
    color: #ffffff;
}

.nav-btn.next:hover:not(:disabled) {
    background: #1a365d;
}

.nav-btn.next:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.btn-text {
    white-space: nowrap;
}

.spinner-small {
    width: 16px;
    height: 16px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-top-color: #fff;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}

.saving-indicator {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-top: 16px;
    padding: 12px;
    background: #f8fbff;
    border: 1px solid #e8f0fe;
    border-radius: 4px;
    font-size: 13px;
    color: #2c5282;
}

.saving-spinner {
    width: 14px;
    height: 14px;
    border: 2px solid #e8f0fe;
    border-top-color: #2c5282;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}

.success-modal {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 20px;
}

.success-content {
    background: #ffffff;
    border-radius: 8px;
    padding: 32px;
    text-align: center;
    max-width: 400px;
    width: 100%;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.success-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 64px;
    height: 64px;
    margin: 0 auto 16px;
    background: #e6f4ea;
    border-radius: 50%;
    color: #34a853;
}

.success-title {
    font-family: 'Georgia', serif;
    font-size: 20px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 12px 0;
}

.success-text {
    font-size: 14px;
    color: #555;
    margin: 0 0 24px 0;
    line-height: 1.5;
}

.dashboard-btn {
    padding: 12px 32px;
    background: #2c5282;
    color: #ffffff;
    border: none;
    border-radius: 4px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    font-family: inherit;
}

.dashboard-btn:hover {
    background: #1a365d;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

@media (max-width: 480px) {
    .form-header {
        padding: 16px;
    }

    .form-title {
        font-size: 18px;
    }

    .form-content {
        padding: 16px;
    }

    .form-navigation {
        flex-direction: column-reverse;
        gap: 10px;
    }

    .nav-btn {
        width: 100%;
        max-width: none;
        padding: 14px;
    }

    .btn-text {
        font-size: 14px;
    }

    .success-content {
        padding: 24px;
    }

    .success-title {
        font-size: 18px;
    }
}
</style>
