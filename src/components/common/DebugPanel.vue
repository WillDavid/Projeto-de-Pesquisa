<script>
import { supabase } from '../../supabase';

export default {
    name: 'DebugPanel',
    data() {
        return {
            debugInfo: [],
            loading: false
        };
    },
    methods: {
        async runTests() {
            this.loading = true;
            this.debugInfo = [];

            this.log('Testando conexão com Supabase...');

            try {
                const { data: perguntas, error: err1 } = await supabase
                    .from('perguntas_opcoes')
                    .select('*')
                    .order('ordem');

                if (err1) {
                    this.log('❌ Erro ao buscar perguntas: ' + err1.message);
                } else {
                    this.log(`✅ Perguntas carregadas: ${perguntas ? perguntas.length : 0}`);
                    if (perguntas && perguntas.length > 0) {
                        this.log('Primeira pergunta: ' + JSON.stringify(perguntas[0]));
                    }
                }
            } catch (e) {
                this.log('❌ Erro: ' + e.message);
            }

            try {
                const { data: setores, error: err2 } = await supabase
                    .from('setores')
                    .select('*');

                if (err2) {
                    this.log('❌ Erro ao buscar setores: ' + err2.message);
                } else {
                    this.log(`✅ Setores encontrados: ${setores ? setores.length : 0}`);
                }
            } catch (e) {
                this.log('❌ Erro: ' + e.message);
            }

            try {
                const { data: senhas, error: err3 } = await supabase
                    .from('senhas')
                    .select('*')
                    .limit(3);

                if (err3) {
                    this.log('❌ Erro ao buscar senhas: ' + err3.message);
                } else {
                    this.log(`✅ Senhas encontradas: ${senhas ? senhas.length : 0}`);
                    if (senhas && senhas.length > 0) {
                        this.log('Primeira senha: ' + JSON.stringify(senhas[0]));
                    }
                }
            } catch (e) {
                this.log('❌ Erro: ' + e.message);
            }

            this.loading = false;
        },
        log(msg) {
            this.debugInfo.push({
                time: new Date().toLocaleTimeString(),
                msg
            });
        }
    },
    mounted() {
        this.runTests();
    }
};
</script>

<template>
    <div class="debug-panel">
        <h3>Debug Supabase</h3>
        <button @click="runTests" :disabled="loading">
            {{ loading ? 'Testando...' : 'Rodar Testes' }}
        </button>
        <div class="debug-logs">
            <div v-for="(log, i) in debugInfo" :key="i" :class="['log-item', log.msg.includes('❌') ? 'error' : 'success']">
                <span class="log-time">{{ log.time }}</span>
                <span class="log-msg">{{ log.msg }}</span>
            </div>
        </div>
    </div>
</template>

<style scoped>
.debug-panel {
    background: #1a1a1a;
    color: #0f0;
    padding: 16px;
    border-radius: 8px;
    margin: 20px;
    font-family: monospace;
    font-size: 12px;
}
.debug-panel h3 {
    color: #fff;
    margin: 0 0 12px 0;
}
.debug-panel button {
    padding: 8px 16px;
    background: #333;
    color: #fff;
    border: 1px solid #555;
    cursor: pointer;
    margin-bottom: 12px;
}
.debug-logs {
    max-height: 300px;
    overflow-y: auto;
}
.log-item {
    padding: 4px 0;
    border-bottom: 1px solid #333;
}
.log-item.error {
    color: #ff6b6b;
}
.log-item.success {
    color: #51cf66;
}
.log-time {
    color: #666;
    margin-right: 8px;
}
</style>