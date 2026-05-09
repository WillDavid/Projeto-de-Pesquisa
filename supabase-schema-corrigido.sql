-- =====================================================
-- SISTEMA DE PESQUISA CORPORATIVA
-- Schema corrigido e idempotente
-- =====================================================

-- =====================================================
-- 1. TABELAS BASE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.setores (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.senhas (
    id SERIAL PRIMARY KEY,
    senha TEXT NOT NULL UNIQUE,
    setor_id INTEGER REFERENCES public.setores(id) ON DELETE CASCADE,
    formulario_opcoes_concluido BOOLEAN NOT NULL DEFAULT FALSE,
    formulario_preferencias_concluido BOOLEAN NOT NULL DEFAULT FALSE,
    formulario_opcoes_concluido_em TIMESTAMP WITH TIME ZONE,
    formulario_preferencias_concluido_em TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.senhas
    ADD COLUMN IF NOT EXISTS formulario_opcoes_concluido BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.senhas
    ADD COLUMN IF NOT EXISTS formulario_preferencias_concluido BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.senhas
    ADD COLUMN IF NOT EXISTS formulario_opcoes_concluido_em TIMESTAMP WITH TIME ZONE;

ALTER TABLE public.senhas
    ADD COLUMN IF NOT EXISTS formulario_preferencias_concluido_em TIMESTAMP WITH TIME ZONE;

-- =====================================================
-- 2. FORMULARIO DE OPCOES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.perguntas_opcoes (
    id TEXT PRIMARY KEY,
    categoria TEXT NOT NULL,
    pergunta TEXT NOT NULL,
    tipo TEXT NOT NULL,
    opcoes JSONB NOT NULL,
    ordem INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS public.respostas_opcoes (
    id BIGSERIAL PRIMARY KEY,
    senha_id INTEGER NOT NULL REFERENCES public.senhas(id) ON DELETE CASCADE,
    setor_id INTEGER NOT NULL REFERENCES public.setores(id) ON DELETE CASCADE,
    pergunta_id TEXT NOT NULL REFERENCES public.perguntas_opcoes(id) ON DELETE RESTRICT,
    resposta INTEGER NOT NULL,
    data_resposta TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Evita duplicidade da mesma pergunta respondida pela mesma senha
CREATE UNIQUE INDEX IF NOT EXISTS respostas_opcoes_unique_resposta
ON public.respostas_opcoes (senha_id, pergunta_id);

CREATE INDEX IF NOT EXISTS idx_respostas_opcoes_senha_id
ON public.respostas_opcoes (senha_id);

CREATE INDEX IF NOT EXISTS idx_respostas_opcoes_setor_id
ON public.respostas_opcoes (setor_id);

CREATE INDEX IF NOT EXISTS idx_respostas_opcoes_pergunta_id
ON public.respostas_opcoes (pergunta_id);

-- =====================================================
-- 3. FORMULARIO DE PREFERENCIAS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.perguntas_preferencias (
    id TEXT PRIMARY KEY,
    categoria TEXT NOT NULL,
    pergunta TEXT NOT NULL,
    tipo TEXT NOT NULL,
    opcoes JSONB NOT NULL,
    peso INTEGER NOT NULL DEFAULT 3,
    ordem INTEGER NOT NULL
);

ALTER TABLE public.perguntas_preferencias
    ADD COLUMN IF NOT EXISTS peso INTEGER NOT NULL DEFAULT 3;

CREATE TABLE IF NOT EXISTS public.respostas_preferencias (
    id BIGSERIAL PRIMARY KEY,
    senha_id INTEGER NOT NULL REFERENCES public.senhas(id) ON DELETE CASCADE,
    setor_id INTEGER NOT NULL REFERENCES public.setores(id) ON DELETE CASCADE,
    pergunta_id TEXT NOT NULL REFERENCES public.perguntas_preferencias(id) ON DELETE RESTRICT,
    resposta TEXT NOT NULL,
    data_resposta TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS respostas_preferencias_unique_resposta
ON public.respostas_preferencias (senha_id, pergunta_id);

CREATE INDEX IF NOT EXISTS idx_respostas_preferencias_senha_id
ON public.respostas_preferencias (senha_id);

CREATE INDEX IF NOT EXISTS idx_respostas_preferencias_setor_id
ON public.respostas_preferencias (setor_id);

CREATE INDEX IF NOT EXISTS idx_respostas_preferencias_pergunta_id
ON public.respostas_preferencias (pergunta_id);

-- =====================================================
-- 4. PROGRESSO
-- =====================================================
CREATE TABLE IF NOT EXISTS public.progresso_respondente (
    id BIGSERIAL PRIMARY KEY,
    senha_id INTEGER NOT NULL REFERENCES public.senhas(id) ON DELETE CASCADE,
    formulario TEXT NOT NULL,
    respostas JSONB DEFAULT '{}'::jsonb,
    pergunta_atual INTEGER DEFAULT 0,
    concluido BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (senha_id, formulario)
);

CREATE INDEX IF NOT EXISTS idx_progresso_respondente_senha_id
ON public.progresso_respondente (senha_id);

-- =====================================================
-- 5. RLS E POLICIES
-- Motivo: o frontend usa anon key, entao precisa policy explicita.
-- =====================================================
ALTER TABLE public.setores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.senhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perguntas_opcoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.respostas_opcoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perguntas_preferencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.respostas_preferencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progresso_respondente ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS setores_select_anon ON public.setores;
DROP POLICY IF EXISTS senhas_select_anon ON public.senhas;
DROP POLICY IF EXISTS senhas_update_anon ON public.senhas;
DROP POLICY IF EXISTS perguntas_opcoes_select_anon ON public.perguntas_opcoes;
DROP POLICY IF EXISTS respostas_opcoes_select_anon ON public.respostas_opcoes;
DROP POLICY IF EXISTS respostas_opcoes_insert_anon ON public.respostas_opcoes;
DROP POLICY IF EXISTS respostas_opcoes_update_anon ON public.respostas_opcoes;
DROP POLICY IF EXISTS perguntas_preferencias_select_anon ON public.perguntas_preferencias;
DROP POLICY IF EXISTS respostas_preferencias_select_anon ON public.respostas_preferencias;
DROP POLICY IF EXISTS respostas_preferencias_insert_anon ON public.respostas_preferencias;
DROP POLICY IF EXISTS respostas_preferencias_update_anon ON public.respostas_preferencias;
DROP POLICY IF EXISTS progresso_respondente_select_anon ON public.progresso_respondente;
DROP POLICY IF EXISTS progresso_respondente_insert_anon ON public.progresso_respondente;
DROP POLICY IF EXISTS progresso_respondente_update_anon ON public.progresso_respondente;

CREATE POLICY setores_select_anon
ON public.setores
FOR SELECT
TO anon
USING (true);

CREATE POLICY senhas_select_anon
ON public.senhas
FOR SELECT
TO anon
USING (true);

CREATE POLICY senhas_update_anon
ON public.senhas
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

-- =====================================================
-- 5.1 BACKFILL DOS STATUS NAS SENHAS
-- =====================================================
UPDATE public.senhas AS s
SET
    formulario_opcoes_concluido = (
        SELECT COUNT(DISTINCT ro.pergunta_id)
        FROM public.respostas_opcoes ro
        WHERE ro.senha_id = s.id
    ) >= (
        SELECT COUNT(*)
        FROM public.perguntas_opcoes po
    ),
    formulario_opcoes_concluido_em = CASE
        WHEN (
            SELECT COUNT(DISTINCT ro.pergunta_id)
            FROM public.respostas_opcoes ro
            WHERE ro.senha_id = s.id
        ) >= (
            SELECT COUNT(*)
            FROM public.perguntas_opcoes po
        ) THEN COALESCE(
            (
                SELECT MAX(ro.data_resposta)
                FROM public.respostas_opcoes ro
                WHERE ro.senha_id = s.id
            ),
            NOW()
        )
        ELSE NULL
    END;

UPDATE public.senhas AS s
SET
    formulario_preferencias_concluido = (
        SELECT COUNT(DISTINCT rp.pergunta_id)
        FROM public.respostas_preferencias rp
        WHERE rp.senha_id = s.id
    ) >= (
        SELECT COUNT(*)
        FROM public.perguntas_preferencias pp
    )
    AND (
        SELECT COUNT(*)
        FROM public.perguntas_preferencias pp
    ) > 0,
    formulario_preferencias_concluido_em = CASE
        WHEN (
            SELECT COUNT(DISTINCT rp.pergunta_id)
            FROM public.respostas_preferencias rp
            WHERE rp.senha_id = s.id
        ) >= (
            SELECT COUNT(*)
            FROM public.perguntas_preferencias pp
        )
        AND (
            SELECT COUNT(*)
            FROM public.perguntas_preferencias pp
        ) > 0 THEN COALESCE(
            (
                SELECT MAX(rp.data_resposta)
                FROM public.respostas_preferencias rp
                WHERE rp.senha_id = s.id
            ),
            NOW()
        )
        ELSE NULL
    END;

CREATE POLICY perguntas_opcoes_select_anon
ON public.perguntas_opcoes
FOR SELECT
TO anon
USING (true);

CREATE POLICY respostas_opcoes_select_anon
ON public.respostas_opcoes
FOR SELECT
TO anon
USING (true);

CREATE POLICY respostas_opcoes_insert_anon
ON public.respostas_opcoes
FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY respostas_opcoes_update_anon
ON public.respostas_opcoes
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY perguntas_preferencias_select_anon
ON public.perguntas_preferencias
FOR SELECT
TO anon
USING (true);

CREATE POLICY respostas_preferencias_select_anon
ON public.respostas_preferencias
FOR SELECT
TO anon
USING (true);

CREATE POLICY respostas_preferencias_insert_anon
ON public.respostas_preferencias
FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY respostas_preferencias_update_anon
ON public.respostas_preferencias
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY progresso_respondente_select_anon
ON public.progresso_respondente
FOR SELECT
TO anon
USING (true);

CREATE POLICY progresso_respondente_insert_anon
ON public.progresso_respondente
FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY progresso_respondente_update_anon
ON public.progresso_respondente
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

-- =====================================================
-- 6. DADOS INICIAIS
-- =====================================================
INSERT INTO public.perguntas_opcoes (id, categoria, pergunta, tipo, opcoes, ordem)
VALUES
    ('I01', 'Disponibilidade', 'Em relação aos dados necessários para desempenhar minhas atividades, tenho acesso a:', 'radio', '[{"valor":0,"texto":"Parte deles"},{"valor":1,"texto":"Todos"}]'::jsonb, 1),
    ('I02', 'Disponibilidade', 'Os dados que tenho acesso são consistentes, corretos e atendem às expectativas.', 'escala', '[{"valor":0,"texto":"Discordo totalmente"},{"valor":1,"texto":"Discordo"},{"valor":2,"texto":"Concordo"},{"valor":3,"texto":"Concordo totalmente"}]'::jsonb, 2),
    ('I03', 'Disponibilidade', 'Os dados são atualizados e disponibilizados em tempo adequado para realizar o meu trabalho.', 'escala', '[{"valor":0,"texto":"Discordo totalmente"},{"valor":1,"texto":"Discordo"},{"valor":2,"texto":"Concordo"},{"valor":3,"texto":"Concordo totalmente"}]'::jsonb, 3),
    ('I04', 'Disponibilidade', 'As ferramentas de análise de dados fornecidas pela empresa são adequadas para as análises que preciso realizar.', 'escala', '[{"valor":0,"texto":"Discordo totalmente"},{"valor":1,"texto":"Discordo"},{"valor":2,"texto":"Concordo"},{"valor":3,"texto":"Concordo totalmente"}]'::jsonb, 4),
    ('I05', 'Disponibilidade', 'As ferramentas de dados disponibilizadas pela empresa são fáceis de serem utilizadas.', 'escala', '[{"valor":0,"texto":"Discordo totalmente"},{"valor":1,"texto":"Discordo"},{"valor":2,"texto":"Concordo"},{"valor":3,"texto":"Concordo totalmente"}]'::jsonb, 5),
    ('I06', 'Disponibilidade', 'Quando temos problemas técnicos, o suporte técnico de dados e ferramentas é:', 'escala', '[{"valor":0,"texto":"Ineficaz"},{"valor":1,"texto":"Pouco eficaz"},{"valor":2,"texto":"Eficaz"},{"valor":3,"texto":"Muito eficaz"}]'::jsonb, 6),
    ('I07', 'Disponibilidade', 'Posso contar com profissionais especializados para auxiliar, estruturar ou gerar os dados e análises necessários para o meu trabalho.', 'escala', '[{"valor":0,"texto":"Nunca"},{"valor":1,"texto":"Poucas vezes"},{"valor":2,"texto":"Na maioria das vezes"},{"valor":3,"texto":"Sempre"}]'::jsonb, 7),
    ('I08', 'Disponibilidade', 'A documentação de como os dados são definidos, coletados e tratados facilita minha compreensão das métricas da empresa.', 'escala', '[{"valor":0,"texto":"Discordo totalmente"},{"valor":1,"texto":"Discordo"},{"valor":2,"texto":"Concordo"},{"valor":3,"texto":"Concordo totalmente"}]'::jsonb, 8),
    ('I09', 'Incentivo ao desenvolvimento', 'Os treinamentos oferecidos pela empresa colaboram para que eu use mais os dados no meu dia a dia.', 'simNao', '[{"valor":0,"texto":"Não"},{"valor":1,"texto":"Sim"}]'::jsonb, 9),
    ('I10', 'Incentivo ao desenvolvimento', 'A empresa incentiva o desenvolvimento de competências para gerar informações a partir dos dados.', 'simNao', '[{"valor":0,"texto":"Não"},{"valor":1,"texto":"Sim"}]'::jsonb, 10),
    ('I11', 'Incentivo ao desenvolvimento', 'A empresa incentiva o desenvolvimento de técnicas de comunicação para apresentar análises, insights e informações obtidas pelos dados.', 'simNao', '[{"valor":0,"texto":"Não"},{"valor":1,"texto":"Sim"}]'::jsonb, 11),
    ('I12', 'Incentivo ao desenvolvimento', 'A empresa incentiva a realização de testes para verificar hipóteses de negócios.', 'simNao', '[{"valor":0,"texto":"Não"},{"valor":1,"texto":"Sim"}]'::jsonb, 12),
    ('I13', 'Suporte da liderança', 'Os líderes investem em profissionais qualificados para a realização das análises com base em dados.', 'escala', '[{"valor":0,"texto":"Nunca"},{"valor":1,"texto":"Nem sempre"},{"valor":2,"texto":"Sempre"}]'::jsonb, 13),
    ('I14', 'Suporte da liderança', 'Sei quais são os objetivos da empresa para o uso de dados.', 'simNao', '[{"valor":0,"texto":"Não"},{"valor":1,"texto":"Sim"}]'::jsonb, 14),
    ('I15', 'Benefícios individuais', 'Tomo ações melhores e mais rápidas com o uso de dados da empresa.', 'simNao', '[{"valor":0,"texto":"Não"},{"valor":1,"texto":"Sim"}]'::jsonb, 15),
    ('I16', 'Benefícios individuais', 'As informações geradas pelos dados têm resultado aplicável aos processos da empresa.', 'simNao', '[{"valor":0,"texto":"Não"},{"valor":1,"texto":"Sim"}]'::jsonb, 16),
    ('I17', 'Resultados para a empresa', 'Meus líderes utilizam as informações geradas a partir dos dados para tomar decisões.', 'escala', '[{"valor":0,"texto":"Nunca"},{"valor":1,"texto":"Nem sempre"},{"valor":2,"texto":"Sempre"}]'::jsonb, 17),
    ('I18', 'Resultados para a empresa', 'Os líderes investem em profissionais qualificados para a realização das análises com base em dados.', 'escala', '[{"valor":0,"texto":"Nunca"},{"valor":1,"texto":"Nem sempre"},{"valor":2,"texto":"Sempre"}]'::jsonb, 18)
ON CONFLICT (id) DO UPDATE SET
    categoria = EXCLUDED.categoria,
    pergunta = EXCLUDED.pergunta,
    tipo = EXCLUDED.tipo,
    opcoes = EXCLUDED.opcoes,
    ordem = EXCLUDED.ordem;

INSERT INTO public.perguntas_preferencias (id, categoria, pergunta, tipo, opcoes, peso, ordem)
VALUES
    ('P01', 'Preferencias', 'Os colaboradores devem ser capacitados para utilizar as ferramentas de forma eficiente, desenvolvendo habilidades que vao alem do aspecto tecnico e incluam a aplicacao pratica para resolver problemas reais do negocio.', 'ranking', '[]'::jsonb, 3, 1),
    ('P02', 'Preferencias', 'E fundamental que a organizacao invista em educacao e treinamentos focados no desenvolvimento de competencias em analise de informacoes e gestao de dados.', 'ranking', '[]'::jsonb, 3, 2),
    ('P03', 'Preferencias', 'E essencial que haja uma integracao entre evidencias derivada dos dados e o conhecimento humano, utilizando a experimentacao frequente como metodo para otimizar decisoes e superar escolhas baseadas apenas em experiencias passadas.', 'ranking', '[]'::jsonb, 3, 3),
    ('P04', 'Preferencias', 'E fundamental que a organizacao promova workshops envolvendo diferentes equipes e espacos de demonstracao onde melhores praticas sejam compartilhadas, fornecendo reforco positivo e exemplos concretos de como as informacoes sao utilizadas na pratica', 'ranking', '[]'::jsonb, 3, 4),
    ('P05', 'Preferencias', 'E fundamental que os colaboradores percebam como as ferramentas de analise podem gerar valor para o negocio e desenvolvam uma atitude proativa no uso das informacoes disponiveis.', 'ranking', '[]'::jsonb, 3, 5),
    ('P06', 'Preferencias', 'Os colaboradores devem ser capazes de realizar suas tarefas com qualidade de forma independente, equilibrando atividades rotineiras e de inovacao, e utilizem sua experiencia pratica para validar a consistencia das informacoes.', 'ranking', '[]'::jsonb, 3, 6),
    ('P07', 'Preferencias', 'E essencial que os colaboradores desenvolvam a habilidade de coletar, analisar, interpretar e comunicar informacoes de forma eficiente, aplicando metodos analiticos para descrever o uso e o valor das informacoes disponiveis.', 'ranking', '[]'::jsonb, 3, 7),
    ('P08', 'Preferencias', 'A organizacao deve reconhecer e superar a distribuicao desigual de competencias em analise de dados, pois a baixa utilizacao ocorre quando os colaboradores nao tem consciencia das possibilidades que as informacoes oferecem ou nao sabem como visualizar e gerar valor a partir delas.', 'ranking', '[]'::jsonb, 3, 8),
    ('P09', 'Preferencias', 'E fundamental que os lideres comuniquem claramente a visao de mudanca desejada e demonstrem no dia a dia como utilizar dados para tomar decisoes, influenciando assim toda a estrutura organizacional.', 'ranking', '[]'::jsonb, 3, 9),
    ('P10', 'Preferencias', 'A gestao deve promover a mudanca de mentalidade dos proprios gestores, incentivando-os a questionar suas suposicoes e a substituir decisoes baseadas apenas em intuicao por analises fundamentadas em evidencias concretas.', 'ranking', '[]'::jsonb, 3, 10),
    ('P11', 'Preferencias', 'A empresa deve criar um cargo de alta gestao especifico para os dados para atuar como facilitador da transformacao e operacionalizar a cultura desejada.', 'ranking', '[]'::jsonb, 3, 11),
    ('P12', 'Preferencias', 'E fundamental que independentemente do nivel hierarquico e do conhecimento em analise de dados, todos os colaboradores sejam incentivados trocar experiencias com especialistas e a propor insights baseados em dados.', 'ranking', '[]'::jsonb, 3, 12),
    ('P13', 'Preferencias', 'E fundamental que os colaboradores explorem, compartilhem e apliquem ativamente o conhecimento disponivel, colaborando para usar o conhecimento na organizacao para criar vantagens estrategicas diante das mudancas constantes.', 'ranking', '[]'::jsonb, 3, 13),
    ('P14', 'Preferencias', 'E fundamental desenvolver a capacidade analitica, seja ela descritiva, preditiva ou prescritiva, permitindo analisar informacoes em tempo real de diversas fontes.', 'ranking', '[]'::jsonb, 3, 14),
    ('P15', 'Preferencias', 'A organizacao deve estar disposta mudar os arranjos de poder dentro da organizacao, definindo responsabilidades individuais para implementacao de analises e sendo tolerante ao teste e erro.', 'ranking', '[]'::jsonb, 3, 15),
    ('P16', 'Preferencias', 'E fundamental que a organizacao defina e institua papeis especializados, como analistas de dados, cientista de dados e gestor de dados, pois a institucionalizacao de cargos atua como propagador das funcoes desejadas na organizacao.', 'ranking', '[]'::jsonb, 3, 16),
    ('P17', 'Preferencias', 'Os lideres devem estabelecer principios comuns sobre o uso de informacoes e garantir que pressoes comerciais nao comprometam a qualidade das decisoes baseadas em fatos e dados.', 'ranking', '[]'::jsonb, 3, 17),
    ('P18', 'Preferencias', 'A organizacao deve disponibilizar sistemas que permitam acessar e utilizar os dados de forma autonoma e agil, com relatorios automatizados e uma operacao eficiente entre as equipes de negocio e tecnologia da informacao.', 'ranking', '[]'::jsonb, 3, 18),
    ('P19', 'Preferencias', 'A organizacao deve garantir transparencia sobre a origem e o uso das informacoes, fornecendo dados de alta qualidade e consistencia para que os colaboradores desenvolvam confianca e senso de responsabilidade.', 'ranking', '[]'::jsonb, 3, 19),
    ('P20', 'Preferencias', 'A organizacao deve estabelecer regras claras para maximizar o valor extraido das informacoes enquanto minimiza riscos e custos, garantindo a coleta correta dos dados e definindo uma fonte unica e confiavel de informacoes.', 'ranking', '[]'::jsonb, 3, 20),
    ('P21', 'Preferencias', 'E essencial que a empresa defina claramente quem e responsavel pela captura, veracidade e governanca das informacoes, e institucionalize principios eticos de transparencia, privacidade e controle rigoroso de acesso a dados sensiveis.', 'ranking', '[]'::jsonb, 3, 21),
    ('P22', 'Preferencias', 'Um setor especializado deve estabelecer a visao, estrategia e governanca para todas as iniciativas de dados, garantindo o bom funcionamento dos sistemas, o uso etico e responsavel das informacoes, e responsabilizando-se pelas decisoes sobre manutencao e evolucao dos mecanismos de governanca.', 'ranking', '[]'::jsonb, 3, 22),
    ('P23', 'Preferencias', 'Os membros da organizacao devem compartilhar informacoes e conhecimentos, colaborar e comunicar uns com os outros para que a aprendizagem continua dos membros possa mitigar divergencias e reduzir conflitos.', 'ranking', '[]'::jsonb, 3, 23),
    ('P24', 'Preferencias', 'Os membros da organizacao necessitam desenvolver habilidades de comunicacao, capacitando-se para compartilhar informacoes eficazmente e traduzir analises tecnicas em informacoes praticas que orientem decisoes de negocio.', 'ranking', '[]'::jsonb, 3, 24),
    ('P25', 'Preferencias', 'E fundamental que a organizacao documente e comunique uma visao clara sobre o uso de dados, alinhada as necessidades do negocio seja aplicavel em processos e iniciativas especificas.', 'ranking', '[]'::jsonb, 3, 25),
    ('P26', 'Preferencias', 'E essencial que a opiniao dos membros da organizacao seja considerada durante as definicoes de mudanca das rotinas de analise, fornecendo feedbacks acerca de possiveis ferramentas de analise de dados e seu uso dentro da empresa.', 'ranking', '[]'::jsonb, 3, 26),
    ('P27', 'Preferencias', 'E fundamental que as ferramentas e sistemas de analise sejam implementados para atender necessidades especificas do negocio, e nao apenas por razoes tecnologicas, garantindo o uso sistematico das informacoes disponiveis.', 'ranking', '[]'::jsonb, 3, 27),
    ('P28', 'Preferencias', 'E essencial que profissionais com ampla experiencia atuem como agentes de mudanca, disseminando praticas eficazes e removendo obstaculos no acesso e uso das informacoes.', 'ranking', '[]'::jsonb, 3, 28),
    ('P29', 'Preferencias', 'A organizacao deve construir um ambiente onde os colaboradores sintam-se seguros para experimentar novas abordagens, aprender com os erros e compartilhar descobertas que possam desafiar percepcoes ja existentes.', 'ranking', '[]'::jsonb, 3, 29),
    ('P30', 'Preferencias', 'E essencial que os colaboradores estejam abertos para compartilhar informacoes e conhecimentos entre si e que haja alinhamento e colaboracao entre os setores envolvidos.', 'ranking', '[]'::jsonb, 3, 30),
    ('P31', 'Preferencias', 'A empresa deve realizar sessoes praticas onde novas ferramentas sejam demonstradas e seu valor explicado, difunda relatos sobre a historia de sucesso da aplicacao, e integre esses esforcos a melhora da performance organizacional.', 'ranking', '[]'::jsonb, 3, 31),
    ('P32', 'Preferencias', 'E fundamental desenvolver politicas de recursos humanos que definam as competencias necessarias para analise de dados eficaz, para entao atrair talentos especializados nessas competencias e desenvolve-las nos demais membros da organizacao.', 'ranking', '[]'::jsonb, 3, 32),
    ('P33', 'Preferencias', 'Os lideres devem construir um ambiente onde os colaboradores sintam-se seguros para questionar, inovar e aprender com os erros, fortalecendo a confianca nas iniciativas baseadas em analise de dados.', 'ranking', '[]'::jsonb, 3, 33),
    ('P34', 'Preferencias', 'E essencial que os gestores evidenciem a importancia do demandem o uso de dados para decisoes, reconhecam formalmente as praticas consideradas corretas e destinem recursos para capacitacao e infraestrutura necessarias.', 'ranking', '[]'::jsonb, 3, 34),
    ('P35', 'Preferencias', 'E essencial reconhecer que colaboradores podem resistir em abandonar metodos familiares, que tecnologias podem ser implementadas sem explicacao adequada de seu potencial, e que existe dificuldade em admitir lacunas no proprio conhecimento.', 'ranking', '[]'::jsonb, 3, 35),
    ('P36', 'Preferencias', 'A empresa deve estruturar processos para sustentar a cultura, avaliando a robustez da organizacao para as praticas desejadas e orquestrando recursos e ativos para promove-las.', 'ranking', '[]'::jsonb, 3, 36),
    ('P37', 'Preferencias', 'A lideranca deve conhecer e comunicar os procedimentos e politicas de uso dos dados para alinhar com seus pares e subordinados acerca das regras e seus objetivos da organizacao.', 'ranking', '[]'::jsonb, 3, 37),
    ('P38', 'Preferencias', 'A empresa deve definir normas bem estruturadas que garantam a precisao, credibilidade e adequacao das informacoes, mantendo a integridade e a padronizacao necessarias para que os colaboradores confiem nas analises e tomem decisoes seguras.', 'ranking', '[]'::jsonb, 3, 38),
    ('P39', 'Preferencias', 'Os colaboradores devem estar dispostos a reformular suas bases de conhecimento quando novas informacoes contradizem praticas existentes, promovendo o refinamento de abordagens e a geracao de inovacoes em produtos e processos.', 'ranking', '[]'::jsonb, 3, 39),
    ('P40', 'Preferencias', 'E crucial formar equipes multidisciplinares que integrem especialistas em tecnologia e analise de dados com profissionais que possuem o conhecimento pratico das operacoes.', 'ranking', '[]'::jsonb, 3, 40),
    ('P41', 'Preferencias', 'A empresa deve destinar orcamento especifico para capacitacao e estruturar sistemas formais de aprendizagem, como bibliotecas de conhecimento, onde especialistas compartilhem suas experiencias e formalizem a aquisicao de novas competencias.', 'ranking', '[]'::jsonb, 3, 41),
    ('P42', 'Preferencias', 'E essencial que a empresa estabeleca infraestrutura robusta para coletar, armazenar e consolidar informacoes, utilizando sistemas organizados que disponibilizem os dados para as pessoas certas no momento adequado.', 'ranking', '[]'::jsonb, 3, 42),
    ('P43', 'Preferencias', 'E fundamental que a organizacao estabeleca regras claras sobre como administrar, compartilhar e proteger os dados de forma etica e segura, formalizando o modo como sao valorizados e utilizados nas decisoes.', 'ranking', '[]'::jsonb, 3, 43),
    ('P44', 'Preferencias', 'A organizacao deve desenvolver a capacidade de adquirir, assimilar e aplicar novas informacoes de forma agil, demonstrando disposicao clara para adaptar processos e comportamentos com base nos insights obtidos.', 'ranking', '[]'::jsonb, 3, 44),
    ('P45', 'Preferencias', 'A empresa deve medir e monitorar os resultados das iniciativas orientada a dados para aumentar a confianca nos dados e motivar os colaboradores, demonstrando os beneficios tangiveis do trabalho orientado por dados.', 'ranking', '[]'::jsonb, 3, 45),
    ('P46', 'Preferencias', 'A organizacao deve estabelecer um ciclo continuo de metas claras, medicao do sucesso, interacao e feedback constantes, e aprendizado a partir dos resultados, garantindo que os indicadores sejam claros e logicos para que os colaboradores gerem insights e os gerenciem de forma autonoma.', 'ranking', '[]'::jsonb, 3, 46)
ON CONFLICT (id) DO UPDATE SET
    categoria = EXCLUDED.categoria,
    pergunta = EXCLUDED.pergunta,
    tipo = EXCLUDED.tipo,
    opcoes = EXCLUDED.opcoes,
    peso = EXCLUDED.peso,
    ordem = EXCLUDED.ordem;

-- Opcional: setores iniciais
INSERT INTO public.setores (nome)
VALUES
    ('RH'),
    ('Financeiro')
ON CONFLICT DO NOTHING;
