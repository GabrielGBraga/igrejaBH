import { useNavigate } from "react-router-dom";
import { 
  Calendar, 
  MapPin, 
  Users, 
  ArrowRight, 
  MoreVertical, 
  Edit, 
  Trash2, 
  CheckCircle2, 
  FileText 
} from "lucide-react";
import { Card, CardContent, CardFooter, CardHeader } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import type { Database } from "@/lib/database.types";

export type RetreatWithForm = Database["public"]["Tables"]["retreats"]["Row"] & {
  forms?: {
    name: string;
  } | null;
  registrations_count?: number;
};

interface EventCardProps {
  retreat: RetreatWithForm;
  registeredCount?: number;
  onEdit?: (retreat: RetreatWithForm) => void;
  onDelete?: (retreatId: string) => void;
  onActivate?: (retreatId: string) => void;
}

export function EventCard({
  retreat,
  registeredCount = 0,
  onEdit,
  onDelete,
  onActivate,
}: EventCardProps) {
  const navigate = useNavigate();

  const maxCapacity = retreat.max_participants || 100;
  const occupancyRate = Math.min(100, Math.round((registeredCount / maxCapacity) * 100));
  const remainingSpots = Math.max(0, maxCapacity - registeredCount);

  const formatDateRange = (start?: string | null, end?: string | null) => {
    if (!start) return "Data a definir";
    const startDate = new Date(start).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
    if (!end || end === start) return startDate;
    const endDate = new Date(end).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
    return `${startDate} — ${endDate}`;
  };

  const getStatusBadge = (status?: string | null) => {
    switch (status) {
      case "ativo":
        return (
          <Badge
            variant="outline"
            className="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 text-[11px] font-bold tracking-wide uppercase px-2.5 py-0.5"
          >
            Ativo
          </Badge>
        );
      case "rascunho":
        return (
          <Badge
            variant="outline"
            className="bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/30 text-[11px] font-bold tracking-wide uppercase px-2.5 py-0.5"
          >
            Rascunho
          </Badge>
        );
      case "encerrado":
      default:
        return (
          <Badge
            variant="outline"
            className="bg-zinc-500/10 text-zinc-600 dark:text-zinc-400 border-zinc-500/30 text-[11px] font-bold tracking-wide uppercase px-2.5 py-0.5"
          >
            Encerrado
          </Badge>
        );
    }
  };

  const formattedPrice =
    retreat.price && retreat.price > 0
      ? new Intl.NumberFormat("pt-BR", {
          style: "currency",
          currency: "BRL",
        }).format(retreat.price)
      : "Gratuito";

  return (
    <Card className="group flex flex-col justify-between rounded-xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 shadow-sm transition-all duration-200 hover:border-zinc-300 dark:hover:border-zinc-700 hover:shadow-md overflow-hidden relative">
      {/* Header */}
      <CardHeader className="p-5 pb-3">
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-2 flex-wrap">
            {getStatusBadge(retreat.status)}
            <span className="text-xs font-bold text-zinc-900 dark:text-zinc-50 bg-zinc-100 dark:bg-zinc-800 px-2.5 py-0.5 rounded-full">
              {formattedPrice}
            </span>
          </div>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="min-h-[44px] min-w-[44px] h-11 w-11 text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer -mr-2"
                aria-label="Opções do evento"
              >
                <MoreVertical className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-44">
              {onEdit && (
                <DropdownMenuItem
                  onClick={() => onEdit(retreat)}
                  className="cursor-pointer text-xs flex items-center gap-2"
                >
                  <Edit className="h-3.5 w-3.5 text-zinc-500" />
                  Editar Detalhes
                </DropdownMenuItem>
              )}
              {retreat.status === "rascunho" && onActivate && (
                <DropdownMenuItem
                  onClick={() => onActivate(retreat.id)}
                  className="cursor-pointer text-xs flex items-center gap-2 text-emerald-600 dark:text-emerald-400"
                >
                  <CheckCircle2 className="h-3.5 w-3.5" />
                  Ativar Retiro
                </DropdownMenuItem>
              )}
              {onDelete && (
                <>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem
                    onClick={() => onDelete(retreat.id)}
                    className="cursor-pointer text-xs flex items-center gap-2 text-red-600 dark:text-red-400"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                    Excluir Retiro
                  </DropdownMenuItem>
                </>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        <h3 className="text-lg font-bold text-zinc-900 dark:text-zinc-50 mt-2 line-clamp-2 leading-snug group-hover:text-primary transition-colors">
          {retreat.title}
        </h3>

        {retreat.description && (
          <p className="text-xs text-zinc-500 dark:text-zinc-400 line-clamp-2 mt-1 leading-relaxed">
            {retreat.description}
          </p>
        )}
      </CardHeader>

      {/* Content & Metadata */}
      <CardContent className="p-5 pt-0 space-y-4">
        <div className="space-y-2 text-xs text-zinc-600 dark:text-zinc-400 border-t border-zinc-100 dark:border-zinc-800/80 pt-3">
          <div className="flex items-center gap-2">
            <Calendar className="h-3.5 w-3.5 text-zinc-400 shrink-0" />
            <span className="truncate">{formatDateRange(retreat.start_date, retreat.end_date)}</span>
          </div>

          <div className="flex items-center gap-2">
            <MapPin className="h-3.5 w-3.5 text-zinc-400 shrink-0" />
            <span className="truncate">
              {retreat.location_text || "Local a confirmar"}
            </span>
          </div>

          {retreat.forms?.name && (
            <div className="flex items-center gap-2 text-primary dark:text-primary/90">
              <FileText className="h-3.5 w-3.5 shrink-0" />
              <span className="truncate font-medium">Ficha: {retreat.forms.name}</span>
            </div>
          )}
        </div>

        {/* Capacity / Occupancy Bar */}
        <div className="space-y-1.5 bg-zinc-50 dark:bg-zinc-800/40 p-3 rounded-lg border border-zinc-100 dark:border-zinc-800/50">
          <div className="flex justify-between items-center text-xs">
            <span className="font-semibold text-zinc-700 dark:text-zinc-300 flex items-center gap-1.5">
              <Users className="h-3.5 w-3.5 text-zinc-500" />
              Lotação
            </span>
            <span className="font-bold text-zinc-900 dark:text-zinc-100">
              {registeredCount} / {maxCapacity} ({occupancyRate}%)
            </span>
          </div>

          <Progress value={occupancyRate} className="h-2 bg-zinc-200 dark:bg-zinc-700" />

          <div className="flex justify-between items-center text-[11px] text-zinc-500 pt-0.5">
            <span>
              {remainingSpots > 0 ? `${remainingSpots} vagas restantes` : "Lotação completa"}
            </span>
            {occupancyRate >= 90 && remainingSpots > 0 && (
              <span className="text-amber-600 dark:text-amber-400 font-semibold">
                Quase esgotado
              </span>
            )}
          </div>
        </div>
      </CardContent>

      {/* Footer / Manage Event CTA */}
      <CardFooter className="p-5 pt-0 border-t border-zinc-100 dark:border-zinc-800/60 mt-2">
        <Button
          onClick={() => navigate(`/manage-events/${retreat.id}`)}
          className="w-full min-h-[44px] h-11 bg-zinc-900 hover:bg-zinc-800 text-zinc-50 dark:bg-zinc-50 dark:hover:bg-zinc-200 dark:text-zinc-900 rounded-lg font-bold text-xs flex items-center justify-center gap-2 cursor-pointer shadow-sm transition-all group/btn"
        >
          <span>Gerenciar Evento</span>
          <ArrowRight className="h-4 w-4 transition-transform group-hover/btn:translate-x-1" />
        </Button>
      </CardFooter>
    </Card>
  );
}
