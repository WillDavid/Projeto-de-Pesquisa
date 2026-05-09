<script>
export default {
    name: 'QuestionRenderer',
    props: {
        pergunta: {
            type: Object,
            required: true
        },
        resposta: {
            type: [Number, String],
            default: null
        }
    },
    emits: ['update'],
    methods: {
        selecionarOpcao(valor) {
            this.$emit('update', valor);
        }
    }
};
</script>

<template>
    <div class="question-renderer">
        <div class="question-header">
            <span class="question-id">{{ pergunta.id }}</span>
            <span class="question-category">{{ pergunta.categoria }}</span>
        </div>

        <h3 class="question-text">{{ pergunta.pergunta }}</h3>

        <div class="question-options">
            <div
                v-for="opcao in pergunta.opcoes"
                :key="opcao.valor"
                :class="['option-item', { selected: resposta === opcao.valor }]"
                @click="selecionarOpcao(opcao.valor)"
            >
                <div class="option-marker">
                    <span v-if="resposta === opcao.valor" class="check-mark">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                            <polyline points="20 6 9 17 4 12"></polyline>
                        </svg>
                    </span>
                </div>
                <span class="option-text">{{ opcao.texto }}</span>
            </div>
        </div>
    </div>
</template>

<style scoped>
.question-renderer {
    width: 100%;
}

.question-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 14px;
    flex-wrap: wrap;
}

.question-id {
    font-family: 'Courier New', monospace;
    font-size: 12px;
    font-weight: 600;
    color: #2c5282;
    padding: 4px 8px;
    background: #e8f0fe;
    border-radius: 3px;
}

.question-category {
    font-size: 11px;
    font-weight: 500;
    color: #666;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.question-text {
    font-family: 'Georgia', serif;
    font-size: 16px;
    font-weight: 500;
    color: #1a1a1a;
    margin: 0 0 20px 0;
    line-height: 1.5;
}

.question-options {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.option-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px 14px;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s ease;
    background: #ffffff;
}

.option-item:hover {
    border-color: #2c5282;
    background: #f8fbff;
}

.option-item.selected {
    border-color: #2c5282;
    background: #e8f0fe;
}

.option-marker {
    width: 18px;
    height: 18px;
    border: 2px solid #ccc;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    margin-top: 1px;
    transition: all 0.2s ease;
}

.option-item.selected .option-marker {
    background: #2c5282;
    border-color: #2c5282;
}

.check-mark {
    color: #ffffff;
    display: flex;
    align-items: center;
    justify-content: center;
}

.option-text {
    font-size: 13px;
    color: #333;
    line-height: 1.4;
    flex: 1;
}

@media (max-width: 480px) {
    .question-header {
        gap: 8px;
    }

    .question-id {
        font-size: 11px;
        padding: 3px 6px;
    }

    .question-category {
        font-size: 10px;
    }

    .question-text {
        font-size: 15px;
    }

    .option-item {
        padding: 10px 12px;
        gap: 10px;
    }

    .option-marker {
        width: 16px;
        height: 16px;
        margin-top: 2px;
    }

    .option-text {
        font-size: 13px;
    }
}
</style>