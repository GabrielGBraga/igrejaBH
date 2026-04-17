import { Settings as SettingsIcon } from 'lucide-react';

export default function Settings() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] text-center px-4">
      <div className="p-4 bg-muted/50 rounded-full mb-4">
        <SettingsIcon className="w-12 h-12 text-muted-foreground" />
      </div>
      <h1 className="text-2xl font-bold tracking-tight">Página de Ajustes</h1>
      <p className="text-muted-foreground mt-2 max-w-sm">
        Aqui você poderá configurar as preferências do seu aplicativo em breve!
      </p>
    </div>
  );
}
