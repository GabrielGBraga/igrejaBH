import { useEffect, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { NavigationIcon, MapPinIcon, Users } from "lucide-react";
import { Button } from "@/components/ui/button";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import supabase from "@/lib/supabase";

// Fix for default marker icons in react-leaflet
import icon from "leaflet/dist/images/marker-icon.png";
import iconShadow from "leaflet/dist/images/marker-shadow.png";

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
});

L.Marker.prototype.options.icon = DefaultIcon;

interface HomeGroup {
  id: string;
  name: string;
  meeting_day: number;
  location_text: string;
  lat: number;
  lng: number;
}

const dayMap: Record<number, string> = {
  0: "Domingo",
  1: "Segunda-feira",
  2: "Terça-feira",
  3: "Quarta-feira",
  4: "Quinta-feira",
  5: "Sexta-feira",
  6: "Sábado",
};

export function ChurchMap() {
  const [homeGroups, setHomeGroups] = useState<HomeGroup[]>([]);
  const [loading, setLoading] = useState(true);
  // Holds the Leaflet Map instance so we can call map.remove() on cleanup,
  // which properly clears _leaflet_id and prevents Strict Mode double-init.
  const mapRef = useRef<L.Map | null>(null);

  useEffect(() => {
    async function fetchHomeGroups() {
      try {
        const { data, error } = await supabase
          .from("home_groups")
          .select("*")
          .not("lat", "is", null)
          .not("lng", "is", null);

        if (error) {
          console.error("Error fetching home groups:", error);
        } else if (data) {
          setHomeGroups(data as unknown as HomeGroup[]);
        }
      } catch (err) {
        console.error("Failed to load home groups:", err);
      } finally {
        setLoading(false);
      }
    }

    fetchHomeGroups();

    // On unmount (including React Strict Mode's simulated unmount), properly
    // remove the Leaflet instance so the container is clean for the next mount.
    return () => {
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
  }, []);

  const centerPosition: [number, number] = [-19.9226463, -43.935]; // Belo Horizonte center

  return (
    <Card className="h-full border-border bg-card/40 backdrop-blur-md shadow-xl flex flex-col">
      <CardHeader className="pb-4">
        <div className="flex flex-row justify-between items-start gap-4">
          <div>
            <CardTitle className="text-xl font-bold flex items-center gap-2">
              <MapPinIcon className="w-5 h-5 text-primary" />
              Grupos Caseiros e Localização
            </CardTitle>
            <CardDescription className="mt-1">
              Encontre um grupo caseiro perto de você em Belo Horizonte.
            </CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent className="flex-1 flex flex-col p-4 pt-0">
        <div className="w-full flex-1 min-h-[400px] rounded-xl overflow-hidden border border-border/50 shadow-inner relative group isolate bg-secondary/10">
          {!loading && (
            <MapContainer
              ref={mapRef}
              center={centerPosition}
              zoom={13}
              scrollWheelZoom={false}
              className="absolute inset-0 w-full h-full z-0"
              style={{ height: "100%", width: "100%" }}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              
              {/* Main Church Location Marker */}
              <Marker position={centerPosition}>
                <Popup className="min-w-[200px]">
                  <div className="flex flex-col gap-2">
                    <p className="font-semibold text-sm m-0">Igreja em BH Central</p>
                    <p className="text-xs text-muted-foreground m-0">Sede Principal</p>
                    <Button size="sm" className="w-full mt-2 h-8 text-xs bg-primary hover:bg-primary/90">
                      <NavigationIcon className="w-3 h-3 mr-1" />
                      Como Chegar
                    </Button>
                  </div>
                </Popup>
              </Marker>

              {/* Home Groups Markers */}
              {homeGroups.map((group) => (
                <Marker key={group.id} position={[group.lat, group.lng]}>
                  <Popup className="min-w-[220px]">
                    <div className="flex flex-col gap-2">
                      <div className="flex items-center gap-2 font-semibold text-sm m-0 text-primary">
                        <Users className="w-4 h-4" />
                        {group.name}
                      </div>
                      <div className="text-xs text-muted-foreground m-0 flex flex-col gap-1">
                        <span className="font-medium text-foreground">
                          {dayMap[group.meeting_day] || "Dia a definir"}
                        </span>
                        <span>{group.location_text}</span>
                      </div>
                    </div>
                  </Popup>
                </Marker>
              ))}
            </MapContainer>
          )}

          {/* Glassmorphism Overlay Info */}
          <div className="absolute bottom-4 left-4 right-4 bg-background/80 backdrop-blur-md p-4 rounded-lg border border-border shadow-lg flex items-center justify-between z-1000 pointer-events-none">
            <div>
              <p className="font-semibold text-foreground text-sm flex items-center gap-2">
                <MapPinIcon className="w-4 h-4 text-primary" />
                Grupos Caseiros
              </p>
              <p className="text-xs text-muted-foreground mt-0.5">
                {homeGroups.length > 0 
                  ? `${homeGroups.length} grupo(s) encontrado(s)` 
                  : loading ? "Carregando..." : "Nenhum grupo com localização"}
              </p>
            </div>
            <div className="pointer-events-auto">
              <Button size="sm" variant="outline" className="bg-background/50 hover:bg-background">
                <NavigationIcon className="w-4 h-4 mr-2" />
                Igreja Central
              </Button>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
