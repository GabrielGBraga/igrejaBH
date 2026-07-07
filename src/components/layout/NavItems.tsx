import { Home, Users, BookOpen, PlusSquare, Calendar, MessageSquare, Settings, User, ClipboardList, Network } from 'lucide-react';

export const navItems = [
  { name: 'Início', href: '/', icon: Home },
  { name: 'Grupos Caseiros', href: '/grupos-caseiros', icon: Users, requireAdmin: true },
  { name: 'Ensinos', href: '/ensinos', icon: BookOpen },
  { name: 'Nova Notícia', href: '/noticias/nova', icon: PlusSquare },
  { name: 'Eventos', href: '/eventos', icon: Calendar },
  { name: 'Mensagens', href: '/mensagens', icon: MessageSquare },
  { name: 'Rede de Relacionamentos', href: '/gestao/grafo', icon: Network, requireManagement: true },
  { name: 'Formulários', href: '/gestao/formularios', icon: ClipboardList, requireCanPost: true },
  { name: 'Perfil', href: '/perfil', icon: User },
  { name: 'Ajustes', href: '/ajustes', icon: Settings },
];
