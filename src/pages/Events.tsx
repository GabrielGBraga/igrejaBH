import { Calendar } from 'lucide-react';

export default function Events() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] text-center px-4">
      <div className="p-4 bg-muted/50 rounded-full mb-4">
        <Calendar className="w-12 h-12 text-muted-foreground" />
      </div>
      <h1 className="text-2xl font-bold tracking-tight">Página de Eventos</h1>
      <p className="text-muted-foreground mt-2 max-w-sm">
        Esta página está em desenvolvimento. Em breve você poderá conferir todos os eventos da nossa igreja aqui!
      </p>
    </div>
  );
}
