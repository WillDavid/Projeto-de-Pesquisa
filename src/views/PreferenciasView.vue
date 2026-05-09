<script>
import { supabase } from '../supabase';
import { useAuthStore } from '../stores/auth';
import { useQuestionnaireStore } from '../stores/questionnaire';
import ProgressBar from '../components/common/ProgressBar.vue';
import { perguntasPreferencias } from '../data/perguntasPreferencias';

const STEPS = [
    {
        id: 'mais_20',
        fase: 'Mais Importantes',
        titulo: 'Selecione as 20 mais importantes',
        descricao: 'Das 46 afirmacoes, escolha as 20 que sao mais importantes para a organizacao.',
        required: 20,
        source: 'all'
    },
    {
        id: 'mais_10',
        fase: 'Mais Importantes',
        titulo: 'Selecione as 10 mais importantes',
        descricao: 'Das 20 que voce escolheu, selecione as 10 que considera mais importantes de todas.',
        required: 10,
        source: 'mais20'
    },
    {
        id: 'menos_20',
        fase: 'Menos Importantes',
        titulo: 'Selecione as 20 menos importantes',
        descricao: 'Das 46 afirmacoes, escolha as 20 que sao menos importantes para a organizacao.',
        required: 20,
        source: 'all'
    },
    {
        id: 'menos_10',
        fase: 'Menos Importantes',
        titulo: 'Selecione as 10 menos importantes',
        descricao: 'Das 20 que voce escolheu, selecione as 10 que considera menos importantes de todas.',
        required: 10,
        source: 'menos20'
    }
];

export default {
    name: 'PreferenciasView',
    components: {
        ProgressBar
    },
    setup() {
        return {
            authStore: useAuthStore(),
            questionnaireStore: useQuestionnaireStore()
        };
    },
    data() {
        return {
            steps: STEPS,
            loading: true,
            saving: false,
            showingSuccess: false,
            perguntas: [],
            currentStepIndex: 0,
            selectedIds: [],
            stageSelections: {
                mais20: [],
                mais10: [],
                menos20: [],
                menos10: []
            },
            savingMessage: 'Salvando classificacao...',
            showModal: true,
            showMaxAlert: false
        };
    },
    computed: {
        currentStep() {
            return this.steps[this.currentStepIndex];
        },
        progresso() {
            if (this.showingSuccess) {
                return 100;
            }

            return Math.round((this.currentStepIndex / this.steps.length) * 100);
        },
        availableQuestions() {
            if (!this.currentStep) {
                return [];
            }

            if (this.currentStep.source === 'mais20') {
                return this.perguntas.filter((item) => this.stageSelections.mais20.includes(item.id));
            }

            if (this.currentStep.source === 'menos20') {
                return this.perguntas.filter((item) => this.stageSelections.menos20.includes(item.id));
            }

            return this.perguntas;
        },
        canAdvance() {
            return this.selectedIds.length === (this.currentStep?.required || 0);
        },
        totalSelecionadas() {
            return this.selectedIds.length;
        }
    },
    async mounted() {
        this.authStore.checkSession();
        if (!this.authStore.isLoggedIn) {
            this.$router.push('/login-respondente');
            return;
        }

        await this.authStore.refreshStatus();

        if (this.authStore.formularioPreferenciasConcluido) {
            this.$router.push('/participante');
            return;
        }

        await this.loadQuestions();
        this.restoreProgress();
        this.loading = false;
    },
    methods: {
        progressKey() {
            return `preferencias_${this.authStore.senhaId}`;
        },
        async loadQuestions() {
            const { data, error } = await supabase
                .from('perguntas_preferencias')
                .select('*')
                .order('ordem');

            if (error || !data || data.length === 0) {
                this.perguntas = perguntasPreferencias.map((item, index) => ({
                    ...item,
                    ordem: index + 1
                }));
                return;
            }

            this.perguntas = data.map((item, index) => ({
                id: item.id,
                descricao: item.pergunta || item.descricao,
                peso: Number(item.peso || 3),
                ordem: item.ordem || index + 1
            }));
        },
        restoreProgress() {
            const saved = localStorage.getItem(this.progressKey());
            if (!saved) {
                return;
            }

            try {
                const parsed = JSON.parse(saved);
                this.currentStepIndex = parsed.currentStepIndex || 0;
                this.selectedIds = parsed.selectedIds || [];
                this.stageSelections = parsed.stageSelections || this.stageSelections;

                if (Array.isArray(parsed.perguntas) && parsed.perguntas.length === this.perguntas.length) {
                    const pesoMap = new Map(parsed.perguntas.map((item) => [item.id, item.peso]));
                    this.perguntas = this.perguntas.map((item) => ({
                        ...item,
                        peso: Number(pesoMap.get(item.id) ?? item.peso)
                    }));
                }
            } catch (error) {
                console.error('Erro ao restaurar progresso de preferencias:', error);
            }
        },
        persistProgress() {
            localStorage.setItem(this.progressKey(), JSON.stringify({
                currentStepIndex: this.currentStepIndex,
                selectedIds: this.selectedIds,
                stageSelections: this.stageSelections,
                perguntas: this.perguntas.map((item) => ({ id: item.id, peso: item.peso }))
            }));
        },
        toggleSelection(id) {
            if (this.saving || this.showingSuccess) {
                return;
            }

            if (this.selectedIds.includes(id)) {
                this.selectedIds = this.selectedIds.filter((item) => item !== id);
                this.persistProgress();
                return;
            }

            if (this.selectedIds.length >= this.currentStep.required) {
                this.showMaxAlert = true;
                return;
            }

            this.selectedIds = [...this.selectedIds, id];
            this.persistProgress();
        },
        applyCurrentStep() {
            if (this.currentStep.id === 'mais_20') {
                this.stageSelections.mais20 = [...this.selectedIds];
                this.perguntas = this.perguntas.map((item) => ({
                    ...item,
                    peso: this.selectedIds.includes(item.id) ? 4 : item.peso
                }));
            }

            if (this.currentStep.id === 'mais_10') {
                this.stageSelections.mais10 = [...this.selectedIds];
                this.perguntas = this.perguntas.map((item) => ({
                    ...item,
                    peso: this.selectedIds.includes(item.id) ? 5 : item.peso
                }));
            }

            if (this.currentStep.id === 'menos_20') {
                this.stageSelections.menos20 = [...this.selectedIds];
                this.perguntas = this.perguntas.map((item) => {
                    if (!this.selectedIds.includes(item.id)) {
                        return item;
                    }

                    return {
                        ...item,
                        peso: item.peso === 3 ? 2 : 0
                    };
                });
            }

            if (this.currentStep.id === 'menos_10') {
                this.stageSelections.menos10 = [...this.selectedIds];
                this.perguntas = this.perguntas.map((item) => {
                    if (!this.selectedIds.includes(item.id)) {
                        return item;
                    }

                    return {
                        ...item,
                        peso: item.peso === 2 ? 1 : 0
                    };
                });
            }
        },
        async advanceStep() {
            if (!this.canAdvance || this.saving) {
                return;
            }

            this.applyCurrentStep();

            if (this.currentStepIndex === this.steps.length - 1) {
                await this.finalizeSurvey();
                return;
            }

            this.currentStepIndex += 1;
            this.selectedIds = [];
            this.showModal = true;
            this.persistProgress();
        },
        async verifySavedWeights() {
            const expected = new Map(this.perguntas.map((item) => [item.id, String(item.peso)]));
            const { data, error } = await supabase
                .from('respostas_preferencias')
                .select('pergunta_id, resposta')
                .eq('senha_id', this.authStore.senhaId)
                .eq('setor_id', this.authStore.setorId)
                .in('pergunta_id', this.perguntas.map((item) => item.id));

            if (error) {
                throw error;
            }

            if (!data || data.length !== this.perguntas.length) {
                return false;
            }

            return data.every((item) => expected.get(item.pergunta_id) === String(item.resposta));
        },
        async finalizeSurvey() {
            this.saving = true;
            this.savingMessage = 'Salvando pesos finais da pesquisa...';

            try {
                const rows = this.perguntas.map((item) => ({
                    senha_id: this.authStore.senhaId,
                    setor_id: this.authStore.setorId,
                    pergunta_id: item.id,
                    resposta: String(item.peso),
                    data_resposta: new Date().toISOString()
                }));

                const { error } = await supabase
                    .from('respostas_preferencias')
                    .upsert(rows, { onConflict: 'senha_id,pergunta_id' });

                if (error) {
                    throw error;
                }

                this.savingMessage = 'Verificando gravacao no banco de dados...';
                const verified = await this.verifySavedWeights();

                if (!verified) {
                    await new Promise((resolve) => setTimeout(resolve, 1000));
                    const retryVerified = await this.verifySavedWeights();
                    if (!retryVerified) {
                        throw new Error('Falha na verificacao das respostas de preferencias.');
                    }
                }

                const { error: statusError } = await supabase
                    .from('senhas')
                    .update({
                        formulario_preferencias_concluido: true,
                        formulario_preferencias_concluido_em: new Date().toISOString()
                    })
                    .eq('id', this.authStore.senhaId);

                if (statusError) {
                    throw new Error('As preferencias foram gravadas, mas o status da senha nao foi atualizado.');
                }

                this.authStore.setFormularioStatus('preferencias', true);
                localStorage.removeItem(this.progressKey());
                this.showingSuccess = true;
            } catch (error) {
                console.error('Erro ao finalizar preferencias:', error);
                alert(error?.message || 'Erro ao salvar preferencias.');
            } finally {
                this.saving = false;
            }
        },
        goToParticipante() {
            this.questionnaireStore.resetFormulario();
            this.$router.push('/participante');
        },
        closeModal() {
            this.showModal = false;
        },
        closeMaxAlert() {
            this.showMaxAlert = false;
        },
        sair() {
            this.authStore.logout();
            this.$router.push('/');
        }
    }
};
</script>

<template>
    <div class="preferencias-container">
        <header class="preferencias-header">
            <div class="header-top">
                <div>
                    <span class="header-badge">Pesquisa Preferencial</span>
                    <h1 class="header-title">Formulário de Preferências</h1>
                    <p class="header-subtitle">Senha: {{ authStore.senhaCodigo }} | Setor: {{ authStore.setorNome }}</p>
                </div>
                <button class="exit-btn" @click="sair" :disabled="saving">Sair</button>
            </div>
        </header>

        <main class="preferencias-main">
            <div v-if="loading" class="loading-state">Carregando pesquisa...</div>

            <template v-else>
                <Teleport to="body">
                    <div v-if="showModal && !showingSuccess" class="modal-overlay" @click.self="closeModal">
                        <div class="modal-content">
                            <span :class="['modal-badge', currentStep.fase === 'Mais Importantes' ? 'badge-mais' : 'badge-menos']">
                                {{ currentStep.fase }}
                            </span>
                            <h3 class="modal-title">{{ currentStep.titulo }}</h3>
                            <p class="modal-description">{{ currentStep.descricao }}</p>
                            <p class="modal-instruction">
                                Você precisa selecionar exatamente <strong>{{ currentStep.required }}</strong> opções.
                            </p>
                            <button class="modal-btn" @click="closeModal">Entendi</button>
                        </div>
                    </div>

                    <div v-if="showMaxAlert" class="modal-overlay" @click.self="closeMaxAlert">
                        <div class="modal-content">
                            <div class="modal-alert-icon">
                                <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                                    <circle cx="24" cy="24" r="24" fill="#fff3cd"/>
                                    <path d="M24 14v10M24 28v4" stroke="#856404" stroke-width="3" stroke-linecap="round"/>
                                </svg>
                            </div>
                            <h3 class="modal-title">Limite atingido</h3>
                            <p class="modal-description">
                                Voce ja selecionou o maximo de <strong>{{ currentStep.required }}</strong> opcoes desta etapa.
                            </p>
                            <p class="modal-description">Para alterar, clique em uma opcao ja selecionada para remove-la.</p>
                            <button class="modal-btn" @click="closeMaxAlert">Entendi</button>
                        </div>
                    </div>
                </Teleport>

                <ProgressBar
                    :progresso="progresso"
                    :label="`Etapa ${currentStepIndex + 1} de ${steps.length}`"
                />

                <section v-if="!showingSuccess" class="step-card">
                    <span class="step-phase">{{ currentStep.fase }}</span>
                    <h2 class="step-title">{{ currentStep.titulo }}</h2>
                    <p class="step-description">{{ currentStep.descricao }}</p>

                    <div class="selection-summary">
                        <span>Selecionadas: <strong>{{ totalSelecionadas }}</strong> / {{ currentStep.required }}</span>
                    </div>

                    <div class="question-list">
                        <button
                            v-for="pergunta in availableQuestions"
                            :key="pergunta.id"
                            type="button"
                            :class="['question-item', { selected: selectedIds.includes(pergunta.id) }]"
                            @click="toggleSelection(pergunta.id)"
                            :disabled="saving"
                        >
                            <div class="question-meta">
                                <span class="question-id">{{ pergunta.id }}</span>
                                <span class="question-weight">Peso atual: {{ pergunta.peso }}</span>
                            </div>
                            <span class="question-text">{{ pergunta.descricao }}</span>
                        </button>
                    </div>

                    <div class="actions">
                        <button class="primary-btn" :disabled="!canAdvance || saving" @click="advanceStep">
                            <span v-if="saving" class="spinner"></span>
                            <span v-else>{{ currentStepIndex === steps.length - 1 ? 'Finalizar Pesquisa' : 'Continuar' }}</span>
                        </button>
                    </div>

                    <div v-if="saving" class="saving-box">{{ savingMessage }}</div>
                </section>

                <section v-else class="success-card">
                    <div class="success-icon">✓</div>
                    <h2 class="success-title">Pesquisa de Preferências concluída</h2>
                    <p class="success-text">A classificacao final foi registrada com sucesso. Este formulário nao pode mais ser respondido por esta senha.</p>
                    <button class="primary-btn" @click="goToParticipante">Voltar para Participante</button>
                </section>
            </template>
        </main>
    </div>
</template>

<style scoped>
.preferencias-container {
    min-height: 100vh;
    background: #f8f9fa;
}

.preferencias-header {
    background: #2c5282;
    color: #fff;
    padding: 20px 24px;
}

.header-top {
    max-width: 980px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    gap: 16px;
}

.header-badge {
    display: inline-block;
    margin-bottom: 8px;
    padding: 4px 10px;
    font-size: 10px;
    letter-spacing: 2px;
    text-transform: uppercase;
    border: 1px solid rgba(255, 255, 255, 0.35);
}

.header-title {
    margin: 0 0 6px;
    font-family: 'Georgia', serif;
    font-size: 26px;
}

.header-subtitle {
    margin: 0;
    color: rgba(255, 255, 255, 0.82);
    font-size: 13px;
}

.exit-btn,
.primary-btn {
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-family: inherit;
}

.exit-btn {
    align-self: flex-start;
    padding: 10px 16px;
    background: rgba(255, 255, 255, 0.12);
    color: #fff;
}

.preferencias-main {
    max-width: 980px;
    margin: 0 auto;
    padding: 24px;
}

.loading-state,
.step-card,
.success-card {
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    padding: 24px;
}

.step-phase {
    display: inline-block;
    margin-bottom: 10px;
    padding: 4px 10px;
    background: #eef3ff;
    color: #2c5282;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 600;
}

.step-title,
.success-title {
    margin: 0 0 8px;
    font-family: 'Georgia', serif;
    font-size: 28px;
    color: #1a1a1a;
}

.step-description,
.success-text {
    margin: 0 0 18px;
    color: #555;
    line-height: 1.6;
}

.selection-summary {
    margin-bottom: 18px;
    font-size: 14px;
    color: #2c5282;
}

.question-list {
    display: grid;
    gap: 12px;
}

.question-item {
    width: 100%;
    padding: 16px;
    border: 1px solid #d9dde3;
    border-radius: 6px;
    background: #fff;
    text-align: left;
    transition: all 0.2s ease;
}

.question-item:hover:not(:disabled) {
    border-color: #2c5282;
    background: #f8fbff;
}

.question-item.selected {
    border-color: #2c5282;
    background: #eef4ff;
}

.question-item:disabled {
    opacity: 0.7;
    cursor: not-allowed;
}

.question-meta {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 8px;
    font-size: 12px;
}

.question-id {
    font-family: 'Courier New', monospace;
    color: #2c5282;
    font-weight: 700;
}

.question-weight {
    color: #666;
}

.question-text {
    display: block;
    color: #222;
    line-height: 1.5;
}

.actions {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
}

.primary-btn {
    min-width: 220px;
    padding: 14px 20px;
    background: #2c5282;
    color: #fff;
    font-size: 14px;
    font-weight: 600;
}

.primary-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.saving-box {
    margin-top: 16px;
    padding: 12px 14px;
    background: #f8fbff;
    border: 1px solid #d9e6ff;
    color: #2c5282;
    border-radius: 4px;
}

.success-card {
    text-align: center;
}

.success-icon {
    width: 64px;
    height: 64px;
    margin: 0 auto 16px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #e6f4ea;
    color: #34a853;
    font-size: 28px;
    font-weight: 700;
}

.spinner {
    width: 16px;
    height: 16px;
    display: inline-block;
    border: 2px solid rgba(255, 255, 255, 0.4);
    border-top-color: #fff;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

@media (max-width: 720px) {
    .header-top {
        flex-direction: column;
    }

    .preferencias-main {
        padding: 16px;
    }

    .step-title,
    .success-title {
        font-size: 22px;
    }

    .question-meta {
        flex-direction: column;
        gap: 4px;
    }

    .actions {
        justify-content: stretch;
    }

    .primary-btn {
        width: 100%;
        min-width: 0;
    }
}

.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    padding: 20px;
}

.modal-content {
    background: #fff;
    border-radius: 12px;
    padding: 32px;
    max-width: 480px;
    width: 100%;
    text-align: center;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
}

.modal-badge {
    display: inline-block;
    margin-bottom: 16px;
    padding: 8px 16px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
}

.badge-mais {
    background: #d4edda;
    color: #155724;
    border: 2px solid #28a745;
}

.badge-menos {
    background: #f8d7da;
    color: #721c24;
    border: 2px solid #dc3545;
}

.modal-title {
    margin: 0 0 12px;
    font-family: 'Georgia', serif;
    font-size: 24px;
    color: #1a1a1a;
}

.modal-description {
    margin: 0 0 20px;
    color: #555;
    line-height: 1.6;
    font-size: 15px;
}

.modal-instruction {
    margin: 0 0 28px;
    padding: 14px;
    background: #f8fbff;
    border-radius: 8px;
    color: #2c5282;
    font-size: 14px;
}

.modal-instruction strong {
    color: #1a365d;
}

.modal-btn {
    width: 100%;
    max-width: 280px;
    padding: 14px 24px;
    background: #2c5282;
    color: #fff;
    border: none;
    border-radius: 6px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s ease;
}

.modal-btn:hover {
    background: #1a365d;
}
</style>
