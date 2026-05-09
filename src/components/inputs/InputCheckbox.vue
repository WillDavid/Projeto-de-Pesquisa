<template>
    <div class="input-checkbox">
        <label class="input-label">
            {{ field.label }}
            <span v-if="field.required" class="required-mark">*</span>
        </label>
        <div class="checkbox-options">
            <div
                v-for="option in field.options"
                :key="option.value"
                class="checkbox-option"
            >
                <input
                    :id="`${field.id}-${option.value}`"
                    type="checkbox"
                    :value="option.value"
                    :checked="isChecked(option.value)"
                    @change="toggleOption(option.value)"
                    class="checkbox-input"
                />
                <label :for="`${field.id}-${option.value}`" class="checkbox-label">
                    {{ option.label }}
                </label>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'InputCheckbox',
    props: {
        field: {
            type: Object,
            required: true
        },
        modelValue: {
            type: Array,
            default: () => []
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
    },
    methods: {
        toggleOption(optionValue) {
            const newValue = [...this.value];
            const index = newValue.indexOf(optionValue);
            if (index === -1) {
                newValue.push(optionValue);
            } else {
                newValue.splice(index, 1);
            }
            this.$emit('update:modelValue', newValue);
        },
        isChecked(optionValue) {
            return this.value.includes(optionValue);
        }
    }
};
</script>

<style scoped>
.input-checkbox {
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

.checkbox-options {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.checkbox-option {
    display: flex;
    align-items: center;
    gap: 8px;
}

.checkbox-input {
    width: 18px;
    height: 18px;
    cursor: pointer;
    accent-color: #1a73e8;
}

.checkbox-label {
    font-size: 14px;
    color: #333;
    cursor: pointer;
}
</style>