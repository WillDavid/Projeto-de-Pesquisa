import { defineStore } from 'pinia';
import { supabase } from '../supabase';

export const useAuthStore = defineStore('auth', {
    state: () => ({
        isLoggedIn: false,
        senhaId: null,
        senhaCodigo: '',
        setorId: null,
        setorNome: '',
        formularioOpcoesConcluido: false,
        formularioPreferenciasConcluido: false
    }),

    actions: {
        async login(senha) {
            const { data, error } = await supabase
                .from('senhas')
                .select('*, setores(nome)')
                .eq('senha', senha.toUpperCase())
                .single();

            if (error || !data) {
                throw new Error('Senha inválida');
            }

            this.isLoggedIn = true;
            this.senhaId = data.id;
            this.senhaCodigo = data.senha;
            this.setorId = data.setor_id;
            this.setorNome = data.setores?.nome || '';
            this.formularioOpcoesConcluido = Boolean(data.formulario_opcoes_concluido);
            this.formularioPreferenciasConcluido = Boolean(data.formulario_preferencias_concluido);

            localStorage.setItem('respondenteLogado', 'true');
            localStorage.setItem('senhaId', data.id);
            localStorage.setItem('senhaCodigo', data.senha);
            localStorage.setItem('setorId', data.setor_id);
            localStorage.setItem('setorNome', this.setorNome);
            localStorage.setItem('formularioOpcoesConcluido', String(this.formularioOpcoesConcluido));
            localStorage.setItem('formularioPreferenciasConcluido', String(this.formularioPreferenciasConcluido));

            return data;
        },

        checkSession() {
            const loggedIn = localStorage.getItem('respondenteLogado');
            if (loggedIn) {
                this.isLoggedIn = true;
                this.senhaId = localStorage.getItem('senhaId');
                this.senhaCodigo = localStorage.getItem('senhaCodigo') || '';
                this.setorId = localStorage.getItem('setorId');
                this.setorNome = localStorage.getItem('setorNome') || '';
                this.formularioOpcoesConcluido = localStorage.getItem('formularioOpcoesConcluido') === 'true';
                this.formularioPreferenciasConcluido = localStorage.getItem('formularioPreferenciasConcluido') === 'true';
            }
        },

        async refreshStatus() {
            if (!this.senhaId) {
                return;
            }

            const { data, error } = await supabase
                .from('senhas')
                .select('senha, formulario_opcoes_concluido, formulario_preferencias_concluido, setores(nome)')
                .eq('id', this.senhaId)
                .single();

            if (error || !data) {
                return;
            }

            this.senhaCodigo = data.senha || this.senhaCodigo;
            this.setorNome = data.setores?.nome || this.setorNome;
            this.formularioOpcoesConcluido = Boolean(data.formulario_opcoes_concluido);
            this.formularioPreferenciasConcluido = Boolean(data.formulario_preferencias_concluido);

            localStorage.setItem('senhaCodigo', this.senhaCodigo);
            localStorage.setItem('setorNome', this.setorNome);
            localStorage.setItem('formularioOpcoesConcluido', String(this.formularioOpcoesConcluido));
            localStorage.setItem('formularioPreferenciasConcluido', String(this.formularioPreferenciasConcluido));
        },

        setFormularioStatus(formulario, concluido) {
            if (formulario === 'opcoes') {
                this.formularioOpcoesConcluido = concluido;
                localStorage.setItem('formularioOpcoesConcluido', String(concluido));
            }

            if (formulario === 'preferencias') {
                this.formularioPreferenciasConcluido = concluido;
                localStorage.setItem('formularioPreferenciasConcluido', String(concluido));
            }
        },

        logout() {
            this.isLoggedIn = false;
            this.senhaId = null;
            this.senhaCodigo = '';
            this.setorId = null;
            this.setorNome = '';
            this.formularioOpcoesConcluido = false;
            this.formularioPreferenciasConcluido = false;

            localStorage.removeItem('respondenteLogado');
            localStorage.removeItem('senhaId');
            localStorage.removeItem('senhaCodigo');
            localStorage.removeItem('setorId');
            localStorage.removeItem('setorNome');
            localStorage.removeItem('formularioOpcoesConcluido');
            localStorage.removeItem('formularioPreferenciasConcluido');
            localStorage.removeItem('progressoFormulario');
        }
    }
});
