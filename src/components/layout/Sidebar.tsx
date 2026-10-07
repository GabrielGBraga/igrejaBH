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

interface UserProfile {
  id: string
  full_name: string
  avatar_url?: string
}

export function Sidebar() {
  const location = useLocation()
  const { setTheme } = useTheme()

  const toggleTheme = () => {
    const isDark = document.documentElement.classList.contains("dark")
    setTheme(isDark ? "light" : "dark")
  }
  const [isAdmin, setIsAdmin] = useState(false)
  const [isManagement, setIsManagement] = useState(false)
  const [canPost, setCanPost] = useState(false)
  const [profile, setProfile] = useState<UserProfile | null>(null)
  const [isCollapsed, setIsCollapsed] = useState(() => {
    const saved = localStorage.getItem("sidebar-collapsed")
    return saved ? JSON.parse(saved) : false
  })

  useEffect(() => {
    localStorage.setItem("sidebar-collapsed", JSON.stringify(isCollapsed))
  }, [isCollapsed])

  useEffect(() => {
    async function fetchUserData() {
      const {
        data: { session },
      } = await supabase.auth.getSession()
      if (session?.user) {
        const { data: profileData } = await supabase
          .from("profiles")
          .select(
            "id, full_name, avatar_url, is_dev, is_presbyter, is_deacon, can_post"
          )
          .eq("user_id", session.user.id)
          .single()

        if (profileData) {
          setProfile({
            id: profileData.id,
            full_name: profileData.full_name,
            avatar_url: profileData.avatar_url || undefined,
          })
          setIsAdmin(!!(profileData.is_dev || profileData.is_presbyter))
          setCanPost(
            !!(
              profileData.is_dev ||
              profileData.is_presbyter ||
              profileData.can_post
            )
          )

          const { count } = await supabase
            .from("home_groups")
            .select("*", { count: "exact", head: true })
            .or(
              `leader_1_id.eq.${profileData.id},leader_2_id.eq.${profileData.id}`
            )

          setIsManagement(
            !!(
              profileData.is_dev ||
              profileData.is_presbyter ||
              profileData.is_deacon ||
              (count || 0) > 0
            )
          )
        }
      }
    }
    fetchUserData()
  }, [])

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
                    <span className="truncate text-[10px] uppercase tracking-wider text-muted-foreground font-medium mt-0.5">
                      A Igreja na Cidade
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
                  "flex items-center rounded-xl text-sm font-medium transition-all duration-200",
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
          {/* Botão de alternar tema (Claro / Escuro) acima do avatar do perfil */}
          {isCollapsed ? (
            <Tooltip>
              <TooltipTrigger asChild>
                <button
                  type="button"
                  onClick={toggleTheme}
                  aria-label="Alternar tema claro e escuro"
                  className="relative flex h-11 w-11 shrink-0 cursor-pointer items-center justify-center rounded-xl text-muted-foreground transition-all hover:bg-primary/10 hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                >
                  <Sun className="h-5 w-5 scale-100 rotate-0 text-foreground transition-transform duration-300 dark:scale-0 dark:-rotate-90 motion-reduce:transition-none motion-reduce:transform-none" />
                  <Moon className="absolute h-5 w-5 scale-0 rotate-90 text-foreground transition-transform duration-300 dark:scale-100 dark:rotate-0 motion-reduce:transition-none motion-reduce:transform-none" />
                  <span className="sr-only">Alternar tema</span>
                </button>
              </TooltipTrigger>
              <TooltipContent side="right" sideOffset={10}>
                Alternar tema
              </TooltipContent>
            </Tooltip>
          ) : (
            <button
              type="button"
              onClick={toggleTheme}
              aria-label="Alternar tema claro e escuro"
              className="flex w-full min-h-[44px] cursor-pointer items-center justify-between rounded-xl px-3 py-2.5 text-sm font-medium text-muted-foreground transition-all hover:bg-primary/10 hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              <div className="flex items-center gap-3 min-w-0">
                <div className="relative flex h-5 w-5 shrink-0 items-center justify-center">
                  <Sun className="h-5 w-5 scale-100 rotate-0 text-foreground transition-transform duration-300 dark:scale-0 dark:-rotate-90 motion-reduce:transition-none motion-reduce:transform-none" />
                  <Moon className="absolute h-5 w-5 scale-0 rotate-90 text-foreground transition-transform duration-300 dark:scale-100 dark:rotate-0 motion-reduce:transition-none motion-reduce:transform-none" />
                </div>
                <span className="truncate">Alternar tema</span>
              </div>
              <span className="rounded-md bg-muted/80 px-2 py-0.5 text-[11px] font-medium text-muted-foreground dark:hidden">
                Claro
              </span>
              <span className="hidden rounded-md bg-muted/80 px-2 py-0.5 text-[11px] font-medium text-muted-foreground dark:inline">
                Escuro
              </span>
            </button>
          )}

          {profile &&
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
                    <AvatarImage src={profile.avatar_url} />
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
            })()}

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
