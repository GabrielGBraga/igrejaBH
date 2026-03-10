import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BellIcon, MapPinIcon, CalendarHeartIcon, Loader2 } from "lucide-react";
import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { format, parseISO } from "date-fns";
import { ptBR } from "date-fns/locale";

type Post = {
    id: string;
    title: string;
    content: string;
    event_date: string | null;
    category: string;
};

const visualStyles = [
    { color: "text-primary", bg: "bg-primary/20", icon: CalendarHeartIcon },
    { color: "text-amber-500", bg: "bg-amber-500/20", icon: BellIcon },
    { color: "text-emerald-500", bg: "bg-emerald-500/20", icon: MapPinIcon }
];

export function NewsTimeline() {
    const [news, setNews] = useState<Post[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPosts = async () => {
            const { data, error } = await supabase
                .from('posts')
                .select('*')
                .eq('is_published', true)
                .order('event_date', { ascending: true })
                .limit(10);
            
            if (!error && data) {
                setNews(data);
            }
            setLoading(false);
        };

        fetchPosts();
    }, []);

    const formatEventDate = (dateString: string | null) => {
        if (!dateString) return "Data a definir";
        try {
            const date = parseISO(dateString);
            const formatted = format(date, "EEEE, dd/MM 'às' HH:mm", { locale: ptBR });
            return formatted.charAt(0).toUpperCase() + formatted.slice(1);
        } catch (e) {
            return dateString;
        }
    };

    return (
        <Card className="h-full border-border bg-card/40 backdrop-blur-md shadow-xl flex flex-col">
            <CardHeader className="pb-4">
                <CardTitle className="text-xl font-bold flex items-center gap-2">
                    <BellIcon className="w-5 h-5 text-primary" />
                    Mural de Avisos
                </CardTitle>
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
                                        <time className="text-xs font-medium text-primary block mb-2">{formatEventDate(item.event_date)}</time>
                                        <p className="text-muted-foreground text-sm leading-relaxed">
                                            {item.content}
                                        </p>
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
