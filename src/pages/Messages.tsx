import { MessageSquare } from "lucide-react"

export default function Messages() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center">
      <div className="mb-4 rounded-full bg-muted/50 p-4">
        <MessageSquare className="h-12 w-12 text-muted-foreground" />
      </div>
      <h1 className="text-2xl font-bold tracking-tight">Página de Mensagens</h1>
      <p className="mt-2 max-w-sm text-muted-foreground">
        Esta página está em desenvolvimento. Em breve você poderá trocar
        mensagens com outros membros aqui!
      </p>
    </div>
  )
}
