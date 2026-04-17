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
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group";
import { Loader2, MapPinIcon, ClockIcon } from "lucide-react";
import { useState, useEffect, useCallback } from "react";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import { useNavigate } from "react-router-dom";
import {
  Combobox,
  ComboboxContent,
  ComboboxEmpty,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from "@/components/ui/combobox";
import {
  MapContainer,
  TileLayer,
  Marker,
  useMapEvents,
  useMap,
} from "react-leaflet";
import L from "leaflet";

delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

interface Member {
  id: string;
  full_name: string;
}

function MapEventsHandler({ onChange }: { onChange: (lat: number, lng: number) => void }) {
  useMapEvents({
    click(e) {
      onChange(e.latlng.lat, e.latlng.lng);
      toast.info("Localização ajustada manualmente", { duration: 1500 });
    },
  });
  return null;
}

function MapRecenter({ center }: { center: [number, number] | null }) {
  const map = useMap();
  useEffect(() => {
    if (center) {
      map.setView(center, 16);
    }
  }, [center, map]);
  return null;
}

export default function AddHomeGroup() {
  const navigate = useNavigate();
  const [submitting, setSubmitting] = useState(false);
  const [leaders, setLeaders] = useState<Member[]>([]);
  const [loadingLeaders, setLoadingLeaders] = useState(true);
  const [geocoding, setGeocoding] = useState(false);

  const form = useForm<HomeGroupValue>({
    resolver: zodResolver(homeGroupSchema),
    defaultValues: {
      meetingDay: 1,
      startTime: "20:00",
      locationText: "",
      leader1Id: "",
      leader2Id: null,
      lat: null,
      lng: null,
    },
  });

  const locationText = form.watch("locationText");
  const currentLat = form.watch("lat");
  const currentLng = form.watch("lng");

  useEffect(() => {
    async function fetchLeaders() {
      try {
        const { data, error } = await supabase
          .from("profiles")
          .select("id, full_name")
          .order("full_name");
        
        if (error) throw error;
        const formattedUsers = data.map((u) => ({
          id: u.id,
          full_name: u.full_name,
        }));
        setLeaders(formattedUsers || []);
      } catch (error) {
        console.error("Error fetching leaders:", error);
        toast.error("Erro ao carregar lista de membros.");
      } finally {
        setLoadingLeaders(false);
      }
    }
    fetchLeaders();
  }, []);

  useEffect(() => {
    if (!locationText || locationText.length < 8) return;

    const timer = setTimeout(async () => {
      setGeocoding(true);
      try {
        const baseAddress = locationText
          .replace(/,\s*(ap|apto|sala|bloco)\s*\d+/gi, "")
          .replace(/\s+(ap|apto|sala|bloco)\s*\d+/gi, "");

        const queries = [
          baseAddress.toLowerCase().includes("belo horizonte") ? baseAddress : `${baseAddress}, Belo Horizonte, MG`,
          baseAddress.replace(/\s+(de|da|do|das|dos)\s+/gi, " ") + ", Belo Horizonte, MG",
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
              description: `Ajuste o pino no mapa se necessário.`
            });
            found = true;
          }
        }
      } catch (error) {
        console.error("Geocoding error:", error);
      } finally {
        setGeocoding(false);
      }
    }, 1500);

    return () => clearTimeout(timer);
  }, [locationText, form]);

  const handleMapChange = useCallback((lat: number, lng: number) => {
    form.setValue("lat", lat);
    form.setValue("lng", lng);
  }, [form]);

  async function onSubmit(data: HomeGroupValue) {
    if (!data.lat || !data.lng) {
      toast.error("Por favor, aguarde a localização ser encontrada ou revise o endereço.");
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
      error: "Erro ao salvar grupo caseiro.",
      finally: () => setSubmitting(false),
    });
  }

  return (
    <div className="max-w-3xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="border-b border-border pb-6 mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Novo Grupo Caseiro</h1>
        <p className="text-muted-foreground mt-1">Configure um novo local de reunião e seus líderes.</p>
      </div>

      <Card className="border-border bg-card/30 backdrop-blur-sm shadow-xl rounded-3xl overflow-hidden">
        <CardHeader className="space-y-1 p-8">
          <CardTitle className="text-2xl font-bold">Informações Básicas</CardTitle>
          <CardDescription>
            Digite o endereço para que possamos localizá-lo no mapa automaticamente.
          </CardDescription>
        </CardHeader>
        <CardContent className="px-8 pb-8">
          <form
            id="add-home-group-form"
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-8"
          >
            <FieldGroup className="space-y-6">
              <Controller
                name="locationText"
                control={form.control}
                render={({ field, fieldState }) => (
                  <Field data-invalid={fieldState.invalid}>
                    <FieldLabel className="flex items-center gap-2">
                       Endereço Completo*
                       {geocoding && <Loader2 className="h-3 w-3 animate-spin text-primary" />}
                    </FieldLabel>
                    <InputGroup>
                      <InputGroupInput 
                        {...field} 
                        placeholder="Ex: Rua José de Antenor 260, Heliópolis" 
                        autoComplete="off"
                        className="bg-background/50 rounded-xl"
                      />
                      <InputGroupAddon align="inline-end">
                        <MapPinIcon className={`h-4 w-4 ${currentLat ? 'text-primary' : 'text-muted-foreground'}`} />
                      </InputGroupAddon>
                    </InputGroup>
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />

              <div className="space-y-3">
                <FieldLabel>Localização Geográfica</FieldLabel>
                <div className="relative h-72 w-full rounded-2xl overflow-hidden border border-border/50 shadow-inner group">
                  <MapContainer
                    center={currentLat && currentLng ? [currentLat, currentLng] : [-19.9167, -43.9345]}
                    zoom={13}
                    style={{ height: "100%", width: "100%" }}
                    className="z-0"
                  >
                    <TileLayer
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    />
                    <MapEventsHandler onChange={handleMapChange} />
                    <MapRecenter center={currentLat && currentLng ? [currentLat, currentLng] : null} />
                    {currentLat && currentLng && <Marker position={[currentLat, currentLng]} />}
                  </MapContainer>
                  {!currentLat && (
                    <div className="absolute inset-0 bg-background/60 backdrop-blur-[2px] z-10 flex flex-col items-center justify-center p-4 text-center">
                      <MapPinIcon className="h-8 w-8 text-primary mb-2 animate-bounce" />
                      <p className="text-sm font-medium text-muted-foreground max-w-[200px]">
                        Digite o endereço ou marque diretamente no mapa.
                      </p>
                    </div>
                  )}
                </div>
                <p className="text-[10px] text-muted-foreground font-medium uppercase tracking-wider">
                  * Você pode ajustar o pino manualmente se a localização automática falhar.
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4">
                <Controller
                  name="meetingDay"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel>Dia da Reunião*</FieldLabel>
                      <select
                        {...field}
                        className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                        onChange={(e) => field.onChange(parseInt(e.target.value))}
                      >
                        <option value={1}>Segunda-feira</option>
                        <option value={2}>Terça-feira</option>
                        <option value={3}>Quarta-feira</option>
                        <option value={4}>Quinta-feira</option>
                        <option value={5}>Sexta-feira</option>
                        <option value={6}>Sábado</option>
                        <option value={0}>Domingo</option>
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
                      <FieldLabel className="flex items-center gap-2">
                        Horário de Início*
                        <ClockIcon className="h-3 w-3 text-muted-foreground" />
                      </FieldLabel>
                      <Input {...field} type="time" className="bg-background/50 h-11 rounded-xl" />
                      <FieldError errors={[fieldState.error]} />
                    </Field>
                  )}
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t border-border/50">
                <Controller
                  name="leader1Id"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel className="flex items-center gap-2">
                        Líder 1*
                        {loadingLeaders && <Loader2 className="h-3 w-3 animate-spin" />}
                      </FieldLabel>
                      <Combobox 
                        value={leaders.find(l => l.id === field.value)?.full_name || ""} 
                        onValueChange={(name) => {
                          const leader = leaders.find(l => l.full_name === name);
                          if (leader) field.onChange(leader.id);
                        }}
                      >
                        <ComboboxInput placeholder="Buscar líder..." className="bg-background/50 h-11 rounded-xl" />
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
                      <FieldLabel>Líder 2 (Opcional)</FieldLabel>
                      <Combobox 
                        value={leaders.find(l => l.id === field.value)?.full_name || ""} 
                        onValueChange={(name) => {
                          if (!name) { field.onChange(null); return; }
                          const leader = leaders.find(l => l.full_name === name);
                          if (leader) field.onChange(leader.id);
                        }}
                      >
                        <ComboboxInput placeholder="Buscar líder..." className="bg-background/50 h-11 rounded-xl" />
                        <ComboboxContent>
                          <ComboboxList>
                            <ComboboxItem value="">Nenhum</ComboboxItem>
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
            </FieldGroup>
          </form>
        </CardContent>
        <CardFooter className="px-8 pb-8 flex flex-col gap-4">
          <Button
            type="submit"
            form="add-home-group-form"
            className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-bold h-14 rounded-2xl transition-all shadow-lg shadow-primary/20"
            disabled={submitting}
          >
            {submitting ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Salvando Grupo...
              </>
            ) : (
              "Adicionar Grupo Caseiro"
            )}
          </Button>
          <p className="text-center text-[11px] text-muted-foreground font-medium uppercase tracking-tighter">
            Campos marcados com * são obrigatórios.
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}
