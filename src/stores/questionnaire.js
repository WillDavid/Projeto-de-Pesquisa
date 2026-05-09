import { defineStore } from 'pinia';
import { supabase } from '../supabase';
import { formularios, perguntasOpcoes } from '../data/perguntasOpcoes';

export const useQuestionnaireStore = defineStore('questionnaire', {
    state: () => ({
        formularios: JSON.parse(JSON.stringify(formularios)),
        formularioAtual: null,
        respostas: {},
        perguntaAtualIndex: 0,
        loading: false,
        progresso: 0
    }),

    getters: {
        getFormularios: (state) => state.formularios,

        getFormularioAtual: (state) => {
            if (!state.formularioAtual) return null;
            const form = state.formularios.find(f => f.id === state.formularioAtual);
            return form;
        },

        getPerguntaAtual: (state) => {
            const form = state.formularios.find(f => f.id === state.formularioAtual);
            if (!form || !form.perguntas || form.perguntas.length === 0) return null;
            return form.perguntas[state.perguntaAtualIndex];
        },

        getTotalPerguntas: (state) => {
            const form = state.formularios.find(f => f.id === state.formularioAtual);
            return form && form.perguntas ? form.perguntas.length : 0;
        },

        getProgresso: (state) => {
            const form = state.formularios.find(f => f.id === state.formularioAtual);
            if (!form || !form.perguntas || form.perguntas.length === 0) return 0;
            return Math.round(((state.perguntaAtualIndex + 1) / form.perguntas.length) * 100);
        },

        getRespostasCount: (state) => Object.keys(state.respostas).length,

        isFormularioConcluido: (state) => (formId) => {
            const form = state.formularios.find(f => f.id === formId);
            return form ? form.concluido : false;
        }
    },

    actions: {
        resetFormulariosStatus() {
            this.formularios = JSON.parse(JSON.stringify(formularios));
        },

        async carregarStatusFormularios(senhaId) {
            this.resetFormulariosStatus();

            if (!senhaId) {
                return;
            }

            const { data, error } = await supabase
                .from('senhas')
                .select('formulario_opcoes_concluido, formulario_preferencias_concluido')
                .eq('id', senhaId)
                .single();

            if (error) {
                console.error('Erro ao carregar status dos formularios:', error);
                return;
            }

            const formularioOpcoes = this.formularios.find((form) => form.id === 'opcoes');
            const formularioPreferencias = this.formularios.find((form) => form.id === 'preferencias');

            if (formularioOpcoes) {
                formularioOpcoes.concluido = Boolean(data?.formulario_opcoes_concluido);
                formularioOpcoes.progressoRespondente = formularioOpcoes.concluido ? 100 : 0;
            }

            if (formularioPreferencias) {
                formularioPreferencias.concluido = Boolean(data?.formulario_preferencias_concluido);
                formularioPreferencias.progressoRespondente = formularioPreferencias.concluido ? 100 : 0;
            }
        },

        async carregarPerguntasDoBanco() {
            try {
                const { data, error } = await supabase
                    .from('perguntas_opcoes')
                    .select('*')
                    .order('ordem');

                if (error) {
                    console.error('Erro ao carregar perguntas:', error);
                    this.aplicarPerguntasLocais();
                    return false;
                }

                if (data && data.length > 0) {
                    const form = this.formularios.find(f => f.id === 'opcoes');
                    if (form) {
                        form.perguntas = data.map(p => ({
                            id: p.id,
                            categoria: p.categoria,
                            pergunta: p.pergunta,
                            tipo: p.tipo,
                            opcoes: p.opcoes
                        }));
                        return true;
                    }
                }

                console.warn('Tabela perguntas_opcoes vazia. Usando fallback local.');
                this.aplicarPerguntasLocais();
                return false;
            } catch (e) {
                console.error('Erro:', e);
                this.aplicarPerguntasLocais();
                return false;
            }
        },

        aplicarPerguntasLocais() {
            const form = this.formularios.find(f => f.id === 'opcoes');
            if (form) {
                form.perguntas = JSON.parse(JSON.stringify(perguntasOpcoes));
            }
        },

        async iniciarFormulario(formId) {
            this.formularioAtual = formId;
            this.perguntaAtualIndex = 0;
            this.respostas = {};

            await this.carregarPerguntasDoBanco();
            this.carregarProgresso();
        },

        carregarProgresso() {
            const progressoSalvo = localStorage.getItem(`progresso_${this.formularioAtual}`);
            if (progressoSalvo) {
                try {
                    const data = JSON.parse(progressoSalvo);
                    this.respostas = data.respostas || {};
                    this.perguntaAtualIndex = data.perguntaIndex || 0;
                } catch (e) {
                    console.error('Erro ao carregar progresso:', e);
                }
            }
        },

        salvarProgresso() {
            const data = {
                respostas: this.respostas,
                perguntaIndex: this.perguntaAtualIndex,
                formularioAtual: this.formularioAtual
            };
            localStorage.setItem(`progresso_${this.formularioAtual}`, JSON.stringify(data));
        },

        salvarResposta(perguntaId, valor) {
            this.respostas[perguntaId] = {
                valor: valor,
                dataResposta: new Date().toISOString()
            };
            this.salvarProgresso();
        },

        proximaPergunta() {
            const form = this.formularios.find(f => f.id === this.formularioAtual);
            if (form && form.perguntas && this.perguntaAtualIndex < form.perguntas.length - 1) {
                this.perguntaAtualIndex++;
                this.salvarProgresso();
                return true;
            }
            return false;
        },

        perguntaAnterior() {
            if (this.perguntaAtualIndex > 0) {
                this.perguntaAtualIndex--;
                this.salvarProgresso();
                return true;
            }
            return false;
        },

        async verificarRespostasSalvas(senhaId, setorId, perguntaIds) {
            try {
                const { data, error } = await supabase
                    .from('respostas_opcoes')
                    .select('id, pergunta_id')
                    .eq('senha_id', senhaId)
                    .eq('setor_id', setorId)
                    .in('pergunta_id', perguntaIds);

                if (error) throw error;

                const savedIds = new Set((data || []).map((item) => item.pergunta_id));
                const saved = savedIds.size;
                console.log(`Respostas no banco: ${saved}/${perguntaIds.length}`);

                return saved === perguntaIds.length;
            } catch (e) {
                console.error('Erro na verificação:', e);
                return false;
            }
        },

        async enviarFormulario(senhaId, setorId) {
            this.loading = true;

            try {
                const form = this.formularios.find((item) => item.id === this.formularioAtual);
                const respostasArray = [];
                const perguntaIds = form?.perguntas?.map((item) => item.id) || Object.keys(this.respostas);

                for (const [perguntaId, resposta] of Object.entries(this.respostas)) {
                    respostasArray.push({
                        senha_id: senhaId,
                        setor_id: setorId,
                        pergunta_id: perguntaId,
                        resposta: resposta.valor,
                        data_resposta: resposta.dataResposta
                    });
                }

                if (respostasArray.length === 0) {
                    throw new Error('Nenhuma resposta para salvar');
                }

                console.log('Salvando respostas:', respostasArray.length);

                const { data, error } = await supabase
                    .from('respostas_opcoes')
                    .upsert(respostasArray, { onConflict: 'senha_id,pergunta_id' })
                    .select('id, pergunta_id');

                if (error) {
                    console.error('Erro Supabase:', error);
                    if (error.code === '42501') {
                        throw new Error('O Supabase bloqueou a insercao em respostas_opcoes. Configure uma policy de INSERT ou desative o RLS dessa tabela.');
                    }
                    throw error;
                }

                console.log('Respostas salvas, verificando...');

                const verified = await this.verificarRespostasSalvas(senhaId, setorId, perguntaIds);

                if (!verified) {
                    console.warn('Verificação falhou, tentando novamente...');
                    await new Promise(r => setTimeout(r, 1000));
                    const retryVerified = await this.verificarRespostasSalvas(senhaId, setorId, perguntaIds);
                    if (!retryVerified) {
                        throw new Error('Falha na verificação das respostas');
                    }
                }

                console.log('Todas as respostas confirmadas no banco!');

                const { error: statusError } = await supabase
                    .from('senhas')
                    .update({
                        formulario_opcoes_concluido: true,
                        formulario_opcoes_concluido_em: new Date().toISOString()
                    })
                    .eq('id', senhaId);

                if (statusError) {
                    console.error('Erro ao atualizar status da senha:', statusError);
                    throw new Error('As respostas foram gravadas, mas falhou ao atualizar o status da senha.');
                }

                if (form) {
                    form.concluido = true;
                    form.progressoRespondente = 100;
                }

                return true;
            } catch (error) {
                console.error('Erro ao enviar respostas:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        resetFormulario() {
            if (this.formularioAtual) {
                localStorage.removeItem(`progresso_${this.formularioAtual}`);
            }
            this.formularioAtual = null;
            this.respostas = {};
            this.perguntaAtualIndex = 0;
        }
    }
});
