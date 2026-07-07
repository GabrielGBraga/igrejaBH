import { useEffect, useRef, useState } from "react"
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "@/components/ui/card"
import { NavigationIcon, MapPinIcon, Users } from "lucide-react"
import { Button } from "@/components/ui/button"
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet"
import "leaflet/dist/leaflet.css"
import L from "leaflet"
import supabase from "@/lib/supabase"

// Fix for default marker icons in react-leaflet
import icon from "leaflet/dist/images/marker-icon.png"
import iconShadow from "leaflet/dist/images/marker-shadow.png"

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
})

L.Marker.prototype.options.icon = DefaultIcon

interface HomeGroup {
  id: string
  meeting_day: number
  location_text: string
  lat: number
  lng: number
}

const dayMap: Record<number, string> = {
  0: "Domingo",
  1: "Segunda-feira",
  2: "Terça-feira",
  3: "Quarta-feira",
  4: "Quinta-feira",
  5: "Sexta-feira",
  6: "Sábado",
}

export function ChurchMap() {
  const [homeGroups, setHomeGroups] = useState<HomeGroup[]>([])
  const [loading, setLoading] = useState(true)
  // Holds the Leaflet Map instance so we can call map.remove() on cleanup,
  // which properly clears _leaflet_id and prevents Strict Mode double-init.
  const mapRef = useRef<L.Map | null>(null)

  useEffect(() => {
    async function fetchHomeGroups() {
      try {
        const { data, error } = await supabase
          .from("home_groups")
          .select("*")
          .not("lat", "is", null)
          .not("lng", "is", null)

        if (error) {
          console.error("Error fetching home groups:", error)
        } else if (data) {
          setHomeGroups(data as unknown as HomeGroup[])
        }
      } catch (err) {
        console.error("Failed to load home groups:", err)
      } finally {
        setLoading(false)
      }
    }

    fetchHomeGroups()

    // Cleanup handles itself via react-leaflet
    return () => {}
  }, [])

  const centerPosition: [number, number] = [-19.9226463, -43.935] // Belo Horizonte center

  return (
    <Card className="flex h-full flex-col border-border bg-card/40 shadow-xl backdrop-blur-md">
      <CardHeader className="pb-4">
        <div className="flex flex-row items-start justify-between gap-4">
          <div>
            <CardTitle className="flex items-center gap-2 text-xl font-bold">
              <MapPinIcon className="h-5 w-5 text-primary" />
              Grupos Caseiros e Localização
            </CardTitle>
            <CardDescription className="mt-1">
              Encontre um grupo caseiro perto de você em Belo Horizonte.
            </CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent className="flex flex-1 flex-col p-4 pt-0">
        <div className="group relative isolate min-h-[400px] w-full flex-1 overflow-hidden rounded-xl border border-border/50 bg-secondary/10 shadow-inner">
          {!loading && (
            <MapContainer
              ref={mapRef}
              center={centerPosition}
              zoom={13}
              scrollWheelZoom={false}
              className="absolute inset-0 z-0 h-full w-full"
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
                    <p className="m-0 text-sm font-semibold">
                      Igreja em BH Central
                    </p>
                    <p className="m-0 text-xs text-muted-foreground">
                      Sede Principal
                    </p>
                    <Button
                      size="sm"
                      className="mt-2 h-8 w-full bg-primary text-xs hover:bg-primary/90"
                    >
                      <NavigationIcon className="mr-1 h-3 w-3" />
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
                      <div className="m-0 flex items-center gap-2 text-sm font-semibold text-primary">
                        <Users className="h-4 w-4" />
                        Grupo Caseiro
                      </div>
                      <div className="m-0 flex flex-col gap-1 text-xs text-muted-foreground">
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
          <div className="pointer-events-none absolute right-4 bottom-4 left-4 z-1000 flex items-center justify-between rounded-lg border border-border bg-background/80 p-4 shadow-lg backdrop-blur-md">
            <div>
              <p className="flex items-center gap-2 text-sm font-semibold text-foreground">
                <MapPinIcon className="h-4 w-4 text-primary" />
                Grupos Caseiros
              </p>
              <p className="mt-0.5 text-xs text-muted-foreground">
                {homeGroups.length > 0
                  ? `${homeGroups.length} grupo(s) encontrado(s)`
                  : loading
                    ? "Carregando..."
                    : "Nenhum grupo com localização"}
              </p>
            </div>
            <div className="pointer-events-auto">
              <Button
                size="sm"
                variant="outline"
                className="bg-background/50 hover:bg-background"
              >
                <NavigationIcon className="mr-2 h-4 w-4" />
                Igreja Central
              </Button>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
