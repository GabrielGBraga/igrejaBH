import { useState, useEffect } from "react";
import supabase from "@/lib/supabase";
import { 
  DollarSign, 
  Plus, 
  Trash2, 
  Edit, 
  TrendingUp, 
  TrendingDown, 
  Receipt, 
  Loader2,
  PieChart
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogDescription,
  DialogFooter
} from "@/components/ui/dialog";
import { Field, FieldLabel } from "@/components/ui/field";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { toast } from "sonner";
import type { Database } from "@/lib/database.types";

export type RetreatExpense = Database["public"]["Tables"]["retreat_expenses"]["Row"];

interface EventFinanceTabProps {
  retreatId: string;
  totalIncome: number;
  pendingIncome: number;
}

const CATEGORIES_MAP: Record<string, string> = {
  local: "Aluguel de Local / Sítio",
  alimentacao: "Alimentação / Cozinha",
  transporte: "Transporte / Ônibus",
  material: "Material & Impressões",
  som_multimidia: "Som & Multimídia",
  outros: "Outras Despesas",
};

export function EventFinanceTab({
  retreatId,
  totalIncome,
  pendingIncome,
}: EventFinanceTabProps) {
  const [expenses, setExpenses] = useState<RetreatExpense[]>([]);
  const [loadingExpenses, setLoadingExpenses] = useState(true);

  // Expense Dialog State
  const [isExpenseDialogOpen, setIsExpenseDialogOpen] = useState(false);
  const [editingExpense, setEditingExpense] = useState<RetreatExpense | null>(null);
  const [description, setDescription] = useState("");
  const [category, setCategory] = useState("outros");
  const [amount, setAmount] = useState<number | "">("");
  const [expenseDate, setExpenseDate] = useState(new Date().toISOString().split("T")[0]);
  const [expenseNotes, setExpenseNotes] = useState("");
  const [submittingExpense, setSubmittingExpense] = useState(false);

  useEffect(() => {
    if (retreatId) {
      fetchExpenses();
    }
  }, [retreatId]);

  async function fetchExpenses() {
    setLoadingExpenses(true);
    try {
      const { data, error } = await supabase
        .from("retreat_expenses")
        .select("*")
        .eq("retreat_id", retreatId)
        .order("expense_date", { ascending: false });

      if (error) throw error;
      setExpenses(data || []);
    } catch (err: any) {
      console.error("Erro ao buscar despesas:", err);
      toast.error("Erro ao carregar lançamentos de despesas.");
    } finally {
      setLoadingExpenses(false);
    }
  }

  const handleOpenCreateExpense = () => {
    setEditingExpense(null);
    setDescription("");
    setCategory("outros");
    setAmount("");
    setExpenseDate(new Date().toISOString().split("T")[0]);
    setExpenseNotes("");
    setIsExpenseDialogOpen(true);
  };

  const handleOpenEditExpense = (exp: RetreatExpense) => {
    setEditingExpense(exp);
    setDescription(exp.description);
    setCategory(exp.category || "outros");
    setAmount(exp.amount);
    setExpenseDate(exp.expense_date || new Date().toISOString().split("T")[0]);
    setExpenseNotes(exp.notes || "");
    setIsExpenseDialogOpen(true);
  };

  const handleSaveExpense = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!description.trim() || amount === "" || Number(amount) <= 0) {
      toast.error("Preencha uma descrição e um valor maior que zero.");
      return;
    }

    setSubmittingExpense(true);
    const payload = {
      retreat_id: retreatId,
      description: description.trim(),
      category,
      amount: Number(amount),
      expense_date: expenseDate,
      notes: expenseNotes.trim() || null,
    };

    try {
      if (editingExpense) {
        const { error } = await supabase
          .from("retreat_expenses")
          .update(payload)
          .eq("id", editingExpense.id);
        if (error) throw error;
        toast.success("Despesa atualizada com sucesso!");
      } else {
        const { error } = await supabase
          .from("retreat_expenses")
          .insert([payload]);
        if (error) throw error;
        toast.success("Gastos/Despesa lançada com sucesso!");
      }
      setIsExpenseDialogOpen(false);
      fetchExpenses();
    } catch (err: any) {
      toast.error("Erro ao salvar despesa: " + err.message);
    } finally {
      setSubmittingExpense(false);
    }
  };

  const handleDeleteExpense = async (expId: string) => {
    if (!confirm("Tem certeza que deseja excluir esta despesa lançada?")) return;
    try {
      const { error } = await supabase
        .from("retreat_expenses")
        .delete()
        .eq("id", expId);
      if (error) throw error;
      toast.success("Despesa excluída!");
      fetchExpenses();
    } catch (err: any) {
      toast.error("Erro ao excluir despesa: " + err.message);
    }
  };

  // Calculations
  const totalExpenses = expenses.reduce((acc, curr) => acc + Number(curr.amount || 0), 0);
  const netBalance = totalIncome - totalExpenses;
  const isPositiveBalance = netBalance >= 0;

  // Expenses category breakdown
  const categoryTotals: Record<string, number> = {};
  expenses.forEach(exp => {
    const cat = exp.category || "outros";
    categoryTotals[cat] = (categoryTotals[cat] || 0) + Number(exp.amount || 0);
  });

  return (
    <div className="space-y-6">
      {/* KPI Cards Header */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Total Collected */}
        <Card className="border border-emerald-500/20 bg-emerald-500/5">
          <CardContent className="p-5 flex items-center justify-between">
            <div>
              <span className="text-[11px] font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 block">
                Total Arrecadado (Bruto)
              </span>
              <span className="text-2xl font-black text-foreground mt-1 block">
                R$ {totalIncome.toFixed(2)}
              </span>
              <span className="text-[11px] text-muted-foreground mt-0.5 block">
                Confirmado em conta
              </span>
            </div>
            <div className="h-12 w-12 rounded-full bg-emerald-500/15 text-emerald-500 flex items-center justify-center shrink-0">
              <TrendingUp className="w-6 h-6" />
            </div>
          </CardContent>
        </Card>

        {/* Total Expenses */}
        <Card className="border border-red-500/20 bg-red-500/5">
          <CardContent className="p-5 flex items-center justify-between">
            <div>
              <span className="text-[11px] font-bold uppercase tracking-wider text-red-600 dark:text-red-400 block">
                Total de Gastos / Despesas
              </span>
              <span className="text-2xl font-black text-foreground mt-1 block">
                R$ {totalExpenses.toFixed(2)}
              </span>
              <span className="text-[11px] text-muted-foreground mt-0.5 block">
                {expenses.length} lançamento(s)
              </span>
            </div>
            <div className="h-12 w-12 rounded-full bg-red-500/15 text-red-500 flex items-center justify-center shrink-0">
              <TrendingDown className="w-6 h-6" />
            </div>
          </CardContent>
        </Card>

        {/* Net Balance (Profit / Deficit) */}
        <Card className={`border ${isPositiveBalance ? "border-primary/30 bg-primary/5" : "border-amber-500/30 bg-amber-500/5"}`}>
          <CardContent className="p-5 flex items-center justify-between">
            <div>
              <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground block">
                Resultado Líquido do Evento
              </span>
              <span className={`text-2xl font-black mt-1 block ${isPositiveBalance ? "text-emerald-500" : "text-amber-500"}`}>
                R$ {netBalance.toFixed(2)}
              </span>
              <span className="text-[11px] font-semibold text-muted-foreground mt-0.5 block">
                {isPositiveBalance ? "Superávit (Sobra)" : "Déficit (A pagar)"}
              </span>
            </div>
            <div className={`h-12 w-12 rounded-full flex items-center justify-center shrink-0 ${isPositiveBalance ? "bg-emerald-500/15 text-emerald-500" : "bg-amber-500/15 text-amber-500"}`}>
              <DollarSign className="w-6 h-6" />
            </div>
          </CardContent>
        </Card>

        {/* Pending Income */}
        <Card className="border border-border/60 bg-card/40">
          <CardContent className="p-5 flex items-center justify-between">
            <div>
              <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground block">
                Valor Pendente
              </span>
              <span className="text-2xl font-black text-foreground mt-1 block">
                R$ {pendingIncome.toFixed(2)}
              </span>
              <span className="text-[11px] text-muted-foreground mt-0.5 block">
                Aguardando pagamento
              </span>
            </div>
            <div className="h-12 w-12 rounded-full bg-muted text-muted-foreground flex items-center justify-center shrink-0">
              <Receipt className="w-6 h-6" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Main Expenses Table Section */}
      <Card className="border border-border/60 bg-card/40 shadow-sm rounded-2xl">
        <CardHeader className="p-6 border-b border-border/40 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <CardTitle className="text-lg font-bold text-foreground flex items-center gap-2">
              <Receipt className="w-5 h-5 text-primary" />
              Lançamento e Controle de Gastos
            </CardTitle>
            <CardDescription className="text-xs text-muted-foreground mt-0.5">
              Registre fornecedores, aluguel de espaço, alimentação e outras despesas operacionais do retiro.
            </CardDescription>
          </div>
          <Button 
            onClick={handleOpenCreateExpense}
            className="rounded-xl flex items-center gap-2 cursor-pointer self-start sm:self-auto"
          >
            <Plus className="w-4 h-4" /> Lançar Nova Despesa
          </Button>
        </CardHeader>

        <CardContent className="p-0">
          {loadingExpenses ? (
            <div className="p-8 text-center text-xs text-muted-foreground flex items-center justify-center gap-2">
              <Loader2 className="w-4 h-4 animate-spin" /> Carregando lançamentos...
            </div>
          ) : expenses.length === 0 ? (
            <div className="p-12 text-center space-y-3">
              <Receipt className="w-12 h-12 text-muted-foreground mx-auto" />
              <h4 className="font-bold text-foreground text-sm">Nenhum gasto ou despesa lançada</h4>
              <p className="text-xs text-muted-foreground max-w-sm mx-auto">
                Clique no botão "Lançar Nova Despesa" acima para manter a prestação de contas do evento atualizada.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="border-b border-border/50 hover:bg-transparent">
                    <TableHead className="w-[120px]">Data</TableHead>
                    <TableHead>Descrição do Gasto</TableHead>
                    <TableHead className="w-[180px]">Categoria</TableHead>
                    <TableHead className="text-right w-[140px]">Valor (R$)</TableHead>
                    <TableHead className="text-right w-[100px]">Ações</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {expenses.map((exp) => (
                    <TableRow key={exp.id} className="border-b border-border/40">
                      <TableCell className="text-xs font-medium text-muted-foreground">
                        {exp.expense_date ? new Date(exp.expense_date + "T00:00:00").toLocaleDateString("pt-BR") : "S/D"}
                      </TableCell>
                      <TableCell className="font-semibold text-xs text-foreground">
                        {exp.description}
                        {exp.notes && (
                          <span className="block text-[11px] font-normal text-muted-foreground mt-0.5">
                            {exp.notes}
                          </span>
                        )}
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="text-[10px] font-bold uppercase rounded-full">
                          {CATEGORIES_MAP[exp.category || "outros"] || exp.category}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right font-bold text-xs text-red-500">
                        - R$ {Number(exp.amount).toFixed(2)}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 w-8 p-0 cursor-pointer text-muted-foreground hover:text-foreground"
                            onClick={() => handleOpenEditExpense(exp)}
                          >
                            <Edit className="w-3.5 h-3.5" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 w-8 p-0 cursor-pointer text-red-500 hover:bg-red-500/10"
                            onClick={() => handleDeleteExpense(exp.id)}
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Expense Category Breakdown */}
      {expenses.length > 0 && (
        <Card className="border border-border/60 bg-card/40 p-6 rounded-2xl space-y-4">
          <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
            <PieChart className="w-4 h-4 text-primary" /> Distribuição de Despesas por Categoria
          </h4>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
            {Object.entries(categoryTotals).map(([catKey, total]) => {
              const pct = totalExpenses > 0 ? (total / totalExpenses) * 100 : 0;
              return (
                <div key={catKey} className="bg-muted/30 border border-border/30 p-3.5 rounded-xl space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-bold text-foreground">
                      {CATEGORIES_MAP[catKey] || catKey}
                    </span>
                    <span className="font-extrabold text-red-500">
                      R$ {total.toFixed(2)}
                    </span>
                  </div>
                  <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-red-500 rounded-full transition-all duration-300"
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                  <span className="text-[10px] text-muted-foreground block text-right font-semibold">
                    {pct.toFixed(1)}% do total de gastos
                  </span>
                </div>
              );
            })}
          </div>
        </Card>
      )}

      {/* Dialog para Lançar / Editar Despesa */}
      <Dialog open={isExpenseDialogOpen} onOpenChange={setIsExpenseDialogOpen}>
        <DialogContent className="sm:max-w-md max-w-full rounded-2xl border border-border bg-card p-6">
          <DialogHeader>
            <DialogTitle className="text-lg font-bold text-foreground">
              {editingExpense ? "Editar Lançamento de Gasto" : "Lançar Nova Despesa"}
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Informe a descrição do gasto, categoria e valor da despesa do evento.
            </DialogDescription>
          </DialogHeader>

          <form onSubmit={handleSaveExpense} className="space-y-4 py-2">
            <Field>
              <FieldLabel htmlFor="description">Descrição da Despesa / Fornecedor *</FieldLabel>
              <Input
                id="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Ex: Aluguel do Sítio Ebenezer, Açougue da Serra"
                required
              />
            </Field>

            <div className="grid grid-cols-2 gap-4">
              <Field>
                <FieldLabel htmlFor="amount">Valor (R$) *</FieldLabel>
                <Input
                  id="amount"
                  type="number"
                  step="0.01"
                  min="0.01"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value === "" ? "" : Number(e.target.value))}
                  placeholder="0.00"
                  required
                />
              </Field>

              <Field>
                <FieldLabel htmlFor="expenseDate">Data do Gasto</FieldLabel>
                <Input
                  id="expenseDate"
                  type="date"
                  value={expenseDate}
                  onChange={(e) => setExpenseDate(e.target.value)}
                />
              </Field>
            </div>

            <Field>
              <FieldLabel htmlFor="category">Categoria da Despesa</FieldLabel>
              <Select value={category} onValueChange={setCategory}>
                <SelectTrigger id="category">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {Object.entries(CATEGORIES_MAP).map(([key, label]) => (
                    <SelectItem key={key} value={key}>{label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </Field>

            <Field>
              <FieldLabel htmlFor="expenseNotes">Notas Adicionais (Opcional)</FieldLabel>
              <Input
                id="expenseNotes"
                value={expenseNotes}
                onChange={(e) => setExpenseNotes(e.target.value)}
                placeholder="Ex: Nota fiscal nº 1234, pago via Pix do Presbitério"
              />
            </Field>

            <DialogFooter className="pt-2">
              <Button type="button" variant="outline" onClick={() => setIsExpenseDialogOpen(false)}>
                Cancelar
              </Button>
              <Button type="submit" disabled={submittingExpense} className="cursor-pointer">
                {submittingExpense ? <Loader2 className="w-4 h-4 animate-spin" /> : "Salvar Despesa"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
