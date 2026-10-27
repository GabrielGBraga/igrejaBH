/**
 * @file landingData.ts
 * @description Dataset for the public landing page:
 * - Daily rotating scriptures (Propósito Eterno, Sacerdócio Universal, Juntas e Ligamentos)
 * - Fallback ministrações and public updates
 * - Recurring calendar events and teaching categories
 */

import { getRandomCatequeseVerse, type CatequeseVerseEntry } from "@/data/catequese"

export interface NavItem {
  label: string
  href: string
  isRoute?: boolean
}

export const LANDING_NAV_ITEMS: NavItem[] = [
  { label: "Notícias", href: "#noticias" },
  { label: "Agenda", href: "#agenda" },
  { label: "Ensinos", href: "/ensinos", isRoute: true },
  { label: "Quem Somos", href: "#quem-somos" },
  { label: "Nossa Fé", href: "/quem-somos", isRoute: true },
]

export interface LandscapeImage {
  id: string
  title: string
  src: string
  fallbackSrc: string
  alt: string
}

export const BH_LANDSCAPES: LandscapeImage[] = [
  {
    id: "serra-do-curral",
    title: "Serra do Curral & Skyline",
    src: "/images/landscapes/bh-serra-do-curral.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Belo_Horizonte_view_081610.jpg/1920px-Belo_Horizonte_view_081610.jpg",
    alt: "Vista panorâmica da cidade de Belo Horizonte com a Serra do Curral ao fundo",
  },
  {
    id: "praca-do-papa",
    title: "Praça do Papa & Serra das Mangabeiras",
    src: "/images/landscapes/bh-praca-do-papa.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Praca_do_Papa%2C_Belo_Horizonte_%28cropped%292.jpg/1280px-Praca_do_Papa%2C_Belo_Horizonte_%28cropped%292.jpg",
    alt: "Mirante da Praça do Papa com ampla vista panorâmica de Belo Horizonte",
  },
  {
    id: "lagoa-da-pampulha",
    title: "Orla e Lagoa da Pampulha",
    src: "/images/landscapes/bh-lagoa-pampulha.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Panorama_Mineir%C3%A3o_Pampulha_%28cropped%29.jpg/1280px-Panorama_Mineir%C3%A3o_Pampulha_%28cropped%29.jpg",
    alt: "Paisagem panorâmica da Orla da Lagoa da Pampulha",
  },
  {
    id: "panorama-centro",
    title: "Panorama Urbano e Centro de BH",
    src: "/images/landscapes/bh-panorama-centro.jpg",
    fallbackSrc:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Belo_Horizonte%2C_Brasil.jpg/1280px-Belo_Horizonte%2C_Brasil.jpg",
    alt: "Vista do centro urbano e horizonte de Belo Horizonte",
  },
]

export interface DailyVerse {
  quote: string
  reference: string
  theme: string
}

export interface NewsHighlight {
  id: string
  type: "video" | "article" | "event" | "mission"
  title: string
  speakerOrAuthor?: string
  dateLabel: string
  description: string
  badgeText: string
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
  link: string
}

export const REGIONS_BH: string[] = [
  "Barreiro / Oeste (Buritis, Barreiro, Estoril, Gutierrez)",
  "Pampulha / São Gabriel (Ouro Preto, Castelo, Dona Clara)",
  "Centro / Sul (Savassi, Lourdes, Funcionários, Santo Agostinho)",
  "Leste / Nordeste (Santa Inês, Sagrada Família, Cidade Nova)",
  "Noroeste (Padre Eustáquio, Caiçara, Carlos Prates)",
  "Venda Nova (Planalto, Letícia, Mantiqueira, Candelária)",
  "Santa Luzia / Ribeirão das Neves (Cristina, São Benedito)",
  "Contagem (Eldorado, Industrial, Novo Eldorado, Cabral)",
  "Betim (Centro Betim, Jardim Alterosa, PTB, Imbiruçu)",
  "Outra Região da RMBH",
]

// ==========================================
// 1. ESCRITURA DO DIA (ROTAÇÃO DIÁRIA)
// ==========================================
export const DAILY_CATECHESIS: DailyVerse[] = [
  {
    quote:
      "Porquanto aos que de antemão conheceu, também os predestinou para serem conformes à imagem de seu Filho, a fim de que Ele seja o primogênito entre muitos irmãos.",
    reference: "Romanos 8:29",
    theme: "O Propósito Eterno",
  },
  {
    quote:
      "Vós, porém, sois raça eleita, sacerdócio real, nação santa, povo de propriedade exclusiva de Deus, a fim de proclamardes as virtudes daquele que vos chamou das trevas para a sua maravilhosa luz.",
    reference: "1 Pedro 2:9",
    theme: "Sacerdócio Universal",
  },
  {
    quote:
      "De quem todo o corpo, bem ajustado e consolidado pelo auxílio de todas as juntas, segundo a justa cooperação de cada parte, efetua o seu próprio crescimento para a edificação de si mesmo no amor.",
    reference: "Efésios 4:16",
    theme: "Juntas e Ligamentos",
  },
  {
    quote:
      "E todos os dias, no templo e de casa em casa, não cessavam de ensinar e de pregar a Jesus, o Cristo.",
    reference: "Atos 5:42",
    theme: "Nas Casas e nas Ruas",
  },
  {
    quote:
      "Nisto é glorificado meu Pai: que deis muito fruto; e assim vos tornareis meus discípulos.",
    reference: "João 15:8",
    theme: "Evangelismo e Frutos",
  },
  {
    quote:
      "Rogo-vos, irmãos, pelo nome de nosso Senhor Jesus Cristo, que faleis todos a mesma coisa e que não haja entre vós divisões; antes, sejais inteiramente unidos, na mesma disposição mental e no mesmo parecer.",
    reference: "1 Coríntios 1:10",
    theme: "Unidade do Corpo Único",
  },
  {
    quote:
      "E perseveravam na doutrina dos apóstolos e na comunhão, no partir do pão e nas orações.",
    reference: "Atos 2:42",
    theme: "Vida Comum",
  },
]

/**
 * Retorna um versículo da catequese sorteado a cada carregamento da página (load / reload)
 */
export function getTodayCatechesis(): DailyVerse {
  return getRandomCatequeseVerse()
}

export { getRandomCatequeseVerse, type CatequeseVerseEntry }


/**
 * Extrai o ID do vídeo do YouTube a partir de qualquer formato de URL
 */
export function getYoutubeVideoId(url?: string): string | null {
  if (!url) return null
  const match = url.match(/(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|embed\/|v\/|shorts\/))([\w-]{11})/)
  return match ? match[1] : null
}

/**
 * Retorna a thumbnail oficial do YouTube em alta definição
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
  title: "A Esperança da Ressurreição",
  speakerOrAuthor: "Reginaldo Moraes",
  dateLabel: "05/08/2026",
  description:
    "Mensagem compartilhada entre os discípulos em Belo Horizonte sobre os fundamentos da fé a respeito da ressurreição de Jesus e a viva esperança da igreja.",
  badgeText: "Ministração",
  imageUrl: "https://i.ytimg.com/vi/UXNHb2KRLJo/maxresdefault.jpg",
  videoUrl: "https://www.youtube.com/watch?v=UXNHb2KRLJo",
  linkUrl: "#video-player",
}

export const FALLBACK_NEWS_CARDS: NewsHighlight[] = [
  {
    id: "art-juntas-ligamentos",
    type: "article",
    title: "Juntas e Ligamentos no Corpo de Cristo",
    description:
      "A edificação e o funcionamento de cada junta no Corpo. Entenda como o discipulado 'vida na vida' sustenta o crescimento orgânico da igreja.",
    dateLabel: "Outubro 2026",
    badgeText: "Estudo",
    imageUrl:
      "https://images.unsplash.com/photo-1499209974431-9dddcece7f88?q=80&w=800&auto=format&fit=crop",
    linkUrl: "/ensinos?tab=artigos",
  },
  {
    id: "ret-solteiros-2027",
    type: "event",
    title: "Retiro de Solteiros e Jovens — Comunhão e Ensino",
    description:
      "Um tempo de comunhão fraterna, santidade e busca pelo Senhor para discípulos solteiros da Grande BH.",
    dateLabel: "Outubro 2026",
    badgeText: "Encontro",
    imageUrl:
      "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=800&auto=format&fit=crop",
    linkUrl: "#contato",
  },
  {
    id: "mis-para-2026",
    type: "mission",
    title: "Envio e Serviço no Pará — Relato dos Irmãos",
    description:
      "Acompanhe o testemunho do serviço de irmãos enviados ao norte do país na formação de novos discípulos.",
    dateLabel: "Relato de Missão",
    badgeText: "Missões",
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
    id: "mod-trilhas",
    title: "Trilhas de Estudo",
    description:
      "Jornadas bíblicas estruturadas passo a passo sobre o Propósito Eterno, Juntas e Ligamentos e a vida nas casas.",
    iconName: "graduationCap",
    buttonText: "Explorar trilhas",
    link: "/ensinos?tab=trilhas",
  },
  {
    id: "mod-apostilas",
    title: "Apostilas",
    description:
      "Cadernos temáticos de formação bíblica, fundamentos da fé e manuais de discipulado prático em PDF.",
    iconName: "book",
    buttonText: "Ler apostilas",
    link: "/ensinos?tab=apostilas",
  },
  {
    id: "mod-ministracoes",
    title: "Ministrações",
    description:
      "Mensagens em vídeo e áudio compartilhadas nos encontros gerais e retiros para edificação do Corpo.",
    iconName: "mic",
    buttonText: "Ouvir mensagens",
    link: "/ensinos?tab=ministracoes",
  },
  {
    id: "mod-artigos",
    title: "Artigos e Textos",
    description:
      "Estudos bíblicos, reflexões e testemunhos práticos da caminhada diária de casa em casa.",
    iconName: "fileText",
    buttonText: "Ler textos",
    link: "/ensinos?tab=artigos",
  },
]
