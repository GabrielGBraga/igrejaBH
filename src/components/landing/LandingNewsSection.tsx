import { useState, useEffect } from "react"
import { Link } from "react-router-dom"
import { Play, ArrowRight, BookOpen, Calendar, Globe } from "lucide-react"
import supabase from "@/lib/supabase"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"
import {
  FALLBACK_FEATURED_VIDEO,
  FALLBACK_NEWS_CARDS,
  getYoutubeThumbnail,
  type NewsHighlight,
} from "@/data/landingData"
import { VideoPlayerModal } from "./VideoPlayerModal"

export function LandingNewsSection() {
  const [featured, setFeatured] = useState<NewsHighlight>(() => ({
    ...FALLBACK_FEATURED_VIDEO,
    imageUrl: getYoutubeThumbnail(FALLBACK_FEATURED_VIDEO.videoUrl),
  }))
  const [newsCards, setNewsCards] = useState<NewsHighlight[]>(FALLBACK_NEWS_CARDS)
  const [selectedVideo, setSelectedVideo] = useState<NewsHighlight | null>(null)
  const [selectedPost, setSelectedPost] = useState<NewsHighlight | null>(null)

  useEffect(() => {
    async function loadDynamicContent() {
      try {
        // 1. Tenta carregar a ministração em vídeo mais recente do Supabase
        const { data: mediaData } = await supabase
          .from("media_resources")
          .select("*")
          .eq("type", "video")
          .order("created_at", { ascending: false })
          .limit(1)

        if (mediaData && mediaData.length > 0) {
          const m = mediaData[0]
          const actualThumbnail = getYoutubeThumbnail(m.url)

          setFeatured({
            id: m.id,
            type: "video",
            title: m.title,
            categoryTitle: "Nova mensagem publicada",
            speakerOrAuthor: m.series_name || "Igreja em Belo Horizonte",
            dateLabel: new Date(m.created_at || Date.now()).toLocaleDateString("pt-BR"),
            description: m.description || FALLBACK_FEATURED_VIDEO.description,
            badgeText: "Vídeo Oficial",
            tags: ["#Edificação", "#Mensagem"],
            imageUrl: actualThumbnail,
            videoUrl: m.url,
            linkUrl: "#video-player",
          })
        }

        // 2. Tenta carregar notícias recentes de posts do banco
        const { data: postsData } = await supabase
          .from("posts")
          .select("id, title, content, category, created_at, image_urls")
          .eq("is_published", true)
          .order("created_at", { ascending: false })
          .limit(3)

        if (postsData && postsData.length > 0) {
          const mappedCards: NewsHighlight[] = postsData.map((p, idx) => {
            const hasCustomImg = Array.isArray(p.image_urls) && p.image_urls.length > 0
            const fallbackCard = FALLBACK_NEWS_CARDS[idx % FALLBACK_NEWS_CARDS.length]

            return {
              id: p.id,
              type: p.category === "aviso" ? "event" : "article",
              title: p.title,
              description: p.content,
              dateLabel: new Date(p.created_at || Date.now()).toLocaleDateString("pt-BR"),
              badgeText: p.category === "aviso" ? "Aviso Comunitário" : "Notícia",
              tags: [`#${p.category || "VidaComum"}`, "#IgrejaNaCidade"],
              imageUrl: hasCustomImg && p.image_urls ? p.image_urls[0] : fallbackCard.imageUrl,
              linkUrl: p.category === "aviso" ? "/eventos" : "/ensinos?tab=artigos",
            }
          })
          setNewsCards(mappedCards)
        }
      } catch (err) {
        // Fallback gracioso aos dados curados
        console.warn("Usando dados de destaque locais:", err)
      }
    }

    loadDynamicContent()
  }, [])

  const getCardIcon = (type: NewsHighlight["type"]) => {
    switch (type) {
      case "video":
        return <Play className="h-3.5 w-3.5" />
      case "event":
        return <Calendar className="h-3.5 w-3.5" />
      case "mission":
        return <Globe className="h-3.5 w-3.5" />
      default:
        return <BookOpen className="h-3.5 w-3.5" />
    }
  }

  return (
    <section id="noticias" className="scroll-mt-20 py-16 sm:py-20 border-b border-border/40">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Section Title */}
        <div className="text-center mb-10 sm:mb-12">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Notícias
          </h2>
          <p className="mt-2 text-xs sm:text-sm text-muted-foreground">
            Acompanhe as últimas mensagens, artigos e o mover de Deus entre os discípulos.
          </p>
        </div>

        {/* 1. Main Featured Media Card with actual YouTube Thumbnail */}
        <div className="relative overflow-hidden rounded-2xl border border-border/60 bg-card p-4 sm:p-6 shadow-xs transition-all hover:border-primary/40 hover:shadow-sm">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-6 items-center">
            {/* Left: Video / Thumbnail */}
            <div className="md:col-span-6 lg:col-span-7">
              <div
                className="group relative aspect-video w-full cursor-pointer overflow-hidden rounded-xl bg-black shadow-md focus-visible:ring-2 focus-visible:ring-primary"
                onClick={() => setSelectedVideo(featured)}
                role="button"
                tabIndex={0}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") {
                    e.preventDefault()
                    setSelectedVideo(featured)
                  }
                }}
                aria-label={`Assistir à ministração: ${featured.title}`}
              >
                {/* Actual Video Thumbnail */}
                <img
                  src={featured.imageUrl}
                  alt={featured.title}
                  className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                  loading="lazy"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent" />

                {/* Video Play Button Overlay */}
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="flex h-14 w-14 sm:h-16 sm:w-16 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform duration-200 group-hover:scale-110">
                    <Play className="h-6 w-6 sm:h-7 sm:w-7 fill-current ml-1" />
                  </div>
                </div>

                {/* Top Overlay Badge */}
                <div className="absolute top-3 left-3">
                  <Badge className="bg-black/70 hover:bg-black/70 text-white text-[11px] font-semibold border-none backdrop-blur-xs">
                    {featured.badgeText}
                  </Badge>
                </div>
              </div>
            </div>

            {/* Right: Text Description & Actions */}
            <div className="md:col-span-6 lg:col-span-5 flex flex-col justify-between space-y-4">
              <div>
                <span className="text-xs font-semibold uppercase tracking-wider text-primary">
                  {featured.categoryTitle || "Nova mensagem publicada"}
                </span>
                <h3 className="mt-1 text-xl sm:text-2xl font-bold tracking-tight text-foreground">
                  {featured.title}
                </h3>
                <p className="mt-3 text-xs sm:text-sm leading-relaxed text-muted-foreground">
                  {featured.description}
                </p>
              </div>

              <div className="pt-2 flex items-center justify-between border-t border-border/40">
                <Button
                  type="button"
                  variant="link"
                  onClick={() => setSelectedVideo(featured)}
                  className="p-0 text-xs sm:text-sm font-semibold text-primary hover:underline flex items-center gap-1"
                >
                  Assistir ministração
                  <ArrowRight className="h-4 w-4" />
                </Button>
                {featured.speakerOrAuthor && (
                  <span className="text-[11px] text-muted-foreground font-medium">
                    {featured.speakerOrAuthor}
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* 2. Three Secondary News Cards (Grid/Responsive) */}
        <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
          {newsCards.map((card) => (
            <div
              key={card.id}
              className="flex flex-col justify-between overflow-hidden rounded-xl border border-border/60 bg-card p-5 shadow-2xs transition-all hover:border-primary/40 hover:shadow-xs"
            >
              <div>
                {/* Header with Type Badge & Date */}
                <div className="flex items-center justify-between mb-3">
                  <Badge
                    variant="outline"
                    className="gap-1 rounded-full border-primary/20 bg-primary/5 px-2.5 py-0.5 text-[11px] font-semibold text-primary"
                  >
                    {getCardIcon(card.type)}
                    {card.badgeText}
                  </Badge>
                  <span className="text-[11px] text-muted-foreground">{card.dateLabel}</span>
                </div>

                <h4 className="text-base font-bold tracking-tight text-foreground line-clamp-2">
                  {card.title}
                </h4>

                <p className="mt-2 text-xs leading-relaxed text-muted-foreground line-clamp-3">
                  {card.description}
                </p>
              </div>

              <div className="mt-5 pt-3 border-t border-border/30 flex items-center justify-between">
                {/* Tags */}
                <div className="flex flex-wrap gap-1.5">
                  {card.tags.map((tag) => (
                    <span
                      key={tag}
                      className="text-[10px] font-medium text-muted-foreground/80"
                    >
                      {tag}
                    </span>
                  ))}
                </div>

                {/* Link or Action Modal */}
                {card.type === "article" ? (
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => setSelectedPost(card)}
                    className="h-8 px-2 text-xs font-semibold text-primary hover:text-primary/80"
                  >
                    Ler artigo
                    <ArrowRight className="ml-1 h-3 w-3" />
                  </Button>
                ) : (
                  <Button asChild variant="ghost" size="sm" className="h-8 px-2 text-xs font-semibold text-primary">
                    <Link to={card.linkUrl}>
                      Ver mais
                      <ArrowRight className="ml-1 h-3 w-3" />
                    </Link>
                  </Button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Video Player Modal */}
      {selectedVideo && (
        <VideoPlayerModal
          open={!!selectedVideo}
          onOpenChange={(open) => !open && setSelectedVideo(null)}
          title={selectedVideo.title}
          speaker={selectedVideo.speakerOrAuthor}
          dateLabel={selectedVideo.dateLabel}
          videoUrl={selectedVideo.videoUrl}
        />
      )}

      {/* Post Reader Modal for Public Reading */}
      {selectedPost && (
        <Dialog open={!!selectedPost} onOpenChange={(open) => !open && setSelectedPost(null)}>
          <DialogContent className="max-w-2xl p-6 bg-card border-border/80">
            <DialogHeader className="text-left space-y-2">
              <div className="flex items-center gap-2">
                <Badge variant="outline" className="border-primary/20 text-primary">
                  {selectedPost.badgeText}
                </Badge>
                <span className="text-xs text-muted-foreground">{selectedPost.dateLabel}</span>
              </div>
              <DialogTitle className="text-xl font-bold tracking-tight text-foreground">
                {selectedPost.title}
              </DialogTitle>
              <DialogDescription className="sr-only">
                Detalhes e conteúdo completo da publicação
              </DialogDescription>
            </DialogHeader>

            <div className="mt-4 text-sm leading-relaxed text-foreground/90 whitespace-pre-line max-h-[60vh] overflow-y-auto pr-2">
              {selectedPost.description}
            </div>

            <div className="mt-6 pt-3 border-t border-border/40 flex justify-between items-center">
              <Button asChild variant="outline" size="sm" className="min-h-[40px]">
                <Link to="/ensinos?tab=artigos">
                  Acessar Central de Ensinos
                </Link>
              </Button>
              <Button
                type="button"
                onClick={() => setSelectedPost(null)}
                className="min-h-[40px] px-4"
              >
                Fechar
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </section>
  )
}
