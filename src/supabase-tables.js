import { supabase } from './supabase';

export async function setupTables() {
    // Criar tabela setores
    const { error: errorSetores } = await supabase.rpc('exec_sql', {
        sql: `
            CREATE TABLE IF NOT EXISTS setores (
                id SERIAL PRIMARY KEY,
                nome TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
        `
    }).catch(() => null);

    // Criar tabela senhas
    await supabase.rpc('exec_sql', {
        sql: `
            CREATE TABLE IF NOT EXISTS senhas (
                id SERIAL PRIMARY KEY,
                senha TEXT NOT NULL UNIQUE,
                setor_id INTEGER REFERENCES setores(id) ON DELETE CASCADE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
        `
    }).catch(() => null);

    // Criar tabela respostas
    await supabase.rpc('exec_sql', {
        sql: `
            CREATE TABLE IF NOT EXISTS respostas (
                id SERIAL PRIMARY KEY,
                senha_id INTEGER REFERENCES senhas(id) ON DELETE CASCADE,
                setor_id INTEGER REFERENCES setores(id) ON DELETE CASCADE,
                opiniao TEXT,
                recommend TEXT,
                intereses TEXT[],
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
        `
    }).catch(() => null);

    // Inserir setores iniciais
    const { data: existingSetores } = await supabase
        .from('setores')
        .select('id')
        .limit(1);

    if (!existingSetores || existingSetores.length === 0) {
        await supabase.from('setores').insert([
            { nome: 'RH' },
            { nome: 'Financeiro' },
            { nome: 'TI' },
            { nome: 'Atendimento' }
        ]);
    }
}