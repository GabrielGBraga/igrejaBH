import { useEffect, useState, useMemo } from "react"
import supabase from "@/lib/supabase"
import { Sparkles } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { HomeGroupCard } from "@/components/home/HomeGroupCard"
import { DiscipleshipCard } from "@/components/home/DiscipleshipCard"
import { StudyProgressCard, type ActiveStudyInfo } from "@/components/home/StudyProgressCard"
import { CommunityCalendarCard, type CommunityEvent } from "@/components/home/CommunityCalendarCard"
import { NewsTimeline } from "@/components/home/NewsTimeline"
import type { Database } from "@/lib/database.types"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"] & {
  sectors?: Database["public"]["Tables"]["sectors"]["Row"] | null
  leader_1?: Database["public"]["Tables"]["profiles"]["Row"] | null
  leader_2?: Database["public"]["Tables"]["profiles"]["Row"] | null
}

type ProfileSummary = Pick<Profile, "id" | "full_name" | "avatar_url" | "phone">

// Versículos focados no Propósito Eterno e edificação mútua
const dailyVerses = [
  {
    verse:
      "Porque os que dantes conheceu, também os predestinou para serem conformes à imagem de seu Filho, a fim de que ele seja o primogênito entre muitos irmãos.",
    reference: "Romanos 8:29",
    theme: "O Propósito Eterno",
  },
  {
    verse:
      "Do qual todo o corpo, bem ajustado e ligado pelo auxílio de todas as juntas, segundo a justa operação de cada parte, faz o aumento do corpo, para sua edificação em amor.",
    reference: "Efésios 4:16",
    theme: "Juntas e Ligamentos",
  },
  {
    verse:
      "E perseveravam na doutrina dos apóstolos, e na comunhão, e no partir do pão, e nas orações.",
    reference: "Atos 2:42",
    theme: "A Vida Comum",
  },
  {
    verse:
      "Habite ricamente em vós a palavra de Cristo, em toda a sabedoria, ensinando-vos e admoestando-vos uns aos outros.",
    reference: "Colossenses 3:16",
    theme: "Sacerdócio Universal",
  },
]

export default function Home() {
  const [profile, setProfile] = useState<Profile | null>(null)
  const [homeGroup, setHomeGroup] = useState<HomeGroup | null>(null)
  const [groupMembers, setGroupMembers] = useState<ProfileSummary[]>([])
  const [discipler, setDiscipler] = useState<ProfileSummary | null>(null)
  const [disciples, setDisciples] = useState<ProfileSummary[]>([])
  const [fellows, setFellows] = useState<ProfileSummary[]>([])
  const [studyInfo, setStudyInfo] = useState<ActiveStudyInfo | null>(null)
  const [communityEvents, setCommunityEvents] = useState<CommunityEvent[]>([])
  const [loading, setLoading] = useState(true)

  // Seleciona um versículo do dia baseado no dia do ano
  const todaysVerse = useMemo(() => {
    const dayOfYear = Math.floor(
      (Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) /
        1000 /
        60 /
        60 /
        24
    )
    return dailyVerses[dayOfYear % dailyVerses.length]
  }, [])

  useEffect(() => {
    let isMounted = true

    async function loadDashboardData() {
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession()

        if (!session?.user) {
          if (isMounted) setLoading(false)
          return
        }

        // 1. Carrega o perfil do discípulo logado
        const { data: userProfile } = await supabase
          .from("profiles")
          .select("*")
          .eq("user_id", session.user.id)
          .maybeSingle()

        if (!userProfile) {
          if (isMounted) setLoading(false)
          return
        }

        if (isMounted) setProfile(userProfile)

        // 2. Carrega dados do Grupo Caseiro e dos seus membros
        if (userProfile.home_group_id) {
          const { data: hgData } = await supabase
            .from("home_groups")
            .select(`
              *,
              sectors (*),
              leader_1:profiles!home_groups_leader_1_id_fkey (*),
              leader_2:profiles!home_groups_leader_2_id_fkey (*)
            `)
            .eq("id", userProfile.home_group_id)
            .maybeSingle()

          if (isMounted && hgData) {
            setHomeGroup(hgData as unknown as HomeGroup)
          }

          const { data: membersData } = await supabase
            .from("profiles")
            .select("id, full_name, avatar_url, phone")
            .eq("home_group_id", userProfile.home_group_id)
            .order("full_name")

          if (isMounted && membersData) {
            setGroupMembers(membersData)
          }
        }

        // 3. Carrega Juntas e Ligamentos (Discipulador, Discípulos e Fellows)
        if (userProfile.discipler_id) {
          const { data: disciplerData } = await supabase
            .from("profiles")
            .select("id, full_name, avatar_url, phone")
            .eq("id", userProfile.discipler_id)
            .maybeSingle()

          if (isMounted && disciplerData) {
            setDiscipler(disciplerData)
          }
        }

        // Discípulos que eu acompanho
        const { data: disciplesData } = await supabase
          .from("profiles")
          .select("id, full_name, avatar_url, phone")
          .eq("discipler_id", userProfile.id)

        if (isMounted && disciplesData) {
          setDisciples(disciplesData)
        }

        // Companheiros de Jugo (fellowships)
        const [fellowsARes, fellowsBRes] = await Promise.all([
          supabase
            .from("fellowships")
            .select("member_b:profiles!fellowships_member_b_id_fkey(id, full_name, avatar_url, phone)")
            .eq("member_a_id", userProfile.id),
          supabase
            .from("fellowships")
            .select("member_a:profiles!fellowships_member_a_id_fkey(id, full_name, avatar_url, phone)")
            .eq("member_b_id", userProfile.id),
        ])

        const combinedFellows: ProfileSummary[] = []
        fellowsARes.data?.forEach((f) => {
          if (f.member_b) combinedFellows.push(f.member_b as ProfileSummary)
        })
        fellowsBRes.data?.forEach((f) => {
          if (f.member_a) combinedFellows.push(f.member_a as ProfileSummary)
        })

        if (isMounted) {
          setFellows(combinedFellows)
        }

        // 4. Carrega Progresso de Estudos / Catequese
        const { data: allStudies } = await supabase
          .from("studies")
          .select(`
            id,
            title,
            study_steps (
              id,
              sort_order,
              media_resources (
                id,
                title
              )
            )
          `)
          .order("created_at", { ascending: true })

        const { data: userProgress } = await supabase
          .from("user_study_progress")
          .select("step_id")
          .eq("profile_id", userProfile.id)

        if (allStudies && allStudies.length > 0) {
          const completedStepIds = new Set(userProgress?.map((p) => p.step_id) || [])

          // Encontra o primeiro estudo ainda não 100% concluído, ou o último
          let activeStudy = allStudies[0]
          let activeNextStepTitle: string | null = null
          let completedInActive = 0
          let totalInActive = 0

          for (const study of allStudies) {
            const steps = study.study_steps || []
            const completedCount = steps.filter((s: { id: string }) => completedStepIds.has(s.id)).length
            if (completedCount < steps.length) {
              activeStudy = study
              completedInActive = completedCount
              totalInActive = steps.length
              const nextStep = steps.find((s: { id: string }) => !completedStepIds.has(s.id))
              const mediaRes = nextStep?.media_resources as { id: string; title: string } | null
              activeNextStepTitle = mediaRes?.title || null
              break
            }
          }

          // Se concluiu todos os estudos
          if (totalInActive === 0 && activeStudy.study_steps) {
            totalInActive = activeStudy.study_steps.length
            completedInActive = totalInActive
          }

          if (isMounted) {
            setStudyInfo({
              studyId: activeStudy.id,
              studyTitle: activeStudy.title,
              totalSteps: totalInActive || 1,
              completedSteps: completedInActive,
              nextStepTitle: activeNextStepTitle,
            })
          }
        }

        // 5. Carrega Encontros da Igreja na Cidade (posts com datas)
        const { data: eventsData } = await supabase
          .from("posts")
          .select("*")
          .eq("is_published", true)
          .not("event_start_date", "is", null)
          .order("event_start_date", { ascending: true })

        if (isMounted && eventsData) {
          setCommunityEvents(eventsData)
        }
      } catch (err) {
        console.error("Erro ao carregar dashboard:", err)
      } finally {
        if (isMounted) setLoading(false)
      }
    }

    loadDashboardData()

    return () => {
      isMounted = false
    }
  }, [])

  const firstName = profile?.full_name ? profile.full_name.split(" ")[0] : ""

  return (
    <div className="mx-auto max-w-5xl animate-in space-y-8 pb-12 duration-500 fade-in slide-in-from-bottom-4">
      {/* 1. Header Fraternal & Versículo do Dia */}
      <header className="space-y-4 border-b border-border/60 pb-6">
        <div>
          <h1 className="text-2xl font-extrabold tracking-tight text-foreground sm:text-3xl">
            {profile ? `Bem-vindo(a), ${firstName}` : "Bem-vindo(a)"}
          </h1>
          <p className="mt-1 text-xs text-muted-foreground sm:text-sm">
            Portal de Vida Comum • A Igreja em Belo Horizonte
          </p>
        </div>

        {/* Card Sutil do Versículo do Dia (Propósito Eterno) */}
        <div className="rounded-xl border border-border/70 border-l-4 border-l-primary bg-card/60 p-4 shadow-2xs backdrop-blur-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-wider text-primary">
              <Sparkles className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
              Versículo do Dia • {todaysVerse.theme}
            </span>
            <Badge variant="outline" className="border-border text-[10px] font-semibold text-muted-foreground">
              {todaysVerse.reference}
            </Badge>
          </div>
          <p className="mt-2 text-xs italic leading-relaxed text-muted-foreground sm:text-sm">
            &ldquo;{todaysVerse.verse}&rdquo;
          </p>
        </div>
      </header>

      {/* 2. Grid Principal: 4 Eixos da Vida Orgânica */}
      <section aria-label="Eixos da Vida Comum">
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          {/* Card 1: Meu Grupo Caseiro (Oikos) */}
          <HomeGroupCard
            homeGroup={homeGroup}
            members={groupMembers}
            loading={loading}
          />

          {/* Card 2: Juntas e Ligamentos (Rede de Discipulado) */}
          <DiscipleshipCard
            discipler={discipler}
            disciples={disciples}
            fellows={fellows}
            loading={loading}
          />

          {/* Card 3: Catequese & Ensinos */}
          <StudyProgressCard
            studyInfo={studyInfo}
            loading={loading}
          />

          {/* Card 4: Encontros da Igreja na Cidade (Calendário & Agenda Casual) */}
          <CommunityCalendarCard
            events={communityEvents}
            loading={loading}
          />
        </div>
      </section>

      {/* 3. Rodapé: Timeline Simples de Avisos da Comunidade */}
      <section id="mural" aria-label="Avisos e Comunicados" className="pt-2">
        <NewsTimeline />
      </section>
    </div>
  )
}
