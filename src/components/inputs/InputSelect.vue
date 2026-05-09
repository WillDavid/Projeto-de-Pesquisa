<template>
    <div class="input-select">
        <label :for="field.id" class="input-label">
            {{ field.label }}
            <span v-if="field.required" class="required-mark">*</span>
        </label>
        <select
            :id="field.id"
            v-model="value"
            :required="field.required"
            class="input-field"
        >
            <option value="" disabled>Selecione uma opção</option>
            <option
                v-for="option in field.options"
                :key="option.value"
                :value="option.value"
            >
                {{ option.label }}
            </option>
        </select>
    </div>
</template>

<script>
export default {
    name: 'InputSelect',
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
.input-select {
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

.input-field {
    padding: 10px 12px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 14px;
    background-color: #fff;
    cursor: pointer;
    transition: border-color 0.2s ease;
}

.input-field:focus {
    outline: none;
    border-color: #1a73e8;
    box-shadow: 0 0 0 2px rgba(26, 115, 232, 0.2);
}
</style>