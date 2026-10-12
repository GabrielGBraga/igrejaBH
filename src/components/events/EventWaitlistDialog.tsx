import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"
import { EventWaitlistForm } from "./EventWaitlistForm"

interface EventWaitlistDialogProps {
  retreat: {
    id: string
    title: string
    location_text?: string | null
    [key: string]: unknown
  } | null
  isOpen: boolean
  onClose: () => void
  userProfile?: {
    fullName?: string
    email?: string
    phone?: string
    cpf?: string
    cityState?: string
  } | null
  onSuccess?: () => void
}

export function EventWaitlistDialog({
  retreat,
  isOpen,
  onClose,
  userProfile,
  onSuccess,
}: EventWaitlistDialogProps) {
  if (!retreat) return null

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-lg p-0 overflow-hidden border-border/80 bg-background max-h-[92vh] overflow-y-auto">
        <DialogHeader className="sr-only">
          <DialogTitle>Lista de Espera: {retreat.title}</DialogTitle>
          <DialogDescription>
            Formulário para entrar na lista de espera do evento {retreat.title}.
          </DialogDescription>
        </DialogHeader>

        <EventWaitlistForm
          retreat={retreat}
          initialData={userProfile || undefined}
          onSuccess={() => {
            onSuccess?.()
          }}
          onCancel={onClose}
          className="border-none shadow-none p-4 sm:p-6"
        />
      </DialogContent>
    </Dialog>
  )
}
