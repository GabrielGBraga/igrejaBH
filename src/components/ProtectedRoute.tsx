import { useEffect, useState } from "react";
import { Navigate, Outlet, useLocation } from "react-router-dom";
import supabase from "@/lib/supabase";
import { Loader2 } from "lucide-react";
import type { User } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";

type Profile = Database["public"]["Tables"]["profiles"]["Row"];

interface ProtectedRouteProps {
  children?: React.ReactNode;
  requireAdmin?: boolean;
}

export function ProtectedRoute({ children, requireAdmin }: ProtectedRouteProps) {
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
          if (active) setProfile(profileData);
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
        setLoading(false);
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

  if (requireAdmin && profile) {
    const isAllowed = profile.is_dev || profile.is_presbyter;
    if (!isAllowed) {
      return <Navigate to="/" replace />;
    }
  }

  return children ? <>{children}</> : <Outlet />;
}
