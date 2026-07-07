import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { 
    UsersIcon, 
    SearchIcon, 
    Loader2, 
    PhoneIcon, 
    MapPinIcon,
    HomeIcon,
    CalendarIcon,
    PlusIcon,
    Edit2Icon,
    Trash2Icon,
    MailIcon,
    UserCheckIcon,
    HeartIcon,
    FileText
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import type { Database } from "@/lib/database.types";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { 
    Dialog, 
    DialogContent, 
    DialogHeader, 
    DialogTitle, 
    DialogDescription,
    DialogFooter
} from "@/components/ui/dialog";
import { Field, FieldLabel, FieldError } from "@/components/ui/field";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { toast } from "sonner";

type ProfileWithGroup = Database["public"]["Tables"]["profiles"]["Row"] & {
    home_groups?: {
        location_text: string | null;
    } | null;
    father?: {
        full_name: string;
    } | null;
    mother?: {
        full_name: string;
    } | null;
    is_leader?: boolean;
};

interface HomeGroupOption {
    id: string;
    location_text: string | null;
    leader_1_id: string | null;
    leader_2_id: string | null;
    leader_1?: {
        full_name: string;
    } | null;
    leader_2?: {
        full_name: string;
    } | null;
}

/**
 * Validação de CPF brasileiro
 */
const validateCPF = (cpf: string) => {
    const cleanCPF = cpf.replace(/\D/g, "");

    if (cleanCPF.length !== 11) return false;
    if (/^(\d)\1+$/.test(cleanCPF)) return false;

    let sum = 0;
    let rest;

    for (let i = 1; i <= 9; i++) {
        sum = sum + parseInt(cleanCPF.substring(i - 1, i)) * (11 - i);
    }

    rest = (sum * 10) % 11;
    if (rest === 10 || rest === 11) rest = 0;
    if (rest !== parseInt(cleanCPF.substring(9, 10))) return false;

    sum = 0;
    for (let i = 1; i <= 10; i++) {
        sum = sum + parseInt(cleanCPF.substring(i - 1, i)) * (12 - i);
    }

    rest = (sum * 10) % 11;
    if (rest === 10 || rest === 11) rest = 0;
    if (rest !== parseInt(cleanCPF.substring(10, 11))) return false;

    return true;
};

/**
 * Auto-formatação de CPF (000.000.000-00)
 */
const formatCPF = (value: string) => {
    const clean = value.replace(/\D/g, "");
    const digits = clean.slice(0, 11);
    
    if (digits.length <= 3) {
        return digits;
    }
    if (digits.length <= 6) {
        return `${digits.slice(0, 3)}.${digits.slice(3)}`;
    }
    if (digits.length <= 9) {
        return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6)}`;
    }
    return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`;
};

/**
 * Retorna o nome amigável do grupo caseiro baseado no(s) líder(es)
 */
const getGroupLabel = (group: HomeGroupOption) => {
    const leader1 = group.leader_1?.full_name;
    const leader2 = group.leader_2?.full_name;
    
    if (leader1 && leader2) {
        return `Grupo de ${leader1} & ${leader2}`;
    }
    if (leader1) {
        return `Grupo de ${leader1}`;
    }
    if (leader2) {
        return `Grupo de ${leader2}`;
    }
    return group.location_text || `Grupo em BH (${group.id.slice(0, 5)})`;
};

/**
 * Auto-formatação de Telefone Celular
 * Apenas insere caracteres de formatação (parênteses, traço, espaços, mais), sem inserir números.
 */
const formatPhone = (value: string) => {
    const clean = value.replace(/\D/g, "");
    
    if (clean.length === 0) return "";
    
    // Caso com DDI (+55...)
    if (clean.startsWith("55") && clean.length > 10) {
        const ddi = clean.slice(0, 2);
        const ddd = clean.slice(2, 4);
        const rest = clean.slice(4);
        
        if (rest.length <= 4) {
            return `+${ddi} (${ddd}) ${rest}`;
        }
        if (rest.length <= 8) {
            return `+${ddi} (${ddd}) ${rest.slice(0, 4)}-${rest.slice(4)}`;
        }
        return `+${ddi} (${ddd}) ${rest.slice(0, 5)}-${rest.slice(5, 9)}`;
    }
    
    // Caso sem DDI (DDD + número)
    if (clean.length <= 2) {
        return `(${clean}`;
    }
    if (clean.length <= 6) {
        return `(${clean.slice(0, 2)}) ${clean.slice(2)}`;
    }
    if (clean.length <= 10) {
        return `(${clean.slice(0, 2)}) ${clean.slice(2, 6)}-${clean.slice(6)}`;
    }
    return `(${clean.slice(0, 2)}) ${clean.slice(2, 7)}-${clean.slice(7, 11)}`;
};

// Zod Schema para perfis provisórios/vinculados
const phantomUserSchema = z.object({
    registrationType: z.enum(["adult", "child"]),
    fullName: z.string().min(3, { message: "O nome deve ter pelo menos 3 caracteres." }),
    email: z.union([z.string().email({ message: "E-mail inválido." }), z.literal("")]).optional().nullable(),
    cpf: z.string().refine(validateCPF, {
        message: "CPF inválido."
    }),
    phone: z.union([
        z.string().refine((val) => val === "" || /^(?:\+55 )?\(\d{2}\) 9\d{4}-\d{4}$/.test(val), {
            message: "O telefone celular deve ser válido e conter o 9 (ex: (31) 98888-7777)."
        }),
        z.literal("")
    ]).optional().nullable(),
    birthDate: z.union([z.string().regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Data inválida (AAAA-MM-DD)." }), z.literal("")]).optional().nullable(),
    baptismDate: z.union([z.string().regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Data inválida (AAAA-MM-DD)." }), z.literal("")]).optional().nullable(),
    gender: z.union([z.enum(["masculino", "feminino", "outro"] as const), z.literal("")]).optional().nullable(),
    maritalStatus: z.union([z.enum(["solteiro", "casado", "divorciado", "viuvo"] as const), z.literal("")]).optional().nullable(),
    homeGroupId: z.union([z.string().uuid(), z.literal("")]).optional().nullable(),
    disciplerId: z.union([z.string().uuid(), z.literal("")]).optional().nullable(),
    fatherId: z.union([z.string().uuid(), z.literal("")]).optional().nullable(),
    motherId: z.union([z.string().uuid(), z.literal("")]).optional().nullable(),
}).superRefine((data, ctx) => {
    if (data.registrationType === "adult") {
        if (!data.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                message: "E-mail é obrigatório para irmãos vinculados.",
                path: ["email"],
            });
        }
        if (!data.homeGroupId) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                message: "Grupo caseiro é obrigatório para irmãos vinculados.",
                path: ["homeGroupId"],
            });
        }
        if (!data.disciplerId) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                message: "Discipulador é obrigatório para irmãos vinculados.",
                path: ["disciplerId"],
            });
        }
    } else if (data.registrationType === "child") {
        if (!data.fatherId && !data.motherId) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                message: "Filhos não batizados devem ter pelo menos o Pai ou a Mãe vinculados.",
                path: ["fatherId"],
            });
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                message: "Filhos não batizados devem ter pelo menos o Pai ou a Mãe vinculados.",
                path: ["motherId"],
            });
        }
    }

    // Validar que a data de batismo não é menor que a data de nascimento
    if (data.birthDate && data.baptismDate) {
        const birth = new Date(data.birthDate);
        const baptism = new Date(data.baptismDate);
        if (baptism < birth) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                message: "A data de batismo não pode ser anterior à data de nascimento.",
                path: ["baptismDate"],
            });
        }
    }
});

type PhantomUserValue = z.infer<typeof phantomUserSchema>;

interface MemberManagementProps {
  hideHeader?: boolean;
}

export default function MemberManagement({ hideHeader = false }: MemberManagementProps) {
    const [members, setMembers] = useState<ProfileWithGroup[]>([]);
    const [homeGroups, setHomeGroups] = useState<HomeGroupOption[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    
    // Modal states
    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [selectedMember, setSelectedMember] = useState<ProfileWithGroup | null>(null);
    const [submitting, setSubmitting] = useState(false);

    const form = useForm<PhantomUserValue>({
        resolver: zodResolver(phantomUserSchema),
        defaultValues: {
            registrationType: "adult",
            fullName: "",
            email: "",
            cpf: "",
            phone: "",
            birthDate: "",
            baptismDate: "",
            gender: "",
            maritalStatus: "",
            homeGroupId: "",
            disciplerId: "",
            fatherId: "",
            motherId: "",
        }
    });

    const registrationType = form.watch("registrationType");

    const fetchData = async () => {
        setLoading(true);
        try {
            const { data: profilesData, error: profilesError } = await supabase
                .from('profiles')
                .select('*, home_groups!profiles_home_group_id_fkey(location_text), father:profiles!father_id(full_name), mother:profiles!mother_id(full_name)')
                .order('full_name');
            
            if (profilesError) throw profilesError;

            const { data: groupsData, error: groupsError } = await supabase
                .from('home_groups')
                .select(`
                    id, 
                    location_text, 
                    leader_1_id, 
                    leader_2_id,
                    leader_1:profiles!leader_1_id(full_name),
                    leader_2:profiles!leader_2_id(full_name)
                `);
            
            if (groupsError) throw groupsError;

            // Salva os grupos caseiros disponíveis para seleção no form
            const mappedGroups = (groupsData || []).map(g => ({
                ...g,
                leader_1: Array.isArray(g.leader_1) ? (g.leader_1[0] || null) : null,
                leader_2: Array.isArray(g.leader_2) ? (g.leader_2[0] || null) : null
            }));
            setHomeGroups(mappedGroups);

            const leaderIds = new Set<string>();
            groupsData?.forEach(g => {
                if (g.leader_1_id) leaderIds.add(g.leader_1_id);
                if (g.leader_2_id) leaderIds.add(g.leader_2_id);
            });

            const enrichedMembers = (profilesData || []).map(profile => ({
                ...profile,
                is_leader: leaderIds.has(profile.id),
                father: Array.isArray(profile.father) ? (profile.father[0] || null) : null,
                mother: Array.isArray(profile.mother) ? (profile.mother[0] || null) : null
            }));

            setMembers(enrichedMembers);
        } catch (error) {
            console.error("Error fetching members:", error);
            toast.error("Erro ao carregar dados dos vinculados.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const handleAddClick = () => {
        setSelectedMember(null);
        form.reset({
            registrationType: "adult",
            fullName: "",
            email: "",
            cpf: "",
            phone: "",
            birthDate: "",
            baptismDate: "",
            gender: "",
            maritalStatus: "",
            homeGroupId: "",
            disciplerId: "",
            fatherId: "",
            motherId: "",
        });
        setIsDialogOpen(true);
    };

    const handleEditClick = (member: ProfileWithGroup) => {
        setSelectedMember(member);
        const isChild = !!(member.father_id || member.mother_id) && !member.baptism_date;
        form.reset({
            registrationType: isChild ? "child" : "adult",
            fullName: member.full_name,
            email: member.email || "",
            cpf: member.cpf || "",
            phone: member.phone || "",
            birthDate: member.birth_date || "",
            baptismDate: member.baptism_date || "",
            gender: (member.gender as any) || "",
            maritalStatus: (member.marital_status as any) || "",
            homeGroupId: member.home_group_id || "",
            disciplerId: member.discipler_id || "",
            fatherId: member.father_id || "",
            motherId: member.mother_id || "",
        });
        setIsDialogOpen(true);
    };

    const handleDeleteClick = async (id: string) => {
        if (!window.confirm("Tem certeza que deseja remover este perfil provisório? Esta ação é irreversível.")) {
            return;
        }

        const deleteOperation = async () => {
            const { error } = await supabase
                .from("profiles")
                .delete()
                .eq("id", id);
            
            if (error) throw error;
        };

        toast.promise(deleteOperation(), {
            loading: "Removendo perfil...",
            success: () => {
                fetchData();
                return "Perfil removido com sucesso!";
            },
            error: (err) => {
                console.error("Error deleting member:", err);
                return "Erro ao remover perfil provisório. Verifique suas permissões.";
            }
        });
    };

    const onSubmit = async (data: PhantomUserValue) => {
        setSubmitting(true);
        
        try {
            // Verificar duplicidade de CPF ou E-mail antes de salvar
            let query = supabase
                .from("profiles")
                .select("id, full_name, email, cpf");
                
            if (selectedMember) {
                query = query.neq("id", selectedMember.id);
            }
            
            const filters = [];
            if (data.cpf) {
                filters.push(`cpf.eq.${data.cpf}`);
            }
            if (data.registrationType === "adult" && data.email) {
                filters.push(`email.eq.${data.email}`);
            }
            
            if (filters.length > 0) {
                const { data: duplicates, error: queryError } = await query.or(filters.join(","));
                
                if (queryError) throw queryError;
                
                if (duplicates && duplicates.length > 0) {
                    const duplicateCpf = duplicates.find(d => d.cpf === data.cpf);
                    const duplicateEmail = duplicates.find(d => d.email === data.email);
                    
                    if (duplicateCpf) {
                        form.setError("cpf", {
                            type: "manual",
                            message: `CPF já cadastrado para ${duplicateCpf.full_name}.`
                        });
                    }
                    if (duplicateEmail) {
                        form.setError("email", {
                            type: "manual",
                            message: `E-mail já cadastrado para ${duplicateEmail.full_name}.`
                        });
                    }
                    
                    setSubmitting(false);
                    return;
                }
            }
        } catch (err) {
            console.error("Erro ao verificar duplicados:", err);
            toast.error("Erro ao verificar duplicidade de perfil.");
            setSubmitting(false);
            return;
        }
        
        const basePayload = {
            full_name: data.fullName,
            email: data.registrationType === "adult" ? (data.email || null) : null,
            cpf: data.cpf,
            phone: data.registrationType === "adult" ? (data.phone || null) : null,
            birth_date: data.birthDate || null,
            baptism_date: data.registrationType === "adult" ? (data.baptismDate || null) : null, // não batizado se for criança
            gender: data.gender || null,
            marital_status: data.registrationType === "adult" ? (data.maritalStatus || null) : null,
            home_group_id: data.homeGroupId || null,
            discipler_id: data.registrationType === "adult" ? (data.disciplerId || null) : null,
            father_id: data.fatherId || null,
            mother_id: data.motherId || null,
            // Certificamos que um perfil provisório criado pela liderança nunca tem acesso associado por padrão
            user_id: selectedMember ? selectedMember.user_id : null,
        };

        const saveOperation = async () => {
            if (selectedMember) {
                // Atualização
                const { error } = await supabase
                    .from("profiles")
                    .update(basePayload)
                    .eq("id", selectedMember.id);
                
                if (error) throw error;
            } else {
                // Inserção de novo perfil provisório com placeholders para as colunas NOT NULL
                const insertPayload = {
                    ...basePayload,
                    occupation: "Não informado",
                    education_level: "Não informado",
                    employment_status: "Não informado",
                    household_income: "Não informado",
                    housing_status: "Não informado",
                    drivers_license: "Não informado",
                };

                const { error } = await supabase
                    .from("profiles")
                    .insert([insertPayload]);
                
                if (error) throw error;
            }
        };

        toast.promise(saveOperation(), {
            loading: selectedMember ? "Atualizando perfil..." : "Criando perfil provisório...",
            success: () => {
                setIsDialogOpen(false);
                fetchData();
                return selectedMember ? "Perfil atualizado com sucesso!" : "Perfil provisório criado!";
            },
            error: (err) => {
                console.error("Error saving member:", err);
                return "Erro ao salvar perfil. Verifique suas permissões ou se o CPF/E-mail já está em uso.";
            },
            finally: () => {
                setSubmitting(false);
            }
        });
    };

    const filteredMembers = members.filter(m => 
        m.full_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        m.phone?.includes(searchQuery) ||
        m.cpf?.includes(searchQuery) ||
        m.address_neighborhood?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        m.email?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const getInitials = (name: string) => {
        return name
            .split(" ")
            .filter(Boolean)
            .map(n => n[0])
            .join("")
            .toUpperCase()
            .slice(0, 2);
    };

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            {!hideHeader ? (
                <header className="flex flex-col md:flex-row md:items-center justify-between gap-6 pb-6 border-b border-border">
                    <div>
                        <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
                            <UsersIcon className="w-8 h-8 text-primary" />
                            Gestão de Vinculados
                        </h1>
                        <p className="text-muted-foreground mt-1">Lista completa de irmãos e vinculados da Oikos na cidade.</p>
                    </div>
                    
                    <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
                        <div className="relative w-full sm:w-80 group">
                            <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                            <Input 
                                placeholder="Buscar por nome, CPF, e-mail..." 
                                className="pl-10 bg-card/30 backdrop-blur-sm border-border/50 rounded-xl focus:border-primary/50 transition-all focus:ring-2 focus:ring-primary/20"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>
                        
                        <Button 
                            onClick={handleAddClick}
                            className="bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 rounded-xl flex items-center gap-2"
                        >
                            <PlusIcon className="w-4 h-4" />
                            Criar Vinculado
                        </Button>
                    </div>
                </header>
            ) : (
                <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 pb-4 border-b border-border/50">
                    <div>
                        <h2 className="text-lg font-bold text-foreground">Lista de Vinculados</h2>
                        <p className="text-xs text-muted-foreground">Gerencie as fichas dos discípulos e seus dados.</p>
                    </div>
                    <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                        <div className="relative w-full sm:w-64 group">
                            <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                            <Input 
                                placeholder="Buscar por nome, CPF, e-mail..." 
                                className="pl-10 bg-card/30 backdrop-blur-sm border-border/50 rounded-xl h-9 text-xs"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>
                        
                        <Button 
                            onClick={handleAddClick}
                            size="sm"
                            className="bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 rounded-xl flex items-center gap-2 h-9 px-3 text-xs font-semibold"
                        >
                            <PlusIcon className="w-4 h-4" />
                            Criar Vinculado
                        </Button>
                    </div>
                </div>
            )}

            {loading ? (
                <div className="flex flex-col items-center justify-center py-24 gap-4">
                    <Loader2 className="w-12 h-12 animate-spin text-primary" />
                    <p className="text-muted-foreground font-medium animate-pulse">Carregando membros...</p>
                </div>
            ) : filteredMembers.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-24 text-center space-y-4 bg-muted/20 rounded-3xl border border-dashed border-border/50">
                    <div className="w-20 h-20 rounded-full bg-muted/50 flex items-center justify-center shadow-inner">
                        <SearchIcon className="w-10 h-10 text-muted-foreground/30" />
                    </div>
                    <div>
                        <h3 className="text-xl font-bold text-foreground">Nenhum irmão encontrado</h3>
                        <p className="text-muted-foreground mt-1 max-w-sm mx-auto">Tente ajustar sua busca ou cadastrar um novo vinculado.</p>
                    </div>
                </div>
            ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 pb-12">
                    {filteredMembers.map((member) => (
                        <Card key={member.id} className="border-border/50 bg-card/30 backdrop-blur-sm shadow-sm hover:shadow-xl hover:border-primary/30 transition-all duration-500 group rounded-2xl overflow-hidden flex flex-col">
                            <CardHeader className="flex flex-row items-center gap-4 pb-4 px-5 pt-5 shrink-0">
                                <Avatar className="size-14 border border-border shadow-sm group-hover:scale-110 transition-transform duration-500">
                                    <AvatarImage src={member.avatar_url || undefined} className="object-cover" />
                                    <AvatarFallback className="bg-primary/20 text-primary font-bold text-lg">
                                        {getInitials(member.full_name)}
                                    </AvatarFallback>
                                </Avatar>
                                <div className="flex-1 min-w-0">
                                    <CardTitle className="text-lg font-bold truncate group-hover:text-primary transition-colors leading-tight">
                                        {member.full_name}
                                    </CardTitle>
                                    <div className="flex flex-wrap gap-1.5 mt-2">
                                        {member.is_dev && (
                                            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-blue-500/10 text-blue-500 border border-blue-500/20">
                                                Dev
                                            </span>
                                        )}
                                        {member.is_presbyter && (
                                            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-purple-500/10 text-purple-500 border border-purple-500/20">
                                                Presbítero
                                            </span>
                                        )}
                                        {member.is_deacon && (
                                            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-amber-500/10 text-amber-500 border border-amber-500/20">
                                                Diácono
                                            </span>
                                        )}
                                        {member.is_leader && (
                                            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-emerald-500/10 text-emerald-500 border border-emerald-500/20">
                                                Líder GC
                                            </span>
                                        )}
                                        {!member.baptism_date && (member.father_id || member.mother_id) && (
                                            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-amber-500/10 text-amber-500 border border-amber-500/20">
                                                Filho Não Batizado
                                            </span>
                                        )}
                                        {!member.user_id ? (
                                            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-zinc-500/10 text-zinc-500 border border-zinc-500/20 dark:bg-zinc-400/10 dark:text-zinc-400 dark:border-zinc-400/20">
                                                Pendente de Login
                                            </span>
                                        ) : (
                                            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-sky-500/10 text-sky-500 border border-sky-500/20">
                                                Conta Ativa
                                            </span>
                                        )}
                                    </div>
                                </div>

                                {!member.user_id && (
                                    <div className="flex items-center gap-1 self-start">
                                        <Button
                                            variant="ghost"
                                            size="icon"
                                            className="h-8 w-8 rounded-lg hover:bg-zinc-500/10 text-muted-foreground hover:text-foreground shrink-0 cursor-pointer"
                                            onClick={() => handleEditClick(member)}
                                            title="Editar Perfil Vinculado"
                                        >
                                            <Edit2Icon className="w-3.5 h-3.5" />
                                        </Button>
                                        <Button
                                            variant="ghost"
                                            size="icon"
                                            className="h-8 w-8 rounded-lg hover:bg-red-500/10 text-muted-foreground hover:text-red-500 shrink-0 cursor-pointer"
                                            onClick={() => handleDeleteClick(member.id)}
                                            title="Remover Perfil Vinculado"
                                        >
                                            <Trash2Icon className="w-3.5 h-3.5" />
                                        </Button>
                                    </div>
                                )}
                            </CardHeader>
                            <CardContent className="space-y-4 px-5 pb-5 pt-2 flex-1 flex flex-col justify-between">
                                <div className="grid grid-cols-1 gap-3 text-sm">
                                    {member.cpf && (
                                        <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors duration-300">
                                            <div className="w-8 h-8 rounded-lg bg-muted/50 flex items-center justify-center shrink-0">
                                                <FileText className="w-4 h-4 text-primary/70" />
                                            </div>
                                            <span className="truncate font-medium">CPF: {member.cpf}</span>
                                        </div>
                                    )}

                                    {member.email && (
                                        <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors duration-300">
                                            <div className="w-8 h-8 rounded-lg bg-muted/50 flex items-center justify-center shrink-0">
                                                <MailIcon className="w-4 h-4 text-primary/70" />
                                            </div>
                                            <span className="truncate font-medium">{member.email}</span>
                                        </div>
                                    )}

                                    <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors duration-300">
                                        <div className="w-8 h-8 rounded-lg bg-muted/50 flex items-center justify-center shrink-0">
                                            <PhoneIcon className="w-4 h-4 text-primary/70" />
                                        </div>
                                        <span className="font-medium">{member.phone || "Não informado"}</span>
                                    </div>
                                    
                                    <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors duration-300">
                                        <div className="w-8 h-8 rounded-lg bg-muted/50 flex items-center justify-center shrink-0">
                                            <MapPinIcon className="w-4 h-4 text-primary/70" />
                                        </div>
                                        <span className="truncate font-medium">
                                            {member.home_groups?.location_text || "Sem Grupo Caseiro"}
                                        </span>
                                    </div>

                                    {(member.father || member.mother) && (
                                        <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors duration-300">
                                            <div className="w-8 h-8 rounded-lg bg-muted/50 flex items-center justify-center shrink-0">
                                                <HeartIcon className="w-4 h-4 text-primary/70" />
                                            </div>
                                            <span className="truncate font-medium text-xs">
                                                {member.father && `Pai: ${member.father.full_name}`}
                                                {member.father && member.mother && ' | '}
                                                {member.mother && `Mãe: ${member.mother.full_name}`}
                                            </span>
                                        </div>
                                    )}

                                    {member.address_neighborhood && (
                                        <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors duration-300">
                                            <div className="w-8 h-8 rounded-lg bg-muted/50 flex items-center justify-center shrink-0">
                                                <HomeIcon className="w-4 h-4 text-primary/70" />
                                            </div>
                                            <span className="truncate font-medium">
                                                {member.address_neighborhood}, {member.address_city}
                                            </span>
                                        </div>
                                    )}
                                </div>
                                
                                <div className="pt-4 mt-2 border-t border-border/50 flex items-center justify-between text-[10px] text-muted-foreground font-bold uppercase tracking-widest opacity-60">
                                    <div className="flex items-center gap-1.5">
                                        <CalendarIcon className="w-3 h-3" />
                                        Desde {member.created_at ? new Date(member.created_at).toLocaleDateString() : "N/A"}
                                    </div>
                                    {member.gender && (
                                        <div className="capitalize">
                                            {member.gender}
                                        </div>
                                    )}
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}

            {/* Modal Dialog para Cadastro/Edição de Vinculados */}
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                <DialogContent className="sm:max-w-xl rounded-3xl border-border/50 bg-card/95 backdrop-blur-xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle className="text-xl font-bold flex items-center gap-2">
                            <UserCheckIcon className="w-5 h-5 text-primary" />
                            {selectedMember ? "Editar Perfil Vinculado" : "Criar Irmão Vinculado"}
                        </DialogTitle>
                        <DialogDescription>
                            Insira os dados demográficos básicos. Perfis provisórios servem para controle demográfico e serão vinculados à conta de acesso correspondente.
                        </DialogDescription>
                    </DialogHeader>

                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6 pt-4">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {/* Tipo de Cadastro */}
                            <div className="md:col-span-2">
                                <Controller
                                    name="registrationType"
                                    control={form.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>Tipo de Cadastro</FieldLabel>
                                            <select
                                                {...field}
                                                className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                            >
                                                <option value="adult">Adulto / Irmão Vinculado</option>
                                                <option value="child">Filho Não Batizado (Criança)</option>
                                            </select>
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>

                            {/* Nome Completo */}
                            <div className="md:col-span-2">
                                <Controller
                                    name="fullName"
                                    control={form.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>Nome Completo*</FieldLabel>
                                            <Input 
                                                {...field}
                                                placeholder="Ex: Pedro de Souza"
                                                className="bg-background/50 rounded-xl"
                                                autoComplete="off"
                                            />
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>

                            {/* CPF */}
                            <div>
                                <Controller
                                    name="cpf"
                                    control={form.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>CPF*</FieldLabel>
                                            <Input 
                                                {...field}
                                                placeholder="Ex: 123.456.789-00"
                                                className="bg-background/50 rounded-xl"
                                                autoComplete="off"
                                                onChange={(e) => {
                                                    const formatted = formatCPF(e.target.value);
                                                    field.onChange(formatted);
                                                }}
                                            />
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>

                            {/* E-mail (Apenas para Adultos) */}
                            {registrationType === "adult" && (
                                <div>
                                    <Controller
                                        name="email"
                                        control={form.control}
                                        render={({ field, fieldState }) => (
                                            <Field data-invalid={fieldState.invalid}>
                                                <FieldLabel>E-mail*</FieldLabel>
                                                <Input 
                                                    {...field}
                                                    value={field.value ?? ""}
                                                    type="email"
                                                    placeholder="Ex: pedro@email.com"
                                                    className="bg-background/50 rounded-xl"
                                                    autoComplete="off"
                                                />
                                                <FieldError errors={[fieldState.error]} />
                                            </Field>
                                        )}
                                    />
                                </div>
                            )}

                            {/* Telefone (Apenas para Adultos) */}
                            {registrationType === "adult" && (
                                <div>
                                    <Controller
                                        name="phone"
                                        control={form.control}
                                        render={({ field, fieldState }) => (
                                            <Field data-invalid={fieldState.invalid}>
                                                <FieldLabel>Telefone (opcional)</FieldLabel>
                                                <Input 
                                                    {...field}
                                                    value={field.value ?? ""}
                                                    placeholder="Ex: +55 (31) 98888-8888"
                                                    className="bg-background/50 rounded-xl"
                                                    autoComplete="off"
                                                    onChange={(e) => {
                                                        const formatted = formatPhone(e.target.value);
                                                        field.onChange(formatted);
                                                    }}
                                                />
                                                <FieldError errors={[fieldState.error]} />
                                            </Field>
                                        )}
                                    />
                                </div>
                            )}

                            {/* Gênero */}
                            <div>
                                <Controller
                                    name="gender"
                                    control={form.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>Gênero</FieldLabel>
                                            <select
                                                {...field}
                                                value={field.value || ""}
                                                className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                            >
                                                <option value="">Selecione...</option>
                                                <option value="masculino">Masculino</option>
                                                <option value="feminino">Feminino</option>
                                                <option value="outro">Outro</option>
                                            </select>
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>

                            {/* Estado Civil (Apenas para Adultos) */}
                            {registrationType === "adult" && (
                                <div>
                                    <Controller
                                        name="maritalStatus"
                                        control={form.control}
                                        render={({ field, fieldState }) => (
                                            <Field data-invalid={fieldState.invalid}>
                                                <FieldLabel>Estado Civil</FieldLabel>
                                                <select
                                                    {...field}
                                                    value={field.value || ""}
                                                    className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                                >
                                                    <option value="">Selecione...</option>
                                                    <option value="solteiro">Solteiro(a)</option>
                                                    <option value="casado">Casado(a)</option>
                                                    <option value="divorciado">Divorciado(a)</option>
                                                    <option value="viuvo">Viúvo(a)</option>
                                                </select>
                                                <FieldError errors={[fieldState.error]} />
                                            </Field>
                                        )}
                                    />
                                </div>
                            )}

                            {/* Data de Nascimento */}
                            <div>
                                <Controller
                                    name="birthDate"
                                    control={form.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>Data de Nascimento</FieldLabel>
                                            <Input 
                                                {...field}
                                                type="date"
                                                className="bg-background/50 rounded-xl"
                                                value={field.value || ""}
                                            />
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>

                            {/* Data de Batismo (Apenas para Adultos) */}
                            {registrationType === "adult" && (
                                <div>
                                    <Controller
                                        name="baptismDate"
                                        control={form.control}
                                        render={({ field, fieldState }) => (
                                            <Field data-invalid={fieldState.invalid}>
                                                <FieldLabel>Data de Batismo</FieldLabel>
                                                <Input 
                                                    {...field}
                                                    type="date"
                                                    className="bg-background/50 rounded-xl"
                                                    value={field.value || ""}
                                                />
                                                <FieldError errors={[fieldState.error]} />
                                            </Field>
                                        )}
                                    />
                                </div>
                            )}

                            {/* Grupo Caseiro */}
                            <div>
                                <Controller
                                    name="homeGroupId"
                                    control={form.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>Grupo Caseiro{registrationType === "adult" ? "*" : ""}</FieldLabel>
                                            <select
                                                {...field}
                                                value={field.value || ""}
                                                className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                            >
                                                <option value="">{registrationType === "adult" ? "Selecione o Grupo Caseiro..." : "Sem Grupo Caseiro"}</option>
                                                {homeGroups.map(group => (
                                                    <option key={group.id} value={group.id}>
                                                        {getGroupLabel(group)}
                                                    </option>
                                                ))}
                                            </select>
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>

                            {/* Discipulador (Apenas para Adultos) */}
                            {registrationType === "adult" && (
                                <div>
                                    <Controller
                                        name="disciplerId"
                                        control={form.control}
                                        render={({ field, fieldState }) => (
                                            <Field data-invalid={fieldState.invalid}>
                                                <FieldLabel>Discipulador*</FieldLabel>
                                                <select
                                                    {...field}
                                                    value={field.value || ""}
                                                    className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                                >
                                                    <option value="">Selecione o Discipulador...</option>
                                                    {members
                                                        .filter(m => !selectedMember || m.id !== selectedMember.id)
                                                        .map(member => (
                                                            <option key={member.id} value={member.id}>
                                                                {member.full_name}
                                                            </option>
                                                        ))
                                                    }
                                                </select>
                                                <FieldError errors={[fieldState.error]} />
                                            </Field>
                                        )}
                                    />
                                </div>
                            )}

                            {/* Filiação: Pai (Apenas para Crianças) */}
                            {registrationType === "child" && (
                                <div>
                                    <Controller
                                        name="fatherId"
                                        control={form.control}
                                        render={({ field, fieldState }) => (
                                            <Field data-invalid={fieldState.invalid}>
                                                <FieldLabel>Pai* (Pelo menos Pai ou Mãe)</FieldLabel>
                                                <select
                                                    {...field}
                                                    value={field.value || ""}
                                                    className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                                >
                                                    <option value="">Selecione o Pai...</option>
                                                    {members
                                                        .filter(m => !selectedMember || m.id !== selectedMember.id)
                                                        .map(member => (
                                                            <option key={member.id} value={member.id}>
                                                                {member.full_name}
                                                            </option>
                                                        ))
                                                    }
                                                </select>
                                                <FieldError errors={[fieldState.error]} />
                                            </Field>
                                        )}
                                    />
                                </div>
                            )}

                            {/* Filiação: Mãe (Apenas para Crianças) */}
                            {registrationType === "child" && (
                                <div>
                                    <Controller
                                        name="motherId"
                                        control={form.control}
                                        render={({ field, fieldState }) => (
                                            <Field data-invalid={fieldState.invalid}>
                                                <FieldLabel>Mãe* (Pelo menos Pai ou Mãe)</FieldLabel>
                                                <select
                                                    {...field}
                                                    value={field.value || ""}
                                                    className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                                >
                                                    <option value="">Selecione a Mãe...</option>
                                                    {members
                                                        .filter(m => !selectedMember || m.id !== selectedMember.id)
                                                        .map(member => (
                                                            <option key={member.id} value={member.id}>
                                                                {member.full_name}
                                                            </option>
                                                        ))
                                                    }
                                                </select>
                                                <FieldError errors={[fieldState.error]} />
                                            </Field>
                                        )}
                                    />
                                </div>
                            )}
                        </div>

                        <DialogFooter className="gap-2 sm:gap-0 mt-6 pt-4 border-t border-border/50">
                            <Button 
                                type="button" 
                                variant="outline" 
                                className="rounded-xl"
                                onClick={() => setIsDialogOpen(false)}
                                disabled={submitting}
                            >
                                Cancelar
                            </Button>
                            <Button 
                                type="submit" 
                                className="bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 rounded-xl"
                                disabled={submitting}
                            >
                                {submitting ? (
                                    <>
                                        <Loader2 className="w-4 h-4 animate-spin mr-2" />
                                        Salvando...
                                    </>
                                ) : (
                                    "Salvar Perfil"
                                )}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>
        </div>
    );
}
