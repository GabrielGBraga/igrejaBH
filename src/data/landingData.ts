/**
 * @file landingData.ts
 * @description Dataset for dynamic landing page:
 * - Daily rotating catechesis/scriptures (Propósito Eterno, Sacerdócio Universal, Juntas e Ligamentos)
 * - Initial/fallback news, ministrações, and articles matching the initial design mockup
 * - Recurring calendar events and rhythms of the church in Belo Horizonte
 */

export interface DailyVerse {
  quote: string
  reference: string
  theme: string
  reflection?: string
}

export interface NewsHighlight {
  id: string
  type: "video" | "article" | "event" | "mission"
  title: string
  categoryTitle?: string
  speakerOrAuthor?: string
  dateLabel: string
  duration?: string
  description: string
  badgeText: string
  tags: string[]
  imageUrl: string
  videoUrl?: string
  linkUrl: string
}

export interface AgendaEvent {
  id: string
  day: number
  dayEnd?: number
  month: number // 1-12
  year: number
  title: string
  type: "geral" | "setor" | "jovens" | "casais" | "retiro" | "caseiro"
  location?: string
  isHighlight?: boolean
  link?: string
}

export interface TeachingModule {
  id: string
  title: string
  description: string
  iconName: "book" | "mic" | "fileText" | "graduationCap"
  buttonText: string
  badgeText?: string
  isLocked?: boolean
  link: string
  bgPattern: string
}

// ==========================================
// 1. CATEQUESE DO DIA (ROTAÇÃO DIÁRIA)
// ==========================================
export const DAILY_CATECHESIS: DailyVerse[] = [
  {
    quote:
      "Porquanto aos que de antemão conheceu, também os predestinou para serem conformes à imagem de seu Filho, a fim de que Ele seja o primogênito entre muitos irmãos.",
    reference: "Romanos 8:29",
    theme: "O Propósito Eterno",
    reflection:
      "O propósito de Deus antes da fundação do mundo não era apenas salvar o homem do pecado, mas formar uma grande família de muitos filhos que expressem o caráter e a semelhança de Jesus Cristo.",
  },
  {
    quote:
      "Vós, porém, sois raça eleita, sacerdócio real, nação santa, povo de propriedade exclusiva de Deus, a fim de proclamardes as virtudes daquele que vos chamou das trevas para a sua maravilhosa luz.",
    reference: "1 Pedro 2:9",
    theme: "Sacerdócio Universal",
    reflection:
      "Não há clero nem leigos no Corpo de Cristo. Cada discípulo é constituído sacerdote para servir a Deus e edificar os irmãos no cotidiano da vida.",
  },
  {
    quote:
      "De quem todo o corpo, bem ajustado e consolidado pelo auxílio de todas as juntas, segundo a justa cooperação de cada parte, efetua o seu próprio crescimento para a edificação de si mesmo no amor.",
    reference: "Efésios 4:16",
    theme: "Juntas e Ligamentos",
    reflection:
      "O crescimento espiritual genuíno não acontece em isolamento ou assistindo a sermões passivamente, mas pela vida partilhada e relacionamentos profundos de discipulado.",
  },
  {
    quote:
      "E todos os dias, no templo e de casa em casa, não cessavam de ensinar e de pregar a Jesus, o Cristo.",
    reference: "Atos 5:42",
    theme: "Nas Casas e nas Ruas",
    reflection:
      "A igreja são as pessoas salvas, não quatro paredes. Nos reunimos nas casas para comunhão e treinamento, e vamos às ruas proclamar o Evangelho do Reino.",
  },
  {
    quote:
      "Nisto é glorificado meu Pai: que deis muito fruto; e assim vos tornareis meus discípulos.",
    reference: "João 15:8",
    theme: "Evangelismo e Frutos",
    reflection:
      "Dar fruto é reproduzir a vida de Cristo em outros. O amor genuíno por Jesus se expressa em acolher pessoas e gerar novos discípulos.",
  },
  {
    quote:
      "Rogo-vos, irmãos, pelo nome de nosso Senhor Jesus Cristo, que faleis todos a mesma coisa e que não haja entre vós divisões; antes, sejais inteiramente unidos, na mesma disposição mental e no mesmo parecer.",
    reference: "1 Coríntios 1:10",
    theme: "Unidade do Corpo Único",
    reflection:
      "Cristo não tem várias igrejas ou marcas concorrentes em Belo Horizonte. Seu Corpo é um só, e nos reconhecemos como irmãos de todos os que foram lavados pelo sangue do Cordeiro.",
  },
  {
    quote:
      "E perseveravam na doutrina dos apóstolos e na comunhão, no partir do pão e nas orações.",
    reference: "Atos 2:42",
    theme: "Vida Comum",
    reflection:
      "A vida da igreja primitiva era simples e contínua: ensino das ordens do Senhor, partir o pão ao redor da mesa, orações mútuas e cuidado recíproco.",
  },
]

/**
 * Retorna o versículo do dia baseado no dia do ano atual (1 a 365)
 */
export function getTodayCatechesis(): DailyVerse {
  const now = new Date()
  const start = new Date(now.getFullYear(), 0, 0)
  const diff = now.getTime() - start.getTime()
  const oneDay = 1000 * 60 * 60 * 24
  const dayOfYear = Math.floor(diff / oneDay)

  const index = Math.abs(dayOfYear) % DAILY_CATECHESIS.length
  return DAILY_CATECHESIS[index]
}

/**
 * Extrai o ID do vídeo do YouTube a partir de qualquer formato de URL
 */
export function getYoutubeVideoId(url?: string): string | null {
  if (!url) return null
  const match = url.match(/(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|embed\/|v\/|shorts\/))([\w-]{11})/)
  return match ? match[1] : null
}

/**
 * Retorna a thumbnail real oficial do YouTube em alta definição (hqdefault / maxresdefault)
 */
export function getYoutubeThumbnail(url?: string): string {
  const videoId = getYoutubeVideoId(url)
  if (videoId) {
    return `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`
  }
  return "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Belo_Horizonte_view_081610.jpg/1920px-Belo_Horizonte_view_081610.jpg"
}

// ==========================================
// 2. DESTAQUES DE NOTÍCIAS & MÍDIA
// ==========================================
export const FALLBACK_FEATURED_VIDEO: NewsHighlight = {
  id: "video-ressurreicao-2026",
  type: "video",
  title: "A ESPERANÇA DA RESSURREIÇÃO",
  categoryTitle: "Nova mensagem publicada",
  speakerOrAuthor: "Reginaldo Moraes",
  dateLabel: "05/08/2026",
  duration: "1:00:21",
  description:
    "Confira a mensagem ministrada por Reginaldo Moraes no canal oficial dos Discípulos em Belo Horizonte, abordando os fundamentos da fé a respeito da Ressurreição de Jesus e a viva esperança.",
  badgeText: "Vídeo Oficial",
  tags: ["#Fundamentos", "#Esperança", "#EncontroGeral"],
  imageUrl: "https://i.ytimg.com/vi/UXNHb2KRLJo/maxresdefault.jpg",
  videoUrl: "https://www.youtube.com/watch?v=UXNHb2KRLJo",
  linkUrl: "#video-player",
}

export const FALLBACK_NEWS_CARDS: NewsHighlight[] = [
  {
    id: "art-juntas-ligamentos",
    type: "article",
    title: "Novo artigo publicado: Juntas e Ligamentos no corpo",
    description:
      "A edificação e o funcionamento de cada junta no Corpo de Cristo. Entenda como o discipulado 'vida na vida' sustenta o crescimento orgânico da igreja.",
    dateLabel: "Outubro 2026",
    badgeText: "Artigo",
    tags: ["#Edificação", "#Vida Comum"],
    imageUrl:
      "https://images.unsplash.com/photo-1499209974431-9dddcece7f88?q=80&w=800&auto=format&fit=crop",
    linkUrl: "/ensinos?tab=artigos",
  },
  {
    id: "ret-solteiros-2027",
    type: "event",
    title: "Retiro de Solteiros 2027 — Inscrições abertas",
    description:
      "Um tempo de comunhão, santidade e busca pelo Senhor. Vagas limitadas para discípulos solteiros da Grande BH e regiões metropolitanas.",
    dateLabel: "Carnaval 2027",
    badgeText: "Inscrições Abertas",
    tags: ["#Retiro", "#Setor", "#Vida Comum"],
    imageUrl:
      "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=800&auto=format&fit=crop",
    linkUrl: "/eventos",
  },
  {
    id: "mis-para-2026",
    type: "mission",
    title: "Missão Pará — confira o que Deus está fazendo",
    description:
      "Acompanhe o impacto de nosso envio aos lugares necessitados e a formação de novos discípulos no norte do país.",
    dateLabel: "Relatório de Missão",
    badgeText: "Missões",
    tags: ["#Missões", "#Evangelismo"],
    imageUrl:
      "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=800&auto=format&fit=crop",
    linkUrl: "/ensinos?tab=artigos",
  },
]

// ==========================================
// 3. AGENDA & EVENTOS DO MÊS (ALINHADOS COM O BANCO DE DADOS)
// ==========================================
export const DEFAULT_MONTHLY_EVENTS: AgendaEvent[] = [
  {
    id: "4faf45cb-c431-48f6-9d3f-598fbe9e5bcc",
    day: 10,
    dayEnd: 12,
    month: 10,
    year: 2026,
    title: "Retiro de Solteiros e Jovens 2026",
    type: "retiro",
    location: "Sítio das Palmeiras, Santa Luzia, MG",
    isHighlight: true,
  },
  {
    id: "fdc1c69d-e0f5-480f-8586-3c7cfeaa6b2b",
    day: 24,
    month: 10,
    year: 2026,
    title: "Comunhão da Igreja no Parque Municipal",
    type: "geral",
    location: "Parque Municipal - Centro, Belo Horizonte",
    isHighlight: true,
  },
  {
    id: "98e5662e-1b59-47a5-b345-f12bfad59abe",
    day: 1,
    month: 11,
    year: 2026,
    title: "Oração e Comunhão ao Redor da Lagoa da Pampulha",
    type: "geral",
    location: "Praça da Pampulha, Belo Horizonte",
    isHighlight: false,
  },
  {
    id: "b2c3d4e5-f6a7-48b9-c0d1-223344556677",
    day: 20,
    dayEnd: 22,
    month: 11,
    year: 2026,
    title: "Encontro Metropolitano de Casais nas Casas 2026",
    type: "casais",
    location: "Pousada Morada do Sol, Nova Lima, MG",
    isHighlight: true,
  },
]

// ==========================================
// 4. MÓDULOS DE ENSINOS
// ==========================================
export const TEACHING_MODULES: TeachingModule[] = [
  {
    id: "mod-apostilas",
    title: "Apostilas",
    description:
      "Cadernos temáticos de formação bíblica, fundamentos da fé e manuais de discipulado prático para leitura livre.",
    iconName: "book",
    buttonText: "Acessar",
    badgeText: "Acesso Livre",
    isLocked: false,
    link: "/ensinos?tab=apostilas",
    bgPattern: "from-emerald-950/20 to-emerald-900/10",
  },
  {
    id: "mod-ministracoes",
    title: "Ministrações",
    description:
      "Áudios e vídeos de mensagens gravadas nos Encontros Gerais, retiros e palestras de edificação comunitária.",
    iconName: "mic",
    buttonText: "Acessar",
    badgeText: "Acesso Livre",
    isLocked: false,
    link: "/ensinos?tab=ministracoes",
    bgPattern: "from-amber-950/20 to-amber-900/10",
  },
  {
    id: "mod-artigos",
    title: "Artigos",
    description:
      "Textos reflexivos, estudos bíblicos pontuais e testemunhos da vida diária da igreja de casa em casa.",
    iconName: "fileText",
    buttonText: "Ver mais",
    badgeText: "Acesso Livre",
    isLocked: false,
    link: "/ensinos?tab=artigos",
    bgPattern: "from-teal-950/20 to-teal-900/10",
  },
  {
    id: "mod-trilhas",
    title: "Trilhas de Estudo",
    description:
      "Jornadas estruturadas passo a passo com anotações e progresso de aprendizado para caminhar no discipulado.",
    iconName: "graduationCap",
    buttonText: "Acessar",
    badgeText: "Apenas para usuários logados",
    isLocked: true,
    link: "/entrar",
    bgPattern: "from-zinc-900/30 to-zinc-800/10",
  },
]
