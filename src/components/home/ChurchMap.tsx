import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { MapPinIcon, Users } from "lucide-react";
import { MapContainer, TileLayer, Marker, Popup, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import supabase from "@/lib/supabase";
import type { Database } from "@/lib/database.types";

// Fix for default marker icons in react-leaflet
import icon from "leaflet/dist/images/marker-icon.png";
import iconShadow from "leaflet/dist/images/marker-shadow.png";

const DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
});

L.Marker.prototype.options.icon = DefaultIcon;

export type HomeGroupData = Database["public"]["Tables"]["home_groups"]["Row"];

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

const createMarkerIcon = (color: string, count?: number) => {
  const displayCount = typeof count === "number" ? count : "";
  return L.divIcon({
    html: `
      <div style="
        display: flex;
        flex-direction: column;
        align-items: center;
        width: 32px;
        height: 38px;
        cursor: pointer;
      ">
        <div style="
          display: flex;
          align-items: center;
          justify-content: center;
          min-width: 28px;
          height: 28px;
          padding: 0 4px;
          background-color: ${color};
          color: #ffffff;
          font-size: 11px;
          font-weight: 800;
          font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          border-radius: 9999px;
          border: 2px solid #ffffff;
          box-shadow: 0 3px 8px rgba(0, 0, 0, 0.45);
          text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
          line-height: 1;
        ">
          ${displayCount}
        </div>
        <div style="
          width: 0;
          height: 0;
          border-left: 5px solid transparent;
          border-right: 5px solid transparent;
          border-top: 6px solid ${color};
          margin-top: -2px;
          filter: drop-shadow(0 2px 2px rgba(0, 0, 0, 0.3));
        "></div>
      </div>
    `,
    className: "custom-sector-marker",
    iconSize: [32, 38],
    iconAnchor: [16, 36],
    popupAnchor: [0, -36],
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

export interface ChurchMapProps {
  homeGroups?: HomeGroupData[];
  sectors?: Sector[];
  colorLabelingBySector?: boolean;
  getGroupLeadersName?: (hg: HomeGroupData) => string;
  groupMemberCounts?: Map<string, number> | Record<string, number>;
  hideHeader?: boolean;
  scrollWheelZoom?: boolean;
}

// Subcomponente interno que recalibra o tamanho e enquadramento do mapa
function MapController({
  homeGroups,
  scrollWheelZoom = true,
}: {
  homeGroups: HomeGroupData[];
  scrollWheelZoom?: boolean;
}) {
  const map = useMap();

  useEffect(() => {
    // Força o Leaflet a recalcular as dimensões exatas na tela
    map.invalidateSize();
    const t1 = setTimeout(() => map.invalidateSize(), 100);
    const t2 = setTimeout(() => map.invalidateSize(), 350);
    const t3 = setTimeout(() => map.invalidateSize(), 800);

    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
    };
  }, [map]);

  useEffect(() => {
    if (scrollWheelZoom) {
      map.scrollWheelZoom.enable();
    } else {
      map.scrollWheelZoom.disable();
    }
  }, [map, scrollWheelZoom]);

  useEffect(() => {
    const valid = homeGroups.filter(
      (g) => typeof g.lat === "number" && typeof g.lng === "number"
    );
    if (valid.length > 0) {
      const bounds = L.latLngBounds(
        valid.map((g) => [g.lat!, g.lng!] as [number, number])
      );
      if (bounds.isValid()) {
        map.fitBounds(bounds, { padding: [40, 40], maxZoom: 14 });
      }
    }
  }, [homeGroups, map]);

  return null;
}

export function ChurchMap({
  homeGroups: externalHomeGroups,
  sectors = [],
  colorLabelingBySector = false,
  getGroupLeadersName,
  groupMemberCounts,
  hideHeader = false,
  scrollWheelZoom = true,
}: ChurchMapProps) {
  const [internalHomeGroups, setInternalHomeGroups] = useState<HomeGroupData[]>([]);
  const [loading, setLoading] = useState(false);

  const getMemberCount = (groupId: string): number => {
    if (!groupMemberCounts) return 0;
    if (groupMemberCounts instanceof Map) {
      return groupMemberCounts.get(groupId) || 0;
    }
    return (groupMemberCounts as Record<string, number>)[groupId] || 0;
  };

  // Usar os grupos externos se fornecidos, senão buscar internamente
  const homeGroups = externalHomeGroups || internalHomeGroups;

  useEffect(() => {
    if (externalHomeGroups && externalHomeGroups.length > 0) return;

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
    <Card className={`border-border bg-card shadow-sm flex flex-col ${hideHeader ? "border-none shadow-none bg-transparent" : ""}`}>
      {!hideHeader && (
        <CardHeader className="pb-3">
          <div className="flex flex-row justify-between items-start gap-4">
            <div>
              <CardTitle className="text-lg font-bold flex items-center gap-2 text-foreground">
                <MapPinIcon className="w-5 h-5 text-primary" />
                Grupos Caseiros na Cidade
              </CardTitle>
              <CardDescription className="mt-0.5 text-xs">
                Localização dos Grupos Caseiros em Belo Horizonte e Região Metropolitana.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
      )}
      <CardContent className={`p-4 pt-0 ${hideHeader ? "p-0" : ""}`}>
        <div className="w-full h-[450px] sm:h-[480px] rounded-xl overflow-hidden border border-border/70 shadow-inner relative group isolate bg-muted/20">
          {!loading && (
            <MapContainer
              center={centerPosition}
              zoom={12}
              scrollWheelZoom={scrollWheelZoom}
              className="h-full w-full z-0"
              style={{ height: "100%", width: "100%", minHeight: "450px" }}
            >
              <MapController homeGroups={homeGroups} scrollWheelZoom={scrollWheelZoom} />
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />

              {/* Marcadores dos Grupos Caseiros */}
              {homeGroups
                .filter((g) => g.lat !== null && g.lng !== null)
                .map((group) => {
                  const color = colorLabelingBySector ? getSectorColor(group.sector_id || null) : "#10b981";
                  const memberCount = getMemberCount(group.id);
                  const markerIcon = createMarkerIcon(color, memberCount);
                  const sec = colorLabelingBySector && group.sector_id ? sectors.find(s => s.id === group.sector_id) : null;
                  const groupTitle = getGroupLeadersName ? getGroupLeadersName(group) : (group.location_text || "Grupo Caseiro");

                  return (
                    <Marker 
                      key={group.id} 
                      position={[group.lat!, group.lng!]}
                      icon={markerIcon}
                    >
                      <Popup className="min-w-[220px]">
                        <div className="flex flex-col gap-1.5 p-1">
                          <div className="flex items-center gap-2 font-semibold text-sm text-primary">
                            <Users className="w-4 h-4" />
                            <span>{groupTitle}</span>
                          </div>
                          {memberCount > 0 && (
                            <div className="text-xs font-semibold text-foreground/90 bg-muted/50 px-2 py-0.5 rounded-md w-fit">
                              {memberCount} discípulo(s) vinculado(s)
                            </div>
                          )}
                          <div className="text-xs text-muted-foreground flex flex-col gap-1">
                            {group.meeting_day !== undefined && group.meeting_day !== null && (
                              <span className="font-medium text-foreground">
                                {dayMap[group.meeting_day] || "Dia a definir"}
                              </span>
                            )}
                            <span>{group.location_text}</span>
                            {colorLabelingBySector && (
                              <span
                                className="inline-block mt-1 font-semibold px-2 py-0.5 rounded text-[10px] w-fit"
                                style={{
                                  backgroundColor: `${color}18`,
                                  color: color,
                                  border: `1px solid ${color}40`,
                                }}
                              >
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

          {/* Legenda compacta no rodapé do mapa */}
          <div className="absolute bottom-3 left-3 bg-background/90 backdrop-blur-md px-3 py-1.5 rounded-lg border border-border shadow-md flex items-center gap-2 z-[400] pointer-events-none">
            <MapPinIcon className="w-3.5 h-3.5 text-primary" />
            <span className="text-xs font-medium text-foreground">
              {homeGroups.filter((g) => g.lat !== null && g.lng !== null).length} grupo(s) no mapa
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
