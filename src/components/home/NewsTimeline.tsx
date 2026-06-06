import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BellIcon, MapPinIcon, CalendarHeartIcon, Loader2 } from "lucide-react";
import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { format, parseISO } from "date-fns";
import { ptBR } from "date-fns/locale";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { PlusIcon } from "lucide-react";

type Post = {
    id: string;
    title: string;
    content: string;
    event_start_date: string | null;
    event_end_date: string | null;
    category: "noticia" | "oracao" | "aviso" | "evento" | "diaconato" | "obra";
    image_urls?: string[] | null;
};

const visualStyles = [
    { color: "text-primary", bg: "bg-primary/20", icon: CalendarHeartIcon },
    { color: "text-amber-500", bg: "bg-amber-500/20", icon: BellIcon },
    { color: "text-emerald-500", bg: "bg-emerald-500/20", icon: MapPinIcon }
];

export function NewsTimeline() {
    const [news, setNews] = useState<Post[]>([]);
    const [loading, setLoading] = useState(true);
    const [canPost, setCanPost] = useState(false);

    useEffect(() => {
        const fetchPosts = async () => {
            const { data, error } = await supabase
                .from('posts')
                .select('*')
                .eq('is_published', true)
                .order('event_start_date', { ascending: true })
                .limit(10);
            
            if (!error && data) {
                setNews(data);
            }
            setLoading(false);
        };

        const checkPermissions = async () => {
            const { data: { session } } = await supabase.auth.getSession();
            if (session?.user) {
                const { data: profile } = await supabase
                    .from("profiles")
                    .select("can_post")
                    .eq("user_id", session.user.id)
                    .single();
                
                if (profile) {
                    setCanPost(!!profile.can_post);
                }
            }
        };

        fetchPosts();
        checkPermissions();
    }, []);

    const formatEventDate = (startDate: string | null, endDate: string | null) => {
        if (!startDate) return "Data a definir";
        try {
            const start = parseISO(startDate);
            const startStr = format(start, "EEEE, dd/MM 'às' HH:mm", { locale: ptBR });
            
            if (!endDate) return startStr;
            
            const end = parseISO(endDate);
            
            if (format(start, "dd/MM") === format(end, "dd/MM")) {
                const startTime = format(start, "HH:mm");
                const endTime = format(end, "HH:mm");
                return `${format(start, "EEEE, dd/MM", { locale: ptBR })} | ${startTime} - ${endTime}`;
            }
            return `${format(start, "dd/MM")} a ${format(end, "dd/MM")}`;
        } catch (e) {
            return startDate;
        }
    };

    return (
        <Card className="h-full border-border bg-card/40 backdrop-blur-md shadow-xl flex flex-col">
            <CardHeader className="pb-4">
                <div className="flex items-center justify-between gap-4">
                    <CardTitle className="text-xl font-bold flex items-center gap-2">
                        <BellIcon className="w-5 h-5 text-primary" />
                        Mural de Avisos
                    </CardTitle>
                    {canPost && (
                        <Button asChild size="sm" variant="outline" className="h-8 gap-1 border-primary/20 hover:border-primary/50 hover:bg-primary/5">
                            <Link to="/noticias/nova">
                                <PlusIcon className="w-4 h-4" />
                                <span className="hidden sm:inline">Novo Aviso</span>
                            </Link>
                        </Button>
                    )}
                </div>
            </CardHeader>
            <CardContent className="flex-1 overflow-y-auto pr-2">
                <div className="relative border-l-2 border-primary/20 ml-3 space-y-8 pb-4">
                    {loading ? (
                        <div className="flex items-center justify-center p-8">
                            <Loader2 className="w-6 h-6 animate-spin text-primary" />
                        </div>
                    ) : news.length === 0 ? (
                        <p className="text-center text-muted-foreground p-8">Nenhum evento futuro.</p>
                    ) : (
                        news.map((item, index) => {
                            const style = visualStyles[index % visualStyles.length];
                            const Icon = style.icon;
                            
                            return (
                                <div key={item.id} className="relative pl-6">
                                    {/* Marker */}
                                    <div className={`absolute -left-[11px] top-1 w-5 h-5 rounded-full border-4 border-card backdrop-blur-sm flex items-center justify-center ${style.bg}`}>
                                        <div className={`w-2 h-2 rounded-full ${style.color.replace('text-', 'bg-')}`} />
                                    </div>
                                    
                                    {/* Content */}
                                    <div className="bg-background/50 rounded-lg p-4 shadow-sm border border-border/50 hover:border-primary/30 transition-colors">
                                        <div className="flex items-center gap-2 mb-1">
                                            <Icon className={`w-4 h-4 ${style.color}`} />
                                            <h3 className="font-semibold text-foreground text-sm lg:text-base">{item.title}</h3>
                                        </div>
                                        <time className="text-xs font-medium text-primary block mb-2">
                                            {formatEventDate(item.event_start_date, item.event_end_date)}
                                        </time>
                                        <p className="text-muted-foreground text-sm leading-relaxed mb-4">
                                            {item.content}
                                        </p>

                                        {item.image_urls && item.image_urls.length > 0 && (
                                            <div className={`grid gap-2 mb-2 ${item.image_urls.length === 1 ? 'grid-cols-1' : 'grid-cols-2'}`}>
                                                {item.image_urls.map((url, idx) => (
                                                    <div 
                                                        key={idx} 
                                                        className={`relative rounded-md overflow-hidden bg-muted/20 border border-border/30 ${
                                                            item.image_urls && item.image_urls.length === 3 && idx === 0 ? 'col-span-2' : ''
                                                        }`}
                                                    >
                                                        <img 
                                                            src={url} 
                                                            alt={`Post image ${idx + 1}`} 
                                                            className="w-full h-full object-cover max-h-48"
                                                        />
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                </div>
                            );
                        })
                    )}
                </div>
            </CardContent>
        </Card>
    );
}
