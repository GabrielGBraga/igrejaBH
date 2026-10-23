import { useState, useEffect, useMemo } from "react"
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
import { Checkbox } from "@/components/ui/checkbox"
import { SearchableSelect } from "@/components/ui/searchable-select"
import {
  getHomeGroupDisplayName,
  getHomeGroupFullLabel,
  getHomeGroupSearchKeywords,
} from "@/lib/homeGroupUtils"
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
  Calendar,
  RotateCcw,
  Check,
  BookOpen,
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
  initialTransformToLinked?: boolean
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
  initialTransformToLinked = false,
  lockGroupSelectionOnCreate = false,
  onSuccess,
}: DiscipleEditorDialogProps) {
  const isEditing = !!disciple
  const isTransformingLinked = Boolean(initialTransformToLinked || (disciple && disciple.is_church_linked === false))

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
        const shouldTransformLinked = Boolean(initialTransformToLinked || disciple.is_church_linked === false)

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
        setIsChurchLinked(shouldTransformLinked ? true : (disciple.is_church_linked !== false))

        if (shouldTransform) {
          toast.info("Transição ativada! Defina o discipulador e confirme a data do batismo.")
        } else if (shouldTransformLinked) {
          setShowOptionalFields(true)
          toast.info("Transição ativada! Defina o Grupo Caseiro e o Discipulador para vincular o irmão.")
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
  }, [open, disciple, defaultHomeGroupId, homeGroups, fellowships, initialTransformToBaptized, initialTransformToLinked])

  // Tratamento da mudança de gênero para auto-ajustar discipulador, cônjuge e companheiro(s) de obra
  const handleGenderChange = (newGender: "M" | "F") => {
    setGender(newGender)

    // Se o discipulador selecionado não for do mesmo gênero, reseta
    if (disciplerId !== "none") {
      const dProf = allProfiles.find((p) => p.id === disciplerId)
      if (dProf?.gender && dProf.gender !== newGender) {
        setDisciplerId("none")
      }
    }

    // Se o cônjuge selecionado não for do gênero oposto, reseta
    if (spouseId !== "none") {
      const sProf = allProfiles.find((p) => p.id === spouseId)
      if (sProf?.gender && sProf.gender === newGender) {
        setSpouseId("none")
      }
    }

    // Se houver companheiro(s) de obra com gênero diferente do novo, remove
    if (selectedFellowships.length > 0) {
      const validFellowships = selectedFellowships.filter((fid) => {
        const fProf = allProfiles.find((p) => p.id === fid)
        return !fProf?.gender || fProf.gender === newGender
      })
      if (validFellowships.length !== selectedFellowships.length) {
        setSelectedFellowships(validFellowships)
      }
    }
  }

  // Lista de irmãos disponíveis para discipulador (somente mesmo gênero)
  const availableDisciplers = useMemo(() => {
    return allProfiles
      .filter((p) => {
        if (p.id === disciple?.id) return false
        if (checkIsChild(p)) return false
        if (p.id === disciplerId) return true
        return gender ? p.gender === gender : true
      })
      .sort((a, b) => a.full_name.localeCompare(b.full_name))
  }, [allProfiles, disciple?.id, disciplerId, gender])

  // Lista de irmãos disponíveis para cônjuge (somente gênero oposto)
  const availableSpouses = useMemo(() => {
    const oppositeGender = gender === "M" ? "F" : "M"
    return allProfiles
      .filter((p) => {
        if (p.id === disciple?.id) return false
        if (checkIsChild(p)) return false
        if (p.id === spouseId) return true
        return p.gender === oppositeGender
      })
      .sort((a, b) => a.full_name.localeCompare(b.full_name))
  }, [allProfiles, disciple?.id, spouseId, gender])

  // Lista de irmãos disponíveis para companheiro(s) de obra (somente mesmo gênero)
  const availableCompanions = useMemo(() => {
    return allProfiles
      .filter(
        (p) =>
          p.id !== disciple?.id &&
          !selectedFellowships.includes(p.id) &&
          !checkIsChild(p) &&
          (gender ? p.gender === gender : true)
      )
      .sort((a, b) => a.full_name.localeCompare(b.full_name))
  }, [allProfiles, disciple?.id, selectedFellowships, gender])

  // Mapeamento rápido de perfis e líderes
  const profileMap = useMemo(() => {
    const map = new Map<string, Profile>()
    allProfiles.forEach((p) => map.set(p.id, p))
    return map
  }, [allProfiles])

  const homeGroupMap = useMemo(() => {
    const map = new Map<string, (typeof homeGroups)[0]>()
    homeGroups.forEach((hg) => map.set(hg.id, hg))
    return map
  }, [homeGroups])

  const leaderIds = useMemo(() => {
    const set = new Set<string>()
    homeGroups.forEach((g) => {
      if (g.leader_1_id) set.add(g.leader_1_id)
      if (g.leader_2_id) set.add(g.leader_2_id)
    })
    return set
  }, [homeGroups])

  // Opções para o Seletor com pesquisa de Grupo Caseiro (com nome dos líderes)
  const homeGroupOptions = useMemo(() => {
    return homeGroups.map((hg) => {
      const displayName = getHomeGroupDisplayName(hg, profileMap)
      const loc = hg.location_text ? hg.location_text.split("-")[0].trim() : ""
      return {
        value: hg.id,
        label: displayName,
        description: loc || undefined,
        keywords: getHomeGroupSearchKeywords(hg, profileMap),
      }
    })
  }, [homeGroups, profileMap])

  // Opções de Discipulador (exibindo o grupo caseiro no lugar do telefone/número)
  const disciplerOptions = useMemo(() => {
    return [
      { value: "none", label: "Nenhum no momento", keywords: "nenhum sem discipulador" },
      ...availableDisciplers.map((p) => {
        const hg = p.home_group_id ? homeGroupMap.get(p.home_group_id) : undefined
        const hgLabel = hg ? getHomeGroupFullLabel(hg, profileMap) : "Sem Grupo Caseiro"
        const hgKeywords = hg ? getHomeGroupSearchKeywords(hg, profileMap) : "sem grupo caseiro"
        return {
          value: p.id,
          label: p.full_name,
          description: hgLabel,
          badge: p.is_presbyter ? "Presbítero" : leaderIds.has(p.id) ? "Líder de GC" : undefined,
          keywords: `${hgLabel} ${hgKeywords} ${p.phone || ""}`.trim(),
        }
      }),
    ]
  }, [availableDisciplers, leaderIds, homeGroupMap, profileMap])

  // Opções de Cônjuge
  const spouseOptions = useMemo(() => {
    return [
      { value: "none", label: "Não é casado(a) / Nenhum", keywords: "solteiro nao casado nenhum" },
      ...availableSpouses.map((p) => ({
        value: p.id,
        label: p.full_name,
        description: p.phone ? formatPhone(p.phone) : undefined,
        keywords: p.phone || "",
      })),
    ]
  }, [availableSpouses])

  // Opções de Companheiro de Obra
  const companionOptions = useMemo(() => {
    return [
      { value: "none", label: "Selecione para adicionar" },
      ...availableCompanions.map((p) => ({
        value: p.id,
        label: p.full_name,
        description: p.phone ? formatPhone(p.phone) : undefined,
        keywords: p.phone || "",
      })),
    ]
  }, [availableCompanions])

  // Opções de Pai (Crianças)
  const fatherOptions = useMemo(() => {
    return [
      { value: "none", label: "Não informado" },
      ...allProfiles
        .filter((p) => !checkIsChild(p) && p.gender === "M")
        .map((p) => ({
          value: p.id,
          label: p.full_name,
          description: p.phone ? formatPhone(p.phone) : undefined,
          keywords: p.phone || "",
        })),
    ]
  }, [allProfiles])

  // Opções de Mãe (Crianças)
  const motherOptions = useMemo(() => {
    return [
      { value: "none", label: "Não informada" },
      ...allProfiles
        .filter((p) => !checkIsChild(p) && p.gender === "F")
        .map((p) => ({
          value: p.id,
          label: p.full_name,
          description: p.phone ? formatPhone(p.phone) : undefined,
          keywords: p.phone || "",
        })),
    ]
  }, [allProfiles])

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

    if (isTransformingLinked && !isChild) {
      if ((!disciplerId || disciplerId === "none") && !disciple?.is_presbyter) {
        toast.error("Por favor, selecione um Discipulador para vincular o irmão à igreja.")
        return
      }
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
      <DialogContent className="h-[90vh] sm:h-[85vh] max-h-[90vh] sm:max-h-[85vh] w-full max-w-[calc(100%-1.5rem)] sm:max-w-2xl md:max-w-3xl flex flex-col p-0 overflow-hidden rounded-2xl gap-0 shadow-2xl">
        <DialogHeader className="px-5 py-4 sm:px-6 border-b border-border/60 shrink-0 bg-background/95 backdrop-blur-xs">
          <DialogTitle className="text-xl sm:text-2xl font-bold tracking-tight text-foreground">
            {isTransformingLinked
              ? "Integrar Discípulo à Comunhão"
              : isEditing
              ? "Editar Irmão e Vínculos"
              : "Adicionar Irmão ao Grupo"}
          </DialogTitle>
          <DialogDescription className="text-xs sm:text-sm text-muted-foreground mt-0.5">
            {isTransformingLinked
              ? `Integre ${disciple?.full_name || "este irmão"} à comunhão da igreja local definindo seu Grupo Caseiro e discipulador para acompanhamento mútuo.`
              : isEditing
              ? "Atualize os dados e os vínculos de cuidado mútuo (juntas e ligamentos) no Corpo."
              : "Preencha as informações básicas para incluir o irmão na vida e comunhão do Grupo Caseiro."}
          </DialogDescription>
        </DialogHeader>

        {/* Corpo com Scroll Integrado ao Modal */}
        <div className="flex-1 min-h-0 overflow-y-auto px-5 py-4 sm:px-6 space-y-4 overscroll-contain">
          {/* Banner de Acolhimento na Comunhão */}
          {isTransformingLinked && (
            <div className="rounded-xl border border-border/80 bg-muted/40 p-3.5 text-xs text-foreground flex items-start gap-2.5">
              <BookOpen className="h-4 w-4 text-primary shrink-0 mt-0.5" />
              <div>
                <p className="font-semibold text-foreground">
                  Acolhimento na Comunhão da Igreja
                </p>
                <p className="text-[11px] text-muted-foreground mt-0.5 leading-relaxed">
                  Defina o Grupo Caseiro e o Discipulador para integrar este irmão plenamente na comunhão do Corpo.
                </p>
              </div>
            </div>
          )}

          {/* 1. Seletor: Adulto/Jovem vs Criança (Apenas ao criar novo) */}
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
                  ? "border-border/80 bg-muted/30"
                  : "border-border/80 bg-card"
              }`}
            >
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                <div className="flex items-center gap-2.5">
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                    {isChild ? <Baby className="h-4 w-4" /> : <Check className="h-4 w-4" />}
                  </div>
                  <div>
                    <h5 className="text-xs font-semibold text-foreground">
                      {isChild ? "Registrado como Criança" : "Batismo Registrado"}
                    </h5>
                    <p className="text-[11px] text-muted-foreground">
                      {isChild
                        ? "Após o batismo, confirme para liberar os vínculos de discipulado."
                        : "Vínculos de discipulador e companheiro(s) de obra liberados abaixo."}
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
                    className="h-11 min-h-[44px] shrink-0 rounded-xl font-semibold text-xs shadow-xs px-4"
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
                    className="h-11 min-h-[44px] shrink-0 gap-1 rounded-xl border-border text-xs font-medium text-muted-foreground hover:text-foreground"
                  >
                    <RotateCcw className="h-3 w-3" />
                    <span>Desfazer</span>
                  </Button>
                )}
              </div>

              {/* Campo Rápido de Data de Batismo quando em transição */}
              {!isChild && (
                <div className="mt-3 pt-2.5 border-t border-border/50 flex items-center gap-2.5">
                  <Label htmlFor="baptismDateQuick" className="text-xs font-medium text-foreground shrink-0">
                    Data do Batismo:
                  </Label>
                  <Input
                    id="baptismDateQuick"
                    type="date"
                    value={baptismDate}
                    onChange={(e) => setBaptismDate(e.target.value)}
                    className="h-11 min-h-[44px] max-w-[180px] rounded-lg bg-background text-xs"
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
                    onClick={() => handleGenderChange("M")}
                  >
                    Masculino
                  </Button>
                  <Button
                    type="button"
                    variant={gender === "F" ? "secondary" : "outline"}
                    className="h-11 min-h-[44px] rounded-xl font-medium text-xs sm:text-sm"
                    onClick={() => handleGenderChange("F")}
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
                <SearchableSelect
                  options={homeGroupOptions}
                  value={homeGroupId}
                  onValueChange={setHomeGroupId}
                  placeholder="Buscar Grupo Caseiro por líder ou bairro..."
                  disabled={!isEditing && lockGroupSelectionOnCreate}
                  clearable={false}
                />
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
                  {/* Discipulador (somente mesmo gênero) */}
                  <div className="space-y-1.5">
                    <Label className="text-xs font-medium text-foreground">
                      Quem é o Discipulador(a)? <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <SearchableSelect
                      options={disciplerOptions}
                      value={disciplerId}
                      onValueChange={setDisciplerId}
                      placeholder={gender === "M" ? "Buscar discipulador pelo nome..." : "Buscar discipuladora pelo nome..."}
                      clearable={true}
                    />
                    {disciplerId && disciplerId !== "none" && (() => {
                      const dProf = profileMap.get(disciplerId)
                      if (!dProf) return null
                      const dHg = dProf.home_group_id ? homeGroupMap.get(dProf.home_group_id) : undefined
                      const dHgName = dHg ? getHomeGroupFullLabel(dHg, profileMap) : "Sem Grupo Caseiro"
                      return (
                        <p className="text-[11px] text-muted-foreground flex items-center gap-1.5 pt-0.5">
                          <span className="font-medium text-foreground/80">Grupo Caseiro:</span>
                          <span className="text-muted-foreground truncate">{dHgName}</span>
                        </p>
                      )
                    })()}
                  </div>

                  {/* Cônjuge (somente gênero oposto) */}
                  <div className="space-y-1.5">
                    <Label className="text-xs font-medium text-foreground">
                      É casado(a)? Cônjuge: <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <SearchableSelect
                      options={spouseOptions}
                      value={spouseId}
                      onValueChange={setSpouseId}
                      placeholder={gender === "M" ? "Buscar esposa pelo nome..." : "Buscar marido pelo nome..."}
                      clearable={true}
                    />
                  </div>
                </div>

                {/* Companheiro(s) de Obra (somente mesmo gênero) */}
                <div className="space-y-2.5 border-t border-border/60 pt-3">
                  <Label className="text-xs font-medium text-foreground">
                    Companheiro(s) de obra: <span className="text-muted-foreground font-normal">(Opcional)</span>
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

                  {/* Seletor para adicionar novo companheiro de obra */}
                  <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                    <div className="flex-1 min-w-0">
                      <SearchableSelect
                        options={companionOptions}
                        value={companionToAdd}
                        onValueChange={setCompanionToAdd}
                        placeholder={gender === "M" ? "Buscar companheiro de obra..." : "Buscar companheira de obra..."}
                        clearable={false}
                      />
                    </div>
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
                    <SearchableSelect
                      options={fatherOptions}
                      value={fatherId}
                      onValueChange={setFatherId}
                      placeholder="Buscar pai pelo nome..."
                      clearable={true}
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label className="text-xs font-medium text-foreground">
                      Mãe <span className="text-muted-foreground font-normal">(Opcional)</span>
                    </Label>
                    <SearchableSelect
                      options={motherOptions}
                      value={motherId}
                      onValueChange={setMotherId}
                      placeholder="Buscar mãe pelo nome..."
                      clearable={true}
                    />
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

                {isTier3 && !isTransformingLinked && (
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
                    className="h-11 min-h-[44px] text-xs text-destructive hover:bg-destructive/10 shrink-0"
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
                      className="h-11 min-h-[44px] flex-1 text-xs font-medium rounded-xl"
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
                      className="h-11 min-h-[44px] flex-1 text-xs rounded-xl"
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
            ) : isTransformingLinked ? (
              "Integrar à Comunhão"
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
