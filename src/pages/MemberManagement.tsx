import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { 
    UsersIcon, 
    SearchIcon, 
    Loader2, 
    PhoneIcon, 
    MapPinIcon,
    HomeIcon,
    CalendarIcon
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import type { Database } from "@/lib/database.types";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

type ProfileWithGroup = Database["public"]["Tables"]["profiles"]["Row"] & {
    home_groups?: {
        location_text: string | null;
    } | null;
    is_leader?: boolean;
};

export default function MemberManagement() {
    const [members, setMembers] = useState<ProfileWithGroup[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            try {
                const { data: profilesData, error: profilesError } = await supabase
                    .from('profiles')
                    .select('*, home_groups!profiles_home_group_id_fkey(location_text)')
                    .order('full_name');
                
                if (profilesError) throw profilesError;

                const { data: groupsData, error: groupsError } = await supabase
                    .from('home_groups')
                    .select('leader_1_id, leader_2_id');
                
                if (groupsError) throw groupsError;

                const leaderIds = new Set<string>();
                groupsData?.forEach(g => {
                    if (g.leader_1_id) leaderIds.add(g.leader_1_id);
                    if (g.leader_2_id) leaderIds.add(g.leader_2_id);
                });

                const enrichedMembers = (profilesData || []).map(profile => ({
                    ...profile,
                    is_leader: leaderIds.has(profile.id)
                }));

                setMembers(enrichedMembers);
            } catch (error) {
                console.error("Error fetching members:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, []);

    const filteredMembers = members.filter(m => 
        m.full_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        m.phone?.includes(searchQuery) ||
        m.address_neighborhood?.toLowerCase().includes(searchQuery.toLowerCase())
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
            <header className="flex flex-col md:flex-row md:items-center justify-between gap-6 pb-6 border-b border-border">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
                        <UsersIcon className="w-8 h-8 text-primary" />
                        Gestão de Vinculados
                    </h1>
                    <p className="text-muted-foreground mt-1">Lista completa de irmãos e vinculados da Igreja em BH.</p>
                </div>
                
                <div className="relative w-full md:w-96 group">
                    <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                    <Input 
                        placeholder="Buscar por nome, telefone ou bairro..." 
                        className="pl-10 bg-card/30 backdrop-blur-sm border-border/50 rounded-xl focus:border-primary/50 transition-all focus:ring-2 focus:ring-primary/20"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                    />
                </div>
            </header>

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
                        <p className="text-muted-foreground mt-1 max-w-sm mx-auto">Tente ajustar sua busca ou verifique a ortografia do nome ou bairro.</p>
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
                                    </div>
                                </div>
                            </CardHeader>
                            <CardContent className="space-y-4 px-5 pb-5 pt-2 flex-1 flex flex-col justify-between">
                                <div className="grid grid-cols-1 gap-3 text-sm">
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
        </div>
    );
}
