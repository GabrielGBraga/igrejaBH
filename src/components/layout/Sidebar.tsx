import { Link, useLocation } from "react-router-dom"
import {
  LogOutIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  Sun,
  Moon,
} from "lucide-react"
import { cn } from "@/lib/utils"
import supabase from "@/lib/supabase"
import { useEffect, useState } from "react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { ChurchAvatar } from "@/components/ui/church-avatar"
import { Button } from "@/components/ui/button"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { navItems } from "./NavItems"
import { useTheme } from "@/components/theme-provider"
import { ThemeSwitch } from "@/components/ThemeSwitch"
import { useCurrentUserProfile } from "@/hooks/useCurrentUserProfile"

export function Sidebar() {
  const location = useLocation()
  const { resolvedTheme, setTheme } = useTheme()
  const { profile, isAdmin, isManagement, canPost, loading } = useCurrentUserProfile()

  const isDark = resolvedTheme === "dark"

  const toggleTheme = () => {
    setTheme(isDark ? "light" : "dark")
  }

  const [isCollapsed, setIsCollapsed] = useState(() => {
    const saved = localStorage.getItem("sidebar-collapsed")
    return saved ? JSON.parse(saved) : false
  })

  useEffect(() => {
    localStorage.setItem("sidebar-collapsed", JSON.stringify(isCollapsed))
  }, [isCollapsed])

  const filteredNavItems = navItems.filter((item) => {
    if (item.requireAdmin && !isAdmin) return false
    if (item.requireManagement && !isManagement) return false
    if (item.requireCanPost && !canPost) return false
    return true
  })

  const handleLogout = async () => {
    await supabase.auth.signOut()
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
    <TooltipProvider delayDuration={0}>
      <aside
        className={cn(
          "sticky top-0 z-40 hidden h-screen shrink-0 flex-col border-r border-border bg-card/30 backdrop-blur-xl transition-all duration-300 ease-in-out md:flex",
          isCollapsed ? "w-20" : "w-64"
        )}
      >
        <div
          className={cn(
            "relative flex h-16 items-center border-b border-border",
            isCollapsed ? "justify-center px-0" : "px-6"
          )}
        >
          <Tooltip>
            <TooltipTrigger asChild>
              <Link
                to="/dashboard"
                className={cn(
                  "flex items-center gap-3 transition-opacity hover:opacity-90",
                  isCollapsed && "justify-center"
                )}
              >
                <ChurchAvatar size="md" variant="subtle" />
                {!isCollapsed && (
                  <div className="flex flex-col min-w-0">
                    <span className="truncate text-base font-bold tracking-tight text-foreground leading-none">
                      Igreja em BH
                    </span>
                  </div>
                )}
              </Link>
            </TooltipTrigger>
            {isCollapsed && (
              <TooltipContent side="right" sideOffset={10}>
                Igreja em BH
              </TooltipContent>
            )}
          </Tooltip>

          <Button
            variant="ghost"
            size="icon"
            className="absolute top-1/2 -right-3 h-6 w-6 -translate-y-1/2 rounded-full border border-border bg-background shadow-sm hover:bg-accent"
            onClick={() => setIsCollapsed(!isCollapsed)}
          >
            {isCollapsed ? (
              <ChevronRightIcon className="h-4 w-4" />
            ) : (
              <ChevronLeftIcon className="h-4 w-4" />
            )}
          </Button>
        </div>

        <div
          className={cn(
            "no-scrollbar flex-1 space-y-1 overflow-y-auto py-6",
            isCollapsed ? "px-2" : "px-4"
          )}
        >
          {filteredNavItems.map((item) => {
            const Icon = item.icon
            const isActive = location.pathname === item.href
            const content = (
              <Link
                key={item.name}
                to={item.href}
                className={cn(
                  "flex items-center rounded-xl text-sm font-medium transition-all duration-200 ease-out active:scale-[0.98] motion-reduce:active:scale-100",
                  isCollapsed ? "justify-center p-2.5" : "gap-3 px-3 py-2.5",
                  isActive
                    ? "bg-primary text-primary-foreground shadow-lg shadow-primary/20"
                    : "text-muted-foreground hover:bg-primary/10 hover:text-foreground"
                )}
              >
                <Icon className="h-5 w-5 shrink-0" />
                {!isCollapsed && <span className="truncate">{item.name}</span>}
              </Link>
            )

            if (!isCollapsed) return content

            return (
              <Tooltip key={item.name}>
                <TooltipTrigger asChild>{content}</TooltipTrigger>
                <TooltipContent side="right" sideOffset={10}>
                  {item.name}
                </TooltipContent>
              </Tooltip>
            )
          })}
        </div>

        <div
          className={cn(
            "mt-auto space-y-3 border-t border-border p-4",
            isCollapsed ? "flex flex-col items-center" : ""
          )}
        >
          {/* Alternância de tema (Claro / Escuro): Ícone no modo recolhido, Switch ampliado no modo aberto */}
          {isCollapsed ? (
            <Tooltip>
              <TooltipTrigger asChild>
                <button
                  type="button"
                  data-theme-transition
                  onClick={toggleTheme}
                  aria-label={
                    isDark ? "Mudar para modo claro" : "Mudar para modo escuro"
                  }
                  className="group relative flex h-11 w-11 shrink-0 cursor-pointer items-center justify-center rounded-xl text-muted-foreground transition-all duration-200 hover:bg-primary/10 hover:text-foreground active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                >
                  <div className="relative flex size-5 items-center justify-center">
                    <Sun
                      className={cn(
                        "size-5 text-amber-600 transition-all duration-500 ease-[cubic-bezier(0.34,1.4,0.64,1)] motion-reduce:transition-none motion-reduce:transform-none",
                        isDark
                          ? "scale-0 -rotate-90 opacity-0"
                          : "scale-100 rotate-0 opacity-100"
                      )}
                    />
                    <Moon
                      className={cn(
                        "absolute size-5 text-amber-400 transition-all duration-500 ease-[cubic-bezier(0.34,1.4,0.64,1)] motion-reduce:transition-none motion-reduce:transform-none",
                        isDark
                          ? "scale-100 rotate-0 opacity-100"
                          : "scale-0 rotate-90 opacity-0"
                      )}
                    />
                  </div>
                  <span className="sr-only">
                    {isDark ? "Mudar para modo claro" : "Mudar para modo escuro"}
                  </span>
                </button>
              </TooltipTrigger>
              <TooltipContent side="right" sideOffset={10}>
                {isDark ? "Mudar para modo claro" : "Mudar para modo escuro"}
              </TooltipContent>
            </Tooltip>
          ) : (
            <div className="flex w-full min-h-[44px] items-center justify-center py-1">
              <Tooltip>
                <TooltipTrigger asChild>
                  <ThemeSwitch
                    size="xl"
                    checked={isDark}
                    onCheckedChange={toggleTheme}
                    aria-label={
                      isDark ? "Mudar para modo claro" : "Mudar para modo escuro"
                    }
                  />
                </TooltipTrigger>
                <TooltipContent side="top" sideOffset={10}>
                  {isDark ? "Mudar para modo claro" : "Mudar para modo escuro"}
                </TooltipContent>
              </Tooltip>
            </div>
          )}

          {profile ? (
            (() => {
              const content = (
                <Link
                  to="/perfil"
                  className={cn(
                    "flex w-full min-h-[44px] items-center rounded-xl transition-all hover:bg-primary/10",
                    isCollapsed ? "justify-center p-2" : "gap-3 p-2",
                    location.pathname === "/perfil" &&
                      "border border-primary/20 bg-primary/10"
                  )}
                >
                  <Avatar className="size-9 shrink-0 border border-border shadow-sm">
                    <AvatarImage src={profile.avatar_url || undefined} />
                    <AvatarFallback className="bg-primary/20 text-xs font-bold text-primary">
                      {getInitials(profile.full_name)}
                    </AvatarFallback>
                  </Avatar>
                  {!isCollapsed && (
                    <div className="flex min-w-0 flex-col">
                      <span className="truncate text-sm font-semibold text-foreground">
                        {profile.full_name}
                      </span>
                      <span className="truncate text-[10px] font-bold tracking-widest text-muted-foreground uppercase opacity-70">
                        Ver perfil
                      </span>
                    </div>
                  )}
                </Link>
              )

              if (!isCollapsed) return content

              return (
                <Tooltip>
                  <TooltipTrigger asChild>{content}</TooltipTrigger>
                  <TooltipContent side="right" sideOffset={10}>
                    {profile.full_name}
                  </TooltipContent>
                </Tooltip>
              )
            })()
          ) : loading ? (
            <div
              className={cn(
                "flex w-full min-h-[44px] items-center rounded-xl p-2",
                isCollapsed ? "justify-center" : "gap-3"
              )}
            >
              <div className="size-9 shrink-0 rounded-full bg-muted/70 animate-pulse" />
              {!isCollapsed && (
                <div className="flex flex-col gap-1.5 flex-1 min-w-0">
                  <div className="h-3.5 w-24 rounded bg-muted/70 animate-pulse" />
                  <div className="h-2.5 w-14 rounded bg-muted/40 animate-pulse" />
                </div>
              )}
            </div>
          ) : null}

          <Tooltip>
            <TooltipTrigger asChild>
              <button
                onClick={handleLogout}
                className={cn(
                  "flex w-full min-h-[44px] items-center rounded-xl text-sm font-bold text-muted-foreground transition-all hover:bg-destructive/10 hover:text-destructive cursor-pointer",
                  isCollapsed ? "justify-center p-2.5" : "gap-3 px-3 py-2.5"
                )}
              >
                <LogOutIcon className="h-5 w-5 shrink-0" />
                {!isCollapsed && <span className="truncate">Sair</span>}
              </button>
            </TooltipTrigger>
            {isCollapsed && (
              <TooltipContent side="right" sideOffset={10}>
                Sair
              </TooltipContent>
            )}
          </Tooltip>
        </div>
      </aside>
    </TooltipProvider>
  )
}
