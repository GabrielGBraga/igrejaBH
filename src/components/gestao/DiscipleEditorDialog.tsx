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
import { Checkbox } from "@/components/ui/checkbox"
import {
  User,
  Baby,
  Users,
  Phone,
  ChevronDown,
  ChevronUp,
  Trash2,
  Plus,
  X,
  Loader2,
  Heart,
  Calendar,
  RotateCcw,
  Check,
} from "lucide-react"
import { toast } from "sonner"
import supabase from "@/lib/supabase"
import type { Database } from "@/lib/database.types"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]
type Fellowship = Database["public"]["Tables"]["fellowships"]["Row"]

export interface DiscipleEditorDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  disciple: Profile | null // null = adding new
  homeGroups: HomeGroup[]
  allProfiles: Profile[]
  fellowships: Fellowship[]
  defaultHomeGroupId?: string | null
  isTier3: boolean // true if dev, presbyter, or deacon
  initialTransformToBaptized?: boolean
  lockGroupSelectionOnCreate?: boolean
  onSuccess: () => void
}

// Helpers de formatação
const formatCPF = (value: string) => {
  const clean = value.replace(/\D/g, "").slice(0, 11)
  if (clean.length <= 3) return clean
  if (clean.length <= 6) return `${clean.slice(0, 3)}.${clean.slice(3)}`
  if (clean.length <= 9) return `${clean.slice(0, 3)}.${clean.slice(3, 6)}.${clean.slice(6)}`
  return `${clean.slice(0, 3)}.${clean.slice(3, 6)}.${clean.slice(6, 9)}-${clean.slice(9)}`
}

const formatPhone = (value: string) => {
  const clean = value.replace(/\D/g, "")
  if (clean.length === 0) return ""
  if (clean.length <= 2) return `(${clean}`
  if (clean.length <= 6) return `(${clean.slice(0, 2)}) ${clean.slice(2)}`
  if (clean.length <= 10) return `(${clean.slice(0, 2)}) ${clean.slice(2, 6)}-${clean.slice(6)}`
  return `(${clean.slice(0, 2)}) ${clean.slice(2, 7)}-${clean.slice(7, 11)}`
}

const checkIsChild = (p: Profile) => {
  return !p.baptism_date && !!(p.father_id || p.mother_id)
}

export function DiscipleEditorDialog({
  open,
  onOpenChange,
  disciple,
  homeGroups,
  allProfiles,
  fellowships,
  defaultHomeGroupId,
  isTier3,
  initialTransformToBaptized = false,
  lockGroupSelectionOnCreate = false,
  onSuccess,
}: DiscipleEditorDialogProps) {
  const isEditing = !!disciple

  // Form State
  const [isChild, setIsChild] = useState<boolean>(false)
  const [fullName, setFullName] = useState<string>("")
  const [phone, setPhone] = useState<string>("")
  const [gender, setGender] = useState<"M" | "F">("M")
  const [homeGroupId, setHomeGroupId] = useState<string>("")
  const [disciplerId, setDisciplerId] = useState<string>("none")
  const [spouseId, setSpouseId] = useState<string>("none")
  const [fatherId, setFatherId] = useState<string>("none")
  const [motherId, setMotherId] = useState<string>("none")
  const [selectedFellowships, setSelectedFellowships] = useState<string[]>([])
  const [companionToAdd, setCompanionToAdd] = useState<string>("none")

  // Optional Section
  const [showOptionalFields, setShowOptionalFields] = useState<boolean>(false)
  const [email, setEmail] = useState<string>("")
  const [cpf, setCpf] = useState<string>("")
  const [birthDate, setBirthDate] = useState<string>("")
  const [baptismDate, setBaptismDate] = useState<string>("")
  const [isChurchLinked, setIsChurchLinked] = useState<boolean>(true)

  // Loading & Deletion
  const [saving, setSaving] = useState<boolean>(false)
  const [deleting, setDeleting] = useState<boolean>(false)
  const [confirmDelete, setConfirmDelete] = useState<boolean>(false)

  // Sync state when dialog opens or disciple changes
  useEffect(() => {
    if (open) {
      if (disciple) {
        const isChildProfile = checkIsChild(disciple)
        const shouldTransform = Boolean(initialTransformToBaptized && isChildProfile)

        setIsChild(shouldTransform ? false : isChildProfile)
        setFullName(disciple.full_name || "")
        setPhone(disciple.phone ? formatPhone(disciple.phone) : "")
        setGender((disciple.gender as "M" | "F") || "M")
        setHomeGroupId(disciple.home_group_id || defaultHomeGroupId || "")
        setDisciplerId(disciple.discipler_id || "none")
        setSpouseId(disciple.spouse_id || "none")
        setFatherId(disciple.father_id || "none")
        setMotherId(disciple.mother_id || "none")
        setEmail(disciple.email || "")
        setCpf(disciple.cpf ? formatCPF(disciple.cpf) : "")
        setBirthDate(disciple.birth_date || "")
        setBaptismDate(
          shouldTransform
            ? (disciple.baptism_date || new Date().toISOString().split("T")[0])
            : (disciple.baptism_date || "")
        )
        setIsChurchLinked(disciple.is_church_linked !== false)

        if (shouldTransform) {
          toast.info("Transição ativada! Defina o discipulador e confirme a data do batismo.")
        }

        // Carregar companheiros existentes
        const currentCompanions = fellowships
          .filter(
            (f) => f.member_a_id === disciple.id || f.member_b_id === disciple.id
          )
          .map((f) => (f.member_a_id === disciple.id ? f.member_b_id : f.member_a_id))
        setSelectedFellowships(currentCompanions)
      } else {
        // Reset for new creation
        setIsChild(false)
        setFullName("")
        setPhone("")
        setGender("M")
        setHomeGroupId(defaultHomeGroupId || (homeGroups[0]?.id ?? ""))
        setDisciplerId("none")
        setSpouseId("none")
        setFatherId("none")
        setMotherId("none")
        setSelectedFellowships([])
        setEmail("")
        setCpf("")
        setBirthDate("")
        setBaptismDate("")
        setIsChurchLinked(true)
      }
      setCompanionToAdd("none")
      setConfirmDelete(false)
      setShowOptionalFields(false)
    }
  }, [open, disciple, defaultHomeGroupId, homeGroups, fellowships, initialTransformToBaptized])

  // Lista de irmãos disponíveis para companheiro
  const availableCompanions = allProfiles.filter(
    (p) =>
      p.id !== disciple?.id &&
      !selectedFellowships.includes(p.id) &&
      !checkIsChild(p) &&
      (gender ? p.gender === gender : true)
  )

  const handleAddCompanion = () => {
    if (companionToAdd && companionToAdd !== "none") {
      setSelectedFellowships([...selectedFellowships, companionToAdd])
      setCompanionToAdd("none")
    }
  }

  const handleRemoveCompanion = (idToRemove: string) => {
    setSelectedFellowships(selectedFellowships.filter((id) => id !== idToRemove))
  }

  const handleSave = async () => {
    if (!fullName.trim()) {
      toast.error("O Nome Completo é obrigatório.")
      return
    }

    if (!gender) {
      toast.error("O Sexo é obrigatório.")
      return
    }

    if (!homeGroupId) {
      toast.error("Por favor, selecione um Grupo Caseiro.")
      return
    }

    if (!birthDate.trim()) {
      toast.error("A Data de Nascimento é obrigatória.")
      return
    }

    setSaving(true)
    try {
      const cleanPhone = phone.replace(/\D/g, "") || null
      const cleanCPF = cpf.replace(/\D/g, "") || null
      const cleanEmail = email.trim() ? email.trim().toLowerCase() : null
      const cleanBirth = birthDate.trim() || null
      const cleanBaptism = baptismDate.trim() || null

      let finalBaptism = cleanBaptism
      // Se o perfil era criança e foi marcado para transição como discípulo batizado, garantir data de batismo
      if (!isChild && disciple && checkIsChild(disciple) && !finalBaptism) {
        finalBaptism = new Date().toISOString().split("T")[0]
      }

      const profilePayload = {
        full_name: fullName.trim(),
        phone: cleanPhone,
        gender: gender,
        home_group_id: homeGroupId,
        discipler_id: !isChild && disciplerId !== "none" ? disciplerId : null,
        spouse_id: !isChild && spouseId !== "none" ? spouseId : null,
        marital_status:
          !isChild && spouseId !== "none"
            ? "casado"
            : disciple?.marital_status || "solteiro",
        father_id: isChild ? (fatherId !== "none" ? fatherId : null) : (disciple?.father_id || null),
        mother_id: isChild ? (motherId !== "none" ? motherId : null) : (disciple?.mother_id || null),
        email: cleanEmail,
        cpf: cleanCPF,
        birth_date: cleanBirth,
        baptism_date: finalBaptism,
        is_church_linked: isChurchLinked,
      }

      let savedProfileId = disciple?.id

      if (isEditing && disciple) {
        // Atualiza perfil existente
        const { error: updateError } = await supabase
          .from("profiles")
          .update(profilePayload)
          .eq("id", disciple.id)

        if (updateError) throw updateError

        // Se o cônjuge mudou, atualizar reciprocidade
        if (disciple.spouse_id && disciple.spouse_id !== profilePayload.spouse_id) {
          await supabase
            .from("profiles")
            .update({ spouse_id: null })
            .eq("id", disciple.spouse_id)
        }
        if (profilePayload.spouse_id) {
          await supabase
            .from("profiles")
            .update({ spouse_id: disciple.id, marital_status: "casado" })
            .eq("id", profilePayload.spouse_id)
        }
      } else {
        // Inserir novo perfil provisório
        const { data: inserted, error: insertError } = await supabase
          .from("profiles")
          .insert({
            ...profilePayload,
            user_id: null,
          })
          .select("id")
          .single()

        if (insertError) throw insertError
        savedProfileId = inserted.id

        if (profilePayload.spouse_id && savedProfileId) {
          await supabase
            .from("profiles")
            .update({ spouse_id: savedProfileId, marital_status: "casado" })
            .eq("id", profilePayload.spouse_id)
        }
      }

      // Sincronizar Comunhões / Companheiros (Fellowships)
      if (savedProfileId && !isChild) {
        const existingFellowships = fellowships.filter(
          (f) => f.member_a_id === savedProfileId || f.member_b_id === savedProfileId
        )

        // Comunhões a remover
        const toDelete = existingFellowships.filter((f) => {
          const otherId =
            f.member_a_id === savedProfileId ? f.member_b_id : f.member_a_id
          return !selectedFellowships.includes(otherId)
        })

        for (const f of toDelete) {
          await supabase
            .from("fellowships")
            .delete()
            .match({ member_a_id: f.member_a_id, member_b_id: f.member_b_id })
        }

        // Comunhões a adicionar
        const existingOtherIds = existingFellowships.map((f) =>
          f.member_a_id === savedProfileId ? f.member_b_id : f.member_a_id
        )
        const toAdd = selectedFellowships.filter(
          (id) => !existingOtherIds.includes(id)
        )

        if (toAdd.length > 0) {
          const insertRows = toAdd.map((otherId) => ({
            member_a_id: savedProfileId!,
            member_b_id: otherId,
          }))
          const { error: fErr } = await supabase.from("fellowships").insert(insertRows)
          if (fErr) {
            console.warn("Aviso ao salvar comunhões:", fErr)
          }
        }
      }

      toast.success(
        isEditing
          ? "Dados e vínculos atualizados com sucesso!"
          : "Irmão adicionado com sucesso ao Grupo Caseiro!"
      )
      onSuccess()
      onOpenChange(false)
    } catch (err: unknown) {
      console.error("Erro ao salvar irmão:", err)
      const message = err instanceof Error ? err.message : "Erro desconhecido ao salvar."
      toast.error(`Não foi possível salvar: ${message}`)
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!disciple) return
    setDeleting(true)
    try {
      const { error } = await supabase.from("profiles").delete().eq("id", disciple.id)
      if (error) throw error

      toast.success("Perfil provisório removido com sucesso.")
      onSuccess()
      onOpenChange(false)
    } catch (err: unknown) {
      console.error("Erro ao excluir perfil:", err)
      const message = err instanceof Error ? err.message : "Erro desconhecido."
      toast.error(`Não foi possível excluir: ${message}`)
    } finally {
      setDeleting(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] sm:max-h-[85vh] w-full max-w-[calc(100%-1.5rem)] sm:max-w-2xl md:max-w-3xl flex flex-col p-0 overflow-hidden rounded-2xl gap-0 shadow-2xl">
        <DialogHeader className="px-5 py-4 sm:px-6 border-b border-border/60 shrink-0 bg-background/95 backdrop-blur-xs">
          <DialogTitle className="text-xl sm:text-2xl font-bold tracking-tight text-foreground">
            {isEditing ? "Editar Irmão e Vínculos" : "Adicionar Irmão ao Grupo"}
          </DialogTitle>
          <DialogDescription className="text-xs sm:text-sm text-muted-foreground mt-0.5">
            {isEditing
              ? "Atualize os dados e os vínculos de cuidado mútuo (juntas e ligamentos) no Corpo."
              : "Preencha as informações básicas para incluir o irmão na vida e comunhão do Grupo Caseiro."}
          </DialogDescription>
        </DialogHeader>

        {/* Corpo com Scroll Integrado ao Modal */}
        <div className="flex-1 overflow-y-auto px-5 py-4 sm:px-6 space-y-4">
          {/* 1. Seletor Grande: Adulto/Jovem vs Criança (Apenas ao criar novo) */}
          {!isEditing && (
            <div>
              <Label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                Quem é a pessoa?
              </Label>
              <div className="mt-2 grid grid-cols-2 gap-3">
                <Button
                  type="button"
                  variant={!isChild ? "default" : "outline"}
                  className="h-12 min-h-[48px] gap-2 rounded-xl text-sm font-semibold transition-all shadow-xs"
                  onClick={() => setIsChild(false)}
                >
                  <User className="h-4 w-4" />
                  <span>Adulto / Jovem</span>
                </Button>
                <Button
                  type="button"
                  variant={isChild ? "default" : "outline"}
                  className="h-12 min-h-[48px] gap-2 rounded-xl text-sm font-semibold transition-all shadow-xs"
                  onClick={() => setIsChild(true)}
                >
                  <Baby className="h-4 w-4" />
                  <span>Criança / Filho</span>
                </Button>
              </div>
            </div>
          )}

          {/* 2. Banner de Batismo para Crianças */}
          {isEditing && disciple && (checkIsChild(disciple) || (!isChild && checkIsChild(disciple))) && (
            <div
              className={`rounded-xl border p-3.5 transition-all ${
                isChild
                  ? "border-sky-200 bg-sky-50/70 dark:border-sky-900/60 dark:bg-sky-950/30"
                  : "border-emerald-200 bg-emerald-50/70 dark:border-emerald-900/60 dark:bg-emerald-950/30"
              }`}
            >
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                <div className="flex items-center gap-2.5">
                  <div
                    className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${
                      isChild
                        ? "bg-sky-100 text-sky-700 dark:bg-sky-900 dark:text-sky-300"
                        : "bg-emerald-100 text-emerald-700 dark:bg-emerald-900 dark:text-emerald-300"
                    }`}
                  >
                    {isChild ? <Baby className="h-4 w-4" /> : <Check className="h-4 w-4" />}
                  </div>
                  <div>
                    <h5 className="text-xs font-semibold text-foreground">
                      {isChild ? "Registrado como Criança" : "Batismo Registrado"}
                    </h5>
                    <p className="text-[11px] text-muted-foreground">
                      {isChild
                        ? "Foi batizado(a)? Clique no botão para registrar o batismo."
                        : "Vínculos de discipulador e companheiros liberados abaixo."}
                    </p>
                  </div>
                </div>

                {isChild ? (
                  <Button
                    type="button"
                    onClick={() => {
                      setIsChild(false)
                      if (!baptismDate) {
                        setBaptismDate(new Date().toISOString().split("T")[0])
                      }
                      toast.success("Batismo registrado! Defina o discipulador e salve.")
                    }}
                    className="h-10 min-h-[40px] shrink-0 rounded-xl bg-sky-600 hover:bg-sky-700 text-white font-semibold text-xs shadow-xs px-4"
                  >
                    <span>Registrar Batismo</span>
                  </Button>
                ) : (
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => {
                      setIsChild(true)
                      setBaptismDate("")
                    }}
                    className="h-9 min-h-[36px] shrink-0 gap-1 rounded-xl border-border text-xs font-medium text-muted-foreground hover:text-foreground"
                  >
                    <RotateCcw className="h-3 w-3" />
                    <span>Desfazer</span>
                  </Button>
                )}
              </div>

              {/* Campo Rápido de Data de Batismo quando em transição */}
              {!isChild && (
                <div className="mt-3 pt-2.5 border-t border-emerald-200/60 dark:border-emerald-800/60 flex items-center gap-2.5">
                  <Label htmlFor="baptismDateQuick" className="text-xs font-medium text-foreground shrink-0">
                    Data do Batismo:
                  </Label>
                  <Input
                    id="baptismDateQuick"
                    type="date"
                    value={baptismDate}
                    onChange={(e) => setBaptismDate(e.target.value)}
                    className="h-9 min-h-[36px] max-w-[180px] rounded-lg bg-background text-xs"
                  />
                </div>
              )}
            </div>
          )}

          {/* 3. Dados Básicos em Grid Amplo */}
          <div className="space-y-4 rounded-xl border border-border/80 bg-card p-4 sm:p-5 shadow-xs">
            <div className="flex items-center gap-2 border-b border-border/50 pb-2">
              <User className="h-4 w-4 text-primary" />
              <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">
                Dados Básicos
              </h4>
            </div>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              {/* Nome Completo (Obrigatório) */}
              <div className="space-y-1.5 sm:col-span-2">
                <Label htmlFor="full_name" className="text-xs font-medium text-foreground">
                  Nome Completo <span className="text-destructive">*</span>
                </Label>
                <Input
                  id="full_name"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="Ex: João da Silva"
                  className="h-11 min-h-[44px] rounded-xl text-sm"
                />
              </div>

              {/* Data de Nascimento (Obrigatório) */}
              <div className="space-y-1.5">
                <Label htmlFor="birth_date" className="text-xs font-medium text-foreground">
                  Data de Nascimento <span className="text-destructive">*</span>
                </Label>
                <div className="relative">
                  <Calendar className="absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                  <Input
                    id="birth_date"
                    type="date"
                    value={birthDate}
                    onChange={(e) => setBirthDate(e.target.value)}
                    className="h-11 min-h-[44px] rounded-xl pl-10 text-sm"
                  />
                </div>
              </div>

              {/* Sexo (Obrigatório) */}
              <div className="space-y-1.5">
                <Label className="text-xs font-medium text-foreground">
                  Sexo <span className="text-destructive">*</span>
                </Label>
                <div className="grid grid-cols-2 gap-2">
                  <Button
                    type="button"
                    variant={gender === "M" ? "secondary" : "outline"}
                    className="h-11 min-h-[44px] rounded-xl font-medium text-xs sm:text-sm"
                    onClick={() => setGender("M")}
                  >
                    Masculino
                  </Button>
                  <Button
                    type="button"
                    variant={gender === "F" ? "secondary" : "outline"}
                    className="h-11 min-h-[44px] rounded-xl font-medium text-xs sm:text-sm"
                    onClick={() => setGender("F")}
                  >
                    Feminino
                  </Button>
                </div>
              </div>

              {/* Grupo Caseiro (Obrigatório) */}
              <div className="space-y-1.5 sm:col-span-2">
                <Label className="text-xs font-medium text-foreground">
                  Grupo Caseiro <span className="text-destructive">*</span>
                </Label>
                <Select
                  value={homeGroupId}
                  onValueChange={setHomeGroupId}
                  disabled={!isEditing && lockGroupSelectionOnCreate}
                >
                  <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                    <SelectValue placeholder="Selecione o Grupo Caseiro" />
                  </SelectTrigger>
                  <SelectContent className="max-h-64">
                    {homeGroups.map((hg) => (
                      <SelectItem key={hg.id} value={hg.id}>
                        {hg.location_text || `Grupo Caseiro (${hg.id.slice(0, 5)})`}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>

          {/* 3. Juntas e Ligamentos em Grid Amplo */}
          <div className="space-y-4 rounded-xl border border-border/80 bg-card p-4 sm:p-5 shadow-xs">
            <div className="flex items-center gap-2 border-b border-border/50 pb-2">
              <Users className="h-4 w-4 text-primary" />
              <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">
                Juntas e Ligamentos (Vínculos de Cuidado)
              </h4>
            </div>

            {!isChild ? (
              <>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {/* Discipulador */}
                  <div className="space-y-1.5">
                    <Label className="text-xs font-medium text-foreground">
                      Quem é o Discipulador(a)? <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <Select value={disciplerId} onValueChange={setDisciplerId}>
                      <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                        <SelectValue placeholder="Selecione quem o acompanha" />
                      </SelectTrigger>
                      <SelectContent className="max-h-60">
                        <SelectItem value="none">Nenhum no momento</SelectItem>
                        {allProfiles
                          .filter((p) => p.id !== disciple?.id && !checkIsChild(p))
                          .map((p) => (
                            <SelectItem key={p.id} value={p.id}>
                              {p.full_name}
                            </SelectItem>
                          ))}
                      </SelectContent>
                    </Select>
                  </div>

                  {/* Cônjuge */}
                  <div className="space-y-1.5">
                    <Label className="text-xs font-medium text-foreground">
                      É casado(a)? Cônjuge: <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <Select value={spouseId} onValueChange={setSpouseId}>
                      <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                        <SelectValue placeholder="Selecione o cônjuge" />
                      </SelectTrigger>
                      <SelectContent className="max-h-60">
                        <SelectItem value="none">Não é casado(a) / Nenhum</SelectItem>
                        {allProfiles
                          .filter(
                            (p) =>
                              p.id !== disciple?.id &&
                              !checkIsChild(p) &&
                              (gender === "M" ? p.gender === "F" : p.gender === "M")
                          )
                          .map((p) => (
                            <SelectItem key={p.id} value={p.id}>
                              {p.full_name}
                            </SelectItem>
                          ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                {/* Companheiros de Caminhada */}
                <div className="space-y-2.5 border-t border-border/60 pt-3">
                  <Label className="text-xs font-medium text-foreground">
                    Companheiros(as) de Oração e Comunhão: <span className="text-muted-foreground font-normal">(Opcional)</span>
                  </Label>

                  {/* Chips já adicionados */}
                  {selectedFellowships.length > 0 && (
                    <div className="flex flex-wrap gap-2">
                      {selectedFellowships.map((fid) => {
                        const companionProfile = allProfiles.find((p) => p.id === fid)
                        return (
                          <span
                            key={fid}
                            className="inline-flex items-center gap-1.5 rounded-full bg-secondary/80 px-3 py-1.5 text-xs font-medium text-secondary-foreground border border-border/50"
                          >
                            <Heart className="h-3 w-3 text-primary" />
                            <span>{companionProfile?.full_name || "Irmão"}</span>
                            <button
                              type="button"
                              onClick={() => handleRemoveCompanion(fid)}
                              className="ml-1 rounded-full p-0.5 text-muted-foreground hover:bg-muted hover:text-foreground"
                            >
                              <X className="h-3.5 w-3.5" />
                            </button>
                          </span>
                        )
                      })}
                    </div>
                  )}

                  {/* Seletor para adicionar novo companheiro */}
                  <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                    <Select
                      value={companionToAdd}
                      onValueChange={setCompanionToAdd}
                    >
                      <SelectTrigger className="h-11 min-h-[44px] flex-1 rounded-xl text-xs sm:text-sm">
                        <SelectValue placeholder="Adicionar companheiro(a) de oração..." />
                      </SelectTrigger>
                      <SelectContent className="max-h-48">
                        <SelectItem value="none">Selecione para adicionar</SelectItem>
                        {availableCompanions.map((p) => (
                          <SelectItem key={p.id} value={p.id}>
                            {p.full_name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <Button
                      type="button"
                      variant="outline"
                      onClick={handleAddCompanion}
                      disabled={companionToAdd === "none"}
                      className="h-11 min-h-[44px] shrink-0 gap-1.5 rounded-xl px-4 text-xs font-medium"
                    >
                      <Plus className="h-4 w-4" />
                      <span>Adicionar</span>
                    </Button>
                  </div>
                </div>
              </>
            ) : (
              <>
                {/* Para Crianças: Pai e Mãe */}
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <div className="space-y-1.5">
                    <Label className="text-xs font-medium text-foreground">
                      Pai <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <Select value={fatherId} onValueChange={setFatherId}>
                      <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                        <SelectValue placeholder="Selecione o pai" />
                      </SelectTrigger>
                      <SelectContent className="max-h-52">
                        <SelectItem value="none">Não informado</SelectItem>
                        {allProfiles
                          .filter((p) => !checkIsChild(p) && p.gender === "M")
                          .map((p) => (
                            <SelectItem key={p.id} value={p.id}>
                              {p.full_name}
                            </SelectItem>
                          ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-medium text-foreground">
                      Mãe <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <Select value={motherId} onValueChange={setMotherId}>
                      <SelectTrigger className="h-11 min-h-[44px] rounded-xl text-sm">
                        <SelectValue placeholder="Selecione a mãe" />
                      </SelectTrigger>
                      <SelectContent className="max-h-52">
                        <SelectItem value="none">Não informado</SelectItem>
                        {allProfiles
                          .filter((p) => !checkIsChild(p) && p.gender === "F")
                          .map((p) => (
                            <SelectItem key={p.id} value={p.id}>
                              {p.full_name}
                            </SelectItem>
                          ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </>
            )}
          </div>

          {/* 4. Acordeão: Mais dados opcionais */}
          <div className="rounded-xl border border-border/80 bg-card overflow-hidden shadow-xs">
            <button
              type="button"
              onClick={() => setShowOptionalFields(!showOptionalFields)}
              className="flex w-full items-center justify-between p-4 text-xs font-semibold text-muted-foreground hover:bg-muted/40 transition-colors"
            >
              <div className="flex items-center gap-2">
                <Calendar className="h-4 w-4 text-primary" />
                <span>Mais dados opcionais (Telefone, E-mail, CPF, Data de Batismo)</span>
              </div>
              {showOptionalFields ? (
                <ChevronUp className="h-4 w-4" />
              ) : (
                <ChevronDown className="h-4 w-4" />
              )}
            </button>

            {showOptionalFields && (
              <div className="space-y-4 border-t border-border/70 p-4 sm:p-5">
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {/* Telefone / WhatsApp */}
                  <div className="space-y-1.5 sm:col-span-2">
                    <Label htmlFor="phone" className="text-xs font-medium text-foreground">
                      Telefone / WhatsApp <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <div className="relative">
                      <Phone className="absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                      <Input
                        id="phone"
                        value={phone}
                        onChange={(e) => setPhone(formatPhone(e.target.value))}
                        placeholder="(31) 99999-9999"
                        className="h-11 min-h-[44px] rounded-xl pl-10 text-sm"
                      />
                    </div>
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="cpf" className="text-xs font-medium text-foreground">
                      CPF <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <Input
                      id="cpf"
                      value={cpf}
                      onChange={(e) => setCpf(formatCPF(e.target.value))}
                      placeholder="000.000.000-00"
                      className="h-11 min-h-[44px] rounded-xl text-sm"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="email" className="text-xs font-medium text-foreground">
                      E-mail <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <Input
                      id="email"
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="exemplo@email.com"
                      className="h-11 min-h-[44px] rounded-xl text-sm"
                    />
                  </div>

                  <div className="space-y-1.5 sm:col-span-2">
                    <Label htmlFor="baptismDate" className="text-xs font-medium text-foreground">
                      Data de Batismo <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <Input
                      id="baptismDate"
                      type="date"
                      value={baptismDate}
                      onChange={(e) => setBaptismDate(e.target.value)}
                      className="h-11 min-h-[44px] rounded-xl text-sm"
                    />
                  </div>
                </div>

                {isTier3 && (
                  <div className="flex items-center gap-2 pt-2 border-t border-border/50">
                    <Checkbox
                      id="isChurchLinked"
                      checked={isChurchLinked}
                      onCheckedChange={(checked) => setIsChurchLinked(!!checked)}
                    />
                    <Label
                      htmlFor="isChurchLinked"
                      className="text-xs font-medium cursor-pointer text-foreground"
                    >
                      Vinculado à Vida da Igreja (Desmarque se for apenas visitante em estudos)
                    </Label>
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Exclusão de Perfil Provisório (se user_id IS NULL) */}
          {isEditing && disciple?.user_id === null && (
            <div className="rounded-xl border border-destructive/30 bg-destructive/5 p-4">
              {!confirmDelete ? (
                <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                  <div>
                    <p className="text-xs font-semibold text-destructive">
                      Perfil Provisório (sem conta de acesso cadastrada)
                    </p>
                    <p className="text-[11px] text-muted-foreground">
                      Este irmão ainda não criou login no aplicativo. Você pode remover este cadastro se foi criado por engano.
                    </p>
                  </div>
                  <Button
                    type="button"
                    variant="ghost"
                    onClick={() => setConfirmDelete(true)}
                    className="h-10 min-h-[40px] text-xs text-destructive hover:bg-destructive/10 shrink-0"
                  >
                    <Trash2 className="mr-1.5 h-4 w-4" />
                    Excluir Cadastro
                  </Button>
                </div>
              ) : (
                <div className="space-y-3">
                  <p className="text-xs font-semibold text-destructive">
                    Tem certeza que deseja excluir o cadastro provisório de {disciple.full_name}?
                  </p>
                  <div className="flex items-center gap-2">
                    <Button
                      type="button"
                      variant="destructive"
                      disabled={deleting}
                      onClick={handleDelete}
                      className="h-10 min-h-[40px] flex-1 text-xs font-medium rounded-xl"
                    >
                      {deleting ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : (
                        "Confirmar Exclusão"
                      )}
                    </Button>
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => setConfirmDelete(false)}
                      className="h-10 min-h-[40px] flex-1 text-xs rounded-xl"
                    >
                      Cancelar
                    </Button>
                  </div>
                </div>
              )}
            </div>
          )}
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
            ) : isEditing ? (
              "Salvar Alterações"
            ) : (
              "Salvar e Incluir"
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
