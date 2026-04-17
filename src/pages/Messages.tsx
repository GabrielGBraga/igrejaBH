import { MessageSquare } from 'lucide-react';

export default function Messages() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] text-center px-4">
      <div className="p-4 bg-muted/50 rounded-full mb-4">
        <MessageSquare className="w-12 h-12 text-muted-foreground" />
      </div>
      <h1 className="text-2xl font-bold tracking-tight">Página de Mensagens</h1>
      <p className="text-muted-foreground mt-2 max-w-sm">
        Esta página está em desenvolvimento. Em breve você poderá trocar mensagens com outros membros aqui!
      </p>
    </div>
  );
}
