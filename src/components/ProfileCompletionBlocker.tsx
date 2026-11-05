import { useEffect, useState } from "react"
import { useLocation, useNavigate } from "react-router-dom"
import supabase from "@/lib/supabase"
import {
  PROFILE_SECTIONS,
  isSectionComplete,
} from "@/lib/profile-config"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import {
  AlertCircleIcon,
  ArrowRightIcon,
  LogOutIcon,
  UserIcon,
  PhoneIcon,
  MapPinIcon,
  ShieldIcon,
  CheckCircle2Icon,
} from "lucide-react"

export function ProfileCompletionBlocker() {
  const [isOpen, setIsOpen] = useState(false)
  const [loading, setLoading] = useState(true)
  const location = useLocation()
  const navigate = useNavigate()

  // Não bloqueia se o usuário já estiver na página de perfil
  const isProfilePage = location.pathname === "/perfil"

  const handleLogout = async () => {
    await supabase.auth.signOut()
    navigate("/entrar", { replace: true })
  }

  useEffect(() => {
    async function checkProfile() {
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession()
        if (!session?.user) {
          setLoading(false)
          return
        }

        const { data: profile, error } = await supabase
          .from("profiles")
          .select("*")
          .eq("user_id", session.user.id)
          .single()

        if (error) throw error

        if (profile) {
          // Bloqueia apenas discípulos vinculados à igreja.
          // Usuários não vinculados têm acesso liberado sem obrigatoriedade de dados diaconais.
          if (!profile.is_church_linked) {
            setIsOpen(false)
            return
          }

          const hasPending = PROFILE_SECTIONS.some(
            (sec) => !isSectionComplete(profile, sec.key)
          )

          setIsOpen(hasPending && !isProfilePage)
        }
      } catch (error) {
        console.error("Erro ao verificar completitude do perfil:", error)
      } finally {
        setLoading(false)
      }
    }

    checkProfile()

    // Listen for profile updates
    const channel = supabase
      .channel("profile_changes")
      .on(
        "postgres_changes",
        { event: "UPDATE", schema: "public", table: "profiles" },
        () => {
          checkProfile()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [location.pathname, isProfilePage])

  if (loading) return null
  if (!isOpen) return null

  const getSectionIcon = (key: string) => {
    switch (key) {
      case "personal":
        return UserIcon
      case "contact":
        return PhoneIcon
      case "address":
        return MapPinIcon
      default:
        return ShieldIcon
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={() => {}}>
      <DialogContent
        size="md"
        showCloseButton={false}
        className="pointer-events-auto rounded-3xl border-border/50 bg-card/95 backdrop-blur-xl p-5 sm:p-6"
        onPointerDownOutside={(e) => e.preventDefault()}
        onEscapeKeyDown={(e) => e.preventDefault()}
      >
        <DialogHeader className="items-center text-center">
          <div className="mb-3 flex size-14 items-center justify-center rounded-full bg-primary/10">
            <AlertCircleIcon className="size-7 animate-pulse text-primary" />
          </div>
          <DialogTitle className="text-xl sm:text-2xl font-bold tracking-tight">
            Perfil Incompleto
          </DialogTitle>
          <DialogDescription className="pt-1.5 text-xs sm:text-sm text-muted-foreground max-w-sm">
            Precisamos que você preencha suas informações de cadastro para ter acesso total ao sistema. O preenchimento é feito passo a passo.
          </DialogDescription>
        </DialogHeader>

        {/* Etapas do preenchimento */}
        <div className="my-3 space-y-2 rounded-2xl border border-border/50 bg-muted/20 p-3 sm:p-4">
          <p className="text-[11px] font-bold tracking-wider text-muted-foreground uppercase">
            Etapas Obrigatórias (4 categorias):
          </p>
          <div className="grid grid-cols-1 gap-2">
            {PROFILE_SECTIONS.map((sec, idx) => {
              const Icon = getSectionIcon(sec.key)
              return (
                <div
                  key={sec.key}
                  className="flex items-center gap-2.5 rounded-xl border border-border/40 bg-card/60 p-2.5 text-xs"
                >
                  <div className="flex size-6 shrink-0 items-center justify-center rounded-full bg-primary/10 text-[11px] font-bold text-primary">
                    {idx + 1}
                  </div>
                  <Icon className="size-4 text-primary shrink-0" />
                  <div className="min-w-0 flex-1">
                    <p className="font-semibold text-foreground truncate">{sec.label}</p>
                    <p className="text-[10px] text-muted-foreground truncate">{sec.description}</p>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Ações: Ir para preenchimento incremental ou Sair */}
        <div className="flex flex-col gap-2.5 pt-1">
          <Button
            onClick={() => {
              setIsOpen(false)
              navigate("/perfil?complete=true")
            }}
            className="gap-2 rounded-xl py-6 font-bold shadow-lg shadow-primary/20 min-h-[44px]"
          >
            <CheckCircle2Icon className="size-4" />
            Preencher Dados Agora
            <ArrowRightIcon className="size-4 ml-auto" />
          </Button>

          <Button
            variant="ghost"
            onClick={handleLogout}
            className="min-h-[44px] text-xs text-muted-foreground hover:text-destructive gap-1.5"
          >
            <LogOutIcon className="size-3.5" />
            Sair da Conta
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
