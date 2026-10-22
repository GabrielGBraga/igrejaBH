import { useEffect, useState, type ReactNode } from "react"
import { useNavigate } from "react-router-dom"
import supabase from "@/lib/supabase"
import { disableRestrictedGroupMode } from "@/lib/restrictedMode"
import { ChurchAvatar } from "@/components/ui/church-avatar"
import { ThemeToggle } from "@/components/ThemeToggle"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { LogOut } from "lucide-react"

interface RestrictedGroupLayoutProps {
  children: ReactNode
}

interface UserProfile {
  id: string
  full_name: string
  avatar_url?: string | null
}

export function RestrictedGroupLayout({ children }: RestrictedGroupLayoutProps) {
  const navigate = useNavigate()
  const [profile, setProfile] = useState<UserProfile | null>(null)

  useEffect(() => {
    let active = true

    async function loadUser() {
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession()

        if (session?.user && active) {
          const { data } = await supabase
            .from("profiles")
            .select("id, full_name, avatar_url")
            .eq("user_id", session.user.id)
            .single()

          if (data && active) {
            setProfile(data)
          }
        }
      } catch (err) {
        console.error("Erro ao carregar usuário no layout restrito:", err)
      }
    }

    loadUser()

    return () => {
      active = false
    }
  }, [])

  const handleLogout = async () => {
    try {
      disableRestrictedGroupMode()
      await supabase.auth.signOut()
    } finally {
      navigate("/entrar", { replace: true })
    }
  }

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .filter(Boolean)
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .substring(0, 2)
  }

  return (
    <div className="flex min-h-screen w-full flex-col bg-background text-foreground overflow-x-hidden">
      {/* Barra Superior Minimalista e Isolada */}
      <header className="sticky top-0 z-40 w-full border-b border-border/80 bg-background/85 backdrop-blur-md">
        <div className="mx-auto flex h-16 w-full max-w-6xl items-center justify-between px-4 sm:px-6">
          {/* Identificação da Igreja e do Modo (Sem links de navegação externa) */}
          <div className="flex items-center gap-3">
            <ChurchAvatar size="md" variant="subtle" />
            <div className="flex flex-col min-w-0">
              <span className="truncate text-base font-bold tracking-tight text-foreground leading-none">
                Igreja em BH
              </span>
              <span className="truncate text-[11px] font-medium text-primary mt-0.5 uppercase tracking-wider">
                Gestão do Grupo Caseiro
              </span>
            </div>
          </div>

          {/* Controles da Direita: Perfil Estático, Tema e Sair */}
          <div className="flex items-center gap-2 sm:gap-3">
            {profile && (
              <div className="hidden sm:flex items-center gap-2.5 rounded-xl border border-border/60 bg-muted/30 px-3 py-1.5">
                <Avatar className="size-7 border border-border shadow-2xs">
                  <AvatarImage src={profile.avatar_url || undefined} />
                  <AvatarFallback className="bg-primary/20 text-[10px] font-bold text-primary">
                    {getInitials(profile.full_name)}
                  </AvatarFallback>
                </Avatar>
                <span className="max-w-[140px] truncate text-xs font-semibold text-foreground">
                  {profile.full_name}
                </span>
              </div>
            )}

            <ThemeToggle />

            <Button
              type="button"
              variant="outline"
              onClick={handleLogout}
              className="h-11 min-h-[44px] gap-2 rounded-xl border-border/80 px-3 text-xs font-semibold text-muted-foreground hover:bg-destructive/10 hover:text-destructive hover:border-destructive/30 transition-colors"
              title="Encerrar sessão"
            >
              <LogOut className="h-4 w-4" />
              <span className="hidden sm:inline">Sair</span>
            </Button>
          </div>
        </div>
      </header>

      {/* Conteúdo Principal Focado */}
      <main className="mx-auto w-full max-w-6xl flex-1 animate-in p-4 duration-300 fade-in sm:p-6 lg:p-8">
        {children}
      </main>
    </div>
  )
}
