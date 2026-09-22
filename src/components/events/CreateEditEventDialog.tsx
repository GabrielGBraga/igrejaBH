import { useEffect, useState } from "react";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";
import supabase from "@/lib/supabase";
import { ensureMandatoryEventFields, type FormField } from "@/lib/forms";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { Field, FieldLabel, FieldError } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import type { Resolver } from "react-hook-form";
import type { Database, Json } from "@/lib/database.types";

type Retreat = Database["public"]["Tables"]["retreats"]["Row"];

const retreatFormSchema = z.object({
  title: z.string().min(3, { message: "O título deve ter pelo menos 3 caracteres." }),
  description: z.string().default(""),
  price: z.coerce.number().min(0, { message: "O preço deve ser igual ou maior que zero." }),
  location_text: z.string().default(""),
  start_date: z
    .string()
    .min(1, { message: "A data de início é obrigatória." })
    .regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Formato de data inválido (AAAA-MM-DD)." }),
  end_date: z
    .string()
    .min(1, { message: "A data de término é obrigatória." })
    .regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Formato de data inválido (AAAA-MM-DD)." }),
  max_participants: z.coerce
    .number()
    .min(1, { message: "Deve ter capacidade para pelo menos 1 participante." }),
  status: z.enum(["ativo", "rascunho", "encerrado"] as const),
  form_id: z.string().optional().nullable(),
  registration_deadline: z.string().optional().nullable(),
});

type RetreatFormValues = z.infer<typeof retreatFormSchema>;

interface FormOption {
  id: string;
  name: string;
}

interface CreateEditEventDialogProps {
  isOpen: boolean;
  onOpenChange: (open: boolean) => void;
  retreat?: Retreat | null;
  forms: FormOption[];
  onSuccess: () => void;
}

export function CreateEditEventDialog({
  isOpen,
  onOpenChange,
  retreat,
  forms,
  onSuccess,
}: CreateEditEventDialogProps) {
  const [submitting, setSubmitting] = useState(false);

  const { control, handleSubmit, reset, setValue } = useForm<RetreatFormValues>({
    resolver: zodResolver(retreatFormSchema) as Resolver<RetreatFormValues>,
    defaultValues: {
      title: "",
      description: "",
      price: 0,
      location_text: "",
      start_date: "",
      end_date: "",
      max_participants: 100,
      status: "ativo",
      form_id: "",
      registration_deadline: "",
    },
  });

  useEffect(() => {
    if (retreat) {
      setValue("title", retreat.title);
      setValue("description", retreat.description || "");
      setValue("price", retreat.price || 0);
      setValue("location_text", retreat.location_text || "");
      setValue("start_date", retreat.start_date || "");
      setValue("end_date", retreat.end_date || "");
      setValue("max_participants", retreat.max_participants || 100);
      setValue(
        "status",
        retreat.status === "rascunho" || retreat.status === "encerrado"
          ? retreat.status
          : "ativo"
      );
      setValue("form_id", retreat.form_id || "");
      setValue("registration_deadline", retreat.registration_deadline || "");
    } else {
      reset({
        title: "",
        description: "",
        price: 0,
        location_text: "",
        start_date: "",
        end_date: "",
        max_participants: 100,
        status: "ativo",
        form_id: "",
        registration_deadline: "",
      });
    }
  }, [retreat, isOpen, setValue, reset]);

  const onSubmitEvent = async (data: RetreatFormValues) => {
    setSubmitting(true);
    const payload = {
      title: data.title,
      description: data.description || null,
      price: data.price,
      location_text: data.location_text || null,
      start_date: data.start_date,
      end_date: data.end_date,
      max_participants: data.max_participants,
      status: data.status,
      form_id: data.form_id === "" ? null : data.form_id,
      registration_deadline:
        data.registration_deadline === "" ? null : data.registration_deadline,
    };

    // Garantir campos obrigatórios no formulário selecionado
    if (payload.form_id) {
      try {
        const { data: dbForm } = await supabase
          .from("forms")
          .select("id, fields")
          .eq("id", payload.form_id)
          .single();

        if (dbForm && dbForm.fields) {
          const updatedFields = ensureMandatoryEventFields(
            dbForm.fields as unknown as FormField[]
          );
          await supabase
            .from("forms")
            .update({ fields: updatedFields as unknown as Json })
            .eq("id", payload.form_id);
        }
      } catch (fErr: unknown) {
        const msg = fErr instanceof Error ? fErr.message : "Erro desconhecido";
        console.error("Erro ao verificar campos obrigatórios no formulário:", msg);
      }
    }

    try {
      if (retreat) {
        const { error } = await supabase
          .from("retreats")
          .update(payload)
          .eq("id", retreat.id);

        if (error) throw error;
        toast.success("Evento atualizado com sucesso!");
      } else {
        const { error } = await supabase.from("retreats").insert([payload]);

        if (error) throw error;
        toast.success("Evento criado com sucesso!");
      }

      onOpenChange(false);
      reset();
      onSuccess();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao salvar evento";
      toast.error(msg);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-3xl max-w-full rounded-2xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 p-6 md:p-8 max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="text-xl font-bold text-zinc-900 dark:text-zinc-50">
            {retreat ? "Editar Encontro/Retiro" : "Criar Novo Encontro/Retiro"}
          </DialogTitle>
          <DialogDescription className="text-zinc-500 dark:text-zinc-400">
            Preencha os detalhes logísticos do evento comunitário.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmitEvent)} className="space-y-4 py-2">
          <Field>
            <FieldLabel htmlFor="title">Título do Retiro *</FieldLabel>
            <Controller
              name="title"
              control={control}
              render={({ field, fieldState }) => (
                <>
                  <Input
                    {...field}
                    id="title"
                    placeholder="Ex: Retiro de Jovens 2026"
                    className="rounded-md min-h-[44px]"
                  />
                  {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                </>
              )}
            />
          </Field>

          <Field>
            <FieldLabel htmlFor="description">Descrição</FieldLabel>
            <Controller
              name="description"
              control={control}
              render={({ field }) => (
                <Textarea
                  {...field}
                  value={field.value || ""}
                  id="description"
                  placeholder="Informações detalhadas do encontro..."
                  className="rounded-md min-h-[80px]"
                />
              )}
            />
          </Field>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Field>
              <FieldLabel htmlFor="price">Preço por Pessoa (R$) *</FieldLabel>
              <Controller
                name="price"
                control={control}
                render={({ field, fieldState }) => (
                  <>
                    <Input
                      {...field}
                      id="price"
                      type="number"
                      step="0.01"
                      min="0"
                      placeholder="Ex: 150.00 (0 para Gratuito)"
                      className="rounded-md min-h-[44px]"
                    />
                    {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                  </>
                )}
              />
            </Field>

            <Field>
              <FieldLabel htmlFor="max_participants">Capacidade Máxima *</FieldLabel>
              <Controller
                name="max_participants"
                control={control}
                render={({ field, fieldState }) => (
                  <>
                    <Input
                      {...field}
                      id="max_participants"
                      type="number"
                      min="1"
                      placeholder="Ex: 120"
                      className="rounded-md min-h-[44px]"
                    />
                    {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                  </>
                )}
              />
            </Field>
          </div>

          <Field>
            <FieldLabel htmlFor="location_text">Local do Evento</FieldLabel>
            <Controller
              name="location_text"
              control={control}
              render={({ field }) => (
                <Input
                  {...field}
                  value={field.value || ""}
                  id="location_text"
                  placeholder="Ex: Sítio Ebenézer, Esmeraldas - MG"
                  className="rounded-md min-h-[44px]"
                />
              )}
            />
          </Field>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Field>
              <FieldLabel htmlFor="start_date">Data de Início *</FieldLabel>
              <Controller
                name="start_date"
                control={control}
                render={({ field, fieldState }) => (
                  <>
                    <Input
                      {...field}
                      id="start_date"
                      type="date"
                      className="rounded-md min-h-[44px]"
                    />
                    {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                  </>
                )}
              />
            </Field>

            <Field>
              <FieldLabel htmlFor="end_date">Data de Término *</FieldLabel>
              <Controller
                name="end_date"
                control={control}
                render={({ field, fieldState }) => (
                  <>
                    <Input
                      {...field}
                      id="end_date"
                      type="date"
                      className="rounded-md min-h-[44px]"
                    />
                    {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                  </>
                )}
              />
            </Field>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Field>
              <FieldLabel htmlFor="status">Status *</FieldLabel>
              <Controller
                name="status"
                control={control}
                render={({ field }) => (
                  <Select onValueChange={field.onChange} value={field.value}>
                    <SelectTrigger id="status" className="w-full min-h-[44px]">
                      <SelectValue placeholder="Selecione o status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="ativo">Ativo (Inscrições Abertas)</SelectItem>
                      <SelectItem value="rascunho">Rascunho (Privado)</SelectItem>
                      <SelectItem value="encerrado">Encerrado</SelectItem>
                    </SelectContent>
                  </Select>
                )}
              />
            </Field>

            <Field>
              <FieldLabel htmlFor="form_id">Ficha de Inscrição Customizada</FieldLabel>
              <Controller
                name="form_id"
                control={control}
                render={({ field }) => (
                  <Select
                    onValueChange={(val) => field.onChange(val === "none" ? null : val)}
                    value={field.value || "none"}
                  >
                    <SelectTrigger id="form_id" className="w-full min-h-[44px]">
                      <SelectValue placeholder="Nenhum (Formulário Padrão)" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="none">Nenhum (Formulário Padrão)</SelectItem>
                      {forms.map((f) => (
                        <SelectItem key={f.id} value={f.id}>
                          {f.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                )}
              />
            </Field>
          </div>

          <DialogFooter className="pt-4 flex flex-col sm:flex-row gap-2">
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
              className="min-h-[44px] cursor-pointer"
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              disabled={submitting}
              className="min-h-[44px] cursor-pointer bg-zinc-900 hover:bg-zinc-800 text-zinc-50 dark:bg-zinc-50 dark:hover:bg-zinc-200 dark:text-zinc-900 font-bold"
            >
              {submitting ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin mr-2" />
                  Salvando...
                </>
              ) : retreat ? (
                "Salvar Alterações"
              ) : (
                "Criar Retiro"
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
