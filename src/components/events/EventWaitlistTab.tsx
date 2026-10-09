import { useState, useEffect, useMemo, useCallback } from "react"
import {
  Clock,
  Search,
  CheckCircle2,
  Phone,
  Mail,
  MapPin,
  Plane,
  UserCheck,
  Send,
  Copy,
  Trash2,
  AlertCircle,
  Loader2,
  MoreVertical,
  ArrowUpDown,
} from "lucide-react"
import { toast } from "sonner"
import supabase from "@/lib/supabase"
import { formatValue } from "@/lib/forms"
import { THEME_CLASSES, WAITLIST_STATUS_CONFIG } from "@/constants/colors"
import type { Database } from "@/lib/database.types"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
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
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

type WaitlistRow = Database["public"]["Tables"]["event_waitlist"]["Row"]
type Retreat = Database["public"]["Tables"]["retreats"]["Row"]

interface EventWaitlistTabProps {
  retreat: Retreat
  eventId: string
  formId?: string | null
  onWaitlistCountChange?: (count: number) => void
}

export function EventWaitlistTab({
  retreat,
  eventId,
  formId,
  onWaitlistCountChange,
}: EventWaitlistTabProps) {
  const [waitlist, setWaitlist] = useState<WaitlistRow[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("todos")
  const [travelFilter, setTravelFilter] = useState<string>("todos")

  // Modal para "Chamar Participante"
  const [callModalEntry, setCallModalEntry] = useState<WaitlistRow | null>(null)
  const [generatedCode, setGeneratedCode] = useState("")
  const [copiedLink, setCopiedLink] = useState(false)
  const [copiedCode, setCopiedCode] = useState(false)
  const [calling, setCalling] = useState(false)

  // Modal para exclusão
  const [entryToDelete, setEntryToDelete] = useState<WaitlistRow | null>(null)
  const [deleting, setDeleting] = useState(false)

  // 1. Carregar lista de espera em ordem cronológica estrita
  const fetchWaitlist = useCallback(async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from("event_waitlist")
        .select("*")
        .eq("retreat_id", eventId)
        .order("created_at", { ascending: true })

      if (error) throw error
      const rows = data || []
      setWaitlist(rows)
      onWaitlistCountChange?.(rows.filter((r) => r.status === "aguardando").length)
    } catch (err: unknown) {
      console.error("Erro ao carregar lista de espera:", err)
      const message = err instanceof Error ? err.message : "Erro desconhecido"
      toast.error("Erro ao carregar lista de espera: " + message)
    } finally {
      setLoading(false)
    }
  }, [eventId, onWaitlistCountChange])

  useEffect(() => {
    fetchWaitlist()
  }, [fetchWaitlist])

  // 2. Filtros e Pesquisa
  const filteredWaitlist = useMemo(() => {
    return waitlist.filter((entry) => {
      // Filtro de texto
      if (searchTerm.trim()) {
        const query = searchTerm.toLowerCase()
        const matchName = entry.full_name.toLowerCase().includes(query)
        const matchEmail = entry.email.toLowerCase().includes(query)
        const matchPhone = entry.phone.includes(query)
        const matchCity = entry.city_state?.toLowerCase().includes(query)
        if (!matchName && !matchEmail && !matchPhone && !matchCity) return false
      }

      // Filtro de status
      if (statusFilter !== "todos" && entry.status !== statusFilter) {
        return false
      }

      // Filtro de transporte
      if (travelFilter === "passagem" && entry.travel_mode !== "Já comprei passagem") {
        return false
      }
      if (travelFilter !== "todos" && travelFilter !== "passagem" && entry.travel_mode !== travelFilter) {
        return false
      }

      return true
    })
  }, [waitlist, searchTerm, statusFilter, travelFilter])

  // Métricas de KPIs da lista de espera
  const kpis = useMemo(() => {
    const total = waitlist.length
    const aguardando = waitlist.filter((w) => w.status === "aguardando").length
    const chamados = waitlist.filter((w) => w.status === "chamado").length
    const inscritos = waitlist.filter((w) => w.status === "inscrito").length
    const comPassagem = waitlist.filter((w) => w.travel_mode === "Já comprei passagem").length

    return { total, aguardando, chamados, inscritos, comPassagem }
  }, [waitlist])

  // 3. Abrir modal de chamada do participante
  const openCallModal = (entry: WaitlistRow) => {
    // Gerar código exclusivo: VAGA-XXX
    const namePart = entry.full_name
      .split(" ")[0]
      .replace(/[^A-Za-z]/g, "")
      .toUpperCase()
      .slice(0, 4)
    const randomPart = Math.floor(1000 + Math.random() * 9000)
    const code = `VAGA-${namePart || "ESPERA"}-${randomPart}`

    setGeneratedCode(code)
    setCallModalEntry(entry)
    setCopiedLink(false)
    setCopiedCode(false)
  }

  // Gera link exclusivo direto
  const getDirectLink = (entry: WaitlistRow, code: string) => {
    const baseId = formId || retreat.id
    const origin = typeof window !== "undefined" ? window.location.origin : ""
    return `${origin}/formularios/responder/${encodeURIComponent(baseId)}?waitlist_id=${encodeURIComponent(
      entry.id
    )}&cupom=${encodeURIComponent(code)}&nome=${encodeURIComponent(entry.full_name)}`
  }

  // Copiar link
  const handleCopyLink = () => {
    if (!callModalEntry) return
    const link = getDirectLink(callModalEntry, generatedCode)
    navigator.clipboard.writeText(link)
    setCopiedLink(true)
    toast.success("Link exclusivo copiado para a área de transferência!")
    setTimeout(() => setCopiedLink(false), 2500)
  }

  // Copiar código
  const handleCopyCode = () => {
    navigator.clipboard.writeText(generatedCode)
    setCopiedCode(true)
    toast.success(`Código ${generatedCode} copiado!`)
    setTimeout(() => setCopiedCode(false), 2500)
  }

  // Confirmar chamada e atualizar status para 'chamado'
  const handleConfirmCall = async (shouldCreateCoupon = true) => {
    if (!callModalEntry) return
    setCalling(true)
    try {
      // 1. Opcionalmente registrar cupom na tabela event_coupons para isenção/validação
      if (shouldCreateCoupon) {
        try {
          const { data: { user } } = await supabase.auth.getUser()
          await supabase.from("event_coupons").insert({
            code: generatedCode,
            retreat_id: eventId,
            form_id: formId || null,
            cpf: callModalEntry.cpf || null,
            discount_percent: 100, // isenção ou liberação de vaga
            notes: `Liberado da lista de espera para ${callModalEntry.full_name}`,
            created_by: user?.id || null,
          })
        } catch (cErr) {
          console.warn("Cupom não pôde ser gerado em event_coupons:", cErr)
        }
      }

      // 2. Atualizar status na tabela event_waitlist para 'chamado'
      const { error } = await supabase
        .from("event_waitlist")
        .update({ status: "chamado" })
        .eq("id", callModalEntry.id)

      if (error) throw error

      toast.success(
        `Participante ${callModalEntry.full_name} marcado como chamado!`
      )

      // Atualizar lista local
      setWaitlist((prev) =>
        prev.map((item) =>
          item.id === callModalEntry.id ? { ...item, status: "chamado" } : item
        )
      )
      setCallModalEntry(null)
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "Erro ao chamar participante"
      toast.error(message)
    } finally {
      setCalling(false)
    }
  }

  // Atualizar status individual
  const handleUpdateStatus = async (
    entry: WaitlistRow,
    newStatus: WaitlistRow["status"]
  ) => {
    try {
      const { error } = await supabase
        .from("event_waitlist")
        .update({ status: newStatus })
        .eq("id", entry.id)

      if (error) throw error

      toast.success(
        `Status de ${entry.full_name} alterado para "${WAITLIST_STATUS_CONFIG[newStatus].label}".`
      )
      setWaitlist((prev) =>
        prev.map((item) =>
          item.id === entry.id ? { ...item, status: newStatus } : item
        )
      )
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "Erro ao atualizar status"
      toast.error(message)
    }
  }

  // Deletar participante da lista de espera
  const handleDeleteEntry = async () => {
    if (!entryToDelete) return
    setDeleting(true)
    try {
      const { error } = await supabase
        .from("event_waitlist")
        .delete()
        .eq("id", entryToDelete.id)

      if (error) throw error

      toast.success(`Registro de ${entryToDelete.full_name} removido da lista de espera.`)
      setWaitlist((prev) => prev.filter((item) => item.id !== entryToDelete.id))
      setEntryToDelete(null)
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "Erro ao remover registro"
      toast.error(message)
    } finally {
      setDeleting(false)
    }
  }

  // Gerar mensagem de WhatsApp
  const getWhatsAppShareUrl = (entry: WaitlistRow, code: string) => {
    const cleanPhone = entry.phone.replace(/\D/g, "")
    const link = getDirectLink(entry, code)
    const text = encodeURIComponent(
      `Olá, ${entry.full_name}! A paz do Senhor.\nUma vaga abriu para você participar do encontro *${retreat.title}*! 🎉\n\nUse este link exclusivo para concluir sua inscrição:\n${link}\n\nCódigo exclusivo: *${code}*\n\nFicamos na expectativa de caminhar juntos neste encontro!`
    )
    return `https://wa.me/55${cleanPhone}?text=${text}`
  }

  if (loading) {
    return (
      <div className="flex min-h-[300px] flex-col items-center justify-center gap-3">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <span className="text-sm font-medium text-muted-foreground">
          Carregando lista de espera...
        </span>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* 1. KPI Cards Row */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
        <Card className="rounded-xl border-border/60 bg-card p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-muted-foreground">Total na Fila</span>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </div>
          <div className="mt-2 text-2xl font-black text-foreground">{kpis.total}</div>
          <p className="mt-0.5 text-[11px] text-muted-foreground">Ordem de chegada</p>
        </Card>

        <Card className="rounded-xl border-amber-500/20 bg-amber-500/5 p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-amber-600 dark:text-amber-400">Aguardando</span>
            <Clock className="h-4 w-4 text-amber-500" />
          </div>
          <div className="mt-2 text-2xl font-black text-amber-700 dark:text-amber-300">
            {kpis.aguardando}
          </div>
          <p className="mt-0.5 text-[11px] text-amber-600/80 dark:text-amber-400/80">Esperando vaga</p>
        </Card>

        <Card className="rounded-xl border-blue-500/20 bg-blue-500/5 p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-blue-600 dark:text-blue-400">Chamados</span>
            <Send className="h-4 w-4 text-blue-500" />
          </div>
          <div className="mt-2 text-2xl font-black text-blue-700 dark:text-blue-300">
            {kpis.chamados}
          </div>
          <p className="mt-0.5 text-[11px] text-blue-600/80 dark:text-blue-400/80">Com link enviado</p>
        </Card>

        <Card className="rounded-xl border-emerald-500/20 bg-emerald-500/5 p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-emerald-600 dark:text-emerald-400">Inscritos</span>
            <CheckCircle2 className="h-4 w-4 text-emerald-500" />
          </div>
          <div className="mt-2 text-2xl font-black text-emerald-700 dark:text-emerald-300">
            {kpis.inscritos}
          </div>
          <p className="mt-0.5 text-[11px] text-emerald-600/80 dark:text-emerald-400/80">Finalizados</p>
        </Card>

        <Card className="rounded-xl border-purple-500/20 bg-purple-500/5 p-4 shadow-xs col-span-2 sm:col-span-1">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-purple-700 dark:text-purple-300">Com Passagem</span>
            <Plane className="h-4 w-4 text-purple-600 dark:text-purple-400" />
          </div>
          <div className="mt-2 text-2xl font-black text-purple-800 dark:text-purple-200">
            {kpis.comPassagem}
          </div>
          <p className="mt-0.5 text-[11px] text-purple-600/80 dark:text-purple-300/80">Prioridade de viagem</p>
        </Card>
      </div>

      {/* 2. Filtros e Busca */}
      <div className="flex flex-col gap-3 rounded-2xl border border-border/60 bg-card p-4 sm:flex-row sm:items-center sm:justify-between shadow-xs">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Buscar por nome, e-mail, celular ou cidade..."
            className="pl-9 h-11 text-xs min-h-[44px]"
          />
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {/* Filtro de Status */}
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="h-11 min-h-[44px] text-xs w-[140px]">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="todos">Todos os status</SelectItem>
              <SelectItem value="aguardando">Aguardando</SelectItem>
              <SelectItem value="chamado">Chamados</SelectItem>
              <SelectItem value="inscrito">Inscritos</SelectItem>
              <SelectItem value="desistiu">Desistiram</SelectItem>
            </SelectContent>
          </Select>

          {/* Filtro de Transporte */}
          <Select value={travelFilter} onValueChange={setTravelFilter}>
            <SelectTrigger className="h-11 min-h-[44px] text-xs w-[170px]">
              <SelectValue placeholder="Transporte" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="todos">Todos os transportes</SelectItem>
              <SelectItem value="passagem">✈️ Com Passagem</SelectItem>
              <SelectItem value="Carro próprio">Carro próprio</SelectItem>
              <SelectItem value="Carona">Carona</SelectItem>
              <SelectItem value="A definir">A definir</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* 3. Listagem */}
      {filteredWaitlist.length === 0 ? (
        <Card className="rounded-2xl border-dashed border-border/80 p-12 text-center">
          <Clock className="mx-auto h-12 w-12 text-muted-foreground/60" />
          <h3 className="mt-3 text-base font-bold text-foreground">
            Nenhum registro encontrado
          </h3>
          <p className="mt-1 text-xs text-muted-foreground">
            {searchTerm || statusFilter !== "todos" || travelFilter !== "todos"
              ? "Tente ajustar os filtros ou a busca acima."
              : "Ainda não há ninguém na lista de espera deste encontro."}
          </p>
        </Card>
      ) : (
        <div className="space-y-3">
          {/* Header descritivo de ordem de chegada */}
          <div className="flex items-center justify-between px-1 text-xs font-medium text-muted-foreground">
            <span className="flex items-center gap-1.5">
              <ArrowUpDown className="h-3.5 w-3.5" />
              Exibindo <strong>{filteredWaitlist.length}</strong> participante(s) em ordem cronológica estrita de chegada
            </span>
          </div>

          {/* Versão Desktop (Tabela) */}
          <div className="hidden md:block overflow-hidden rounded-2xl border border-border/60 bg-card shadow-xs">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="border-b border-border/60 bg-muted/40 text-muted-foreground font-semibold">
                  <tr>
                    <th className="py-3 px-4 w-12 text-center">#</th>
                    <th className="py-3 px-4">Participante</th>
                    <th className="py-3 px-4">Contato</th>
                    <th className="py-3 px-4">Deslocamento</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4">Data Chegada</th>
                    <th className="py-3 px-4 text-right">Ações</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border/30">
                  {filteredWaitlist.map((item, idx) => {
                    const position = idx + 1
                    const hasBoughtTicket = item.travel_mode === "Já comprei passagem"
                    const statusCfg = WAITLIST_STATUS_CONFIG[item.status] || WAITLIST_STATUS_CONFIG.aguardando

                    return (
                      <tr
                        key={item.id}
                        className={`hover:bg-muted/30 transition-colors ${
                          hasBoughtTicket ? "bg-purple-500/[0.02]" : ""
                        }`}
                      >
                        {/* Posição na fila */}
                        <td className="py-3.5 px-4 text-center font-bold text-muted-foreground">
                          <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-muted text-[11px] font-bold text-foreground">
                            {position}
                          </span>
                        </td>

                        {/* Nome e CPF */}
                        <td className="py-3.5 px-4">
                          <div className="font-bold text-foreground text-sm flex items-center gap-2">
                            <span>{item.full_name}</span>
                            {hasBoughtTicket && (
                              <span className={THEME_CLASSES.badgePriority} title="Passagem comprada">
                                <Plane className="h-3 w-3 mr-1" /> Passagem Comprada
                              </span>
                            )}
                          </div>
                          {item.cpf && (
                            <div className="text-[11px] text-muted-foreground">
                              CPF: {formatValue(item.cpf, "cpf")}
                            </div>
                          )}
                          {item.notes && (
                            <div className="mt-1 text-[11px] text-muted-foreground/80 italic max-w-xs truncate" title={item.notes}>
                              Obs: {item.notes}
                            </div>
                          )}
                        </td>

                        {/* Contatos */}
                        <td className="py-3.5 px-4 space-y-0.5">
                          <div className="flex items-center gap-1.5 text-foreground">
                            <Phone className="h-3 w-3 text-muted-foreground" />
                            <span>{item.phone}</span>
                          </div>
                          <div className="flex items-center gap-1.5 text-muted-foreground text-[11px]">
                            <Mail className="h-3 w-3" />
                            <span className="truncate max-w-[180px]">{item.email}</span>
                          </div>
                          {item.city_state && (
                            <div className="flex items-center gap-1 text-[11px] text-muted-foreground">
                              <MapPin className="h-3 w-3" />
                              <span>{item.city_state}</span>
                            </div>
                          )}
                        </td>

                        {/* Modo de Viagem */}
                        <td className="py-3.5 px-4">
                          <span
                            className={
                              hasBoughtTicket
                                ? THEME_CLASSES.badgePriority
                                : THEME_CLASSES.badgeNeutral
                            }
                          >
                            {hasBoughtTicket ? "✈️ Já comprei passagem" : item.travel_mode || "A definir"}
                          </span>
                        </td>

                        {/* Status */}
                        <td className="py-3.5 px-4">
                          <span className={statusCfg.className}>
                            {statusCfg.label}
                          </span>
                        </td>

                        {/* Data e hora de chegada */}
                        <td className="py-3.5 px-4 text-muted-foreground text-[11px]">
                          {new Date(item.created_at).toLocaleString("pt-BR", {
                            dateStyle: "short",
                            timeStyle: "short",
                          })}
                        </td>

                        {/* Ações */}
                        <td className="py-3.5 px-4 text-right">
                          <div className="flex items-center justify-end gap-1.5">
                            {item.status === "aguardando" && (
                              <Button
                                size="sm"
                                onClick={() => openCallModal(item)}
                                className="min-h-[36px] h-9 px-3 rounded-lg bg-primary text-primary-foreground font-bold text-xs gap-1.5 cursor-pointer shadow-xs"
                              >
                                <Send className="h-3.5 w-3.5" />
                                <span>Chamar</span>
                              </Button>
                            )}

                            {item.status === "chamado" && (
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => openCallModal(item)}
                                className="min-h-[36px] h-9 px-3 rounded-lg text-xs font-semibold gap-1.5 cursor-pointer"
                              >
                                <Copy className="h-3.5 w-3.5" />
                                <span>Ver Link</span>
                              </Button>
                            )}

                            {/* Dropdown de Mais Ações */}
                            <DropdownMenu>
                              <DropdownMenuTrigger asChild>
                                <Button
                                  variant="ghost"
                                  size="icon"
                                  className="h-9 w-9 min-h-[36px] min-w-[36px] cursor-pointer rounded-lg text-muted-foreground hover:text-foreground"
                                >
                                  <MoreVertical className="h-4 w-4" />
                                </Button>
                              </DropdownMenuTrigger>
                              <DropdownMenuContent align="end" className="w-48 text-xs">
                                <DropdownMenuLabel>Alterar Status</DropdownMenuLabel>
                                <DropdownMenuItem
                                  onClick={() => handleUpdateStatus(item, "aguardando")}
                                  className="cursor-pointer"
                                >
                                  Marcar como Aguardando
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  onClick={() => handleUpdateStatus(item, "chamado")}
                                  className="cursor-pointer"
                                >
                                  Marcar como Chamado
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  onClick={() => handleUpdateStatus(item, "inscrito")}
                                  className="cursor-pointer"
                                >
                                  Marcar como Inscrito
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  onClick={() => handleUpdateStatus(item, "desistiu")}
                                  className="cursor-pointer"
                                >
                                  Marcar como Desistiu
                                </DropdownMenuItem>
                                <DropdownMenuSeparator />
                                <DropdownMenuItem
                                  onClick={() => setEntryToDelete(item)}
                                  className="cursor-pointer text-destructive focus:text-destructive"
                                >
                                  <Trash2 className="h-3.5 w-3.5 mr-2" />
                                  Excluir da Lista
                                </DropdownMenuItem>
                              </DropdownMenuContent>
                            </DropdownMenu>
                          </div>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </div>

          {/* Versão Mobile (Cards Fluidos) */}
          <div className="grid grid-cols-1 gap-3 md:hidden">
            {filteredWaitlist.map((item, idx) => {
              const position = idx + 1
              const hasBoughtTicket = item.travel_mode === "Já comprei passagem"
              const statusCfg = WAITLIST_STATUS_CONFIG[item.status] || WAITLIST_STATUS_CONFIG.aguardando

              return (
                <Card
                  key={item.id}
                  className={`rounded-2xl border-border/60 p-4 shadow-xs space-y-3 ${
                    hasBoughtTicket ? "border-purple-500/30 bg-purple-500/[0.02]" : ""
                  }`}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-muted text-xs font-black text-foreground">
                        #{position}
                      </span>
                      <div>
                        <h4 className="font-bold text-foreground text-sm leading-tight">
                          {item.full_name}
                        </h4>
                        <span className="text-[11px] text-muted-foreground">
                          {new Date(item.created_at).toLocaleString("pt-BR", {
                            dateStyle: "short",
                            timeStyle: "short",
                          })}
                        </span>
                      </div>
                    </div>
                    <span className={statusCfg.className}>{statusCfg.label}</span>
                  </div>

                  {hasBoughtTicket && (
                    <div>
                      <span className={THEME_CLASSES.badgePriority}>
                        <Plane className="h-3 w-3 mr-1" /> Já comprou passagem
                      </span>
                    </div>
                  )}

                  {/* Informações de contato */}
                  <div className="rounded-xl border border-border/40 bg-muted/20 p-2.5 text-xs space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="text-muted-foreground">Celular:</span>
                      <a href={`tel:${item.phone}`} className="font-semibold text-foreground underline">
                        {item.phone}
                      </a>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-muted-foreground">E-mail:</span>
                      <span className="font-semibold text-foreground truncate max-w-[180px]">
                        {item.email}
                      </span>
                    </div>
                    {item.city_state && (
                      <div className="flex items-center justify-between">
                        <span className="text-muted-foreground">Cidade:</span>
                        <span className="font-semibold text-foreground">{item.city_state}</span>
                      </div>
                    )}
                    {item.notes && (
                      <div className="pt-1 border-t border-border/20 text-[11px] text-muted-foreground italic">
                        Obs: {item.notes}
                      </div>
                    )}
                  </div>

                  {/* Ações no Mobile */}
                  <div className="flex items-center gap-2 pt-1">
                    {item.status === "aguardando" && (
                      <Button
                        onClick={() => openCallModal(item)}
                        className="flex-1 min-h-[44px] rounded-xl bg-primary text-primary-foreground font-bold text-xs gap-1.5 cursor-pointer shadow-xs"
                      >
                        <Send className="h-3.5 w-3.5" /> Chamar Participante
                      </Button>
                    )}

                    {item.status === "chamado" && (
                      <Button
                        variant="outline"
                        onClick={() => openCallModal(item)}
                        className="flex-1 min-h-[44px] rounded-xl text-xs font-semibold gap-1.5 cursor-pointer"
                      >
                        <Copy className="h-3.5 w-3.5" /> Ver Link Exclusivo
                      </Button>
                    )}

                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button
                          variant="outline"
                          className="min-h-[44px] px-3 rounded-xl text-xs font-semibold cursor-pointer"
                        >
                          Status
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end" className="w-48 text-xs">
                        <DropdownMenuItem onClick={() => handleUpdateStatus(item, "aguardando")}>
                          Marcar Aguardando
                        </DropdownMenuItem>
                        <DropdownMenuItem onClick={() => handleUpdateStatus(item, "chamado")}>
                          Marcar Chamado
                        </DropdownMenuItem>
                        <DropdownMenuItem onClick={() => handleUpdateStatus(item, "inscrito")}>
                          Marcar Inscrito
                        </DropdownMenuItem>
                        <DropdownMenuItem onClick={() => handleUpdateStatus(item, "desistiu")}>
                          Marcar Desistiu
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem
                          onClick={() => setEntryToDelete(item)}
                          className="text-destructive"
                        >
                          <Trash2 className="h-3.5 w-3.5 mr-2" /> Excluir
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </div>
                </Card>
              )
            })}
          </div>
        </div>
      )}

      {/* 4. Modal para Chamar Participante */}
      {callModalEntry && (
        <Dialog open={!!callModalEntry} onOpenChange={(open) => !open && setCallModalEntry(null)}>
          <DialogContent className="max-w-lg rounded-2xl border-border/80 bg-background p-6">
            <DialogHeader>
              <div className="flex items-center gap-2">
                <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10 text-primary">
                  <UserCheck className="h-5 w-5" />
                </div>
                <div>
                  <DialogTitle className="text-lg font-bold text-foreground">
                    Chamar {callModalEntry.full_name}
                  </DialogTitle>
                  <DialogDescription className="text-xs text-muted-foreground">
                    Gere o link exclusivo de inscrição para convocar o participante da lista de espera.
                  </DialogDescription>
                </div>
              </div>
            </DialogHeader>

            <div className="mt-4 space-y-4 text-xs">
              {/* Destaque de Passagem Comprada se aplicável */}
              {callModalEntry.travel_mode === "Já comprei passagem" && (
                <div className="flex items-center gap-2 rounded-xl border border-purple-500/30 bg-purple-500/10 p-3 text-purple-900 dark:bg-purple-500/15 dark:text-purple-200">
                  <Plane className="h-4 w-4 shrink-0 text-purple-600 dark:text-purple-300" />
                  <span>
                    <strong>Prioridade:</strong> O participante já tem passagem comprada.
                  </span>
                </div>
              )}

              {/* Código Exclusivo Gerado */}
              <div className="space-y-1.5">
                <label className="font-semibold text-foreground flex items-center justify-between">
                  <span>Código de Acesso / Cupom Exclusivo:</span>
                  <Badge variant="outline" className="text-[10px] uppercase font-bold text-primary">
                    100% Isenção / Vaga
                  </Badge>
                </label>
                <div className="flex gap-2">
                  <Input
                    readOnly
                    value={generatedCode}
                    className="h-10 text-xs font-mono font-bold bg-muted/40 cursor-default select-all"
                  />
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleCopyCode}
                    className="h-10 min-h-[40px] px-3 text-xs font-semibold cursor-pointer"
                  >
                    {copiedCode ? <CheckCircle2 className="h-4 w-4 text-emerald-500" /> : <Copy className="h-4 w-4" />}
                  </Button>
                </div>
              </div>

              {/* Link Direto */}
              <div className="space-y-1.5">
                <label className="font-semibold text-foreground">Link Direto de Inscrição:</label>
                <div className="flex gap-2">
                  <Input
                    readOnly
                    value={getDirectLink(callModalEntry, generatedCode)}
                    className="h-10 text-xs font-mono text-muted-foreground bg-muted/40 cursor-default select-all"
                  />
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleCopyLink}
                    className="h-10 min-h-[40px] px-3 text-xs font-semibold cursor-pointer"
                  >
                    {copiedLink ? <CheckCircle2 className="h-4 w-4 text-emerald-500" /> : <Copy className="h-4 w-4" />}
                  </Button>
                </div>
                <p className="text-[11px] text-muted-foreground">
                  Este link direciona o participante diretamente para a ficha com liberação de vaga.
                </p>
              </div>

              {/* Envio rápido por WhatsApp */}
              <div className="pt-2 border-t border-border/40">
                <Button
                  type="button"
                  asChild
                  className="w-full min-h-[44px] rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs gap-2 cursor-pointer shadow-xs"
                >
                  <a
                    href={getWhatsAppShareUrl(callModalEntry, generatedCode)}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Send className="h-4 w-4" />
                    Enviar Convite no WhatsApp ({callModalEntry.phone})
                  </a>
                </Button>
              </div>
            </div>

            <DialogFooter className="mt-4 gap-2 sm:gap-0">
              <Button
                variant="outline"
                onClick={() => setCallModalEntry(null)}
                className="min-h-[44px] cursor-pointer rounded-xl font-semibold text-xs"
              >
                Fechar
              </Button>
              {callModalEntry.status !== "chamado" && (
                <Button
                  onClick={() => handleConfirmCall(true)}
                  disabled={calling}
                  className="min-h-[44px] cursor-pointer rounded-xl bg-primary text-primary-foreground font-bold text-xs shadow-xs"
                >
                  {calling ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Atualizando...
                    </>
                  ) : (
                    "Confirmar e Marcar como Chamado"
                  )}
                </Button>
              )}
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}

      {/* 5. Modal de Confirmação de Exclusão */}
      {entryToDelete && (
        <Dialog open={!!entryToDelete} onOpenChange={(open) => !open && setEntryToDelete(null)}>
          <DialogContent className="max-w-md rounded-2xl border-border/80 bg-background p-6">
            <DialogHeader>
              <DialogTitle className="text-base font-bold text-foreground flex items-center gap-2">
                <AlertCircle className="h-5 w-5 text-destructive" />
                Remover da Lista de Espera?
              </DialogTitle>
              <DialogDescription className="text-xs text-muted-foreground mt-2">
                Tem certeza que deseja remover <strong>{entryToDelete.full_name}</strong> da lista de espera?
                Esta ação não pode ser desfeita.
              </DialogDescription>
            </DialogHeader>

            <DialogFooter className="mt-6 gap-2">
              <Button
                variant="outline"
                onClick={() => setEntryToDelete(null)}
                disabled={deleting}
                className="min-h-[44px] cursor-pointer rounded-xl text-xs font-semibold"
              >
                Cancelar
              </Button>
              <Button
                variant="destructive"
                onClick={handleDeleteEntry}
                disabled={deleting}
                className="min-h-[44px] cursor-pointer rounded-xl text-xs font-bold"
              >
                {deleting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Removendo...
                  </>
                ) : (
                  "Remover Registro"
                )}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}
