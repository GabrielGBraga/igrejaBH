import { useState, useEffect } from "react"
import { Link } from "react-router-dom"
import { Play, ArrowRight } from "lucide-react"
import supabase from "@/lib/supabase"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  FALLBACK_FEATURED_VIDEO,
  FALLBACK_NEWS_CARDS,
  getYoutubeThumbnail,
  type NewsHighlight,
} from "@/data/landingData"
import { VideoPlayerModal } from "./VideoPlayerModal"
import { useNewsFeed } from "@/hooks/useNewsFeed"
import { NewsCard } from "@/components/news/NewsCard"

export function LandingNewsSection() {
  const [featured, setFeatured] = useState<NewsHighlight>(() => ({
    ...FALLBACK_FEATURED_VIDEO,
    imageUrl: getYoutubeThumbnail(FALLBACK_FEATURED_VIDEO.videoUrl),
  }))
  const [selectedVideo, setSelectedVideo] = useState<NewsHighlight | null>(null)

  // Busca notícias públicas diretamente do hook centralizado
  const { feedItems: publicPosts } = useNewsFeed({ publicOnly: true, limit: 3 })

  useEffect(() => {
    async function loadFeaturedVideo() {
      try {
        // Tenta carregar a ministração em vídeo mais recente do Supabase
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
            speakerOrAuthor: m.series_name || "Igreja em Belo Horizonte",
            dateLabel: new Date(m.created_at || Date.now()).toLocaleDateString("pt-BR"),
            description: m.description || FALLBACK_FEATURED_VIDEO.description,
            badgeText: "Ministração",
            imageUrl: actualThumbnail,
            videoUrl: m.url,
            linkUrl: "#video-player",
          })
        }
      } catch (err) {
        console.warn("Usando vídeo de destaque local:", err)
      }
    }

    loadFeaturedVideo()
  }, [])

  return (
    <section id="noticias" className="scroll-mt-20 py-16 sm:py-20 border-b border-border/40">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Section Title */}
        <div className="text-center mb-10 sm:mb-12">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Notícias & Vida Comum
          </h2>
          <p className="mt-2 text-xs sm:text-sm text-muted-foreground">
            Acompanhe as últimas mensagens, comunicados e o mover de Deus entre os discípulos na cidade.
          </p>
        </div>

        {/* 1. Main Featured Media Card with actual YouTube Thumbnail */}
        <div className="relative overflow-hidden rounded-3xl border border-border/60 bg-card p-4 sm:p-6 shadow-xs transition-all hover:border-primary/40 hover:shadow-sm">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-6 items-center">
            {/* Left: Video / Thumbnail */}
            <div className="md:col-span-6 lg:col-span-7">
              <div
                className="group relative aspect-video w-full cursor-pointer overflow-hidden rounded-2xl bg-black shadow-md focus-visible:ring-2 focus-visible:ring-primary"
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
                  className="h-full w-full object-cover transition-opacity duration-300"
                  loading="lazy"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent" />

                {/* Video Play Button Overlay */}
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="flex h-14 w-14 sm:h-16 sm:w-16 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-colors duration-200">
                    <Play className="h-6 w-6 sm:h-7 sm:w-7 fill-current ml-1" />
                  </div>
                </div>
              </div>
            </div>

            {/* Right: Text Description & Actions */}
            <div className="md:col-span-6 lg:col-span-5 flex flex-col justify-between space-y-4">
              <div>
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  <span className="font-medium text-primary">{featured.badgeText}</span>
                  {featured.dateLabel && (
                    <>
                      <span>&middot;</span>
                      <span>{featured.dateLabel}</span>
                    </>
                  )}
                </div>
                <h3 className="mt-1.5 text-xl sm:text-2xl font-bold tracking-tight text-foreground">
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
                  className="min-h-[44px] p-0 text-xs sm:text-sm font-semibold text-primary hover:underline flex items-center gap-1"
                >
                  Assistir ministração
                  <ArrowRight className="h-4 w-4" />
                </Button>
                {featured.speakerOrAuthor && (
                  <span className="text-xs text-muted-foreground font-medium">
                    {featured.speakerOrAuthor}
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* 2. Secondary News Cards */}
        <div className="mt-10">
          <div className="mb-4">
            <h3 className="text-sm font-semibold text-foreground">
              Comunicados e Estudos Recentes
            </h3>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {publicPosts.length > 0
              ? publicPosts.map((post) => (
                  <NewsCard key={post.id} post={post} />
                ))
              : FALLBACK_NEWS_CARDS.map((card) => (
                  <div
                    key={card.id}
                    className="flex flex-col justify-between overflow-hidden rounded-xl border border-border/60 bg-card p-5 shadow-2xs transition-colors hover:border-border"
                  >
                    <div>
                      <div className="flex items-center justify-between mb-3">
                        <Badge
                          variant="outline"
                          className="rounded-full border-primary/20 bg-primary/5 px-2.5 py-0.5 text-[11px] font-medium text-primary"
                        >
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
                      <Button asChild variant="ghost" size="sm" className="min-h-[44px] px-2 text-xs font-semibold text-primary">
                        <Link to={card.linkUrl}>
                          Ler mais
                          <ArrowRight className="ml-1 h-3.5 w-3.5" />
                        </Link>
                      </Button>
                    </div>
                  </div>
                ))}
          </div>
        </div>
      </div>

      {/* Video Player Modal */}
      {selectedVideo && (
        <VideoPlayerModal
          open={Boolean(selectedVideo)}
          onOpenChange={(open) => !open && setSelectedVideo(null)}
          title={selectedVideo.title}
          speaker={selectedVideo.speakerOrAuthor}
          dateLabel={selectedVideo.dateLabel}
          videoUrl={selectedVideo.videoUrl}
        />
      )}
    </section>
  )
}
