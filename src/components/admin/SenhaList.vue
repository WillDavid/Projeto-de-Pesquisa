<script>
import { supabase, generatePassword, isValidPassword } from '../../supabase';

export default {
    name: 'SenhaList',
    props: {
        setor: {
            type: Object,
            required: true
        }
    },
    emits: ['back'],
    data() {
        return {
            senhas: [],
            loading: false,
            error: '',
            quantidadeSenhas: 1,
            geracaoLoading: false
        };
    },
    async mounted() {
        await this.loadSenhas();
    },
    methods: {
        async loadSenhas() {
            this.loading = true;
            const { data, error } = await supabase
                .from('senhas')
                .select('*')
                .eq('setor_id', this.setor.id)
                .order('created_at', { ascending: false });
            if (!error) {
                this.senhas = data;
            }
            this.loading = false;
        },
        async generateSenha() {
            if (this.geracaoLoading) return;
            this.geracaoLoading = true;

            const quantity = parseInt(this.quantidadeSenhas) || 1;
            if (quantity < 1 || quantity > 500) {
                alert('Quantidade deve ser entre 1 e 500');
                this.geracaoLoading = false;
                return;
            }

            const existingSenhas = new Set((await supabase.from('senhas').select('senha')).data?.map(s => s.senha) || []);
            const newSenhas = [];

            for (let i = 0; i < quantity; i++) {
                let newSenha = generatePassword();
                let exists = true;

                while (exists) {
                    if (existingSenhas.has(newSenha)) {
                        newSenha = generatePassword();
                    } else {
                        exists = false;
                        existingSenhas.add(newSenha);
                    }
                }

                newSenhas.push({
                    senha: newSenha,
                    setor_id: this.setor.id
                });
            }

            if (newSenhas.length > 0) {
                await supabase.from('senhas').insert(newSenhas);
                await this.loadSenhas();
            }

            this.geracaoLoading = false;
        },
        async deleteSenha(senha) {
            if (!confirm(`Excluir a senha "${senha.senha}"?`)) return;

            await supabase
                .from('senhas')
                .delete()
                .eq('id', senha.id);

            await this.loadSenhas();
        },
        goBack() {
            this.$emit('back');
        }
    }
};
</script>

<template>
    <div class="senha-list">
        <div class="list-header">
            <div class="header-left">
                <button class="back-btn" @click="goBack">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="19" y1="12" x2="5" y2="12"></line>
                        <polyline points="12 19 5 12 12 5"></polyline>
                    </svg>
                    Voltar
                </button>
                <h2 class="list-title">
                    Senhas do Setor: <span class="setor-name">{{ setor.nome }}</span>
                </h2>
            </div>
            <div class="generate-section">
                <div class="quantity-input">
                    <label for="quantidade">Quantidade:</label>
                    <input
                        id="quantidade"
                        type="number"
                        v-model.number="quantidadeSenhas"
                        min="1"
                        max="500"
                    />
                </div>
                <button class="add-btn" @click="generateSenha" :disabled="geracaoLoading">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="12" y1="5" x2="12" y2="19"></line>
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                    </svg>
                    {{ geracaoLoading ? 'Gerando...' : (quantidadeSenhas === 1 ? 'Gerar Nova Senha' : 'Gerar ' + quantidadeSenhas + ' Senhas') }}
                </button>
            </div>
        </div>

        <p class="info-text">
            As senhas possuem 8 caracteres alfanuméricos e são únicas no sistema.
        </p>

        <div v-if="loading" class="loading">Carregando...</div>

        <table v-else class="senha-table">
            <thead>
                <tr>
                    <th>Senha</th>
                    <th>Data de Criação</th>
                    <th>Ações</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="senha in senhas" :key="senha.id">
                    <td class="senha-cell">{{ senha.senha }}</td>
                    <td>{{ new Date(senha.created_at).toLocaleDateString('pt-BR') }}</td>
                    <td class="actions">
                        <button class="action-btn delete" @click="deleteSenha(senha)">
                            Excluir
                        </button>
                    </td>
                </tr>
                <tr v-if="senhas.length === 0">
                    <td colspan="3" class="empty">Nenhuma senha cadastrada neste setor</td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<style scoped>
.senha-list {
    width: 100%;
}

.list-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    padding-bottom: 16px;
    border-bottom: 1px solid #eee;
}

.header-left {
    display: flex;
    align-items: center;
    gap: 12px;
}

.generate-section {
    display: flex;
    align-items: center;
    gap: 12px;
}

.quantity-input {
    display: flex;
    align-items: center;
    gap: 8px;
}

.quantity-input label {
    font-size: 13px;
    color: #555;
    font-weight: 500;
}

.quantity-input input {
    width: 70px;
    padding: 8px 10px;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 14px;
    font-family: inherit;
}

.quantity-input input:focus {
    outline: none;
    border-color: #2c5282;
}

.back-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 12px;
    background: #ffffff;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 12px;
    color: #555;
    cursor: pointer;
    font-family: inherit;
}

.back-btn:hover {
    background: #f5f5f5;
}

.list-title {
    font-family: 'Georgia', 'Times New Roman', serif;
    font-size: 18px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0;
}

.setor-name {
    color: #2c5282;
}

.add-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    background: #2c5282;
    color: #ffffff;
    border: none;
    border-radius: 3px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    font-family: inherit;
}

.add-btn:hover:not(:disabled) {
    background: #1a365d;
}

.add-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.info-text {
    font-size: 13px;
    color: #666;
    margin: 0 0 20px 0;
    font-style: italic;
}

.loading {
    text-align: center;
    padding: 40px;
    color: #666;
    font-size: 14px;
}

.senha-table {
    width: 100%;
    border-collapse: collapse;
}

.senha-table th,
.senha-table td {
    padding: 12px 16px;
    text-align: left;
    border-bottom: 1px solid #eee;
}

.senha-table th {
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    color: #666;
    background: #fafafa;
}

.senha-table td {
    font-size: 14px;
    color: #333;
}

.senha-cell {
    font-family: 'Courier New', monospace;
    font-size: 15px;
    font-weight: 600;
    color: #2c5282;
    letter-spacing: 3px;
}

.actions {
    display: flex;
    gap: 8px;
}

.action-btn {
    padding: 6px 12px;
    border: 1px solid;
    border-radius: 3px;
    font-size: 12px;
    cursor: pointer;
    transition: all 0.2s;
    font-family: inherit;
}

.action-btn.delete {
    background: #ffffff;
    border-color: #b00020;
    color: #b00020;
}

.action-btn.delete:hover {
    background: #fef2f2;
}

.empty {
    text-align: center;
    color: #888;
    font-style: italic;
    padding: 40px !important;
}

@media (max-width: 768px) {
    .list-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
    }

    .header-left {
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
    }

    .back-btn {
        width: 100%;
        justify-content: center;
    }

    .generate-section {
        width: 100%;
        flex-direction: column;
    }

    .quantity-input {
        width: 100%;
    }

    .quantity-input input {
        width: 100%;
    }

    .add-btn {
        width: 100%;
        justify-content: center;
    }

    .senha-table {
        display: block;
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
    }

    .senha-table th,
    .senha-table td {
        padding: 10px 12px;
    }

    .senha-cell {
        letter-spacing: 1px;
    }
}
</style>