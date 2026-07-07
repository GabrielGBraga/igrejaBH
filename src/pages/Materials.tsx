import { useState, useEffect } from "react"
import {
  YoutubeIcon,
  FileTextIcon,
  BookOpenIcon,
  PlusIcon,
  SearchIcon,
  Loader2Icon,
} from "lucide-react"
import { cn } from "@/lib/utils"
import supabase from "@/lib/supabase"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { fetchLatestVideos, type YouTubeVideo } from "@/lib/youtube"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

type TabType = "videos" | "pdfs" | "textos"

interface Profile {
  is_presbyter: boolean
  is_deacon: boolean
  is_dev: boolean
}

export default function Materials() {
  const [activeTab, setActiveTab] = useState<TabType>("videos")
  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")

  // YouTube states
  const [videos, setVideos] = useState<YouTubeVideo[]>([])
  const [loadingVideos, setLoadingVideos] = useState(false)
  const [selectedVideo, setSelectedVideo] = useState<YouTubeVideo | null>(null)

  useEffect(() => {
    async function fetchProfile() {
      const {
        data: { session },
      } = await supabase.auth.getSession()
      if (session?.user) {
        const { data } = await supabase
          .from("profiles")
          .select("is_presbyter, is_deacon, is_dev")
          .eq("user_id", session.user.id)
          .single()
        setProfile(
          data
            ? {
                is_presbyter: !!data.is_presbyter,
                is_deacon: !!data.is_deacon,
                is_dev: !!data.is_dev,
              }
            : null
        )
      }
      setLoading(false)
    }
    fetchProfile()
  }, [])

  useEffect(() => {
    async function loadVideos() {
      if (activeTab === "videos" && videos.length === 0) {
        setLoadingVideos(true)
        const fetchedVideos = await fetchLatestVideos()
        setVideos(fetchedVideos)
        setLoadingVideos(false)
      }
    }
    loadVideos()
  }, [activeTab])

  const canAddMaterial =
    profile?.is_presbyter || profile?.is_deacon || profile?.is_dev

  const tabs = [
    { id: "videos", label: "Vídeos", icon: YoutubeIcon },
    { id: "pdfs", label: "PDFs", icon: FileTextIcon },
    { id: "textos", label: "Textos", icon: BookOpenIcon },
  ]

  if (loading) {
    return (
      <div className="flex h-[60vh] items-center justify-center">
        <Loader2Icon className="h-8 w-8 animate-spin text-primary" />
      </div>
    )
  }

  return (
    <div className="animate-in space-y-8 duration-500 fade-in slide-in-from-bottom-4">
      <div className="flex flex-col justify-between gap-4 border-b border-border pb-6 md:flex-row md:items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">
            Materiais e Recursos
          </h1>
          <p className="mt-1 text-muted-foreground">
            Acesse vídeos, apostilas e outros materiais da nossa igreja.
          </p>
        </div>
        {canAddMaterial && (
          <Button className="shrink-0 gap-2 rounded-full px-6 shadow-lg shadow-primary/20">
            <PlusIcon className="h-4 w-4" />
            Adicionar Material
          </Button>
        )}
      </div>

      <div className="flex flex-col gap-6">
        <div className="flex flex-col items-start justify-between gap-4 md:flex-row md:items-center">
          {/* Tabs Switcher */}
          <div className="no-scrollbar flex w-full overflow-x-auto rounded-2xl border border-border/50 bg-muted/30 p-1 backdrop-blur-sm md:w-fit">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as TabType)}
                className={cn(
                  "flex flex-1 items-center justify-center gap-2 rounded-xl px-6 py-2.5 text-sm font-medium whitespace-nowrap transition-all md:flex-none",
                  activeTab === tab.id
                    ? "bg-primary text-primary-foreground shadow-sm"
                    : "text-muted-foreground hover:bg-muted/50 hover:text-foreground"
                )}
              >
                <tab.icon className="h-4 w-4" />
                {tab.label}
              </button>
            ))}
          </div>

          {/* Search Bar */}
          <div className="group relative w-full md:max-w-xs">
            <SearchIcon className="absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-muted-foreground transition-colors group-focus-within:text-primary" />
            <Input
              placeholder="Buscar materiais..."
              className="rounded-xl border-border/50 bg-card/30 pl-10 backdrop-blur-sm transition-all focus:border-primary/50 focus:ring-2 focus:ring-primary/20"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>

        {/* Content Sections */}
        <div className="min-h-[400px]">
          {activeTab === "videos" && (
            <div className="animate-in duration-500 fade-in slide-in-from-bottom-4">
              {loadingVideos ? (
                <div className="flex items-center justify-center py-24">
                  <Loader2Icon className="h-10 w-10 animate-spin text-primary" />
                </div>
              ) : videos.length > 0 ? (
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
                  {videos.map((video) => (
                    <Card
                      key={video.id}
                      className="group flex cursor-pointer flex-col overflow-hidden rounded-2xl border-border/50 bg-card/30 backdrop-blur-sm transition-all hover:border-primary/30 hover:shadow-xl hover:shadow-primary/5"
                      onClick={() => setSelectedVideo(video)}
                    >
                      <div className="relative flex aspect-video shrink-0 items-center justify-center overflow-hidden bg-muted">
                        <img
                          src={video.thumbnailUrl}
                          alt={video.title}
                          className="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110"
                        />
                        <div className="absolute inset-0 flex items-center justify-center bg-black/40 transition-colors group-hover:bg-black/20">
                          <div className="flex h-14 w-14 scale-50 transform items-center justify-center rounded-full border-4 border-white/20 bg-primary/90 opacity-0 shadow-xl transition-all duration-300 group-hover:scale-100 group-hover:opacity-100">
                            <YoutubeIcon className="ml-1 h-7 w-7 text-primary-foreground" />
                          </div>
                        </div>
                      </div>
                      <CardHeader className="flex-1 p-5">
                        <CardTitle
                          className="line-clamp-2 text-base leading-tight text-foreground transition-colors group-hover:text-primary"
                          title={video.title}
                        >
                          {video.title}
                        </CardTitle>
                        <CardDescription className="pt-1 text-xs">
                          {new Date(video.publishedAt).toLocaleDateString(
                            "pt-BR"
                          )}
                        </CardDescription>
                      </CardHeader>
                    </Card>
                  ))}
                </div>
              ) : (
                <div className="rounded-3xl border border-dashed border-border/50 bg-card/30 py-24 text-center backdrop-blur-sm">
                  <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-muted/50">
                    <YoutubeIcon className="h-10 w-10 text-muted-foreground/30" />
                  </div>
                  <h3 className="text-xl font-medium text-foreground">
                    Nenhum vídeo encontrado
                  </h3>
                  <p className="mx-auto mt-2 max-w-sm text-muted-foreground">
                    Os vídeos do canal da igreja aparecerão aqui
                    automaticamente.
                  </p>
                </div>
              )}
            </div>
          )}

          {activeTab === "pdfs" && (
            <div className="grid animate-in grid-cols-1 gap-6 duration-500 fade-in slide-in-from-bottom-4 sm:grid-cols-2 lg:grid-cols-4">
              {[1, 2, 3, 4].map((i) => (
                <Card
                  key={i}
                  className="group flex flex-col overflow-hidden rounded-2xl border-border/50 bg-card/30 backdrop-blur-sm transition-all hover:border-blue-500/30 hover:shadow-xl"
                >
                  <CardHeader className="flex-1 p-6">
                    <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-500/10 transition-transform duration-300 group-hover:scale-110">
                      <FileTextIcon className="h-6 w-6 text-blue-500" />
                    </div>
                    <CardTitle className="text-lg text-foreground transition-colors group-hover:text-blue-500">
                      Apostila {i}
                    </CardTitle>
                    <CardDescription>Estudo Bíblico • PDF</CardDescription>
                  </CardHeader>
                  <CardContent className="p-6 pt-0">
                    <Button
                      variant="outline"
                      className="w-full gap-2 rounded-xl border-border/50 transition-all hover:bg-blue-500 hover:text-white"
                    >
                      Baixar Arquivo
                    </Button>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {activeTab === "textos" && (
            <div className="mx-auto w-full max-w-4xl animate-in duration-500 fade-in slide-in-from-bottom-4">
              <div className="space-y-4">
                {[1, 2].map((i) => (
                  <Card
                    key={i}
                    className="group cursor-pointer overflow-hidden rounded-2xl border-border/50 bg-card/30 backdrop-blur-sm transition-all hover:bg-primary/5"
                  >
                    <CardHeader className="p-6">
                      <div className="flex items-center justify-between">
                        <div className="space-y-1">
                          <CardTitle className="text-xl text-foreground transition-colors group-hover:text-primary">
                            Guia de Leitura e Oração {i}
                          </CardTitle>
                          <CardDescription>
                            23 de Março, 2026 • 5 min de leitura
                          </CardDescription>
                        </div>
                        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 transition-transform duration-300 group-hover:scale-110">
                          <BookOpenIcon className="h-5 w-5 text-primary" />
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="px-6 pt-0 pb-6">
                      <p className="line-clamp-2 text-muted-foreground">
                        Acesse o conteúdo detalhado com orientações para sua
                        devocional diária e estudos complementares.
                      </p>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      <Dialog
        open={!!selectedVideo}
        onOpenChange={(open) => !open && setSelectedVideo(null)}
      >
        <DialogContent className="w-[95vw] overflow-hidden rounded-3xl border-white/10 bg-black/95 p-0 shadow-2xl sm:max-w-6xl">
          <DialogHeader className="sr-only">
            <DialogTitle>{selectedVideo?.title}</DialogTitle>
          </DialogHeader>
          {selectedVideo && (
            <div className="flex aspect-video w-full items-center justify-center bg-black">
              <iframe
                width="100%"
                height="100%"
                src={`https://www.youtube.com/embed/${selectedVideo.id}?autoplay=1`}
                title={selectedVideo.title}
                frameBorder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
                className="h-full w-full"
              ></iframe>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
