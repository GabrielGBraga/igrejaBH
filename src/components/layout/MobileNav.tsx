import { Link, useLocation } from "react-router-dom"
import { Menu, LogOut } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"
import { navItems } from "./NavItems"
import { cn } from "@/lib/utils"
import { useState } from "react"
import { ChurchLogo } from "@/components/icons/ChurchLogo"
import { ThemeToggle } from "@/components/ThemeToggle"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { useCurrentUserProfile } from "@/hooks/useCurrentUserProfile"
import supabase from "@/lib/supabase"

interface MobileNavProps {
  menuOpen?: boolean
  onMenuOpenChange?: (open: boolean) => void
}

export function MobileNav({ menuOpen: controlledOpen, onMenuOpenChange: setControlledOpen }: MobileNavProps) {
  const location = useLocation()
  const [internalOpen, setInternalOpen] = useState(false)
  const { profile, isAdmin, isManagement, canPost } = useCurrentUserProfile()

  const isOpen = controlledOpen !== undefined ? controlledOpen : internalOpen
  const setIsOpen = setControlledOpen !== undefined ? setControlledOpen : setInternalOpen

  const filteredNavItems = navItems.filter((item) => {
    if (item.requireAdmin && !isAdmin) return false
    if (item.requireManagement && !isManagement) return false
    if (item.requireCanPost && !canPost) return false
    return true
  })

  const getInitials = (name?: string) => {
    if (!name) return "D"
    return name
      .split(" ")
      .filter(Boolean)
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  const handleLogout = async () => {
    setIsOpen(false)
    await supabase.auth.signOut()
  }

  return (
    <header className="sticky top-0 z-50 flex h-16 items-center justify-between border-b border-border/80 bg-background/90 px-4 pt-safe backdrop-blur-md md:hidden">
      {/* Brand Logo */}
      <Link
        to="/dashboard"
        className="flex min-h-[44px] items-center outline-none focus-visible:ring-2 focus-visible:ring-primary rounded-md"
        aria-label="Ir para o início"
      >
        <ChurchLogo size="sm" />
      </Link>

      {/* Header Actions: ThemeToggle + UserAvatar + Menu Trigger */}
      <div className="flex items-center gap-1.5 sm:gap-2">
        <ThemeToggle />

        {/* User Profile Avatar Link */}
        <Link
          to="/perfil"
          aria-label="Meu Perfil"
          className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-full outline-none focus-visible:ring-2 focus-visible:ring-primary"
        >
          <Avatar className="h-8 w-8 border border-border shadow-2xs">
            <AvatarImage src={profile?.avatar_url || undefined} alt={profile?.full_name || "Perfil"} />
            <AvatarFallback className="bg-primary/20 text-xs font-bold text-primary">
              {getInitials(profile?.full_name)}
            </AvatarFallback>
          </Avatar>
        </Link>

        {/* Drawer Sheet Menu */}
        <Sheet open={isOpen} onOpenChange={setIsOpen}>
          <SheetTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="min-h-[44px] min-w-[44px] rounded-xl text-foreground"
              aria-label="Abrir menu de navegação"
            >
              <Menu className="h-6 w-6" />
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="w-[300px] p-0 sm:w-[350px] flex flex-col justify-between">
            <div>
              <SheetHeader className="border-b border-border/60 p-5 text-left">
                <SheetTitle className="flex items-center justify-between">
                  <ChurchLogo size="sm" />
                </SheetTitle>

                {/* Perfil Compacto no Drawer */}
                {profile && (
                  <Link
                    to="/perfil"
                    onClick={() => setIsOpen(false)}
                    className="mt-3 flex items-center gap-3 rounded-xl border border-border/60 bg-muted/30 p-2.5 transition-colors hover:bg-muted/60"
                  >
                    <Avatar className="h-10 w-10 border border-border">
                      <AvatarImage src={profile.avatar_url || undefined} />
                      <AvatarFallback className="bg-primary/20 text-sm font-bold text-primary">
                        {getInitials(profile.full_name)}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex flex-col min-w-0">
                      <span className="truncate text-sm font-bold text-foreground">
                        {profile.full_name}
                      </span>
                      <span className="truncate text-[11px] text-muted-foreground">
                        Ver meu perfil
                      </span>
                    </div>
                  </Link>
                )}
              </SheetHeader>

              {/* Lista de Navegação Principal */}
              <nav className="flex flex-col gap-1 p-3">
                <span className="px-3 pt-2 pb-1 text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
                  Navegação do Portal
                </span>
                {filteredNavItems.map((item) => {
                  const Icon = item.icon
                  const isActive =
                    location.pathname === item.href ||
                    (item.href !== "/dashboard" && location.pathname.startsWith(item.href))

                  return (
                    <Link
                      key={item.name}
                      to={item.href}
                      onClick={() => setIsOpen(false)}
                      className={cn(
                        "flex min-h-[44px] items-center gap-3 rounded-xl px-3.5 py-2.5 text-sm font-medium transition-colors",
                        isActive
                          ? "bg-primary text-primary-foreground font-semibold shadow-2xs"
                          : "text-muted-foreground hover:bg-muted hover:text-foreground"
                      )}
                    >
                      <Icon className="h-5 w-5 shrink-0" />
                      <span>{item.name}</span>
                    </Link>
                  )
                })}


              </nav>
            </div>

            {/* Rodapé do Menu Drawer: Botão Sair */}
            <div className="border-t border-border/60 p-4 pb-safe">
              <Button
                variant="outline"
                onClick={handleLogout}
                className="min-h-[44px] w-full justify-start gap-2.5 rounded-xl text-xs font-semibold text-destructive hover:bg-destructive/10 hover:text-destructive border-destructive/20"
              >
                <LogOut className="h-4 w-4" />
                <span>Sair da Conta</span>
              </Button>
            </div>
          </SheetContent>
        </Sheet>
      </div>
    </header>
  )
}
