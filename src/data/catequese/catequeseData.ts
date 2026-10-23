export interface CatequeseVerse {
  reference: string;
  url?: string;
  text: string;
  label?: string;
}

export interface CatequeseQA {
  question?: string;
  answer: string;
  label?: string;
}

export interface CatequeseItem {
  id: string;
  trackId: "proposito-eterno" | "principios-elementares";
  trackTitle: string;
  sectionTitle: string;
  lessonNumber: number;
  lessonTitle: string;
  qaList: CatequeseQA[];
  verses: CatequeseVerse[];
  tags: string[];
}

export const CATEQUESE_ITEMS: CatequeseItem[] = [
  // ==========================================
  // O PROPÓSITO ETERNO DE DEUS (16 itens)
  // ==========================================
  {
    id: "pe-01",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O Propósito Eterno de Deus",
    lessonNumber: 1,
    lessonTitle: "O propósito de Deus ao criar o homem",
    qaList: [
      {
        question: "Qual o propósito de Deus quando criou o homem?",
        answer: "Deus queria uma família de homens semelhantes a Ele.",
      },
    ],
    verses: [
      {
        reference: "Gn 1:26 ARA",
        url: "https://www.bible.com/bible/1608/GEN.1.26",
        text: "Também disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; tenha ele domínio sobre os peixes do mar, sobre as aves dos céus, sobre os animais domésticos, sobre toda a terra e sobre todos os répteis que rastejam pela terra.",
      },
    ],
    tags: ["proposito-eterno", "criacao", "familia-de-deus"],
  },
  {
    id: "pe-02",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O Propósito Eterno de Deus",
    lessonNumber: 2,
    lessonTitle: "O que aconteceu quando o homem pecou?",
    qaList: [
      {
        question: "O que aconteceu quando o homem pecou?",
        answer: "O homem se tornou inútil para o propósito de Deus.",
      },
      {
        question: "Deus desistiu do seu propósito por causa do pecado?",
        answer: "Não. Deus não desistiu do seu propósito.",
      },
    ],
    verses: [
      {
        reference: "Rm 3:12 ARA",
        url: "https://www.bible.com/bible/1608/ROM.3.12",
        text: "Todos se extraviaram, à uma se fizeram inúteis; não há quem faça o bem, não há nem um sequer.",
      },
    ],
    tags: ["proposito-eterno", "queda", "fidelidade-de-deus"],
  },
  {
    id: "pe-03",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O Propósito Eterno de Deus",
    lessonNumber: 3,
    lessonTitle: "O que Deus fez para realizar o seu propósito?",
    qaList: [
      {
        question: "Se o homem se tornou inútil, como Deus tem esperança de realizar o Seu propósito?",
        answer: "Ele nos dá uma nova vida em Cristo. A esperança de Deus é a vida de Cristo em nós.",
      },
    ],
    verses: [
      {
        reference: "2Co 5:17 ARA",
        url: "https://www.bible.com/bible/1608/2CO.5.17",
        text: "E, assim, se alguém está em Cristo, é nova criatura; as coisas antigas já passaram; eis que se fizeram novas.",
      },
      {
        reference: "Cl 1:27 ARA",
        url: "https://www.bible.com/bible/1608/COL.1.27",
        text: "Aos quais Deus quis dar a conhecer qual seja a riqueza da glória deste mistério entre os gentios, isto é, Cristo em vós, a esperança da glória.",
      },
    ],
    tags: ["proposito-eterno", "nova-criatura", "vida-de-cristo"],
  },
  {
    id: "pe-04",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O Propósito Eterno de Deus",
    lessonNumber: 4,
    lessonTitle: "Qual o propósito de Deus hoje?",
    qaList: [
      {
        question: "Qual é o propósito de Deus hoje?",
        answer: "Deus quer uma família de muitos filhos semelhantes a Jesus.",
      },
    ],
    verses: [
      {
        reference: "Rm 8:28-29 ARA",
        url: "https://www.bible.com/bible/1608/ROM.8.28-29",
        text: "Sabemos que todas as coisas cooperam para o bem daqueles que amam a Deus, daqueles que são chamados segundo o seu propósito. Porquanto aos que de antemão conheceu, também os predestinou para serem conformes à imagem de seu Filho, a fim de que ele seja o primogênito entre muitos irmãos.",
      },
      {
        reference: "Ef 4:13 ARA",
        url: "https://www.bible.com/bible/1608/EPH.4.13",
        text: "Até que todos cheguemos à unidade da fé e do pleno conhecimento do Filho de Deus, à perfeita varonilidade, à medida da estatura da plenitude de Cristo.",
      },
    ],
    tags: ["proposito-eterno", "familia-de-filhos", "imagem-do-filho"],
  },
  {
    id: "pe-05",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O Propósito Eterno de Deus",
    lessonNumber: 5,
    lessonTitle: "Devemos ser como Jesus",
    qaList: [
      {
        question: "Mas o propósito de Deus não é a salvação do homem?",
        answer: "Não, a salvação é o meio para alcançar o propósito. Seu propósito é que sejamos semelhantes a Jesus.",
      },
      {
        question: "Em que devemos ser como Jesus?",
        answer: "Ser mansos e humildes como Jesus; ser santos como Jesus; servir como Jesus; pregar ao mundo como Jesus; perdoar como Jesus; amar como Jesus.",
      },
    ],
    verses: [
      {
        reference: "1Jo 2:6 ARA",
        url: "https://www.bible.com/bible/1608/1JN.2.6",
        text: "Aquele que diz que permanece nele, esse deve também andar assim como ele andou.",
      },
      {
        reference: "Mt 11:29 ARA",
        url: "https://www.bible.com/bible/1608/MAT.11.29",
        text: "Tomai sobre vós o meu jugo e aprendei de mim, porque sou manso e humilde de coração; e achareis descanso para a vossa alma.",
        label: "Mansos e humildes como Jesus",
      },
      {
        reference: "1Pe 1:15 ARA",
        url: "https://www.bible.com/bible/1608/1PE.1.15",
        text: "Pelo contrário, segundo é santo aquele que vos chamou, tornai-vos santos também vós mesmos em todo o vosso procedimento.",
        label: "Ser santos como Jesus",
      },
      {
        reference: "Jo 13:14 ARA",
        url: "https://www.bible.com/bible/1608/JHN.13.4",
        text: "Ora, se eu, sendo o Senhor e o Mestre, vos lavei os pés, também vós deveis lavar os pés uns dos outros.",
        label: "Servir como Jesus",
      },
      {
        reference: "Jo 17:18 ARA",
        url: "https://www.bible.com/bible/1608/JHN.17.18",
        text: "Assim como tu me enviaste ao mundo, também eu os enviei ao mundo.",
        label: "Pregar ao mundo como Jesus",
      },
      {
        reference: "Cl 3:13 ARA",
        url: "https://www.bible.com/bible/1608/COL.3.13",
        text: "Suportai-vos uns aos outros, perdoai-vos mutuamente, caso alguém tenha motivo de queixa contra outrem. Assim como o Senhor vos perdoou, assim também perdoai vós.",
        label: "Perdoar como Jesus",
      },
      {
        reference: "Jo 13:34 ARA",
        url: "https://www.bible.com/bible/1608/JHN.13.34",
        text: "Novo mandamento vos dou: que vos ameis uns aos outros; assim como eu vos amei, que também vos ameis uns aos outros.",
        label: "Amar como Jesus",
      },
    ],
    tags: ["proposito-eterno", "semelhanca-com-cristo", "santidade", "amor"],
  },
  {
    id: "pe-06",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 6,
    lessonTitle: "Quem são os sacerdotes?",
    qaList: [
      {
        question: "Quem são os sacerdotes na igreja?",
        answer: "Todos os santos são sacerdotes.",
      },
    ],
    verses: [
      {
        reference: "1Pe 2:9 ARA",
        url: "https://www.bible.com/bible/1608/1PE.2.9",
        text: "Vós, porém, sois raça eleita, sacerdócio real, nação santa, povo de propriedade exclusiva de Deus, a fim de proclamardes as virtudes daquele que vos chamou das trevas para a sua maravilhosa luz.",
      },
    ],
    tags: ["servico-da-igreja", "sacerdocio-universal", "todos-os-santos"],
  },
  {
    id: "pe-07",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 7,
    lessonTitle: "Quem edifica a Igreja?",
    qaList: [
      {
        question: "Quem edifica o corpo de Cristo?",
        answer: "O corpo de Cristo edifica o corpo de Cristo.",
      },
    ],
    verses: [
      {
        reference: "Ef 4:11-12 ARA",
        url: "https://www.bible.com/bible/1608/EPH.4.11-12",
        text: "E ele mesmo concedeu uns para apóstolos, outros para profetas, outros para evangelistas e outros para pastores e mestres, com vistas ao aperfeiçoamento dos santos para o desempenho do seu serviço, para a edificação do corpo de Cristo.",
      },
    ],
    tags: ["servico-da-igreja", "edificacao-mutua", "corpo-de-cristo"],
  },
  {
    id: "pe-08",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O ministério de testemunhas",
    lessonNumber: 8,
    lessonTitle: "O ministério de testemunhas (1ª parte)",
    qaList: [
      {
        question: "Como iniciamos o serviço de fazer discípulos?",
        answer: "Sendo testemunhas e proclamadores.",
      },
    ],
    verses: [
      {
        reference: "At 1:8 ARA",
        url: "https://www.bible.com/bible/1608/ACT.1.8",
        text: "Mas recebereis poder, ao descer sobre vós o Espírito Santo, e sereis minhas testemunhas tanto em Jerusalém como em toda a Judeia e Samaria e até aos confins da terra.",
      },
    ],
    tags: ["testemunhas", "evangelho-do-reino", "fazer-discipulos"],
  },
  {
    id: "pe-09",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O ministério de testemunhas",
    lessonNumber: 9,
    lessonTitle: "O ministério de testemunhas (2ª parte)",
    qaList: [
      {
        question: "Como iniciamos o serviço de fazer discípulos?",
        answer: "Sendo testemunhas e proclamadores.",
      },
    ],
    verses: [
      {
        reference: "At 1:8 ARA",
        url: "https://www.bible.com/bible/1608/ACT.1.8",
        text: "Mas recebereis poder, ao descer sobre vós o Espírito Santo, e sereis minhas testemunhas tanto em Jerusalém como em toda a Judeia e Samaria e até aos confins da terra.",
      },
    ],
    tags: ["testemunhas", "espirito-santo", "proclamacao"],
  },
  {
    id: "pe-10",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 10,
    lessonTitle: "O ministério das juntas e ligamentos",
    qaList: [
      {
        question: "O que são juntas e ligamentos no corpo de Cristo?",
        answer: "Juntas e ligamentos no corpo de Cristo são relações fortes e resistentes entre os seus membros.",
      },
      {
        question: "Para que servem as juntas e ligamentos?",
        answer: "Para unir, alimentar e edificar o corpo de Cristo.",
      },
    ],
    verses: [
      {
        reference: "Ef 4:15-16 ARA",
        url: "https://www.bible.com/bible/1608/EPH.4.15-16",
        text: "Mas, seguindo a verdade em amor, cresçamos em tudo naquele que é a cabeça, Cristo, de quem todo o corpo, bem-ajustado e consolidado pelo auxílio de toda junta, segundo a justa cooperação de cada parte, efetua o seu próprio aumento para a edificação de si mesmo em amor.",
      },
    ],
    tags: ["juntas-e-ligamentos", "relacionamentos", "edificacao"],
  },
  {
    id: "pe-11",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 11,
    lessonTitle: "Juntas e ligamentos de discipulado (1ª parte)",
    qaList: [
      {
        question: "Qual é a função do discipulador?",
        answer: "Ensinar a guardar todas as coisas que Jesus ordenou.",
      },
    ],
    verses: [
      {
        reference: "Mt 28:19-20 ARA",
        url: "https://www.bible.com/bible/1608/MAT.28.19-20",
        text: "Ide, portanto, fazei discípulos de todas as nações, batizando-os em nome do Pai, e do Filho, e do Espírito Santo; ensinando-os a guardar todas as coisas que vos tenho ordenado. E eis que estou convosco todos os dias até à consumação do século.",
      },
    ],
    tags: ["discipulado", "grande-comissao", "ordens-de-jesus"],
  },
  {
    id: "pe-12",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 12,
    lessonTitle: "Juntas e ligamentos de discipulado (2ª parte)",
    qaList: [
      {
        question: "O que é necessário para ser discipulado?",
        answer: "Ser manso, humilde e submisso.",
      },
    ],
    verses: [
      {
        reference: "Ef 5:21 ARA",
        url: "https://www.bible.com/bible/1608/EPH.5.21",
        text: "Sujeitando-vos uns aos outros no temor de Cristo.",
      },
    ],
    tags: ["discipulado", "humildade", "submissao-mutua"],
  },
  {
    id: "pe-13",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 13,
    lessonTitle: "Juntas e ligamentos de companheirismo (1ª parte)",
    qaList: [
      {
        question: "Porque o discipulado e o companheirismo são tão importantes?",
        answer: "Porque unem o corpo por juntas e ligamentos.",
      },
      {
        question: "Quais são as principais atitudes no companheirismo?",
        answer: "Amor, submissão, transparência e perdão.",
      },
    ],
    verses: [
      {
        reference: "Jo 13:34 ARA",
        url: "https://www.bible.com/bible/1608/JHN.13.34",
        text: "Novo mandamento vos dou: que vos ameis uns aos outros; assim como eu vos amei, que também vos ameis uns aos outros.",
      },
    ],
    tags: ["companheirismo", "amor", "transparencia", "perdao"],
  },
  {
    id: "pe-14",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 14,
    lessonTitle: "Juntas e ligamentos de companheirismo (2ª parte)",
    qaList: [
      {
        question: "Quais são as principais atividades no companheirismo?",
        answer: "Orar, aconselhar, servir e fazer discípulos.",
      },
      {
        question: "Qual é o fruto de tudo isto?",
        answer: "A edificação do corpo em amor.",
      },
    ],
    verses: [
      {
        reference: "Cl 3:16 ARA",
        url: "https://www.bible.com/bible/1608/COL.3.16",
        text: "Habite, ricamente, em vós a palavra de Cristo; instruí-vos e aconselhai-vos mutuamente em toda a sabedoria, louvando a Deus, com salmos, e hinos, e cânticos espirituais, com gratidão, em vosso coração.",
      },
    ],
    tags: ["companheirismo", "oracao", "aconselhamento", "fruto"],
  },
  {
    id: "pe-15",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 15,
    lessonTitle: "A necessidade de dar fruto",
    qaList: [
      {
        question: "O que o agricultor exige do ramo?",
        answer: "Todo ramo deve dar frutos.",
      },
      {
        question: "Qual é o fruto que o ramo deve dar?",
        answer: "A multiplicação da vida de Cristo.",
      },
    ],
    verses: [
      {
        reference: "Jo 15:16 ARA",
        url: "https://www.bible.com/bible/1608/JHN.15.16",
        text: "Não fostes vós que me escolhestes a mim; pelo contrário, eu vos escolhi a vós outros e vos designei para que vades e deis fruto, e o vosso fruto permaneça; a fim de que tudo quanto pedirdes ao Pai em meu nome, ele vo-lo conceda.",
      },
    ],
    tags: ["dar-fruto", "multiplicacao", "vida-de-cristo"],
  },
  {
    id: "pe-16",
    trackId: "proposito-eterno",
    trackTitle: "O Propósito Eterno de Deus",
    sectionTitle: "O serviço da Igreja para cumprir o propósito de Deus",
    lessonNumber: 16,
    lessonTitle: "O trabalho nas casas",
    qaList: [
      {
        question: "Qual é o motivo do encontro do grupo caseiro?",
        answer: "A obra do grupo caseiro é o desenvolvimento do serviço dos santos.",
      },
    ],
    verses: [],
    tags: ["igreja-nas-casas", "grupo-caseiro", "servico-dos-santos"],
  },

  // ==========================================
  // PRINCÍPIOS ELEMENTARES (14 itens)
  // ==========================================
  {
    id: "el-01",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 1,
    lessonTitle: "Jesus existia antes de todas as coisas",
    qaList: [
      {
        question: "Quem é Jesus antes da criação de todas as coisas?",
        answer: "Jesus existia antes de todas as coisas. Ele é o Verbo eterno, estava com Deus e era Deus.",
      },
    ],
    verses: [
      {
        reference: "Jo 1:1-3 ARA",
        url: "https://www.bible.com/bible/1608/JHN.1.1-3",
        text: "No princípio era o Verbo, e o Verbo estava com Deus, e o Verbo era Deus. Ele estava no princípio com Deus. Todas as coisas foram feitas por intermédio dele, e, sem ele, nada do que foi feito se fez.",
      },
    ],
    tags: ["vida-de-jesus", "cristologia", "eternidade"],
  },
  {
    id: "el-02",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 2,
    lessonTitle: "Tornou-se homem",
    qaList: [
      {
        question: "Como o Filho de Deus veio ao mundo?",
        answer: "Tornou-se homem. Esvaziou-se a Si mesmo, assumindo a forma de servo e a semelhança de homens.",
      },
    ],
    verses: [
      {
        reference: "Fp 2:5-8 ARA",
        url: "https://www.bible.com/bible/1608/PHP.2.5-8",
        text: "Tende em vós o mesmo sentimento que houve também em Cristo Jesus, pois ele, subsistindo em forma de Deus, não julgou como usurpação o ser igual a Deus; antes, a si mesmo se esvaziou, assumindo a forma de servo, tornando-se em semelhança de homens; e, reconhecido em figura humana, a si mesmo se humilhou, tornando-se obediente até à morte e morte de cruz.",
      },
    ],
    tags: ["vida-de-jesus", "encarnacao", "humildade"],
  },
  {
    id: "el-03",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 3,
    lessonTitle: "Sua vida foi perfeita e irrepreensível",
    qaList: [
      {
        question: "Como foi a vida terrena de Jesus?",
        answer: "Sua vida foi perfeita e irrepreensível. Não cometeu pecado, nem dolo algum se achou em sua boca.",
      },
    ],
    verses: [
      {
        reference: "1Pe 2:22 ARA",
        url: "https://www.bible.com/bible/1608/1PE.2.22",
        text: "O qual não cometeu pecado, nem dolo algum se achou em sua boca.",
      },
    ],
    tags: ["vida-de-jesus", "santidade", "perfeicao"],
  },
  {
    id: "el-04",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 4,
    lessonTitle: "Sua obra foi tremenda e grandiosa",
    qaList: [
      {
        question: "Qual foi o impacto das obras de Jesus?",
        answer: "Sua obra foi tremenda e grandiosa. Ungido com o Espírito Santo e poder, andou por toda parte fazendo o bem e curando os oprimidos.",
      },
    ],
    verses: [
      {
        reference: "At 10:38 ARA",
        url: "https://www.bible.com/bible/1608/ACT.10.38",
        text: "Como Deus ungiu a Jesus de Nazaré com o Espírito Santo e com poder, o qual andou por toda parte, fazendo o bem e curando a todos os oprimidos do diabo, porque Deus era com ele.",
      },
    ],
    tags: ["vida-de-jesus", "obras-de-cristo", "poder-do-espirito"],
  },
  {
    id: "el-05",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 5,
    lessonTitle: "Morreu pelos nossos pecados",
    qaList: [
      {
        question: "Por que Jesus entregou a Sua vida na cruz?",
        answer: "Morreu pelos nossos pecados. Ele foi traspassado pelas nossas transgressões e feito pecado por nós para nos justificar.",
      },
    ],
    verses: [
      {
        reference: "Is 53:5-6 ARA",
        url: "https://www.bible.com/bible/1608/ISA.53.5-6",
        text: "Mas ele foi traspassado pelas nossas transgressões e moído pelas nossas iniquidades; o castigo que nos traz a paz estava sobre ele, e pelas suas pisaduras fomos sarados. Todos nós andávamos desgarrados como ovelhas; cada um se desviava pelo caminho, mas o SENHOR fez cair sobre ele a iniquidade de nós todos.",
      },
      {
        reference: "2Co 5:21 ARA",
        url: "https://www.bible.com/bible/1608/2CO.5.21",
        text: "Aquele que não conheceu pecado, ele o fez pecado por nós; para que, nele, fôssemos feitos justiça de Deus.",
      },
    ],
    tags: ["vida-de-jesus", "cruz", "redencao"],
  },
  {
    id: "el-06",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 6,
    lessonTitle: "Ressuscitou",
    qaList: [
      {
        question: "A morte conseguiu reter a Jesus?",
        answer: "Não! Ele ressuscitou, rompendo os grilhões da morte, pois não era possível que a morte o retivesse.",
      },
    ],
    verses: [
      {
        reference: "At 2:24 ARA",
        url: "https://www.bible.com/bible/1608/ACT.2.24",
        text: "Ao qual, porém, Deus ressuscitou, rompendo os grilhões da morte; porquanto não era possível fosse ele retido por ela.",
      },
    ],
    tags: ["vida-de-jesus", "ressurreicao", "vitoria"],
  },
  {
    id: "el-07",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 7,
    lessonTitle: "Foi exaltado",
    qaList: [
      {
        question: "Qual posição Deus concedeu a Jesus após a ressurreição?",
        answer: "Foi exaltado soberanamente! Deus o fez Senhor e Cristo, dando-lhe o Nome que está acima de todo nome.",
      },
    ],
    verses: [
      {
        reference: "At 2:36 ARA",
        url: "https://www.bible.com/bible/1608/ACT.2.36",
        text: "Esteja absolutamente certa, pois, toda a casa de Israel de que a este Jesus, que vós crucificastes, Deus o fez Senhor e Cristo.",
      },
      {
        reference: "Fp 2:9-11 ARA",
        url: "https://www.bible.com/bible/1608/PHP.2.9-11",
        text: "Pelo que também Deus o exaltou sobremaneira e lhe deu o nome que está acima de todo nome, para que ao nome de Jesus se dobre todo joelho, nos céus, na terra e debaixo da terra, e toda língua confesse que Jesus Cristo é Senhor, para glória de Deus Pai.",
      },
    ],
    tags: ["vida-de-jesus", "senhorio", "exaltacao"],
  },
  {
    id: "el-08",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "8 pontos da vida de Jesus",
    lessonNumber: 8,
    lessonTitle: "Voltará",
    qaList: [
      {
        question: "Qual é a bendita esperança da Igreja a respeito de Jesus?",
        answer: "Ele voltará! O Filho do Homem virá sobre as nuvens do céu com poder e muita glória.",
      },
    ],
    verses: [
      {
        reference: "Mt 24:30 ARA",
        url: "https://www.bible.com/bible/1608/MAT.24.30",
        text: "Então, aparecerá no céu o sinal do Filho do Homem; todos os povos da terra se lamentarão e verão o Filho do Homem vindo sobre as nuvens do céu, com poder e muita glória.",
      },
    ],
    tags: ["vida-de-jesus", "volta-de-cristo", "esperanca"],
  },
  {
    id: "el-09",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "A ordem que Jesus nos deu",
    lessonNumber: 9,
    lessonTitle: "A ordem que Jesus nos deu",
    qaList: [
      {
        question: "O que Jesus nos mandou fazer?",
        answer: "Jesus nos mandou fazer discípulos de todas as nações, ensinando-os a guardar todas as coisas que Ele ordenou.",
      },
    ],
    verses: [
      {
        reference: "Mt 28:18-20 ARA",
        url: "https://www.bible.com/bible/1608/MAT.28.18-20",
        text: "Jesus, aproximando-se, falou-lhes, dizendo: Toda a autoridade me foi dada no céu e na terra. Ide, portanto, fazei discípulos de todas as nações, batizando-os em nome do Pai, e do Filho, e do Espírito Santo; ensinando-os a guardar todas as coisas que vos tenho ordenado. E eis que estou convosco todos os dias até à consumação do século.",
      },
    ],
    tags: ["a-ordem-de-jesus", "fazer-discipulos", "grande-comissao"],
  },
  {
    id: "el-10",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "A ordem que Jesus nos deu",
    lessonNumber: 10,
    lessonTitle: "Do que devemos falar para fazer discípulos",
    qaList: [
      {
        question: "Do que devemos falar para fazer discípulos?",
        answer: "Falar de Jesus e da porta do reino.",
      },
      {
        question: "Qual é a porta do reino?",
        answer: "Arrependimento, Batismo em Cristo e Dom do Espírito Santo.",
      },
      {
        question: "Qual o Caminho do reino?",
        answer: "Guardar todas as coisas que Jesus ordenou.",
      },
    ],
    verses: [
      {
        reference: "At 2:38 ARA",
        url: "https://www.bible.com/bible/1608/ACT.2.38",
        text: "Respondeu-lhes Pedro: Arrependei-vos, e cada um de vós seja batizado em nome de Jesus Cristo para remissão dos vossos pecados, e recebereis o dom do Espírito Santo.",
      },
    ],
    tags: ["porta-do-reino", "arrependimento", "batismo", "espirito-santo"],
  },
  {
    id: "el-11",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "Porta do Reino: Arrependimento",
    lessonNumber: 11,
    lessonTitle: "Arrependimento (Parte 1)",
    qaList: [
      {
        question: "O que é arrependimento?",
        answer: "Arrependimento é uma mudança de atitude interior.",
      },
      {
        question: "Qual a mudança interior que acontece no arrependimento?",
        answer: "Deixar de ser independente para ser dependente de Deus.",
      },
    ],
    verses: [
      {
        reference: "Mc 8:34-36 ARA",
        url: "https://www.bible.com/bible/1608/MRK.8.34-36",
        text: "Então, convocando a multidão e juntamente os seus discípulos, disse-lhes: Se alguém quer vir após mim, a si mesmo se negue, tome a sua cruz e siga-me. Quem quiser, pois, salvar a sua vida perdê-la-á; e quem perder a vida por causa de mim e do evangelho salvá-la-á. Que aproveita ao homem ganhar o mundo inteiro e perder a sua alma?",
      },
    ],
    tags: ["porta-do-reino", "arrependimento", "dependencia-de-deus"],
  },
  {
    id: "el-12",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "Porta do Reino: Arrependimento",
    lessonNumber: 12,
    lessonTitle: "Arrependimento (Parte 2)",
    qaList: [
      {
        question: "O que é necessário para mudar de atitude?",
        answer: "Negar-se a si mesmo, tomar a cruz, perder a vida e renunciar a tudo.",
      },
    ],
    verses: [
      {
        reference: "Lc 14:33 ARA",
        url: "https://www.bible.com/bible/1608/LUK.14.33",
        text: "Assim, pois, todo aquele que dentre vós não renuncia a tudo quanto tem não pode ser meu discípulo.",
      },
    ],
    tags: ["porta-do-reino", "renuncia", "cruz", "discipulado"],
  },
  {
    id: "el-13",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "Porta do Reino: Batismo",
    lessonNumber: 13,
    lessonTitle: "Batismo",
    qaList: [
      {
        question: "O que acontece no batismo?",
        answer: "Somos colocados em Cristo.",
      },
    ],
    verses: [
      {
        reference: "Gl 3:27 ARA",
        url: "https://www.bible.com/bible/1608/GAL.3.27",
        text: "Porque todos quantos fostes batizados em Cristo de Cristo vos revestistes.",
      },
    ],
    tags: ["porta-do-reino", "batismo", "em-cristo"],
  },
  {
    id: "el-14",
    trackId: "principios-elementares",
    trackTitle: "Princípios Elementares",
    sectionTitle: "Porta do Reino: O Dom do Espírito Santo",
    lessonNumber: 14,
    lessonTitle: "O Dom do Espírito Santo",
    qaList: [
      {
        question: "O que acontece no batismo com o Espírito Santo?",
        answer: "Recebemos poder para testemunhar e podemos manifestar os dons.",
      },
    ],
    verses: [
      {
        reference: "At 1:8 ARA",
        url: "https://www.bible.com/bible/1608/ACT.1.8",
        text: "Mas recebereis poder, ao descer sobre vós o Espírito Santo, e sereis minhas testemunhas tanto em Jerusalém como em toda a Judeia e Samaria e até aos confins da terra.",
      },
    ],
    tags: ["porta-do-reino", "espirito-santo", "poder-para-testemunhar"],
  },
];

/**
 * Retorna o índice diário determinístico e pseudo-aleatório baseado na data informada.
 * Garante que todos os discípulos que abrirem o aplicativo no mesmo dia vejam o mesmo conteúdo,
 * rotacionando de forma bem distribuída entre os 30 itens.
 */
export function getDailyCatequeseIndex(date: Date = new Date(), total: number = CATEQUESE_ITEMS.length): number {
  if (total <= 0) return 0;
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();

  // Algoritmo de dispersão inteiro (pseudo-aleatório determinístico por data)
  let seed = year * 372 + month * 31 + day;
  seed = ((seed >> 16) ^ seed) * 0x45d9f3b;
  seed = ((seed >> 16) ^ seed) * 0x45d9f3b;
  seed = (seed >> 16) ^ seed;

  return Math.abs(seed) % total;
}

/**
 * Obtém a lição da catequese correspondente ao dia de hoje (ou à data fornecida).
 */
export function getDailyCatequeseItem(date: Date = new Date()): CatequeseItem {
  const index = getDailyCatequeseIndex(date, CATEQUESE_ITEMS.length);
  return CATEQUESE_ITEMS[index];
}

/**
 * Sorteia um item aleatório diferente do ID atual (para interação no card).
 */
export function getRandomCatequeseItem(excludeId?: string): CatequeseItem {
  const candidates = excludeId
    ? CATEQUESE_ITEMS.filter((item) => item.id !== excludeId)
    : CATEQUESE_ITEMS;
  const randomIndex = Math.floor(Math.random() * candidates.length);
  return candidates[randomIndex] || CATEQUESE_ITEMS[0];
}

/**
 * Localiza um item pelo ID.
 */
export function getCatequeseItemById(id: string): CatequeseItem | undefined {
  return CATEQUESE_ITEMS.find((item) => item.id === id);
}

export interface CatequeseVerseEntry {
  quote: string;
  reference: string;
  theme: string;
  trackTitle: string;
  lessonTitle: string;
  url?: string;
}

/**
 * Retorna todos os versículos bíblicos da catequese da igreja,
 * mapeados com temas limpos (sem anotações editoriais redundantes como "(1ª parte)").
 * Por padrão remove duplicatas idênticas de texto e referência.
 */
export function getAllCatequeseVerses(uniqueOnly = true): CatequeseVerseEntry[] {
  const cleanTheme = (title: string) =>
    title.replace(/\s*\((?:1ª|2ª|Parte)\s*\d*.*?\)/i, "").trim();

  const entries: CatequeseVerseEntry[] = [];
  const seen = new Set<string>();

  for (const item of CATEQUESE_ITEMS) {
    for (const verse of item.verses) {
      const key = `${verse.reference}::${verse.text}`;
      if (uniqueOnly && seen.has(key)) continue;
      seen.add(key);

      entries.push({
        quote: verse.text,
        reference: verse.reference,
        theme: cleanTheme(verse.label || item.lessonTitle),
        trackTitle: item.trackTitle,
        lessonTitle: item.lessonTitle,
        url: verse.url,
      });
    }
  }

  return entries;
}

/**
 * Retorna um versículo aleatório da catequese a cada chamada (ideal para rotação a cada page load / reload).
 */
export function getRandomCatequeseVerse(): CatequeseVerseEntry {
  const all = getAllCatequeseVerses();
  const randomIndex = Math.floor(Math.random() * all.length);
  return all[randomIndex] || all[0];
}

