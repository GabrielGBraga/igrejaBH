import { Link, useLocation } from 'react-router-dom';
import { Menu } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from '@/components/ui/sheet';
import { navItems } from './NavItems';
import { cn } from '@/lib/utils';
import supabase from '@/lib/supabase';
import { useEffect, useState } from 'react';

export function MobileNav() {
  const location = useLocation();
  const [isAdmin, setIsAdmin] = useState(false);
  const [isManagement, setIsManagement] = useState(false);
  const [canPost, setCanPost] = useState(false);

  useEffect(() => {
    async function fetchUserData() {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user) {
        const { data: profileData } = await supabase
          .from("profiles")
          .select("id, is_dev, is_presbyter, is_deacon, can_post")
          .eq("user_id", session.user.id)
          .single();
        
        if (profileData) {
          setIsAdmin(!!(profileData.is_dev || profileData.is_presbyter));
          setCanPost(!!(profileData.is_dev || profileData.is_presbyter || profileData.can_post));
          
          const { count } = await supabase
            .from("home_groups")
            .select("*", { count: 'exact', head: true })
            .or(`leader_1_id.eq.${profileData.id},leader_2_id.eq.${profileData.id}`);
          
          setIsManagement(!!(profileData.is_dev || profileData.is_presbyter || profileData.is_deacon || (count || 0) > 0));
        }
      }
    }
    fetchUserData();
  }, []);

  const filteredNavItems = navItems.filter(item => {
    if (item.requireManagement && !isManagement) return false;
    // @ts-ignore
    if (item.requireCanPost && !canPost) return false;
    if (item.href === '/grupos-caseiros/adicionar' && !isAdmin) return false;
    return true;
  });

  return (
    <div className="flex md:hidden items-center justify-between p-4 border-b bg-background/80 backdrop-blur-md sticky top-0 z-50">
      <Link to="/" className="flex items-center gap-2">
        <img src="/logo_igreja.png" alt="Logo" className="h-8 w-auto" />
        <span className="font-bold text-lg tracking-tight">Igreja BH</span>
      </Link>
      
      <Sheet>
        <SheetTrigger asChild>
          <Button variant="ghost" size="icon" className="md:hidden">
            <Menu className="h-6 w-6" />
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-[300px] sm:w-[350px] p-0">
          <SheetHeader className="p-6 border-b">
            <SheetTitle className="flex items-center gap-2">
              <img src="/logo_igreja.png" alt="Logo" className="h-8 w-auto" />
              <span className="font-bold tracking-tight text-xl">Igreja BH</span>
            </SheetTitle>
          </SheetHeader>
          <nav className="flex flex-col gap-1 p-4">
            {filteredNavItems.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname === item.href;
              
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={cn(
                    "flex items-center gap-3 px-3 py-3 rounded-lg text-sm font-medium transition-colors",
                    isActive 
                      ? "bg-primary text-primary-foreground" 
                      : "text-muted-foreground hover:bg-muted hover:text-foreground"
                  )}
                >
                  <Icon className="h-5 w-5" />
                  {item.name}
                </Link>
              );
            })}
          </nav>
        </SheetContent>
      </Sheet>
    </div>
  );
}
