import { useState, useEffect, useCallback } from "react"
import { Bell, Plus, Loader2, Globe, Lock, Trash2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card } from "@/components/ui/card"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Field, FieldLabel } from "@/components/ui/field"
import supabase from "@/lib/supabase"
import { toast } from "sonner"
import { format, parseISO } from "date-fns"
import { ptBR } from "date-fns/locale"
import type { Database } from "@/lib/database.types"

type Post = Database["public"]["Tables"]["posts"]["Row"]
type Retreat = Database["public"]["Tables"]["retreats"]["Row"]

interface EventAnnouncementsTabProps {
  retreat: Retreat
}

const SUGGESTED_LABELS = [
  "Vagas Abertas",
  "Transporte & Caronas",
  "Lista de Espera",
  "Oração",
  "Mensagem de Ânimo",
  "Aviso Geral",
  "Orientações do Local",
]

export function EventAnnouncementsTab({ retreat }: EventAnnouncementsTabProps) {
  const [announcements, setAnnouncements] = useState<Post[]>([])
  const [loading, setLoading] = useState(true)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  // Form states
  const [title, setTitle] = useState("")
  const [content, setContent] = useState("")
  const [label, setLabel] = useState("Aviso Geral")
  const [isPublic, setIsPublic] = useState(true)

  const fetchAnnouncements = useCallback(async () => {
    setLoading(true)
    try {
      const { data, error } = await supabase
        .from("posts")
        .select("*")
        .eq("retreat_id", retreat.id)
        .order("created_at", { ascending: false })

      if (error) throw error
      setAnnouncements(data || [])
    } catch (err) {
      console.error("Erro ao carregar comunicados do evento:", err)
      toast.error("Erro ao carregar comunicados do evento.")
    } finally {
      setLoading(false)
    }
  }, [retreat.id])

  useEffect(() => {
    fetchAnnouncements()
  }, [fetchAnnouncements])

  const handleCreateAnnouncement = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !content.trim()) {
      toast.error("Por favor, preencha o título e o conteúdo do comunicado.")
      return
    }

    setSubmitting(true)
    try {
      const {
        data: { session },
      } = await supabase.auth.getSession()

      if (!session?.user) throw new Error("Usuário não autenticado")

      const { data: profile } = await supabase
        .from("profiles")
        .select("id")
        .eq("user_id", session.user.id)
        .single()

      if (!profile) throw new Error("Perfil não encontrado")

      const { error: insertError } = await supabase.from("posts").insert({
        title: title.trim(),
        content: content.trim(),
        category: "evento",
        retreat_id: retreat.id,
        event_label: label.trim() || null,
        is_public: isPublic,
        is_published: true,
        author_id: profile.id,
      })

      if (insertError) throw insertError

      toast.success("Comunicado publicado com sucesso no Mural!")
      setTitle("")
      setContent("")
      setLabel("Aviso Geral")
      setIsPublic(true)
      setDialogOpen(false)
      fetchAnnouncements()
    } catch (err: any) {
      console.error("Erro ao publicar comunicado:", err)
      toast.error(err.message || "Erro ao publicar comunicado.")
    } finally {
      setSubmitting(false)
    }
  }

  const handleDeleteAnnouncement = async (postId: string) => {
    if (!confirm("Tem certeza que deseja excluir este comunicado?")) return

    try {
      const { error } = await supabase.from("posts").delete().eq("id", postId)
      if (error) throw error
      toast.success("Comunicado excluído com sucesso.")
      setAnnouncements((prev) => prev.filter((p) => p.id !== postId))
    } catch (err: any) {
      console.error("Erro ao excluir comunicado:", err)
      toast.error("Erro ao excluir comunicado.")
    }
  }

  return (
    <div className="space-y-6">
      {/* Top Banner & Action */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 rounded-2xl border border-border/70 bg-card/60 p-5 backdrop-blur-xs">
        <div>
          <h3 className="text-lg font-bold text-foreground flex items-center gap-2">
            <Bell className="h-5 w-5 text-primary" />
            <span>Comunicados & Avisos do Evento</span>
          </h3>
          <p className="text-xs text-muted-foreground mt-1">
            Lance avisos com a etiqueta oficial deste retiro. Os comunicados aparecem no Mural do portal e, se marcados como públicos, na Landing Page.
          </p>
        </div>

        <Button
          onClick={() => setDialogOpen(true)}
          className="min-h-[44px] shrink-0 gap-1.5 rounded-full font-semibold px-4"
        >
          <Plus className="h-4 w-4" />
          <span>Novo Comunicado</span>
        </Button>
      </div>

      {/* Lista de Comunicados */}
      {loading ? (
        <div className="flex items-center justify-center p-12">
          <Loader2 className="h-7 w-7 animate-spin text-primary" />
        </div>
      ) : announcements.length === 0 ? (
        <Card className="rounded-2xl border border-dashed border-border/70 bg-card/30 p-8 text-center">
          <Bell className="h-8 w-8 text-muted-foreground/40 mx-auto mb-2" />
          <p className="text-sm font-semibold text-foreground">
            Nenhum comunicado publicado para este evento ainda.
          </p>
          <p className="text-xs text-muted-foreground mt-1">
            Clique em "Novo Comunicado" para avisar a igreja sobre transporte, vagas, lista de espera ou orações.
          </p>
        </Card>
      ) : (
        <div className="space-y-3">
          {announcements.map((post) => (
            <div
              key={post.id}
              className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 rounded-xl border border-border/60 bg-card/70 p-4 transition-colors hover:border-primary/40"
            >
              <div className="space-y-1.5 min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  {post.event_label && (
                    <Badge
                      variant="secondary"
                      className="bg-amber-500/10 text-amber-700 dark:text-amber-400 font-semibold text-[11px] py-0.5"
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
                      <span>Interno</span>
                    </Badge>
                  )}

                  <span className="text-[11px] text-muted-foreground">
                    {format(parseISO(post.created_at), "dd/MM/yyyy 'às' HH:mm", {
                      locale: ptBR,
                    })}
                  </span>
                </div>

                <h4 className="text-sm font-bold text-foreground">{post.title}</h4>
                <p className="text-xs text-muted-foreground line-clamp-2">
                  {post.content}
                </p>
              </div>

              <div className="flex items-center gap-2 shrink-0 self-end sm:self-center">
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => handleDeleteAnnouncement(post.id)}
                  className="h-9 w-9 text-destructive hover:bg-destructive/10"
                  aria-label="Excluir comunicado"
                >
                  <Trash2 className="h-4 w-4" />
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal de Criação de Comunicado */}
      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-lg p-5 sm:p-6">
          <DialogHeader className="text-left space-y-1.5">
            <DialogTitle className="text-lg font-bold">
              Publicar Comunicado do Evento
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Este comunicado será vinculado ao evento "{retreat.title}" e aparecerá no Mural da Igreja.
            </DialogDescription>
          </DialogHeader>

          <form onSubmit={handleCreateAnnouncement} className="space-y-4 pt-2">
            <Field>
              <FieldLabel className="text-xs font-semibold">Título do Comunicado*</FieldLabel>
              <Input
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Ex: Abertura das Inscrições nos Chalés"
                className="h-11 rounded-xl"
                required
              />
            </Field>

            <div className="space-y-1.5">
              <FieldLabel className="text-xs font-semibold">Etiqueta / Tag</FieldLabel>
              <Input
                value={label}
                onChange={(e) => setLabel(e.target.value)}
                placeholder="Ex: Vagas Abertas, Transporte, Oração"
                className="h-11 rounded-xl"
              />
              <div className="flex flex-wrap gap-1.5 pt-1">
                {SUGGESTED_LABELS.map((item) => (
                  <button
                    key={item}
                    type="button"
                    onClick={() => setLabel(item)}
                    className="rounded-md border border-border/60 bg-muted/30 px-2 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-muted hover:text-foreground"
                  >
                    {item}
                  </button>
                ))}
              </div>
            </div>

            <div className="flex items-center justify-between rounded-xl border border-border/60 bg-muted/20 p-3">
              <div>
                <span className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                  {isPublic ? (
                    <>
                      <Globe className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                      <span>Visível na Landing Page</span>
                    </>
                  ) : (
                    <>
                      <Lock className="h-4 w-4 text-amber-600 dark:text-amber-400" />
                      <span>Apenas Membros Vinculados</span>
                    </>
                  )}
                </span>
                <p className="text-[11px] text-muted-foreground mt-0.5">
                  {isPublic
                    ? "Visitantes não autenticados poderão ler na landing page."
                    : "Exige login e vínculo de membro da igreja para visualização."}
                </p>
              </div>
              <Switch checked={isPublic} onCheckedChange={setIsPublic} />
            </div>

            <Field>
              <FieldLabel className="text-xs font-semibold">Mensagem do Comunicado*</FieldLabel>
              <Textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Descreva as informações importantes..."
                className="min-h-[120px] rounded-xl"
                required
              />
            </Field>

            <DialogFooter className="gap-2 pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setDialogOpen(false)}
                className="min-h-[44px]"
              >
                Cancelar
              </Button>
              <Button
                type="submit"
                disabled={submitting}
                className="min-h-[44px] font-semibold"
              >
                {submitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Publicando...
                  </>
                ) : (
                  "Publicar Comunicado"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  )
}
