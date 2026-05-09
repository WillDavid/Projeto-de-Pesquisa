<script>
import { supabase, generatePassword } from '../supabase';
import * as XLSX from 'xlsx';
import SetorList from '../components/admin/SetorList.vue';
import SenhaList from '../components/admin/SenhaList.vue';
import { perguntasOpcoes } from '../data/perguntasOpcoes';
import { perguntasPreferencias } from '../data/perguntasPreferencias';

export default {
    name: 'AdminView',
    components: {
        SetorList,
        SenhaList
    },
    data() {
        return {
            activeTab: 'setores',
            selectedSetor: null,
            loading: true,
            exportando: false
        };
    },
    async mounted() {
        const isAdmin = localStorage.getItem('adminLogado');
        if (!isAdmin) {
            this.$router.push('/login-admin');
            return;
        }
        this.loading = false;
    },
    methods: {
        logout() {
            localStorage.removeItem('adminLogado');
            this.$router.push('/');
        },
        selectSetor(setor) {
            this.selectedSetor = setor;
            this.activeTab = 'senhas';
        },
        backToSetores() {
            this.selectedSetor = null;
            this.activeTab = 'setores';
        },
        async exportarRespostas(formato) {
            if (this.exportando) {
                return;
            }

            this.exportando = true;

            try {
                const [setoresResult, senhasResult, respostasOpcoesResult, respostasPreferenciasResult] = await Promise.all([
                    supabase.from('setores').select('id, nome').order('nome'),
                    supabase.from('senhas').select('id, senha, setor_id').order('id'),
                    supabase.from('respostas_opcoes').select('senha_id, pergunta_id, resposta'),
                    supabase.from('respostas_preferencias').select('senha_id, pergunta_id, resposta')
                ]);

                const errors = [
                    setoresResult.error,
                    senhasResult.error,
                    respostasOpcoesResult.error,
                    respostasPreferenciasResult.error
                ].filter(Boolean);

                if (errors.length > 0) {
                    throw new Error(errors[0].message);
                }

                const setoresMap = new Map((setoresResult.data || []).map((item) => [item.id, item.nome]));

                const respostasOpcoesMap = new Map();
                for (const item of respostasOpcoesResult.data || []) {
                    const key = `${item.senha_id}:${item.pergunta_id}`;
                    respostasOpcoesMap.set(key, item.resposta);
                }

                const respostasPreferenciasMap = new Map();
                for (const item of respostasPreferenciasResult.data || []) {
                    const key = `${item.senha_id}:${item.pergunta_id}`;
                    respostasPreferenciasMap.set(key, item.resposta);
                }

                const linhas = (senhasResult.data || []).map((senhaItem) => {
                    const row = {
                        Setor: setoresMap.get(senhaItem.setor_id) || '',
                        Senha: senhaItem.senha
                    };

                    for (const pergunta of perguntasOpcoes) {
                        const key = `${senhaItem.id}:${pergunta.id}`;
                        row[`${pergunta.id} - ${pergunta.pergunta}`] = respostasOpcoesMap.has(key)
                            ? respostasOpcoesMap.get(key)
                            : '';
                    }

                    for (const pergunta of perguntasPreferencias) {
                        const key = `${senhaItem.id}:${pergunta.id}`;
                        row[`${pergunta.id} - ${pergunta.descricao}`] = respostasPreferenciasMap.has(key)
                            ? respostasPreferenciasMap.get(key)
                            : '';
                    }

                    return row;
                });

                const worksheet = XLSX.utils.json_to_sheet(linhas);
                const workbook = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(workbook, worksheet, 'Respostas');

                const dataArquivo = new Date().toISOString().slice(0, 10);
                const nomeBase = `pesquisa-corporativa-${dataArquivo}`;

                if (formato === 'csv') {
                    XLSX.writeFile(workbook, `${nomeBase}.csv`, { bookType: 'csv' });
                } else {
                    XLSX.writeFile(workbook, `${nomeBase}.xlsx`, { bookType: 'xlsx' });
                }
            } catch (error) {
                console.error('Erro ao exportar respostas:', error);
                alert(error?.message || 'Erro ao exportar respostas.');
            } finally {
                this.exportando = false;
            }
        },
        onTabChange(tab) {
            if (tab === 'setores') {
                this.selectedSetor = null;
            }
            this.activeTab = tab;
        }
    }
};
</script>

<template>
    <div class="admin-container">
        <div v-if="loading" class="loading-screen">
            <div class="spinner"></div>
        </div>
        <div v-else>
            <header class="admin-header">
                <div class="header-left">
                    <div class="header-badge">Admin</div>
                    <h1 class="admin-title">Painel de Controle</h1>
                </div>
                <div class="header-actions">
                    <button class="export-btn" @click="exportarRespostas('csv')" :disabled="exportando">
                        {{ exportando ? 'Exportando...' : 'Baixar CSV' }}
                    </button>
                    <button class="export-btn excel" @click="exportarRespostas('xlsx')" :disabled="exportando">
                        {{ exportando ? 'Exportando...' : 'Baixar Excel' }}
                    </button>
                    <button class="logout-btn" @click="logout">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16 17 21 12 16 7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        Sair
                    </button>
                </div>
            </header>

            <div class="admin-content">
                <nav class="admin-tabs">
                    <button
                        :class="['tab-btn', { active: activeTab === 'setores' }]"
                        @click="onTabChange('setores')"
                    >
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
                        </svg>
                        Setores
                    </button>
                    <button
                        :class="['tab-btn', { active: activeTab === 'senhas' }]"
                        @click="onTabChange('senhas')"
                        :disabled="!selectedSetor"
                    >
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path>
                        </svg>
                        Senhas de Respondentes
                    </button>
                </nav>

                <div class="tab-content">
                    <SetorList
                        v-if="activeTab === 'setores'"
                        @select="selectSetor"
                    />

                    <div v-else-if="activeTab === 'senhas' && selectedSetor">
                        <SenhaList :setor="selectedSetor" @back="backToSetores" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.admin-container {
    min-height: 100vh;
    background: #f8f9fa;
}

.loading-screen {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
}

.spinner {
    width: 32px;
    height: 32px;
    border: 3px solid #eee;
    border-top: 3px solid #333;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.admin-header {
    background: #ffffff;
    padding: 16px 32px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #e0e0e0;
}

.header-left {
    display: flex;
    align-items: center;
    gap: 12px;
}

.header-badge {
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 1px;
    text-transform: uppercase;
    color: #666;
    padding: 4px 8px;
    border: 1px solid #ccc;
    background: #fafafa;
}

.admin-title {
    font-family: 'Georgia', 'Times New Roman', serif;
    font-size: 20px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0;
}

.header-actions {
    display: flex;
    align-items: center;
    gap: 10px;
}

.export-btn {
    padding: 8px 14px;
    background: #2c5282;
    border: 1px solid #2c5282;
    border-radius: 3px;
    font-size: 13px;
    font-weight: 500;
    color: #ffffff;
    cursor: pointer;
    transition: all 0.2s;
    font-family: inherit;
}

.export-btn.excel {
    background: #1f6f43;
    border-color: #1f6f43;
}

.export-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.logout-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    background: #ffffff;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 13px;
    font-weight: 500;
    color: #555;
    cursor: pointer;
    transition: all 0.2s;
    font-family: inherit;
}

.logout-btn:hover {
    background: #f5f5f5;
    color: #333;
}

.admin-content {
    max-width: 1000px;
    margin: 0 auto;
    padding: 32px;
}

.admin-tabs {
    display: flex;
    gap: 8px;
    margin-bottom: 24px;
    border-bottom: 1px solid #e0e0e0;
    padding-bottom: 16px;
}

.tab-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 18px;
    background: #ffffff;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 13px;
    font-weight: 500;
    color: #555;
    cursor: pointer;
    transition: all 0.2s;
    font-family: inherit;
}

.tab-btn:hover:not(:disabled) {
    background: #f5f5f5;
}

.tab-btn.active {
    background: #333;
    color: #ffffff;
    border-color: #333;
}

.tab-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}

.tab-content {
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 24px;
}

@media (max-width: 820px) {
    .admin-header {
        padding: 16px 20px;
        flex-direction: column;
        align-items: flex-start;
        gap: 12px;
    }

    .header-actions {
        width: 100%;
        flex-wrap: wrap;
    }

    .admin-content {
        padding: 20px;
    }
}
</style>
