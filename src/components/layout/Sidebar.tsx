import { Link, useLocation } from "react-router-dom";
import { 
    HomeIcon, 
    CalendarIcon, 
    UsersIcon, 
    SettingsIcon, 
    MessageCircleIcon,
    LogOutIcon,
    PlusCircleIcon 
} from "lucide-react";
import { cn } from "@/lib/utils";
import supabase from "@/lib/supabase";
import { useEffect, useState } from "react";

export function Sidebar() {
    const location = useLocation();
    const [isAdmin, setIsAdmin] = useState(false);

    useEffect(() => {
        async function checkAdmin() {
            const { data: { session } } = await supabase.auth.getSession();
            if (session?.user) {
                const { data: profile } = await supabase
                    .from("profiles")
                    .select("is_dev, is_presbyter")
                    .eq("user_id", session.user.id)
                    .single();
                
                if (profile) {
                    setIsAdmin(!!(profile.is_dev || profile.is_presbyter));
                }
            }
        }
        checkAdmin();
    }, []);

    const navItems = [
        { name: "Início", path: "/", icon: HomeIcon },
        { name: "Eventos", path: "/eventos", icon: CalendarIcon },
        { name: "Grupos Caseiros", path: "/grupos-caseiros", icon: UsersIcon },
        ...(isAdmin ? [{ name: "Novo Grupo", path: "/grupos-caseiros/adicionar", icon: PlusCircleIcon }] : []),
        { name: "Mensagens", path: "/mensagens", icon: MessageCircleIcon },
        { name: "Ajustes", path: "/ajustes", icon: SettingsIcon },
    ];

    const handleLogout = async () => {
        await supabase.auth.signOut();
    };

    return (
        <aside className="w-64 shrink-0 hidden md:flex flex-col border-r border-border bg-card/50 backdrop-blur-xl h-screen sticky top-0">
            <div className="h-16 flex items-center px-6 border-b border-border">
                <div className="w-8 h-8 rounded-lg bg-primary/20 flex items-center justify-center mr-3">
                    <span className="text-primary font-bold text-xl leading-none">I</span>
                </div>
                <h1 className="text-lg font-bold tracking-tight text-foreground">Igreja em BH</h1>
            </div>

            <div className="flex-1 py-6 px-4 space-y-2 overflow-y-auto">
                {navItems.map((item) => {
                    const isActive = location.pathname === item.path;
                    return (
                        <Link
                            key={item.path}
                            to={item.path}
                            className={cn(
                                "flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200 text-sm font-medium",
                                isActive 
                                    ? "bg-primary text-primary-foreground shadow-sm" 
                                    : "text-muted-foreground hover:bg-primary/10 hover:text-foreground"
                            )}
                        >
                            <item.icon className="w-5 h-5" />
                            {item.name}
                        </Link>
                    );
                })}
            </div>

            <div className="p-4 border-t border-border mt-auto">
                <button 
                    onClick={handleLogout}
                    className="flex w-full items-center gap-3 px-3 py-2.5 rounded-lg transition-colors text-sm font-medium text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                >
                    <LogOutIcon className="w-5 h-5" />
                    Sair
                </button>
            </div>
        </aside>
    );
}
