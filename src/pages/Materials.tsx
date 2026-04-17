import { useState, useEffect } from "react";
import { 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    PlusIcon, 
    SearchIcon,
    Loader2Icon
} from "lucide-react";
import { cn } from "@/lib/utils";
import supabase from "@/lib/supabase";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { fetchLatestVideos, type YouTubeVideo } from "@/lib/youtube";
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";

type TabType = "videos" | "pdfs" | "textos";

interface Profile {
    is_presbyter: boolean;
    is_deacon: boolean;
    is_dev: boolean;
}

export default function Materials() {
    const [activeTab, setActiveTab] = useState<TabType>("videos");
    const [profile, setProfile] = useState<Profile | null>(null);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    // YouTube states
    const [videos, setVideos] = useState<YouTubeVideo[]>([]);
    const [loadingVideos, setLoadingVideos] = useState(false);
    const [selectedVideo, setSelectedVideo] = useState<YouTubeVideo | null>(null);

    useEffect(() => {
        async function fetchProfile() {
            const { data: { session } } = await supabase.auth.getSession();
            if (session?.user) {
                const { data } = await supabase
                    .from("profiles")
                    .select("is_presbyter, is_deacon, is_dev")
                    .eq("user_id", session.user.id)
                    .single();
                setProfile(data ? {
                    is_presbyter: !!data.is_presbyter,
                    is_deacon: !!data.is_deacon,
                    is_dev: !!data.is_dev,
                } : null);
            }
            setLoading(false);
        }
        fetchProfile();
    }, []);

    useEffect(() => {
        async function loadVideos() {
            if (activeTab === "videos" && videos.length === 0) {
                setLoadingVideos(true);
                const fetchedVideos = await fetchLatestVideos();
                setVideos(fetchedVideos);
                setLoadingVideos(false);
            }
        }
        loadVideos();
    }, [activeTab]);

    const canAddMaterial = profile?.is_presbyter || profile?.is_deacon || profile?.is_dev;

    const tabs = [
        { id: "videos", label: "Vídeos", icon: YoutubeIcon },
        { id: "pdfs", label: "PDFs", icon: FileTextIcon },
        { id: "textos", label: "Textos", icon: BookOpenIcon },
    ];

    if (loading) {
        return (
            <div className="flex h-[60vh] items-center justify-center">
                <Loader2Icon className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border pb-6">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-foreground">
                        Materiais e Recursos
                    </h1>
                    <p className="text-muted-foreground mt-1">
                        Acesse vídeos, apostilas e outros materiais da nossa igreja.
                    </p>
                </div>
                {canAddMaterial && (
                    <Button className="shrink-0 gap-2 shadow-lg shadow-primary/20 rounded-full px-6">
                        <PlusIcon className="h-4 w-4" />
                        Adicionar Material
                    </Button>
                )}
            </div>

            <div className="flex flex-col gap-6">
                <div className="flex flex-col md:flex-row gap-4 items-start md:items-center justify-between">
                    {/* Tabs Switcher */}
                    <div className="flex p-1 bg-muted/30 backdrop-blur-sm rounded-2xl border border-border/50 w-full md:w-fit overflow-x-auto no-scrollbar">
                        {tabs.map((tab) => (
                            <button
                                key={tab.id}
                                onClick={() => setActiveTab(tab.id as TabType)}
                                className={cn(
                                    "flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl text-sm font-medium transition-all whitespace-nowrap flex-1 md:flex-none",
                                    activeTab === tab.id
                                        ? "bg-primary text-primary-foreground shadow-sm"
                                        : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                                )}
                            >
                                <tab.icon className="h-4 w-4" />
                                {tab.label}
                            </button>
                        ))}
                    </div>

                    {/* Search Bar */}
                    <div className="relative w-full md:max-w-xs group">
                        <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                        <Input
                            placeholder="Buscar materiais..."
                            className="pl-10 bg-card/30 backdrop-blur-sm border-border/50 rounded-xl focus:border-primary/50 transition-all focus:ring-2 focus:ring-primary/20"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                        />
                    </div>
                </div>

                {/* Content Sections */}
                <div className="min-h-[400px]">
                    {activeTab === "videos" && (
                        <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                            {loadingVideos ? (
                                <div className="flex justify-center items-center py-24">
                                    <Loader2Icon className="h-10 w-10 animate-spin text-primary" />
                                </div>
                            ) : videos.length > 0 ? (
                                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                    {videos.map((video) => (
                                        <Card 
                                            key={video.id} 
                                            className="overflow-hidden border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl hover:shadow-primary/5 cursor-pointer group flex flex-col rounded-2xl"
                                            onClick={() => setSelectedVideo(video)}
                                        >
                                            <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden shrink-0">
                                                <img 
                                                    src={video.thumbnailUrl} 
                                                    alt={video.title} 
                                                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" 
                                                />
                                                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                                                    <div className="w-14 h-14 rounded-full bg-primary/90 flex items-center justify-center opacity-0 group-hover:opacity-100 transform scale-50 group-hover:scale-100 transition-all duration-300 shadow-xl border-4 border-white/20">
                                                        <YoutubeIcon className="h-7 w-7 text-primary-foreground ml-1" />
                                                    </div>
                                                </div>
                                            </div>
                                            <CardHeader className="flex-1 p-5">
                                                <CardTitle className="text-base text-foreground line-clamp-2 leading-tight group-hover:text-primary transition-colors" title={video.title}>
                                                    {video.title}
                                                </CardTitle>
                                                <CardDescription className="text-xs pt-1">
                                                    {new Date(video.publishedAt).toLocaleDateString('pt-BR')}
                                                </CardDescription>
                                            </CardHeader>
                                        </Card>
                                    ))}
                                </div>
                            ) : (
                                <div className="text-center py-24 bg-card/30 backdrop-blur-sm border border-dashed border-border/50 rounded-3xl">
                                    <div className="w-20 h-20 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-6">
                                        <YoutubeIcon className="h-10 w-10 text-muted-foreground/30" />
                                    </div>
                                    <h3 className="text-xl font-medium text-foreground">Nenhum vídeo encontrado</h3>
                                    <p className="text-muted-foreground mt-2 max-w-sm mx-auto">
                                        Os vídeos do canal da igreja aparecerão aqui automaticamente.
                                    </p>
                                </div>
                            )}
                        </div>
                    )}

                    {activeTab === "pdfs" && (
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
                            {[1, 2, 3, 4].map((i) => (
                                <Card key={i} className="flex flex-col border-border/50 bg-card/30 backdrop-blur-sm hover:border-blue-500/30 transition-all hover:shadow-xl group rounded-2xl overflow-hidden">
                                    <CardHeader className="flex-1 p-6">
                                        <div className="w-12 h-12 rounded-2xl bg-blue-500/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform duration-300">
                                            <FileTextIcon className="h-6 w-6 text-blue-500" />
                                        </div>
                                        <CardTitle className="text-lg text-foreground group-hover:text-blue-500 transition-colors">Apostila {i}</CardTitle>
                                        <CardDescription>Estudo Bíblico • PDF</CardDescription>
                                    </CardHeader>
                                    <CardContent className="p-6 pt-0">
                                        <Button variant="outline" className="w-full gap-2 border-border/50 rounded-xl hover:bg-blue-500 hover:text-white transition-all">
                                            Baixar Arquivo
                                        </Button>
                                    </CardContent>
                                </Card>
                            ))}
                        </div>
                    )}

                    {activeTab === "textos" && (
                        <div className="max-w-4xl mx-auto w-full animate-in fade-in slide-in-from-bottom-4 duration-500">
                            <div className="space-y-4">
                                {[1, 2].map((i) => (
                                    <Card key={i} className="border-border/50 bg-card/30 backdrop-blur-sm hover:bg-primary/5 transition-all cursor-pointer group rounded-2xl overflow-hidden">
                                        <CardHeader className="p-6">
                                            <div className="flex items-center justify-between">
                                                <div className="space-y-1">
                                                    <CardTitle className="text-xl group-hover:text-primary transition-colors text-foreground">
                                                        Guia de Leitura e Oração {i}
                                                    </CardTitle>
                                                    <CardDescription>23 de Março, 2026 • 5 min de leitura</CardDescription>
                                                </div>
                                                <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                                                    <BookOpenIcon className="h-5 w-5 text-primary" />
                                                </div>
                                            </div>
                                        </CardHeader>
                                        <CardContent className="px-6 pb-6 pt-0">
                                            <p className="text-muted-foreground line-clamp-2">
                                                Acesse o conteúdo detalhado com orientações para sua devocional diária e estudos complementares.
                                            </p>
                                        </CardContent>
                                    </Card>
                                ))}
                            </div>
                        </div>
                    )}
                </div>
            </div>

            <Dialog 
                open={!!selectedVideo} 
                onOpenChange={(open) => !open && setSelectedVideo(null)}
            >
                <DialogContent className="sm:max-w-6xl w-[95vw] p-0 overflow-hidden bg-black/95 border-white/10 shadow-2xl rounded-3xl">
                    <DialogHeader className="sr-only">
                        <DialogTitle>{selectedVideo?.title}</DialogTitle>
                    </DialogHeader>
                    {selectedVideo && (
                        <div className="aspect-video w-full bg-black flex items-center justify-center">
                            <iframe 
                                width="100%" 
                                height="100%" 
                                src={`https://www.youtube.com/embed/${selectedVideo.id}?autoplay=1`} 
                                title={selectedVideo.title} 
                                frameBorder="0" 
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                allowFullScreen
                                className="w-full h-full"
                            ></iframe>
                        </div>
                    )}
                </DialogContent>
            </Dialog>
        </div>
    );
}
