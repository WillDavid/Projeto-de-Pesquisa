<script>
import { supabase } from '../supabase';
import { useAuthStore } from '../stores/auth';
import { useQuestionnaireStore } from '../stores/questionnaire';

export default {
    name: 'DebugView',
    setup() {
        return {
            authStore: useAuthStore(),
            questionnaireStore: useQuestionnaireStore()
        };
    },
    data() {
        return {
            debugInfo: [],
            testResult: null
        };
    },
    async mounted() {
        this.log('=== DEBUG SUPABASE ===');

        this.log('1. Testando tabelas...');

        await this.testTable('setores');
        await this.testTable('senhas');
        await this.testTable('perguntas_opcoes');
        await this.testTable('respostas_opcoes');

        this.log('');
        this.log('2. Estado atual:');
        this.log('Senha ID: ' + this.authStore.senhaId);
        this.log('Setor ID: ' + this.authStore.setorId);
        this.log('Respostas: ' + JSON.stringify(this.questionnaireStore.respostas));
    },
    methods: {
        log(msg) {
            this.debugInfo.push(msg);
        },
        async testTable(tableName) {
            try {
                const { data, error } = await supabase
                    .from(tableName)
                    .select('*')
                    .limit(1);

                if (error) {
                    this.log(`❌ ${tableName}: ${error.message}`);
                } else {
                    this.log(`✅ ${tableName}: OK (${data ? data.length : 0} registros)`);
                }
            } catch (e) {
                this.log(`❌ ${tableName}: ${e.message}`);
            }
        },
        async testInsert() {
            if (!this.authStore.senhaId) {
                alert('Faça login primeiro');
                return;
            }

            this.log('');
            this.log('3. Testando inserção...');

            const testData = {
                senha_id: this.authStore.senhaId,
                setor_id: this.authStore.setorId,
                pergunta_id: 'TESTE1',
                resposta: 1,
                data_resposta: new Date().toISOString()
            };

            this.log('Dados: ' + JSON.stringify(testData));

            const { data, error } = await supabase
                .from('respostas_opcoes')
                .insert([testData])
                .select();

            if (error) {
                this.log('❌ ERRO: ' + error.message);
                this.log('Código: ' + error.code);
            } else {
                this.log('✅ SUCESSO! Dados inseridos: ' + JSON.stringify(data));
            }
        }
    }
};
</script>

<template>
    <div style="background: #1a1a1a; color: #0f0; padding: 20px; font-family: monospace; font-size: 12px; min-height: 100vh;">
        <h2 style="color: #fff;">Debug - Teste de Banco</h2>

        <button
            @click="testInsert"
            style="padding: 12px 24px; background: #2c5282; color: #fff; border: none; cursor: pointer; font-size: 14px;"
        >
            Testar Inserção
        </button>

        <pre style="background: #000; padding: 16px; border-radius: 4px; overflow-x: auto;">
{{ debugInfo.join('\n') }}
        </pre>

        <p style="color: #666;">
            Abra o console do navegador (F12) para ver mais logs
        </p>
    </div>
</template>