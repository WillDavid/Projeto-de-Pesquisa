import { perguntasPreferencias } from './perguntasPreferencias';

export const perguntasOpcoes = [
    {
        id: 'I01',
        categoria: 'Disponibilidade',
        pergunta: 'Em relação aos dados necessários para desempenhar minhas atividades, tenho acesso a:',
        tipo: 'radio',
        opcoes: [
            { valor: 0, texto: 'Parte deles' },
            { valor: 1, texto: 'Todos' }
        ]
    },
    {
        id: 'I02',
        categoria: 'Disponibilidade',
        pergunta: 'Os dados que tenho acesso são consistentes, corretos e atendem às expectativas.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Discordo totalmente' },
            { valor: 1, texto: 'Discordo' },
            { valor: 2, texto: 'Concordo' },
            { valor: 3, texto: 'Concordo totalmente' }
        ]
    },
    {
        id: 'I03',
        categoria: 'Disponibilidade',
        pergunta: 'Os dados são atualizados e disponibilizados em tempo adequado para realizar o meu trabalho.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Discordo totalmente' },
            { valor: 1, texto: 'Discordo' },
            { valor: 2, texto: 'Concordo' },
            { valor: 3, texto: 'Concordo totalmente' }
        ]
    },
    {
        id: 'I04',
        categoria: 'Disponibilidade',
        pergunta: 'As ferramentas de análise de dados fornecidas pela empresa são adequadas para as análises que preciso realizar.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Discordo totalmente' },
            { valor: 1, texto: 'Discordo' },
            { valor: 2, texto: 'Concordo' },
            { valor: 3, texto: 'Concordo totalmente' }
        ]
    },
    {
        id: 'I05',
        categoria: 'Disponibilidade',
        pergunta: 'As ferramentas de dados disponibilizadas pela empresa são fáceis de serem utilizadas.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Discordo totalmente' },
            { valor: 1, texto: 'Discordo' },
            { valor: 2, texto: 'Concordo' },
            { valor: 3, texto: 'Concordo totalmente' }
        ]
    },
    {
        id: 'I06',
        categoria: 'Disponibilidade',
        pergunta: 'Quando temos problemas técnicos, o suporte técnico de dados e ferramentas é:',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Ineficaz' },
            { valor: 1, texto: 'Pouco eficaz' },
            { valor: 2, texto: 'Eficaz' },
            { valor: 3, texto: 'Muito eficaz' }
        ]
    },
    {
        id: 'I07',
        categoria: 'Disponibilidade',
        pergunta: 'Posso contar com profissionais especializados para auxiliar, estruturar ou gerar os dados e análises necessários para o meu trabalho.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Nunca' },
            { valor: 1, texto: 'Poucas vezes' },
            { valor: 2, texto: 'Na maioria das vezes' },
            { valor: 3, texto: 'Sempre' }
        ]
    },
    {
        id: 'I08',
        categoria: 'Disponibilidade',
        pergunta: 'A documentação de como os dados são definidos, coletados e tratados facilita minha compreensão das métricas da empresa.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Discordo totalmente' },
            { valor: 1, texto: 'Discordo' },
            { valor: 2, texto: 'Concordo' },
            { valor: 3, texto: 'Concordo totalmente' }
        ]
    },
    {
        id: 'I09',
        categoria: 'Incentivo ao desenvolvimento',
        pergunta: 'Os treinamentos oferecidos pela empresa colaboram para que eu use mais os dados no meu dia a dia.',
        tipo: 'simNao',
        opcoes: [
            { valor: 0, texto: 'Não' },
            { valor: 1, texto: 'Sim' }
        ]
    },
    {
        id: 'I10',
        categoria: 'Incentivo ao desenvolvimento',
        pergunta: 'A empresa incentiva o desenvolvimento de competências para gerar informações a partir dos dados.',
        tipo: 'simNao',
        opcoes: [
            { valor: 0, texto: 'Não' },
            { valor: 1, texto: 'Sim' }
        ]
    },
    {
        id: 'I11',
        categoria: 'Incentivo ao desenvolvimento',
        pergunta: 'A empresa incentiva o desenvolvimento de técnicas de comunicação para apresentar análises, insights e informações obtidas pelos dados.',
        tipo: 'simNao',
        opcoes: [
            { valor: 0, texto: 'Não' },
            { valor: 1, texto: 'Sim' }
        ]
    },
    {
        id: 'I12',
        categoria: 'Incentivo ao desenvolvimento',
        pergunta: 'A empresa incentiva a realização de testes para verificar hipóteses de negócios.',
        tipo: 'simNao',
        opcoes: [
            { valor: 0, texto: 'Não' },
            { valor: 1, texto: 'Sim' }
        ]
    },
    {
        id: 'I13',
        categoria: 'Suporte da liderança',
        pergunta: 'Os líderes investem em profissionais qualificados para a realização das análises com base em dados.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Nunca' },
            { valor: 1, texto: 'Nem sempre' },
            { valor: 2, texto: 'Sempre' }
        ]
    },
    {
        id: 'I14',
        categoria: 'Suporte da liderança',
        pergunta: 'Sei quais são os objetivos da empresa para o uso de dados.',
        tipo: 'simNao',
        opcoes: [
            { valor: 0, texto: 'Não' },
            { valor: 1, texto: 'Sim' }
        ]
    },
    {
        id: 'I15',
        categoria: 'Benefícios individuais',
        pergunta: 'Tomo ações melhores e mais rápidas com o uso de dados da empresa.',
        tipo: 'simNao',
        opcoes: [
            { valor: 0, texto: 'Não' },
            { valor: 1, texto: 'Sim' }
        ]
    },
    {
        id: 'I16',
        categoria: 'Benefícios individuais',
        pergunta: 'As informações geradas pelos dados têm resultado aplicável aos processos da empresa.',
        tipo: 'simNao',
        opcoes: [
            { valor: 0, texto: 'Não' },
            { valor: 1, texto: 'Sim' }
        ]
    },
    {
        id: 'I17',
        categoria: 'Resultados para a empresa',
        pergunta: 'Meus líderes utilizam as informações geradas a partir dos dados para tomar decisões.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Nunca' },
            { valor: 1, texto: 'Nem sempre' },
            { valor: 2, texto: 'Sempre' }
        ]
    },
    {
        id: 'I18',
        categoria: 'Resultados para a empresa',
        pergunta: 'Os líderes investem em profissionais qualificados para a realização das análises com base em dados.',
        tipo: 'escala',
        opcoes: [
            { valor: 0, texto: 'Nunca' },
            { valor: 1, texto: 'Nem sempre' },
            { valor: 2, texto: 'Sempre' }
        ]
    }
];

export const formularios = [
    {
        id: 'opcoes',
        titulo: 'Formulário de Opções',
        descricao: 'Questionário sobre uso de dados e ferramentas',
        perguntas: perguntasOpcoes,
        concluido: false
    },
    {
        id: 'preferencias',
        titulo: 'Formulário de Preferências',
        descricao: 'Ranqueamento progressivo de prioridades organizacionais',
        perguntas: perguntasPreferencias,
        concluido: false,
        emBreve: false
    }
];
