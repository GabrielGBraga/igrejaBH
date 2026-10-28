import { Link, useLocation } from "react-router-dom"
import { Home, BookOpen, Calendar, Users, User, Menu } from "lucide-react"
import { cn } from "@/lib/utils"
import { useCurrentUserProfile } from "@/hooks/useCurrentUserProfile"

interface BottomNavProps {
  onOpenMenu: () => void
}

export function BottomNav({ onOpenMenu }: BottomNavProps) {
  const location = useLocation()
  const { isManagement } = useCurrentUserProfile()

  const navItems = isManagement
    ? [
        { name: "Início", href: "/dashboard", icon: Home },
        { name: "Ensinos", href: "/ensinos", icon: BookOpen },
        { name: "Eventos", href: "/manage-events", icon: Calendar },
        { name: "Corpo", href: "/gestao", icon: Users },
      ]
    : [
        { name: "Início", href: "/dashboard", icon: Home },
        { name: "Ensinos", href: "/ensinos", icon: BookOpen },
        { name: "Eventos", href: "/eventos", icon: Calendar },
        { name: "Perfil", href: "/perfil", icon: User },
      ]

  return (
    <nav
      aria-label="Navegação Rápida Mobile"
      className="fixed bottom-0 left-0 right-0 z-40 border-t border-border/80 bg-background/95 pb-safe backdrop-blur-md md:hidden"
    >
      <div className="flex h-16 items-center justify-around px-2">
        {navItems.map((item) => {
          const Icon = item.icon
          const isActive =
            location.pathname === item.href ||
            (item.href !== "/dashboard" && location.pathname.startsWith(item.href))

          return (
            <Link
              key={item.href}
              to={item.href}
              aria-current={isActive ? "page" : undefined}
              className={cn(
                "group relative flex min-h-[48px] min-w-[56px] flex-1 flex-col items-center justify-center gap-1 rounded-xl py-1 text-[11px] font-semibold transition-colors",
                isActive
                  ? "text-primary"
                  : "text-muted-foreground hover:text-foreground active:scale-95"
              )}
            >
              <div
                className={cn(
                  "flex h-7 w-12 items-center justify-center rounded-full transition-colors",
                  isActive
                    ? "bg-primary/10 text-primary"
                    : "text-muted-foreground group-hover:text-foreground"
                )}
              >
                <Icon className={cn("h-5 w-5", isActive ? "stroke-[2.25]" : "stroke-2")} />
              </div>
              <span className="truncate leading-none">{item.name}</span>
            </Link>
          )
        })}

        {/* Botão Mais / Menu Completo */}
        <button
          type="button"
          onClick={onOpenMenu}
          aria-label="Abrir menu completo"
          className="group relative flex min-h-[48px] min-w-[56px] flex-1 flex-col items-center justify-center gap-1 rounded-xl py-1 text-[11px] font-semibold text-muted-foreground transition-colors hover:text-foreground active:scale-95"
        >
          <div className="flex h-7 w-12 items-center justify-center rounded-full text-muted-foreground group-hover:text-foreground">
            <Menu className="h-5 w-5 stroke-2" />
          </div>
          <span className="truncate leading-none">Mais</span>
        </button>
      </div>
    </nav>
  )
}
