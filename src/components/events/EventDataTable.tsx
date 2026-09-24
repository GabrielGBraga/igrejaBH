import { useState, useMemo, useEffect } from "react";
import {
  useLegacyTable as useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  type LegacyColumnDef as ColumnDef,
} from "@tanstack/react-table/legacy";
import { flexRender, type SortingState } from "@tanstack/react-table";
import {
  Search,
  ArrowUpDown,
  Download,
  Eye,
  Check,
  X,
  Trash2,
  Bed,
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
} from "lucide-react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import type { RegistrationWithDetails } from "./RegistrationDetailDialog";

interface GuestDataShape {
  full_name?: string;
  email?: string;
  phone?: string;
  cpf?: string;
  gender?: string;
}

interface EventDataTableProps {
  data: RegistrationWithDetails[];
  isLoading?: boolean;
  onViewDetails: (reg: RegistrationWithDetails) => void;
  onTogglePayment: (reg: RegistrationWithDetails) => void;
  onAssignRoomClick: (reg: RegistrationWithDetails) => void;
  onDeleteRegistration: (reg: RegistrationWithDetails) => void;
  onExportData: (filteredRecords?: RegistrationWithDetails[]) => void;
  onFilteredDataChange?: (filtered: RegistrationWithDetails[]) => void;
}

export function EventDataTable({
  data,
  isLoading = false,
  onViewDetails,
  onTogglePayment,
  onAssignRoomClick,
  onDeleteRegistration,
  onExportData,
  onFilteredDataChange,
}: EventDataTableProps) {
  const [sorting, setSorting] = useState<SortingState>([
    { id: "created_at", desc: true },
  ]);
  const [globalFilter, setGlobalFilter] = useState("");
  const [paymentFilter, setPaymentFilter] = useState<string>("all");
  const [roomFilter, setRoomFilter] = useState<string>("all");
  const [pagination, setPagination] = useState({
    pageIndex: 0,
    pageSize: 10,
  });

  // Extract gender helper
  const getParticipantGender = (reg: RegistrationWithDetails): string => {
    const customResps = reg.custom_responses as Record<string, unknown> | null;
    const guestData = reg.guest_data as GuestDataShape | null;

    if (customResps) {
      for (const [key, val] of Object.entries(customResps)) {
        if (
          key.toLowerCase().includes("gênero") ||
          key.toLowerCase().includes("genero") ||
          key.toLowerCase().includes("sexo")
        ) {
          const valStr = String(val).toLowerCase();
          if (valStr.includes("masculino") || valStr === "m" || valStr.includes("homem"))
            return "masculino";
          if (valStr.includes("feminino") || valStr === "f" || valStr.includes("mulher"))
            return "feminino";
        }
      }
    }
    if (guestData?.gender) {
      const gStr = String(guestData.gender).toLowerCase();
      if (gStr.includes("masculino") || gStr === "m" || gStr.includes("homem"))
        return "masculino";
      if (gStr.includes("feminino") || gStr === "f" || gStr.includes("mulher"))
        return "feminino";
    }
    return "indefinido";
  };

  // Define Table Columns
  const columns = useMemo<ColumnDef<RegistrationWithDetails>[]>(
    () => [
      {
        id: "participant",
        accessorFn: (row) => {
          const guest = row.guest_data as GuestDataShape | null;
          return row.profiles?.full_name || guest?.full_name || "Desconhecido";
        },
        header: ({ column }) => (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="p-0 h-auto font-bold text-xs text-zinc-900 dark:text-zinc-50 hover:bg-transparent flex items-center gap-1.5 cursor-pointer"
          >
            Participante
            <ArrowUpDown className="h-3 w-3 text-zinc-400" />
          </Button>
        ),
        cell: ({ row }) => {
          const reg = row.original;
          const guest = reg.guest_data as GuestDataShape | null;
          const name = reg.profiles?.full_name || guest?.full_name || "Desconhecido";
          const email = reg.profiles?.email || guest?.email || "Sem e-mail";
          const phone = reg.profiles?.phone || guest?.phone || "Sem telefone";

          return (
            <div className="space-y-0.5 min-w-[180px]">
              <div className="font-bold text-xs text-zinc-900 dark:text-zinc-50 leading-tight">
                {name}
              </div>
              <div className="text-[11px] text-zinc-500 dark:text-zinc-400 truncate max-w-[220px]">
                {email} • {phone}
              </div>
            </div>
          );
        },
      },
      {
        id: "cpf",
        accessorFn: (row) => {
          const guest = row.guest_data as GuestDataShape | null;
          return row.profiles?.cpf || guest?.cpf || "S/C";
        },
        header: () => (
          <span className="font-bold text-xs text-zinc-900 dark:text-zinc-50">CPF</span>
        ),
        cell: ({ getValue }) => (
          <span className="text-xs font-mono text-zinc-600 dark:text-zinc-400">
            {getValue<string>()}
          </span>
        ),
      },
      {
        id: "gender",
        accessorFn: (row) => getParticipantGender(row),
        header: () => (
          <span className="font-bold text-xs text-zinc-900 dark:text-zinc-50">Gênero</span>
        ),
        cell: ({ getValue }) => {
          const gender = getValue<string>();
          return (
            <Badge
              variant="outline"
              className={`text-[10px] font-bold uppercase capitalize px-2 py-0.5 ${
                gender === "masculino"
                  ? "bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/30"
                  : gender === "feminino"
                  ? "bg-pink-500/10 text-pink-600 dark:text-pink-400 border-pink-500/30"
                  : "bg-zinc-500/10 text-zinc-600 dark:text-zinc-400 border-zinc-500/30"
              }`}
            >
              {gender}
            </Badge>
          );
        },
      },
      {
        id: "payment_status",
        accessorFn: (row) => (row.paid ? "pago" : "pendente"),
        header: ({ column }) => (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="p-0 h-auto font-bold text-xs text-zinc-900 dark:text-zinc-50 hover:bg-transparent flex items-center gap-1.5 cursor-pointer"
          >
            Pagamento
            <ArrowUpDown className="h-3 w-3 text-zinc-400" />
          </Button>
        ),
        cell: ({ row }) => {
          const reg = row.original;
          return (
            <div className="flex items-center gap-2">
              <Badge
                variant="outline"
                className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full ${
                  reg.paid
                    ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30"
                    : "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/30"
                }`}
              >
                {reg.paid ? "Pago" : "Pendente"}
              </Badge>
              {reg.payment_method && (
                <span className="text-[10px] uppercase font-semibold text-zinc-500">
                  ({reg.payment_method})
                </span>
              )}
            </div>
          );
        },
      },
      {
        id: "room_allocation",
        accessorFn: (row) =>
          row.retreat_rooms?.name || row.room_allocation || "Não alocado",
        header: () => (
          <span className="font-bold text-xs text-zinc-900 dark:text-zinc-50">
            Alojamento / Quarto
          </span>
        ),
        cell: ({ row }) => {
          const reg = row.original;
          const roomName =
            reg.retreat_rooms?.name || reg.room_allocation || "Não alocado";
          const isAllocated =
            roomName !== "Não alocado" && Boolean(reg.room_id || reg.room_allocation);

          return (
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onAssignRoomClick(reg)}
                    className="min-h-[44px] h-11 sm:min-h-[36px] sm:h-9 text-xs font-semibold rounded-lg flex items-center gap-1.5 cursor-pointer hover:bg-primary/10 hover:border-primary/40 px-3"
                  >
                    <Bed className="w-3.5 h-3.5 text-primary shrink-0" />
                    <span
                      className={
                        !isAllocated
                          ? "text-zinc-500 dark:text-zinc-400 italic font-normal"
                          : "font-bold text-zinc-900 dark:text-zinc-100"
                      }
                    >
                      {roomName}
                    </span>
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p className="text-xs">Clique para selecionar ou alterar o quarto</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          );
        },
      },
      {
        id: "created_at",
        accessorFn: (row) => row.created_at || "",
        header: ({ column }) => (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="p-0 h-auto font-bold text-xs text-zinc-900 dark:text-zinc-50 hover:bg-transparent flex items-center gap-1.5 cursor-pointer"
          >
            Inscrição
            <ArrowUpDown className="h-3 w-3 text-zinc-400" />
          </Button>
        ),
        cell: ({ getValue }) => {
          const dateVal = getValue<string>();
          return (
            <span className="text-xs text-zinc-500 dark:text-zinc-400 whitespace-nowrap">
              {dateVal
                ? new Date(dateVal).toLocaleDateString("pt-BR", {
                    day: "2-digit",
                    month: "2-digit",
                    year: "numeric",
                  })
                : "—"}
            </span>
          );
        },
      },
      {
        id: "actions",
        header: () => (
          <span className="font-bold text-xs text-zinc-900 dark:text-zinc-50 text-right block pr-2">
            Ações
          </span>
        ),
        cell: ({ row }) => {
          const reg = row.original;
          return (
            <div className="flex items-center justify-end gap-1.5 pr-1">
              {/* Ver Detalhes */}
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => onViewDetails(reg)}
                      className="min-h-[44px] h-11 sm:min-h-[36px] sm:h-9 px-2.5 text-xs font-semibold text-primary hover:bg-primary/10 rounded-md cursor-pointer flex items-center gap-1"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      <span className="hidden sm:inline">Detalhes</span>
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p className="text-xs">Ver ficha e respostas completas</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              {/* Toggle Pagamento */}
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => onTogglePayment(reg)}
                      className={`min-h-[44px] min-w-[44px] h-11 w-11 sm:min-h-[36px] sm:min-w-[36px] sm:h-9 sm:w-9 rounded-md cursor-pointer ${
                        reg.paid
                          ? "text-emerald-600 hover:bg-emerald-500/10 dark:text-emerald-400"
                          : "text-amber-600 hover:bg-amber-500/10 dark:text-amber-400"
                      }`}
                      aria-label={reg.paid ? "Marcar como pendente" : "Confirmar pagamento"}
                    >
                      {reg.paid ? <Check className="w-4 h-4" /> : <X className="w-4 h-4" />}
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p className="text-xs">
                      {reg.paid ? "Marcar como pendente" : "Confirmar pagamento"}
                    </p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              {/* Excluir */}
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => onDeleteRegistration(reg)}
                      className="min-h-[44px] min-w-[44px] h-11 w-11 sm:min-h-[36px] sm:min-w-[36px] sm:h-9 sm:w-9 text-red-500 hover:bg-red-500/10 rounded-md cursor-pointer"
                      aria-label="Excluir inscrição"
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p className="text-xs">Excluir inscrição permanentemente</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>
            </div>
          );
        },
      },
    ],
    [onViewDetails, onTogglePayment, onAssignRoomClick, onDeleteRegistration]
  );

  // Filter dataset based on global search, payment filter, and room filter
  const filteredData = useMemo(() => {
    return data.filter((item) => {
      // 1. Payment filter
      if (paymentFilter === "paid" && !item.paid) return false;
      if (paymentFilter === "pending" && item.paid) return false;

      // 2. Room filter
      const hasRoom = Boolean(
        item.room_id ||
          (item.room_allocation && item.room_allocation !== "Não alocado")
      );
      if (roomFilter === "allocated" && !hasRoom) return false;
      if (roomFilter === "unallocated" && hasRoom) return false;

      // 3. Global search
      if (globalFilter.trim() !== "") {
        const query = globalFilter.toLowerCase();
        const guest = item.guest_data as GuestDataShape | null;
        const name = (item.profiles?.full_name || guest?.full_name || "").toLowerCase();
        const email = (item.profiles?.email || guest?.email || "").toLowerCase();
        const cpf = (item.profiles?.cpf || guest?.cpf || "").toLowerCase();
        const phone = (item.profiles?.phone || guest?.phone || "").toLowerCase();
        const room = (item.retreat_rooms?.name || item.room_allocation || "").toLowerCase();

        const matches =
          name.includes(query) ||
          email.includes(query) ||
          cpf.includes(query) ||
          phone.includes(query) ||
          room.includes(query);

        if (!matches) return false;
      }

      return true;
    });
  }, [data, paymentFilter, roomFilter, globalFilter]);

  useEffect(() => {
    onFilteredDataChange?.(filteredData);
  }, [filteredData, onFilteredDataChange]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: {
      sorting,
      pagination,
    },
    onSortingChange: setSorting,
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  return (
    <div className="space-y-4 w-full">
      {/* Controls Bar: Search, Filters & Export */}
      <div className="flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3 bg-white dark:bg-zinc-900 p-4 rounded-xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
        {/* Global Search Input */}
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Buscar por nome, e-mail, CPF, quarto..."
            value={globalFilter}
            onChange={(e) => {
              setGlobalFilter(e.target.value);
              setPagination((prev) => ({ ...prev, pageIndex: 0 }));
            }}
            className="pl-9 min-h-[44px] h-11 text-xs rounded-lg"
          />
        </div>

        {/* Filter Dropdowns & Export */}
        <div className="flex flex-wrap items-center gap-2.5">
          {/* Payment Status Filter */}
          <div className="w-[150px]">
            <Select
              value={paymentFilter}
              onValueChange={(val) => {
                setPaymentFilter(val);
                setPagination((prev) => ({ ...prev, pageIndex: 0 }));
              }}
            >
              <SelectTrigger className="min-h-[44px] h-11 text-xs">
                <SelectValue placeholder="Pagamento" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Todos Pagamentos</SelectItem>
                <SelectItem value="paid">Apenas Pagos</SelectItem>
                <SelectItem value="pending">Apenas Pendentes</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Room Allocation Filter */}
          <div className="w-[160px]">
            <Select
              value={roomFilter}
              onValueChange={(val) => {
                setRoomFilter(val);
                setPagination((prev) => ({ ...prev, pageIndex: 0 }));
              }}
            >
              <SelectTrigger className="min-h-[44px] h-11 text-xs">
                <SelectValue placeholder="Alojamento" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Todos os Quartos</SelectItem>
                <SelectItem value="allocated">Alocados em Quarto</SelectItem>
                <SelectItem value="unallocated">Sem Quarto (Pendentes)</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Export Button */}
          <Button
            variant="outline"
            onClick={() => onExportData(filteredData)}
            className="min-h-[44px] h-11 px-4 text-xs font-semibold rounded-lg flex items-center gap-2 cursor-pointer shrink-0"
          >
            <Download className="h-4 w-4 text-zinc-500" />
            <span>Exportar CSV</span>
          </Button>
        </div>
      </div>

      {/* Table Container */}
      <div className="rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 shadow-sm overflow-hidden relative">
        <div className="overflow-x-auto">
          <Table className="w-full">
            <TableHeader className="bg-zinc-50 dark:bg-zinc-800/60 border-b border-zinc-200 dark:border-zinc-800">
              {table.getHeaderGroups().map((headerGroup) => (
                <TableRow key={headerGroup.id} className="hover:bg-transparent">
                  {headerGroup.headers.map((header) => (
                    <TableHead key={header.id} className="py-3 px-4">
                      {header.isPlaceholder
                        ? null
                        : flexRender(
                            header.column.columnDef.header,
                            header.getContext()
                          )}
                    </TableHead>
                  ))}
                </TableRow>
              ))}
            </TableHeader>
            <TableBody className="divide-y divide-zinc-200 dark:divide-zinc-800">
              {isLoading ? (
                <TableRow>
                  <TableCell
                    colSpan={columns.length}
                    className="h-32 text-center text-xs text-zinc-500 dark:text-zinc-400"
                  >
                    Carregando inscrições...
                  </TableCell>
                </TableRow>
              ) : table.getRowModel().rows?.length ? (
                table.getRowModel().rows.map((row) => (
                  <TableRow
                    key={row.id}
                    className="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors"
                  >
                    {row.getVisibleCells().map((cell) => (
                      <TableCell key={cell.id} className="py-3 px-4">
                        {flexRender(
                          cell.column.columnDef.cell,
                          cell.getContext()
                        )}
                      </TableCell>
                    ))}
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell
                    colSpan={columns.length}
                    className="h-32 text-center text-xs text-zinc-500 dark:text-zinc-400"
                  >
                    Nenhuma inscrição encontrada com os filtros aplicados.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </div>

        {/* Pagination Bar */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3 p-4 border-t border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/50 text-xs text-zinc-600 dark:text-zinc-400">
          <div className="flex items-center gap-2">
            <span>Linhas por página:</span>
            <Select
              value={String(table.getState().pagination.pageSize)}
              onValueChange={(val) => table.setPageSize(Number(val))}
            >
              <SelectTrigger className="min-h-[44px] h-11 w-[75px] text-xs">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="10">10</SelectItem>
                <SelectItem value="25">25</SelectItem>
                <SelectItem value="50">50</SelectItem>
              </SelectContent>
            </Select>
            <span className="hidden sm:inline ml-2 text-zinc-500">
              Total de <strong>{filteredData.length}</strong> participantes
            </span>
          </div>

          <div className="flex items-center gap-2">
            <span>
              Página <strong>{table.getState().pagination.pageIndex + 1}</strong> de{" "}
              <strong>{Math.max(1, table.getPageCount())}</strong>
            </span>

            <div className="flex items-center gap-1">
              <Button
                variant="outline"
                size="icon"
                onClick={() => table.setPageIndex(0)}
                disabled={!table.getCanPreviousPage()}
                className="min-h-[44px] min-w-[44px] h-11 w-11 cursor-pointer"
                aria-label="Primeira página"
              >
                <ChevronsLeft className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                size="icon"
                onClick={() => table.previousPage()}
                disabled={!table.getCanPreviousPage()}
                className="min-h-[44px] min-w-[44px] h-11 w-11 cursor-pointer"
                aria-label="Página anterior"
              >
                <ChevronLeft className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                size="icon"
                onClick={() => table.nextPage()}
                disabled={!table.getCanNextPage()}
                className="min-h-[44px] min-w-[44px] h-11 w-11 cursor-pointer"
                aria-label="Próxima página"
              >
                <ChevronRight className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                size="icon"
                onClick={() => table.setPageIndex(table.getPageCount() - 1)}
                disabled={!table.getCanNextPage()}
                className="min-h-[44px] min-w-[44px] h-11 w-11 cursor-pointer"
                aria-label="Última página"
              >
                <ChevronsRight className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
