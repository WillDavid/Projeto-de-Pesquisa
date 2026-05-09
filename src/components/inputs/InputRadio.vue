<template>
    <div class="input-radio">
        <label class="input-label">
            {{ field.label }}
            <span v-if="field.required" class="required-mark">*</span>
        </label>
        <div class="radio-options">
            <div
                v-for="option in field.options"
                :key="option.value"
                class="radio-option"
            >
                <input
                    :id="`${field.id}-${option.value}`"
                    v-model="value"
                    type="radio"
                    :name="field.id"
                    :value="option.value"
                    class="radio-input"
                />
                <label :for="`${field.id}-${option.value}`" class="radio-label">
                    {{ option.label }}
                </label>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'InputRadio',
    props: {
        field: {
            type: Object,
            required: true
        },
        modelValue: {
            type: String,
            default: ''
        }
    },
    computed: {
        value: {
            get() {
                return this.modelValue;
            },
            set(value) {
                this.$emit('update:modelValue', value);
            }
        }
    }
};
</script>

<style scoped>
.input-radio {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 20px;
}

.input-label {
    font-size: 14px;
    font-weight: 500;
    color: #333;
}

.required-mark {
    color: #d93025;
    margin-left: 2px;
}

.radio-options {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.radio-option {
    display: flex;
    align-items: center;
    gap: 8px;
}

.radio-input {
    width: 18px;
    height: 18px;
    cursor: pointer;
    accent-color: #1a73e8;
}

.radio-label {
    font-size: 14px;
    color: #333;
    cursor: pointer;
}
</style>