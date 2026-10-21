import { Link } from "react-router-dom"
import { BookOpen, Play, CheckCircle2, ChevronRight, GraduationCap } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"

export interface ActiveStudyInfo {
  studyId: string
  studyTitle: string
  totalSteps: number
  completedSteps: number
  nextStepTitle?: string | null
}

interface StudyProgressCardProps {
  studyInfo: ActiveStudyInfo | null
  loading?: boolean
}

export function StudyProgressCard({ studyInfo, loading = false }: StudyProgressCardProps) {
  if (loading) {
    return (
      <Card className="rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-2 pb-3">
          <div className="h-5 w-36 animate-pulse rounded bg-muted" />
          <div className="h-4 w-48 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="h-8 w-full animate-pulse rounded-lg bg-muted" />
          <div className="h-4 w-full animate-pulse rounded-full bg-muted" />
        </CardContent>
      </Card>
    )
  }

  const percent =
    studyInfo && studyInfo.totalSteps > 0
      ? Math.round((studyInfo.completedSteps / studyInfo.totalSteps) * 100)
      : 0

  return (
    <Card className="rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
      <CardHeader className="space-y-1 pb-3">
        <div className="flex items-center justify-between gap-2">
          <div className="space-y-0.5">
            <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
              <BookOpen className="h-5 w-5 text-primary shrink-0" />
              <span>Catequese &amp; Ensinos</span>
            </CardTitle>
            <CardDescription className="text-xs font-medium text-muted-foreground">
              Crescimento e maturidade na Palavra
            </CardDescription>
          </div>
          <Button
            asChild
            variant="ghost"
            size="sm"
            className="h-8 gap-1 text-xs font-semibold text-primary hover:text-primary/90"
          >
            <Link to="/ensinos">
              Ver todas as trilhas
              <ChevronRight className="h-3.5 w-3.5" />
            </Link>
          </Button>
        </div>
      </CardHeader>

      <CardContent className="space-y-3 pt-0 pb-4">
        {!studyInfo ? (
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 rounded-lg border border-border/60 bg-muted/20 p-4">
            <div className="space-y-1">
              <span className="text-xs font-bold text-foreground">Fundamentos da Fé</span>
              <p className="text-xs text-muted-foreground">
                Inicie os estudos apostólicos da igreja. A Trilha 1 apresenta o fundamento bíblico do Propósito Eterno de Deus!
              </p>
            </div>
            <Button asChild size="sm" className="btn-tactile min-h-[44px] shrink-0 text-xs font-semibold">
              <Link to="/ensinos">
                <Play className="h-3.5 w-3.5 fill-current mr-1" />
                Iniciar Trilha 1
              </Link>
            </Button>
          </div>
        ) : (
          <div className="rounded-lg border border-border/60 bg-muted/20 p-4 space-y-3">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <Badge
                variant="outline"
                className="gap-1.5 rounded-md border-primary/25 bg-primary/10 px-2 py-0.5 text-[11px] font-semibold text-primary"
              >
                <GraduationCap className="h-3.5 w-3.5" />
                {studyInfo.studyTitle}
              </Badge>
              <span className="text-xs text-muted-foreground font-medium">
                {studyInfo.completedSteps} de {studyInfo.totalSteps} etapas • {percent}% concluído
              </span>
            </div>

            {studyInfo.nextStepTitle && (
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">
                  Próxima Lição
                </span>
                <h4 className="text-sm font-semibold text-foreground leading-snug">
                  {studyInfo.nextStepTitle}
                </h4>
              </div>
            )}

            <div className="space-y-1.5">
              <Progress value={percent} className="h-2" />
            </div>

            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pt-1 border-t border-border/40">
              <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                {percent === 100 ? (
                  <span className="flex items-center gap-1 font-semibold text-emerald-600 dark:text-emerald-400">
                    <CheckCircle2 className="h-3.5 w-3.5" />
                    Trilha Concluída!
                  </span>
                ) : (
                  <span>Etapa atual em andamento</span>
                )}
              </div>

              <Button
                asChild
                size="sm"
                className="btn-tactile min-h-[44px] sm:min-h-[38px] justify-center gap-1.5 text-xs font-semibold shadow-xs"
              >
                <Link to="/ensinos">
                  <Play className="h-3.5 w-3.5 fill-current" />
                  {percent > 0 && percent < 100 ? "Retomar Estudo" : "Acessar Lições"}
                </Link>
              </Button>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
