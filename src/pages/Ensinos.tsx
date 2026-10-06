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
    PencilIcon,
    StickyNoteIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import supabase from "@/lib/supabase";
import { TextEditor } from "@/components/TextEditor";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import { Spinner } from "@/components/ui/spinner";
import { Badge } from "@/components/ui/badge";
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
    CardFooter,
} from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { fetchLatestVideos, type YouTubeVideo } from "@/lib/youtube";
import type { Database } from "@/lib/database.types";

type TabType = "estudos" | "videos" | "pdfs" | "textos" | "anotacoes";

type MediaResource = Database["public"]["Tables"]["media_resources"]["Row"];
type Study = Database["public"]["Tables"]["studies"]["Row"];
type StudyStep = Database["public"]["Tables"]["study_steps"]["Row"] & {
    media_resource: MediaResource;
};
type UserProgress = Database["public"]["Tables"]["user_study_progress"]["Row"];
type StudyNote = Database["public"]["Tables"]["study_notes"]["Row"];

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

// Extract YouTube ID helper
const getYouTubeId = (url: string) => {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);
    return (match && match[2].length === 11) ? match[2] : null;
};

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
    const [notes, setNotes] = useState<StudyNote[]>([]);
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

    // Note Modal control states
    const [noteTarget, setNoteTarget] = useState<{
        type: "study" | "resource";
        id: string;
        title: string;
        studyId?: string;
        note?: StudyNote | null;
    } | null>(null);
    const [isNoteEditorOpen, setIsNoteEditorOpen] = useState(false);
    const [isSideBySideNotesOpen, setIsSideBySideNotesOpen] = useState(false);
    const [notesFilter, setNotesFilter] = useState<"todos" | "estudos" | "videos" | "pdfs" | "textos">("todos");

    // File upload state
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [uploadingFile, setUploadingFile] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const isSyncingRef = useRef(false);

    // Selected resources for study creation
    const [selectedResourcesForStudy, setSelectedResourcesForStudy] = useState<MediaResource[]>([]);
    const [selectedResourceVal, setSelectedResourceVal] = useState<string>("");
    const [studyResourceSearch, setStudyResourceSearch] = useState("");
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
                        
                        // Pre-fetch YouTube channel videos
                        setLoadingYoutube(true);
                        const fetched = await fetchLatestVideos();
                        setYoutubeVideos(fetched);
                        setLoadingYoutube(false);
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
            setStudySteps((stepsData as unknown as StudyStep[]) || []);

            // 4. Fetch User Progress
            const { data: progData } = await supabase
                .from("user_study_progress")
                .select("*")
                .eq("profile_id", profileId);
            setUserProgress(progData || []);

            // 5. Fetch User Study Notes
            const { data: notesData } = await supabase
                .from("study_notes")
                .select("*")
                .eq("profile_id", profileId)
                .order("updated_at", { ascending: false });
            setNotes(notesData || []);

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

    // Automatically sync new YouTube videos to database when an admin visits the page
    useEffect(() => {
        async function autoSyncYoutubeVideos() {
            if (!profile || !canAddMaterial || youtubeVideos.length === 0 || isSyncingRef.current) return;
            
            const dbIds = new Set(
                resources
                    .filter(r => r.type === "video")
                    .map(v => getYouTubeId(v.url))
                    .filter((id): id is string => id !== null)
            );
            const toSync = youtubeVideos.filter(yt => !dbIds.has(yt.id));
            if (toSync.length === 0) return;

            isSyncingRef.current = true;
            try {
                const videosToInsert = toSync.map(video => ({
                    title: video.title,
                    description: video.description || null,
                    type: "video" as const,
                    url: `https://www.youtube.com/watch?v=${video.id}`,
                    category: "videos"
                }));
                
                const { error } = await supabase
                    .from("media_resources")
                    .insert(videosToInsert);
                
                if (error) throw error;
                
                await loadDatabaseData(profile.id);
                toast.success(`${videosToInsert.length} novos vídeos do YouTube sincronizados automaticamente!`);
            } catch (err) {
                console.error("Error auto-syncing youtube videos:", err);
            } finally {
                isSyncingRef.current = false;
            }
        }
        autoSyncYoutubeVideos();
    }, [youtubeVideos, resources, profile, canAddMaterial]);

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

    // Extract unique YouTube channel videos that are not yet in our database
    const dbVideoIds = new Set(
        resources
            .filter(r => r.type === "video")
            .map(v => getYouTubeId(v.url))
            .filter((id): id is string => id !== null)
    );
    const uniqueYoutubeVideos = youtubeVideos.filter(yt => !dbVideoIds.has(yt.id));

    // Filter unique YouTube channel videos by search query
    const filteredUniqueYoutubeVideos = uniqueYoutubeVideos.filter(video => {
        return video.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (video.description && video.description.toLowerCase().includes(searchQuery.toLowerCase()));
    });

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

        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error creating resource:", error);
            toast.error(error.message || "Erro ao salvar recurso.");
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

        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error saving study:", error);
            toast.error(error.message || "Erro ao salvar estudo.");
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
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error deleting study:", error);
            toast.error(error.message || "Erro ao deletar estudo.");
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
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error deleting resource:", error);
            toast.error(error.message || "Erro ao deletar recurso.");
        } finally {
            setLoadingData(false);
        }
    };

    // Import YouTube video into the collection
    const handleImportYoutubeVideo = async (video: YouTubeVideo, e?: React.MouseEvent) => {
        if (e) e.stopPropagation();
        if (!profile) return;

        try {
            setLoadingData(true);
            const { error } = await supabase
                .from("media_resources")
                .insert({
                    title: video.title,
                    description: video.description || null,
                    type: "video",
                    url: `https://www.youtube.com/watch?v=${video.id}`,
                    category: "videos"
                });

            if (error) throw error;

            toast.success("Vídeo adicionado ao acervo com sucesso!");
            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error importing youtube video:", error);
            toast.error(error.message || "Erro ao adicionar vídeo ao acervo.");
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

        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error toggling step progress:", error);
            toast.error(error.message || "Erro ao atualizar progresso.");
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

    // Calculate overall courses progress (completed studies vs total studies)
    const getOverallCoursesProgress = () => {
        if (studies.length === 0) return { total: 0, completed: 0, percent: 0 };
        
        let completed = 0;
        let total = 0;

        studies.forEach(study => {
            const { total: studyStepsCount, completed: studyCompletedSteps } = getStudyProgressData(study.id);
            // Count studies that have at least one step
            if (studyStepsCount > 0) {
                total++;
                if (studyCompletedSteps === studyStepsCount) {
                    completed++;
                }
            }
        });

        const percent = total > 0 ? Math.round((completed / total) * 100) : 0;
        return { total, completed, percent };
    };

    // Helper to get study note
    const getStudyNote = (studyId: string) => {
        return notes.find(n => n.study_id === studyId && !n.media_resource_id);
    };

    // Helper to get resource note
    const getResourceNote = (resourceId: string) => {
        return notes.find(n => n.media_resource_id === resourceId);
    };

    // Open note editor for a study
    const handleOpenStudyNote = (study: Study, e?: React.MouseEvent) => {
        if (e) e.stopPropagation();
        const existingNote = getStudyNote(study.id);
        setNoteTarget({
            type: "study",
            id: study.id,
            title: study.title,
            note: existingNote || null,
        });
        setIsNoteEditorOpen(true);
    };

    // Open note editor for a media resource (opens side-by-side viewer)
    const handleOpenResourceNote = (resource: MediaResource, studyId?: string, e?: React.MouseEvent) => {
        if (e) e.stopPropagation();
        const existingNote = getResourceNote(resource.id);
        setNoteTarget({
            type: "resource",
            id: resource.id,
            title: resource.title,
            studyId,
            note: existingNote || null,
        });
        setActiveStep({
            id: "",
            study_id: studyId || "",
            media_resource_id: resource.id,
            sort_order: 0,
            created_at: "",
            media_resource: resource,
        });
        setIsSideBySideNotesOpen(true);
    };

    // Save note handler
    const handleSaveNote = async (data: { title: string; description: string; markdownContent: string }) => {
        if (!profile || !noteTarget) return;

        try {
            const existingNote = noteTarget.note;
            if (existingNote) {
                const { data: updated, error } = await supabase
                    .from("study_notes")
                    .update({
                        title: data.title,
                        content: data.markdownContent,
                        updated_at: new Date().toISOString()
                    })
                    .eq("id", existingNote.id)
                    .select()
                    .single();

                if (error) throw error;
                if (updated) {
                    setNoteTarget(prev => prev ? { ...prev, note: updated } : null);
                }
            } else {
                const isUuidStr = (v?: string) => !!v && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
                const mediaResId = (noteTarget.type === "resource" && isUuidStr(noteTarget.id)) ? noteTarget.id : null;
                const { data: inserted, error } = await supabase
                    .from("study_notes")
                    .insert({
                        profile_id: profile.id,
                        study_id: noteTarget.type === "study" ? noteTarget.id : (noteTarget.studyId || null),
                        media_resource_id: mediaResId,
                        title: data.title || `Anotações: ${noteTarget.title}`,
                        content: data.markdownContent,
                        updated_at: new Date().toISOString()
                    })
                    .select()
                    .single();

                if (error) throw error;
                if (inserted) {
                    setNoteTarget(prev => prev ? { ...prev, note: inserted } : null);
                }
            }

            toast.success("Anotação salva com sucesso!");
            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error saving note:", error);
            toast.error(error.message || "Erro ao salvar anotação.");
            throw error;
        }
    };

    // Delete note handler
    const handleDeleteNote = async (noteId?: string) => {
        const idToDelete = noteId || noteTarget?.note?.id;
        if (!profile || !idToDelete) return;

        try {
            const { error } = await supabase
                .from("study_notes")
                .delete()
                .eq("id", idToDelete);

            if (error) throw error;

            toast.success("Anotação excluída com sucesso.");
            setIsNoteEditorOpen(false);
            setNoteTarget(prev => prev ? { ...prev, note: null } : null);
            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error deleting note:", error);
            toast.error(error.message || "Erro ao excluir anotação.");
            throw error;
        }
    };

    // Enriched notes for notes tab
    const enrichedNotes = notes.map(note => {
        const study = note.study_id ? studies.find(s => s.id === note.study_id) : null;
        const resource = note.media_resource_id ? resources.find(r => r.id === note.media_resource_id) : null;
        let typeLabel: "Estudo" | "Vídeo" | "PDF" | "Texto" = "Estudo";
        if (resource) {
            typeLabel = resource.type === "video" ? "Vídeo" : resource.type === "pdf" ? "PDF" : "Texto";
        }
        const targetTitle = study ? study.title : resource ? resource.title : note.title;
        return {
            ...note,
            study,
            resource,
            typeLabel,
            targetTitle,
        };
    });

    const filteredNotes = enrichedNotes.filter(item => {
        const query = searchQuery.toLowerCase();
        const matchesSearch = 
            item.title.toLowerCase().includes(query) ||
            item.content.toLowerCase().includes(query) ||
            item.targetTitle.toLowerCase().includes(query);
        
        if (!matchesSearch) return false;

        if (notesFilter === "todos") return true;
        if (notesFilter === "estudos") return !item.media_resource_id;
        if (notesFilter === "videos") return item.resource?.type === "video";
        if (notesFilter === "pdfs") return item.resource?.type === "pdf";
        if (notesFilter === "textos") return item.resource?.type === "markdown";
        return true;
    });

    // Helper to open note editor from enriched note card
    const handleEditEnrichedNote = (item: typeof enrichedNotes[0]) => {
        if (item.resource) {
            setNoteTarget({
                type: "resource",
                id: item.resource.id,
                title: item.resource.title,
                studyId: item.study_id || undefined,
                note: item,
            });
            setActiveStep({
                id: "",
                study_id: item.study_id || "",
                media_resource_id: item.resource.id,
                sort_order: 0,
                created_at: "",
                media_resource: item.resource,
            });
            setIsSideBySideNotesOpen(true);
        } else {
            setNoteTarget({
                type: "study",
                id: item.study_id || "",
                title: item.targetTitle,
                studyId: item.study_id || undefined,
                note: item,
            });
            setIsNoteEditorOpen(true);
        }
    };

    // Helper to open study or resource viewer from enriched note card
    const handleOpenReferencedItem = (item: typeof enrichedNotes[0]) => {
        if (item.resource) {
            setNoteTarget({
                type: "resource",
                id: item.resource.id,
                title: item.resource.title,
                studyId: item.study_id || undefined,
                note: item,
            });
            setActiveStep({
                id: "",
                study_id: item.study_id || "",
                media_resource_id: item.resource.id,
                sort_order: 0,
                created_at: "",
                media_resource: item.resource,
            });
            setIsSideBySideNotesOpen(true);
        } else if (item.study) {
            setSelectedStudy(item.study);
        }
    };

    const tabs = [
        { id: "estudos", label: "Estudos", icon: GraduationCapIcon },
        { id: "videos", label: "Vídeos", icon: YoutubeIcon },
        { id: "pdfs", label: "PDFs", icon: FileTextIcon },
        { id: "textos", label: "Textos/MD", icon: BookOpenIcon },
        { id: "anotacoes", label: "Minhas Anotações", icon: StickyNoteIcon },
    ];

    if (loading) {
        return (
            <div className="flex h-[60vh] items-center justify-center">
                <Spinner className="h-8 w-8 text-primary" />
            </div>
        );
    }

    const { total: totalCourses, completed: completedCourses, percent: overallCoursesPercent } = getOverallCoursesProgress();

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

            {/* Overall progress indicator (Only when studies exist and have steps) */}
            {studies.length > 0 && totalCourses > 0 && (
                <Card className="border-border/50 bg-card/30 backdrop-blur-sm overflow-hidden rounded-2xl">
                    <CardContent className="p-6">
                        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div className="space-y-1">
                                <h3 className="font-semibold text-lg text-foreground">Progresso Geral em Estudos</h3>
                                <p className="text-xs text-muted-foreground">Estatísticas de conclusão dos estudos disponíveis.</p>
                            </div>
                            <div className="flex items-center gap-4 w-full md:max-w-md">
                                <div className="flex-1 space-y-1">
                                    <div className="flex justify-between text-xs font-semibold">
                                        <span className="text-primary">{completedCourses} de {totalCourses} {totalCourses === 1 ? 'estudo' : 'estudos'} concluídos</span>
                                        <span className="text-foreground">{overallCoursesPercent}%</span>
                                    </div>
                                    <Progress value={overallCoursesPercent} className="h-3 bg-muted/60" />
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
                            placeholder={`Buscar ${activeTab === 'estudos' ? 'estudos' : activeTab === 'anotacoes' ? 'anotações' : 'recursos'}...`}
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
                            <Spinner className="h-10 w-10 text-primary" />
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
                                                const studyNote = getStudyNote(study.id);
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
                                                                <div className="flex items-center gap-1">
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="icon"
                                                                        onClick={(e) => handleOpenStudyNote(study, e)}
                                                                        className={cn(
                                                                            "h-8 w-8 rounded-full cursor-pointer",
                                                                            studyNote 
                                                                                ? "text-primary bg-primary/10 hover:bg-primary/20" 
                                                                                : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                                                                        )}
                                                                        title={studyNote ? "Editar Anotações do Estudo" : "Anotar neste Estudo"}
                                                                    >
                                                                        <StickyNoteIcon className="h-4 w-4" />
                                                                    </Button>
                                                                    {canAddMaterial && (
                                                                        <>
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
                                                                        </>
                                                                    )}
                                                                </div>
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
                                                                    <div className="flex items-center gap-2">
                                                                        {studyNote && (
                                                                            <span className="text-[10px] font-semibold text-primary flex items-center gap-0.5">
                                                                                <StickyNoteIcon className="h-3 w-3" /> Anotado
                                                                            </span>
                                                                        )}
                                                                        <span className="font-semibold text-foreground">{percent}%</span>
                                                                    </div>
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
                            {activeTab === "videos" && (
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
                                                                        <div className="flex items-center gap-1 shrink-0 -mt-1 -mr-2">
                                                                            <Button
                                                                                variant="ghost"
                                                                                size="icon"
                                                                                onClick={(e) => handleOpenResourceNote(video, undefined, e)}
                                                                                className={cn(
                                                                                    "h-8 w-8 rounded-full cursor-pointer",
                                                                                    getResourceNote(video.id)
                                                                                        ? "text-primary bg-primary/10 hover:bg-primary/20"
                                                                                        : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                                                                                )}
                                                                                title={getResourceNote(video.id) ? "Ver Anotações deste Vídeo" : "Anotar neste Vídeo"}
                                                                            >
                                                                                <StickyNoteIcon className="h-4 w-4" />
                                                                            </Button>
                                                                            {canAddMaterial && (
                                                                                <Button
                                                                                    variant="ghost"
                                                                                    size="icon"
                                                                                    onClick={(e) => handleDeleteResource(video.id, e)}
                                                                                    className="h-8 w-8 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full"
                                                                                    title="Excluir Recurso"
                                                                                >
                                                                                    <Trash2Icon className="h-4 w-4" />
                                                                                </Button>
                                                                            )}
                                                                        </div>
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
                                                <Spinner className="h-10 w-10 text-primary" />
                                            </div>
                                        ) : filteredUniqueYoutubeVideos.length > 0 ? (
                                            <div className="space-y-4">
                                                {tabVideos.length > 0 && <Separator className="my-6" />}
                                                <h3 className="text-lg font-bold text-foreground flex items-center gap-2 text-muted-foreground">
                                                    <YoutubeIcon className="h-5 w-5 text-destructive" />
                                                    Vídeos Recentes do Canal
                                                </h3>
                                                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                                    {filteredUniqueYoutubeVideos.map((video) => (
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
                                                                <div className="flex justify-between items-start gap-4">
                                                                    <CardTitle className="text-base text-foreground line-clamp-2 leading-tight group-hover:text-primary transition-colors" title={video.title}>
                                                                        {video.title}
                                                                    </CardTitle>
                                                                    {canAddMaterial && (
                                                                        <Button
                                                                            variant="outline"
                                                                            size="sm"
                                                                            onClick={(e) => handleImportYoutubeVideo(video, e)}
                                                                            className="rounded-full gap-1 border-primary/20 text-primary hover:bg-primary/5 shrink-0 -mt-1 -mr-2 text-[10px] px-2.5 py-1 h-7"
                                                                            title="Adicionar ao Acervo"
                                                                        >
                                                                            <PlusIcon className="h-3 w-3" />
                                                                            Salvar
                                                                        </Button>
                                                                    )}
                                                                </div>
                                                                <CardDescription className="text-xs pt-1">
                                                                    {new Date(video.publishedAt).toLocaleDateString('pt-BR')}
                                                                </CardDescription>
                                                            </CardHeader>
                                                        </Card>
                                                    ))}
                                                </div>
                                            </div>
                                        ) : null}

                                        {tabVideos.length === 0 && filteredUniqueYoutubeVideos.length === 0 && !loadingYoutube && (
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
                                )}

                            {/* TAB: PDFs */}
                            {activeTab === "pdfs" && (
                                <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                    {tabPDFs.length > 0 ? (
                                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 lg:grid-cols-4 gap-6">
                                            {tabPDFs.map((pdf) => {
                                                const pdfNote = getResourceNote(pdf.id);
                                                return (
                                                    <Card key={pdf.id} className="flex flex-col border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl group rounded-2xl overflow-hidden relative">
                                                        <CardHeader className="flex-1 p-6">
                                                            <div className="flex justify-between items-start gap-4">
                                                                <div className="w-12 h-12 rounded-2xl bg-red-500/10 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform duration-300">
                                                                    <FileTextIcon className="h-6 w-6 text-red-500" />
                                                                </div>
                                                                <div className="flex items-center gap-1 shrink-0 -mt-1 -mr-2">
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="icon"
                                                                        onClick={(e) => handleOpenResourceNote(pdf, undefined, e)}
                                                                        className={cn(
                                                                            "min-h-[44px] min-w-[44px] rounded-full cursor-pointer",
                                                                            pdfNote
                                                                                ? "text-primary bg-primary/10 hover:bg-primary/20"
                                                                                : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                                                                        )}
                                                                        title={pdfNote ? "Ver Anotações deste PDF" : "Anotar neste PDF"}
                                                                    >
                                                                        <StickyNoteIcon className="h-4 w-4" />
                                                                    </Button>
                                                                    {canAddMaterial && (
                                                                        <Button
                                                                            variant="ghost"
                                                                            size="icon"
                                                                            onClick={(e) => handleDeleteResource(pdf.id, e)}
                                                                            className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full"
                                                                            title="Excluir PDF"
                                                                        >
                                                                            <Trash2Icon className="h-4 w-4" />
                                                                        </Button>
                                                                    )}
                                                                </div>
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
                                                        <CardContent className="p-6 pt-0 space-y-2 mt-auto">
                                                            {pdfNote && (
                                                                <div className="text-[10px] font-semibold text-primary flex items-center gap-1 mb-1">
                                                                    <StickyNoteIcon className="h-3 w-3" />
                                                                    <span>Possui anotações pessoais</span>
                                                                </div>
                                                            )}
                                                            <Button 
                                                                variant="outline" 
                                                                className="w-full gap-2 border-border/50 rounded-xl hover:bg-primary hover:text-primary-foreground transition-all min-h-[44px]"
                                                                onClick={() => setActiveStep({ id: "", study_id: "", media_resource_id: pdf.id, sort_order: 0, created_at: "", media_resource: pdf })}
                                                            >
                                                                <EyeIcon className="h-4 w-4" />
                                                                Visualizar
                                                            </Button>
                                                        </CardContent>
                                                    </Card>
                                                );
                                            })}
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
                                            {tabTextos.map((texto) => {
                                                const textoNote = getResourceNote(texto.id);
                                                return (
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
                                                                <div className="flex items-center gap-1 shrink-0 -mt-1 -mr-2">
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="icon"
                                                                        onClick={(e) => handleOpenResourceNote(texto, undefined, e)}
                                                                        className={cn(
                                                                            "min-h-[44px] min-w-[44px] rounded-full cursor-pointer",
                                                                            textoNote
                                                                                ? "text-primary bg-primary/10 hover:bg-primary/20"
                                                                                : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                                                                        )}
                                                                        title={textoNote ? "Ver Anotações deste Texto" : "Anotar neste Texto"}
                                                                    >
                                                                        <StickyNoteIcon className="h-4 w-4" />
                                                                    </Button>
                                                                    {canAddMaterial && (
                                                                        <>
                                                                            <Button
                                                                                variant="ghost"
                                                                                size="icon"
                                                                                onClick={(e) => {
                                                                                    e.stopPropagation();
                                                                                    setEditingTextResource(texto);
                                                                                    setIsTextEditorOpen(true);
                                                                                }}
                                                                                className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-amber-600 hover:bg-amber-500/10 rounded-full cursor-pointer"
                                                                                title="Editar Texto"
                                                                            >
                                                                                <PencilIcon className="h-4 w-4" />
                                                                            </Button>
                                                                            <Button
                                                                                variant="ghost"
                                                                                size="icon"
                                                                                onClick={(e) => handleDeleteResource(texto.id, e)}
                                                                                className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full cursor-pointer"
                                                                                title="Excluir Texto"
                                                                            >
                                                                                <Trash2Icon className="h-4 w-4" />
                                                                            </Button>
                                                                        </>
                                                                    )}
                                                                </div>
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
                                                            <div className="flex items-center justify-between text-xs text-muted-foreground pt-2 border-t border-border/40">
                                                                <div className="flex items-center gap-1.5">
                                                                    {textoNote && (
                                                                        <span className="text-[10px] font-semibold text-primary flex items-center gap-0.5">
                                                                            <StickyNoteIcon className="h-3 w-3" /> Anotado
                                                                        </span>
                                                                    )}
                                                                </div>
                                                                <div className="text-xs font-semibold text-primary group-hover:underline flex items-center gap-1">
                                                                    Ler Texto <ChevronRightIcon className="h-3 w-3" />
                                                                </div>
                                                            </div>
                                                        </CardContent>
                                                    </Card>
                                                );
                                            })}
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

                            {/* TAB: MINHAS ANOTAÇÕES */}
                            {activeTab === "anotacoes" && (
                                <div className="animate-in fade-in slide-in-from-bottom-4 duration-500 space-y-6">
                                    {/* Sub-filters for Notes */}
                                    <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
                                        {(
                                            [
                                                { id: "todos", label: "Todas", count: notes.length },
                                                { 
                                                    id: "estudos", 
                                                    label: "Estudos", 
                                                    count: notes.filter(n => n.study_id && !n.media_resource_id).length 
                                                },
                                                { 
                                                    id: "videos", 
                                                    label: "Vídeos", 
                                                    count: notes.filter(n => {
                                                        const r = resources.find(res => res.id === n.media_resource_id);
                                                        return r?.type === "video";
                                                    }).length 
                                                },
                                                { 
                                                    id: "pdfs", 
                                                    label: "PDFs", 
                                                    count: notes.filter(n => {
                                                        const r = resources.find(res => res.id === n.media_resource_id);
                                                        return r?.type === "pdf";
                                                    }).length 
                                                },
                                                { 
                                                    id: "textos", 
                                                    label: "Textos", 
                                                    count: notes.filter(n => {
                                                        const r = resources.find(res => res.id === n.media_resource_id);
                                                        return r?.type === "markdown";
                                                    }).length 
                                                },
                                            ] as const
                                        ).map((filter) => (
                                            <button
                                                key={filter.id}
                                                onClick={() => setNotesFilter(filter.id)}
                                                className={cn(
                                                    "flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-semibold transition-all whitespace-nowrap min-h-[44px] cursor-pointer",
                                                    notesFilter === filter.id
                                                        ? "bg-primary text-primary-foreground shadow-sm"
                                                        : "bg-muted/40 text-muted-foreground hover:bg-muted/80 hover:text-foreground"
                                                )}
                                            >
                                                <span>{filter.label}</span>
                                                <span className={cn(
                                                    "px-1.5 py-0.5 rounded-full text-[10px]",
                                                    notesFilter === filter.id
                                                        ? "bg-primary-foreground/20 text-primary-foreground"
                                                        : "bg-muted text-muted-foreground"
                                                )}>
                                                    {filter.count}
                                                </span>
                                            </button>
                                        ))}
                                    </div>

                                    {filteredNotes.length > 0 ? (
                                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                            {filteredNotes.map((item) => {
                                                const dateVal = item.updated_at || item.created_at || Date.now();
                                                const updatedAt = new Date(dateVal).toLocaleDateString("pt-BR", {
                                                    day: "2-digit",
                                                    month: "short",
                                                    year: "numeric"
                                                });

                                                // Clean preview excerpt removing Markdown tokens
                                                const cleanPreview = item.content
                                                    .replace(/#+\s/g, "")
                                                    .replace(/[*_`>~-]/g, "")
                                                    .slice(0, 160)
                                                    .trim();

                                                return (
                                                    <Card 
                                                        key={item.id} 
                                                        className="border-border/50 bg-card/30 backdrop-blur-sm hover:border-primary/30 transition-all hover:shadow-xl rounded-2xl flex flex-col justify-between overflow-hidden"
                                                    >
                                                        <CardHeader className="p-6 pb-3">
                                                            <div className="flex justify-between items-start gap-3 mb-2">
                                                                <Badge 
                                                                    variant="outline" 
                                                                    className={cn(
                                                                        "gap-1 font-semibold text-xs py-1 px-2.5 rounded-full",
                                                                        item.typeLabel === "Estudo" && "border-primary/30 text-primary bg-primary/5",
                                                                        item.typeLabel === "Vídeo" && "border-destructive/30 text-destructive bg-destructive/5",
                                                                        item.typeLabel === "PDF" && "border-red-500/30 text-red-500 bg-red-500/5",
                                                                        item.typeLabel === "Texto" && "border-amber-500/30 text-amber-600 dark:text-amber-500 bg-amber-500/5"
                                                                    )}
                                                                >
                                                                    {item.typeLabel === "Estudo" && <GraduationCapIcon className="h-3.5 w-3.5" />}
                                                                    {item.typeLabel === "Vídeo" && <YoutubeIcon className="h-3.5 w-3.5" />}
                                                                    {item.typeLabel === "PDF" && <FileTextIcon className="h-3.5 w-3.5" />}
                                                                    {item.typeLabel === "Texto" && <BookOpenIcon className="h-3.5 w-3.5" />}
                                                                    <span>{item.typeLabel}</span>
                                                                </Badge>

                                                                <div className="flex items-center gap-1 shrink-0 -mt-1 -mr-2">
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="icon"
                                                                        onClick={() => handleEditEnrichedNote(item)}
                                                                        className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-full cursor-pointer"
                                                                        title="Editar Anotação"
                                                                    >
                                                                        <PencilIcon className="h-4 w-4" />
                                                                    </Button>
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="icon"
                                                                        onClick={() => handleDeleteNote(item.id)}
                                                                        className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full cursor-pointer"
                                                                        title="Excluir Anotação"
                                                                    >
                                                                        <Trash2Icon className="h-4 w-4" />
                                                                    </Button>
                                                                </div>
                                                            </div>

                                                            <CardTitle className="text-base text-foreground font-semibold leading-snug">
                                                                {item.title}
                                                            </CardTitle>

                                                            <div className="text-xs text-muted-foreground pt-1 flex items-center gap-1 truncate" title={item.targetTitle}>
                                                                <span className="font-medium text-foreground/80">Referente a:</span>
                                                                <span className="truncate">{item.targetTitle}</span>
                                                            </div>
                                                        </CardHeader>

                                                        <CardContent className="px-6 py-2">
                                                            <div className="p-3 bg-muted/20 border border-border/40 rounded-xl text-xs text-muted-foreground line-clamp-3 font-sans leading-relaxed min-h-[64px]">
                                                                {cleanPreview || <span className="italic text-muted-foreground/60">Anotação vazia</span>}
                                                            </div>
                                                        </CardContent>

                                                        <CardFooter className="p-6 pt-3 border-t border-border/40 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-2">
                                                            <span className="text-[11px] text-muted-foreground">
                                                                Atualizado em {updatedAt}
                                                            </span>
                                                            <div className="flex items-center gap-2">
                                                                {(item.resource || item.study) && (
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="sm"
                                                                        onClick={() => handleOpenReferencedItem(item)}
                                                                        className="min-h-[44px] text-xs gap-1 rounded-xl cursor-pointer hover:bg-primary/5 hover:text-primary"
                                                                    >
                                                                        <EyeIcon className="h-3.5 w-3.5" />
                                                                        <span>Ver Material</span>
                                                                    </Button>
                                                                )}
                                                                <Button
                                                                    variant="outline"
                                                                    size="sm"
                                                                    onClick={() => handleEditEnrichedNote(item)}
                                                                    className="min-h-[44px] text-xs gap-1.5 rounded-xl cursor-pointer border-border/60 hover:bg-primary hover:text-primary-foreground transition-all"
                                                                >
                                                                    <StickyNoteIcon className="h-3.5 w-3.5" />
                                                                    <span>Editar</span>
                                                                </Button>
                                                            </div>
                                                        </CardFooter>
                                                    </Card>
                                                );
                                            })}
                                        </div>
                                    ) : (
                                        <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/50 rounded-3xl p-6">
                                            <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
                                                <StickyNoteIcon className="h-8 w-8 text-primary" />
                                            </div>
                                            <h3 className="text-lg font-medium text-foreground">
                                                {searchQuery ? "Nenhuma anotação encontrada" : "Você ainda não possui anotações"}
                                            </h3>
                                            <p className="text-muted-foreground mt-2 max-w-md mx-auto text-sm leading-relaxed">
                                                {searchQuery
                                                    ? "Nenhuma anotação corresponde aos termos buscados ou filtro selecionado."
                                                    : "Suas reflexões e notas pessoais sobre estudos, vídeos, apostilas e leituras aparecerão organizadas aqui. Para começar, clique no ícone de anotação em qualquer material."}
                                            </p>
                                            {searchQuery && (
                                                <Button
                                                    variant="outline"
                                                    onClick={() => {
                                                        setSearchQuery("");
                                                        setNotesFilter("todos");
                                                    }}
                                                    className="mt-4 rounded-full min-h-[44px] px-6"
                                                >
                                                    Limpar busca
                                                </Button>
                                            )}
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
                                            <Spinner className="mr-2" />
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
                                    <Badge variant="outline" className="text-xs text-muted-foreground bg-muted/40 font-medium px-2 py-0.5">
                                        {selectedResourcesForStudy.length} recursos
                                    </Badge>
                                </div>

                                {/* Resource Selector */}
                                <div className="flex items-center">
                                    <Select 
                                        value={selectedResourceVal}
                                        onValueChange={async (val) => {
                                            if (!val) return;
                                            
                                            if (val.startsWith("yt_")) {
                                                const ytId = val.substring(3);
                                                const video = youtubeVideos.find(v => v.id === ytId);
                                                if (video) {
                                                    try {
                                                        setLoadingData(true);
                                                        const { data: newRes, error } = await supabase
                                                            .from("media_resources")
                                                            .insert({
                                                                title: video.title,
                                                                description: video.description || null,
                                                                type: "video",
                                                                url: `https://www.youtube.com/watch?v=${video.id}`,
                                                                category: "videos"
                                                            })
                                                            .select()
                                                            .single();

                                                        if (error) throw error;
                                                        
                                                        if (profile) {
                                                            await loadDatabaseData(profile.id);
                                                        }
                                                        
                                                        setSelectedResourcesForStudy(prev => [...prev, newRes]);
                                                        toast.success("Vídeo do YouTube adicionado à trilha!");
                                                    } catch (err: unknown) {
                                                        const error = err as Error;
                                                        console.error("Error importing video inside study:", error);
                                                        toast.error("Erro ao importar vídeo do YouTube.");
                                                    } finally {
                                                        setLoadingData(false);
                                                    }
                                                }
                                            } else {
                                                const res = resources.find(r => r.id === val);
                                                if (res && !selectedResourcesForStudy.some(item => item.id === res.id)) {
                                                    setSelectedResourcesForStudy([...selectedResourcesForStudy, res]);
                                                }
                                            }
                                            setSelectedResourceVal("");
                                        }}
                                        onOpenChange={(open) => {
                                            if (!open) setStudyResourceSearch("");
                                        }}
                                    >
                                        <SelectTrigger className="rounded-xl border border-dashed border-primary/40 bg-transparent text-primary hover:bg-primary/5 px-4 h-10 w-fit flex items-center gap-2 font-medium cursor-pointer shadow-sm">
                                            <PlusIcon className="h-4 w-4" />
                                            <SelectValue placeholder="Adicionar Recurso à Trilha" />
                                        </SelectTrigger>
                                        <SelectContent position="popper" className="max-h-[300px] overflow-y-auto">
                                            {/* Search filter inside the select dropdown */}
                                            <div 
                                                className="p-1.5 border-b border-border/40 sticky top-0 bg-popover z-10" 
                                                onClick={(e) => e.stopPropagation()}
                                                onKeyDown={(e) => e.stopPropagation()}
                                            >
                                                <Input 
                                                    placeholder="Pesquisar por nome..." 
                                                    value={studyResourceSearch}
                                                    onChange={(e) => setStudyResourceSearch(e.target.value)}
                                                    className="h-8 text-xs bg-muted/30 border-border/40 rounded-lg px-2 w-full focus-visible:ring-1 focus-visible:ring-primary"
                                                />
                                            </div>
                                            
                                            {/* VÍDEOS DO ACERVO */}
                                            {(() => {
                                                const dbVideos = resources.filter(r => r.type === "video" && r.title.toLowerCase().includes(studyResourceSearch.toLowerCase()));
                                                if (dbVideos.length === 0) return null;
                                                return (
                                                    <>
                                                        <div className="px-2 py-1 text-xs font-bold text-muted-foreground mt-1">
                                                            🎥 Vídeos do Acervo
                                                        </div>
                                                        {dbVideos.map(r => (
                                                            <SelectItem key={r.id} value={r.id} disabled={selectedResourcesForStudy.some(s => s.id === r.id)}>
                                                                {r.title}
                                                            </SelectItem>
                                                        ))}
                                                    </>
                                                );
                                            })()}

                                            {/* PDFs DO ACERVO */}
                                            {(() => {
                                                const dbPDFs = resources.filter(r => r.type === "pdf" && r.title.toLowerCase().includes(studyResourceSearch.toLowerCase()));
                                                if (dbPDFs.length === 0) return null;
                                                return (
                                                    <>
                                                        <div className="px-2 py-1.5 border-t border-border/40 text-xs font-bold text-muted-foreground mt-1">
                                                            📄 Documentos PDF
                                                        </div>
                                                        {dbPDFs.map(r => (
                                                            <SelectItem key={r.id} value={r.id} disabled={selectedResourcesForStudy.some(s => s.id === r.id)}>
                                                                {r.title}
                                                            </SelectItem>
                                                        ))}
                                                    </>
                                                );
                                            })()}

                                            {/* TEXTOS / MARKDOWN */}
                                            {(() => {
                                                const dbTextos = resources.filter(r => r.type === "markdown" && r.title.toLowerCase().includes(studyResourceSearch.toLowerCase()));
                                                if (dbTextos.length === 0) return null;
                                                return (
                                                    <>
                                                        <div className="px-2 py-1.5 border-t border-border/40 text-xs font-bold text-muted-foreground mt-1">
                                                            📝 Textos e Leituras (Markdown)
                                                        </div>
                                                        {dbTextos.map(r => (
                                                            <SelectItem key={r.id} value={r.id} disabled={selectedResourcesForStudy.some(s => s.id === r.id)}>
                                                                {r.title}
                                                            </SelectItem>
                                                        ))}
                                                    </>
                                                );
                                            })()}
                                            
                                            {/* YOUTUBE CHANNEL VIDEOS */}
                                            {(() => {
                                                const ytVideos = uniqueYoutubeVideos.filter(v => v.title.toLowerCase().includes(studyResourceSearch.toLowerCase()));
                                                if (ytVideos.length === 0) return null;
                                                return (
                                                    <>
                                                        <div className="px-2 py-1.5 border-t border-border/50 text-xs font-bold text-muted-foreground flex items-center gap-1.5 mt-1">
                                                            <YoutubeIcon className="h-3.5 w-3.5 text-destructive" />
                                                            Vídeos Recentes do Canal (Não Salvos)
                                                        </div>
                                                        {ytVideos.map(v => (
                                                            <SelectItem key={v.id} value={`yt_${v.id}`} disabled={selectedResourcesForStudy.some(s => s.url.includes(v.id))}>
                                                                🔴 {v.title}
                                                            </SelectItem>
                                                        ))}
                                                    </>
                                                );
                                            })()}
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
                                    <div className="flex items-center gap-2 shrink-0">
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => handleOpenStudyNote(selectedStudy)}
                                            className={cn(
                                                "rounded-xl gap-2 shrink-0 border-border min-h-[44px] px-3.5 cursor-pointer transition-all",
                                                getStudyNote(selectedStudy.id)
                                                    ? "border-primary/40 bg-primary/10 text-primary font-medium"
                                                    : "hover:bg-primary/5 hover:text-primary"
                                            )}
                                            title="Minhas anotações sobre este estudo"
                                        >
                                            <StickyNoteIcon className="h-4 w-4" />
                                            <span className="hidden sm:inline">
                                                {getStudyNote(selectedStudy.id) ? "Minhas Anotações" : "Anotar"}
                                            </span>
                                        </Button>
                                        {canAddMaterial && (
                                            <Button
                                                variant="outline"
                                                size="sm"
                                                onClick={(e) => {
                                                    handleEditStudy(selectedStudy, e);
                                                    setSelectedStudy(null);
                                                }}
                                                className="rounded-xl gap-2 shrink-0 border-primary/20 text-primary hover:bg-primary/5 hover:text-primary min-h-[44px] px-3.5"
                                            >
                                                <PencilIcon className="h-3.5 w-3.5" />
                                                <span>Editar</span>
                                            </Button>
                                        )}
                                    </div>
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
                                            const stepNote = getResourceNote(step.media_resource.id);

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
                                                        <div className="flex items-center gap-1 shrink-0">
                                                            <Button
                                                                type="button"
                                                                variant="ghost"
                                                                size="icon"
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    handleOpenResourceNote(step.media_resource, selectedStudy.id);
                                                                }}
                                                                className={cn(
                                                                    "min-h-[44px] min-w-[44px] rounded-xl cursor-pointer",
                                                                    stepNote
                                                                        ? "text-primary bg-primary/10 hover:bg-primary/20"
                                                                        : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                                                                )}
                                                                title={stepNote ? "Ver anotações deste material" : "Anotar neste material"}
                                                            >
                                                                <StickyNoteIcon className="h-4 w-4" />
                                                            </Button>
                                                            <Button 
                                                                variant="ghost" 
                                                                size="sm"
                                                                className="min-h-[44px] rounded-xl gap-1 hover:bg-primary hover:text-white"
                                                            >
                                                                <span>Acessar</span>
                                                                <ChevronRightIcon className="h-3.5 w-3.5" />
                                                            </Button>
                                                        </div>
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

            {/* DIALOG: VISUALIZAR ETAPA (MEDIA VIEWER E CONCLUSÃO COM ANOTAÇÕES LADO A LADO) */}
            <Dialog 
                open={!!activeStep} 
                onOpenChange={(open) => {
                    if (!open) {
                        setActiveStep(null);
                        setIsSideBySideNotesOpen(false);
                    }
                }}
            >
                {activeStep && (() => {
                    const resObj = activeStep.media_resource;
                    const isStepCompleted = userProgress.some(p => p.step_id === activeStep.id);
                    const isStudyStep = !!activeStep.id; // False if opened from general media tabs (mocked id)

                    const renderMediaContent = () => (
                        <div className="bg-muted/30 border border-border/50 rounded-2xl overflow-hidden flex flex-col justify-center min-h-[260px] sm:min-h-[300px]">
                            {/* Video Rendering */}
                            {resObj.type === "video" && (() => {
                                const ytId = getYouTubeId(resObj.url);
                                if (ytId) {
                                    return (
                                        <div className="aspect-video w-full bg-black/95">
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
                                    <div className="flex flex-col items-center justify-center p-6 sm:p-8 text-center">
                                        <YoutubeIcon className="h-10 w-10 sm:h-12 sm:w-12 text-destructive mb-3 animate-pulse" />
                                        <h5 className="font-semibold text-sm sm:text-base mb-2">Vídeo Externo</h5>
                                        <p className="text-xs text-muted-foreground max-w-sm mb-4">Este vídeo não possui formato do YouTube compatível com player interno.</p>
                                        <a href={resObj.url} target="_blank" rel="noopener noreferrer">
                                            <Button className="rounded-full gap-2 min-h-[44px]">
                                                <PlayIcon className="h-4 w-4" />
                                                Abrir no YouTube
                                            </Button>
                                        </a>
                                    </div>
                                );
                            })()}

                            {/* PDF Rendering */}
                            {resObj.type === "pdf" && (
                                <div className="flex flex-col items-center justify-center p-6 sm:p-8 text-center min-h-[280px] sm:min-h-[320px]">
                                    <FileTextIcon className="h-12 w-12 sm:h-16 sm:w-16 text-red-500 mb-3 sm:mb-4" />
                                    <h5 className="font-bold text-base sm:text-lg mb-2">Documento PDF Pronto para Leitura</h5>
                                    <p className="text-xs sm:text-sm text-muted-foreground max-w-sm mb-5 sm:mb-6">
                                        Abra a apostila ou guia de estudos para acompanhar simultaneamente com suas anotações.
                                    </p>
                                    <div className="flex flex-col sm:flex-row gap-3 w-full justify-center">
                                        <a href={resObj.url} target="_blank" rel="noopener noreferrer" className="w-full sm:w-auto">
                                            <Button className="rounded-full gap-2 w-full px-5 min-h-[44px] shadow-md">
                                                <EyeIcon className="h-4 w-4" />
                                                Visualizar PDF
                                            </Button>
                                        </a>
                                        <a href={resObj.url} download className="w-full sm:w-auto">
                                            <Button variant="outline" className="rounded-full gap-2 w-full px-5 min-h-[44px] border-border/60">
                                                <DownloadIcon className="h-4 w-4" />
                                                Baixar Arquivo
                                            </Button>
                                        </a>
                                    </div>
                                </div>
                            )}

                            {/* Markdown Rendering */}
                            {resObj.type === "markdown" && (
                                <div className="p-4 sm:p-6 max-h-[500px] overflow-y-auto">
                                    <MarkdownViewer url={resObj.url} />
                                </div>
                            )}
                        </div>
                    );

                    return (
                        <DialogContent className={cn(
                            "bg-card border-border shadow-2xl rounded-3xl p-0 transition-all duration-200",
                            isSideBySideNotesOpen 
                                ? "w-[98vw] sm:max-w-6xl md:max-w-7xl max-w-[1550px] h-[94vh] flex flex-col overflow-hidden" 
                                : (resObj.type === "markdown" ? "sm:max-w-4xl w-[95vw] max-h-[90vh] overflow-y-auto" : "sm:max-w-3xl w-[95vw] max-h-[90vh] overflow-y-auto")
                        )}>
                            <DialogHeader className="p-4 sm:p-6 pb-3 border-b border-border/50 flex flex-row items-start justify-between gap-3 shrink-0">
                                <div className="space-y-1 flex-1 min-w-0">
                                    <div className="flex flex-wrap items-center gap-2">
                                        <Badge variant="secondary" className="font-bold uppercase tracking-wider text-[10px] px-2 py-0.5">
                                            {resObj.type === 'video' ? 'Vídeo' : resObj.type === 'pdf' ? 'Apostila PDF' : 'Leitura'}
                                        </Badge>
                                        {isSideBySideNotesOpen && (
                                            <Badge variant="outline" className="text-[10px] text-primary border-primary/30 bg-primary/5 font-semibold">
                                                Modo Estudo com Anotações
                                            </Badge>
                                        )}
                                    </div>
                                    <DialogTitle className="text-base sm:text-lg font-bold text-foreground truncate" title={resObj.title}>
                                        {resObj.title}
                                    </DialogTitle>
                                </div>
                                <div className="shrink-0 flex items-center gap-2">
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => {
                                            if (isSideBySideNotesOpen) {
                                                setIsSideBySideNotesOpen(false);
                                            } else {
                                                const existingNote = getResourceNote(resObj.id);
                                                setNoteTarget({
                                                    type: "resource",
                                                    id: resObj.id,
                                                    title: resObj.title,
                                                    studyId: isStudyStep ? activeStep.study_id : undefined,
                                                    note: existingNote || null,
                                                });
                                                setIsSideBySideNotesOpen(true);
                                            }
                                        }}
                                        className={cn(
                                            "rounded-xl gap-2 min-h-[44px] px-3 sm:px-3.5 cursor-pointer transition-all text-xs sm:text-sm",
                                            isSideBySideNotesOpen || getResourceNote(resObj.id)
                                                ? "border-primary/40 bg-primary/10 text-primary font-semibold shadow-xs"
                                                : "hover:bg-primary/5 hover:text-primary"
                                        )}
                                        title={isSideBySideNotesOpen ? "Ocultar anotações" : "Anotar neste material"}
                                    >
                                        <StickyNoteIcon className="h-4 w-4" />
                                        <span className="hidden sm:inline">
                                            {isSideBySideNotesOpen 
                                                ? "Ocultar Anotações" 
                                                : (getResourceNote(resObj.id) ? "Minhas Anotações" : "Anotar")}
                                        </span>
                                        <span className="sm:hidden">
                                            {isSideBySideNotesOpen ? "Ocultar" : "Anotar"}
                                        </span>
                                    </Button>
                                </div>
                            </DialogHeader>

                            {isSideBySideNotesOpen ? (
                                <div className="flex-1 min-h-0 grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6 p-4 sm:p-6 overflow-y-auto lg:overflow-hidden">
                                    {/* Left Column: Resource Player / Viewer */}
                                    <div className="flex flex-col h-full min-h-0 overflow-y-auto pr-0 lg:pr-2 space-y-4">
                                        {renderMediaContent()}

                                        {resObj.description && resObj.type !== "markdown" && (
                                            <div className="bg-muted/10 border border-border/30 p-3.5 sm:p-4 rounded-xl text-xs sm:text-sm text-muted-foreground shrink-0">
                                                <p className="font-semibold text-foreground mb-1">Sobre este material:</p>
                                                {resObj.description}
                                            </div>
                                        )}

                                        {/* Action buttons */}
                                        <div className="mt-auto pt-2 flex flex-wrap items-center justify-between gap-3 shrink-0">
                                            <div className="flex items-center gap-2">
                                                <Button 
                                                    type="button" 
                                                    variant="ghost" 
                                                    onClick={() => {
                                                        setActiveStep(null);
                                                        setIsSideBySideNotesOpen(false);
                                                    }}
                                                    className="rounded-full px-5 min-h-[44px]"
                                                >
                                                    Voltar
                                                </Button>
                                                {canAddMaterial && resObj.type === "markdown" && (
                                                    <Button
                                                        onClick={() => {
                                                            setActiveStep(null);
                                                            setIsSideBySideNotesOpen(false);
                                                            setEditingTextResource(resObj);
                                                            setIsTextEditorOpen(true);
                                                        }}
                                                        variant="outline"
                                                        className="rounded-full px-4 gap-2 text-amber-600 border-amber-600/20 hover:bg-amber-500/10 min-h-[44px] text-xs cursor-pointer"
                                                    >
                                                        <PencilIcon className="h-3.5 w-3.5" />
                                                        Editar Texto Original
                                                    </Button>
                                                )}
                                            </div>

                                            {isStudyStep ? (
                                                <Button
                                                    onClick={() => {
                                                        handleToggleCompleteStep(activeStep);
                                                        setActiveStep(null);
                                                        setIsSideBySideNotesOpen(false);
                                                    }}
                                                    className={cn(
                                                        "rounded-full px-6 gap-2 font-semibold shadow-md min-h-[44px]",
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

                                    {/* Right Column: Embedded Note Editor */}
                                    <div className="h-[520px] lg:h-full min-h-[450px] flex flex-col min-h-0">
                                        <TextEditor
                                            inline={true}
                                            isOpen={true}
                                            mode="note"
                                            modalTitle={`Anotações: ${resObj.title}`}
                                            modalDescription="Suas reflexões e notas pessoais sobre este estudo."
                                            initialData={noteTarget?.note ? {
                                                id: noteTarget.note.id,
                                                title: noteTarget.note.title,
                                                content: noteTarget.note.content
                                            } : {
                                                title: `Anotações: ${resObj.title}`,
                                                content: ""
                                            }}
                                            onClose={() => setIsSideBySideNotesOpen(false)}
                                            onSave={handleSaveNote}
                                            onDelete={noteTarget?.note ? () => handleDeleteNote(noteTarget.note?.id) : undefined}
                                            className="h-full"
                                        />
                                    </div>
                                </div>
                            ) : (
                                <div className="p-4 sm:p-6 overflow-y-auto">
                                    <div className="mb-6">
                                        {renderMediaContent()}
                                    </div>

                                    {resObj.description && resObj.type !== "markdown" && (
                                        <div className="bg-muted/10 border border-border/30 p-4 rounded-xl mb-6 text-sm text-muted-foreground">
                                            <p className="font-medium text-foreground mb-1">Sobre esta etapa:</p>
                                            {resObj.description}
                                        </div>
                                    )}

                                    {/* Completion control for studies and note actions */}
                                    <div className="flex flex-wrap justify-between items-center gap-3 pt-2">
                                        <div className="flex flex-wrap items-center gap-2">
                                            <Button 
                                                type="button" 
                                                variant="ghost" 
                                                onClick={() => setActiveStep(null)}
                                                className="rounded-full px-5 min-h-[44px]"
                                            >
                                                Voltar
                                            </Button>
                                            <Button
                                                variant="outline"
                                                onClick={() => {
                                                    const existingNote = getResourceNote(resObj.id);
                                                    setNoteTarget({
                                                        type: "resource",
                                                        id: resObj.id,
                                                        title: resObj.title,
                                                        studyId: isStudyStep ? activeStep.study_id : undefined,
                                                        note: existingNote || null,
                                                    });
                                                    setIsSideBySideNotesOpen(true);
                                                }}
                                                className={cn(
                                                    "rounded-full px-4 gap-2 text-xs min-h-[44px] cursor-pointer",
                                                    getResourceNote(resObj.id)
                                                        ? "border-primary/40 bg-primary/10 text-primary font-medium"
                                                        : "hover:bg-primary/5 hover:text-primary"
                                                )}
                                            >
                                                <StickyNoteIcon className="h-3.5 w-3.5" />
                                                <span>{getResourceNote(resObj.id) ? "Minhas Anotações" : "Fazer Anotações"}</span>
                                            </Button>
                                            {canAddMaterial && resObj.type === "markdown" && (
                                                <Button
                                                    onClick={() => {
                                                        setActiveStep(null);
                                                        setEditingTextResource(resObj);
                                                        setIsTextEditorOpen(true);
                                                    }}
                                                    variant="outline"
                                                    className="rounded-full px-4 gap-2 text-amber-600 border-amber-600/20 hover:bg-amber-500/10 min-h-[44px] text-xs cursor-pointer"
                                                >
                                                    <PencilIcon className="h-3.5 w-3.5" />
                                                    Editar Texto Original
                                                </Button>
                                            )}
                                        </div>

                                        {isStudyStep ? (
                                            <Button
                                                onClick={() => {
                                                    handleToggleCompleteStep(activeStep);
                                                    setActiveStep(null);
                                                }}
                                                className={cn(
                                                    "rounded-full px-6 gap-2 font-semibold shadow-md min-h-[44px]",
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
                            )}
                        </DialogContent>
                    );
                })()}
            </Dialog>

            {/* TEXT RESOURCE EDITOR MODAL */}
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

            {/* STUDY & MATERIAL NOTE EDITOR MODAL */}
            <TextEditor
                isOpen={isNoteEditorOpen}
                mode="note"
                modalTitle={noteTarget ? `Anotações: ${noteTarget.title}` : "Minhas Anotações"}
                modalDescription="Suas reflexões e notas pessoais sobre este estudo. Visível apenas para você."
                initialData={noteTarget ? {
                    id: noteTarget.note?.id,
                    title: noteTarget.note?.title || `Anotações: ${noteTarget.title}`,
                    content: noteTarget.note?.content || ""
                } : null}
                onClose={() => {
                    setIsNoteEditorOpen(false);
                    setNoteTarget(null);
                }}
                onSave={handleSaveNote}
                onDelete={noteTarget?.note ? () => handleDeleteNote(noteTarget.note?.id) : undefined}
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
                <Spinner className="h-6 w-6 text-primary" />
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
