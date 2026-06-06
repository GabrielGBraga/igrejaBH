import { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import supabase from "@/lib/supabase";
import { getMissingProfileFields, getFieldLabel, type MandatoryProfileField } from "@/lib/profile-config";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { AlertCircleIcon, ArrowRightIcon } from "lucide-react";

export function ProfileCompletionBlocker() {
    const [isOpen, setIsOpen] = useState(false);
    const [loading, setLoading] = useState(true);
    const [missingFields, setMissingFields] = useState<MandatoryProfileField[]>([]);
    const location = useLocation();
    const navigate = useNavigate();

    // Não bloqueia se o usuário já estiver na página de perfil
    const isProfilePage = location.pathname === "/perfil";

    useEffect(() => {
        async function checkProfile() {
            try {
                const { data: { session } } = await supabase.auth.getSession();
                if (!session?.user) {
                    setLoading(false);
                    return;
                }

                const { data: profile, error } = await supabase
                    .from("profiles")
                    .select("*")
                    .eq("user_id", session.user.id)
                    .single();

                if (error) throw error;

                if (profile) {
                    const missing = getMissingProfileFields(profile);
                    setMissingFields(missing);
                    setIsOpen(missing.length > 0 && !isProfilePage);
                }
            } catch (error) {
                console.error("Erro ao verificar completitude do perfil:", error);
            } finally {
                setLoading(false);
            }
        }

        checkProfile();

        // Listen for profile updates (optional but good)
        const channel = supabase
            .channel('profile_changes')
            .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'profiles' }, () => {
                checkProfile();
            })
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, [location.pathname, isProfilePage]);

    if (loading) return null;
    if (!isOpen) return null;

    return (
        <Dialog open={isOpen} onOpenChange={() => {}}>
            <DialogContent 
                className="sm:max-w-[425px] rounded-3xl border-border/50 bg-card/95 backdrop-blur-xl pointer-events-auto"
                onPointerDownOutside={(e) => e.preventDefault()}
                onEscapeKeyDown={(e) => e.preventDefault()}
            >
                <DialogHeader className="items-center text-center">
                    <div className="size-16 bg-primary/10 rounded-full flex items-center justify-center mb-4">
                        <AlertCircleIcon className="size-8 text-primary animate-pulse" />
                    </div>
                    <DialogTitle className="text-2xl font-bold">Perfil Incompleto</DialogTitle>
                    <DialogDescription className="text-base pt-2">
                        Precisamos que você complete suas informações de cadastro para continuar utilizando o sistema.
                    </DialogDescription>
                </DialogHeader>
                
                <div className="bg-muted/30 p-4 rounded-2xl border border-border/50 my-4">
                    <p className="text-sm font-bold text-muted-foreground uppercase tracking-widest mb-2">Informações Faltantes:</p>
                    <ul className="grid grid-cols-1 gap-1">
                        {missingFields.slice(0, 5).map(field => (
                            <li key={field} className="text-sm flex items-center gap-2">
                                <div className="size-1.5 rounded-full bg-primary" />
                                <span className="">{getFieldLabel(field)}</span>
                            </li>
                        ))}
                        {missingFields.length > 5 && (
                            <li className="text-xs text-muted-foreground italic mt-1">
                                ...e mais {missingFields.length - 5} campos.
                            </li>
                        )}
                    </ul>
                </div>

                <div className="flex flex-col gap-3 pt-2">
                    <Button 
                        onClick={() => {
                            setIsOpen(false);
                            navigate("/perfil?edit=socio");
                        }}
                        className="rounded-xl py-6 font-bold shadow-lg shadow-primary/20 gap-2"
                    >
                        Completar Agora
                        <ArrowRightIcon className="size-4" />
                    </Button>
                    <p className="text-[10px] text-center text-muted-foreground px-6">
                        Ao clicar em completar, você será redirecionado para a página de perfil.
                    </p>
                </div>
            </DialogContent>
        </Dialog>
    );
}
