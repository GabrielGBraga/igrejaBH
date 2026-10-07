import { useState, useEffect, useRef } from "react";
import { 
    GraduationCapIcon, 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    StickyNoteIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import supabase from "@/lib/supabase";
import { Spinner } from "@/components/ui/spinner";
import { TextEditor } from "@/components/TextEditor";
import { fetchLatestVideos, type YouTubeVideo } from "@/lib/youtube";
import type { Database } from "@/lib/database.types";

// Modular study components
import { StudyHeader } from "@/components/study/StudyHeader";
import { StudyOverallProgress } from "@/components/study/StudyOverallProgress";
import { StudyTabsNav, type TabType } from "@/components/study/StudyTabsNav";
import { StudyCard } from "@/components/study/StudyCard";
import { ResourceCard, YouTubeImportCard } from "@/components/study/ResourceCard";
import { NoteCard, type EnrichedNote } from "@/components/study/NoteCard";
import { StudyDetailModal } from "@/components/study/StudyDetailModal";
import { StudyLessonModal } from "@/components/study/StudyLessonModal";
import { CreateStudyModal, type StudyFormValues } from "@/components/study/CreateStudyModal";
import { AddResourceModal, type ResourceFormValues } from "@/components/study/AddResourceModal";

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

const getYouTubeId = (url: string) => {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);
    return match && match[2].length === 11 ? match[2] : null;
};

export default function Ensinos() {
    const [activeTab, setActiveTab] = useState<TabType>("estudos");
    const [profile, setProfile] = useState<Profile | null>(null);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const [selectedCategory, setSelectedCategory] = useState("todos");

    // Database content states
    const [resources, setResources] = useState<MediaResource[]>([]);
    const [studies, setStudies] = useState<Study[]>([]);
    const [studySteps, setStudySteps] = useState<StudyStep[]>([]);
    const [userProgress, setUserProgress] = useState<UserProgress[]>([]);
    const [notes, setNotes] = useState<StudyNote[]>([]);
    const [loadingData, setLoadingData] = useState(true);

    // YouTube state
    const [youtubeVideos, setYoutubeVideos] = useState<YouTubeVideo[]>([]);
    const [loadingYoutube, setLoadingYoutube] = useState(false);
    const isSyncingRef = useRef(false);

    // Modal states
    const [isAddResourceOpen, setIsAddResourceOpen] = useState(false);
    const [isCreateStudyOpen, setIsCreateStudyOpen] = useState(false);
    const [editingStudy, setEditingStudy] = useState<Study | null>(null);
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
    const [notesFilter, setNotesFilter] = useState<"todos" | "estudos" | "videos" | "pdfs" | "textos">("todos");

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
                            is_presbyter: Boolean(profData.is_presbyter),
                            is_deacon: Boolean(profData.is_deacon),
                            is_dev: Boolean(profData.is_dev),
                        };
                        setProfile(profObj);
                        await loadDatabaseData(profObj.id);

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

            // 3. Fetch Study Steps with Media Resources
            const { data: stepsData } = await supabase
                .from("study_steps")
                .select("*, media_resource:media_resources(*)")
                .order("sort_order", { ascending: true });
            setStudySteps((stepsData as unknown as StudyStep[]) || []);

            // 4. Fetch User Progress
            const { data: progData } = await supabase
                .from("user_study_progress")
                .select("*")
                .eq("profile_id", profileId);
            setUserProgress(progData || []);

            // 5. Fetch Study Notes
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

    const canAddMaterial = Boolean(profile?.is_presbyter || profile?.is_deacon || profile?.is_dev);

    // Auto-sync YouTube videos if leader
    useEffect(() => {
        async function autoSyncYoutubeVideos() {
            if (!profile || !canAddMaterial || youtubeVideos.length === 0 || isSyncingRef.current) return;

            const dbIds = new Set(
                resources
                    .filter((r) => r.type === "video")
                    .map((v) => getYouTubeId(v.url))
                    .filter((id): id is string => id !== null)
            );
            const toSync = youtubeVideos.filter((yt) => !dbIds.has(yt.id));
            if (toSync.length === 0) return;

            isSyncingRef.current = true;
            try {
                const videosToInsert = toSync.map((video) => ({
                    title: video.title,
                    description: video.description || null,
                    type: "video" as const,
                    url: `https://www.youtube.com/watch?v=${video.id}`,
                    category: "videos",
                }));

                const { error } = await supabase.from("media_resources").insert(videosToInsert);
                if (error) throw error;

                await loadDatabaseData(profile.id);
                toast.success(`${videosToInsert.length} novos vídeos do YouTube sincronizados!`);
            } catch (err) {
                console.error("Error auto-syncing youtube videos:", err);
            } finally {
                isSyncingRef.current = false;
            }
        }
        autoSyncYoutubeVideos();
    }, [youtubeVideos, resources, profile, canAddMaterial]);

    // Add Media Resource Handler
    const handleAddResourceSubmit = async (values: ResourceFormValues, selectedFile: File | null) => {
        if (!profile) return;

        let publicUrl = values.url || "";

        try {
            if (values.type === "pdf" || values.type === "markdown") {
                if (!selectedFile) {
                    toast.error("Selecione um arquivo para fazer upload.");
                    return;
                }

                const ext = selectedFile.name.split(".").pop()?.toLowerCase();
                if (values.type === "pdf" && ext !== "pdf") {
                    toast.error("Por favor, selecione um arquivo PDF válido.");
                    return;
                }
                if (values.type === "markdown" && ext !== "md" && ext !== "markdown") {
                    toast.error("Por favor, selecione um arquivo Markdown (.md) válido.");
                    return;
                }

                const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.${ext}`;
                const filePath = `${profile.id}/${fileName}`;

                const { error: uploadError } = await supabase.storage
                    .from("ensinos")
                    .upload(filePath, selectedFile, {
                        cacheControl: "3600",
                        upsert: false,
                    });

                if (uploadError) throw uploadError;

                const { data: urlData } = supabase.storage
                    .from("ensinos")
                    .getPublicUrl(filePath);

                publicUrl = urlData.publicUrl;
            }

            if (!publicUrl) {
                toast.error("Por favor, informe a URL do vídeo.");
                return;
            }

            const { error: insertError } = await supabase
                .from("media_resources")
                .insert({
                    title: values.title,
                    description: values.description || null,
                    type: values.type,
                    url: publicUrl,
                    category: activeTab !== "estudos" ? activeTab : "ensinos",
                });

            if (insertError) throw insertError;

            toast.success("Recurso adicionado com sucesso!");
            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error creating resource:", error);
            toast.error(error.message || "Erro ao salvar recurso.");
        }
    };

    // Save Rich Text / Markdown Handler
    const handleSaveText = async (data: { title: string; description: string; markdownContent: string }) => {
        if (!profile) return;

        try {
            const blob = new Blob([data.markdownContent], { type: "text/markdown" });

            if (editingTextResource) {
                const urlParts = editingTextResource.url.split("/ensinos/");
                if (urlParts.length <= 1) {
                    throw new Error("URL do recurso inválida para edição.");
                }
                const storagePath = urlParts[1];

                const { error: uploadError } = await supabase.storage
                    .from("ensinos")
                    .upload(storagePath, blob, {
                        cacheControl: "3600",
                        upsert: true,
                    });

                if (uploadError) throw uploadError;

                const { error: updateError } = await supabase
                    .from("media_resources")
                    .update({
                        title: data.title,
                        description: data.description || null,
                    })
                    .eq("id", editingTextResource.id);

                if (updateError) throw updateError;

                toast.success("Texto atualizado com sucesso!");
                setEditingTextResource(null);
            } else {
                const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.md`;
                const filePath = `${profile.id}/${fileName}`;

                const { error: uploadError } = await supabase.storage
                    .from("ensinos")
                    .upload(filePath, blob, {
                        cacheControl: "3600",
                        upsert: false,
                    });

                if (uploadError) throw uploadError;

                const { data: urlData } = supabase.storage
                    .from("ensinos")
                    .getPublicUrl(filePath);

                const { error: insertError } = await supabase
                    .from("media_resources")
                    .insert({
                        title: data.title,
                        description: data.description || null,
                        type: "markdown",
                        url: urlData.publicUrl,
                        category: "textos",
                    });

                if (insertError) throw insertError;
                toast.success("Texto criado com sucesso!");
            }

            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error saving rich text:", error);
            toast.error(error.message || "Erro ao salvar texto.");
            throw error;
        }
    };

    // Create or Edit Study Handler
    const handleCreateStudySubmit = async (values: StudyFormValues, selectedResourcesForStudy: MediaResource[]) => {
        if (!profile) return;
        if (selectedResourcesForStudy.length === 0) {
            toast.error("Adicione pelo menos um recurso (etapa) à trilha.");
            return;
        }

        try {
            setLoadingData(true);

            if (editingStudy) {
                const { error: studyError } = await supabase
                    .from("studies")
                    .update({
                        title: values.title,
                        description: values.description || null,
                    })
                    .eq("id", editingStudy.id);

                if (studyError) throw studyError;

                const { error: deleteStepsError } = await supabase
                    .from("study_steps")
                    .delete()
                    .eq("study_id", editingStudy.id);

                if (deleteStepsError) throw deleteStepsError;

                const stepsData = selectedResourcesForStudy.map((res, index) => ({
                    study_id: editingStudy.id,
                    media_resource_id: res.id,
                    sort_order: index + 1,
                }));

                const { error: stepsError } = await supabase.from("study_steps").insert(stepsData);
                if (stepsError) throw stepsError;

                toast.success("Trilha de estudo atualizada com sucesso!");
            } else {
                const { data: newStudy, error: studyError } = await supabase
                    .from("studies")
                    .insert({
                        title: values.title,
                        description: values.description || null,
                        created_by: profile.id,
                    })
                    .select()
                    .single();

                if (studyError) throw studyError;

                const stepsData = selectedResourcesForStudy.map((res, index) => ({
                    study_id: newStudy.id,
                    media_resource_id: res.id,
                    sort_order: index + 1,
                }));

                const { error: stepsError } = await supabase.from("study_steps").insert(stepsData);
                if (stepsError) throw stepsError;

                toast.success("Trilha de estudo criada com sucesso!");
            }

            setIsCreateStudyOpen(false);
            setEditingStudy(null);
            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error saving study:", error);
            toast.error(error.message || "Erro ao salvar trilha de estudo.");
        } finally {
            setLoadingData(false);
        }
    };

    // Import YouTube video into the collection
    const handleImportYoutubeVideo = async (video: YouTubeVideo): Promise<MediaResource | null> => {
        if (!profile) return null;
        try {
            setLoadingData(true);
            const { data, error } = await supabase
                .from("media_resources")
                .insert({
                    title: video.title,
                    description: video.description || null,
                    type: "video",
                    url: `https://www.youtube.com/watch?v=${video.id}`,
                    category: "videos",
                })
                .select()
                .single();

            if (error) throw error;
            toast.success("Vídeo adicionado ao acervo com sucesso!");
            await loadDatabaseData(profile.id);
            return data;
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error importing youtube video:", error);
            toast.error("Erro ao adicionar vídeo ao acervo.");
            return null;
        } finally {
            setLoadingData(false);
        }
    };

    // Delete Study
    const handleDeleteStudy = async (studyId: string, e: React.MouseEvent) => {
        e.stopPropagation();
        if (!profile) return;
        if (!confirm("Deseja realmente excluir esta trilha? As etapas e progressos serão removidos.")) return;

        try {
            setLoadingData(true);
            const { error } = await supabase.from("studies").delete().eq("id", studyId);
            if (error) throw error;
            toast.success("Trilha removida.");
            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error deleting study:", error);
            toast.error(error.message || "Erro ao deletar trilha.");
        } finally {
            setLoadingData(false);
        }
    };

    // Delete Media Resource
    const handleDeleteResource = async (resourceId: string, e: React.MouseEvent) => {
        e.stopPropagation();
        if (!profile) return;
        if (!confirm("Deseja excluir este recurso de mídia? Ele será removido de qualquer trilha associada.")) return;

        try {
            setLoadingData(true);
            const { data: resInfo } = await supabase
                .from("media_resources")
                .select("url, type")
                .eq("id", resourceId)
                .single();

            if (resInfo && (resInfo.type === "pdf" || resInfo.type === "markdown")) {
                const urlParts = resInfo.url.split("/ensinos/");
                if (urlParts.length > 1) {
                    await supabase.storage.from("ensinos").remove([urlParts[1]]);
                }
            }

            const { error } = await supabase.from("media_resources").delete().eq("id", resourceId);
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

    // Toggle complete step logic
    const handleToggleCompleteStep = async (step: StudyStep) => {
        if (!profile) return;

        const isCompleted = userProgress.some((p) => p.step_id === step.id);

        try {
            if (isCompleted) {
                const { error } = await supabase
                    .from("user_study_progress")
                    .delete()
                    .eq("profile_id", profile.id)
                    .eq("step_id", step.id);
                if (error) throw error;
                toast.success("Etapa marcada como pendente.");
            } else {
                const { error } = await supabase
                    .from("user_study_progress")
                    .insert({
                        profile_id: profile.id,
                        study_id: step.study_id,
                        step_id: step.id,
                    });
                if (error) throw error;
                toast.success("Etapa concluída com sucesso!");
            }

            const { data: progData } = await supabase
                .from("user_study_progress")
                .select("*")
                .eq("profile_id", profile.id);
            setUserProgress(progData || []);

            // Check if study is now 100% complete
            const activeStudyId = step.study_id || selectedStudy?.id;
            if (activeStudyId) {
                const currentStudySteps = studySteps.filter((s) => s.study_id === activeStudyId);
                const currentCompletedCount = (progData || []).filter((p) => p.study_id === activeStudyId).length;
                if (!isCompleted && currentCompletedCount === currentStudySteps.length && currentStudySteps.length > 0) {
                    toast.success("Parabéns! Você concluiu com sucesso esta trilha de edificação! 🎉", {
                        duration: 6000,
                    });
                }
            }
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error toggling step progress:", error);
            toast.error(error.message || "Erro ao atualizar progresso.");
        }
    };

    // Save Note Handler
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
                        updated_at: new Date().toISOString(),
                    })
                    .eq("id", existingNote.id)
                    .select()
                    .single();

                if (error) throw error;
                if (updated) {
                    setNoteTarget((prev) => (prev ? { ...prev, note: updated } : null));
                }
            } else {
                const isUuidStr = (v?: string) =>
                    Boolean(v && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v));
                const mediaResId =
                    noteTarget.type === "resource" && isUuidStr(noteTarget.id) ? noteTarget.id : null;

                const { data: inserted, error } = await supabase
                    .from("study_notes")
                    .insert({
                        profile_id: profile.id,
                        study_id: noteTarget.type === "study" ? noteTarget.id : (noteTarget.studyId || null),
                        media_resource_id: mediaResId,
                        title: data.title || `Anotações: ${noteTarget.title}`,
                        content: data.markdownContent,
                        updated_at: new Date().toISOString(),
                    })
                    .select()
                    .single();

                if (error) throw error;
                if (inserted) {
                    setNoteTarget((prev) => (prev ? { ...prev, note: inserted } : null));
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

    // Delete Note Handler
    const handleDeleteNote = async (noteId?: string) => {
        const idToDelete = noteId || noteTarget?.note?.id;
        if (!profile || !idToDelete) return;

        try {
            const { error } = await supabase.from("study_notes").delete().eq("id", idToDelete);
            if (error) throw error;

            toast.success("Anotação excluída com sucesso.");
            setIsNoteEditorOpen(false);
            setNoteTarget((prev) => (prev ? { ...prev, note: null } : null));
            await loadDatabaseData(profile.id);
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error deleting note:", error);
            toast.error(error.message || "Erro ao excluir anotação.");
            throw error;
        }
    };

    // Progress Calculations
    const getStudyProgressData = (studyId: string) => {
        const currentStudySteps = studySteps.filter((s) => s.study_id === studyId);
        const total = currentStudySteps.length;
        const completed = userProgress.filter((p) => p.study_id === studyId).length;
        const percent = total > 0 ? Math.round((completed / total) * 100) : 0;
        return { total, completed, percent, steps: currentStudySteps };
    };

    const getOverallCoursesProgress = () => {
        if (studies.length === 0) return { total: 0, completed: 0, percent: 0, active: 0 };

        let completed = 0;
        let total = 0;
        let active = 0;

        studies.forEach((study) => {
            const { total: stepsCount, completed: stepsCompleted } = getStudyProgressData(study.id);
            if (stepsCount > 0) {
                total++;
                if (stepsCompleted === stepsCount) {
                    completed++;
                } else if (stepsCompleted > 0) {
                    active++;
                }
            }
        });

        const percent = total > 0 ? Math.round((completed / total) * 100) : 0;
        return { total, completed, percent, active };
    };

    // Filtering logic
    const filteredResources = resources.filter((res) => {
        const query = searchQuery.toLowerCase();
        return res.title.toLowerCase().includes(query) || (res.description && res.description.toLowerCase().includes(query));
    });

    const filteredStudies = studies.filter((std) => {
        const query = searchQuery.toLowerCase();
        const matchesSearch = std.title.toLowerCase().includes(query) || (std.description && std.description.toLowerCase().includes(query));
        if (!matchesSearch) return false;

        if (selectedCategory === "todos") return true;
        const text = `${std.title} ${std.description || ""}`.toLowerCase();
        if (selectedCategory === "fundamentos") return text.includes("fundament") || text.includes("reino") || text.includes("fé");
        if (selectedCategory === "casas") return text.includes("casa") || text.includes("oikos") || text.includes("grupo");
        if (selectedCategory === "oracao") return text.includes("oraç") || text.includes("intercess");
        if (selectedCategory === "sacerdocio") return text.includes("sacerd") || text.includes("minist");
        if (selectedCategory === "evangelho") return text.includes("evangelh") || text.includes("arrepend");
        return true;
    });

    const tabVideos = filteredResources.filter((r) => r.type === "video");
    const tabPDFs = filteredResources.filter((r) => r.type === "pdf");
    const tabTextos = filteredResources.filter((r) => r.type === "markdown");

    // YouTube channel unique videos
    const dbVideoIds = new Set(
        resources
            .filter((r) => r.type === "video")
            .map((v) => getYouTubeId(v.url))
            .filter((id): id is string => id !== null)
    );
    const uniqueYoutubeVideos = youtubeVideos.filter((yt) => !dbVideoIds.has(yt.id));
    const filteredUniqueYoutubeVideos = uniqueYoutubeVideos.filter((video) => {
        const query = searchQuery.toLowerCase();
        return video.title.toLowerCase().includes(query) || (video.description && video.description.toLowerCase().includes(query));
    });

    // Enriched notes
    const enrichedNotes: EnrichedNote[] = notes.map((note) => {
        const study = note.study_id ? studies.find((s) => s.id === note.study_id) || null : null;
        const resource = note.media_resource_id ? resources.find((r) => r.id === note.media_resource_id) || null : null;
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

    const filteredNotes = enrichedNotes.filter((item) => {
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

    if (loading) {
        return (
            <div className="flex h-[60vh] items-center justify-center">
                <Spinner className="h-8 w-8 text-primary" />
            </div>
        );
    }

    const { total: totalCourses, completed: completedCourses, percent: overallPercent, active: activeCourses } = getOverallCoursesProgress();

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-16">
            {/* 1. Header with Theological Tone & Action Controls */}
            <StudyHeader
                canAddMaterial={canAddMaterial}
                activeTab={activeTab}
                onCreateStudy={() => {
                    setEditingStudy(null);
                    setIsCreateStudyOpen(true);
                }}
                onAddResource={() => setIsAddResourceOpen(true)}
                onWriteText={() => {
                    setEditingTextResource(null);
                    setIsTextEditorOpen(true);
                }}
            />

            {/* 2. Discipleship Overall Progress KPI Banner */}
            <StudyOverallProgress
                totalStudies={totalCourses}
                completedStudies={completedCourses}
                activeStudies={activeCourses}
                totalNotes={notes.length}
                percent={overallPercent}
            />

            {/* 3. Navigation Tabs, Search & Category Filters */}
            <StudyTabsNav
                activeTab={activeTab}
                onTabChange={setActiveTab}
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
                counts={{
                    estudos: studies.length,
                    videos: resources.filter((r) => r.type === "video").length + uniqueYoutubeVideos.length,
                    pdfs: resources.filter((r) => r.type === "pdf").length,
                    textos: resources.filter((r) => r.type === "markdown").length,
                    anotacoes: notes.length,
                }}
                selectedCategory={selectedCategory}
                onCategoryChange={setSelectedCategory}
            />

            {/* 4. Tab Content Area */}
            <div className="min-h-[300px]">
                {loadingData ? (
                    <div className="flex justify-center items-center py-24">
                        <Spinner className="h-9 w-9 text-primary" />
                    </div>
                ) : (
                    <>
                        {/* TAB: TRILHAS DE ESTUDO */}
                        {activeTab === "estudos" && (
                            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                {filteredStudies.length > 0 ? (
                                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                        {filteredStudies.map((study) => {
                                            const { total, completed, percent } = getStudyProgressData(study.id);
                                            const studyNote = notes.find((n) => n.study_id === study.id && !n.media_resource_id);

                                            return (
                                                <StudyCard
                                                    key={study.id}
                                                    study={study}
                                                    totalSteps={total}
                                                    completedSteps={completed}
                                                    percent={percent}
                                                    studyNote={studyNote}
                                                    canAddMaterial={canAddMaterial}
                                                    onClick={() => setSelectedStudy(study)}
                                                    onOpenNote={(e) => {
                                                        e.stopPropagation();
                                                        setNoteTarget({
                                                            type: "study",
                                                            id: study.id,
                                                            title: study.title,
                                                            note: studyNote || null,
                                                        });
                                                        setIsNoteEditorOpen(true);
                                                    }}
                                                    onEdit={(e) => {
                                                        e.stopPropagation();
                                                        setEditingStudy(study);
                                                        setIsCreateStudyOpen(true);
                                                    }}
                                                    onDelete={(e) => handleDeleteStudy(study.id, e)}
                                                />
                                            );
                                        })}
                                    </div>
                                ) : (
                                    <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/60 rounded-3xl p-6">
                                        <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                            <GraduationCapIcon className="h-8 w-8 text-muted-foreground/40" />
                                        </div>
                                        <h3 className="text-base sm:text-lg font-bold text-foreground">
                                            {searchQuery || selectedCategory !== "todos" ? "Nenhuma trilha encontrada" : "Nenhuma trilha cadastrada"}
                                        </h3>
                                        <p className="text-muted-foreground mt-1.5 max-w-sm mx-auto text-xs sm:text-sm leading-relaxed">
                                            {searchQuery || selectedCategory !== "todos"
                                                ? "Tente ajustar os filtros ou termos da busca."
                                                : "As trilhas ordenadas para edificação serão disponibilizadas aqui pela liderança servidora."}
                                        </p>
                                    </div>
                                )}
                            </div>
                        )}

                        {/* TAB: VÍDEOS */}
                        {activeTab === "videos" && (
                            <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                                {tabVideos.length > 0 && (
                                    <div className="space-y-4">
                                        <h3 className="text-sm sm:text-base font-bold text-foreground flex items-center gap-2">
                                            <span className="w-2 h-2 rounded-full bg-primary" />
                                            Vídeos do Acervo Oficial ({tabVideos.length})
                                        </h3>
                                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                            {tabVideos.map((video) => {
                                                const videoNote = notes.find((n) => n.media_resource_id === video.id);
                                                return (
                                                    <ResourceCard
                                                        key={video.id}
                                                        resource={video}
                                                        note={videoNote}
                                                        canAddMaterial={canAddMaterial}
                                                        onClick={() => {
                                                            setActiveStep({
                                                                id: "",
                                                                study_id: "",
                                                                media_resource_id: video.id,
                                                                sort_order: 0,
                                                                created_at: "",
                                                                media_resource: video,
                                                            });
                                                        }}
                                                        onOpenNote={(e) => {
                                                            e.stopPropagation();
                                                            setNoteTarget({
                                                                type: "resource",
                                                                id: video.id,
                                                                title: video.title,
                                                                note: videoNote || null,
                                                            });
                                                            setActiveStep({
                                                                id: "",
                                                                study_id: "",
                                                                media_resource_id: video.id,
                                                                sort_order: 0,
                                                                created_at: "",
                                                                media_resource: video,
                                                            });
                                                        }}
                                                        onDelete={(e) => handleDeleteResource(video.id, e)}
                                                    />
                                                );
                                            })}
                                        </div>
                                    </div>
                                )}

                                {/* YouTube Channel Recent Videos */}
                                {loadingYoutube ? (
                                    <div className="flex justify-center items-center py-16">
                                        <Spinner className="h-8 w-8 text-primary" />
                                    </div>
                                ) : filteredUniqueYoutubeVideos.length > 0 ? (
                                    <div className="space-y-4 pt-2">
                                        <h3 className="text-sm sm:text-base font-bold text-foreground flex items-center gap-2 text-muted-foreground">
                                            <YoutubeIcon className="h-4 w-4 text-destructive" />
                                            Vídeos Recentes do Canal da Igreja ({filteredUniqueYoutubeVideos.length})
                                        </h3>
                                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                            {filteredUniqueYoutubeVideos.map((video) => (
                                                <YouTubeImportCard
                                                    key={video.id}
                                                    video={video}
                                                    canAddMaterial={canAddMaterial}
                                                    onClick={() => {
                                                        const mockResource: MediaResource = {
                                                            id: "",
                                                            title: video.title,
                                                            description: video.description,
                                                            type: "video",
                                                            url: `https://www.youtube.com/watch?v=${video.id}`,
                                                            series_name: null,
                                                            category: "youtube",
                                                            created_at: video.publishedAt,
                                                        };
                                                        setActiveStep({
                                                            id: "",
                                                            study_id: "",
                                                            media_resource_id: "",
                                                            sort_order: 0,
                                                            created_at: "",
                                                            media_resource: mockResource,
                                                        });
                                                    }}
                                                    onImport={(e) => {
                                                        e.stopPropagation();
                                                        handleImportYoutubeVideo(video);
                                                    }}
                                                />
                                            ))}
                                        </div>
                                    </div>
                                ) : null}

                                {tabVideos.length === 0 && filteredUniqueYoutubeVideos.length === 0 && !loadingYoutube && (
                                    <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/60 rounded-3xl p-6">
                                        <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                            <YoutubeIcon className="h-8 w-8 text-muted-foreground/30" />
                                        </div>
                                        <h3 className="text-base sm:text-lg font-bold text-foreground">Nenhum vídeo disponível</h3>
                                        <p className="text-muted-foreground mt-1 max-w-sm mx-auto text-xs sm:text-sm">
                                            As ministrações e ensinos gravados aparecerão aqui.
                                        </p>
                                    </div>
                                )}
                            </div>
                        )}

                        {/* TAB: PDFS */}
                        {activeTab === "pdfs" && (
                            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                {tabPDFs.length > 0 ? (
                                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                        {tabPDFs.map((pdf) => {
                                            const pdfNote = notes.find((n) => n.media_resource_id === pdf.id);
                                            return (
                                                <ResourceCard
                                                    key={pdf.id}
                                                    resource={pdf}
                                                    note={pdfNote}
                                                    canAddMaterial={canAddMaterial}
                                                    onClick={() => {
                                                        setActiveStep({
                                                            id: "",
                                                            study_id: "",
                                                            media_resource_id: pdf.id,
                                                            sort_order: 0,
                                                            created_at: "",
                                                            media_resource: pdf,
                                                        });
                                                    }}
                                                    onOpenNote={(e) => {
                                                        e.stopPropagation();
                                                        setNoteTarget({
                                                            type: "resource",
                                                            id: pdf.id,
                                                            title: pdf.title,
                                                            note: pdfNote || null,
                                                        });
                                                        setActiveStep({
                                                            id: "",
                                                            study_id: "",
                                                            media_resource_id: pdf.id,
                                                            sort_order: 0,
                                                            created_at: "",
                                                            media_resource: pdf,
                                                        });
                                                    }}
                                                    onDelete={(e) => handleDeleteResource(pdf.id, e)}
                                                />
                                            );
                                        })}
                                    </div>
                                ) : (
                                    <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/60 rounded-3xl p-6">
                                        <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                            <FileTextIcon className="h-8 w-8 text-muted-foreground/30" />
                                        </div>
                                        <h3 className="text-base sm:text-lg font-bold text-foreground">Nenhuma apostila em PDF cadastrada</h3>
                                        <p className="text-muted-foreground mt-1 max-w-sm mx-auto text-xs sm:text-sm">
                                            Apostilas, manuais práticos e cadernos de estudo aparecerão aqui.
                                        </p>
                                    </div>
                                )}
                            </div>
                        )}

                        {/* TAB: TEXTOS / MD */}
                        {activeTab === "textos" && (
                            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                {tabTextos.length > 0 ? (
                                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                        {tabTextos.map((txt) => {
                                            const txtNote = notes.find((n) => n.media_resource_id === txt.id);
                                            return (
                                                <ResourceCard
                                                    key={txt.id}
                                                    resource={txt}
                                                    note={txtNote}
                                                    canAddMaterial={canAddMaterial}
                                                    onClick={() => {
                                                        setActiveStep({
                                                            id: "",
                                                            study_id: "",
                                                            media_resource_id: txt.id,
                                                            sort_order: 0,
                                                            created_at: "",
                                                            media_resource: txt,
                                                        });
                                                    }}
                                                    onOpenNote={(e) => {
                                                        e.stopPropagation();
                                                        setNoteTarget({
                                                            type: "resource",
                                                            id: txt.id,
                                                            title: txt.title,
                                                            note: txtNote || null,
                                                        });
                                                        setActiveStep({
                                                            id: "",
                                                            study_id: "",
                                                            media_resource_id: txt.id,
                                                            sort_order: 0,
                                                            created_at: "",
                                                            media_resource: txt,
                                                        });
                                                    }}
                                                    onEdit={(e) => {
                                                        e.stopPropagation();
                                                        setEditingTextResource(txt);
                                                        setIsTextEditorOpen(true);
                                                    }}
                                                    onDelete={(e) => handleDeleteResource(txt.id, e)}
                                                />
                                            );
                                        })}
                                    </div>
                                ) : (
                                    <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/60 rounded-3xl p-6">
                                        <div className="w-16 h-16 bg-muted/50 rounded-full flex items-center justify-center mx-auto mb-4">
                                            <BookOpenIcon className="h-8 w-8 text-muted-foreground/30" />
                                        </div>
                                        <h3 className="text-base sm:text-lg font-bold text-foreground">Nenhum texto cadastrado</h3>
                                        <p className="text-muted-foreground mt-1 max-w-sm mx-auto text-xs sm:text-sm">
                                            Textos informativos, reflexões ou documentos Markdown (.md) aparecerão aqui.
                                        </p>
                                    </div>
                                )}
                            </div>
                        )}

                        {/* TAB: MINHAS ANOTAÇÕES */}
                        {activeTab === "anotacoes" && (
                            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500 space-y-6">
                                {/* Sub-filters */}
                                <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
                                    {(
                                        [
                                            { id: "todos", label: "Todas", count: notes.length },
                                            {
                                                id: "estudos",
                                                label: "Trilhas",
                                                count: notes.filter((n) => n.study_id && !n.media_resource_id).length,
                                            },
                                            {
                                                id: "videos",
                                                label: "Vídeos",
                                                count: notes.filter((n) => {
                                                    const r = resources.find((res) => res.id === n.media_resource_id);
                                                    return r?.type === "video";
                                                }).length,
                                            },
                                            {
                                                id: "pdfs",
                                                label: "PDFs",
                                                count: notes.filter((n) => {
                                                    const r = resources.find((res) => res.id === n.media_resource_id);
                                                    return r?.type === "pdf";
                                                }).length,
                                            },
                                            {
                                                id: "textos",
                                                label: "Textos",
                                                count: notes.filter((n) => {
                                                    const r = resources.find((res) => res.id === n.media_resource_id);
                                                    return r?.type === "markdown";
                                                }).length,
                                            },
                                        ] as const
                                    ).map((filter) => (
                                        <button
                                            key={filter.id}
                                            onClick={() => setNotesFilter(filter.id)}
                                            className={cn(
                                                "flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-semibold transition-all whitespace-nowrap min-h-[44px] cursor-pointer",
                                                notesFilter === filter.id
                                                    ? "bg-zinc-900 text-zinc-50 dark:bg-zinc-50 dark:text-zinc-900 shadow-xs"
                                                    : "bg-muted/40 text-muted-foreground hover:bg-muted/80 hover:text-foreground"
                                            )}
                                        >
                                            <span>{filter.label}</span>
                                            <span
                                                className={cn(
                                                    "px-1.5 py-0.5 rounded-full text-[10px]",
                                                    notesFilter === filter.id
                                                        ? "bg-primary-foreground/20 text-primary-foreground"
                                                        : "bg-muted text-muted-foreground"
                                                )}
                                            >
                                                {filter.count}
                                            </span>
                                        </button>
                                    ))}
                                </div>

                                {filteredNotes.length > 0 ? (
                                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                        {filteredNotes.map((item) => (
                                            <NoteCard
                                                key={item.id}
                                                note={item}
                                                onEdit={() => {
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
                                                }}
                                                onDelete={() => handleDeleteNote(item.id)}
                                                onOpenMaterial={() => {
                                                    if (item.resource) {
                                                        setActiveStep({
                                                            id: "",
                                                            study_id: item.study_id || "",
                                                            media_resource_id: item.resource.id,
                                                            sort_order: 0,
                                                            created_at: "",
                                                            media_resource: item.resource,
                                                        });
                                                    } else if (item.study) {
                                                        setSelectedStudy(item.study);
                                                    }
                                                }}
                                            />
                                        ))}
                                    </div>
                                ) : (
                                    <div className="text-center py-20 bg-card/30 backdrop-blur-sm border border-dashed border-border/60 rounded-3xl p-6">
                                        <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
                                            <StickyNoteIcon className="h-8 w-8 text-primary" />
                                        </div>
                                        <h3 className="text-base sm:text-lg font-bold text-foreground">
                                            {searchQuery ? "Nenhuma anotação encontrada" : "Você ainda não possui anotações"}
                                        </h3>
                                        <p className="text-muted-foreground mt-1 max-w-md mx-auto text-xs sm:text-sm leading-relaxed">
                                            {searchQuery
                                                ? "Nenhuma reflexão corresponde à busca ou filtro atual."
                                                : "Suas notas pessoais e reflexões bíblicas feitas nas ministrações aparecerão organizadas aqui. Clique no ícone de anotação em qualquer material para registrar."}
                                        </p>
                                    </div>
                                )}
                            </div>
                        )}
                    </>
                )}
            </div>

            {/* 5. MODAL: DETALHES DA TRILHA DE ESTUDO */}
            <StudyDetailModal
                study={selectedStudy}
                steps={selectedStudy ? studySteps.filter((s) => s.study_id === selectedStudy.id) : []}
                userProgress={userProgress}
                notes={notes}
                canAddMaterial={canAddMaterial}
                onClose={() => setSelectedStudy(null)}
                onSelectStep={(step) => setActiveStep(step)}
                onOpenStudyNote={(study) => {
                    const existing = notes.find((n) => n.study_id === study.id && !n.media_resource_id);
                    setNoteTarget({
                        type: "study",
                        id: study.id,
                        title: study.title,
                        note: existing || null,
                    });
                    setIsNoteEditorOpen(true);
                }}
                onOpenStepNote={(resource, studyId) => {
                    const existing = notes.find((n) => n.media_resource_id === resource.id);
                    setNoteTarget({
                        type: "resource",
                        id: resource.id,
                        title: resource.title,
                        studyId,
                        note: existing || null,
                    });
                    setActiveStep({
                        id: "",
                        study_id: studyId,
                        media_resource_id: resource.id,
                        sort_order: 0,
                        created_at: "",
                        media_resource: resource,
                    });
                }}
                onEditStudy={(study) => {
                    setEditingStudy(study);
                    setSelectedStudy(null);
                    setIsCreateStudyOpen(true);
                }}
            />

            {/* 6. MODAL: ESTÚDIO DA AULA INTERATIVA (PLAYER + ANOTAÇÕES LADO A LADO) */}
            <StudyLessonModal
                step={activeStep}
                allStudySteps={activeStep?.study_id ? studySteps.filter((s) => s.study_id === activeStep.study_id) : []}
                studyTitle={activeStep?.study_id ? studies.find((s) => s.id === activeStep.study_id)?.title : undefined}
                studyId={activeStep?.study_id}
                userProgress={userProgress}
                existingNote={activeStep ? notes.find((n) => n.media_resource_id === activeStep.media_resource.id) : null}
                canAddMaterial={canAddMaterial}
                onClose={() => setActiveStep(null)}
                onToggleComplete={handleToggleCompleteStep}
                onNavigateStep={(step) => setActiveStep(step)}
                onSaveNote={handleSaveNote}
                onDeleteNote={handleDeleteNote}
                onEditTextResource={(res) => {
                    setActiveStep(null);
                    setEditingTextResource(res);
                    setIsTextEditorOpen(true);
                }}
            />

            {/* 7. MODAL: CRIAR / EDITAR TRILHA DE ESTUDO */}
            <CreateStudyModal
                isOpen={isCreateStudyOpen}
                editingStudy={editingStudy}
                resources={resources}
                youtubeVideos={youtubeVideos}
                initialSelectedResources={
                    editingStudy
                        ? studySteps
                              .filter((s) => s.study_id === editingStudy.id)
                              .map((s) => s.media_resource)
                              .filter((r): r is MediaResource => Boolean(r))
                        : []
                }
                onClose={() => {
                    setIsCreateStudyOpen(false);
                    setEditingStudy(null);
                }}
                onSubmit={handleCreateStudySubmit}
                onImportYouTubeVideo={handleImportYoutubeVideo}
            />

            {/* 8. MODAL: ADICIONAR RECURSO DE MÍDIA */}
            <AddResourceModal
                isOpen={isAddResourceOpen}
                onClose={() => setIsAddResourceOpen(false)}
                onSubmit={handleAddResourceSubmit}
            />

            {/* 9. MODAL: EDITOR DE TEXTO ORIGINAL (MARKDOWN) */}
            <TextEditor
                isOpen={isTextEditorOpen}
                onClose={() => {
                    setIsTextEditorOpen(false);
                    setEditingTextResource(null);
                }}
                onSave={handleSaveText}
                initialData={
                    editingTextResource
                        ? {
                              id: editingTextResource.id,
                              title: editingTextResource.title,
                              description: editingTextResource.description || "",
                              url: editingTextResource.url,
                          }
                        : null
                }
            />

            {/* 10. MODAL: ANOTAÇÕES DE ESTUDO GERAL */}
            <TextEditor
                isOpen={isNoteEditorOpen}
                mode="note"
                modalTitle={noteTarget ? `Anotações: ${noteTarget.title}` : "Minhas Anotações"}
                modalDescription="Suas reflexões privadas de discipulado."
                initialData={
                    noteTarget
                        ? {
                              id: noteTarget.note?.id,
                              title: noteTarget.note?.title || `Anotações: ${noteTarget.title}`,
                              content: noteTarget.note?.content || "",
                          }
                        : null
                }
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
