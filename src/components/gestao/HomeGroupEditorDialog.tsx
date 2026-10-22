import { useState, useEffect } from "react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { MapPin, Clock, Calendar, Users, Loader2, Search } from "lucide-react"
import { toast } from "sonner"
import supabase from "@/lib/supabase"
import type { Database } from "@/lib/database.types"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]
type Sector = Database["public"]["Tables"]["sectors"]["Row"]

export interface HomeGroupEditorDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  homeGroup: HomeGroup | null // null = adding new (Tier 3 only)
  isTier3: boolean
  allProfiles: Profile[]
  sectors: Sector[]
  onSuccess: () => void
}

const DAYS_OF_WEEK = [
  { value: "0", label: "Domingo" },
  { value: "1", label: "Segunda-feira" },
  { value: "2", label: "Terça-feira" },
  { value: "3", label: "Quarta-feira" },
  { value: "4", label: "Quinta-feira" },
  { value: "5", label: "Sexta-feira" },
  { value: "6", label: "Sábado" },
]

export function HomeGroupEditorDialog({
  open,
  onOpenChange,
  homeGroup,
  isTier3,
  allProfiles,
  sectors,
  onSuccess,
}: HomeGroupEditorDialogProps) {
  const isEditing = !!homeGroup

  const [meetingDay, setMeetingDay] = useState<number>(3) // Quarta-feira
  const [startTime, setStartTime] = useState<string>("20:00")
  const [locationText, setLocationText] = useState<string>("")
  const [lat, setLat] = useState<number | null>(null)
  const [lng, setLng] = useState<number | null>(null)
  const [leader1Id, setLeader1Id] = useState<string>("")
  const [leader2Id, setLeader2Id] = useState<string>("none")
  const [sectorId, setSectorId] = useState<string>("none")

  const [geocoding, setGeocoding] = useState<boolean>(false)
  const [saving, setSaving] = useState<boolean>(false)

  useEffect(() => {
    if (open) {
      if (homeGroup) {
        setMeetingDay(homeGroup.meeting_day ?? 3)
        setStartTime(homeGroup.start_time || "20:00")
        setLocationText(homeGroup.location_text || "")
        setLat(homeGroup.lat)
        setLng(homeGroup.lng)
        setLeader1Id(homeGroup.leader_1_id || "")
        setLeader2Id(homeGroup.leader_2_id || "none")
        setSectorId(homeGroup.sector_id || "none")
      } else {
        setMeetingDay(3)
        setStartTime("20:00")
        setLocationText("")
        setLat(null)
        setLng(null)
        setLeader1Id("")
        setLeader2Id("none")
        setSectorId("none")
      }
    }
  }, [open, homeGroup])

  const handleGeocodeAddress = async () => {
    if (!locationText.trim()) {
      toast.error("Por favor, digite o endereço antes de buscar as coordenadas.")
      return
    }

    // 1. Detectar coordenadas diretas ou coladas do Google Maps (ex: -19.9264, -44.0294)
    const coordRegex = /(-?\d{1,2}\.\d+)[,\s]+(-?\d{1,3}\.\d+)/
    const coordMatch = locationText.match(coordRegex)
    if (coordMatch) {
      const parsedLat = parseFloat(coordMatch[1])
      const parsedLng = parseFloat(coordMatch[2])
      if (parsedLat >= -90 && parsedLat <= 90 && parsedLng >= -180 && parsedLng <= 180) {
        setLat(parsedLat)
        setLng(parsedLng)
        toast.success("Coordenadas identificadas com sucesso!")
        return
      }
    }

    setGeocoding(true)
    try {
      // 2. Limpar prefixos institucionais do tipo "GC Nome -", "Grupo Caseiro X -"
      let clean = locationText
        .replace(/^(GC|Grupo Caseiro|Igreja na Casa|Comunhão)\s*[^-\n:]*[-:]\s*/i, "")
        .trim()

      clean = clean.replace(/^[^-]+-\s*/, (match) => {
        if (/rua|av|avenida|alameda|praça|praca|estrada|rodovia/i.test(match)) {
          return match
        }
        return ""
      }).trim()

      // Identificar cidades da Região Metropolitana
      const metroCities = [
        "contagem",
        "betim",
        "santa luzia",
        "nova lima",
        "sabará",
        "sabara",
        "ibirité",
        "ibirite",
        "ribeirão das neves",
        "ribeirao das neves",
        "vespasiano",
        "lagoa santa",
        "belo horizonte",
        "sarzedo",
        "brumadinho",
      ]

      const lower = clean.toLowerCase()
      const foundCity = metroCities.find((c) => lower.includes(c))
      const citySuffix = foundCity ? (lower.includes("mg") ? "" : ", MG") : ", Belo Horizonte, MG"

      // Construção de consultas progressivas
      const queries: string[] = []

      // Q1: Endereço limpo direto
      queries.push(`${clean}${citySuffix}`)

      // Q2: Rua + Número + Cidade (remover bairro que com frequência falha no OSM)
      const streetMatch = clean.match(/(rua|av|avenida|alameda|praça|praca|estrada|rodovia)\s+[^,]+/i)
      const numberMatch = clean.match(/\b\d{1,5}\b/)
      const cityName = foundCity ? foundCity : "Belo Horizonte"

      if (streetMatch) {
        const street = streetMatch[0]
        const num = numberMatch ? `, ${numberMatch[0]}` : ""
        queries.push(`${street}${num}, ${cityName}, MG`)
        queries.push(`${street}, ${cityName}, MG`)

        const expandedStreet = street
          .replace(/\bDr\.\s*/gi, "Doutor ")
          .replace(/\bAv\.\s*/gi, "Avenida ")
          .replace(/\bCel\.\s*/gi, "Coronel ")
          .replace(/\bProf\.\s*/gi, "Professor ")
        queries.push(`${expandedStreet}${num}, ${cityName}, MG`)
        queries.push(`${expandedStreet}, ${cityName}, MG`)
      }

      // Q5: Bairro + Cidade
      const parts = clean.split(",").map((p) => p.trim())
      if (parts.length >= 2) {
        queries.push(`${parts[parts.length - 2]}, ${cityName}, MG`)
      }

      let found = false
      for (const query of queries) {
        if (found) break
        const response = await fetch(
          `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1`,
          { headers: { "User-Agent": "igrejaBH-app" } }
        )
        const data = await response.json()
        if (data && data.length > 0 && data[0].lat && data[0].lon) {
          setLat(parseFloat(data[0].lat))
          setLng(parseFloat(data[0].lon))
          toast.success("Coordenadas encontradas no mapa!")
          found = true
        }
      }

      if (!found) {
        toast.error(
          "Não conseguimos achar no mapa automaticamente. Você pode colar as coordenadas (ex: -19.924, -44.027) diretamente no endereço."
        )
      }
    } catch (err) {
      console.error("Geocoding error:", err)
      toast.error("Erro ao buscar coordenadas no mapa.")
    } finally {
      setGeocoding(false)
    }
  }

  const handleSave = async () => {
    if (!locationText.trim()) {
      toast.error("Por favor, informe o endereço ou bairro do Grupo Caseiro.")
      return
    }

    if (isTier3 && !leader1Id) {
      toast.error("Por favor, selecione pelo menos o Líder 1.")
      return
    }

    setSaving(true)
    try {
      const payload: Partial<HomeGroup> = {
        meeting_day: meetingDay,
        start_time: startTime,
        location_text: locationText.trim(),
        lat: lat,
        lng: lng,
      }

      if (isTier3) {
        payload.leader_1_id = leader1Id || null
        payload.leader_2_id = leader2Id !== "none" ? leader2Id : null
        payload.sector_id = sectorId !== "none" ? sectorId : null
      }

      if (isEditing && homeGroup) {
        const { error } = await supabase
          .from("home_groups")
          .update(payload)
          .eq("id", homeGroup.id)

        if (error) throw error
        toast.success("Informações do Grupo Caseiro atualizadas com sucesso!")
      } else {
        const { error } = await supabase.from("home_groups").insert(payload)
        if (error) throw error
        toast.success("Novo Grupo Caseiro criado com sucesso!")
      }

      onSuccess()
      onOpenChange(false)
    } catch (err: unknown) {
      console.error("Erro ao salvar grupo:", err)
      const message = err instanceof Error ? err.message : "Erro desconhecido."
      toast.error(`Não foi possível salvar: ${message}`)
    } finally {
      setSaving(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] sm:max-h-[85vh] w-full max-w-[calc(100%-1.5rem)] sm:max-w-2xl md:max-w-3xl flex flex-col p-0 overflow-hidden rounded-2xl gap-0 shadow-2xl">
        <DialogHeader className="px-5 py-4 sm:px-6 border-b border-border/60 shrink-0 bg-background/95 backdrop-blur-xs">
          <DialogTitle className="text-xl sm:text-2xl font-bold tracking-tight text-foreground">
            {isEditing ? "Editar Dados do Grupo Caseiro" : "Novo Grupo Caseiro"}
          </DialogTitle>
          <DialogDescription className="text-xs sm:text-sm text-muted-foreground mt-0.5">
            {isEditing
              ? "Atualize o dia, horário e endereço das reuniões semanais."
              : "Cadastre um novo Grupo Caseiro na vida da igreja."}
          </DialogDescription>
        </DialogHeader>

        {/* Corpo com Scroll Integrado ao Modal */}
        <div className="flex-1 overflow-y-auto px-5 py-4 sm:px-6 space-y-4">
          {/* Liderança e Setor (Apenas Nível 3 - Diáconos, Presbíteros, Devs) */}
          {isTier3 && (
            <div className="space-y-4 rounded-xl border border-border/80 bg-card p-4 sm:p-5 shadow-xs">
              <div className="flex items-center gap-2 border-b border-border/50 pb-2">
                <Users className="h-4 w-4 text-primary" />
                <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">
                  Liderança e Setor
                </h4>
              </div>

              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                {/* Líder 1 */}
                <div className="space-y-1.5">
                  <Label className="text-xs font-medium text-foreground">
                    Líder 1 (Principal) <span className="text-destructive">*</span>
                  </Label>
                  <Select value={leader1Id} onValueChange={setLeader1Id}>
                    <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                      <SelectValue placeholder="Selecione o Líder 1" />
                    </SelectTrigger>
                    <SelectContent className="max-h-60">
                      {allProfiles
                        .filter((p) => !p.father_id || !!p.baptism_date)
                        .map((p) => (
                          <SelectItem key={p.id} value={p.id}>
                            {p.full_name}
                          </SelectItem>
                        ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Líder 2 */}
                <div className="space-y-1.5">
                  <Label className="text-xs font-medium text-foreground">Líder 2 (Cônjuge ou Co-líder)</Label>
                  <Select value={leader2Id} onValueChange={setLeader2Id}>
                    <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                      <SelectValue placeholder="Selecione o Líder 2 (opcional)" />
                    </SelectTrigger>
                    <SelectContent className="max-h-60">
                      <SelectItem value="none">Nenhum</SelectItem>
                      {allProfiles
                        .filter((p) => (!p.father_id || !!p.baptism_date) && p.id !== leader1Id)
                        .map((p) => (
                          <SelectItem key={p.id} value={p.id}>
                            {p.full_name}
                          </SelectItem>
                        ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Setor */}
                <div className="space-y-1.5 sm:col-span-2">
                  <Label className="text-xs font-medium text-foreground">Setor da Cidade</Label>
                  <Select value={sectorId} onValueChange={setSectorId}>
                    <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                      <SelectValue placeholder="Selecione o Setor" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="none">Sem setor definido</SelectItem>
                      {sectors.map((s) => (
                        <SelectItem key={s.id} value={s.id}>
                          {s.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </div>
          )}

          {/* Dia e Horário */}
          <div className="space-y-4 rounded-xl border border-border/80 bg-card p-4 sm:p-5 shadow-xs">
            <div className="flex items-center gap-2 border-b border-border/50 pb-2">
              <Calendar className="h-4 w-4 text-primary" />
              <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">
                Dia e Horário das Reuniões
              </h4>
            </div>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div className="space-y-1.5">
                <Label className="text-xs font-medium text-foreground">Dia da Semana</Label>
                <Select
                  value={String(meetingDay)}
                  onValueChange={(val) => setMeetingDay(parseInt(val, 10))}
                >
                  <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                    <SelectValue placeholder="Selecione o dia" />
                  </SelectTrigger>
                  <SelectContent>
                    {DAYS_OF_WEEK.map((d) => (
                      <SelectItem key={d.value} value={d.value}>
                        {d.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="startTime" className="text-xs font-medium text-foreground">
                  Horário de Início
                </Label>
                <div className="relative">
                  <Clock className="absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="startTime"
                    type="time"
                    value={startTime}
                    onChange={(e) => setStartTime(e.target.value)}
                    className="h-11 min-h-[44px] rounded-xl pl-10 text-sm"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Endereço e Localização */}
          <div className="space-y-4 rounded-xl border border-border/80 bg-card p-4 sm:p-5 shadow-xs">
            <div className="flex items-center gap-2 border-b border-border/50 pb-2">
              <MapPin className="h-4 w-4 text-primary" />
              <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">
                Endereço da Reunião
              </h4>
            </div>

            <div className="space-y-2">
              <Label htmlFor="locationText" className="text-xs font-medium text-foreground">
                Endereço Completo (Rua, Número, Bairro) <span className="text-destructive">*</span>
              </Label>
              <div className="flex flex-col gap-2.5 sm:flex-row">
                <Input
                  id="locationText"
                  value={locationText}
                  onChange={(e) => setLocationText(e.target.value)}
                  placeholder="Ex: Av. Miguel Perrela, 455 - Castelo, BH"
                  className="h-11 min-h-[44px] flex-1 rounded-xl text-sm"
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={handleGeocodeAddress}
                  disabled={geocoding || !locationText.trim()}
                  className="h-11 min-h-[44px] shrink-0 gap-1.5 rounded-xl px-4 text-xs font-medium"
                >
                  {geocoding ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Search className="h-4 w-4 text-primary" />
                  )}
                  <span>Buscar no Mapa</span>
                </Button>
              </div>
            </div>

            {lat && lng ? (
              <div className="flex items-center gap-2.5 rounded-xl bg-card border border-border/80 p-3 text-xs text-foreground">
                <MapPin className="h-4 w-4 shrink-0 text-primary" />
                <span>
                  Coordenadas salvas: {lat.toFixed(4)}, {lng.toFixed(4)} (visível no mapa interativo)
                </span>
              </div>
            ) : (
              <p className="text-[11px] text-muted-foreground">
                Preencha o endereço e acione Buscar no Mapa para localizar as coordenadas no mapa interativo.
              </p>
            )}
          </div>
        </div>

        {/* Rodapé Fixo Docked com Cancelar e Salvar */}
        <DialogFooter className="px-5 py-3.5 sm:px-6 border-t border-border/60 shrink-0 bg-muted/20 backdrop-blur-xs flex flex-col-reverse sm:flex-row gap-2 sm:justify-end mt-0">
          <Button
            type="button"
            variant="outline"
            onClick={() => onOpenChange(false)}
            className="h-11 min-h-[44px] w-full sm:w-auto text-xs rounded-xl px-5"
          >
            Cancelar
          </Button>
          <Button
            type="button"
            onClick={handleSave}
            disabled={saving}
            className="h-11 min-h-[44px] w-full sm:w-auto text-xs font-semibold rounded-xl px-6"
          >
            {saving ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Salvando...
              </>
            ) : (
              "Salvar Grupo Caseiro"
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
