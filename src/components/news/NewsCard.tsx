import { useState } from "react"
import { Card, CardContent, CardFooter, CardHeader } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Clock,
  MapPin,
  BookOpen,
  ClipboardList,
  Sparkles,
  ArrowRight,
  Globe,
  Lock,
  HeartHandshake,
  Bell,
} from "lucide-react"
import { format, parseISO } from "date-fns"
import { ptBR } from "date-fns/locale"
import type { PostWithRelations } from "@/hooks/useNewsFeed"
import { NewsDetailDialog } from "./NewsDetailDialog"
import { getYoutubeThumbnail } from "@/data/landingData"

interface NewsCardProps {
  post: PostWithRelations
  className?: string
  showDirectActions?: boolean
}

export function NewsCard({
  post,
  className = "",
  showDirectActions = true,
}: NewsCardProps) {
  const [detailOpen, setDetailOpen] = useState(false)

  const formatShortDate = (dateStr: string) => {
    try {
      return format(parseISO(dateStr), "dd/MM/yyyy")
    } catch {
      return dateStr
    }
  }

  const formatEventBrief = (startStr?: string | null) => {
    if (!startStr) return null
    try {
      const start = parseISO(startStr)
      return format(start, "EEE, dd/MM 'às' HH:mm", { locale: ptBR })
    } catch {
      return startStr
    }
  }

  const getCategoryMeta = () => {
    switch (post.category) {
      case "encontro":
        return { label: "Encontro", icon: MapPin }
      case "evento":
        return { label: "Evento / Retiro", icon: Sparkles }
      case "estudo":
        return { label: "Estudo", icon: BookOpen }
      case "formulario":
        return { label: "Formulário", icon: ClipboardList }
      case "oracao":
        return { label: "Oração", icon: HeartHandshake }
      case "missoes":
        return { label: "Missões", icon: Globe }
      default:
        return { label: "Aviso", icon: Bell }
    }
  }

  const catMeta = getCategoryMeta()
  const CategoryIcon = catMeta.icon

  // Obtém miniatura se houver (imagem customizada ou thumbnail do YouTube para estudos em vídeo)
  const previewImage =
    post.image_urls && post.image_urls.length > 0
      ? post.image_urls[0]
      : post.media_resources?.type === "video" && post.media_resources.url
      ? getYoutubeThumbnail(post.media_resources.url)
      : null

  return (
    <>
      <Card
        className={`group flex flex-col justify-between overflow-hidden rounded-2xl border-border/70 bg-card/70 shadow-xs backdrop-blur-xs transition-all hover:border-primary/40 hover:shadow-md ${className}`}
      >
        <div>
          {/* Imagem de Capa (se houver) */}
          {previewImage && (
            <div
              className="relative aspect-video w-full cursor-pointer overflow-hidden bg-muted/30"
              onClick={() => setDetailOpen(true)}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === " ") {
                  e.preventDefault()
                  setDetailOpen(true)
                }
              }}
              aria-label={`Ver detalhes de ${post.title}`}
            >
              <img
                src={previewImage}
                alt={post.title}
                className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                loading="lazy"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-60 group-hover:opacity-40 transition-opacity" />

              {/* Tag sobre a foto */}
              <div className="absolute bottom-3 left-3 flex flex-wrap gap-1.5">
                <Badge className="bg-black/70 hover:bg-black/70 text-white border-none text-[10px] backdrop-blur-xs">
                  <CategoryIcon className="mr-1 h-3 w-3" />
                  {catMeta.label}
                </Badge>
                {post.event_label && (
                  <Badge className="bg-amber-600/90 hover:bg-amber-600/90 text-white border-none text-[10px] backdrop-blur-xs">
                    {post.event_label}
                  </Badge>
                )}
              </div>
            </div>
          )}

          <CardHeader className="space-y-2 p-4 sm:p-5 pb-2">
            {/* Header com badges caso não tenha imagem */}
            {!previewImage && (
              <div className="flex flex-wrap items-center justify-between gap-2 pb-1">
                <div className="flex flex-wrap items-center gap-1.5">
                  <Badge
                    variant="outline"
                    className="gap-1 rounded-full border-primary/20 bg-primary/5 px-2.5 py-0.5 text-[11px] font-semibold text-primary"
                  >
                    <CategoryIcon className="h-3 w-3" />
                    <span>{catMeta.label}</span>
                  </Badge>

                  {post.event_label && (
                    <Badge
                      variant="secondary"
                      className="bg-amber-500/10 text-amber-700 dark:text-amber-400 text-[10px] py-0.5"
                    >
                      {post.event_label}
                    </Badge>
                  )}
                </div>

                <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground">
                  {!post.is_public && (
                    <span title="Apenas membros vinculados" className="flex items-center text-muted-foreground">
                      <Lock className="h-3 w-3 mr-0.5" />
                    </span>
                  )}
                  <span>{formatShortDate(post.created_at)}</span>
                </div>
              </div>
            )}

            {/* Título */}
            <h3
              onClick={() => setDetailOpen(true)}
              className="cursor-pointer text-base sm:text-lg font-bold tracking-tight text-foreground transition-colors group-hover:text-primary line-clamp-2"
              role="button"
              tabIndex={0}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === " ") {
                  e.preventDefault()
                  setDetailOpen(true)
                }
              }}
            >
              {post.title}
            </h3>
          </CardHeader>

          <CardContent className="space-y-3 px-4 sm:px-5 py-1">
            {/* Destaque de data/local para encontros casuais */}
            {post.event_start_date && (
              <div className="flex items-center gap-2 rounded-lg border border-primary/20 bg-primary/5 px-3 py-2 text-xs font-semibold text-primary">
                <Clock className="h-3.5 w-3.5 shrink-0" />
                <span className="truncate">{formatEventBrief(post.event_start_date)}</span>
                {post.event_location && (
                  <>
                    <span className="text-muted-foreground">•</span>
                    <span className="truncate font-normal text-muted-foreground">
                      {post.event_location.split("-")[0]}
                    </span>
                  </>
                )}
              </div>
            )}

            {/* Resumo do Conteúdo */}
            <p className="text-xs sm:text-sm leading-relaxed text-muted-foreground line-clamp-3">
              {post.content}
            </p>
          </CardContent>
        </div>

        <CardFooter className="flex items-center justify-between gap-2 border-t border-border/40 p-4 sm:p-5 pt-3">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => setDetailOpen(true)}
            className="min-h-[44px] px-2 text-xs font-semibold text-primary hover:text-primary/80"
          >
            Ver comunicado
            <ArrowRight className="ml-1 h-3.5 w-3.5" />
          </Button>

          {/* Ação rápida contextual (se habilitada) */}
          {showDirectActions && (
            <div>
              {post.retreats && (
                <Badge variant="outline" className="text-[10px] border-primary/30 text-primary">
                  Inscrições Abertas
                </Badge>
              )}
              {post.media_resources && (
                <Badge variant="outline" className="text-[10px] border-primary/30 text-primary">
                  Ensino Disponível
                </Badge>
              )}
            </div>
          )}
        </CardFooter>
      </Card>

      {/* Modal de Detalhes da Notícia */}
      <NewsDetailDialog
        post={post}
        open={detailOpen}
        onOpenChange={setDetailOpen}
      />
    </>
  )
}
