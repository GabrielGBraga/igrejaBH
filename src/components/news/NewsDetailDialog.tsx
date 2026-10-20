import { Link } from "react-router-dom"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Calendar,
  Clock,
  MapPin,
  BookOpen,
  ClipboardList,
  Sparkles,
  Lock,
  Globe,
  Bell,
  HeartHandshake,
} from "lucide-react"
import { format, parseISO } from "date-fns"
import { ptBR } from "date-fns/locale"
import type { PostWithRelations } from "@/hooks/useNewsFeed"

interface NewsDetailDialogProps {
  post: PostWithRelations | null
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function NewsDetailDialog({
  post,
  open,
  onOpenChange,
}: NewsDetailDialogProps) {
  if (!post) return null

  const formatDateLabel = (dateStr: string) => {
    try {
      return format(parseISO(dateStr), "dd 'de' MMMM 'de' yyyy", { locale: ptBR })
    } catch {
      return dateStr
    }
  }

  const formatEventTime = (startStr?: string | null, endStr?: string | null) => {
    if (!startStr) return null
    try {
      const start = parseISO(startStr)
      const dayWeek = format(start, "EEEE, dd/MM", { locale: ptBR })
      const startTime = format(start, "HH:mm'h'")

      if (!endStr) return `${dayWeek} às ${startTime}`

      const end = parseISO(endStr)
      if (format(start, "dd/MM") === format(end, "dd/MM")) {
        return `${dayWeek} das ${startTime} às ${format(end, "HH:mm'h'")}`
      }
      return `${format(start, "dd/MM 'às' HH:mm")} a ${format(end, "dd/MM 'às' HH:mm")}`
    } catch {
      return startStr
    }
  }

  const getCategoryMeta = () => {
    switch (post.category) {
      case "encontro":
        return { label: "Encontro na Cidade", icon: MapPin }
      case "evento":
        return { label: "Evento / Retiro", icon: Sparkles }
      case "estudo":
        return { label: "Estudo & Catequese", icon: BookOpen }
      case "formulario":
        return { label: "Formulário", icon: ClipboardList }
      case "oracao":
        return { label: "Pedido de Oração", icon: HeartHandshake }
      case "missoes":
        return { label: "Missões & Envio", icon: Globe }
      default:
        return { label: "Aviso Comunitário", icon: Bell }
    }
  }

  const catMeta = getCategoryMeta()
  const CategoryIcon = catMeta.icon

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto p-5 sm:p-6">
        <DialogHeader className="text-left space-y-3 pb-2 border-b border-border/40">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <div className="flex flex-wrap items-center gap-2">
              <Badge
                variant="outline"
                className="gap-1 border-primary/30 bg-primary/10 text-primary font-semibold text-xs py-0.5"
              >
                <CategoryIcon className="h-3.5 w-3.5" />
                <span>{catMeta.label}</span>
              </Badge>

              {post.event_label && (
                <Badge
                  variant="secondary"
                  className="bg-amber-500/10 text-amber-700 dark:text-amber-400 font-semibold text-xs py-0.5"
                >
                  {post.event_label}
                </Badge>
              )}

              {post.is_public ? (
                <Badge
                  variant="outline"
                  className="gap-1 border-emerald-500/30 bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 text-[10px]"
                >
                  <Globe className="h-3 w-3" />
                  <span>Público</span>
                </Badge>
              ) : (
                <Badge
                  variant="outline"
                  className="gap-1 border-muted bg-muted/50 text-muted-foreground text-[10px]"
                >
                  <Lock className="h-3 w-3" />
                  <span>Comunidade Interna</span>
                </Badge>
              )}
            </div>

            <span className="text-[11px] text-muted-foreground">
              {formatDateLabel(post.created_at)}
            </span>
          </div>

          <DialogTitle className="text-xl sm:text-2xl font-bold tracking-tight text-foreground leading-snug">
            {post.title}
          </DialogTitle>

          <DialogDescription className="text-xs text-muted-foreground">
            {post.author ? `Publicado por ${post.author.full_name}` : "Publicado pela comunhão dos discípulos"}
          </DialogDescription>
        </DialogHeader>

        {/* Informações de Encontro Casual (Data/Horário/Local) */}
        {post.event_start_date && (
          <div className="rounded-xl border border-primary/20 bg-primary/5 p-4 space-y-2 text-xs">
            <div className="flex items-center gap-2 font-semibold text-foreground">
              <Clock className="h-4 w-4 text-primary shrink-0" />
              <span>{formatEventTime(post.event_start_date, post.event_end_date)}</span>
            </div>
            {post.event_location && (
              <div className="flex items-start gap-2 text-muted-foreground">
                <MapPin className="h-4 w-4 text-primary shrink-0 mt-0.5" />
                <span>{post.event_location}</span>
              </div>
            )}
          </div>
        )}

        {/* Informações de Retiro / Evento Oficial Vinculado */}
        {post.retreats && (
          <div className="rounded-xl border border-border/70 bg-card p-4 space-y-2 text-xs">
            <div className="flex items-center justify-between gap-2">
              <span className="font-bold text-foreground text-sm">
                {post.retreats.title}
              </span>
              {post.retreats.price ? (
                <span className="font-semibold text-primary">
                  R$ {Number(post.retreats.price).toFixed(2).replace(".", ",")}
                </span>
              ) : (
                <span className="font-medium text-emerald-600 dark:text-emerald-400">Gratuito</span>
              )}
            </div>
            {post.retreats.location_text && (
              <p className="text-muted-foreground flex items-center gap-1.5">
                <MapPin className="h-3.5 w-3.5 shrink-0" />
                {post.retreats.location_text}
              </p>
            )}
          </div>
        )}

        {/* Informações de Estudo Vinculado */}
        {post.media_resources && (
          <div className="rounded-xl border border-border/70 bg-card p-4 space-y-1.5 text-xs">
            <span className="font-bold text-foreground text-sm block">
              {post.media_resources.title}
            </span>
            {post.media_resources.series_name && (
              <p className="text-muted-foreground">
                Série: <span className="font-medium text-foreground">{post.media_resources.series_name}</span>
              </p>
            )}
          </div>
        )}

        {/* Conteúdo Detalhado */}
        <div className="py-2 text-sm leading-relaxed text-foreground whitespace-pre-wrap">
          {post.content}
        </div>

        {/* Galeria de Fotos */}
        {post.image_urls && post.image_urls.length > 0 && (
          <div className="space-y-2 pt-2">
            <span className="text-xs font-semibold text-muted-foreground block">
              Fotos da Publicação
            </span>
            <div
              className={`grid gap-3 ${
                post.image_urls.length === 1
                  ? "grid-cols-1"
                  : post.image_urls.length === 2
                  ? "grid-cols-2"
                  : "grid-cols-2 sm:grid-cols-3"
              }`}
            >
              {post.image_urls.map((url, idx) => (
                <div
                  key={idx}
                  className="relative aspect-video sm:aspect-square overflow-hidden rounded-xl border border-border/50 bg-muted/20"
                >
                  <img
                    src={url}
                    alt={`${post.title} - imagem ${idx + 1}`}
                    className="h-full w-full object-cover transition-transform duration-300 hover:scale-105"
                    loading="lazy"
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Ações de Rodapé com Links Inteligentes */}
        <DialogFooter className="flex-col sm:flex-row items-stretch sm:items-center justify-between gap-2.5 pt-4 border-t border-border/40">
          <div>
            {post.retreats && (
              <Button asChild className="min-h-[44px] w-full sm:w-auto">
                <Link to="/eventos">
                  <Sparkles className="mr-2 h-4 w-4" />
                  Ver Detalhes do Evento & Inscrição
                </Link>
              </Button>
            )}

            {post.media_resources && (
              <Button asChild className="min-h-[44px] w-full sm:w-auto">
                <Link
                  to={
                    post.media_resources.type === "markdown"
                      ? "/ensinos?tab=artigos"
                      : post.media_resources.type === "pdf"
                      ? "/ensinos?tab=apostilas"
                      : "/ensinos?tab=ministracoes"
                  }
                >
                  <BookOpen className="mr-2 h-4 w-4" />
                  Acessar Estudo na Central
                </Link>
              </Button>
            )}

            {post.form_id && (
              <Button asChild className="min-h-[44px] w-full sm:w-auto">
                <Link to={`/formularios/responder/${post.form_id}`}>
                  <ClipboardList className="mr-2 h-4 w-4" />
                  Preencher Formulário
                </Link>
              </Button>
            )}

            {post.category === "encontro" && (
              <Button asChild variant="outline" className="min-h-[44px] w-full sm:w-auto">
                <a href="#calendario">
                  <Calendar className="mr-2 h-4 w-4" />
                  Ver no Calendário da Cidade
                </a>
              </Button>
            )}
          </div>

          <Button
            type="button"
            variant="outline"
            onClick={() => onOpenChange(false)}
            className="min-h-[44px]"
          >
            Fechar
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
