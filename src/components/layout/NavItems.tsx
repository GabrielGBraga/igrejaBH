import {
  Home,
  Users,
  BookOpen,
  Calendar,
  Settings,
  ClipboardList,
} from "lucide-react";

export const navItems = [
  { name: "Início", href: "/", icon: Home },
  { name: "Ensinos", href: "/ensinos", icon: BookOpen },
  { name: "Gestão de Eventos", href: "/gestao/eventos", icon: Calendar, requireManagement: true },
  { name: "Gestão de Membros", href: "/gestao/vinculados", icon: Users, requireManagement: true },
  { name: "Formulários", href: "/gestao/formularios", icon: ClipboardList, requireCanPost: true },
  { name: "Ajustes", href: "/ajustes", icon: Settings },
];
