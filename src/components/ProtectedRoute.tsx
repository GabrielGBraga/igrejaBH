import { useEffect, useState } from "react";
import { Navigate, Outlet, useLocation } from "react-router-dom";
import supabase from "@/lib/supabase";
import { Loader2 } from "lucide-react";
import type { User } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";

type Profile = Database["public"]["Tables"]["profiles"]["Row"] & { is_leader?: boolean };

interface ProtectedRouteProps {
  children?: React.ReactNode;
  requireAdmin?: boolean;
  requireManagement?: boolean;
}

export function ProtectedRoute({ children, requireAdmin, requireManagement }: ProtectedRouteProps) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);
  const location = useLocation();

  useEffect(() => {
    let active = true;
    async function check() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!active) return;
        setUser(session?.user || null);
        
        if (session?.user) {
          const { data: profileData } = await supabase
            .from("profiles")
            .select("*")
            .eq("user_id", session.user.id)
            .single();
          
          if (profileData && active) {
            // Check if user is a leader of any home group
            const { count } = await supabase
              .from("home_groups")
              .select("*", { count: 'exact', head: true })
              .or(`leader_1_id.eq.${profileData.id},leader_2_id.eq.${profileData.id}`);
            
            setProfile({ ...profileData, is_leader: (count || 0) > 0 });
          }
        }
      } catch (err) {
        console.error("ProtectedRoute error:", err);
      } finally {
        if (active) setLoading(false);
      }
    }
    check();
    
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (active) {
        setUser(session?.user || null);
        if (!session?.user) {
            setProfile(null);
            setLoading(false);
        } else {
            // Se o usuário mudou, precisamos revalidar
            check();
        }
      }
    });

    return () => {
      active = false;
      subscription.unsubscribe();
    };
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/entrar" state={{ from: location }} replace />;
  }

  if (profile) {
    if (requireAdmin) {
      const isAllowed = profile.is_dev || profile.is_presbyter;
      if (!isAllowed) {
        return <Navigate to="/" replace />;
      }
    }

    if (requireManagement) {
      const isAllowed = profile.is_dev || profile.is_presbyter || profile.is_deacon || profile.is_leader;
      if (!isAllowed) {
        return <Navigate to="/" replace />;
      }
    }
  }

  return children ? <>{children}</> : <Outlet />;
}
