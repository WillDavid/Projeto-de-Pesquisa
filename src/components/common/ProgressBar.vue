<script>
export default {
    name: 'ProgressBar',
    props: {
        progresso: {
            type: Number,
            default: 0
        },
        label: {
            type: String,
            default: 'Progresso'
        }
    }
};
</script>

<template>
    <div class="progress-container">
        <div class="progress-info">
            <span class="progress-label">{{ label }}</span>
            <span class="progress-value">{{ progresso }}%</span>
        </div>
        <div class="progress-bar">
            <div class="progress-fill" :style="{ width: `${progresso}%` }"></div>
        </div>
    </div>
</template>

<style scoped>
.progress-container {
    width: 100%;
    margin-bottom: 20px;
}

.progress-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
}

.progress-label {
    font-size: 12px;
    color: #666;
}

.progress-value {
    font-size: 12px;
    font-weight: 600;
    color: #2c5282;
}

.progress-bar {
    width: 100%;
    height: 6px;
    background: #e0e0e0;
    border-radius: 3px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    background: #2c5282;
    border-radius: 3px;
    transition: width 0.3s ease;
}

@media (max-width: 480px) {
    .progress-info {
        margin-bottom: 6px;
    }

    .progress-label,
    .progress-value {
        font-size: 11px;
    }

    .progress-bar {
        height: 5px;
    }
}
</style>