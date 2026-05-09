<script>
export default {
    name: 'FormCard',
    props: {
        titulo: {
            type: String,
            required: true
        },
        descricao: {
            type: String,
            default: ''
        },
        status: {
            type: String,
            default: 'disponivel'
        },
        concluido: {
            type: Boolean,
            default: false
        },
        emBreve: {
            type: Boolean,
            default: false
        },
        bloqueado: {
            type: Boolean,
            default: false
        },
        progresso: {
            type: Number,
            default: 0
        }
    },
    emits: ['click']
};
</script>

<template>
        <div
        :class="['form-card', status, { concluido, emBreve, bloqueado }]"
        @click="status !== 'bloqueado' && !emBreve && !bloqueado && $emit('click')"
    >
        <div class="card-header">
            <div class="card-status">
                <span v-if="concluido" class="status-icon done">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                        <polyline points="22 4 12 14.01 9 11.01"></polyline>
                    </svg>
                </span>
                <span v-else-if="emBreve" class="status-icon soon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                    </svg>
                </span>
                <span v-else-if="bloqueado || status === 'bloqueado'" class="status-icon blocked">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                </span>
                <span v-else class="status-icon available">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 11l3 3L22 4"></path>
                        <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path>
                    </svg>
                </span>
            </div>
            <div v-if="!emBreve && !concluido && !bloqueado && status !== 'bloqueado'" class="card-progress">
                <div class="mini-progress">
                    <div class="mini-fill" :style="{ width: `${progresso}%` }"></div>
                </div>
            </div>
        </div>

        <div class="card-content">
            <h3 class="card-title">{{ titulo }}</h3>
            <p v-if="descricao" class="card-description">{{ descricao }}</p>
        </div>

        <div class="card-footer">
            <span v-if="concluido" class="card-badge success">Concluído</span>
            <span v-else-if="emBreve" class="card-badge soon">Em breve</span>
            <span v-else-if="bloqueado || status === 'bloqueado'" class="card-badge blocked">Bloqueado</span>
            <span v-else-if="progresso > 0" class="card-badge progress">{{ progresso }}%</span>
            <span v-else class="card-badge available">Iniciar</span>
        </div>
    </div>
</template>

<style scoped>
.form-card {
    background: #ffffff;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    padding: 24px;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.form-card:hover:not(.emBreve):not(.concluido) {
    border-color: #2c5282;
    box-shadow: 0 2px 8px rgba(44, 82, 130, 0.15);
}

.form-card.concluido {
    border-color: #34a853;
    background: #f8fdf8;
}

.form-card.emBreve {
    cursor: default;
    opacity: 0.7;
    background: #fafafa;
}

.form-card.bloqueado {
    cursor: not-allowed;
    opacity: 0.8;
    background: #fafafa;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.status-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border-radius: 50%;
}

.status-icon.done {
    background: #e6f4ea;
    color: #34a853;
}

.status-icon.soon {
    background: #fce8e6;
    color: #f57c00;
}

.status-icon.available {
    background: #e8f0fe;
    color: #2c5282;
}

.status-icon.blocked {
    background: #f1f3f4;
    color: #6b7280;
}

.card-progress {
    flex: 1;
    display: flex;
    justify-content: flex-end;
}

.mini-progress {
    width: 80px;
    height: 4px;
    background: #e0e0e0;
    border-radius: 2px;
    overflow: hidden;
}

.mini-fill {
    height: 100%;
    background: #2c5282;
    border-radius: 2px;
    transition: width 0.3s ease;
}

.card-content {
    flex: 1;
}

.card-title {
    font-family: 'Georgia', serif;
    font-size: 18px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 8px 0;
}

.card-description {
    font-size: 14px;
    color: #666;
    margin: 0;
    line-height: 1.4;
}

.card-footer {
    padding-top: 16px;
    border-top: 1px solid #eee;
}

.card-badge {
    display: inline-block;
    font-size: 12px;
    font-weight: 500;
    padding: 4px 12px;
    border-radius: 3px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.card-badge.success {
    background: #e6f4ea;
    color: #34a853;
}

.card-badge.soon {
    background: #fce8e6;
    color: #f57c00;
}

.card-badge.progress {
    background: #e8f0fe;
    color: #2c5282;
}

.card-badge.available {
    background: #2c5282;
    color: #ffffff;
}

.card-badge.blocked {
    background: #f1f3f4;
    color: #6b7280;
}
</style>
