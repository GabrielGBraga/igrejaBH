# Arquitetura e Diretrizes do Grafo de Relacionamentos (Juntas e Ligamentos)

Este documento registra a arquitetura técnica, os princípios teológicos, os algoritmos determinísticos e as regras contra regressão do módulo de visualização do grafo de relacionamentos (`RelationshipGraphView.tsx`) e sua integração na tela de gestão (`RedeRelacionamentos.tsx`).

---

## 1. Fundamento Teológico e Propósito

Conforme definido em **Efésios 4:16** e detalhado no [`CLAUDE.md`](../CLAUDE.md):
> *"De quem todo o corpo, bem ajustado e consolidado pelo auxílio de toda junta, segundo a justa cooperação de cada parte, efetua o seu próprio aumento para a edificação de si mesmo em amor."*

O sistema da Igreja em Belo Horizonte não trata pessoas como "membros institucionais", mas como **discípulos**. A saúde da igreja depende da vitalidade das suas **juntas e ligamentos**:
1. **Juntas Verticais (Discipulado):** Relacionamento pessoal "vida na vida", onde discípulos mais maduros cuidam, oram, pastoreiam e formam discípulos mais novos, reproduzindo a vida de Cristo.
2. **Juntas Horizontais (Companheirismo de Obra):** Compromisso fraterno de prestação de contas mútua, oração e combate lado a lado no serviço e evangelismo urbano.
3. **Comunhão nas Casas (Grupos Caseiros):** A unidade básica da vida da igreja, onde os vínculos práticos se consolidam na vizinhança.

O objetivo do Grafo de Relacionamentos **NÃO é gerar um diagrama decorativo**, mas fornecer uma ferramenta analítica de precisão para presbíteros e diáconos (Nível 3) identificarem irmãos desprovidos de cuidado, gargalos de sobrecarga e oportunidades de edificação.

---

## 2. Erros Críticos do Passado (O Que NUNCA Mais Repetir)

Para evitar regressões, qualquer desenvolvedor ou agente de IA deve estar ciente das falhas que anteriormente quebraram o grafo:

### ❌ Erro 1: Algoritmo de Árvore Ingênuo que Colapsava em X = 0
* **O Bug:** O código definia `prelimX = 0` para todos os nós folha e depois calculava `(prelimX_primeiro_filho + prelimX_ultimo_filho) / 2 = 0` para os pais.
* **O Efeito:** 100% dos nós convergiam para a mesmíssima coordenada `X = 0`, empilhando centenas de nós uns sobre os outros em uma única coluna vertical ilegível.
* **A Regra Mandatória:** O layout hierárquico deve **obrigatoriamente** calcular a largura das subárvores de baixo para cima (*bottom-up* com espaçamento horizontal mínimo de `92px`) antes de atribuir posições no topo (*top-down*).

### ❌ Erro 2: Fusão de Casais Destruindo Árvores de Discipulado
* **O Bug:** Um algoritmo antigo fundia marido e esposa em um único "nó de casal".
* **O Efeito:** Na prática da igreja, o discipulado é **segregado por gênero** (irmãos discipulam irmãos, irmãs discipulam irmãs). Fundir o casal apagava metade dos vínculos `discipler_id` do banco, quebrando completamente as 4 linhagens de discipulado feminino das esposas de presbíteros.
* **A Regra Mandatória:** Cada irmão e irmã deve ser um nó individual no grafo. O matrimônio deve ser representado como uma ligação pontilhada opcional (`showMarriageLinks`) ou adjacência espacial, **nunca** por fusão de registros.

### ❌ Erro 3: Inclusão de Visitantes e Crianças como Raízes Fantasma (> 17.000px)
* **O Bug:** Perfis não vinculados à igreja (`is_church_linked === false`) e crianças sem batismo e sem discipulador eram tratados como raízes independentes de árvores genealógicas.
* **O Efeito:** Criação de mais de 50 árvores falsas de 1 elemento lado a lado, esticando o canvas além de 17.000 pixels de largura e deixando o zoom microscópico.
* **A Regra Mandatória:** Visitantes não vinculados devem ser excluídos da visualização do Corpo. Crianças são ocultadas por padrão e só aparecem via toggle explícito (*"Incluir Crianças"*), ligadas aos seus pais (`father_id` / `mother_id`).

### ❌ Erro 4: Reset de Zoom e Câmera em Cliques ou Hovers
* **O Bug:** O auto-enquadramento (`fitToScreen`) era disparado toda vez que o estado do componente mudava (como passar o mouse sobre um nó ou selecioná-lo).
* **O Efeito:** O usuário dava zoom em um irmão, clicava nele para inspecionar, e o grafo imediatamente dava "snap back" para o zoom inicial de 100% da tela, impossibilitando a navegação.
* **A Regra Mandatória:** `fitToScreen` só pode ser disparado quando a estrutura do dataset de layout mudar (`layoutKey`), nunca em eventos de seleção ou hover.

### ❌ Erro 5: Cores Hardcoded e Violação de Tema Escuro
* **O Bug:** Uso de hexadecimais soltos (`#3b82f6`, `#ef4444`) no código de desenho do Canvas e no JSX.
* **O Efeito:** Grafo ilegível no tema escuro e contraste quebrado.
* **A Regra Mandatória:** Todas as cores de canvas, links, badges e alertas DEVEM vir exclusivamente de `src/constants/colors.ts` (`RELATIONSHIP_NODE_COLORS`, `GRAPH_LINK_COLORS`, `GRAPH_CANVAS_COLORS`, `GRAPH_UI_CLASSES`).

---

## 3. Os 4 Modos Determinísticos de Visualização

O componente `RelationshipGraphView.tsx` opera em 4 modos estruturais:

### 3.1. Árvore de Discipulado (`computeTidyHierarchyLayout`)
* **Propósito:** Visualizar as cadeias verticais de paternidade espiritual e reprodução de discípulos.
* **Funcionamento:**
  - Monta a floresta de árvores baseada estritamente em `discipler_id`.
  - Calcula a largura de cada ramo de forma recursiva de baixo para cima (`subtreeWidth`), aplicando `NODE_SPACING_X = 92` e `SIBLING_GAP = 16`.
  - Quebra linhas automaticamente (`MAX_ROW_WIDTH = 2600`) para manter o mapa compacto e navegável.
  - Possui controle de profundidade (*Todas as Gerações*, *Até 2ª Geração*, *Até 3ª Geração*).
  - Inclui filtro de **Linhagem Raiz** para focar em uma cadeia específica.
  - Discípulos adultos sem discipulador são posicionados em uma **Zona de Alerta** com borda tracejada, facilitando a triagem.

### 3.2. Juntas por Grupo Caseiro (`computeGroupsClusterLayout`)
* **Propósito:** Mapear a vida do Corpo nas casas e identificar pontes entre grupos.
* **Funcionamento:**
  - Cria um cluster circular (*Oikos*) para cada Grupo Caseiro ativo.
  - Ordena os discípulos do grupo colocando discipuladores de GC e casais adjacentes no topo.
  - Grupos grandes (ex: 60+ discípulos) expandem concentricamente em anéis múltiplos, garantindo distância de arco mínima de `>= 58px`.
  - Links de discipulado entre membros do mesmo GC usam a cor do grupo; links cruzados (inter-GC) são destacados para revelar pontes relacionais na cidade.

### 3.3. Rede de Companheirismo (`computeFellowshipNetworkLayout`)
* **Propósito:** Analisar as juntas horizontais de dois a dois para a obra (Lucas 10:1).
* **Funcionamento:**
  - Divisão hemisférica baseada no gênero:
    - **Esquerda:** Irmãos (M).
    - **Direita:** Irmãs (F).
  - Estratificação em 3 anéis concêntricos de maturidade:
    1. *Núcleo Central:* Presbíteros, diáconos e líderes.
    2. *Anel Intermediário:* Discípulos com juntas ativas de companheirismo (`fellowships`).
    3. *Anel Externo:* Discípulos sem nenhum companheiro de obra registrado.
  - Linhas violeta tracejadas conectam os parceiros de oração e serviço.

### 3.4. Raio-X da Junta Isolada (`computeIsolatedJuntaLayout` / Ego-Network)
* **Propósito:** Foco cirúrgico no ecossistema relacional de um irmão ou irmã específica.
* **Ativação:** Duplo-clique em qualquer nó do canvas ou botão *"Isolar Junta"* no painel lateral.
* **Estrutura:**
  - **Eixo Superior:** Cadeia ascendente direta de discipuladores até a cobertura presbiteral.
  - **Eixo Central:** O irmão em foco, ladeado pelo cônjuge e seus companheiros de obra.
  - **Eixo Inferior:** Todas as gerações de discípulos acompanhados por ele.
  - Botão de alternância entre *"Focar 1ª e 2ª Geração"* e *"Expandir Toda a Linhagem"*.

---

## 4. Diagnósticos Pastorais e Regra do Presbitério

No topo do grafo existem 4 cartões clicáveis e um chip de oportunidade:
1. **Corpo no Recorte:** Total de irmãos presentes nos filtros aplicados.
2. **Sem Discipulador (Atenção):** Discípulos que necessitam de um discipulador.
   * *Regra Especial do Presbitério:* Presbíteros e suas esposas **possuem cobertura mútua no Presbitério** e atuam como raízes da rede. Portanto, **nunca** devem ser computados ou exibidos como "sem discipulador".
3. **Sem Companheiro de Obra:** Discípulos que caminham sozinhos sem uma junta horizontal registrada.
4. **Carga ≥ 4 Discípulos:** Discipuladores que cuidam de 4 ou mais pessoas diretamente (alerta de possível sobrecarga pastoral).
5. **Potenciais Discipuladores:** Irmãos com ≥ 2 anos de batismo que ainda não discipulam ninguém diretamente.

---

## 5. Diretrizes de UI/UX, Acessibilidade e Mobile-First

Conforme as diretrizes globais do projeto:
* **Tamanho Mínimo de Toque (44x44px):** Todos os botões, opções de abas, filtros e controles de zoom possuem classe `min-h-[44px]` (e `min-w-[44px]` quando ícones isolados).
* **Responsividade a partir de 320px:** Nenhum elemento causa overflow horizontal. Formulários e filtros usam grids responsivos (`grid-cols-1 sm:grid-cols-2 lg:...`).
* **Interações Táteis e Canvas:**
  - No desktop: Scroll do mouse para zoom, clique e arraste para pan.
  - No mobile: 1 dedo para arrastar, 2 dedos para pinça (pinch-to-zoom).
* **Renderização Eficiente no Canvas:**
  - Utiliza `requestAnimationFrame` orientado a eventos (dirty flag).
  - Suporte completo a telas Retina (`window.devicePixelRatio`).
  - Consumo de CPU em repouso é **0%**.
* **Higiene Visual (Anti-AI Slop):**
  - Proibido o uso de gradientes chamativos de SaaS, ícones mágicos (`Sparkles`) ou banners artificiais.
  - A interface prioriza legibilidade, sobriedade e funcionalidade pastoral.

---

## 6. Checklist para Modificações Futuras

Antes de aprovar ou commitar qualquer alteração no grafo:
1. [ ] Rodar `npx tsc -b` para garantir ausência de erros de tipagem.
2. [ ] Rodar `npx eslint src/components/gestao/RelationshipGraphView.tsx src/pages/RedeRelacionamentos.tsx` (0 erros).
3. [ ] Rodar `npm run build` para validar empacotamento completo do Vite.
4. [ ] Confirmar que nenhum hexadecimal (`#...`) foi introduzido fora de `src/constants/colors.ts`.
5. [ ] Verificar se os botões interativos mantêm `min-h-[44px]` e touch targets adequados.
6. [ ] Validar que casais permanecem como nós separados nas árvores por gênero.
