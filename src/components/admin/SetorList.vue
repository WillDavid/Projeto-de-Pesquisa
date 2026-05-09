<script>
import { supabase } from '../../supabase';

export default {
    name: 'SetorList',
    emits: ['select'],
    data() {
        return {
            setores: [],
            loading: false,
            showModal: false,
            editingSetor: null,
            form: {
                nome: ''
            },
            error: ''
        };
    },
    async mounted() {
        await this.loadSetores();
    },
    methods: {
        async loadSetores() {
            this.loading = true;
            const { data, error } = await supabase
                .from('setores')
                .select('*')
                .order('nome');

            const { data: senhasData, error: senhasError } = await supabase
                .from('senhas')
                .select('setor_id');

            if (!error && !senhasError) {
                const counts = (senhasData || []).reduce((acc, item) => {
                    acc[item.setor_id] = (acc[item.setor_id] || 0) + 1;
                    return acc;
                }, {});

                this.setores = (data || []).map((setor) => ({
                    ...setor,
                    quantidade_senhas: counts[setor.id] || 0
                }));
            }
            this.loading = false;
        },
        openModal(setor = null) {
            this.editingSetor = setor;
            this.form.nome = setor ? setor.nome : '';
            this.error = '';
            this.showModal = true;
        },
        closeModal() {
            this.showModal = false;
            this.editingSetor = null;
            this.form.nome = '';
            this.error = '';
        },
        async saveSetor() {
            if (!this.form.nome.trim()) {
                this.error = 'Nome do setor é obrigatório';
                return;
            }

            if (this.editingSetor) {
                await supabase
                    .from('setores')
                    .update({ nome: this.form.nome })
                    .eq('id', this.editingSetor.id);
            } else {
                await supabase
                    .from('setores')
                    .insert([{ nome: this.form.nome }]);
            }

            await this.loadSetores();
            this.closeModal();
        },
        async deleteSetor(setor) {
            if (!confirm(`Excluir o setor "${setor.nome}"?`)) return;

            await supabase
                .from('setores')
                .delete()
                .eq('id', setor.id);

            await this.loadSetores();
        },
        selectSetor(setor) {
            this.$emit('select', setor);
        }
    }
};
</script>

<template>
    <div class="setor-list">
        <div class="list-header">
            <h2 class="list-title">Gerenciamento de Setores</h2>
            <button class="add-btn" @click="openModal()">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                Adicionar Setor
            </button>
        </div>

        <div v-if="loading" class="loading">Carregando dados...</div>

        <table v-else class="setor-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nome do Setor</th>
                    <th>Senhas Criadas</th>
                    <th>Ações</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="setor in setores" :key="setor.id">
                    <td class="id-cell">{{ setor.id }}</td>
                    <td>{{ setor.nome }}</td>
                    <td>{{ setor.quantidade_senhas }}</td>
                    <td class="actions">
                        <button class="action-btn edit" @click="openModal(setor)">
                            Editar
                        </button>
                        <button class="action-btn delete" @click="deleteSetor(setor)">
                            Excluir
                        </button>
                        <button class="action-btn select" @click="selectSetor(setor)">
                            Gerenciar Senhas
                        </button>
                    </td>
                </tr>
                <tr v-if="setores.length === 0">
                    <td colspan="4" class="empty">Nenhum setor cadastrado</td>
                </tr>
            </tbody>
        </table>

        <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
            <div class="modal">
                <h3 class="modal-title">
                    {{ editingSetor ? 'Editar Setor' : 'Novo Setor' }}
                </h3>
                <form @submit.prevent="saveSetor">
                    <div class="form-group">
                        <label>Nome do Setor</label>
                        <input
                            v-model="form.nome"
                            type="text"
                            placeholder="Ex: Recursos Humanos"
                            class="form-input"
                        />
                    </div>
                    <p v-if="error" class="error">{{ error }}</p>
                    <div class="modal-actions">
                        <button type="button" class="btn-cancel" @click="closeModal">
                            Cancelar
                        </button>
                        <button type="submit" class="btn-save">Salvar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>

<style scoped>
.setor-list {
    width: 100%;
}

.list-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    padding-bottom: 16px;
    border-bottom: 1px solid #eee;
}

.list-title {
    font-family: 'Georgia', 'Times New Roman', serif;
    font-size: 18px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0;
}

.add-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    background: #333;
    color: #ffffff;
    border: none;
    border-radius: 3px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    font-family: inherit;
}

.add-btn:hover {
    background: #1a1a1a;
}

.loading {
    text-align: center;
    padding: 40px;
    color: #666;
    font-size: 14px;
}

.setor-table {
    width: 100%;
    border-collapse: collapse;
}

.setor-table th,
.setor-table td {
    padding: 12px 16px;
    text-align: left;
    border-bottom: 1px solid #eee;
}

.setor-table th {
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    color: #666;
    background: #fafafa;
}

.setor-table td {
    font-size: 14px;
    color: #333;
}

.id-cell {
    color: #888;
    font-family: monospace;
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

.action-btn.edit {
    background: #ffffff;
    border-color: #ccc;
    color: #333;
}

.action-btn.edit:hover {
    background: #f5f5f5;
}

.action-btn.delete {
    background: #ffffff;
    border-color: #b00020;
    color: #b00020;
}

.action-btn.delete:hover {
    background: #fef2f2;
}

.action-btn.select {
    background: #fff;
    border-color: #2c5282;
    color: #2c5282;
}

.action-btn.select:hover {
    background: #ebf8ff;
}

.empty {
    text-align: center;
    color: #888;
    font-style: italic;
    padding: 40px !important;
}

.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
}

.modal {
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 24px;
    width: 100%;
    max-width: 400px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.modal-title {
    font-family: 'Georgia', 'Times New Roman', serif;
    font-size: 18px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 20px 0;
}

.form-group {
    margin-bottom: 16px;
}

.form-group label {
    display: block;
    font-size: 13px;
    font-weight: 500;
    color: #333;
    margin-bottom: 6px;
}

.form-input {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 14px;
    font-family: inherit;
}

.form-input:focus {
    outline: none;
    border-color: #333;
}

.error {
    color: #b00020;
    font-size: 13px;
    margin: 0 0 16px 0;
}

.modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
}

.btn-cancel {
    padding: 8px 16px;
    background: #ffffff;
    border: 1px solid #ccc;
    border-radius: 3px;
    font-size: 13px;
    color: #555;
    cursor: pointer;
    font-family: inherit;
}

.btn-save {
    padding: 8px 16px;
    background: #333;
    border: none;
    border-radius: 3px;
    font-size: 13px;
    color: #ffffff;
    cursor: pointer;
    font-family: inherit;
}

@media (max-width: 768px) {
    .list-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
    }

    .add-btn {
        width: 100%;
        justify-content: center;
    }

    .setor-table {
        display: block;
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
    }

    .setor-table th,
    .setor-table td {
        white-space: nowrap;
        padding: 10px 12px;
    }

    .actions {
        flex-direction: column;
    }

    .action-btn {
        width: 100%;
        text-align: center;
    }
}
</style>
