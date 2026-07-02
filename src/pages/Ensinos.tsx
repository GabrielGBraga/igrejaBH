import { useState, useEffect, useRef } from "react";
import { useForm, Controller } from "react-hook-form";
import * as z from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    PlusIcon, 
    SearchIcon,
    Loader2Icon,
    CheckCircle2Icon,
    LockIcon,
    ArrowUpIcon,
    ArrowDownIcon,
    Trash2Icon,
    ChevronRightIcon,
    PlayIcon,
    CheckIcon,
    EyeIcon,
    GraduationCapIcon,
    DownloadIcon,
    PencilIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import supabase from "@/lib/supabase";
import { TextEditor } from "@/components/TextEditor";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Progress } from "@/components/ui/progress";
import { toast } from "sonner";
import {
    Field,
    FieldLabel,
    FieldDescription,
    FieldError
} from "@/components/ui/field";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
    DialogFooter
} from "@/components/ui/dialog";
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { fetchLatestVideos, type YouTubeVideo } from "@/lib/youtube";
import type { Database } from "@/lib/database.types";

type TabType = "estudos" | "videos" | "pdfs" | "textos";

type MediaResource = Database["public"]["Tables"]["media_resources"]["Row"];
type Study = Database["public"]["Tables"]["studies"]["Row"];
type StudyStep = Database["public"]["Tables"]["study_steps"]["Row"] & {
    media_resource: MediaResource;
};
type UserProgress = Database["public"]["Tables"]["user_study_progress"]["Row"];

interface Profile {
    id: string;
    is_presbyter: boolean;
    is_deacon: boolean;
    is_dev: boolean;
}

// Zod schemas for validation
const resourceSchema = z.object({
    title: z.string().min(3, "O título deve ter pelo menos 3 caracteres"),
    description: z.string().optional(),
    type: z.enum(["video", "pdf", "markdown"]),
    url: z.string().optional(),
});

const studySchema = z.object({
    title: z.string().min(3, "O título deve ter pelo menos 3 caracteres"),
    description: z.string().optional(),
});

type ResourceFormValues = z.infer<typeof resourceSchema>;
type StudyFormValues = z.infer<typeof studySchema>;

export default function Ensinos() {
    const [activeTab, setActiveTab] = useState<TabType>("estudos");
    const [profile, setProfile] = useState<Profile | null>(null);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    // Database content states
    const [resources, setResources] = useState<MediaResource[]>([]);
    const [studies, setStudies] = useState<Study[]>([]);
    const [studySteps, setStudySteps] = useState<StudyStep[]>([]);
    const [userProgress, setUserProgress] = useState<UserProgress[]>([]);
    const [loadingData, setLoadingData] = useState(true);

    // Youtube fallback
    const [youtubeVideos, setYoutubeVideos] = useState<YouTubeVideo[]>([]);
    const [loadingYoutube, setLoadingYoutube] = useState(false);

    // Modal control states
    const [isAddResourceOpen, setIsAddResourceOpen] = useState(false);
    const [isCreateStudyOpen, setIsCreateStudyOpen] = useState(false);
    const [selectedStudy, setSelectedStudy] = useState<Study | null>(null);
    const [activeStep, setActiveStep] = useState<StudyStep | null>(null);
    const [isTextEditorOpen, setIsTextEditorOpen] = useState(false);
    const [editingTextResource, setEditingTextResource] = useState<MediaResource | null>(null);

    // File upload state
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [uploadingFile, setUploadingFile] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);

    // Selected resources for study creation
    const [selectedResourcesForStudy, setSelectedResourcesForStudy] = useState<MediaResource[]>([]);
    const [selectedResourceVal, setSelectedResourceVal] = useState<string>("");
    const [editingStudy, setEditingStudy] = useState<Study | null>(null);
    const [animatingIndices, setAnimatingIndices] = useState<{ up: number; down: number } | null>(null);

    // React Hook Forms
    const resourceForm = useForm<ResourceFormValues>({
        resolver: zodResolver(resourceSchema),
        defaultValues: {
            title: "",
            description: "",
            type: "video",
            url: ""
        }
    });

    const studyForm = useForm<StudyFormValues>({
        resolver: zodResolver(studySchema),
        defaultValues: {
            title: "",
            description: ""
        }
    });

    const resourceType = resourceForm.watch("type");

    useEffect(() => {
        async function fetchProfileAndData() {
            try {
                setLoading(true);
                const { data: { session } } = await supabase.auth.getSession();
                if (session?.user) {
                    const { data: profData } = await supabase
                        .from("profiles")
                        .select("id, is_presbyter, is_deacon, is_dev")
                        .eq("user_id", session.user.id)
                        .single();
                    
                    if (profData) {
                        const profObj = {
                            id: profData.id,
                            is_presbyter: !!profData.is_presbyter,
                            is_deacon: !!profData.is_deacon,
                            is_dev: !!profData.is_dev,
                        };
                        setProfile(profObj);
                        await loadDatabaseData(profObj.id);
                    }
                }
            } catch (err) {
                console.error("Error fetching initial profile data:", err);
            } finally {
                setLoading(false);
            }
        }
        fetchProfileAndData();
    }, []);

    async function loadDatabaseData(profileId: string) {
        try {
            setLoadingData(true);
            
            // 1. Fetch Media Resources
            const { data: resData } = await supabase
                .from("media_resources")
                .select("*")
                .order("created_at", { ascending: false });
            setResources(resData || []);

            // 2. Fetch Studies
            const { data: stdData } = await supabase
                .from("studies")
                .select("*")
                .order("created_at", { ascending: false });
            setStudies(stdData || []);

            // 3. Fetch Study Steps (with media resources)
            const { data: stepsData } = await supabase
                .from("study_steps")
                .select("*, media_resource:media_resources(*)")
                .order("sort_order", { ascending: true });
            
            // Cast to typed StudyStep
            setStudySteps((stepsData as any) || []);

            // 4. Fetch User Progress
            const { data: progData } = await supabase
                .from("user_study_progress")
                .select("*")
                .eq("profile_id", profileId);
            setUserProgress(progData || []);

        } catch (err) {
            console.error("Error loading learning data:", err);
            toast.error("Erro ao carregar dados do servidor.");
        } finally {
            setLoadingData(false);
        }
    }

    // Load Youtube Fallback Videos
    useEffect(() => {
        async function loadYoutubeFallback() {
            if (activeTab === "videos" && youtubeVideos.length === 0) {
                setLoadingYoutube(true);
                const fetched = await fetchLatestVideos();
                setYoutubeVideos(fetched);
                setLoadingYoutube(false);
            }
        }
        loadYoutubeFallback();
    }, [activeTab, youtubeVideos.length]);

    const canAddMaterial = profile?.is_presbyter || profile?.is_deacon || profile?.is_dev;

    // Filter content based on search query
    const filteredResources = resources.filter(res => {
        const matchesSearch = res.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
            (res.description && res.description.toLowerCase().includes(searchQuery.toLowerCase()));
        return matchesSearch;
    });

    const filteredStudies = studies.filter(std => {
        return std.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (std.description && std.description.toLowerCase().includes(searchQuery.toLowerCase()));
    });

    // Segment resources by active tab
    const tabVideos = filteredResources.filter(r => r.type === "video");
    const tabPDFs = filteredResources.filter(r => r.type === "pdf");
    const tabTextos = filteredResources.filter(r => r.type === "markdown");

    // Add Media Resource Handler
    const handleAddResourceSubmit = async (values: ResourceFormValues) => {
        if (!profile) return;
        
        let publicUrl = values.url || "";

        try {
            resourceForm.clearErrors();
            setUploadingFile(true);

            if (values.type === "pdf" || values.type === "markdown") {
                if (!selectedFile) {
                    toast.error("Selecione um arquivo para fazer upload.");
                    setUploadingFile(false);
                    return;
                }

                // Check extension
                const ext = selectedFile.name.split('.').pop()?.toLowerCase();
                if (values.type === "pdf" && ext !== "pdf") {
                    toast.error("Por favor, selecione um arquivo PDF válido.");
                    setUploadingFile(false);
                    return;
                }
                if (values.type === "markdown" && ext !== "md" && ext !== "markdown") {
                    toast.error("Por favor, selecione um arquivo Markdown (.md) válido.");
                    setUploadingFile(false);
                    return;
                }

                const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.${ext}`;
                const filePath = `${profile.id}/${fileName}`;

                const { error: uploadError } = await supabase.storage
                    .from("ensinos")
                    .upload(filePath, selectedFile, {
                        cacheControl: '3600',
                        upsert: false
                    });

                if (uploadError) throw uploadError;

                const { data: urlData } = supabase.storage
                    .from("ensinos")
                    .getPublicUrl(filePath);
                
                publicUrl = urlData.publicUrl;
            }

            if (!publicUrl) {
                toast.error("Por favor, informe a URL do vídeo.");
                setUploadingFile(false);
                return;
            }

            const { error: insertError } = await supabase
                .from("media_resources")
                .insert({
                    title: values.title,
                    description: values.description || null,
                    type: values.type,
                    url: publicUrl,
                    category: activeTab !== "estudos" ? activeTab : "ensinos"
                });

            if (insertError) throw insertError;

            toast.success("Recurso adicionado com sucesso!");
            setIsAddResourceOpen(false);
            resourceForm.reset();
            setSelectedFile(null);
            if (fileInputRef.current) fileInputRef.current.value = "";
            await loadDatabaseData(profile.id);

        } catch (err: any) {
            console.error("Error creating resource:", err);
            toast.error(err.message || "Erro ao salvar recurso.");
        } finally {
            setUploadingFile(false);
        }
    };

    // Save Rich Text Handler
    const handleSaveText = async (data: { title: string; description: string; markdownContent: string }) => {
        if (!profile) return;

        try {
            const blob = new Blob([data.markdownContent], { type: "text/markdown" });

            if (editingTextResource) {
                // Editing existing resource
                const urlParts = editingTextResource.url.split("/ensinos/");
                if (urlParts.length <= 1) {
                    throw new Error("URL do recurso inválida para edição.");
                }
                const storagePath = urlParts[1];

                // Upload overwriting existing file
                const { error: uploadError } = await supabase.storage
                    .from("ensinos")
                    .upload(storagePath, blob, {
                        cacheControl: '3600',
                        upsert: true
                    });

                if (uploadError) throw uploadError;

                // Update database metadata
                const { error: updateError } = await supabase
                    .from("media_resources")
                    .update({
                        title: data.title,
                        description: data.description || null
                    })
                    .eq("id", editingTextResource.id);

                if (updateError) throw updateError;

                toast.success("Texto atualizado com sucesso!");
                setEditingTextResource(null);
            } else {
                // Creating new resource
                const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.md`;
                const filePath = `${profile.id}/${fileName}`;

                // Upload new file
                const { error: uploadError } = await supabase.storage
                    .from("ensinos")
                    .upload(filePath, blob, {
                        cacheControl: '3600',
                        upsert: false
                    });

                if (uploadError) throw uploadError;

                // Get public URL
                const { data: urlData } = supabase.storage
                    .from("ensinos")
                    .getPublicUrl(filePath);

                const publicUrl = urlData.publicUrl;

                // Insert into media_resources
                const { error: insertError } = await supabase
                    .from("media_resources")
                    .insert({
                        title: data.title,
                        description: data.description || null,
                        type: "markdown",
                        url: publicUrl,
                        category: "textos"
                    });

                if (insertError) throw insertError;

                toast.success("Texto criado com sucesso!");
            }

            await loadDatabaseData(profile.id);
        } catch (err) {
            const error = err as Error;
            console.error("Error saving rich text:", error);
            toast.error(error.message || "Erro ao salvar texto.");
            throw error;
        }
    };

    // Create or Edit Study Handler
    const handleCreateStudySubmit = async (values: StudyFormValues) => {
        if (!profile) return;
        if (selectedResourcesForStudy.length === 0) {
            toast.error("Adicione pelo menos um recurso (etapa) ao estudo.");
            return;
        }

        try {
            setLoadingData(true);

            if (editingStudy) {
                // Update study
                const { error: studyError } = await supabase
                    .from("studies")
                    .update({
                        title: values.title,
                        description: values.description || null
                    })
                    .eq("id", editingStudy.id);

                if (studyError) throw studyError;

                // Delete existing steps
                const { error: deleteStepsError } = await supabase
                    .from("study_steps")
                    .delete()
                    .eq("study_id", editingStudy.id);

                if (deleteStepsError) throw deleteStepsError;

                // Insert updated steps
                const stepsData = selectedResourcesForStudy.map((res, index) => ({
                    study_id: editingStudy.id,
                    media_resource_id: res.id,
                    sort_order: index + 1
                }));

                const { error: stepsError } = await supabase
                    .from("study_steps")
                    .insert(stepsData);

                if (stepsError) throw stepsError;

                toast.success("Estudo atualizado com sucesso!");
            } else {
                // Insert study
                const { data: newStudy, error: studyError } = await supabase
                    .from("studies")
                    .insert({
                        title: values.title,
                        description: values.description || null,
                        created_by: profile.id
                    })
                    .select()
                    .single();

                if (studyError) throw studyError;

                // Insert study steps
                const stepsData = selectedResourcesForStudy.map((res, index) => ({
                    study_id: newStudy.id,
                    media_resource_id: res.id,
                    sort_order: index + 1
                }));

                const { error: stepsError } = await supabase
                    .from("study_steps")
                    .insert(stepsData);

                if (stepsError) throw stepsError;

                toast.success("Estudo criado com sucesso!");
            }

            setIsCreateStudyOpen(false);
            setEditingStudy(null);
            studyForm.reset();
            setSelectedResourcesForStudy([]);
            await loadDatabaseData(profile.id);

        } catch (err: any) {
            console.error("Error saving study:", err);
            toast.error(err.message || "Erro ao salvar estudo.");
        } finally {
            setLoadingData(false);
        }
    };

    // Edit Study Helper
    const handleEditStudy = (study: Study, e: React.MouseEvent) => {
        e.stopPropagation();
        setEditingStudy(study);
        
        studyForm.reset({
            title: study.title,
            description: study.description || ""
        });
        
        // Find steps for this study and resolve their media resources
        const currentSteps = studySteps
            .filter(s => s.study_id === study.id)
            .map(s => s.media_resource)
            .filter((res): res is MediaResource => res !== null);
        
        setSelectedResourcesForStudy(currentSteps);
        setIsCreateStudyOpen(true);
    };

    // Study deletion helper
    const handleDeleteStudy = async (studyId: string, e: React.MouseEvent) => {
        e.stopPropagation();
        if (!profile) return;
        if (!confirm("Deseja realmente excluir este estudo? As etapas e progressos serão removidos.")) return;

        try {
            setLoadingData(true);
            const { error } = await supabase
                .from("studies")
                .delete()
                .eq("id", studyId);
            
            if (error) throw error;
            
            toast.success("Estudo removido.");
            await loadDatabaseData(profile.id);
        } catch (err: any) {
            console.error("Error deleting study:", err);
            toast.error(err.message || "Erro ao deletar estudo.");
        } finally {
            setLoadingData(false);
        }
    };

    // Resource deletion helper
    const handleDeleteResource = async (resourceId: string, e: React.MouseEvent) => {
        e.stopPropagation();
        if (!profile) return;
        if (!confirm("Deseja excluir este recurso de mídia? Ele será removido de qualquer estudo associado.")) return;

        try {
            setLoadingData(true);

            // Fetch resource info to check storage path
            const { data: resInfo } = await supabase
                .from("media_resources")
                .select("url, type")
                .eq("id", resourceId)
                .single();

            if (resInfo && (resInfo.type === "pdf" || resInfo.type === "markdown")) {
                // Extract filename from public URL
                // Format: .../storage/v1/object/public/ensinos/PROFILE_ID/FILENAME
                const urlParts = resInfo.url.split("/ensinos/");
                if (urlParts.length > 1) {
                    const storagePath = urlParts[1];
                    await supabase.storage.from("ensinos").remove([storagePath]);
                }
            }

            const { error } = await supabase
                .from("media_resources")
                .delete()
                .eq("id", resourceId);
            
            if (error) throw error;

            toast.success("Recurso excluído.");
            await loadDatabaseData(profile.id);
        } catch (err: any) {
            console.error("Error deleting resource:", err);
            toast.error(err.message || "Erro ao deletar recurso.");
        } finally {
            setLoadingData(false);
        }
    };

    // Toggle complete step logic
    const handleToggleCompleteStep = async (step: StudyStep) => {
        if (!profile) return;

        const isCompleted = userProgress.some(p => p.step_id === step.id);

        try {
            if (isCompleted) {
                // Unmark completed
                const { error } = await supabase
                    .from("user_study_progress")
                    .delete()
                    .eq("profile_id", profile.id)
                    .eq("step_id", step.id);
                
                if (error) throw error;
                toast.success("Etapa marcada como pendente.");
            } else {
                // Mark completed
                const { error } = await supabase
                    .from("user_study_progress")
                    .insert({
                        profile_id: profile.id,
                        study_id: step.study_id,
                        step_id: step.id
                    });
                
                if (error) throw error;
                toast.success("Etapa concluída!");
            }

            // Reload user progress and studies state
            const { data: progData } = await supabase
                .from("user_study_progress")
                .select("*")
                .eq("profile_id", profile.id);
            setUserProgress(progData || []);

            // Check if study is completed
            if (selectedStudy) {
                const currentStudySteps = studySteps.filter(s => s.study_id === selectedStudy.id);
                const currentCompletedCount = (progData || []).filter(p => p.study_id === selectedStudy.id).length;
                if (!isCompleted && currentCompletedCount === currentStudySteps.length) {
                    toast.success(`Parabéns! Você concluiu com sucesso o estudo: ${selectedStudy.title}! 🎉`, {
                        duration: 6000
                    });
                }
            }

        } catch (err: any) {
            console.error("Error toggling step progress:", err);
            toast.error("Erro ao atualizar progresso.");
        }
    };

    // Calculate individual study progress
    const getStudyProgressData = (studyId: string) => {
        const currentStudySteps = studySteps.filter(s => s.study_id === studyId);
        const total = currentStudySteps.length;
        const completed = userProgress.filter(p => p.study_id === studyId).length;
        const percent = total > 0 ? Math.round((completed / total) * 100) : 0;
        return { total, completed, percent, steps: currentStudySteps };
    };

    // Calculate overall studies progress
    const getOverallProgressPercent = () => {
        const total = studySteps.length;
        const completed = userProgress.length;
        return total > 0 ? Math.round((completed / total) * 100) : 0;
    };

    // Extract YouTube ID helper
    const getYouTubeId = (url: string) => {
        const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
        const match = url.match(regExp);
        return (match && match[2].length === 11) ? match[2] : null;
    };

    const tabs = [
        { id: "estudos", label: "Estudos", icon: GraduationCapIcon },
        { id: "videos", label: "Vídeos", icon: YoutubeIcon },
        { id: "pdfs", label: "PDFs", icon: FileTextIcon },
        { id: "textos", label: "Textos/MD", icon: BookOpenIcon },
    ];

    if (loading) {
        return (
            <div className="flex h-[60vh] items-center justify-center">
                <Loader2Icon className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
            
            {/* Header section */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border pb-6">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-foreground">
                        Ensinos e Recursos
                    </h1>
                    <p className="text-muted-foreground mt-1">
                        Acesse estudos estruturados, vídeos, apostilas e textos informativos do Corpo.
                    </p>
                </div>
                <div className="flex flex-wrap gap-2">
                    {canAddMaterial && (
                        <>
                            <Button 
                                onClick={() => setIsCreateStudyOpen(true)}
                                variant="outline"
                                className="shrink-0 gap-2 rounded-full px-5 border-primary/20 text-primary hover:bg-primary/5"
                            >
                                <PlusIcon className="h-4 w-4" />
                                Criar Estudo
                            </Button>
                            <Button 
                                onClick={() => setIsAddResourceOpen(true)}
                                className="shrink-0 gap-2 shadow-lg shadow-primary/20 rounded-full px-5"
                            >
                                <PlusIcon className="h-4 w-4" />
                                Adicionar Recurso
                            </Button>
                            {activeTab === "textos" && (
                                <Button 
                                    onClick={() => {
                                        setEditingTextResource(null);
                                        setIsTextEditorOpen(true);
                                    }}
                                    className="shrink-0 gap-2 shadow-lg shadow-amber-500/20 bg-amber-600 hover:bg-amber-700 text-white rounded-full px-5 border-0 cursor-pointer"
                                >
                                    <PencilIcon className="h-4 w-4" />
                                    Escrever Texto
                                </Button>
                            )}
                        </>
                    )}
                </div>
            </div>

            {/* Overall progress indicator (Only when studies exist) */}
            {studies.length > 0 && (
                <Card className="border-border/50 bg-card/30 backdrop-blur-sm overflow-hidden rounded-2xl">
                    <CardContent className="p-6">
                        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div className="space-y-1">
                                <h3 className="font-semibold text-lg text-foreground">Progresso Geral em Estudos</h3>
                                <p className="text-xs text-muted-foreground">Estatísticas de conclusão de todas as etapas e cursos disponíveis.</p>
                            </div>
                            <div className="flex items-center gap-4 w-full md:max-w-md">
                                <div className="flex-1 space-y-1">
                                    <div className="flex justify-between text-xs font-semibold">
                                        <span className="text-primary">{userProgress.length} de {studySteps.length} etapas</span>
                                        <span className="text-foreground">{getOverallProgressPercent()}%</span>
                                    </div>
                                    <Progress value={getOverallProgressPercent()} className="h-3 bg-muted/60" />
                                </div>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            )}

            {/* Navigation and Search controls */}
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
                            placeholder={`Buscar ${activeTab === 'estudos' ? 'estudos' : 'recursos'}...`}
                            className="pl-10 bg-card/30 backdrop-blur-sm border-border/50 rounded-xl focus:border-primary/50 transition-all focus:ring-2 focus:ring-primary/20"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                        />
                    </div>
                </div>

                {/* Content Sections */}
                <div className="min-h-[300px]">
                    {loadingData ? (
                        <div className="flex justify-center items-center py-24">
                            <Loader2Icon className="h-10 w-10 animate-spin text-primary" />
                        </div>
                    ) : (
                        <>
                            {/* TAB: ESTUDOS */}
                            {activeTab === "estudos" && (
                                <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                    {filteredStudies.length > 0 ? (
                                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                            {filteredStudies.map((study) => {
                                                const { total, completed, percent } = getStudyProgressData(study.id);
                                                return (
                                                    <Card 
                                                        key={study.id} 
                                                        onClick={() => setSelectedStudy(study)}
                                                        className="overflow-hidden border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl hover:shadow-primary/5 cursor-pointer group flex flex-col rounded-2xl relative"
                                                    >
                                                        <CardHeader className="p-6 pb-4">
                                                            <div className="flex justify-between items-start gap-4">
                                                                <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                                                                    <BookOpenIcon className="h-5 w-5 text-primary" />
                                                                </div>
                                                                {canAddMaterial && (
                                                                    <div className="flex gap-1">
                                                                        <Button
                                                                            variant="ghost"
                                                                            size="icon"
                                                                            onClick={(e) => handleEditStudy(study, e)}
                                                                            className="h-8 w-8 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-full"
                                                                            title="Editar Estudo"
                                                                        >
                                                                            <PencilIcon className="h-4 w-4" />
                                                                        </Button>
                                                                        <Button
                                                                            variant="ghost"
                                                                            size="icon"
                                                                            onClick={(e) => handleDeleteStudy(study.id, e)}
                                                                            className="h-8 w-8 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full"
                                                                            title="Excluir Estudo"
                                                                        >
                                                                            <Trash2Icon className="h-4 w-4" />
                                                                        </Button>
                                                                    </div>
                                                                )}
                                                            </div>
                                                            <CardTitle className="text-lg text-foreground group-hover:text-primary transition-colors mt-3">
                                                                {study.title}
                                                            </CardTitle>
                                                            <CardDescription className="line-clamp-2 mt-1">
                                                                {study.description || "Nenhuma descrição informada."}
                                                            </CardDescription>
                                                        </CardHeader>
                                                        <CardContent className="p-6 pt-0 mt-auto space-y-4">
                                                            <div className="space-y-1">
                                                                <div className="flex justify-between text-xs">
                                                                    <span className="text-muted-foreground">{completed} de {total} etapas</span>
                                                                    <span className="font-semibold text-foreground">{percent}%</span>
                                                                </div>
                                                                <Progress value={percent} className="h-2" />
                                                            </div>
                                                            <Button variant="outline" className="w-full gap-2 border-border/50 rounded-xl hover:bg-zinc-900 hover:text-zinc-50 dark:hover:bg-zinc-100 dark:hover:text-zinc-950 group-hover:border-primary/50 transition-all">
                                                                {percent === 100 ? "Rever Estudo" : percent > 0 ? "Continuar Estudo" : "Começar Estudo"}
                                                                <ChevronRightIcon className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                                                            </Button>
                                                        </CardContent>
                                                    </Card>
                                                );
                                            })}
                                        </div>
                                    ) : (
                                        <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/50 rounded-3xl">
                                            <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                                <GraduationCapIcon className="h-8 w-8 text-muted-foreground/40" />
                                            </div>
                                            <h3 className="text-lg font-medium text-foreground">Nenhum estudo disponível</h3>
                                            <p className="text-muted-foreground mt-2 max-w-sm mx-auto text-sm">
                                                Estudos estruturados com progresso ordenado serão cadastrados aqui pela liderança.
                                            </p>
                                        </div>
                                    )}
                                </div>
                            )}

                            {/* TAB: VÍDEOS */}
                            {activeTab === "videos" && (() => {
                                const dbVideoIds = new Set(
                                    tabVideos
                                        .map(v => getYouTubeId(v.url))
                                        .filter(id => id !== null)
                                );
                                const uniqueYoutubeVideos = youtubeVideos.filter(yt => !dbVideoIds.has(yt.id));

                                return (
                                    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                                        {/* Database Videos (Recursos do Acervo) */}
                                        {tabVideos.length > 0 && (
                                            <div className="space-y-4">
                                                <h3 className="text-lg font-bold text-foreground flex items-center gap-2">
                                                    <span className="w-2.5 h-2.5 rounded-full bg-primary" />
                                                    Vídeos do Acervo
                                                </h3>
                                                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                                    {tabVideos.map((video) => {
                                                        const ytId = getYouTubeId(video.url);
                                                        const thumb = ytId ? `https://img.youtube.com/vi/${ytId}/mqdefault.jpg` : "";
                                                        return (
                                                            <Card 
                                                                key={video.id} 
                                                                className="overflow-hidden border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl hover:shadow-primary/5 cursor-pointer group flex flex-col rounded-2xl relative"
                                                                onClick={() => setActiveStep({ id: "", study_id: "", media_resource_id: video.id, sort_order: 0, created_at: "", media_resource: video })}
                                                            >
                                                                <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden shrink-0">
                                                                    {thumb ? (
                                                                        <img 
                                                                            src={thumb} 
                                                                            alt={video.title} 
                                                                            className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" 
                                                                        />
                                                                    ) : (
                                                                        <div className="w-full h-full flex items-center justify-center bg-black/80">
                                                                            <YoutubeIcon className="h-12 w-12 text-destructive" />
                                                                        </div>
                                                                    )}
                                                                    <div className="absolute inset-0 bg-black/40 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                                                                        <div className="w-12 h-12 rounded-full bg-primary/95 flex items-center justify-center opacity-0 group-hover:opacity-100 transform scale-50 group-hover:scale-100 transition-all duration-300 shadow-xl">
                                                                            <PlayIcon className="h-6 w-6 text-primary-foreground fill-primary-foreground ml-1" />
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <CardHeader className="flex-1 p-5">
                                                                    <div className="flex justify-between items-start gap-4">
                                                                        <CardTitle className="text-base text-foreground line-clamp-2 leading-tight group-hover:text-primary transition-colors" title={video.title}>
                                                                            {video.title}
                                                                        </CardTitle>
                                                                        {canAddMaterial && (
                                                                            <Button
                                                                                variant="ghost"
                                                                                size="icon"
                                                                                onClick={(e) => handleDeleteResource(video.id, e)}
                                                                                className="h-8 w-8 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full shrink-0 -mt-1 -mr-2"
                                                                                title="Excluir Recurso"
                                                                            >
                                                                                <Trash2Icon className="h-4 w-4" />
                                                                            </Button>
                                                                        )}
                                                                    </div>
                                                                    {video.description && (
                                                                        <CardDescription className="line-clamp-2 text-xs pt-1">
                                                                            {video.description}
                                                                        </CardDescription>
                                                                    )}
                                                                </CardHeader>
                                                            </Card>
                                                        );
                                                    })}
                                                </div>
                                            </div>
                                        )}

                                        {/* Youtube Channel Videos (Últimos do Canal) */}
                                        {loadingYoutube ? (
                                            <div className="flex justify-center items-center py-16">
                                                <Loader2Icon className="h-10 w-10 animate-spin text-primary" />
                                            </div>
                                        ) : uniqueYoutubeVideos.length > 0 ? (
                                            <div className="space-y-4">
                                                {tabVideos.length > 0 && <hr className="border-border/40" />}
                                                <h3 className="text-lg font-bold text-foreground flex items-center gap-2 text-muted-foreground">
                                                    <YoutubeIcon className="h-5 w-5 text-destructive" />
                                                    Vídeos Recentes do Canal
                                                </h3>
                                                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                                    {uniqueYoutubeVideos.map((video) => (
                                                        <Card 
                                                            key={video.id} 
                                                            className="overflow-hidden border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl hover:shadow-primary/5 cursor-pointer group flex flex-col rounded-2xl"
                                                            onClick={() => {
                                                                const mockResource: MediaResource = {
                                                                    id: "",
                                                                    title: video.title,
                                                                    description: video.description,
                                                                    type: "video",
                                                                    url: `https://www.youtube.com/watch?v=${video.id}`,
                                                                    series_name: null,
                                                                    category: "youtube",
                                                                    created_at: video.publishedAt
                                                                };
                                                                setActiveStep({ id: "", study_id: "", media_resource_id: "", sort_order: 0, created_at: "", media_resource: mockResource });
                                                            }}
                                                        >
                                                            <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden shrink-0">
                                                                <img 
                                                                    src={video.thumbnailUrl} 
                                                                    alt={video.title} 
                                                                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" 
                                                                />
                                                                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                                                                    <div className="w-12 h-12 rounded-full bg-primary/95 flex items-center justify-center opacity-0 group-hover:opacity-100 transform scale-50 group-hover:scale-100 transition-all duration-300 shadow-xl">
                                                                        <PlayIcon className="h-6 w-6 text-primary-foreground fill-primary-foreground ml-1" />
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
                                            </div>
                                        ) : null}

                                        {tabVideos.length === 0 && youtubeVideos.length === 0 && !loadingYoutube && (
                                            <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/50 rounded-3xl">
                                                <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                                    <YoutubeIcon className="h-8 w-8 text-muted-foreground/30" />
                                                </div>
                                                <h3 className="text-lg font-medium text-foreground">Nenhum vídeo disponível</h3>
                                                <p className="text-muted-foreground mt-2 max-w-sm mx-auto text-sm">
                                                    Os vídeos de estudos e pregações aparecerão aqui.
                                                </p>
                                            </div>
                                        )}
                                    </div>
                                );
                            })()}

                            {/* TAB: PDFs */}
                            {activeTab === "pdfs" && (
                                <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                    {tabPDFs.length > 0 ? (
                                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 lg:grid-cols-4 gap-6">
                                            {tabPDFs.map((pdf) => (
                                                <Card key={pdf.id} className="flex flex-col border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl group rounded-2xl overflow-hidden relative">
                                                    <CardHeader className="flex-1 p-6">
                                                        <div className="flex justify-between items-start gap-4">
                                                            <div className="w-12 h-12 rounded-2xl bg-red-500/10 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform duration-300">
                                                                <FileTextIcon className="h-6 w-6 text-red-500" />
                                                            </div>
                                                            {canAddMaterial && (
                                                                <Button
                                                                    variant="ghost"
                                                                    size="icon"
                                                                    onClick={(e) => handleDeleteResource(pdf.id, e)}
                                                                    className="h-8 w-8 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full"
                                                                    title="Excluir PDF"
                                                                >
                                                                    <Trash2Icon className="h-4 w-4" />
                                                                </Button>
                                                            )}
                                                        </div>
                                                        <CardTitle className="text-base text-foreground group-hover:text-primary transition-colors leading-tight">
                                                            {pdf.title}
                                                        </CardTitle>
                                                        {pdf.description && (
                                                            <CardDescription className="line-clamp-2 text-xs pt-1">
                                                                {pdf.description}
                                                            </CardDescription>
                                                        )}
                                                    </CardHeader>
                                                    <CardContent className="p-6 pt-0 space-y-2">
                                                        <Button 
                                                            variant="outline" 
                                                            className="w-full gap-2 border-border/50 rounded-xl hover:bg-primary hover:text-primary-foreground transition-all"
                                                            onClick={() => setActiveStep({ id: "", study_id: "", media_resource_id: pdf.id, sort_order: 0, created_at: "", media_resource: pdf })}
                                                        >
                                                            <EyeIcon className="h-4 w-4" />
                                                            Visualizar
                                                        </Button>
                                                    </CardContent>
                                                </Card>
                                            ))}
                                        </div>
                                    ) : (
                                        <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/50 rounded-3xl">
                                            <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                                <FileTextIcon className="h-8 w-8 text-muted-foreground/30" />
                                            </div>
                                            <h3 className="text-lg font-medium text-foreground">Nenhum PDF cadastrado</h3>
                                            <p className="text-muted-foreground mt-2 max-w-sm mx-auto text-sm">
                                                Apostilas, catequeses e guias em formato PDF aparecerão aqui.
                                            </p>
                                        </div>
                                    )}
                                </div>
                            )}

                            {/* TAB: TEXTOS */}
                            {activeTab === "textos" && (
                                <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                    {tabTextos.length > 0 ? (
                                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                            {tabTextos.map((texto) => (
                                                <Card 
                                                    key={texto.id} 
                                                    onClick={() => setActiveStep({ id: "", study_id: "", media_resource_id: texto.id, sort_order: 0, created_at: "", media_resource: texto })}
                                                    className="border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl cursor-pointer group rounded-2xl overflow-hidden relative flex flex-col"
                                                >
                                                    <CardHeader className="p-6 flex-1">
                                                        <div className="flex justify-between items-start gap-4">
                                                            <div className="w-10 h-10 rounded-xl bg-amber-500/10 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform duration-300">
                                                                <BookOpenIcon className="h-5 w-5 text-amber-600 dark:text-amber-500" />
                                                            </div>
                                                            {canAddMaterial && (
                                                                <div className="flex items-center gap-1">
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="icon"
                                                                        onClick={(e) => {
                                                                            e.stopPropagation();
                                                                            setEditingTextResource(texto);
                                                                            setIsTextEditorOpen(true);
                                                                        }}
                                                                        className="h-8 w-8 text-muted-foreground hover:text-amber-600 hover:bg-amber-500/10 rounded-full"
                                                                        title="Editar Texto"
                                                                    >
                                                                        <PencilIcon className="h-4 w-4" />
                                                                    </Button>
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="icon"
                                                                        onClick={(e) => handleDeleteResource(texto.id, e)}
                                                                        className="h-8 w-8 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full"
                                                                        title="Excluir Texto"
                                                                    >
                                                                        <Trash2Icon className="h-4 w-4" />
                                                                    </Button>
                                                                </div>
                                                            )}
                                                        </div>
                                                        <CardTitle className="text-base text-foreground group-hover:text-primary transition-colors leading-tight">
                                                            {texto.title}
                                                        </CardTitle>
                                                        {texto.description && (
                                                            <CardDescription className="line-clamp-3 text-xs pt-1">
                                                                {texto.description}
                                                            </CardDescription>
                                                        )}
                                                    </CardHeader>
                                                    <CardContent className="p-6 pt-0 mt-auto">
                                                        <div className="text-xs font-semibold text-primary group-hover:underline flex items-center gap-1">
                                                            Ler Texto <ChevronRightIcon className="h-3 w-3" />
                                                        </div>
                                                    </CardContent>
                                                </Card>
                                            ))}
                                        </div>
                                    ) : (
                                        <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/50 rounded-3xl">
                                            <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                                <BookOpenIcon className="h-8 w-8 text-muted-foreground/30" />
                                            </div>
                                            <h3 className="text-lg font-medium text-foreground">Nenhum texto cadastrado</h3>
                                            <p className="text-muted-foreground mt-2 max-w-sm mx-auto text-sm">
                                                Textos informativos, devocionais ou arquivos em Markdown (.md) aparecerão aqui.
                                            </p>
                                        </div>
                                    )}
                                </div>
                            )}
                        </>
                    )}
                </div>
            </div>

            {/* DIALOG: ADICIONAR RECURSO */}
            <Dialog open={isAddResourceOpen} onOpenChange={setIsAddResourceOpen}>
                <DialogContent className="sm:max-w-lg bg-card border-border shadow-2xl rounded-3xl">
                    <DialogHeader>
                        <DialogTitle>Adicionar Novo Recurso</DialogTitle>
                        <DialogDescription>
                            Adicione vídeos, arquivos PDF ou arquivos Markdown para complementar nossos ensinos.
                        </DialogDescription>
                    </DialogHeader>

                        <form onSubmit={resourceForm.handleSubmit(handleAddResourceSubmit)} className="space-y-4 pt-2">
                            <Controller
                                control={resourceForm.control}
                                name="title"
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel htmlFor="res-title">Título*</FieldLabel>
                                        <Input id="res-title" placeholder="Ex: Teologia da Vida Comum" className="rounded-xl" {...field} />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                control={resourceForm.control}
                                name="description"
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel htmlFor="res-desc">Descrição</FieldLabel>
                                        <Textarea id="res-desc" placeholder="Breve resumo sobre o recurso..." className="rounded-xl min-h-[80px]" {...field} />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                name="type"
                                control={resourceForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Tipo de Recurso</FieldLabel>
                                        <Select value={field.value} onValueChange={field.onChange}>
                                            <SelectTrigger className="rounded-xl bg-background/50 h-10 border border-input">
                                                <SelectValue placeholder="Selecione o tipo" />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="video">Vídeo (YouTube)</SelectItem>
                                                <SelectItem value="pdf">Arquivo PDF</SelectItem>
                                                <SelectItem value="markdown">Arquivo Markdown (.md)</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            {resourceType === "video" ? (
                                <Controller
                                    control={resourceForm.control}
                                    name="url"
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel htmlFor="res-url">URL do YouTube*</FieldLabel>
                                            <Input id="res-url" placeholder="https://www.youtube.com/watch?v=..." className="rounded-xl" {...field} />
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            ) : (
                                <Field>
                                    <FieldLabel htmlFor="res-file">Selecionar Arquivo*</FieldLabel>
                                    <Input 
                                        id="res-file" 
                                        type="file" 
                                        ref={fileInputRef}
                                        onChange={(e) => {
                                            const files = e.target.files;
                                            if (files && files.length > 0) {
                                                setSelectedFile(files[0]);
                                            }
                                        }}
                                        accept={resourceType === "pdf" ? ".pdf" : ".md,.markdown"}
                                        className="rounded-xl file:bg-primary file:text-primary-foreground file:border-0 file:rounded-md file:px-3 file:py-1 file:mr-2 file:text-xs file:font-semibold file:cursor-pointer cursor-pointer" 
                                    />
                                    <FieldDescription>
                                        {resourceType === "pdf" ? "Somente arquivos PDF" : "Arquivos Markdown (.md)"}
                                    </FieldDescription>
                                </Field>
                            )}

                            <DialogFooter className="pt-4">
                                <Button 
                                    type="button" 
                                    variant="ghost" 
                                    onClick={() => {
                                        setIsAddResourceOpen(false);
                                        setSelectedFile(null);
                                        if (fileInputRef.current) fileInputRef.current.value = "";
                                    }}
                                    className="rounded-full px-5"
                                >
                                    Cancelar
                                </Button>
                                <Button 
                                    type="submit" 
                                    disabled={uploadingFile}
                                    className="rounded-full px-6 shadow-md"
                                >
                                    {uploadingFile ? (
                                        <>
                                            <Loader2Icon className="h-4 w-4 animate-spin mr-2" />
                                            Salvando...
                                        </>
                                    ) : (
                                        "Salvar Recurso"
                                    )}
                                </Button>
                            </DialogFooter>
                        </form>
                </DialogContent>
            </Dialog>

            {/* DIALOG: CRIAR ESTUDO (CURSO) */}
            <Dialog open={isCreateStudyOpen} onOpenChange={(open) => {
                setIsCreateStudyOpen(open);
                if (!open) {
                    setEditingStudy(null);
                    studyForm.reset({ title: "", description: "" });
                    setSelectedResourcesForStudy([]);
                }
            }}>
                <DialogContent className="sm:max-w-2xl bg-card border-border shadow-2xl rounded-3xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>{editingStudy ? "Editar Estudo" : "Criar Novo Estudo"}</DialogTitle>
                        <DialogDescription>
                            {editingStudy 
                                ? "Modifique o título, descrição ou a ordem dos recursos deste estudo."
                                : "Monte um estudo unindo recursos de mídia de forma ordenada para criar uma trilha de aprendizagem."
                            }
                        </DialogDescription>
                    </DialogHeader>

                        <form onSubmit={studyForm.handleSubmit(handleCreateStudySubmit)} className="space-y-4 pt-2">
                            <Controller
                                control={studyForm.control}
                                name="title"
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel htmlFor="study-title">Título do Estudo*</FieldLabel>
                                        <Input id="study-title" placeholder="Ex: Catequese da Trindade" className="rounded-xl" {...field} />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                control={studyForm.control}
                                name="description"
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel htmlFor="study-desc">Descrição</FieldLabel>
                                        <Textarea id="study-desc" placeholder="Objetivo e resumo deste estudo..." className="rounded-xl min-h-[80px]" {...field} />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <div className="border border-border/60 rounded-2xl p-4 bg-muted/20 space-y-3">
                                <div className="flex justify-between items-center">
                                    <h4 className="text-sm font-semibold text-foreground">Etapas do Estudo (Em Ordem)</h4>
                                    <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full font-medium">
                                        {selectedResourcesForStudy.length} recursos
                                    </span>
                                </div>

                                {/* Resource Selector */}
                                <div className="flex items-center">
                                    <Select 
                                        value={selectedResourceVal}
                                        onValueChange={(val) => {
                                            if (!val) return;
                                            const res = resources.find(r => r.id === val);
                                            if (res && !selectedResourcesForStudy.some(item => item.id === res.id)) {
                                                setSelectedResourcesForStudy([...selectedResourcesForStudy, res]);
                                            }
                                            setSelectedResourceVal("");
                                        }}
                                    >
                                        <SelectTrigger className="rounded-xl border border-dashed border-primary/40 bg-transparent text-primary hover:bg-primary/5 px-4 h-10 w-fit flex items-center gap-2 font-medium cursor-pointer shadow-sm">
                                            <PlusIcon className="h-4 w-4" />
                                            <SelectValue placeholder="Adicionar Recurso à Trilha" />
                                        </SelectTrigger>
                                        <SelectContent position="popper">
                                            {resources.map(r => (
                                                <SelectItem key={r.id} value={r.id} disabled={selectedResourcesForStudy.some(s => s.id === r.id)}>
                                                    {r.type === 'video' ? '🎥' : r.type === 'pdf' ? '📄' : '📝'} {r.title}
                                                </SelectItem>
                                            ))}
                                        </SelectContent>
                                    </Select>
                                </div>

                                {/* Steps List with Up/Down/Delete */}
                                {selectedResourcesForStudy.length > 0 ? (
                                    <div className="space-y-2 max-h-[220px] overflow-y-auto pr-1 py-1">
                                        {selectedResourcesForStudy.map((res, index) => {
                                            const isMovingUp = animatingIndices?.up === index;
                                            const isMovingDown = animatingIndices?.down === index;

                                            return (
                                                <div 
                                                    key={res.id} 
                                                    className={cn(
                                                        "flex items-center justify-between p-2.5 bg-card border border-border/50 rounded-xl text-sm hover:border-primary/20 relative",
                                                        isMovingUp && "transition-transform duration-300 -translate-y-[50px] z-10 bg-muted/60 border-primary/40 shadow-md",
                                                        isMovingDown && "transition-transform duration-300 translate-y-[50px] z-10 bg-muted/60 border-primary/40 shadow-md"
                                                    )}
                                                >
                                                    <div className="flex items-center gap-2 font-medium">
                                                        <span className="w-5 h-5 rounded-full bg-muted flex items-center justify-center text-xs text-muted-foreground font-semibold">
                                                            {index + 1}
                                                        </span>
                                                        <span className="text-xs mr-1 text-muted-foreground">
                                                            {res.type === 'video' ? 'Vídeo' : res.type === 'pdf' ? 'PDF' : 'Texto'}
                                                        </span>
                                                        <span className="truncate max-w-[280px]" title={res.title}>{res.title}</span>
                                                    </div>
                                                    <div className="flex items-center gap-1 shrink-0">
                                                        <Button
                                                            type="button"
                                                            variant="ghost"
                                                            size="icon"
                                                            disabled={index === 0 || animatingIndices !== null}
                                                            onClick={() => {
                                                                setAnimatingIndices({ up: index, down: index - 1 });
                                                                setTimeout(() => {
                                                                    const newArr = [...selectedResourcesForStudy];
                                                                    const temp = newArr[index];
                                                                    newArr[index] = newArr[index - 1];
                                                                    newArr[index - 1] = temp;
                                                                    setSelectedResourcesForStudy(newArr);
                                                                    setAnimatingIndices(null);
                                                                }, 300);
                                                            }}
                                                            className="h-7 w-7 text-muted-foreground hover:text-foreground rounded-md disabled:opacity-30"
                                                            title="Mover para cima"
                                                        >
                                                            <ArrowUpIcon className="h-3.5 w-3.5" />
                                                        </Button>
                                                        <Button
                                                            type="button"
                                                            variant="ghost"
                                                            size="icon"
                                                            disabled={index === selectedResourcesForStudy.length - 1 || animatingIndices !== null}
                                                            onClick={() => {
                                                                setAnimatingIndices({ up: index + 1, down: index });
                                                                setTimeout(() => {
                                                                    const newArr = [...selectedResourcesForStudy];
                                                                    const temp = newArr[index];
                                                                    newArr[index] = newArr[index + 1];
                                                                    newArr[index + 1] = temp;
                                                                    setSelectedResourcesForStudy(newArr);
                                                                    setAnimatingIndices(null);
                                                                }, 300);
                                                            }}
                                                            className="h-7 w-7 text-muted-foreground hover:text-foreground rounded-md disabled:opacity-30"
                                                            title="Mover para baixo"
                                                        >
                                                            <ArrowDownIcon className="h-3.5 w-3.5" />
                                                        </Button>
                                                        <Button
                                                            type="button"
                                                            variant="ghost"
                                                            size="icon"
                                                            disabled={animatingIndices !== null}
                                                            onClick={() => {
                                                                setSelectedResourcesForStudy(selectedResourcesForStudy.filter(item => item.id !== res.id));
                                                            }}
                                                            className="h-7 w-7 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-md"
                                                            title="Remover"
                                                        >
                                                            <Trash2Icon className="h-3.5 w-3.5" />
                                                        </Button>
                                                    </div>
                                                </div>
                                            );
                                        })}
                                    </div>
                                ) : (
                                    <div className="text-center py-6 border border-dashed border-border/50 rounded-xl text-xs text-muted-foreground">
                                        Nenhum recurso adicionado a este estudo. Selecione recursos acima.
                                    </div>
                                )}
                            </div>

                            <DialogFooter className="pt-4">
                                <Button 
                                    type="button" 
                                    variant="ghost" 
                                    onClick={() => {
                                        setIsCreateStudyOpen(false);
                                        setSelectedResourcesForStudy([]);
                                    }}
                                    className="rounded-full px-5"
                                >
                                    Cancelar
                                </Button>
                                <Button 
                                    type="submit" 
                                    disabled={selectedResourcesForStudy.length === 0}
                                    className="rounded-full px-6 shadow-md"
                                >
                                    {editingStudy ? "Salvar Estudo" : "Criar Estudo"}
                                </Button>
                            </DialogFooter>
                        </form>
                </DialogContent>
            </Dialog>

            {/* DIALOG: VISUALIZAR ESTUDO (DETALHES DO CURSO) */}
            <Dialog open={!!selectedStudy} onOpenChange={(open) => !open && setSelectedStudy(null)}>
                {selectedStudy && (() => {
                    const { total, completed, percent, steps } = getStudyProgressData(selectedStudy.id);
                    return (
                        <DialogContent className="sm:max-w-2xl bg-card border-border shadow-2xl rounded-3xl max-h-[85vh] overflow-y-auto">
                            <DialogHeader className="relative pr-10">
                                <div className="flex justify-between items-start">
                                    <div className="flex-1 min-w-0 pr-4">
                                        <DialogTitle className="text-xl font-bold truncate" title={selectedStudy.title}>{selectedStudy.title}</DialogTitle>
                                        <DialogDescription className="mt-1">
                                            {selectedStudy.description || "Sem descrição disponível."}
                                        </DialogDescription>
                                    </div>
                                    {canAddMaterial && (
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={(e) => {
                                                handleEditStudy(selectedStudy, e);
                                                setSelectedStudy(null);
                                            }}
                                            className="rounded-xl gap-2 shrink-0 border-primary/20 text-primary hover:bg-primary/5 hover:text-primary h-9"
                                        >
                                            <PencilIcon className="h-3.5 w-3.5" />
                                            <span>Editar</span>
                                        </Button>
                                    )}
                                </div>
                            </DialogHeader>

                            <div className="space-y-6 pt-2">
                                {/* Study Progress Bar */}
                                <div className="space-y-1.5 bg-muted/30 border border-border/50 p-4 rounded-2xl">
                                    <div className="flex justify-between items-center text-xs font-semibold">
                                        <span className="text-primary">{completed} de {total} etapas concluídas</span>
                                        <span className="text-foreground">{percent}%</span>
                                    </div>
                                    <Progress value={percent} className="h-3" />
                                </div>

                                {/* Steps List (Ordered) */}
                                <div className="space-y-3">
                                    <h4 className="text-sm font-semibold text-foreground">Etapas do Estudo</h4>
                                    <div className="space-y-2">
                                        {steps.map((step, index) => {
                                            const isStepCompleted = userProgress.some(p => p.step_id === step.id);
                                            // Ordered condition: unlocked if first step OR previous step is completed
                                            const isUnlocked = index === 0 || userProgress.some(p => p.step_id === steps[index - 1].id);

                                            return (
                                                <div 
                                                    key={step.id} 
                                                    onClick={() => isUnlocked && setActiveStep(step)}
                                                    className={cn(
                                                        "flex items-center justify-between p-3.5 border rounded-2xl transition-all select-none",
                                                        isUnlocked 
                                                            ? "bg-card border-border/60 hover:border-primary/30 hover:bg-primary/5 cursor-pointer group" 
                                                            : "bg-muted/10 border-border/30 opacity-60 cursor-not-allowed"
                                                    )}
                                                >
                                                    <div className="flex items-center gap-3 min-w-0">
                                                        <div className={cn(
                                                            "w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0",
                                                            isStepCompleted 
                                                                ? "bg-green-500 text-white" 
                                                                : isUnlocked 
                                                                    ? "bg-primary/10 text-primary" 
                                                                    : "bg-muted text-muted-foreground"
                                                        )}>
                                                            {isStepCompleted ? (
                                                                <CheckIcon className="h-4 w-4" />
                                                            ) : (
                                                                index + 1
                                                            )}
                                                        </div>
                                                        <div className="min-w-0">
                                                            <div className="flex items-center gap-2">
                                                                <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
                                                                    {step.media_resource.type === 'video' ? 'Vídeo' : step.media_resource.type === 'pdf' ? 'PDF' : 'Leitura'}
                                                                </span>
                                                                {!isUnlocked && (
                                                                    <LockIcon className="h-3 w-3 text-muted-foreground" />
                                                                )}
                                                            </div>
                                                            <h5 className={cn(
                                                                "text-sm font-semibold truncate max-w-[340px] mt-0.5",
                                                                isUnlocked ? "text-foreground group-hover:text-primary transition-colors" : "text-muted-foreground"
                                                            )}>
                                                                {step.media_resource.title}
                                                            </h5>
                                                        </div>
                                                    </div>
                                                    
                                                    {isUnlocked && (
                                                        <Button 
                                                            variant="ghost" 
                                                            size="sm"
                                                            className="h-8 rounded-xl gap-1 hover:bg-primary hover:text-white"
                                                        >
                                                            <span>Acessar</span>
                                                            <ChevronRightIcon className="h-3.5 w-3.5" />
                                                        </Button>
                                                    )}
                                                </div>
                                            );
                                        })}
                                    </div>
                                </div>
                            </div>

                            <DialogFooter className="pt-4 border-t border-border/50">
                                <Button 
                                    onClick={() => setSelectedStudy(null)}
                                    className="rounded-full px-6"
                                >
                                    Fechar
                                </Button>
                            </DialogFooter>
                        </DialogContent>
                    );
                })()}
            </Dialog>

            {/* DIALOG: VISUALIZAR ETAPA (MEDIA VIEWER E CONCLUSÃO) */}
            <Dialog open={!!activeStep} onOpenChange={(open) => !open && setActiveStep(null)}>
                {activeStep && (() => {
                    const resObj = activeStep.media_resource;
                    const isStepCompleted = userProgress.some(p => p.step_id === activeStep.id);
                    const isStudyStep = !!activeStep.id; // False if opened from general media tabs (mocked id)

                    return (
                        <DialogContent className={cn(
                            "bg-card border-border shadow-2xl rounded-3xl overflow-hidden p-0",
                            resObj.type === "video" || resObj.type === "markdown" ? "sm:max-w-5xl w-[95vw]" : "sm:max-w-3xl w-[95vw]"
                        )}>
                            <DialogHeader className="p-6 pb-2 border-b border-border/50 flex flex-row items-start justify-between">
                                <div className="space-y-1">
                                    <div className="flex items-center gap-2">
                                        <span className="text-[10px] font-bold uppercase tracking-wider bg-primary/10 text-primary px-2 py-0.5 rounded-md">
                                            {resObj.type === 'video' ? 'Vídeo' : resObj.type === 'pdf' ? 'Apostila PDF' : 'Leitura'}
                                        </span>
                                    </div>
                                    <DialogTitle className="text-lg font-bold text-foreground pr-8">
                                        {resObj.title}
                                    </DialogTitle>
                                </div>
                            </DialogHeader>

                            <div className="p-6">
                                {/* RESOURCE RENDERING SECTION */}
                                <div className="bg-muted/30 border border-border/50 rounded-2xl overflow-hidden mb-6 flex flex-col justify-center min-h-[300px]">
                                    
                                    {/* Video Rendering */}
                                    {resObj.type === "video" && (() => {
                                        const ytId = getYouTubeId(resObj.url);
                                        if (ytId) {
                                            return (
                                                <div className="aspect-video w-full">
                                                    <iframe 
                                                        width="100%" 
                                                        height="100%" 
                                                        src={`https://www.youtube.com/embed/${ytId}?autoplay=1`} 
                                                        title={resObj.title} 
                                                        frameBorder="0" 
                                                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                                        allowFullScreen
                                                        className="w-full h-full"
                                                    ></iframe>
                                                </div>
                                            );
                                        }
                                        return (
                                            <div className="flex flex-col items-center justify-center p-8 text-center">
                                                <YoutubeIcon className="h-12 w-12 text-destructive mb-3 animate-pulse" />
                                                <h5 className="font-semibold mb-2">Vídeo Externo</h5>
                                                <p className="text-xs text-muted-foreground max-w-sm mb-4">Este vídeo não possui formato do YouTube compatível com player interno.</p>
                                                <a href={resObj.url} target="_blank" rel="noopener noreferrer">
                                                    <Button className="rounded-full gap-2">
                                                        <PlayIcon className="h-4 w-4" />
                                                        Abrir no YouTube
                                                    </Button>
                                                </a>
                                            </div>
                                        );
                                    })()}

                                    {/* PDF Rendering */}
                                    {resObj.type === "pdf" && (
                                        <div className="flex flex-col items-center justify-center p-8 text-center min-h-[350px]">
                                            <FileTextIcon className="h-16 w-16 text-red-500 mb-4" />
                                            <h5 className="font-bold text-lg mb-2">Documento PDF Pronto para Leitura</h5>
                                            <p className="text-sm text-muted-foreground max-w-sm mb-6">
                                                Clique no botão abaixo para abrir a apostila ou guia de estudos em uma nova aba do navegador para melhor visualização.
                                            </p>
                                            <div className="flex flex-col sm:flex-row gap-3 w-full justify-center">
                                                <a href={resObj.url} target="_blank" rel="noopener noreferrer" className="w-full sm:w-auto">
                                                    <Button className="rounded-full gap-2 w-full px-6 shadow-md">
                                                        <EyeIcon className="h-4 w-4" />
                                                        Visualizar PDF
                                                    </Button>
                                                </a>
                                                <a href={resObj.url} download className="w-full sm:w-auto">
                                                    <Button variant="outline" className="rounded-full gap-2 w-full px-6 border-border/60">
                                                        <DownloadIcon className="h-4 w-4" />
                                                        Baixar Arquivo
                                                    </Button>
                                                </a>
                                            </div>
                                        </div>
                                    )}

                                    {/* Markdown Rendering */}
                                    {resObj.type === "markdown" && (
                                        <div className="p-6">
                                            <MarkdownViewer url={resObj.url} />
                                        </div>
                                    )}
                                </div>

                                {resObj.description && resObj.type !== "markdown" && (
                                    <div className="bg-muted/10 border border-border/30 p-4 rounded-xl mb-6 text-sm text-muted-foreground">
                                        <p className="font-medium text-foreground mb-1">Sobre esta etapa:</p>
                                        {resObj.description}
                                    </div>
                                )}

                                {/* Completion control for studies */}
                                <div className="flex justify-between items-center pt-2">
                                    <div className="flex items-center gap-2">
                                        <Button 
                                            type="button" 
                                            variant="ghost" 
                                            onClick={() => setActiveStep(null)}
                                            className="rounded-full px-5"
                                        >
                                            Voltar
                                        </Button>
                                        {canAddMaterial && resObj.type === "markdown" && (
                                            <Button
                                                onClick={() => {
                                                    setActiveStep(null);
                                                    setEditingTextResource(resObj);
                                                    setIsTextEditorOpen(true);
                                                }}
                                                variant="outline"
                                                className="rounded-full px-4 gap-2 text-amber-600 border-amber-600/20 hover:bg-amber-500/10 h-9 text-xs"
                                            >
                                                <PencilIcon className="h-3.5 w-3.5" />
                                                Editar Texto
                                            </Button>
                                        )}
                                    </div>

                                    {isStudyStep ? (
                                        <Button
                                            onClick={() => {
                                                handleToggleCompleteStep(activeStep);
                                                setActiveStep(null); // Close viewer after completion toggled
                                            }}
                                            className={cn(
                                                "rounded-full px-6 gap-2 font-semibold shadow-md",
                                                isStepCompleted 
                                                    ? "bg-green-500 hover:bg-green-600 text-white shadow-green-500/10" 
                                                    : "bg-primary hover:bg-primary/90 text-primary-foreground"
                                            )}
                                        >
                                            {isStepCompleted ? (
                                                <>
                                                    <CheckIcon className="h-4 w-4" />
                                                    Etapa Concluída
                                                </>
                                            ) : (
                                                <>
                                                    <CheckCircle2Icon className="h-4 w-4" />
                                                    Concluir Etapa
                                                </>
                                            )}
                                        </Button>
                                    ) : (
                                        <span className="text-xs text-muted-foreground italic">Recurso individual</span>
                                    )}
                                </div>
                            </div>
                        </DialogContent>
                    );
                })()}
            </Dialog>

            {/* TEXT EDITOR MODAL */}
            <TextEditor
                isOpen={isTextEditorOpen}
                onClose={() => {
                    setIsTextEditorOpen(false);
                    setEditingTextResource(null);
                }}
                onSave={handleSaveText}
                initialData={editingTextResource ? {
                    id: editingTextResource.id,
                    title: editingTextResource.title,
                    description: editingTextResource.description || "",
                    url: editingTextResource.url
                } : null}
            />
        </div>
    );
}

// Markdown Viewer Component (Custom parsing with tailwind styles)
function MarkdownViewer({ url }: { url: string }) {
    const [content, setContent] = useState("");
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchMD() {
            try {
                setLoading(true);
                const res = await fetch(url);
                const text = await res.text();
                setContent(text);
            } catch (err) {
                console.error("Error loading markdown:", err);
                setContent("Não foi possível carregar o conteúdo deste texto.");
            } finally {
                setLoading(false);
            }
        }
        fetchMD();
    }, [url]);

    if (loading) {
        return (
            <div className="flex justify-center items-center py-20">
                <Loader2Icon className="h-6 w-6 animate-spin text-primary" />
            </div>
        );
    }

    let frontmatter: string[] = [];
    let markdownBody = content;

    const normalizedContent = content.replace(/\r\n/g, "\n");
    if (normalizedContent.startsWith("---")) {
        const secondDashIndex = normalizedContent.indexOf("\n---", 3);
        if (secondDashIndex !== -1) {
            const fmPart = normalizedContent.slice(0, secondDashIndex + 4);
            frontmatter = fmPart.split("\n")
                .filter((_, idx, arr) => idx > 0 && idx < arr.length - 1)
                .map(line => line.trimEnd());
            markdownBody = normalizedContent.slice(secondDashIndex + 4);
        }
    }

    const lines = markdownBody.split('\n');
    let insideCode = false;

    // Preprocess lines to group consecutive blockquote lines
    const processedLines: Array<{ type: 'blockquote', lines: string[] } | { type: 'normal', text: string }> = [];
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();
        
        if (trimmed.startsWith('>')) {
            const last = processedLines[processedLines.length - 1];
            if (last && last.type === 'blockquote') {
                last.lines.push(line);
            } else {
                processedLines.push({ type: 'blockquote', lines: [line] });
            }
        } else {
            processedLines.push({ type: 'normal', text: line });
        }
    }

    return (
        <div className="space-y-4 text-foreground dark:text-zinc-300 leading-relaxed font-sans max-h-[65vh] overflow-y-auto pr-3 scrollbar-thin">
            {frontmatter.length > 0 && (
                <div className="bg-muted/40 border border-border/80 rounded-2xl p-4 mb-4 text-xs font-mono space-y-1.5 opacity-90">
                    <div className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider border-b border-border/40 pb-1 mb-2 select-none">
                        Propriedades / Metadados
                    </div>
                    {frontmatter.map((line, fIdx) => (
                        <div key={fIdx} className="text-muted-foreground/90 dark:text-zinc-400">
                            {line}
                        </div>
                    ))}
                </div>
            )}
            {processedLines.map((item, idx) => {
                if (item.type === 'blockquote') {
                    let isBibleQuote = false;
                    const renderedLines: string[] = [];
                    
                    for (const l of item.lines) {
                        const t = l.trim();
                        const contentText = t.startsWith("> ") ? t.slice(2) : (t === ">" ? "" : t.slice(1));
                        const contentTrimmed = contentText.trim();
                        const lowerContent = contentTrimmed.toLowerCase();
                        const isBibleMarker = lowerContent.startsWith("!bible") || lowerContent.startsWith("!bíblia");
                        
                        if (isBibleMarker) {
                            isBibleQuote = true;
                            const markerLength = lowerContent.startsWith("!bible") ? 6 : 7;
                            const rest = contentTrimmed.slice(markerLength).trim();
                            if (rest) {
                                renderedLines.push(rest);
                            }
                        } else {
                            renderedLines.push(contentText);
                        }
                    }
                    
                    return (
                        <blockquote key={idx} className="border-l-4 border-primary pl-4 py-3 italic text-muted-foreground bg-muted/20 rounded-r-md my-4">
                            {isBibleQuote && (
                                <div className="flex items-center gap-1.5 text-primary font-semibold text-xs mb-2 not-italic select-none">
                                    <BookOpenIcon className="h-3.5 w-3.5" />
                                    <span>Bíblia</span>
                                </div>
                            )}
                            <div className="space-y-1">
                                {renderedLines.map((contentStr, lineIdx) => (
                                    <div key={lineIdx}>
                                        {parseInlineMarkdown(contentStr)}
                                    </div>
                                ))}
                            </div>
                        </blockquote>
                    );
                }

                const line = item.text;
                const trimmed = line.trim();

                // Code block toggle
                if (trimmed.startsWith('```')) {
                    insideCode = !insideCode;
                    return null;
                }

                if (insideCode) {
                    return (
                        <pre key={idx} className="bg-muted p-4 rounded-xl font-mono text-xs overflow-x-auto border border-border/40">
                            <code>{line}</code>
                        </pre>
                    );
                }

                // Check for HTML aligned tags
                const centerMatch = trimmed.match(/^<p align="center">(.*)<\/p>$/i);
                const justifyMatch = trimmed.match(/^<p align="justify">(.*)<\/p>$/i);
                const headingAlignMatch = trimmed.match(/^<h([1-4]) align="(center|justify)">(.*)<\/h\d>$/i);

                if (centerMatch) {
                    return (
                        <p key={idx} className="text-center text-muted-foreground dark:text-zinc-400 text-sm leading-relaxed">
                            {parseInlineMarkdown(centerMatch[1])}
                        </p>
                    );
                }
                if (justifyMatch) {
                    return (
                        <p key={idx} className="text-justify text-muted-foreground dark:text-zinc-400 text-sm leading-relaxed">
                            {parseInlineMarkdown(justifyMatch[1])}
                        </p>
                    );
                }
                if (headingAlignMatch) {
                    const level = headingAlignMatch[1];
                    const align = headingAlignMatch[2];
                    const content = headingAlignMatch[3];
                    const alignClass = align === "center" ? "text-center" : "text-justify";
                    
                    if (level === "1") return <h1 key={idx} className={`text-xl font-extrabold text-foreground border-b border-border pb-1.5 mt-6 mb-3 ${alignClass}`}>{parseInlineMarkdown(content)}</h1>;
                    if (level === "2") return <h2 key={idx} className={`text-lg font-bold text-foreground mt-5 mb-2 ${alignClass}`}>{parseInlineMarkdown(content)}</h2>;
                    if (level === "3") return <h3 key={idx} className={`text-base font-semibold text-foreground mt-4 mb-1 ${alignClass}`}>{parseInlineMarkdown(content)}</h3>;
                    if (level === "4") return <h4 key={idx} className={`text-sm font-semibold text-muted-foreground mt-3 mb-1 ${alignClass}`}>{parseInlineMarkdown(content)}</h4>;
                }

                // Headings
                if (trimmed.startsWith('# ')) {
                    return <h1 key={idx} className="text-xl font-extrabold text-foreground border-b border-border pb-1.5 mt-6 mb-3">{parseInlineMarkdown(trimmed.slice(2))}</h1>;
                }
                if (trimmed.startsWith('## ')) {
                    return <h2 key={idx} className="text-lg font-bold text-foreground mt-5 mb-2">{parseInlineMarkdown(trimmed.slice(3))}</h2>;
                }
                if (trimmed.startsWith('### ')) {
                    return <h3 key={idx} className="text-base font-semibold text-foreground mt-4 mb-1">{parseInlineMarkdown(trimmed.slice(4))}</h3>;
                }
                if (trimmed.startsWith('#### ')) {
                    return <h4 key={idx} className="text-sm font-semibold text-muted-foreground mt-3 mb-1">{parseInlineMarkdown(trimmed.slice(5))}</h4>;
                }

                // Horizontal Rule
                if (trimmed === '---' || trimmed === '***') {
                    return <hr key={idx} className="my-6 border-border" />;
                }

                // List Items
                if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
                    return (
                        <li key={idx} className="list-disc ml-6 mt-1 text-muted-foreground text-sm">
                            {parseInlineMarkdown(trimmed.slice(2))}
                        </li>
                    );
                }

                // Numbered lists
                if (/^\d+\.\s/.test(trimmed)) {
                    const dotIndex = trimmed.indexOf('.');
                    return (
                        <li key={idx} className="list-decimal ml-6 mt-1 text-muted-foreground text-sm">
                            {parseInlineMarkdown(trimmed.slice(dotIndex + 1).trim())}
                        </li>
                    );
                }

                // Empty line
                if (trimmed === '') {
                    return <div key={idx} className="h-1.5" />;
                }

                // Standard paragraph
                return (
                    <p key={idx} className="text-muted-foreground dark:text-zinc-400 text-sm leading-relaxed">
                        {parseInlineMarkdown(line)}
                    </p>
                );
            })}
        </div>
    );
}

function parseInlineMarkdown(text: string): React.ReactNode[] {
    const tokenRegex = /(\*\*.*?\*\*|`.*?`|\[.*?\]\(.*?\))/g;
    const splitParts = text.split(tokenRegex);

    return splitParts.map((part, index) => {
        if (part.startsWith('**') && part.endsWith('**')) {
            return <strong key={index} className="font-bold text-foreground">{part.slice(2, -2)}</strong>;
        }
        if (part.startsWith('`') && part.endsWith('`')) {
            return <code key={index} className="px-1.5 py-0.5 rounded bg-muted font-mono text-xs border border-border">{part.slice(1, -1)}</code>;
        }
        if (part.startsWith('[') && part.includes('](')) {
            const closeBracket = part.indexOf(']');
            const label = part.slice(1, closeBracket);
            const url = part.slice(closeBracket + 2, -1);
            return (
                <a key={index} href={url} target="_blank" rel="noopener noreferrer" className="text-primary hover:underline font-medium">
                    {label}
                </a>
            );
        }
        return part;
    });
}
