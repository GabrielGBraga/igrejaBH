import { Settings as SettingsIcon } from "lucide-react"

export default function Settings() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center">
      <div className="mb-4 rounded-full bg-muted/50 p-4">
        <SettingsIcon className="h-12 w-12 text-muted-foreground" />
      </div>
      <h1 className="text-2xl font-bold tracking-tight">Página de Ajustes</h1>
      <p className="mt-2 max-w-sm text-muted-foreground">
        Aqui você poderá configurar as preferências do seu aplicativo em breve!
      </p>
    </div>
  )
}
