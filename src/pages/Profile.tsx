import { useEffect, useState, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { 
    UserIcon, 
    MailIcon, 
    LogOutIcon, 
    ShieldIcon,
    MapPinIcon,
    PhoneIcon,
    CalendarIcon,
    UsersIcon,
    HeartIcon,
    FingerprintIcon,
    PencilIcon,
    CameraIcon,
    Loader2Icon,
    SearchIcon
} from "lucide-react";
import supabase from "@/lib/supabase";
import { ImageCropper } from "@/components/ImageCropper";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Skeleton } from "@/components/ui/skeleton";
import { 
    Dialog, 
    DialogContent, 
    DialogDescription, 
    DialogFooter, 
    DialogHeader, 
    DialogTitle 
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Field, FieldGroup, FieldLabel } from "@/components/ui/field";
import { 
    Combobox, 
    ComboboxContent, 
    ComboboxEmpty, 
    ComboboxInput, 
    ComboboxItem, 
    ComboboxList 
} from "@/components/ui/combobox";
import { toast } from "sonner";
import { format } from "date-fns";
import { ptBR } from "date-fns/locale";
import { cn } from "@/lib/utils";

interface UserProfile {
    id: string;
    full_name: string;
    email: string;
    is_dev: boolean;
    is_presbyter: boolean;
    is_deacon: boolean;
    avatar_url?: string;
    cpf?: string;
    birth_date?: string;
    gender?: string;
    marital_status?: string;
    phone?: string;
    address_street?: string;
    address_number?: string;
    address_complement?: string;
    address_neighborhood?: string;
    address_city?: string;
    address_state?: string;
    address_zip_code?: string;
    baptism_date?: string;
    home_group_id?: string;
    discipler_id?: string;
    spouse_id?: string;
    father_id?: string;
    mother_id?: string;
    home_group_name?: string;
    discipler_name?: string;
    spouse_name?: string;
    father_name?: string;
    mother_name?: string;
}

interface MemberOption {
    id: string;
    full_name: string;
}

export default function Profile() {
    const navigate = useNavigate();
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [isEditingContact, setIsEditingContact] = useState(false);
    const [isEditingAddress, setIsEditingAddress] = useState(false);
    const [isEditingFamily, setIsEditingFamily] = useState(false);
    const [isEditingAvatar, setIsEditingAvatar] = useState(false);
    const [isCropping, setIsCropping] = useState(false);
    const [avatarPreview, setAvatarPreview] = useState<string | null>(null);
    const [avatarFile, setAvatarFile] = useState<File | null>(null);

    // Member selection states
    const [allMembers, setAllMembers] = useState<MemberOption[]>([]);
    const [loadingMembers, setLoadingMembers] = useState(false);

    // Form states
    const [editForm, setEditForm] = useState<Partial<UserProfile>>({});

    const fetchProfile = useCallback(async () => {
        try {
            const { data: { session } } = await supabase.auth.getSession();
            if (!session?.user) {
                navigate("/entrar");
                return;
            }

            const { data, error } = await supabase
                .from("profiles")
                .select(`
                    *,
                    home_groups:home_group_id (location_text),
                    discipler:discipler_id (full_name),
                    spouse:spouse_id (full_name),
                    father:father_id (full_name),
                    mother:mother_id (full_name)
                `)
                .eq("user_id", session.user.id)
                .single();

            if (error) throw error;
            if (data) {
                setProfile({
                    id: data.id,
                    full_name: data.full_name,
                    email: session.user.email || "",
                    is_dev: !!data.is_dev,
                    is_presbyter: !!data.is_presbyter,
                    is_deacon: !!data.is_deacon,
                    avatar_url: data.avatar_url || undefined,
                    cpf: data.cpf || undefined,
                    birth_date: data.birth_date || undefined,
                    gender: data.gender || undefined,
                    marital_status: data.marital_status || undefined,
                    phone: data.phone || undefined,
                    address_street: data.address_street || undefined,
                    address_number: data.address_number || undefined,
                    address_complement: data.address_complement || undefined,
                    address_neighborhood: data.address_neighborhood || undefined,
                    address_city: data.address_city || undefined,
                    address_state: data.address_state || undefined,
                    address_zip_code: data.address_zip_code || undefined,
                    baptism_date: data.baptism_date || undefined,
                    home_group_id: data.home_group_id || undefined,
                    discipler_id: data.discipler_id || undefined,
                    spouse_id: data.spouse_id || undefined,
                    father_id: data.father_id || undefined,
                    mother_id: data.mother_id || undefined,
                    home_group_name: (data.home_groups as any)?.location_text,
                    discipler_name: (data.discipler as any)?.full_name,
                    spouse_name: (data.spouse as any)?.full_name,
                    father_name: (data.father as any)?.full_name,
                    mother_name: (data.mother as any)?.full_name
                });
            }
        } catch (error) {
            console.error("Erro ao carregar perfil:", error);
        } finally {
            setLoading(false);
        }
    }, [navigate]);

    const fetchAllMembers = useCallback(async () => {
        if (allMembers.length > 0) return;
        setLoadingMembers(true);
        try {
            const { data, error } = await supabase
                .from("profiles")
                .select("id, full_name")
                .order("full_name");
            if (error) throw error;
            setAllMembers(data || []);
        } catch (error) {
            console.error("Erro ao carregar membros:", error);
        } finally {
            setLoadingMembers(false);
        }
    }, [allMembers.length]);

    useEffect(() => {
        fetchProfile();
    }, [fetchProfile]);

    const handleSaveProfile = async (updates: Partial<UserProfile>) => {
        try {
            setSaving(true);
            const { data: { session } } = await supabase.auth.getSession();
            if (!session?.user) return;

            const { error } = await supabase
                .from("profiles")
                .update(updates)
                .eq("user_id", session.user.id);

            if (error) throw error;
            
            toast.success("Perfil atualizado com sucesso!");
            await fetchProfile();
            setIsEditingContact(false);
            setIsEditingAddress(false);
            setIsEditingFamily(false);
        } catch (error) {
            console.error("Erro ao salvar perfil:", error);
            toast.error("Erro ao salvar as alterações.");
        } finally {
            setSaving(false);
        }
    };


    const handleAvatarSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (!file) return;
        setAvatarPreview(URL.createObjectURL(file));
        setIsCropping(true);
    };

    const handleCropComplete = (croppedBlob: Blob) => {
        if (!avatarPreview) return;
        const file = new File([croppedBlob], "avatar.jpg", { type: "image/jpeg" });
        setAvatarFile(file);
        setAvatarPreview(URL.createObjectURL(croppedBlob));
        setIsCropping(false);
    };

    const handleAvatarUpload = async () => {
        if (!avatarFile) return;

        try {
            setSaving(true);
            const { data: { session } } = await supabase.auth.getSession();
            if (!session?.user) return;

            // 1. Delete old avatar if exists
            if (profile?.avatar_url) {
                try {
                    // Extract path from URL: .../storage/v1/object/public/avatars/PATH
                    const urlParts = profile.avatar_url.split('/avatars/');
                    if (urlParts.length > 1) {
                        const oldPath = urlParts[1];
                        await supabase.storage.from('avatars').remove([oldPath]);
                    }
                } catch (deleteError) {
                    // Log error but don't block upload if deletion fails
                    console.error("Erro ao deletar avatar antigo:", deleteError);
                }
            }

            const fileExt = avatarFile.name.split('.').pop();
            const fileName = `${session.user.id}-${Date.now()}.${fileExt}`;
            const filePath = `${fileName}`;

            const { error: uploadError } = await supabase.storage
                .from('avatars')
                .upload(filePath, avatarFile);

            if (uploadError) throw uploadError;

            const { data: { publicUrl } } = supabase.storage
                .from('avatars')
                .getPublicUrl(filePath);

            const { error: updateError } = await supabase
                .from("profiles")
                .update({ avatar_url: publicUrl })
                .eq("user_id", session.user.id);

            if (updateError) throw updateError;

            toast.success("Foto de perfil atualizada!");
            await fetchProfile();
            setIsEditingAvatar(false);
            setAvatarPreview(null);
            setAvatarFile(null);
        } catch (error) {
            console.error("Erro no upload da foto:", error);
            toast.error("Erro ao carregar a foto.");
        } finally {
            setSaving(false);
        }
    };

    const handleLogout = async () => {
        await supabase.auth.signOut();
        navigate("/entrar");
    };

    if (loading) {
        return (
            <div className="space-y-8 animate-in fade-in duration-500">
                <Skeleton className="h-10 w-48" />
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div className="lg:col-span-1 space-y-4">
                        <Skeleton className="h-[400px] w-full rounded-2xl" />
                    </div>
                    <div className="lg:col-span-2 space-y-4">
                        <Skeleton className="h-[600px] w-full rounded-2xl" />
                    </div>
                </div>
            </div>
        );
    }

    if (!profile) return null;

    const getRole = () => {
        const roles = [];
        if (profile.is_dev) roles.push("Desenvolvedor");
        if (profile.is_presbyter) roles.push("Presbítero");
        if (profile.is_deacon) roles.push("Diácono");
        if (roles.length === 0) roles.push("Membro");
        return roles.join(" • ");
    };

    const getInitials = (name: string) => {
        return name.split(" ").filter(Boolean).map((n) => n[0]).join("").toUpperCase().substring(0, 2);
    };

    const formatDate = (dateString?: string) => {
        if (!dateString) return "Não informado";
        try {
            return format(new Date(dateString), "dd 'de' MMMM 'de' yyyy", { locale: ptBR });
        } catch {
            return dateString;
        }
    };

    const InfoSection = ({ title, icon: Icon, children, onEdit }: { title: string, icon: any, children: React.ReactNode, onEdit?: () => void }) => (
        <div className="space-y-4">
            <div className="flex items-center justify-between text-primary">
                <div className="flex items-center gap-2">
                    <Icon className="size-5" />
                    <h2 className="text-lg font-bold tracking-tight">{title}</h2>
                </div>
                {onEdit && (
                    <Button variant="ghost" size="sm" className="h-8 gap-2 text-xs font-semibold hover:bg-primary/10 rounded-full" onClick={onEdit}>
                        <PencilIcon className="size-3" />
                        Editar
                    </Button>
                )}
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-8 gap-y-4 bg-muted/20 p-5 rounded-2xl border border-border/50">
                {children}
            </div>
        </div>
    );

    const InfoItem = ({ label, value, icon: ItemIcon }: { label: string, value: string | undefined | null, icon?: any }) => (
        <div className="space-y-1 min-w-0">
            <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-widest">{label}</p>
            <div className="flex items-center gap-2">
                {ItemIcon && <ItemIcon className="size-3.5 text-muted-foreground shrink-0" />}
                <p className="text-sm font-medium truncate text-foreground">
                    {value || "Não informado"}
                </p>
            </div>
        </div>
    );

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="border-b border-border pb-6">
                <h1 className="text-3xl font-bold tracking-tight">Meu Perfil</h1>
                <p className="text-muted-foreground mt-1">Gerencie suas informações pessoais e de vínculo com a igreja.</p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <Card className="lg:col-span-1 border-border bg-card/30 backdrop-blur-sm h-fit rounded-3xl overflow-hidden shadow-sm">
                    <CardHeader className="pb-8 pt-12 relative overflow-hidden">
                        <div className="absolute top-0 left-0 w-full h-32 bg-linear-to-br from-primary/20 to-primary/5" />
                        <div className="relative flex flex-col items-center gap-4">
                            <div className="relative group">
                                <Avatar className="size-32 border-4 border-background shadow-2xl transition-transform hover:scale-105 duration-500">
                                    <AvatarImage src={profile.avatar_url} />
                                    <AvatarFallback className="text-4xl bg-primary text-primary-foreground font-bold">
                                        {getInitials(profile.full_name)}
                                    </AvatarFallback>
                                </Avatar>
                                <div 
                                    className="absolute inset-0 flex items-center justify-center bg-black/40 text-white opacity-0 group-hover:opacity-100 transition-all rounded-full cursor-pointer backdrop-blur-[2px]"
                                    onClick={() => {
                                        setAvatarPreview(null);
                                        setAvatarFile(null);
                                        setIsEditingAvatar(true);
                                    }}
                                >
                                    <CameraIcon className="size-8" />
                                </div>
                            </div>
                            <div className="text-center space-y-2 px-4">
                                <CardTitle className="text-2xl font-bold leading-tight">{profile.full_name}</CardTitle>
                                <div className="bg-primary/10 text-primary px-4 py-1.5 rounded-full text-xs font-bold inline-flex items-center gap-2 border border-primary/20">
                                    <ShieldIcon className="size-3" />
                                    {getRole()}
                                </div>
                            </div>
                        </div>
                    </CardHeader>
                    <CardContent className="space-y-4 pt-4 px-6 pb-8">
                        <Button 
                            variant="destructive" 
                            className="w-full gap-2 font-bold shadow-lg shadow-destructive/10 rounded-xl py-6"
                            onClick={handleLogout}
                        >
                            <LogOutIcon className="size-4" />
                            Sair da Conta
                        </Button>
                        <p className="text-[10px] text-center text-muted-foreground uppercase tracking-widest font-bold opacity-50">
                            ID: {profile.id}
                        </p>
                    </CardContent>
                </Card>

                <div className="lg:col-span-2 space-y-8">
                    <Card className="border-border bg-card/30 backdrop-blur-sm rounded-3xl shadow-sm overflow-hidden">
                        <CardContent className="p-6 md:p-10 space-y-12">
                            <InfoSection title="Informações Pessoais" icon={UserIcon}>
                                <InfoItem label="Nome Completo" value={profile.full_name} />
                                <InfoItem label="CPF" value={profile.cpf} icon={FingerprintIcon} />
                                <InfoItem label="Nascimento" value={formatDate(profile.birth_date)} icon={CalendarIcon} />
                                <InfoItem label="Gênero" value={profile.gender} />
                                <InfoItem label="Estado Civil" value={profile.marital_status} icon={HeartIcon} />
                            </InfoSection>

                            <InfoSection title="Vínculos Familiares" icon={HeartIcon} onEdit={() => { 
                                setEditForm({ 
                                    spouse_id: profile.spouse_id, 
                                    father_id: profile.father_id, 
                                    mother_id: profile.mother_id 
                                }); 
                                fetchAllMembers();
                                setIsEditingFamily(true); 
                            }}>
                                <InfoItem label="Cônjuge" value={profile.spouse_name} icon={HeartIcon} />
                                <div className="sm:col-span-2 grid grid-cols-1 sm:grid-cols-2 gap-6">
                                    <InfoItem label="Pai" value={profile.father_name} icon={UserIcon} />
                                    <InfoItem label="Mãe" value={profile.mother_name} icon={UserIcon} />
                                </div>
                            </InfoSection>

                            <InfoSection title="Contato" icon={PhoneIcon} onEdit={() => { setEditForm({ phone: profile.phone }); setIsEditingContact(true); }}>
                                <InfoItem label="E-mail" value={profile.email} icon={MailIcon} />
                                <InfoItem label="Telefone" value={profile.phone} icon={PhoneIcon} />
                            </InfoSection>

                            <InfoSection title="Endereço" icon={MapPinIcon} onEdit={() => { setEditForm({ address_street: profile.address_street, address_number: profile.address_number, address_complement: profile.address_complement, address_neighborhood: profile.address_neighborhood, address_city: profile.address_city, address_state: profile.address_state, address_zip_code: profile.address_zip_code }); setIsEditingAddress(true); }}>
                                <div className="sm:col-span-2 grid grid-cols-1 sm:grid-cols-2 gap-6">
                                    <InfoItem label="Rua" value={profile.address_street} />
                                    <div className="grid grid-cols-2 gap-4">
                                        <InfoItem label="Número" value={profile.address_number} />
                                        <InfoItem label="Complemento" value={profile.address_complement} />
                                    </div>
                                    <InfoItem label="Bairro" value={profile.address_neighborhood} />
                                    <div className="grid grid-cols-2 gap-4">
                                        <InfoItem label="Cidade" value={profile.address_city} />
                                        <InfoItem label="Estado" value={profile.address_state} />
                                    </div>
                                    <InfoItem label="CEP" value={profile.address_zip_code} />
                                </div>
                            </InfoSection>

                            <InfoSection title="Vida Eclesiástica" icon={UsersIcon}>
                                <InfoItem label="Batismo" value={formatDate(profile.baptism_date)} icon={CalendarIcon} />
                                <InfoItem label="Grupo Caseiro" value={profile.home_group_name} icon={UsersIcon} />
                                <InfoItem label="Discipulador" value={profile.discipler_name} icon={UserIcon} />
                            </InfoSection>
                        </CardContent>
                        <CardFooter className="bg-primary/5 p-8 flex items-center gap-4 border-t border-border/50">
                            <div className="bg-primary/20 p-3 rounded-2xl">
                                <ShieldIcon className="size-6 text-primary" />
                            </div>
                            <div className="space-y-1">
                                <p className="text-sm font-bold text-foreground">Privacidade e Proteção de Dados</p>
                                <p className="text-xs text-muted-foreground leading-relaxed">
                                    Suas informações são tratadas com segurança absoluta e de acordo com as políticas da Igreja em BH.
                                </p>
                            </div>
                        </CardFooter>
                    </Card>
                </div>
            </div>

            {/* Dialogs */}
            <Dialog open={isEditingContact} onOpenChange={setIsEditingContact}>
                <DialogContent className="rounded-3xl border-border/50 bg-card/95 backdrop-blur-xl">
                    <DialogHeader>
                        <DialogTitle>Editar Contato</DialogTitle>
                        <DialogDescription>Atualize seu número de telefone abaixo.</DialogDescription>
                    </DialogHeader>
                    <FieldGroup className="pt-2">
                        <Field>
                            <FieldLabel htmlFor="phone">Telefone</FieldLabel>
                            <Input id="phone" value={editForm.phone || ""} onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })} placeholder="(31) 99999-9999" className="rounded-xl border-border/50" />
                        </Field>
                    </FieldGroup>
                    <DialogFooter className="gap-2 sm:gap-0">
                        <Button variant="outline" onClick={() => setIsEditingContact(false)} className="rounded-xl border-border/50">Cancelar</Button>
                        <Button onClick={() => handleSaveProfile({ phone: editForm.phone })} disabled={saving} className="rounded-xl shadow-lg shadow-primary/20">
                            {saving && <Loader2Icon className="mr-2 size-4 animate-spin" />}
                            Salvar Alterações
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <Dialog open={isEditingFamily} onOpenChange={setIsEditingFamily}>
                <DialogContent className="sm:max-w-md rounded-3xl border-border/50 bg-card/95 backdrop-blur-xl">
                    <DialogHeader>
                        <DialogTitle>Vínculos Familiares</DialogTitle>
                        <DialogDescription>Selecione os membros da sua família cadastrados na igreja.</DialogDescription>
                    </DialogHeader>
                    <div className="space-y-6 py-4">
                        <Field>
                            <FieldLabel>Cônjuge</FieldLabel>
                            <Combobox 
                                value={allMembers.find(m => m.id === editForm.spouse_id)?.full_name || ""} 
                                onValueChange={(name) => {
                                    const member = allMembers.find(m => m.full_name === name);
                                    setEditForm({ ...editForm, spouse_id: member?.id || undefined });
                                }}
                            >
                                <ComboboxInput placeholder={loadingMembers ? "Carregando..." : "Buscar cônjuge..."} className="rounded-xl">
                                    <SearchIcon className="h-4 w-4 text-muted-foreground" />
                                </ComboboxInput>
                                <ComboboxContent>
                                    <ComboboxList>
                                        <ComboboxItem value="">Nenhum (Remover)</ComboboxItem>
                                        {allMembers.filter(m => m.id !== profile.id).map((member) => (
                                            <ComboboxItem key={member.id} value={member.full_name}>
                                                {member.full_name}
                                            </ComboboxItem>
                                        ))}
                                    </ComboboxList>
                                    <ComboboxEmpty>Nenhum membro encontrado.</ComboboxEmpty>
                                </ComboboxContent>
                            </Combobox>
                        </Field>

                        <Field>
                            <FieldLabel>Pai</FieldLabel>
                            <Combobox 
                                value={allMembers.find(m => m.id === editForm.father_id)?.full_name || ""} 
                                onValueChange={(name) => {
                                    const member = allMembers.find(m => m.full_name === name);
                                    setEditForm({ ...editForm, father_id: member?.id || undefined });
                                }}
                            >
                                <ComboboxInput placeholder="Buscar pai..." className="rounded-xl" />
                                <ComboboxContent>
                                    <ComboboxList>
                                        <ComboboxItem value="">Nenhum (Remover)</ComboboxItem>
                                        {allMembers.filter(m => m.id !== profile.id).map((member) => (
                                            <ComboboxItem key={member.id} value={member.full_name}>
                                                {member.full_name}
                                            </ComboboxItem>
                                        ))}
                                    </ComboboxList>
                                </ComboboxContent>
                            </Combobox>
                        </Field>

                        <Field>
                            <FieldLabel>Mãe</FieldLabel>
                            <Combobox 
                                value={allMembers.find(m => m.id === editForm.mother_id)?.full_name || ""} 
                                onValueChange={(name) => {
                                    const member = allMembers.find(m => m.full_name === name);
                                    setEditForm({ ...editForm, mother_id: member?.id || undefined });
                                }}
                            >
                                <ComboboxInput placeholder="Buscar mãe..." className="rounded-xl" />
                                <ComboboxContent>
                                    <ComboboxList>
                                        <ComboboxItem value="">Nenhum (Remover)</ComboboxItem>
                                        {allMembers.filter(m => m.id !== profile.id).map((member) => (
                                            <ComboboxItem key={member.id} value={member.full_name}>
                                                {member.full_name}
                                            </ComboboxItem>
                                        ))}
                                    </ComboboxList>
                                </ComboboxContent>
                            </Combobox>
                        </Field>
                    </div>
                    <DialogFooter className="gap-2 sm:gap-0">
                        <Button variant="outline" onClick={() => setIsEditingFamily(false)} className="rounded-xl border-border/50">Cancelar</Button>
                        <Button 
                            onClick={() => handleSaveProfile({ 
                                spouse_id: editForm.spouse_id || null as any, 
                                father_id: editForm.father_id || null as any, 
                                mother_id: editForm.mother_id || null as any 
                            })} 
                            disabled={saving} 
                            className="rounded-xl shadow-lg shadow-primary/20"
                        >
                            {saving && <Loader2Icon className="mr-2 size-4 animate-spin" />}
                            Salvar Vínculos
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <Dialog open={isEditingAddress} onOpenChange={setIsEditingAddress}>
                <DialogContent className="sm:max-w-md rounded-3xl border-border/50 bg-card/95 backdrop-blur-xl">
                    <DialogHeader>
                        <DialogTitle>Editar Endereço</DialogTitle>
                        <DialogDescription>Atualize seu endereço completo.</DialogDescription>
                    </DialogHeader>
                    <div className="max-h-[60vh] overflow-y-auto px-1 no-scrollbar">
                        <FieldGroup className="gap-6 pt-2">
                            <Field>
                                <FieldLabel htmlFor="street">Rua</FieldLabel>
                                <Input id="street" value={editForm.address_street || ""} onChange={(e) => setEditForm({ ...editForm, address_street: e.target.value })} className="rounded-xl border-border/50" />
                            </Field>
                            <div className="grid grid-cols-2 gap-4">
                                <Field>
                                    <FieldLabel htmlFor="number">Número</FieldLabel>
                                    <Input id="number" value={editForm.address_number || ""} onChange={(e) => setEditForm({ ...editForm, address_number: e.target.value })} className="rounded-xl border-border/50" />
                                </Field>
                                <Field>
                                    <FieldLabel htmlFor="complement">Complemento</FieldLabel>
                                    <Input id="complement" value={editForm.address_complement || ""} onChange={(e) => setEditForm({ ...editForm, address_complement: e.target.value })} className="rounded-xl border-border/50" />
                                </Field>
                            </div>
                            <Field>
                                <FieldLabel htmlFor="neighborhood">Bairro</FieldLabel>
                                <Input id="neighborhood" value={editForm.address_neighborhood || ""} onChange={(e) => setEditForm({ ...editForm, address_neighborhood: e.target.value })} className="rounded-xl border-border/50" />
                            </Field>
                            <div className="grid grid-cols-2 gap-4">
                                <Field>
                                    <FieldLabel htmlFor="city">Cidade</FieldLabel>
                                    <Input id="city" value={editForm.address_city || ""} onChange={(e) => setEditForm({ ...editForm, address_city: e.target.value })} className="rounded-xl border-border/50" />
                                </Field>
                                <Field>
                                    <FieldLabel htmlFor="state">Estado</FieldLabel>
                                    <Input id="state" value={editForm.address_state || ""} onChange={(e) => setEditForm({ ...editForm, address_state: e.target.value })} maxLength={2} className="rounded-xl border-border/50" />
                                </Field>
                            </div>
                            <Field>
                                <FieldLabel htmlFor="zip">CEP</FieldLabel>
                                <Input id="zip" value={editForm.address_zip_code || ""} onChange={(e) => setEditForm({ ...editForm, address_zip_code: e.target.value })} className="rounded-xl border-border/50" />
                            </Field>
                        </FieldGroup>
                    </div>
                    <DialogFooter className="gap-2 sm:gap-0 mt-6">
                        <Button variant="outline" onClick={() => setIsEditingAddress(false)} className="rounded-xl border-border/50">Cancelar</Button>
                        <Button onClick={() => handleSaveProfile({ address_street: editForm.address_street, address_number: editForm.address_number, address_complement: editForm.address_complement, address_neighborhood: editForm.address_neighborhood, address_city: editForm.address_city, address_state: editForm.address_state, address_zip_code: editForm.address_zip_code })} disabled={saving} className="rounded-xl shadow-lg shadow-primary/20">
                            {saving && <Loader2Icon className="mr-2 size-4 animate-spin" />}
                            Salvar Alterações
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <Dialog open={isEditingAvatar} onOpenChange={setIsEditingAvatar}>
                <DialogContent className={cn("rounded-3xl border-border/50 bg-card/95 backdrop-blur-xl", isCropping ? "sm:max-w-[425px]" : "")}>
                    <DialogHeader>
                        <DialogTitle>{isCropping ? "Ajustar Foto" : "Foto de Perfil"}</DialogTitle>
                        <DialogDescription>
                            {isCropping 
                                ? "Arraste e aproxime para escolher o melhor enquadramento." 
                                : "Visualize ou altere sua foto de perfil atual."}
                        </DialogDescription>
                    </DialogHeader>

                    {isCropping && avatarPreview ? (
                        <div className="py-4">
                            <ImageCropper 
                                image={avatarPreview} 
                                onCropComplete={handleCropComplete}
                                onCancel={() => setIsCropping(false)}
                            />
                        </div>
                    ) : (
                        <>
                            <div className="flex flex-col items-center gap-6 py-6">
                                <Avatar className="size-56 border-4 border-muted shadow-2xl transition-transform duration-500">
                                    <AvatarImage src={avatarPreview || profile.avatar_url} />
                                    <AvatarFallback className="text-7xl bg-primary text-primary-foreground font-bold">
                                        {getInitials(profile.full_name)}
                                    </AvatarFallback>
                                </Avatar>
                                
                                <div className="flex flex-col w-full gap-2">
                                    <Button variant="outline" className="w-full gap-2 rounded-xl border-border/50 py-6" asChild>
                                        <label htmlFor="avatar-file-input" className="cursor-pointer">
                                            <CameraIcon className="size-4" />
                                            {avatarFile ? "Escolher outra" : "Trocar Foto de Perfil"}
                                        </label>
                                    </Button>
                                    <input id="avatar-file-input" type="file" accept="image/*" className="hidden" onChange={handleAvatarSelect} />
                                </div>
                            </div>
                            <DialogFooter className="gap-2 sm:gap-0">
                                <Button variant="outline" onClick={() => { setIsEditingAvatar(false); setAvatarPreview(null); setAvatarFile(null); setIsCropping(false); }} className="rounded-xl border-border/50">Cancelar</Button>
                                <Button onClick={handleAvatarUpload} disabled={!avatarFile || saving} className="rounded-xl shadow-lg shadow-primary/20">
                                    {saving && <Loader2Icon className="mr-2 size-4 animate-spin" />}
                                    Salvar Nova Foto
                                </Button>
                            </DialogFooter>
                        </>
                    )}
                </DialogContent>
            </Dialog>
        </div>
    );
}
