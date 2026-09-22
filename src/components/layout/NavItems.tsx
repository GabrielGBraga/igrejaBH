import {
  Home,
  Users,
  BookOpen,
  Calendar,
  Settings,
  ClipboardList,
  type LucideIcon,
} from "lucide-react";

export interface NavItem {
  name: string;
  href: string;
  icon: LucideIcon;
  requireAdmin?: boolean;
  requireManagement?: boolean;
  requireCanPost?: boolean;
}

export const navItems: NavItem[] = [
  { name: "Início", href: "/dashboard", icon: Home },
  { name: "Ensinos", href: "/ensinos", icon: BookOpen },
  { name: "Gestão de Eventos", href: "/manage-events", icon: Calendar, requireManagement: true },
  { name: "Gestão de Membros", href: "/gestao/vinculados", icon: Users, requireManagement: true },
  { name: "Formulários", href: "/gestao/formularios", icon: ClipboardList, requireCanPost: true },
  { name: "Ajustes", href: "/ajustes", icon: Settings },
];
