# Diretrizes de Conteúdo e Design de UI/UX (Site da Igreja)

Você é um agente encarregado de criar componentes (React, Tailwind, shadcn/ui) e textos (copywriting) para o site desta igreja. Todo o design, a arquitetura de informação e a linguagem devem refletir estritamente os princípios teológicos abaixo. Evite qualquer modelo tradicional, corporativo ou genérico de sites evangélicos.

---

## 1. O Propósito Eterno (Visão Central)
* **Conceito:** O propósito de Deus, desenhado antes da fundação do mundo, é ter uma família de muitos filhos semelhantes a Jesus. A salvação é o meio para alcançar isso, e não o fim em si mesma.
* **Aplicação no Site:** O tom dos textos não deve ser "humanista" (o homem e suas necessidades no centro), mas teocêntrico. Ao gerar chamadas de ação (CTAs) ou cabeçalhos, foque em "vida em família", "semelhança com Cristo" e "propósito eterno".

---

## 2. Sacerdócio Universal (Sem Divisão Clero/Leigo)
* **Conceito:** Todos os membros da igreja são sacerdotes e ministros chamados para desempenhar um serviço. O corpo de Cristo edifica o corpo de Cristo; líderes existem apenas para equipar e ordenar os santos para que *os santos* façam a obra.
* **Aplicação no Design/UI:** O site não deve ter componentes que destaquem "super astros do púlpito" ou hiperfoco em uma hierarquia pastoral. O design de páginas "Sobre Nós" ou "Liderança" deve refletir horizontalidade e serviço mútuo.

---

## 3. Edificação por Relacionamentos (Juntas e Ligamentos)
* **Conceito:** A estrutura da igreja é mantida por "juntas e ligamentos", que são relacionamentos fortes de discipulado (vida na vida, modelando o caráter de Cristo) e companheirismo (compromisso horizontal de prestação de contas, oração e serviço).
* **Aplicação no Site:** Em vez de focar apenas em descrições de "cultos", crie componentes de interface que estimulem o visitante a se conectar a um relacionamento real de discipulado.

---

## 4. A Dinâmica da Igreja nas Casas e nas Ruas)
* **Conceito:** A igreja não é "templista". Ela deve se reunir nas casas, não apenas para reuniões passivas, mas como equipes de trabalho e centros de treinamento para limpar as armas e planejar o evangelismo prático. A "rua" é o ambiente principal para o contato com o mundo.
* **Aplicação no Design/UI:** A igreja são as pessoas, não um endereço. Na arquitetura de informação, não crie páginas, galerias ou destaques voltados para um "prédio principal" ou "salão de cultos". Ao gerar os *cards* da interface, priorize ilustrar pequenos grupos e o convívio nas casas. O destaque do sistema de mapas/localização deve ser a funcionalidade de encontrar a "Igreja na Casa" mais próxima, e não as coordenadas de um templo central.

---

## 5. Evangelismo e Frutificação
* **Conceito:** Dar fruto é obrigatório e significa a reprodução da vida de Cristo em outros (fazer novos discípulos). O contato inicial com as pessoas deve ser simples, natural, "jogando o anzol" para testar a fome espiritual, compartilhando o testemunho pessoal e ensinando as ordens de Cristo.
* **Aplicação no Site:** Páginas destinadas a visitantes devem ser simples, claras e focar no testemunho da transformação de vida e na proclamação do Evangelho do Reino (arrependimento e novo nascimento).

---

## 6. Identidade Não-Denominacional (Corpo Único)
* **Conceito:** A congregação local não é a totalidade da Igreja do Senhor, mas apenas uma parte dela na cidade. Por isso, não adota nomenclaturas denominacionais, reconhecendo que Cristo não dividiu a Sua igreja e que o Seu Corpo é um só.
* **Aplicação no Design/UI:** O agente nunca deve gerar textos, logos ou seções que sugiram uma "marca" religiosa, franquia ou rede denominacional. Ao gerar cabeçalhos (navbars), rodapés ou *hero sections*, utilize apenas identificações geográficas neutras (ex: "Igreja em [Nome da Cidade]") e reforce visualmente o conceito de unidade do Corpo de Cristo.

---

## 7. Vocabulário: Discípulos em vez de Membros
* **Conceito:** A igreja não é um clube ou instituição associativa; portanto, não possui "membros" estáticos, mas sim discípulos em constante processo de formação e aprendizado prático.
* **Aplicação no Design/UI:** O agente está terminantemente proibido de usar jargões institucionais. Ao gerar botões, formulários de contato ou seções de engajamento, substitua frases institucionais como "Torne-se um membro", "Seja membro" ou "Cadastre-se" por convites relacionais, como "Caminhe conosco", "Inicie seu discipulado" ou "Junte-se a nós".

---

## 8. Higiene de Copywriting e Arquitetura de Informação (Anti-Clichês de IA)
* **Proibição Absoluta da Palavra "Instituição":** NUNCA descreva a igreja como *"nossa existência enquanto instituição"* ou qualquer variação institucional, nem mesmo para explicar o nome geográfico da igreja. Use *"comunhão local"* ou *"presença local na cidade"*.
* **Sem Vazamento de Nomenclatura de Banco de Dados:** NUNCA exponha termos técnicos do schema na interface pública (ex: escrever *"Últimas Publicações Públicas"* por causa da coluna `is_public = true`). Use títulos naturais como *"Comunicados e Estudos Recentes"*.
* **Separação entre Ferramentas Internas e Landing Page Pública:** Componentes internos de estudo e acompanhamento (como widgets completos de `CatequeseDiaria` com metadados de trilhas, lições e botões de cópia para WhatsApp) pertencem ao `/dashboard` ou `/ensinos`. A Hero Section pública deve ser limpa, acolhedora e compreensível imediatamente por um visitante de primeira viagem.
* **Sem Links "Clique Aqui" ou Modais Escondendo Conteúdo Essencial:** NUNCA utilize frases como *"Quer saber mais..., clique aqui"* para esconder os fundamentos da fé em popups/modais que prometem conteúdos inexistentes (ex: prometer *"nossa história"* quando o modal contém apenas tópicos doutrinários). Apresente os fundamentos de forma editorial e direta na página.
* **Consistência de Identificação Geográfica:** Mantenha a identificação *"Igreja em Belo Horizonte"* consistente entre cabeçalho, Hero e rodapé, evitando alternar entre múltiplas variações de títulos em cada seção da mesma página.
