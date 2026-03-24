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

    const canAddMaterial = profile?.is_presbyter || profile?.is_deacon || profile?.is_dev;

    const tabs = [
        { id: "videos", label: "Vídeos do YouTube", icon: YoutubeIcon },
        { id: "pdfs", label: "Arquivos PDF", icon: FileTextIcon },
        { id: "textos", label: "Textos (Markdown)", icon: BookOpenIcon },
    ];

    if (loading) {
        return (
            <div className="flex h-[80vh] items-center justify-center">
                <Loader2Icon className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="container mx-auto py-8 px-4 max-w-7xl animate-in fade-in duration-500">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-foreground mb-2">
                        Materiais e Recursos
                    </h1>
                    <p className="text-muted-foreground">
                        Acesse vídeos, apostilas, planos de leitura e outros materiais da nossa igreja.
                    </p>
                </div>
                {canAddMaterial && (
                    <Button className="shrink-0 gap-2 shadow-lg shadow-primary/20">
                        <PlusIcon className="h-4 w-4" />
                        Adicionar Material
                    </Button>
                )}
            </div>

            <div className="flex flex-col space-y-6">
                {/* Search Bar */}
                <div className="relative max-w-md w-full">
                    <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <Input
                        placeholder="Buscar materiais..."
                        className="pl-10 bg-card/50 border-border/50 focus:border-primary/50 transition-colors"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                    />
                </div>

                {/* Tabs Switcher */}
                <div className="flex p-1 bg-muted/30 rounded-xl border border-border/50 w-fit">
                    {tabs.map((tab) => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveTab(tab.id as TabType)}
                            className={cn(
                                "flex items-center gap-2 px-6 py-2.5 rounded-lg text-sm font-medium transition-all",
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

                {/* Content Sections */}
                <div className="grid gap-6 min-h-[400px]">
                    {activeTab === "videos" && (
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-in slide-in-from-bottom-4 duration-500">
                            {/* Placeholder para Vídeos */}
                            {[1, 2, 3].map((i) => (
                                <Card key={i} className="overflow-hidden border-border/50 hover:border-primary/30 transition-all hover:shadow-xl hover:shadow-primary/5 group">
                                    <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden">
                                        <YoutubeIcon className="h-12 w-12 text-muted-foreground/30 group-hover:scale-110 transition-transform" />
                                        <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
                                    </div>
                                    <CardHeader>
                                        <CardTitle className="text-lg text-foreground">Exemplo de Vídeo {i}</CardTitle>
                                        <CardDescription>Série: Exposição Bíblica</CardDescription>
                                    </CardHeader>
                                    <CardContent>
                                        <p className="text-sm text-muted-foreground line-clamp-2">
                                            Em breve teremos os vídeos do nosso canal do YouTube listados aqui.
                                        </p>
                                    </CardContent>
                                </Card>
                            ))}
                        </div>
                    )}

                    {activeTab === "pdfs" && (
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 animate-in slide-in-from-bottom-4 duration-500">
                            {/* Placeholder para PDFs */}
                            {[1, 2, 3, 4].map((i) => (
                                <Card key={i} className="flex flex-col border-border/50 hover:border-blue-500/30 transition-all hover:shadow-lg group">
                                    <CardHeader className="flex-1">
                                        <div className="w-10 h-10 rounded-lg bg-blue-500/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                                            <FileTextIcon className="h-5 w-5 text-blue-500" />
                                        </div>
                                        <CardTitle className="text-lg text-foreground">Apostila {i}</CardTitle>
                                        <CardDescription>Categoria: Estudo Bíblico</CardDescription>
                                    </CardHeader>
                                    <CardContent className="pt-0">
                                        <Button variant="outline" className="w-full gap-2 border-border/50">
                                            Baixar PDF
                                        </Button>
                                    </CardContent>
                                </Card>
                            ))}
                        </div>
                    )}

                    {activeTab === "textos" && (
                        <div className="max-w-4xl mx-auto w-full animate-in slide-in-from-bottom-4 duration-500">
                            {/* Placeholder para Textos (MD) */}
                            <div className="space-y-4">
                                {[1, 2].map((i) => (
                                    <Card key={i} className="border-border/50 hover:bg-muted/10 transition-colors cursor-pointer group">
                                        <CardHeader>
                                            <div className="flex items-center justify-between">
                                                <div className="space-y-1">
                                                    <CardTitle className="text-xl group-hover:text-primary transition-colors text-foreground">
                                                        Artigo ou Guia de Leitura {i}
                                                    </CardTitle>
                                                    <CardDescription>Publicado em 23 de Março, 2026</CardDescription>
                                                </div>
                                                <BookOpenIcon className="h-5 w-5 text-muted-foreground" />
                                            </div>
                                        </CardHeader>
                                        <CardContent>
                                            <p className="text-muted-foreground">
                                                Este conteúdo virá de arquivos .md renderizados dinamicamente na página.
                                            </p>
                                        </CardContent>
                                    </Card>
                                ))}
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
