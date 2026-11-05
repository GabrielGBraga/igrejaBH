import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function escapePdfText(text) {
  return text
    .replace(/\\/g, "\\\\")
    .replace(/\(/g, "\\(")
    .replace(/\)/g, "\\)")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, ""); // Standard Type1 Helvetica uses ASCII/Latin-1
}

function buildPageStream(lines) {
  let stream = "BT\n50 780 Td\n";
  let first = true;
  for (const l of lines) {
    const escaped = escapePdfText(l.text);
    if (first) {
      stream += `${l.font} ${l.size} Tf\n(${escaped}) Tj\n`;
      first = false;
    } else {
      stream += `${l.font} ${l.size} Tf\n0 ${l.dy} Td\n(${escaped}) Tj\n`;
    }
  }
  stream += "ET\n";
  return Buffer.from(stream, "latin1");
}

function buildMultiPagePdf(pagesData) {
  const pageStreams = pagesData.map(page => buildPageStream(page.lines));
  const pageCount = pageStreams.length;

  const objects = [];
  // Object 1: Catalog
  objects.push(`1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj`);

  // Object 2: Pages
  const pageKidsRefs = [];
  for (let i = 0; i < pageCount; i++) {
    pageKidsRefs.push(`${3 + i} 0 R`);
  }
  objects.push(`2 0 obj\n<< /Type /Pages /Kids [${pageKidsRefs.join(" ")}] /Count ${pageCount} >>\nendobj`);

  // Page Objects: 3 ... 3 + pageCount - 1
  // Font Objects will be after contents
  const contentStartIdx = 3 + pageCount;
  const fontStartIdx = contentStartIdx + pageCount;

  for (let i = 0; i < pageCount; i++) {
    const contentRef = `${contentStartIdx + i} 0 R`;
    objects.push(
      `${3 + i} 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents ${contentRef} /Resources << /Font << /F1 ${fontStartIdx} 0 R /F2 ${fontStartIdx + 1} 0 R /F3 ${fontStartIdx + 2} 0 R >> >> >>\nendobj`
    );
  }

  // Content Stream Objects
  for (let i = 0; i < pageCount; i++) {
    const s = pageStreams[i];
    objects.push(
      `${contentStartIdx + i} 0 obj\n<< /Length ${s.length} >>\nstream\n${s.toString("latin1")}endstream\nendobj`
    );
  }

  // Fonts
  objects.push(`${fontStartIdx} 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj`);
  objects.push(`${fontStartIdx + 1} 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj`);
  objects.push(`${fontStartIdx + 2} 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Oblique >>\nendobj`);

  let body = "%PDF-1.4\n";
  const offsets = [];

  for (let i = 0; i < objects.length; i++) {
    offsets.push(Buffer.byteLength(body, "latin1"));
    body += objects[i] + "\n";
  }

  const startxref = Buffer.byteLength(body, "latin1");
  body += `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`;

  for (let i = 0; i < offsets.length; i++) {
    body += offsets[i].toString().padStart(10, "0") + " 00000 n \n";
  }

  body += `trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n${startxref}\n%%EOF\n`;

  return Buffer.from(body, "latin1");
}

const documentsDir = path.join(__dirname, "../public/documents");
if (!fs.existsSync(documentsDir)) {
  fs.mkdirSync(documentsDir, { recursive: true });
}

// ==========================================
// 1. Caderno de Estudo 01: O Proposito Eterno
// ==========================================
const doc1 = buildMultiPagePdf([
  {
    lines: [
      { font: "/F1", size: 9, text: "IGREJA EM BELO HORIZONTE  *  MINISTERIO APOSTOLICO  *  TRILHA 1", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 18, text: "Caderno de Estudo 01: Fundamentos do Proposito Eterno", dy: -28 },
      { font: "/F2", size: 11, text: "Compreendendo o plano de Deus antes da fundacao do mundo", dy: -18 },
      { font: "/F3", size: 9, text: "Texto-base: Romanos 8:28-30; Efesios 1:3-14 e Efesios 3:8-12", dy: -20 },
      { font: "/F2", size: 8, text: "===================================================================================================================", dy: -14 },
      
      { font: "/F1", size: 12, text: "1. Deus Tem um Proposito Anterior a Criacao", dy: -22 },
      { font: "/F2", size: 10, text: "Antes de haver tempo, universo ou pecado, o Deus Triuno determinou em Si mesmo ter uma grande", dy: -16 },
      { font: "/F2", size: 10, text: "familia de muitos filhos espirituais semelhantes a Jesus Cristo, Seu Filho Primogenito.", dy: -14 },
      { font: "/F2", size: 10, text: "A criacao do ser humano a imagem e semelhanca de Deus foi o primeiro ato para esse objetivo eterno.", dy: -14 },
      { font: "/F2", size: 10, text: "Portanto, a salvacao humana nao e o objetivo final de Deus, mas o meio indispensavel de resgate.", dy: -14 },

      { font: "/F1", size: 12, text: "2. A Cruz e a Centralidade Absoluta de Cristo", dy: -22 },
      { font: "/F2", size: 10, text: "Na cruz do Calvario, o Cordeiro de Deus nao apenas cancelou a nossa divida de pecado,", dy: -16 },
      { font: "/F2", size: 10, text: "mas aniquilou a velha natureza egoista para que a propria vida zoe de Cristo habite em nos.", dy: -14 },
      { font: "/F2", size: 10, text: "Fomos libertos da escravidao do eu para nos tornarmos sacerdotes em comunhao com os irmaos.", dy: -14 },
      { font: "/F2", size: 10, text: "A vida crista individualista e uma contradicao a luz do projeto corporativo do Pai.", dy: -14 },

      { font: "/F1", size: 12, text: "3. Uma Familia de Filhos Maduros", dy: -22 },
      { font: "/F2", size: 10, text: "Deus nao busca apenas conversos que frequentam reunioes passivas, mas discipulos santos", dy: -16 },
      { font: "/F2", size: 10, text: "que reproduzem Seu carater em amor, integridade, mansidao e fe cotidiana em Belo Horizonte.", dy: -14 },
      { font: "/F2", size: 10, text: "Cada casa aberta para orar e repartir o pao e uma testemunha viva desse Reino presente.", dy: -14 },

      { font: "/F3", size: 8, text: "Pagina 1 de 2  *  Caderno 01: Fundamentos do Proposito Eterno  *  Igreja em BH", dy: -60 }
    ]
  },
  {
    lines: [
      { font: "/F1", size: 9, text: "ROTEIRO PRATICO DE DISCIPULADO E FIXACAO  *  ETAPA 1", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 13, text: "Perguntas de Reflexao para o Encontro de Discipulado (Vida na Vida)", dy: -24 },
      
      { font: "/F1", size: 10, text: "Questao 01: Foco Teocentrico vs. Humanocentrico", dy: -20 },
      { font: "/F2", size: 9, text: "Como a compreensao de que a salvacao e para a gloria de Deus muda sua forma de orar e trabalhar?", dy: -14 },
      { font: "/F2", size: 9, text: "Resposta pessoal: __________________________________________________________________________________", dy: -14 },

      { font: "/F1", size: 10, text: "Questao 02: Desprendimento do Individualismo", dy: -22 },
      { font: "/F2", size: 9, text: "Quais aspectos da sua rotina ainda refletem isolamento? Como se conectar a outros santos?", dy: -14 },
      { font: "/F2", size: 9, text: "Resposta pessoal: __________________________________________________________________________________", dy: -14 },

      { font: "/F1", size: 10, text: "Questao 03: Pratica do Evangelho no Lar", dy: -22 },
      { font: "/F2", size: 9, text: "Como sua casa pode se tornar um ponto de acolhimento para vizinhos e novos discipulos?", dy: -14 },
      { font: "/F2", size: 9, text: "Resposta pessoal: __________________________________________________________________________________", dy: -14 },

      { font: "/F1", size: 12, text: "Compromisso Pratico da Semana", dy: -26 },
      { font: "/F2", size: 10, text: "[  ] Meditar diariamente em Efesios capitulo 1 e Romanos capitulo 8.", dy: -16 },
      { font: "/F2", size: 10, text: "[  ] Compartilhar esta compreensao do Proposito com seu discipulador ou companheiro.", dy: -15 },
      { font: "/F2", size: 10, text: "[  ] Praticar hospitalidade desinteressada com uma familia nesta semana.", dy: -15 },

      { font: "/F1", size: 11, text: "Espaco para Anotacoes Pessoais e Oracoes:", dy: -24 },
      { font: "/F2", size: 9, text: "___________________________________________________________________________________________________", dy: -18 },
      { font: "/F2", size: 9, text: "___________________________________________________________________________________________________", dy: -16 },
      { font: "/F2", size: 9, text: "___________________________________________________________________________________________________", dy: -16 },

      { font: "/F3", size: 8, text: "Pagina 2 de 2  *  Uso livre para edificacao no Corpo de Cristo  *  Atos 2:42", dy: -45 }
    ]
  }
]);
fs.writeFileSync(path.join(documentsDir, "caderno-estudo-01-proposito-eterno.pdf"), doc1);

// =========================================================================
// 2. Caderno de Estudo 02: Relacionamentos de Alianca e Cuidado Mutuo (O principal da issue!)
// =========================================================================
const doc2 = buildMultiPagePdf([
  {
    lines: [
      { font: "/F1", size: 9, text: "IGREJA EM BELO HORIZONTE  *  EDIFICACAO NO CORPO  *  TRILHA 2 - ETAPA 2", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 17, text: "Caderno de Estudo 02: Relacionamentos de Alianca e Cuidado Mutuo", dy: -28 },
      { font: "/F2", size: 11, text: "Trilha 2: Juntas e Ligamentos - O Discipulado Pratico - Etapa 2 de 2", dy: -18 },
      { font: "/F3", size: 9, text: "Texto-chave: Efesios 4:15-16; 1 Joao 1:7; Hebreus 10:24-25; Galatas 6:2", dy: -20 },
      { font: "/F2", size: 8, text: "===================================================================================================================", dy: -14 },

      { font: "/F1", size: 12, text: "1. O Que Sao as Juntas e Ligamentos no Corpo de Cristo?", dy: -22 },
      { font: "/F2", size: 10, text: "No corpo biologico, os ossos e musculos nao se conectam sozinhos; dependem de ligamentos fortes", dy: -16 },
      { font: "/F2", size: 10, text: "e juntas flexiveis que distribuem sangue, nutrientes e coordenam movimentos.", dy: -14 },
      { font: "/F2", size: 10, text: "Espiritualmente, o apostolo Paulo ensina que o Corpo cresce e se edifica em amor a medida que cada", dy: -14 },
      { font: "/F2", size: 10, text: "membro esta ajustado e unido pelo auxilio de todas as juntas segundo a cooperacao de cada parte.", dy: -14 },
      { font: "/F2", size: 10, text: "Sem relacionamentos intimos e prestacao de contas, o crente se torna um membro isolado e vulneravel.", dy: -14 },

      { font: "/F1", size: 12, text: "2. Discipulado Vida na Vida: Muito Alem de Encontros Semanais", dy: -22 },
      { font: "/F2", size: 10, text: "O modelo apostolico de discipulado nunca foi uma sala de aula com provas teoricas.", dy: -16 },
      { font: "/F2", size: 10, text: "Jesus chamou os doze para estarem com Ele (Marcos 3:14): caminhar nas estradas, chorar juntos,", dy: -14 },
      { font: "/F2", size: 10, text: "observar Suas reacoes sob pressao e aprender a orar pelo exemplo vivo.", dy: -14 },
      { font: "/F2", size: 10, text: "Discipulado e partilhar as refeicoes, abrir a intimidade do lar e cuidar das familias mutualmente.", dy: -14 },

      { font: "/F1", size: 12, text: "3. Transparencia, Luz e Confissao Mutua", dy: -22 },
      { font: "/F2", size: 10, text: "'Se andarmos na luz, como Ele na luz esta, temos comunhao uns com os outros' (1 Joao 1:7).", dy: -16 },
      { font: "/F2", size: 10, text: "Andar na luz significa nao manter mascaras religiosas de perfeicao. Onde ha confissao de fraquezas,", dy: -14 },
      { font: "/F2", size: 10, text: "ai ha perdao, cura e forca para vencer as tentacoes.", dy: -14 },

      { font: "/F3", size: 8, text: "Pagina 1 de 2  *  Caderno 02: Relacionamentos de Alianca  *  Igreja em Belo Horizonte", dy: -60 }
    ]
  },
  {
    lines: [
      { font: "/F1", size: 9, text: "ROTEIRO PRATICO DE ENCONTRO DE DISCIPULADO E PRESTACAO DE CONTAS", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 13, text: "Guia Semanal de Cuidado Mutuo entre Discipulos", dy: -24 },

      { font: "/F1", size: 10, text: "Passo 1: Compartilhar o Andar com Deus (Vida de Oracao e Palavra)", dy: -18 },
      { font: "/F2", size: 9, text: "- O que o Senhor falou ao seu coracao nas Escrituras durante os ultimos dias?", dy: -14 },
      { font: "/F2", size: 9, text: "- Houve perseveranca na oracao pessoal e intercessao pelos discipulos sob seu cuidado?", dy: -14 },

      { font: "/F1", size: 10, text: "Passo 2: Transparencia no Lar e nos Relacionamentos", dy: -20 },
      { font: "/F2", size: 9, text: "- Como esta a vida conjugal, o pastoreio dos filhos e o testemunho pratico em casa?", dy: -14 },
      { font: "/F2", size: 9, text: "- Ha algum conflito nao resolvido, amargura ou ressentimento necessitando de perdao?", dy: -14 },

      { font: "/F1", size: 10, text: "Passo 3: Integridade no Trabalho, Financas e Pensamentos", dy: -20 },
      { font: "/F2", size: 9, text: "- Houve integridade total nas transacoes, horarios e conduta profissional?", dy: -14 },
      { font: "/F2", size: 9, text: "- Quais foram as principais batalhas na mente contra orgulho, vaidade ou impureza?", dy: -14 },

      { font: "/F1", size: 12, text: "Passos Praticos para a Semana (Juntas e Ligamentos em Acao):", dy: -24 },
      { font: "/F2", size: 10, text: "[  ] Orar pelo companheiro de discipulado nominalmente todos os dias.", dy: -16 },
      { font: "/F2", size: 10, text: "[  ] Realizar uma visita fraterna ou almoco conjunto para fortalecer o vinculo.", dy: -15 },
      { font: "/F2", size: 10, text: "[  ] Juntos, praticar evangelismo de amizade com uma pessoa necessitada.", dy: -15 },

      { font: "/F1", size: 11, text: "Anotacoes e Alvos Espirituais Fixados:", dy: -24 },
      { font: "/F2", size: 9, text: "___________________________________________________________________________________________________", dy: -18 },
      { font: "/F2", size: 9, text: "___________________________________________________________________________________________________", dy: -16 },
      { font: "/F2", size: 9, text: "___________________________________________________________________________________________________", dy: -16 },

      { font: "/F3", size: 8, text: "Pagina 2 de 2  *  Edificacao Organica  *  Igreja em Belo Horizonte  *  Atos 2:42-46", dy: -45 }
    ]
  }
]);
fs.writeFileSync(path.join(documentsDir, "caderno-estudo-02-juntas-e-ligamentos.pdf"), doc2);

// =========================================================================
// 3. Caderno de Apoio: Evangelismo Natural e Fazendo Discipulos
// =========================================================================
const doc3 = buildMultiPagePdf([
  {
    lines: [
      { font: "/F1", size: 9, text: "IGREJA EM BELO HORIZONTE  *  A IGREJA NAS CASAS E NAS RUAS", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 18, text: "Caderno de Apoio: Evangelismo Natural e Fazendo Discipulos", dy: -28 },
      { font: "/F2", size: 11, text: "Proclamando o Evangelho do Reino na Vida Cotidiana de Belo Horizonte", dy: -18 },
      { font: "/F3", size: 9, text: "Texto-base: Lucas 10:1-9; Mateus 28:18-20; Atos 2:46-47", dy: -20 },
      { font: "/F2", size: 8, text: "===================================================================================================================", dy: -14 },

      { font: "/F1", size: 12, text: "1. Evangelismo como Frutificacao Natural de Vida", dy: -22 },
      { font: "/F2", size: 10, text: "No Reino de Deus, o evangelismo nao e uma tecnica de vendas ou proselitismo religioso.", dy: -16 },
      { font: "/F2", size: 10, text: "E a expressao transbordante da presenca de Cristo em nos, comunicada em amor verdadeiro.", dy: -14 },
      { font: "/F2", size: 10, text: "Conversamos naturalmente com vizinhos, colegas e parentes, identificando necessidades e dores.", dy: -14 },
      { font: "/F2", size: 10, text: "Onde o amor e praticado com pureza, o Espirito Santo gera fome pelas verdades eternas.", dy: -14 },

      { font: "/F1", size: 12, text: "2. Procurando o 'Filho da Paz'", dy: -22 },
      { font: "/F2", size: 10, text: "Jesus orientou os discipulos a entrarem nas casas e procurarem a pessoa que acolhe a paz de Deus.", dy: -16 },
      { font: "/F2", size: 10, text: "Nao forçamos portas fechadas com debates inuteis; dedicamos tempo aos que demonstram", dy: -14 },
      { font: "/F2", size: 10, text: "abertura sincera de coracao e sede espiritual.", dy: -14 },

      { font: "/F1", size: 12, text: "3. O Processo de Cuidado: De Ouvinte a Discipulo", dy: -22 },
      { font: "/F2", size: 10, text: "Ganhar uma pessoa para Cristo e apenas o nascimento espiritual (parto). O cuidado posterior", dy: -16 },
      { font: "/F2", size: 10, text: "e a paternidade espiritual continua ate que Cristo seja plenamente formado naquele santo.", dy: -14 },

      { font: "/F3", size: 8, text: "Pagina 1 de 2  *  Evangelismo Natural  *  Igreja em Belo Horizonte", dy: -60 }
    ]
  },
  {
    lines: [
      { font: "/F1", size: 9, text: "PRATICA DE EVANGELISMO E ACOLHIMENTO NAS CASAS", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 13, text: "Roteiro de Compartilhamento do Testemunho Pessoal", dy: -24 },

      { font: "/F1", size: 10, text: "Estrutura Simples em Tres Momentos (Maximo 3 Minutos):", dy: -18 },
      { font: "/F2", size: 9, text: "1. Como era minha vida antes de conhecer e me render ao senhorio de Cristo (o vazio do ego).", dy: -14 },
      { font: "/F2", size: 9, text: "2. Como compreendi o Evangelho da graca, o arrependimento e a cruz do Salvador.", dy: -14 },
      { font: "/F2", size: 9, text: "3. A paz, a vida em familia com a igreja e a transformacao que Jesus opera hoje.", dy: -14 },

      { font: "/F1", size: 11, text: "Alvos de Oracao por Pessoas Especificas (Fazer Lista):", dy: -24 },
      { font: "/F2", size: 10, text: "1. Nome: ________________________________  Relacionamento: __________________________", dy: -18 },
      { font: "/F2", size: 10, text: "2. Nome: ________________________________  Relacionamento: __________________________", dy: -16 },
      { font: "/F2", size: 10, text: "3. Nome: ________________________________  Relacionamento: __________________________", dy: -16 },

      { font: "/F1", size: 11, text: "Acoes Praticas desta Semana:", dy: -24 },
      { font: "/F2", size: 9, text: "[  ] Convidar uma das pessoas acima para um cafe ou almoco despretensioso.", dy: -16 },
      { font: "/F2", size: 9, text: "[  ] Servir concretamente em uma necessidade pratica ou financeira conhecida.", dy: -15 },
      { font: "/F2", size: 9, text: "[  ] Apresentar Jesus de forma relacional, sem religiosidade ou termos complicados.", dy: -15 },

      { font: "/F3", size: 8, text: "Pagina 2 de 2  *  Sacerdocio Universal de Todos os Santos  *  Igreja em BH", dy: -60 }
    ]
  }
]);
fs.writeFileSync(path.join(documentsDir, "caderno-apoio-evangelismo-natural.pdf"), doc3);

// =========================================================================
// 4. Apostila Completa: Panorama de Atos dos Apostolos
// =========================================================================
const doc4 = buildMultiPagePdf([
  {
    lines: [
      { font: "/F1", size: 9, text: "IGREJA EM BELO HORIZONTE  *  ACERVO BIBLICO E DOUTRINARIO", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 18, text: "Apostila Completa: Panorama de Atos dos Apostolos", dy: -28 },
      { font: "/F2", size: 11, text: "O Padrao do Espirito Santo para a Vida e Estrutura da Igreja Local", dy: -18 },
      { font: "/F3", size: 9, text: "Texto-base: Livro de Atos dos Apostolos (Capitulos 1 a 28)", dy: -20 },
      { font: "/F2", size: 8, text: "===================================================================================================================", dy: -14 },

      { font: "/F1", size: 12, text: "1. O Derramamento do Espirito e o Nascimento da Igreja (Atos 2)", dy: -22 },
      { font: "/F2", size: 10, text: "A Igreja do Senhor nao nasceu como uma organizacao humana ou clube corporativo.", dy: -16 },
      { font: "/F2", size: 10, text: "Ela nasceu pelo fogo do Espirito Santo, habitando em homens e mulheres regenerados.", dy: -14 },
      { font: "/F2", size: 10, text: "A caracteristica imediata foi comunhao organica, partilha voluntaria de bens e temor do Senhor.", dy: -14 },

      { font: "/F1", size: 12, text: "2. Os Quatro Pilares de Atos 2:42", dy: -22 },
      { font: "/F2", size: 10, text: "'E perseveravam na doutrina dos apostolos, e na comunhao, e no partir do pao, e nas oracoes.'", dy: -16 },
      { font: "/F2", size: 10, text: "- Doutrina dos Apostolos: Ensino centrado em Cristo, Seu Reino e Seus mandamentos.", dy: -14 },
      { font: "/F2", size: 10, text: "- Comunhao (Koinonia): Vida compartilhada com profundidade, sem individualismos.", dy: -14 },
      { font: "/F2", size: 10, text: "- Partir do Pao: Memorial de Cristo celebrado nas casas com simplicidade e alegria.", dy: -14 },
      { font: "/F2", size: 10, text: "- Oracoes: Dependencia continua do Pai e intercessao perseverante.", dy: -14 },

      { font: "/F1", size: 12, text: "3. Publicamente e nas Casas (Atos 20:20)", dy: -22 },
      { font: "/F2", size: 10, text: "Paulo declarou que jamais deixou de pregar nada util, ensinando publicamente e de casa em casa.", dy: -16 },
      { font: "/F2", size: 10, text: "Esse duplo ambiente preserva a forca coletiva e o pastoreio intimo dos discipulos.", dy: -14 },

      { font: "/F3", size: 8, text: "Pagina 1 de 2  *  Panorama de Atos dos Apostolos  *  Igreja em BH", dy: -60 }
    ]
  },
  {
    lines: [
      { font: "/F1", size: 9, text: "ESTUDO BIBLICO E AUTOAVALIACAO COMUNITARIA", dy: 0 },
      { font: "/F2", size: 8, text: "-------------------------------------------------------------------------------------------------------------------", dy: -12 },
      { font: "/F1", size: 13, text: "Comparativo entre o Modelo Apostolico e as Religiosidades Modernas", dy: -24 },

      { font: "/F1", size: 10, text: "A. Local da Vida Crista", dy: -18 },
      { font: "/F2", size: 9, text: "Modelo do NT: Os crentes sao o templo vivo; reunem-se nos lares e nas ruas de forma descentralizada.", dy: -14 },
      { font: "/F2", size: 9, text: "Desvio Religioso: Templismo, dependencia de predios monumentais e cultos semanais passivos.", dy: -14 },

      { font: "/F1", size: 10, text: "B. Lideranca e Sacerdocio", dy: -20 },
      { font: "/F2", size: 9, text: "Modelo do NT: Todos os santos sao sacerdotes; presbiteros equipam o Corpo para o servico mutuo.", dy: -14 },
      { font: "/F2", size: 9, text: "Desvio Religioso: Divisao clero/leigo, centralizacao em lideres-estrela e plateias silenciosas.", dy: -14 },

      { font: "/F1", size: 10, text: "C. Edificacao", dy: -20 },
      { font: "/F2", size: 9, text: "Modelo do NT: Juntas e ligamentos, confissao mutua, exortacao diaria e amor fraternal comprovado.", dy: -14 },
      { font: "/F2", size: 9, text: "Desvio Religioso: Consumismo espiritual, busca de bencaos pessoais sem compromisso relacional.", dy: -14 },

      { font: "/F1", size: 11, text: "Questoes para Meditacao:", dy: -24 },
      { font: "/F2", size: 10, text: "1. O que impede nossa igreja na cidade de viver com o mesmo fervor de Atos 2?", dy: -16 },
      { font: "/F2", size: 10, text: "2. Como posso cooperar concretamente na edificacao de outros irmaos esta semana?", dy: -16 },

      { font: "/F3", size: 8, text: "Pagina 2 de 2  *  Igreja em Belo Horizonte  *  Atos 2:42", dy: -60 }
    ]
  }
]);
fs.writeFileSync(path.join(documentsDir, "apostila-atos-dos-apostolos.pdf"), doc4);

console.log("All 4 multi-page study PDFs created successfully in public/documents!");
