import { useForm, Controller } from "react-hook-form";
import { homeGroupSchema, type HomeGroupValue } from "../lib/schemas";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Field,
  FieldError,
  FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { Loader2, ArrowLeftIcon, MapPinIcon, ClockIcon, SearchIcon } from "lucide-react";
import { useState, useEffect } from "react";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import { useNavigate } from "react-router-dom";
import type { Database } from "@/lib/database.types";
import {
  Combobox,
  ComboboxInput,
  ComboboxContent,
  ComboboxList,
  ComboboxItem,
  ComboboxEmpty,
} from "@/components/ui/combobox";

type Profile = Pick<Database["public"]["Tables"]["profiles"]["Row"], "id" | "full_name">;

export default function AddHomeGroup() {
  const navigate = useNavigate();
  const [submitting, setSubmitting] = useState(false);
  const [leaders, setLeaders] = useState<Profile[]>([]);
  const [loadingLeaders, setLoadingLeaders] = useState(true);
  const [geocoding, setGeocoding] = useState(false);

  const form = useForm<HomeGroupValue>({
    resolver: zodResolver(homeGroupSchema),
    defaultValues: {
      meetingDay: 0,
      startTime: "19:30",
      locationText: "",
      leader1Id: "",
      leader2Id: null,
      lat: null,
      lng: null,
    },
  });

  const locationText = form.watch("locationText");

  // Fetch all profiles to select as leaders
  useEffect(() => {
    async function fetchLeaders() {
      try {
        const { data, error } = await supabase
          .from("profiles")
          .select("id, full_name")
          .order("full_name");
        
        if (error) throw error;
        setLeaders(data || []);
      } catch (error) {
        console.error("Error fetching leaders:", error);
        toast.error("Erro ao carregar lista de membros.");
      } finally {
        setLoadingLeaders(false);
      }
    }
    fetchLeaders();
  }, []);

  // Geocoding effect
  useEffect(() => {
    const timer = setTimeout(async () => {
      if (locationText && locationText.length > 8) {
        setGeocoding(true);
        try {
          // Limpa detalhes de complemento que confundem o geocoder (ap, apto, sala, bloco)
          const baseAddress = locationText
            .replace(/,\s*(ap|apto|sala|bloco)\s*\d+/gi, "")
            .replace(/\s+(ap|apto|sala|bloco)\s*\d+/gi, "");

          // Lista de variações para tentar encontrar o local
          const queries = [
            // 1. Endereço completo com cidade e estado
            baseAddress.toLowerCase().includes("belo horizonte") ? baseAddress : `${baseAddress}, Belo Horizonte, MG`,
            // 2. Sem partículas comuns (de, da, do) que podem não estar no OSM
            baseAddress.replace(/\s+(de|da|do|das|dos)\s+/gi, " ") + ", Belo Horizonte, MG",
            // 3. Apenas a rua (sem número) + bairro + cidade
            baseAddress.replace(/\d+/, "").trim() + ", Belo Horizonte, MG",
          ];

          let found = false;
          for (const query of queries) {
            if (found) break;

            const response = await fetch(
              `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1`,
              { headers: { "User-Agent": "igrejaBH-app" } }
            );
            const data = await response.json();

            if (data && data.length > 0) {
              form.setValue("lat", parseFloat(data[0].lat));
              form.setValue("lng", parseFloat(data[0].lon));
              toast.success("Localização encontrada!", {
                id: "geocoding-success",
                description: `Coordenadas capturadas via: ${query.split(",")[0]}`
              });
              found = true;
            }
          }
        } catch (error) {
          console.error("Geocoding error:", error);
        } finally {
          setGeocoding(false);
        }
      }
    }, 1500);

    return () => clearTimeout(timer);
  }, [locationText, form]);

  async function onSubmit(data: HomeGroupValue) {
    if (!data.lat || !data.lng) {
      toast.error("Por favor, aguarde a localização ser encontrada ou revise o endereço.", {
        description: "Não foi possível determinar as coordenadas geográficas."
      });
      return;
    }

    setSubmitting(true);
    
    const operation = async () => {
      const { error } = await supabase
        .from("home_groups")
        .insert({
          meeting_day: data.meetingDay,
          start_time: data.startTime,
          location_text: data.locationText,
          leader_1_id: data.leader1Id,
          leader_2_id: data.leader2Id || null,
          lat: data.lat,
          lng: data.lng,
        });
      
      if (error) throw error;
    };

    toast.promise(operation(), {
      loading: "Salvando grupo caseiro...",
      success: () => {
        navigate("/");
        return "Grupo caseiro adicionado com sucesso!";
      },
      error: (error) => {
        console.error("Error adding home group:", error);
        return "Erro ao salvar grupo caseiro.";
      },
      finally: () => {
        setSubmitting(false);
      },
    });
  }

  const daysOfWeek = [
    { value: 0, label: "Domingo" },
    { value: 1, label: "Segunda-feira" },
    { value: 2, label: "Terça-feira" },
    { value: 3, label: "Quarta-feira" },
    { value: 4, label: "Quinta-feira" },
    { value: 5, label: "Sexta-feira" },
    { value: 6, label: "Sábado" },
  ];

  return (
    <div className="relative min-h-screen flex items-center justify-center py-10 px-4 bg-background">
      {/* Background elements */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/20 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-secondary/20 blur-[120px]" />
      </div>

      <Card className="w-full max-w-lg border-border bg-card/50 backdrop-blur-xl shadow-2xl relative z-10">
        <CardHeader className="space-y-1 text-center">
          <div className="flex items-center justify-start mb-2">
            <Button variant="ghost" onClick={() => navigate("/")} size="sm" className="hover:bg-primary/10">
              <ArrowLeftIcon className="mr-2 h-4 w-4" />
              Voltar
            </Button>
          </div>
          <CardTitle className="text-3xl font-bold tracking-tight text-foreground">
            Novo Grupo Caseiro
          </CardTitle>
          <CardDescription className="text-muted-foreground">
            Preencha as informações do novo grupo.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form id="add-home-group-form" onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <Controller
              name="locationText"
              control={form.control}
              render={({ field, fieldState }) => (
                <Field data-invalid={fieldState.invalid}>
                  <FieldLabel>Endereço Completo*</FieldLabel>
                  <div className="relative group">
                    <Input 
                        {...field} 
                        placeholder="Rua, Número, Bairro, Cidade" 
                        className="pr-10 bg-background/50 border-border group-data-[invalid=true]:border-destructive"
                    />
                    <div className="absolute right-3 top-1/2 -translate-y-1/2">
                      {geocoding ? (
                        <Loader2 className="h-4 w-4 animate-spin text-primary" />
                      ) : (
                        <MapPinIcon className="h-4 w-4 text-muted-foreground group-hover:text-primary transition-colors" />
                      )}
                    </div>
                  </div>
                  <FieldError errors={[fieldState.error]} />
                </Field>
              )}
            />

            <div className="grid grid-cols-2 gap-4">
                <Controller
                  name="meetingDay"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel>Dia da Reunião*</FieldLabel>
                      <select
                        {...field}
                        value={field.value}
                        onChange={(e) => field.onChange(parseInt(e.target.value, 10))}
                        className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
                      >
                        {daysOfWeek.map((day) => (
                          <option key={day.value} value={day.value}>
                            {day.label}
                          </option>
                        ))}
                      </select>
                      <FieldError errors={[fieldState.error]} />
                    </Field>
                  )}
                />

                <Controller
                  name="startTime"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel>Horário*</FieldLabel>
                      <div className="relative">
                        <Input 
                            {...field} 
                            type="time" 
                            className="bg-background/50 border-border"
                        />
                        <ClockIcon className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
                      </div>
                      <FieldError errors={[fieldState.error]} />
                    </Field>
                  )}
                />
            </div>

            <div className="space-y-4 pt-2 border-t border-border/50">
                <Controller
                  name="leader1Id"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel className="flex items-center gap-2">
                        Líder Principal*
                        {loadingLeaders && <Loader2 className="h-3 w-3 animate-spin" />}
                      </FieldLabel>
                      <Combobox 
                        value={leaders.find(l => l.id === field.value)?.full_name || ""} 
                        onValueChange={(name) => {
                          const leader = leaders.find(l => l.full_name === name);
                          if (leader) field.onChange(leader.id);
                        }}
                      >
                        <ComboboxInput 
                            placeholder="Buscar por nome..." 
                            className="bg-background/50"
                        >
                            <SearchIcon className="h-4 w-4 text-muted-foreground" />
                        </ComboboxInput>
                        <ComboboxContent>
                          <ComboboxList>
                            {leaders.map((leader) => (
                              <ComboboxItem key={leader.id} value={leader.full_name}>
                                {leader.full_name}
                              </ComboboxItem>
                            ))}
                          </ComboboxList>
                          <ComboboxEmpty>Nenhum membro encontrado.</ComboboxEmpty>
                        </ComboboxContent>
                      </Combobox>
                      <FieldError errors={[fieldState.error]} />
                    </Field>
                  )}
                />

                <Controller
                  name="leader2Id"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel>Segundo Líder (Opcional)</FieldLabel>
                      <Combobox 
                        value={leaders.find(l => l.id === field.value)?.full_name || ""} 
                        onValueChange={(name) => {
                          if (!name) {
                            field.onChange(null);
                            return;
                          }
                          const leader = leaders.find(l => l.full_name === name);
                          if (leader) field.onChange(leader.id);
                        }}
                      >
                        <ComboboxInput 
                            placeholder="Buscar por nome..." 
                            className="bg-background/50"
                        />
                        <ComboboxContent>
                          <ComboboxList>
                            <ComboboxItem value="">Nenhum (Remover)</ComboboxItem>
                            {leaders.map((leader) => (
                              <ComboboxItem key={leader.id} value={leader.full_name}>
                                {leader.full_name}
                              </ComboboxItem>
                            ))}
                          </ComboboxList>
                          <ComboboxEmpty>Nenhum membro encontrado.</ComboboxEmpty>
                        </ComboboxContent>
                      </Combobox>
                      <FieldError errors={[fieldState.error]} />
                    </Field>
                  )}
                />
            </div>
          </form>
        </CardContent>
        <CardFooter>
          <Button
            className="w-full bg-primary hover:bg-primary/95 text-primary-foreground font-bold h-12 rounded-xl transition-all shadow-lg shadow-primary/20 active:scale-[0.98]"
            type="submit"
            form="add-home-group-form"
            disabled={submitting}
          >
            {submitting ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Salvando grupo...
              </>
            ) : (
              "Adicionar Grupo Caseiro"
            )}
          </Button>
        </CardFooter>
      </Card>
    </div>
  );
}
