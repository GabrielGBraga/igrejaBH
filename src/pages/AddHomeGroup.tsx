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
import { SearchIcon, Loader2, ArrowLeftIcon, MapPinIcon, ClockIcon } from "lucide-react";
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

// Fix para ícones do Leaflet que quebram no React/Vite
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

// Componente para lidar com cliques no mapa e atualização de posição
function MapEventsHandler({ onChange }: { onChange: (lat: number, lng: number) => void }) {
  useMapEvents({
    click(e) {
      onChange(e.latlng.lat, e.latlng.lng);
      toast.info("Localização ajustada manualmente", { duration: 1500 });
    },
  });
  return null;
}

// Componente para recentralizar o mapa quando as coordenadas mudam via geocodificação
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

  // Fetch all profiles to select as leaders
  useEffect(() => {
    async function fetchLeaders() {
      try {
        const { data, error } = await supabase
          .from("profiles")
          .select("id, full_name") // Changed to 'id' to match Member interface
          .order("full_name");
        
        if (error) throw error;
        // Map to Member interface if necessary, assuming 'id' is already the user_id
        const formattedUsers = data.map((u) => ({
          id: u.id, // Assuming 'id' from profiles table is the user_id
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

  // Geocoding effect
  useEffect(() => {
    if (!locationText || locationText.length < 8) return;

    const timer = setTimeout(async () => {
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

  return (
    <div className="relative min-h-screen flex items-center justify-center py-10 px-4 bg-background overflow-x-hidden">
      {/* Background elements */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/20 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-secondary/20 blur-[120px]" />
      </div>

      <Card className="w-full max-w-2xl border-border bg-card/60 backdrop-blur-xl shadow-2xl relative z-10 animate-in fade-in zoom-in-95 duration-500">
        <CardHeader className="space-y-1">
          <div className="flex items-center justify-between mb-4">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate("/")}
              className="group text-muted-foreground hover:text-foreground"
            >
              <ArrowLeftIcon className="mr-2 h-4 w-4 transition-transform group-hover:-translate-x-1" />
              Voltar
            </Button>
          </div>
          <CardTitle className="text-3xl font-bold tracking-tight text-center">
            Novo Grupo Caseiro
          </CardTitle>
          <CardDescription className="text-center text-muted-foreground">
            Preencha as informações do novo grupo.
          </CardDescription>
        </CardHeader>
        <CardContent>
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
                       {geocoding && <Loader2 className="h-3 w-3 animate-spin" />}
                    </FieldLabel>
                    <InputGroup>
                      <InputGroupInput 
                        {...field} 
                        placeholder="Ex: Rua José de Antenor 260, Heliópolis" 
                        autoComplete="off"
                        className="pr-10"
                      />
                      <InputGroupAddon align="inline-end">
                        <MapPinIcon className={`h-4 w-4 ${currentLat ? 'text-primary' : 'text-muted-foreground'}`} />
                      </InputGroupAddon>
                    </InputGroup>
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />

              {/* Mapa Interativo */}
              <div className="space-y-2">
                <FieldLabel>Localização no Mapa</FieldLabel>
                <div className="relative h-64 w-full rounded-xl overflow-hidden border border-border/50 shadow-inner group">
                  <MapContainer
                    center={currentLat && currentLng ? [currentLat, currentLng] : [-19.9167, -43.9345]} // BH por padrão
                    zoom={13}
                    style={{ height: "100%", width: "100%" }}
                    className="z-0"
                  >
                    <TileLayer
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                      attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                    />
                    <MapEventsHandler onChange={handleMapChange} />
                    <MapRecenter center={currentLat && currentLng ? [currentLat, currentLng] : null} />
                    {currentLat && currentLng && (
                      <Marker position={[currentLat, currentLng]} />
                    )}
                  </MapContainer>
                  {!currentLat && (
                    <div className="absolute inset-0 bg-background/60 backdrop-blur-[2px] z-10 flex flex-col items-center justify-center p-4 text-center">
                      <MapPinIcon className="h-8 w-8 text-muted-foreground mb-2 animate-bounce" />
                      <p className="text-sm font-medium text-muted-foreground">
                        Digite o endereço acima ou clique no mapa para marcar a localização.
                      </p>
                    </div>
                  )}
                </div>
                <p className="text-[10px] text-muted-foreground italic">
                  * Você pode clicar no mapa para ajustar a posição exata da casa.
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <Controller
                  name="meetingDay"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel>Dia da Reunião*</FieldLabel>
                      <select
                        {...field}
                        className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
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
                        Horário*
                        <ClockIcon className="h-3 w-3 text-muted-foreground" />
                      </FieldLabel>
                      <Input {...field} type="time" className="bg-background/50" />
                      <FieldError errors={[fieldState.error]} />
                    </Field>
                  )}
                />
              </div>

              <FieldGroup className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
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
              </FieldGroup>
            </FieldGroup>
          </form>
        </CardContent>
        <CardFooter>
          <Button
            type="submit"
            form="add-home-group-form"
            className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-semibold h-12 transition-all active:scale-[0.98]"
            disabled={submitting}
          >
            {submitting ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Salvando Grupo...
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
