import { z } from "zod";

/**
 * Validação de CPF brasileiro
 */
const validateCPF = (cpf: string) => {
  const cleanCPF = cpf.replace(/\D/g, "");

  if (cleanCPF.length !== 11) return false;
  if (/^(\d)\1+$/.test(cleanCPF)) return false;

  let sum = 0;
  let rest;

  for (let i = 1; i <= 9; i++) {
    sum = sum + parseInt(cleanCPF.substring(i - 1, i)) * (11 - i);
  }

  rest = (sum * 10) % 11;
  if (rest === 10 || rest === 11) rest = 0;
  if (rest !== parseInt(cleanCPF.substring(9, 10))) return false;

  sum = 0;
  for (let i = 1; i <= 10; i++) {
    sum = sum + parseInt(cleanCPF.substring(i - 1, i)) * (12 - i);
  }

  rest = (sum * 10) % 11;
  if (rest === 10 || rest === 11) rest = 0;
  if (rest !== parseInt(cleanCPF.substring(10, 11))) return false;

  return true;
};

export const passwordSchema = z.string()
  .min(8, { message: "A senha deve ter pelo menos 8 caracteres." })
  .max(32, { message: "A senha deve ter no máximo 32 caracteres." })
  .refine((val) => /[A-Z]/.test(val), {
    message: "A senha deve conter pelo menos uma letra maiúscula.",
  })
  .refine((val) => /[a-z]/.test(val), {
    message: "A senha deve conter pelo menos uma letra minúscula.",
  })
  .refine((val) => /[0-9]/.test(val), {
    message: "A senha deve conter pelo menos um número.",
  })
  .refine((val) => /[!@#$%^&*(),.?":{}|<>]/.test(val), {
    message: "A senha deve conter pelo menos um caractere especial.",
});

export const signInSchema = z.object({
  email: z.email({ message: "Email inválido" }),
  password: z.string().min(1, { message: "Senha é obrigatória" }),
});
export type SignInValue = z.infer<typeof signInSchema>;

export const signUpSchema = z.object({
  fullName: z.string().min(3, { message: "Nome completo deve ter pelo menos 3 caracteres." }),
  email: z.string().email({ message: "Email inválido" }),
  phone: z.string().refine((val) => /^\+55 \(\d{2}\) 9\d{4}-\d{4}$/.test(val), {
    message: "Telefone deve seguir o padrão: +55 (31) 9XXXX-XXXX",
  }),
  cpf: z.string().refine(validateCPF, {
    message: "CPF inválido",
  }),
  birthDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Data de nascimento inválida (AAAA-MM-DD)" }),
  baptismDate: z.union([z.string().regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Data de batismo inválida (AAAA-MM-DD)" }), z.literal("")]),
  gender: z.enum(["masculino", "feminino", "outro"] as const),
  maritalStatus: z.enum(["solteiro", "casado", "divorciado", "viuvo"] as const),
  addressZipCode: z.string().min(8, { message: "CEP inválido" }),
  addressStreet: z.string().min(3, { message: "Rua é obrigatória" }),
  addressNumber: z.string().min(1, { message: "Número é obrigatório" }),
  addressNeighborhood: z.string().min(2, { message: "Bairro é obrigatório" }),
  addressCity: z.string().min(2, { message: "Cidade é obrigatória" }),
  addressState: z.string().length(2, { message: "Estado deve ser a sigla (ex: MG)" }),
  addressComplement: z.string().optional(),
  password: passwordSchema,
  confirmPassword: z.string().min(1, { message: "Confirmação de senha é obrigatória" }),
  avatarUrl: z.string().optional(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "As senhas não coincidem.",
  path: ["confirmPassword"],
});
export type SignUpValue = z.infer<typeof signUpSchema>;
export const homeGroupSchema = z.object({
  meetingDay: z.number().min(0).max(6),
  startTime: z.string().regex(/^\d{2}:\d{2}$/, { message: "Horário inválido (HH:MM)" }),
  locationText: z.string().min(5, { message: "Endereço deve ter pelo menos 5 caracteres." }),
  leader1Id: z.string().uuid({ message: "Selecione um líder" }),
  leader2Id: z.string().uuid().optional().nullable(),
  lat: z.number().optional().nullable(),
  lng: z.number().optional().nullable(),
});
export type HomeGroupValue = z.infer<typeof homeGroupSchema>;
