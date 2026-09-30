import { Link } from "react-router-dom"
import { BookOpen, Play, CheckCircle2, GraduationCap } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card"
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
    <Card className="flex flex-col justify-between rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
      <CardHeader className="space-y-1.5 pb-3">
        <div className="flex items-start justify-between gap-2">
          <div className="space-y-1">
            <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
              <BookOpen className="h-5 w-5 text-primary shrink-0" />
              <span>Catequese & Ensinos</span>
            </CardTitle>
            <CardDescription className="text-xs font-medium text-primary">
              Crescimento e maturidade na Palavra
            </CardDescription>
          </div>
          <Badge
            variant="outline"
            className="shrink-0 gap-1 rounded-full border-primary/30 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary"
          >
            <GraduationCap className="h-3 w-3" />
            Trilhas
          </Badge>
        </div>
      </CardHeader>

      <CardContent className="space-y-4 py-2">
        {!studyInfo ? (
          <div className="rounded-lg border border-border/60 bg-muted/30 p-3.5 text-xs text-muted-foreground">
            <p className="leading-relaxed">
              Inicie os estudos apostólicos da igreja. A Trilha 1 apresenta o fundamento bíblico do Propósito Eterno de Deus!
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            <div>
              <span className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground block">
                Trilha em Andamento
              </span>
              <h4 className="text-sm font-bold text-foreground leading-snug">
                {studyInfo.studyTitle}
              </h4>
              {studyInfo.nextStepTitle && (
                <p className="mt-1 text-xs text-muted-foreground line-clamp-1">
                  Próxima lição: <span className="text-foreground font-medium">{studyInfo.nextStepTitle}</span>
                </p>
              )}
            </div>

            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-xs">
                <span className="text-muted-foreground">Progresso</span>
                <span className="font-bold text-primary">{percent}% concluído</span>
              </div>
              <Progress value={percent} className="h-2" />
              <div className="flex items-center justify-between text-[11px] text-muted-foreground">
                <span>{studyInfo.completedSteps} de {studyInfo.totalSteps} etapas</span>
                {percent === 100 && (
                  <span className="flex items-center gap-1 font-semibold text-emerald-600 dark:text-emerald-400">
                    <CheckCircle2 className="h-3 w-3" />
                    Concluída!
                  </span>
                )}
              </div>
            </div>
          </div>
        )}
      </CardContent>

      <CardFooter className="pt-3">
        <Button
          asChild
          variant="default"
          size="sm"
          className="btn-tactile min-h-[44px] w-full justify-center gap-2 text-xs font-semibold shadow-xs"
        >
          <Link to="/ensinos">
            <Play className="h-3.5 w-3.5 fill-current" />
            {studyInfo && percent > 0 && percent < 100 ? "Retomar Estudo" : "Acessar Centro de Ensinos"}
          </Link>
        </Button>
      </CardFooter>
    </Card>
  )
}
