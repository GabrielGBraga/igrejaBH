import { Link, useLocation } from "react-router-dom";
import { 
    LogOutIcon, 
    ChevronLeftIcon, 
    ChevronRightIcon,
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
import { navItems } from "./NavItems";

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

    const filteredNavItems = navItems.filter(item => {
        if (item.requireManagement && !isManagement) return false;
        if (item.href === '/grupos-caseiros/adicionar' && !isAdmin) return false;
        return true;
    });

    const handleLogout = async () => {
        await supabase.auth.signOut();
    };

    const getInitials = (name: string) => {
        return name
            .split(" ")
            .filter(Boolean)
            .map((n) => n[0])
            .join("")
            .toUpperCase()
            .substring(0, 2);
    };

    return (
        <TooltipProvider delayDuration={0}>
            <aside className={cn(
                "shrink-0 hidden md:flex flex-col border-r border-border bg-card/30 backdrop-blur-xl h-screen sticky top-0 transition-all duration-300 ease-in-out z-40",
                isCollapsed ? "w-20" : "w-64"
            )}>
                <div className={cn(
                    "h-16 flex items-center border-b border-border relative",
                    isCollapsed ? "justify-center px-0" : "px-6"
                )}>
                    <Tooltip>
                        <TooltipTrigger asChild>
                            <Link to="/" className={cn(
                                "w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center transition-all duration-300 overflow-hidden border border-primary/20",
                                !isCollapsed && "mr-3"
                            )}>
                                <img 
                                    src="/logo_igreja.png" 
                                    alt="Logo" 
                                    className="w-full h-full object-contain p-1"
                                />
                            </Link>
                        </TooltipTrigger>
                        {isCollapsed && (
                            <TooltipContent side="right" sideOffset={10}>
                                Igreja BH
                            </TooltipContent>
                        )}
                    </Tooltip>
                    {!isCollapsed && (
                        <h1 className="text-lg font-bold tracking-tight text-foreground truncate">
                            Igreja BH
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
                    "flex-1 py-6 space-y-1 overflow-y-auto no-scrollbar",
                    isCollapsed ? "px-2" : "px-4"
                )}>
                    {filteredNavItems.map((item) => {
                        const Icon = item.icon;
                        const isActive = location.pathname === item.href;
                        const content = (
                            <Link
                                key={item.name}
                                to={item.href}
                                className={cn(
                                    "flex items-center rounded-xl transition-all duration-200 text-sm font-medium",
                                    isCollapsed ? "justify-center p-2.5" : "gap-3 px-3 py-2.5",
                                    isActive 
                                        ? "bg-primary text-primary-foreground shadow-lg shadow-primary/20" 
                                        : "text-muted-foreground hover:bg-primary/10 hover:text-foreground"
                                )}
                            >
                                <Icon className="w-5 h-5 shrink-0" />
                                {!isCollapsed && (
                                    <span className="truncate">
                                        {item.name}
                                    </span>
                                )}
                            </Link>
                        );

                        if (!isCollapsed) return content;

                        return (
                            <Tooltip key={item.name}>
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
                                    "flex items-center rounded-xl transition-all hover:bg-primary/10 w-full",
                                    isCollapsed ? "justify-center p-2" : "gap-3 p-2",
                                    location.pathname === "/perfil" && "bg-primary/10 border border-primary/20"
                                )}
                            >
                                <Avatar className="size-9 border border-border shrink-0 shadow-sm">
                                    <AvatarImage src={profile.avatar_url} />
                                    <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                                        {getInitials(profile.full_name)}
                                    </AvatarFallback>
                                </Avatar>
                                {!isCollapsed && (
                                    <div className="flex flex-col min-w-0">
                                        <span className="text-sm font-semibold truncate text-foreground">
                                            {profile.full_name}
                                        </span>
                                        <span className="text-[10px] text-muted-foreground truncate uppercase tracking-widest font-bold opacity-70">
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
                                    "flex w-full items-center rounded-xl transition-all text-sm font-bold text-muted-foreground hover:bg-destructive/10 hover:text-destructive",
                                    isCollapsed ? "justify-center p-2.5" : "gap-3 px-3 py-2.5"
                                )}
                            >
                                <LogOutIcon className="w-5 h-5 shrink-0" />
                                {!isCollapsed && (
                                    <span className="truncate">
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
