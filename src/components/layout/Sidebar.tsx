import { Link, useLocation } from "react-router-dom";
import { 
    HomeIcon, 
    CalendarIcon, 
    UsersIcon, 
    SettingsIcon, 
    MessageCircleIcon, 
    LogOutIcon, 
    PlusCircleIcon, 
    ChevronLeftIcon, 
    ChevronRightIcon,
    LibraryIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import supabase from "@/lib/supabase";
import { useEffect, useState } from "react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
} from "@/components/ui/tooltip";

interface UserProfile {
    id: string;
    full_name: string;
    avatar_url?: string;
}

export function Sidebar() {
    const location = useLocation();
    const [isAdmin, setIsAdmin] = useState(false);
    const [isManagement, setIsManagement] = useState(false);
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const [isCollapsed, setIsCollapsed] = useState(() => {
        const saved = localStorage.getItem("sidebar-collapsed");
        return saved ? JSON.parse(saved) : false;
    });

    useEffect(() => {
        localStorage.setItem("sidebar-collapsed", JSON.stringify(isCollapsed));
    }, [isCollapsed]);

    useEffect(() => {
        async function fetchUserData() {
            const { data: { session } } = await supabase.auth.getSession();
            if (session?.user) {
                const { data: profileData } = await supabase
                    .from("profiles")
                    .select("id, full_name, avatar_url, is_dev, is_presbyter, is_deacon")
                    .eq("user_id", session.user.id)
                    .single();
                
                if (profileData) {
                    setProfile({
                        id: profileData.id,
                        full_name: profileData.full_name,
                        avatar_url: profileData.avatar_url || undefined
                    });
                    setIsAdmin(!!(profileData.is_dev || profileData.is_presbyter));
                    
                    // Check if leader
                    const { count } = await supabase
                        .from("home_groups")
                        .select("*", { count: 'exact', head: true })
                        .or(`leader_1_id.eq.${profileData.id},leader_2_id.eq.${profileData.id}`);
                    
                    setIsManagement(!!(profileData.is_dev || profileData.is_presbyter || profileData.is_deacon || (count || 0) > 0));
                }
            }
        }
        fetchUserData();
    }, []);

    const navItems = [
        { name: "Início", path: "/", icon: HomeIcon },
        { name: "Eventos", path: "/eventos", icon: CalendarIcon },
        { name: "Grupos Caseiros", path: "/grupos-caseiros", icon: UsersIcon },
        ...(isManagement ? [{ name: "Gestão de Vinculados", path: "/gestao/vinculados", icon: UsersIcon }] : []),
        ...(isAdmin ? [{ name: "Novo Grupo", path: "/grupos-caseiros/adicionar", icon: PlusCircleIcon }] : []),
        { name: "Materiais", path: "/materiais", icon: LibraryIcon },
        { name: "Mensagens", path: "/mensagens", icon: MessageCircleIcon },
        { name: "Ajustes", path: "/ajustes", icon: SettingsIcon },
    ];

    const handleLogout = async () => {
        await supabase.auth.signOut();
    };

    const getInitials = (name: string) => {
        return name
            .split(" ")
            .map((n) => n[0])
            .join("")
            .toUpperCase()
            .substring(0, 2);
    };

    return (
        <TooltipProvider delayDuration={0}>
            <aside className={cn(
                "shrink-0 hidden md:flex flex-col border-r border-border bg-card/50 backdrop-blur-xl h-screen sticky top-0 transition-all duration-300 ease-in-out",
                isCollapsed ? "w-20" : "w-64"
            )}>
                <div className={cn(
                    "h-16 flex items-center border-b border-border relative",
                    isCollapsed ? "justify-center px-0" : "px-6"
                )}>
                    <Tooltip>
                        <TooltipTrigger asChild>
                            <div className={cn(
                                "w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center transition-all duration-300 overflow-hidden border border-primary/20",
                                !isCollapsed && "mr-3"
                            )}>
                                <img 
                                    src="/logo_igreja.png" 
                                    alt="Logo Igreja em BH" 
                                    className="w-full h-full object-contain p-1"
                                />
                            </div>
                        </TooltipTrigger>
                        {isCollapsed && (
                            <TooltipContent side="right" sideOffset={10}>
                                Igreja em BH
                            </TooltipContent>
                        )}
                    </Tooltip>
                    {!isCollapsed && (
                        <h1 className="text-lg font-bold tracking-tight text-foreground truncate animate-in fade-in slide-in-from-left-2 duration-300">
                            Igreja em BH
                        </h1>
                    )}
                    
                    <Button
                        variant="ghost"
                        size="icon"
                        className="absolute -right-3 top-1/2 -translate-y-1/2 h-6 w-6 rounded-full border border-border bg-background shadow-sm hover:bg-accent"
                        onClick={() => setIsCollapsed(!isCollapsed)}
                    >
                        {isCollapsed ? (
                            <ChevronRightIcon className="h-4 w-4" />
                        ) : (
                            <ChevronLeftIcon className="h-4 w-4" />
                        )}
                    </Button>
                </div>

                <div className={cn(
                    "flex-1 py-6 space-y-2 overflow-y-auto scrollbar-none",
                    isCollapsed ? "px-2" : "px-4"
                )}>
                    {navItems.map((item) => {
                        const isActive = location.pathname === item.path;
                        const content = (
                            <Link
                                key={item.path}
                                to={item.path}
                                className={cn(
                                    "flex items-center rounded-lg transition-all duration-200 text-sm font-medium",
                                    isCollapsed ? "justify-center p-2.5" : "gap-3 px-3 py-2.5",
                                    isActive 
                                        ? "bg-primary text-primary-foreground shadow-sm" 
                                        : "text-muted-foreground hover:bg-primary/10 hover:text-foreground"
                                )}
                            >
                                <item.icon className="w-5 h-5 shrink-0" />
                                {!isCollapsed && (
                                    <span className="truncate animate-in fade-in slide-in-from-left-2 duration-300">
                                        {item.name}
                                    </span>
                                )}
                            </Link>
                        );

                        if (!isCollapsed) return content;

                        return (
                            <Tooltip key={item.path}>
                                <TooltipTrigger asChild>
                                    {content}
                                </TooltipTrigger>
                                <TooltipContent side="right" sideOffset={10}>
                                    {item.name}
                                </TooltipContent>
                            </Tooltip>
                        );
                    })}
                </div>

                <div className={cn(
                    "p-4 border-t border-border mt-auto space-y-4",
                    isCollapsed ? "flex flex-col items-center" : ""
                )}>
                    {profile && (() => {
                        const content = (
                            <Link
                                to="/perfil"
                                className={cn(
                                    "flex items-center rounded-lg transition-colors hover:bg-primary/10 w-full",
                                    isCollapsed ? "justify-center p-2" : "gap-3 p-2",
                                    location.pathname === "/perfil" && "bg-primary/10"
                                )}
                            >
                                <Avatar className="size-9 border border-border shrink-0">
                                    <AvatarImage src={profile.avatar_url} />
                                    <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                                        {getInitials(profile.full_name)}
                                    </AvatarFallback>
                                </Avatar>
                                {!isCollapsed && (
                                    <div className="flex flex-col min-w-0 animate-in fade-in slide-in-from-left-2 duration-300">
                                        <span className="text-sm font-semibold truncate text-foreground">
                                            {profile.full_name}
                                        </span>
                                        <span className="text-xs text-muted-foreground truncate">
                                            Ver perfil
                                        </span>
                                    </div>
                                )}
                            </Link>
                        );

                        if (!isCollapsed) return content;

                        return (
                            <Tooltip>
                                <TooltipTrigger asChild>
                                    {content}
                                </TooltipTrigger>
                                <TooltipContent side="right" sideOffset={10}>
                                    {profile.full_name}
                                </TooltipContent>
                            </Tooltip>
                        );
                    })()}

                    <Tooltip>
                        <TooltipTrigger asChild>
                            <button 
                                onClick={handleLogout}
                                className={cn(
                                    "flex w-full items-center rounded-lg transition-colors text-sm font-medium text-muted-foreground hover:bg-destructive/10 hover:text-destructive",
                                    isCollapsed ? "justify-center p-2.5" : "gap-3 px-3 py-2.5"
                                )}
                            >
                                <LogOutIcon className="w-5 h-5 shrink-0" />
                                {!isCollapsed && (
                                    <span className="truncate animate-in fade-in slide-in-from-left-2 duration-300">
                                        Sair
                                    </span>
                                )}
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
    );
}
