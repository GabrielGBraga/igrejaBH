import { useEffect, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { MapPinIcon, Users } from "lucide-react";
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

interface HomeGroupData {
  id: string;
  meeting_day?: number | null;
  location_text: string | null;
  lat: number | null;
  lng: number | null;
  sector_id?: string | null;
  leader_1_id?: string | null;
  leader_2_id?: string | null;
}

interface Sector {
  id: string;
  name: string;
}

const getSectorColor = (sectorId: string | null) => {
  if (!sectorId) return "#a1a1aa";
  const colors = [
    "#ef4444", // Red
    "#3b82f6", // Blue
    "#10b981", // Emerald
    "#f59e0b", // Amber
    "#8b5cf6", // Violet
    "#ec4899", // Pink
    "#14b8a6", // Teal
    "#f97316", // Orange
  ];
  let hash = 0;
  for (let i = 0; i < sectorId.length; i++) {
    hash = sectorId.charCodeAt(i) + ((hash << 5) - hash);
  }
  const index = Math.abs(hash) % colors.length;
  return colors[index];
};

const createMarkerIcon = (color: string) => {
  return L.divIcon({
    html: `<div style="
      background-color: ${color};
      width: 14px;
      height: 14px;
      border-radius: 50%;
      border: 2px solid white;
      box-shadow: 0 0 4px rgba(0,0,0,0.4);
    "></div>`,
    className: "custom-sector-marker",
    iconSize: [14, 14],
    iconAnchor: [7, 7],
  });
};

const dayMap: Record<number, string> = {
  0: "Domingo",
  1: "Segunda-feira",
  2: "Terça-feira",
  3: "Quarta-feira",
  4: "Quinta-feira",
  5: "Sexta-feira",
  6: "Sábado",
};

interface ChurchMapProps {
  homeGroups?: HomeGroupData[];
  sectors?: Sector[];
  colorLabelingBySector?: boolean;
  getGroupLeadersName?: (hg: any) => string;
  hideHeader?: boolean;
}

export function ChurchMap({
  homeGroups: externalHomeGroups,
  sectors = [],
  colorLabelingBySector = false,
  getGroupLeadersName,
  hideHeader = false,
}: ChurchMapProps) {
  const [internalHomeGroups, setInternalHomeGroups] = useState<HomeGroupData[]>([]);
  const [loading, setLoading] = useState(false);
  const mapRef = useRef<L.Map | null>(null);

  const homeGroups = externalHomeGroups || internalHomeGroups;

  useEffect(() => {
    if (externalHomeGroups) return;

    async function fetchHomeGroups() {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from("home_groups")
          .select("*")
          .not("lat", "is", null)
          .not("lng", "is", null);

        if (error) {
          console.error("Error fetching home groups:", error);
        } else if (data) {
          setInternalHomeGroups(data as unknown as HomeGroupData[]);
        }
      } catch (err) {
        console.error("Failed to load home groups:", err);
      } finally {
        setLoading(false);
      }
    }

    fetchHomeGroups();
  }, [externalHomeGroups]);

  const centerPosition: [number, number] = [-19.9226463, -43.935]; // Belo Horizonte center

  return (
    <Card className={`h-full border-border bg-card/40 backdrop-blur-md shadow-xl flex flex-col ${hideHeader ? "border-none shadow-none bg-transparent" : ""}`}>
      {!hideHeader && (
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
      )}
      <CardContent className={`flex-1 flex flex-col p-4 pt-0 ${hideHeader ? "p-0" : ""}`}>
        <div className="w-full flex-1 min-h-[400px] rounded-xl overflow-hidden border border-border/50 shadow-inner relative group isolate bg-secondary/10">
          {!loading && (
            <MapContainer
              ref={mapRef}
              center={centerPosition}
              zoom={12}
              scrollWheelZoom={false}
              className="absolute inset-0 w-full h-full z-0"
              style={{ height: "100%", width: "100%" }}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              


              {/* Home Groups Markers */}
              {homeGroups
                .filter((g) => g.lat !== null && g.lng !== null)
                .map((group) => {
                  const color = colorLabelingBySector ? getSectorColor(group.sector_id || null) : "";
                  const markerIcon = colorLabelingBySector ? createMarkerIcon(color) : DefaultIcon;
                  const sec = colorLabelingBySector && group.sector_id ? sectors.find(s => s.id === group.sector_id) : null;
                  const groupTitle = getGroupLeadersName ? `GC - ${getGroupLeadersName(group)}` : "Grupo Caseiro";

                  return (
                    <Marker 
                      key={group.id} 
                      position={[group.lat!, group.lng!]}
                      icon={markerIcon}
                    >
                      <Popup className="min-w-[220px]">
                        <div className="flex flex-col gap-2">
                          <div className="flex items-center gap-2 font-semibold text-sm m-0 text-primary">
                            <Users className="w-4 h-4" />
                            {groupTitle}
                          </div>
                          <div className="text-xs text-muted-foreground m-0 flex flex-col gap-1">
                            {group.meeting_day !== undefined && group.meeting_day !== null && (
                              <span className="font-medium text-foreground">
                                {dayMap[group.meeting_day] || "Dia a definir"}
                              </span>
                            )}
                            <span>{group.location_text}</span>
                            {colorLabelingBySector && (
                              <span className="inline-block mt-1 font-semibold px-2 py-0.5 rounded text-[10px] w-fit" style={{ backgroundColor: `${color}15`, color: color, border: `1px solid ${color}40` }}>
                                Setor: {sec ? sec.name : "Sem Setor"}
                              </span>
                            )}
                          </div>
                        </div>
                      </Popup>
                    </Marker>
                  );
                })}
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
                  ? `${homeGroups.length} group(s) encontrado(s)` 
                  : loading ? "Carregando..." : "Nenhum grupo com localização"}
              </p>
            </div>

          </div>
        </div>
      </CardContent>
    </Card>
  );
}
