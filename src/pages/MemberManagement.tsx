import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { Sidebar } from "@/components/layout/Sidebar";
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
                // Fetch profiles with their home group info
                const { data: profilesData, error: profilesError } = await supabase
                    .from('profiles')
                    .select('*, home_groups(location_text)')
                    .order('full_name');
                
                if (profilesError) throw profilesError;

                // Fetch home groups to identify leaders
                const { data: groupsData, error: groupsError } = await supabase
                    .from('home_groups')
                    .select('leader_1_id, leader_2_id');
                
                if (groupsError) throw groupsError;

                // Build a set of leader IDs
                const leaderIds = new Set<string>();
                groupsData?.forEach(g => {
                    if (g.leader_1_id) leaderIds.add(g.leader_1_id);
                    if (g.leader_2_id) leaderIds.add(g.leader_2_id);
                });

                // Map members with is_leader flag
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
            .map(n => n[0])
            .join("")
            .toUpperCase()
            .slice(0, 2);
    };

    return (
        <div className="flex min-h-screen bg-background text-foreground selection:bg-primary/20">
            <Sidebar />
            
            <main className="flex-1 flex flex-col items-center justify-start p-4 md:p-8 overflow-y-auto">
                <div className="w-full max-w-7xl mx-auto space-y-8">
                    <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-6 border-b border-border">
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
                                className="pl-10 bg-card/50 border-border backdrop-blur-sm focus:ring-primary/20"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>
                    </header>

                    {loading ? (
                        <div className="flex flex-col items-center justify-center py-20 gap-4">
                            <Loader2 className="w-10 h-10 animate-spin text-primary" />
                            <p className="text-muted-foreground font-medium">Carregando membros...</p>
                        </div>
                    ) : filteredMembers.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-20 text-center space-y-4">
                            <div className="w-16 h-16 rounded-full bg-muted flex items-center justify-center">
                                <SearchIcon className="w-8 h-8 text-muted-foreground" />
                            </div>
                            <div>
                                <h3 className="text-lg font-semibold">Nenhum irmão encontrado</h3>
                                <p className="text-muted-foreground">Tente ajustar sua busca para encontrar o que procura.</p>
                            </div>
                        </div>
                    ) : (
                        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                            {filteredMembers.map((member) => (
                                <Card key={member.id} className="border-border bg-card/40 backdrop-blur-md shadow-lg hover:shadow-xl hover:border-primary/30 transition-all duration-300 group">
                                    <CardHeader className="flex flex-row items-center gap-4 pb-4">
                                        <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary font-bold text-lg border border-primary/20 group-hover:scale-110 transition-transform">
                                            {member.avatar_url ? (
                                                <img src={member.avatar_url} alt={member.full_name} className="w-full h-full object-cover rounded-xl" />
                                            ) : (
                                                getInitials(member.full_name)
                                            )}
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <CardTitle className="text-lg font-bold truncate group-hover:text-primary transition-colors">
                                                {member.full_name}
                                            </CardTitle>
                                            <div className="flex flex-wrap gap-2 mt-1">
                                                {member.is_dev && (
                                                    <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-blue-500/20 text-blue-500 border border-blue-500/30">
                                                        Dev
                                                    </span>
                                                )}
                                                {member.is_presbyter && (
                                                    <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-purple-500/20 text-purple-500 border border-purple-500/30">
                                                        Presbítero
                                                    </span>
                                                )}
                                                {member.is_deacon && (
                                                    <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-amber-500/20 text-amber-500 border border-amber-500/30">
                                                        Diácono
                                                    </span>
                                                )}
                                                {member.is_leader && (
                                                    <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-emerald-500/20 text-emerald-500 border border-emerald-500/30">
                                                        Líder GC
                                                    </span>
                                                )}
                                            </div>
                                        </div>
                                    </CardHeader>
                                    <CardContent className="space-y-4 pt-0">
                                        <div className="grid grid-cols-1 gap-3 text-sm">
                                            <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors">
                                                <PhoneIcon className="w-4 h-4 shrink-0 text-primary/70" />
                                                <span>{member.phone || "Não informado"}</span>
                                            </div>
                                            
                                            <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors">
                                                <MapPinIcon className="w-4 h-4 shrink-0 text-primary/70" />
                                                <span className="truncate">
                                                    {member.home_groups?.location_text || "Sem Grupo Caseiro"}
                                                </span>
                                            </div>

                                            {member.address_neighborhood && (
                                                <div className="flex items-center gap-3 text-muted-foreground group-hover:text-foreground transition-colors">
                                                    <HomeIcon className="w-4 h-4 shrink-0 text-primary/70" />
                                                    <span className="truncate">
                                                        {member.address_neighborhood}, {member.address_city}
                                                    </span>
                                                </div>
                                            )}
                                        </div>
                                        
                                        <div className="pt-4 border-t border-border/50 flex items-center justify-between text-[11px] text-muted-foreground">
                                            <div className="flex items-center gap-1">
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
            </main>
        </div>
    );
}
